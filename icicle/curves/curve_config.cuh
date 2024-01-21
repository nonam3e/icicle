#pragma once
#ifndef INDEX_H
#define INDEX_H

#define BN254     1
#define BLS12_381 2
#define BLS12_377 3
#define BW6_761   4

#include "../primitives/field.cuh"
#include "../primitives/projective.cuh"
#if defined(G2_DEFINED)
#include "../primitives/extension_field.cuh"
#endif

#if CURVE_ID == BN254
#include "bn254_params.cuh"
using namespace bn254;
#elif CURVE_ID == BLS12_381
#include "bls12_381_params.cuh"
using namespace bls12_381;
#elif CURVE_ID == BLS12_377
#include "bls12_377_params.cuh"
using namespace bls12_377;
#elif CURVE_ID == BW6_761
#include "bls12_377_params.cuh"
#include "bw6_761_params.cuh"
using namespace bw6_761;
#endif

namespace curve_config {

#if CURVE_ID == BW6_761
  typedef bls12_377::fq_config fp_config;
#endif
  typedef Field<fp_config> scalar_t;
  typedef Field<fq_config> point_field_t;
  static constexpr point_field_t generator_x = point_field_t{g1_gen_x};
  static constexpr point_field_t generator_y = point_field_t{g1_gen_y};
  static constexpr point_field_t b = point_field_t{weierstrass_b};
  typedef Projective<point_field_t, scalar_t, b, generator_x, generator_y> projective_t;
  typedef Affine<point_field_t> affine_t;

#if defined(G2_DEFINED)
#if CURVE_ID == BW6_761
  typedef point_field_t g2_point_field_t;
  static constexpr g2_point_field_t g2_generator_x = g2_point_field_t{g2_gen_x};
  static constexpr g2_point_field_t g2_generator_y = g2_point_field_t{g2_gen_y};
  static constexpr g2_point_field_t g2_b = g2_point_field_t{g2_weierstrass_b};
#else
  typedef ExtensionField<fq_config> g2_point_field_t;
  static constexpr g2_point_field_t g2_generator_x =
    g2_point_field_t{point_field_t{g2_gen_x_re}, point_field_t{g2_gen_x_im}};
  static constexpr g2_point_field_t g2_generator_y =
    g2_point_field_t{point_field_t{g2_gen_y_re}, point_field_t{g2_gen_y_im}};
  static constexpr g2_point_field_t g2_b =
    g2_point_field_t{point_field_t{weierstrass_b_g2_re}, point_field_t{weierstrass_b_g2_im}};
#endif
  typedef Projective<g2_point_field_t, scalar_t, g2_b, g2_generator_x, g2_generator_y> g2_projective_t;
  typedef Affine<g2_point_field_t> g2_affine_t;
#endif

} // namespace curve_config

#endif
