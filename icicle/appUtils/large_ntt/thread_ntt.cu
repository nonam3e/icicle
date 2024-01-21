#ifndef T_NTT
#define T_NTT
#pragma once

#include <stdio.h>
#include <stdint.h>

struct stage_metadata
{
  uint32_t th_stride;
  uint32_t ntt_block_size;
  uint32_t ntt_block_id;
  uint32_t ntt_inp_id;
};

uint32_t constexpr STAGE_SIZES_HOST[31][5] = {{0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {4,0,0,0,0},
                              {5,0,0,0,0}, //5
                              {6,0,0,0,0}, //6
                              {0,0,0,0,0},
                              {4,4,0,0,0},
                              {5,4,0,0,0},
                              {6,4,0,0,0}, //10
                              {6,5,0,0,0}, //11
                              {6,6,0,0,0}, //12
                              {5,4,4,0,0},
                              {6,4,4,0,0},
                              {6,5,4,0,0}, //15
                              {6,5,5,0,0}, //16
                              {6,6,5,0,0}, //17
                              {6,6,6,0,0}, //18
                              {6,5,4,4,0},
                              {5,5,5,5,0}, //20
                              {6,5,5,5,0},
                              {6,6,5,5,0},
                              {6,6,6,5,0},
                              {6,6,6,6,0}, //24
                              {5,5,5,5,5},
                              {6,5,5,5,5},
                              {6,6,5,5,5},
                              {6,6,6,5,5},
                              {6,6,6,6,5},
                              {6,6,6,6,6}}; //30

__device__ constexpr uint32_t STAGE_SIZES_DEVICE[31][5] = {{0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {4,0,0,0,0},
                              {5,0,0,0,0}, //5
                              {6,0,0,0,0}, //6
                              {0,0,0,0,0},
                              {4,4,0,0,0},
                              {5,4,0,0,0},
                              {6,4,0,0,0}, //10
                              {6,5,0,0,0}, //11
                              {6,6,0,0,0}, //12
                              {5,4,4,0,0},
                              {6,4,4,0,0},
                              {6,5,4,0,0}, //15
                              {6,5,5,0,0}, //16
                              {6,6,5,0,0}, //17
                              {6,6,6,0,0}, //18
                              {6,5,4,4,0},
                              {5,5,5,5,0}, //20
                              {6,5,5,5,0},
                              {6,6,5,5,0},
                              {6,6,6,5,0},
                              {6,6,6,6,0}, //24
                              {5,5,5,5,5},
                              {6,5,5,5,5},
                              {6,6,5,5,5},
                              {6,6,6,5,5},
                              {6,6,6,6,5},
                              {6,6,6,6,6}}; //30

__device__ constexpr uint32_t LOW_W_OFFSETS[31][5] = {{0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0}, //5
                              {0,0,0,0,0}, //6
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0}, //10
                              {0,0,0,0,0}, //11
                              {0,0,0,0,0}, //12
                              {0,0,2<<9,0,0},
                              {0,0,2<<10,0,0},
                              {0,0,2<<11,0,0}, //15
                              {0,0,2<<11,0,0}, //16
                              {0,0,2<<12,0,0}, //17
                              {0,0,2<<12,0,0}, //18
                              {0,0,2<<11,(2<<11)+(2<<15),0},
                              {0,0,2<<10,(2<<10)+(2<<15),0}, //20
                              {0,0,2<<11,(2<<11)+(2<<16),0},
                              {0,0,2<<12,(2<<12)+(2<<17),0},
                              {0,0,2<<12,(2<<12)+(2<<18),0},
                              {0,0,2<<12,(2<<12)+(2<<18),0}, //24
                              {0,0,2<<10,(2<<10)+(2<<15),(2<<10)+(2<<15)+(2<<20)},
                              {0,0,2<<11,(2<<11)+(2<<16),(2<<11)+(2<<16)+(2<<21)},
                              {0,0,2<<12,(2<<12)+(2<<17),(2<<12)+(2<<17)+(2<<22)},
                              {0,0,2<<12,(2<<12)+(2<<18),(2<<12)+(2<<18)+(2<<23)},
                              {0,0,2<<12,(2<<12)+(2<<18),(2<<12)+(2<<18)+(2<<24)},
                              {0,0,2<<12,(2<<12)+(2<<18),(2<<12)+(2<<18)+(2<<24)}}; //30

__device__ constexpr uint32_t HIGH_W_OFFSETS[31][5] = {{0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0},
                              {0,0,0,0,0}, //5
                              {0,0,0,0,0}, //6
                              {0,0,0,0,0},
                              {0,1<<8,0,0,0},
                              {0,1<<9,0,0,0},
                              {0,1<<10,0,0,0}, //10
                              {0,1<<11,0,0,0}, //11
                              {0,1<<12,0,0,0}, //12
                              {0,1<<9,(2<<9)+(1<<13),0,0},
                              {0,1<<10,(2<<10)+(1<<14),0,0},
                              {0,1<<11,(2<<11)+(1<<15),0,0}, //15
                              {0,1<<11,(2<<11)+(1<<16),0,0}, //16
                              {0,1<<12,(2<<12)+(1<<17),0,0}, //17
                              {0,1<<12,(2<<12)+(1<<18),0,0}, //18
                              {0,1<<11,(2<<11)+(1<<15),(2<<11)+(2<<15)+(1<<19),0},
                              {0,1<<10,(2<<10)+(1<<15),(2<<10)+(2<<15)+(1<<20),0}, //20
                              {0,1<<11,(2<<11)+(1<<16),(2<<11)+(2<<16)+(1<<21),0},
                              {0,1<<12,(2<<12)+(1<<17),(2<<12)+(2<<17)+(1<<22),0},
                              {0,1<<12,(2<<12)+(1<<18),(2<<12)+(2<<18)+(1<<23),0},
                              {0,1<<12,(2<<12)+(1<<18),(2<<12)+(2<<18)+(1<<24),0}, //24
                              {0,1<<10,(2<<10)+(1<<15),(2<<10)+(2<<15)+(1<<20),(2<<10)+(2<<15)+(2<<20)+(1<<25)},
                              {0,1<<11,(2<<11)+(1<<16),(2<<11)+(2<<16)+(1<<21),(2<<11)+(2<<16)+(2<<21)+(1<<26)},
                              {0,1<<12,(2<<12)+(1<<17),(2<<12)+(2<<17)+(1<<22),(2<<12)+(2<<17)+(2<<22)+(1<<27)},
                              {0,1<<12,(2<<12)+(1<<18),(2<<12)+(2<<18)+(1<<23),(2<<12)+(2<<18)+(2<<23)+(1<<28)},
                              {0,1<<12,(2<<12)+(1<<18),(2<<12)+(2<<18)+(1<<24),(2<<12)+(2<<18)+(2<<24)+(1<<29)},
                              {0,1<<12,(2<<12)+(1<<18),(2<<12)+(2<<18)+(1<<24),(2<<12)+(2<<18)+(2<<24)+(1<<30)}}; //30

class NTTEngine {
  public:

  test_scalar    X[8];
  test_scalar    WB[3];
  test_scalar    WI[7];
  test_scalar    WE[8];


  __device__ __forceinline__ void initializeRoot(bool stride) {
    #pragma unroll
    for (int i = 0; i < 7; i++)
    {
      WI[i] = test_scalar::omega8(((stride?(threadIdx.x>>3):(threadIdx.x))&0x7)*(i+1));
    }
  }

  __device__ __forceinline__ void loadBasicTwiddles(uint4* basic_twiddles){
    
    #pragma unroll
    for (int i = 0; i < 3; i++)
    {
      WB[i].store_half(basic_twiddles[i], false);
      WB[i].store_half(basic_twiddles[i+3], true);
    }
  }

  __device__ __forceinline__ void loadInternalTwiddles(uint4* data, bool stride){
    #pragma unroll
    for (int i = 0; i < 7; i++)
    {
      WI[i].store_half(data[((stride?(threadIdx.x>>3):(threadIdx.x))&0x7)*(i+1)], false);
      WI[i].store_half(data[((stride?(threadIdx.x>>3):(threadIdx.x))&0x7)*(i+1) + 64], true);
    }
  }

  __device__ __forceinline__ void loadInternalTwiddles32(uint4* data, bool stride){
    #pragma unroll
    for (int i = 0; i < 7; i++)
    {
      WI[i].store_half(data[2*((stride?(threadIdx.x>>4):(threadIdx.x))&0x3)*(i+1)], false);
      WI[i].store_half(data[2*((stride?(threadIdx.x>>4):(threadIdx.x))&0x3)*(i+1) + 64], true);
    }
  }

  __device__ __forceinline__ void loadInternalTwiddles16(uint4* data, bool stride){
    #pragma unroll
    for (int i = 0; i < 7; i++)
    {
      WI[i].store_half(data[4*((stride?(threadIdx.x>>5):(threadIdx.x))&0x1)*(i+1)], false);
      WI[i].store_half(data[4*((stride?(threadIdx.x>>5):(threadIdx.x))&0x1)*(i+1) + 64], true);
    }
  }

  __device__ __forceinline__ void loadExternalTwiddles(uint4* data, uint32_t tw_stride, bool strided, stage_metadata s_meta, uint32_t log_size, uint32_t stage_num) {
   
    data += tw_stride*s_meta.ntt_inp_id + (s_meta.ntt_block_id&(tw_stride-1));
        
    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      WE[i].store_half(data[8*i*tw_stride + LOW_W_OFFSETS[log_size][stage_num]], false);
      WE[i].store_half(data[8*i*tw_stride + HIGH_W_OFFSETS[log_size][stage_num]], true);
    }
  }

  __device__ __forceinline__ void loadExternalTwiddles32(uint4* data, uint32_t tw_stride, bool strided, stage_metadata s_meta, uint32_t log_size, uint32_t stage_num) {
    
    data += tw_stride*s_meta.ntt_inp_id*2 + (s_meta.ntt_block_id&(tw_stride-1));
   
    #pragma unroll
    for(uint32_t j=0;j<2;j++) {
      #pragma unroll
      for(uint32_t i=0;i<4;i++) {
        WE[4*j+i].store_half(data[(8*i+j)*tw_stride + LOW_W_OFFSETS[log_size][stage_num]], false);
        WE[4*j+i].store_half(data[(8*i+j)*tw_stride + HIGH_W_OFFSETS[log_size][stage_num]], true);
      }
    }
  }

  __device__ __forceinline__ void loadExternalTwiddles16(uint4* data, uint32_t tw_stride, bool strided, stage_metadata s_meta, uint32_t log_size, uint32_t stage_num) {
    
    data += tw_stride*s_meta.ntt_inp_id*4 + (s_meta.ntt_block_id&(tw_stride-1));
    
    #pragma unroll
    for(uint32_t j=0;j<4;j++) {
      #pragma unroll
      for(uint32_t i=0;i<2;i++) {
        WE[2*j+i].store_half(data[(8*i+j)*tw_stride + LOW_W_OFFSETS[log_size][stage_num]], false);
        WE[2*j+i].store_half(data[(8*i+j)*tw_stride + HIGH_W_OFFSETS[log_size][stage_num]], true);
      }
    }
  }

  __device__ __forceinline__ void loadGlobalData(uint4* data, uint32_t data_stride, uint32_t log_data_stride, uint32_t log_size, bool strided, stage_metadata s_meta) {
    
    if (strided){
      data += (s_meta.ntt_block_id&(data_stride-1)) + data_stride*s_meta.ntt_inp_id + (s_meta.ntt_block_id>>log_data_stride)*data_stride*s_meta.ntt_block_size;
    }
    else {
      data += s_meta.ntt_block_id*s_meta.ntt_block_size + s_meta.ntt_inp_id;
    }

    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      X[i].store_half(data[s_meta.th_stride*i*data_stride], false);
      X[i].store_half(data[s_meta.th_stride*i*data_stride + (1<<log_size)], true);
    }
  }
  
  
  __device__ __forceinline__ void storeGlobalData(uint4* data, uint32_t data_stride, uint32_t log_data_stride, uint32_t log_size, bool strided, stage_metadata s_meta) {
    
    if (strided){
      data += (s_meta.ntt_block_id&(data_stride-1)) + data_stride*s_meta.ntt_inp_id + (s_meta.ntt_block_id>>log_data_stride)*data_stride*s_meta.ntt_block_size;
    }
    else {
      data += s_meta.ntt_block_id*s_meta.ntt_block_size + s_meta.ntt_inp_id;
    }

    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
        data[s_meta.th_stride*i*data_stride] = X[i].load_half(false);
        data[s_meta.th_stride*i*data_stride + (1<<log_size)] = X[i].load_half(true);
    }
  }

  __device__ __forceinline__ void loadGlobalData32(uint4* data, uint32_t data_stride, uint32_t log_data_stride, uint32_t log_size, bool strided, stage_metadata s_meta) {
    
    if (strided){
      data += (s_meta.ntt_block_id&(data_stride-1)) + data_stride*s_meta.ntt_inp_id*2 + (s_meta.ntt_block_id>>log_data_stride)*data_stride*s_meta.ntt_block_size;
    }
    else {
      data += s_meta.ntt_block_id*s_meta.ntt_block_size + s_meta.ntt_inp_id*2;
    }

    #pragma unroll
    for(uint32_t j=0;j<2;j++) {
      #pragma unroll
      for(uint32_t i=0;i<4;i++) {
        X[4*j+i].store_half(data[(8*i+j)*data_stride], false);
        X[4*j+i].store_half(data[(8*i+j)*data_stride + (1<<log_size)], true);
      }
    }
  }

   __device__ __forceinline__ void storeGlobalData32(uint4* data, uint32_t data_stride, uint32_t log_data_stride, uint32_t log_size, bool strided, stage_metadata s_meta) {
    
    if (strided){
      data += (s_meta.ntt_block_id&(data_stride-1)) + data_stride*s_meta.ntt_inp_id*2 + (s_meta.ntt_block_id>>log_data_stride)*data_stride*s_meta.ntt_block_size;
    }
    else {
      data += s_meta.ntt_block_id*s_meta.ntt_block_size + s_meta.ntt_inp_id*2;
    }

    #pragma unroll
    for(uint32_t j=0;j<2;j++) {
      #pragma unroll
      for(uint32_t i=0;i<4;i++) {
          data[(8*i+j)*data_stride] = X[4*j+i].load_half(false);
          data[(8*i+j)*data_stride + (1<<log_size)] = X[4*j+i].load_half(true);
      }
    }
  }
  
  __device__ __forceinline__ void loadGlobalData16(uint4* data, uint32_t data_stride, uint32_t log_data_stride, uint32_t log_size, bool strided, stage_metadata s_meta) {
    
    if (strided){
      data += (s_meta.ntt_block_id&(data_stride-1)) + data_stride*s_meta.ntt_inp_id*4 + (s_meta.ntt_block_id>>log_data_stride)*data_stride*s_meta.ntt_block_size;
    }
    else {
      data += s_meta.ntt_block_id*s_meta.ntt_block_size + s_meta.ntt_inp_id*4;
    }

    #pragma unroll
    for(uint32_t j=0;j<4;j++) {
      #pragma unroll
      for(uint32_t i=0;i<2;i++) {
        X[2*j+i].store_half(data[(8*i+j)*data_stride], false);
        X[2*j+i].store_half(data[(8*i+j)*data_stride + (1<<log_size)], true);
      }
    }
  }

   __device__ __forceinline__ void storeGlobalData16(uint4* data, uint32_t data_stride, uint32_t log_data_stride, uint32_t log_size, bool strided, stage_metadata s_meta) {
    
    if (strided){
      data += (s_meta.ntt_block_id&(data_stride-1)) + data_stride*s_meta.ntt_inp_id*4 + (s_meta.ntt_block_id>>log_data_stride)*data_stride*s_meta.ntt_block_size;
    }
    else {
      data += s_meta.ntt_block_id*s_meta.ntt_block_size + s_meta.ntt_inp_id*4;
    }

    #pragma unroll
    for(uint32_t j=0;j<4;j++) {
      #pragma unroll
      for(uint32_t i=0;i<2;i++) {
          data[(8*i+j)*data_stride] = X[2*j+i].load_half(false);
          data[(8*i+j)*data_stride + (1<<log_size)] = X[2*j+i].load_half(true);
      }
    }
  }

  __device__ __forceinline__ void ntt4_2() {
    #pragma unroll
    for (int i = 0; i < 2; i++)
    {
        ntt4(X[4*i], X[4*i+1], X[4*i+2], X[4*i+3]);
    }
  }

  __device__ __forceinline__ void ntt2_4() {
    #pragma unroll
    for (int i = 0; i < 4; i++)
    {
        ntt2(X[2*i], X[2*i+1]);
    }
  }


  __device__ __forceinline__ void ntt2(test_scalar& X0, test_scalar& X1) {
    test_scalar T;

    T = X0 + X1;
    X1 = X0 - X1;
    X0 = T;
  }

  __device__ __forceinline__ void ntt4(test_scalar& X0, test_scalar& X1, test_scalar& X2, test_scalar& X3) {
    test_scalar T;

    T  = X0 + X2;
    X2 = X0 - X2;
    X0 = X1 + X3;
    X1 = X1 - X3;   // T has X0, X0 has X1, X2 has X2, X1 has X3
  
    X1 = X1 * WB[0];
  
    X3 = X2 - X1;
    X1 = X2 + X1;
    X2 = T - X0;
    X0 = T + X0;
  }

  //rbo vertion
  __device__ __forceinline__ void ntt4rbo(test_scalar& X0, test_scalar& X1, test_scalar& X2, test_scalar& X3) {
    test_scalar T;

    T = X0 - X1;
    X0 = X0 + X1;
    X1 = X2 + X3;
    X3 = X2 - X3;   // T has X0, X0 has X1, X2 has X2, X1 has X3

    X3 = X3 * WB[0];
    
    X2 = X0 - X1;
    X0 = X0 + X1;
    X1 = T + X3;
    X3 = T - X3;
  }

  __device__ __forceinline__ void ntt8(test_scalar& X0, test_scalar& X1, test_scalar& X2, test_scalar& X3, 
                                       test_scalar& X4, test_scalar& X5, test_scalar& X6, test_scalar& X7) {
    test_scalar T;

    // out of 56,623,104 possible mappings, we have:
    T  = X3 - X7;
    X7 = X3 + X7;
    X3 = X1 - X5;
    X5 = X1 + X5;
    X1 = X2 + X6;
    X2 = X2 - X6;
    X6 = X0 + X4;
    X0 = X0 - X4;

    T  = T * WB[1];
    X2 = X2 * WB[1];
    
    X4 = X6 + X1;
    X6 = X6 - X1;
    X1 = X3 + T;
    X3 = X3 - T;
    T  = X5 + X7;
    X5 = X5 - X7;
    X7 = X0 + X2;
    X0 = X0 - X2;

    X1 = X1 * WB[0];
    X5 = X5 * WB[1];
    X3 = X3 * WB[2];
    
    X2 = X6 + X5;
    X6 = X6 - X5;
    X5 = X7 - X1;
    X1 = X7 + X1;
    X7 = X0 - X3;
    X3 = X0 + X3;
    X0 = X4 + T;
    X4 = X4 - T;   
  }

  __device__ __forceinline__ void ntt8win() {
    test_scalar T;

    T  = X[3] - X[7];
    X[7] = X[3] + X[7];
    X[3] = X[1] - X[5];
    X[5] = X[1] + X[5];
    X[1] = X[2] + X[6];
    X[2] = X[2] - X[6];
    X[6] = X[0] + X[4];
    X[0] = X[0] - X[4];
  
    X[2] = X[2] * WB[0];
    
    X[4] = X[6] + X[1];
    X[6] = X[6] - X[1];
    X[1] = X[3] + T;
    X[3] = X[3] - T;
    T  = X[5] + X[7];
    X[5] = X[5] - X[7];
    X[7] = X[0] + X[2];
    X[0] = X[0] - X[2];
  
    X[1] = X[1] * WB[1];
    X[5] = X[5] * WB[0] ;
    X[3] = X[3] * WB[2];
   
    X[2] = X[6] + X[5];
    X[6] = X[6] - X[5];

    X[5] = X[1] + X[3];
    X[3] = X[1] - X[3];

    X[1] = X[7] + X[5];
    X[5] = X[7] - X[5];
    X[7] = X[0] - X[3];
    X[3] = X[0] + X[3];
    X[0] = X[4] + T;
    X[4] = X[4] - T;   
  }
  
  __device__ __forceinline__ void ntt16() {
     
    #pragma unroll
     for(uint32_t i=0;i<4;i++)
       ntt4(X[i], X[i+4], X[i+8], X[i+12]);
    
     X[5] = X[5] * test_scalar::omega4(1);
     X[6] = X[6] * test_scalar::omega4(2);
     X[7] = X[7] * test_scalar::omega4(3);

     X[9] = X[9] * test_scalar::omega4(2);
     X[10] = X[10] * test_scalar::omega4(4);
     X[11] = X[11] * test_scalar::omega4(6);

     X[13] = X[13] * test_scalar::omega4(3);
     X[14] = X[14] * test_scalar::omega4(6);
     X[15] = X[15] * test_scalar::omega4(9);
    
     #pragma unroll
     for(uint32_t i=0;i<16;i+=4)
       ntt4(X[i], X[i+1], X[i+2], X[i+3]);
     
  }

 
  __device__ __forceinline__ void ntt16win() {
    test_scalar temp;

    // 1
    temp  = X[0] + X[8];
    X[0]  = X[0] - X[8];
    X[8]  = X[4] + X[12];
    X[4]  = X[4] - X[12];
    X[12] = X[2] + X[10];
    X[2]  = X[2] - X[10];
    X[10] = X[6] + X[14];
    X[6]  = X[6] - X[14];
    X[14] = X[1] + X[9];
    X[1]  = X[1] - X[9];
    X[9]  = X[5] + X[13];
    X[5]  = X[5] - X[13];
    X[13] = X[3] + X[11];
    X[3]  = X[3] - X[11];
    X[11] = X[7] + X[15];
    X[7]  = X[7] - X[15];
   
    X[4] = test_scalar::win4(3) * X[4];

    // 2
    X[15] = temp  + X[8];
    temp  = temp  - X[8];
    X[8]  = X[0]  + X[4];
    X[0]  = X[0]  - X[4];
    X[4]  = X[12] + X[10];
    X[12] = X[12] - X[10];
    X[10] = X[2]  + X[6];
    X[2]  = X[2]  - X[6];
    X[6]  = X[14] + X[9];
    X[14] = X[14] - X[9];
    X[9]  = X[13] + X[11];
    X[13] = X[13] - X[11];
    X[11] = X[1]  + X[7];
    X[1]  = X[1]  - X[7];
    X[7]  = X[3]  + X[5];
    X[3]  = X[3]  - X[5];

    X[12] = test_scalar::win4(5) * X[12];
    X[10] = test_scalar::win4(6) * X[10];
    X[2]  = test_scalar::win4(7) * X[2];

    // 3
    X[5]  = X[10] + X[2];
    X[10] = X[10] - X[2];
    X[2]  = X[6]  + X[9];
    X[6]  = X[6]  - X[9];
    X[9]  = X[14] + X[13];
    X[14] = X[14] - X[13];

    X[13] = X[11] + X[7];
    X[13] = test_scalar::win4(14) * X[13];
    X[11] = test_scalar::win4(12) * X[11] + X[13];
    X[7]  = test_scalar::win4(13) * X[7]  + X[13];

    X[13] = X[1] + X[3];
    X[13] = test_scalar::win4(17) * X[13];
    X[1]  = test_scalar::win4(15) * X[1] + X[13];
    X[3]  = test_scalar::win4(16) * X[3] + X[13];

    // 4
    X[13] = X[15] + X[4];
    X[15] = X[15] - X[4];
    X[4]  = temp  + X[12];
    temp  = temp  - X[12];
    X[12] = X[8]  + X[5];
    X[8]  = X[8]  - X[5];
    X[5]  = X[0]  + X[10];
    X[0]  = X[0]  - X[10];

    X[6]   = test_scalar::win4(9)  * X[6];
    X[9]   = test_scalar::win4(10) * X[9];
    X[14]  = test_scalar::win4(11) * X[14];

    X[10] = X[9]  + X[14];
    X[9]  = X[9]  - X[14];
    X[14] = X[11] + X[1];
    X[11] = X[11] - X[1];
    X[1]  = X[7]  + X[3];
    X[7]  = X[7]  - X[3];

    // 5
    X[3]  = X[13] + X[2];
    X[13] = X[13] - X[2];
    X[2]  = X[15] + X[6];
    X[15] = X[15] - X[6];
    X[6]  = X[4]  + X[10];
    X[4]  = X[4]  - X[10];
    X[10] = temp + X[9];
    temp  = temp - X[9];
    X[9]  = X[12] + X[14];
    X[12] = X[12] - X[14];
    X[14] = X[8]  + X[7];
    X[8]  = X[8]  - X[7];
    X[7]  = X[5]  + X[1];
    X[5]  = X[5]  - X[1];
    X[1]  = X[0]  + X[11];
    X[0]  = X[0]  - X[11];

    // reorder + return;
    X[11] = X[0];
    X[0]  = X[3];
    X[3]  = X[7];
    X[7]  = X[1];
    X[1]  = X[9];
    X[9]  = X[12];
    X[12] = X[15];
    X[15] = X[11];
    X[11] = X[5];
    X[5]  = X[14];
    X[14] = temp;
    temp  = X[8];
    X[8]  = X[13];
    X[13] = temp;
    temp  = X[4];
    X[4]  = X[2];
    X[2]  = X[6];
    X[6]  = X[10];
    X[10] = temp;

  }

 
  __device__ __forceinline__ void SharedData64Columns8(uint4 *shmem, bool store, bool high_bits, bool stride) {
    
    uint32_t ntt_id = stride? threadIdx.x & 0x7 : threadIdx.x >> 3;
    uint32_t column_id = stride? threadIdx.x >> 3 : threadIdx.x & 0x7;
  
    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      if (store) {
        shmem[ntt_id * 64 + i * 8 + column_id] = X[i].load_half(high_bits);        
      }
      else {
        X[i].store_half(shmem[ntt_id * 64 + i * 8 + column_id], high_bits);
      }
    }
  }

  __device__ __forceinline__ void SharedData64Rows8(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0x7 : threadIdx.x >> 3;
    uint32_t row_id = stride? threadIdx.x >> 3 : threadIdx.x & 0x7;
    
    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      if (store) {
        shmem[ntt_id * 64 + row_id * 8 + i] = X[i].load_half(high_bits);
      }
      else {
        X[i].store_half(shmem[ntt_id * 64 + row_id * 8 + i] ,high_bits);   
      }
    }
  }

  __device__ __forceinline__ void SharedData32Columns8(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0xf : threadIdx.x >> 2;
    uint32_t column_id = stride? threadIdx.x >> 4 : threadIdx.x & 0x3;
    
    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      if (store) {
        shmem[ntt_id * 32 + i * 4 + column_id] = X[i].load_half(high_bits);      
      }
      else {
        X[i].store_half(shmem[ntt_id * 32 + i * 4 + column_id], high_bits);
      }
    }
  }

  __device__ __forceinline__ void SharedData32Rows8(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0xf : threadIdx.x >> 2;
    uint32_t row_id = stride? threadIdx.x >> 4 : threadIdx.x & 0x3;
    
    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      if (store) {
        shmem[ntt_id * 32 + row_id * 8 + i] = X[i].load_half(high_bits);
      }
      else {
        X[i].store_half(shmem[ntt_id * 32 + row_id * 8 + i] ,high_bits);   
      }
    }
  }

  __device__ __forceinline__ void SharedData32Columns4_2(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0xf : threadIdx.x >> 2;
    uint32_t column_id = (stride? threadIdx.x >> 4 : threadIdx.x & 0x3)*2;
    
    #pragma unroll
    for(uint32_t j=0;j<2;j++) {
      #pragma unroll
      for(uint32_t i=0;i<4;i++) {
        if (store) {
          shmem[ntt_id * 32 + i * 8 + column_id + j] = X[4*j+i].load_half(high_bits);    
        }
        else {
          X[4*j+i].store_half(shmem[ntt_id * 32 + i * 8 + column_id + j], high_bits);
        }
      }
    }
  }

  __device__ __forceinline__ void SharedData32Rows4_2(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0xf : threadIdx.x >> 2;
    uint32_t row_id = (stride? threadIdx.x >> 4 : threadIdx.x & 0x3)*2;
    
    #pragma unroll
    for(uint32_t j=0;j<2;j++) {
      #pragma unroll
      for(uint32_t i=0;i<4;i++) {
        if (store) {
          shmem[ntt_id * 32 + row_id * 4 + 4*j + i] = X[4*j+i].load_half(high_bits);
        }
        else {
          X[4*j+i].store_half(shmem[ntt_id * 32 + row_id * 4 + 4*j + i] ,high_bits);   
        }
      }
    }
  }


  __device__ __forceinline__ void SharedData16Columns8(uint4 *shmem, bool store, bool high_bits, bool stride) {
  
    uint32_t ntt_id = stride? threadIdx.x & 0x1f : threadIdx.x >> 1;
    uint32_t column_id = stride? threadIdx.x >> 5 : threadIdx.x & 0x1;
       
    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      if (store) {
        shmem[ntt_id * 16 + i * 2 + column_id] = X[i].load_half(high_bits);   
      }
      else {
        X[i].store_half(shmem[ntt_id * 16 + i * 2 + column_id], high_bits);
      }
    }
  }

  __device__ __forceinline__ void SharedData16Rows8(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0x1f : threadIdx.x >> 1;
    uint32_t row_id = stride? threadIdx.x >> 5 : threadIdx.x & 0x1;
        
    #pragma unroll
    for(uint32_t i=0;i<8;i++) {
      if (store) {
        shmem[ntt_id * 16 + row_id * 8 + i] = X[i].load_half(high_bits);
      }
      else {
        X[i].store_half(shmem[ntt_id * 16 + row_id * 8 + i] ,high_bits);   
      }
    }
  }

  __device__ __forceinline__ void SharedData16Columns2_4(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0x1f : threadIdx.x >> 1;
    uint32_t column_id = (stride? threadIdx.x >> 5 : threadIdx.x & 0x1)*4;
    
    #pragma unroll
    for(uint32_t j=0;j<4;j++) {
      #pragma unroll
      for(uint32_t i=0;i<2;i++) {
        if (store) {
          shmem[ntt_id * 16 + i * 8 + column_id + j] = X[2*j+i].load_half(high_bits); 
        }
        else {
          X[2*j+i].store_half(shmem[ntt_id * 16 + i * 8 + column_id + j], high_bits);
        }
      }
    }
  }

  __device__ __forceinline__ void SharedData16Rows2_4(uint4 *shmem, bool store, bool high_bits, bool stride) {

    uint32_t ntt_id = stride? threadIdx.x & 0x1f : threadIdx.x >> 1;
    uint32_t row_id = (stride? threadIdx.x >> 5 : threadIdx.x & 0x1)*4;
   
    #pragma unroll
    for(uint32_t j=0;j<4;j++) {
      #pragma unroll
      for(uint32_t i=0;i<2;i++) {
        if (store) {
          shmem[ntt_id * 16 + row_id * 2 + 2*j + i] = X[2*j+i].load_half(high_bits);
        }
        else {
          X[2*j+i].store_half(shmem[ntt_id * 16 + row_id * 2 + 2*j + i] ,high_bits);   
        }
      }
    }
  }


  __device__ __forceinline__ void twiddlesInternal() {
    #pragma unroll 
    for (int i = 1; i < 8; i++)
    {
      X[i] = X[i] * WI[i-1];
    }
  }

  __device__ __forceinline__ void twiddlesExternal() {
    #pragma unroll 
    for (int i = 0; i < 8; i++)
    {
      X[i] = X[i] * WE[i];
    }
  }
};  

#endif