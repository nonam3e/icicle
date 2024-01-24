
#define CURVE_ID 3 // TODO Yuval: move to makefile

#include "../../primitives/field.cuh"
#include "../../primitives/projective.cuh"
#include "../../utils/cuda_utils.cuh"
#include <chrono>
#include <iostream>
#include <vector>

#include "curves/curve_config.cuh"
#include "ntt/ntt.cu"

// #define PERFORMANCE

typedef curve_config::scalar_t test_scalar;
#include "kernel_ntt.cu"

#define $CUDA(call)                                                                                                    \
  if ((call) != 0) {                                                                                                   \
    printf("\nCall \"" #call "\" failed from %s, line %d, error=%d\n", __FILE__, __LINE__, cudaGetLastError());        \
    exit(1);                                                                                                           \
  }

void random_samples(test_scalar* res, uint32_t count)
{
  for (int i = 0; i < count; i++)
    res[i] = i < 1000 ? test_scalar::rand_host() : res[i - 1000];
  // res[i]= i==0? test_scalar::one() : test_scalar::zero();
  // res[i]= i%2? test_scalar::one() : (test_scalar::one() - test_scalar::one() - test_scalar::one());
  // res[i]= i==0? test_scalar::one() : test_scalar::omega_inv(25) * res[i-1];
}

void incremental_values(test_scalar* res, uint32_t count)
{
  for (int i = 0; i < count; i++)
    res[i] = i ? res[i - 1] + test_scalar::one() * test_scalar::omega(4) : test_scalar::zero();
}

int main()
{
#ifdef PERFORMANCE
  cudaEvent_t icicle_start, icicle_stop, new_start, new_stop;
  float icicle_time, new_time;
#endif

  int NTT_LOG_SIZE = 19;
  int TT_LOG_SIZE = NTT_LOG_SIZE;
  int NTT_SIZE = 1 << NTT_LOG_SIZE;
  int TT_SIZE = 1 << TT_LOG_SIZE;
  int INV = false;
  int DIT = false;
  printf("running ntt 2^%d ", NTT_LOG_SIZE);
  if (DIT)
    printf("DIT ");
  else
    printf("DIF ");
  if (INV)
    printf("inverse\n");
  else
    printf("\n");

  // cpu allocation
  test_scalar* cpuIcicle;
  uint4* cpuNew;
  uint4* cpuNew2;
  // uint4* cpuTwiddles;
  cpuIcicle = (test_scalar*)malloc(sizeof(test_scalar) * NTT_SIZE);
  cpuNew = (uint4*)malloc(sizeof(uint4) * NTT_SIZE * 2);
  cpuNew2 = (uint4*)malloc(sizeof(uint4) * NTT_SIZE * 2);
  // cpuTwiddles = (uint4*)malloc(sizeof(uint4) * 6);
  if (cpuIcicle == NULL || cpuNew == NULL || cpuNew2 == NULL) {
    fprintf(stderr, "Malloc failed\n");
    exit(1);
  }

  // gpu allocation
  test_scalar *gpuIcicle, *gpuIcicleOutput;
  uint4* gpuNew;
  uint4* gpuNew2;
  uint4* gpuTwiddles;
  uint4* gpuIntTwiddles;
  uint4* gpuBasicTwiddles;
  $CUDA(cudaMalloc((void**)&gpuIcicle, sizeof(test_scalar) * NTT_SIZE));
  $CUDA(cudaMalloc((void**)&gpuIcicleOutput, sizeof(test_scalar) * NTT_SIZE));
  $CUDA(cudaMalloc((void**)&gpuNew, sizeof(uint4) * NTT_SIZE * 2));
  $CUDA(cudaMalloc((void**)&gpuNew2, sizeof(uint4) * NTT_SIZE * 2));
  $CUDA(cudaMalloc((void**)&gpuTwiddles, sizeof(uint4) * (TT_SIZE + 2 * (TT_SIZE >> 4)) * 2)); // TODO - sketchy
  $CUDA(cudaMalloc((void**)&gpuBasicTwiddles, sizeof(uint4) * 3 * 2));
  // $CUDA(cudaMalloc((void**)&gpuIntTwiddles, sizeof(uint4)*TT_SIZE*2));

  // init inputs
  random_samples(cpuIcicle, NTT_SIZE);
  // incremental_values(cpuIcicle, NTT_SIZE);
  for (int i = 0; i < NTT_SIZE; i++) {
    cpuNew[i] = cpuIcicle[i].load_half(false);
    cpuNew[NTT_SIZE + i] = cpuIcicle[i].load_half(true);
    // cpuNew[NTT_SIZE + i] = cpuIcicle[i].load_half(false);
    cpuNew2[i] = uint4{0, 0, 0, 0};
    cpuNew2[NTT_SIZE + i] = uint4{0, 0, 0, 0};
  }
  // printf("input\n");
  // for(int i=0;i<NTT_SIZE;i++){
  //   // if (i%16 == 0) printf("\n");
  //   // std::cout <<cpuIcicle[i]<<std::endl;
  //   std::cout <<cpuNew[i].w<<cpuNew[i+NTT_SIZE].w<<std::endl;
  // }

  $CUDA(cudaMemcpy(gpuIcicle, cpuIcicle, sizeof(test_scalar) * NTT_SIZE, cudaMemcpyHostToDevice));
  $CUDA(cudaMemcpy(gpuNew, cpuNew, sizeof(uint4) * NTT_SIZE * 2, cudaMemcpyHostToDevice));
  $CUDA(cudaMemcpy(gpuNew2, cpuNew2, sizeof(uint4) * NTT_SIZE * 2, cudaMemcpyHostToDevice));
  const test_scalar basic_root = INV ? test_scalar::omega_inv(NTT_LOG_SIZE) : test_scalar::omega(NTT_LOG_SIZE);
  gpuIntTwiddles = generate_external_twiddles(basic_root, gpuTwiddles, gpuBasicTwiddles, TT_LOG_SIZE, INV);
  printf("finished generating twiddles\n");
  // generate_internal_twiddles<<<1,1>>>(gpuIntTwiddles);
  // cudaDeviceSynchronize();
  // printf("cuda err tw %d\n",cudaGetLastError());

#ifdef PERFORMANCE
  $CUDA(cudaEventCreate(&icicle_start));
  $CUDA(cudaEventCreate(&icicle_stop));
  $CUDA(cudaEventCreate(&new_start));
  $CUDA(cudaEventCreate(&new_stop));

  // run ntts
  int count = 100;
  $CUDA(cudaEventRecord(new_start, 0));
  // ntt64<<<1, 8, 512*sizeof(uint4)>>>(gpuNew, gpuNew, gpuTwiddles, NTT_LOG_SIZE ,1,0);
  for (size_t i = 0; i < count; i++) {
    new_ntt(gpuNew, gpuNew, gpuTwiddles, gpuIntTwiddles, gpuBasicTwiddles, NTT_LOG_SIZE, INV, DIT);
  }
  // new_ntt(gpuNew, gpuNew2, gpuTwiddles, NTT_LOG_SIZE);
  $CUDA(cudaEventRecord(new_stop, 0));
  $CUDA(cudaDeviceSynchronize());
  $CUDA(cudaEventElapsedTime(&new_time, new_start, new_stop));
  cudaDeviceSynchronize();
  printf("cuda err %d\n", cudaGetLastError());
  test_scalar* icicle_tw;
  // icicle_tw = fill_twiddle_factors_array(NTT_SIZE, test_scalar::omega(NTT_LOG_SIZE), 0);
  $CUDA(cudaEventRecord(icicle_start, 0));
  // for (size_t i = 0; i < count; i++)
  // ntt_inplace_batch_template<test_scalar, test_scalar>(gpuIcicle, icicle_tw, NTT_SIZE, 1, INV, false, nullptr, 0,
  // false);
  $CUDA(cudaEventRecord(icicle_stop, 0));
  $CUDA(cudaDeviceSynchronize());
  $CUDA(cudaEventElapsedTime(&icicle_time, icicle_start, icicle_stop));
  cudaDeviceSynchronize();
  printf("cuda err %d\n", cudaGetLastError());
  fprintf(stderr, "Icicle Runtime=%0.3f MS\n", icicle_time / count);
  fprintf(stderr, "New Runtime=%0.3f MS\n", new_time / count);
#else
  if (DIT)
    reorder_digits_kernel<<<(1 << (max(NTT_LOG_SIZE, 6) - 6)), min(64, 1 << NTT_LOG_SIZE)>>>(
      gpuNew, gpuNew2, NTT_LOG_SIZE, DIT);
  new_ntt(
    DIT ? gpuNew2 : gpuNew, DIT ? gpuNew : gpuNew2, gpuTwiddles, gpuIntTwiddles, gpuBasicTwiddles, NTT_LOG_SIZE, INV,
    DIT);
  if (!DIT)
    reorder_digits_kernel<<<(1 << (max(NTT_LOG_SIZE, 6) - 6)), min(64, 1 << NTT_LOG_SIZE)>>>(
      gpuNew2, gpuNew, NTT_LOG_SIZE, DIT);
  printf("finished new\n");

  auto ntt_config = ntt::DefaultNTTConfig<test_scalar>();
  ntt_config.are_inputs_on_device = true;
  ntt_config.are_outputs_on_device = true;
  ntt::InitDomain(basic_root, ntt_config.ctx);
  ntt::NTT(gpuIcicle, NTT_SIZE, INV ? ntt::NTTDir::kInverse : ntt::NTTDir::kForward, ntt_config, gpuIcicleOutput);

  printf("finished icicle\n");

  // verify
  $CUDA(cudaMemcpy(cpuIcicle, gpuIcicleOutput, sizeof(test_scalar) * NTT_SIZE, cudaMemcpyDeviceToHost));
  $CUDA(cudaMemcpy(cpuNew, gpuNew, sizeof(uint4) * NTT_SIZE * 2, cudaMemcpyDeviceToHost));
  $CUDA(cudaMemcpy(cpuNew2, gpuNew2, sizeof(uint4) * NTT_SIZE * 2, cudaMemcpyDeviceToHost));
  // $CUDA(cudaMemcpy(cpuTwiddles, gpuBasicTwiddles, sizeof(uint4)*3*2, cudaMemcpyDeviceToHost));
  // for (int i = 0; i < 3; i++)
  // {
  //   test_scalar new_temp;
  //   new_temp.store_half(cpuTwiddles[i], false);
  //   new_temp.store_half(cpuTwiddles[i+3], true);
  //   // if (i%64 == 0) printf("%d\n",i/64);
  //   std::cout << new_temp <<std::endl;
  // }
  // printf("\n\n");

  bool success = true;
  for (int i = 0; i < NTT_SIZE; i++)
  // for (int i = 0; i < 64*4; i++)
  {
    test_scalar icicle_temp, new_temp;
    icicle_temp = cpuIcicle[i];
    // new_temp.store_half(cpuTwiddles[2*64*64*64 + i], false);
    // new_temp.store_half(cpuTwiddles[2*64*64*64 + i+64*NTT_SIZE], true);
    // new_temp.store_half(cpuTwiddles[i], false);
    // new_temp.store_half(cpuTwiddles[i+NTT_SIZE], true);
    new_temp.store_half(cpuNew[i], false);
    new_temp.store_half(cpuNew[i + NTT_SIZE], true);
    // if (i%(32*32*32) < 64*2) if (i%32 == 0) printf("%d\n",i/32);
    // if (i%16 == 0) printf("%d\n",i/16);
    // if (i%(32*32*32*32) == 1){
    // if (new_temp != test_scalar::zero()){
    if (icicle_temp != new_temp) {
      success = false;
      // std::cout << i << " ref " << icicle_temp << " != " << new_temp << std::endl;
      // break;
      // if (i%(1048576) < 64*2) std::cout << i<< " ref "<< icicle_temp << " != " << new_temp <<std::endl;
      // if (i < 64*2) std::cout << "ref "<< icicle_temp << " != " << new_temp <<std::endl;
    } else {
      // std::cout << i << " ref " << icicle_temp << " == " << new_temp << std::endl;
      // if (i%(1048576)< 64*2) std::cout << i<< " ref "<< icicle_temp << " == " << new_temp <<std::endl;
      // if (i< 64*2) std::cout << "ref "<< icicle_temp << " == " << new_temp <<std::endl;
    }
    // }
  }
  const char* success_str = success ? "SUCCESS!" : "FAIL!";
  printf("%s\n", success_str);
#endif

  return 0;
}