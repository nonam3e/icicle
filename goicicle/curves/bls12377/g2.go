
	// Copyright 2023 Ingonyama
	//
	// Licensed under the Apache License, Version 2.0 (the "License");
	// you may not use this file except in compliance with the License.
	// You may obtain a copy of the License at
	//
	//     http://www.apache.org/licenses/LICENSE-2.0
	//
	// Unless required by applicable law or agreed to in writing, software
	// distributed under the License is distributed on an "AS IS" BASIS,
	// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	// See the License for the specific language governing permissions and
	// limitations under the License.
	
// Code generated by Ingonyama DO NOT EDIT

package bls12377

import (
	"unsafe"
	


	"github.com/consensys/gnark-crypto/ecc/bls12-377"



)

// #cgo CFLAGS: -I${SRCDIR}/icicle/curves/bls12377/
// #cgo LDFLAGS: -L${SRCDIR}/../../ -lbn12_377
// #include "c_api.h"
// #include "ve_mod_mult.h"
import "C"

func BatchConvertFromG2Affine(elements []bls12377.G2Affine) []G2PointAffine {
	var newElements []G2PointAffine
	for _, gg2Affine := range elements {
		var newElement G2PointAffine
		newElement.FromGnarkAffine(&gg2Affine)

		newElements = append(newElements, newElement)
	}
	return newElements
}

// G2 extension field

type G2Element [4]uint64

type ExtentionField struct {
	A0, A1 G2Element
}

type G2PointAffine struct {
	x, y ExtentionField
}

type G2Point struct {
	x, y, z ExtentionField
}

func (p *G2Point) eqg2(pCompare *G2Point) bool {
	// Cast *PointBLS12377 to *C.BLS12377_projective_t
	// The unsafe.Pointer cast is necessary because Go doesn't allow direct casts
	// between different pointer types.
	// It's your responsibility to ensure that the types are compatible.
	pC := (*C.BLS12377_g2_projective_t)(unsafe.Pointer(p))
	pCompareC := (*C.BLS12377_g2_projective_t)(unsafe.Pointer(pCompare))

	// Call the C function
	// The C function doesn't keep any references to the data,
	// so it's fine if the Go garbage collector moves or deletes the data later.
	return bool(C.eq_g2_bls12377(pC, pCompareC))
}

func (p *G2PointAffine) ToProjective() G2Point {
	return G2Point{
		x: p.x,
		y: p.y,
		z: ExtentionField{
			A0: G2Element{1, 0, 0, 0},
			A1: G2Element{0, 0, 0, 0},
		},
	}
}

func (g *G2PointAffine) FromGnarkAffine(gnark *bls12377.G2Affine) *G2PointAffine {
	g.x.A0 = gnark.X.A0.Bits()
	g.x.A1 = gnark.X.A1.Bits()
	g.y.A0 = gnark.Y.A0.Bits()
	g.y.A1 = gnark.Y.A1.Bits()

	return g
}

func (g *G2PointAffine) FromGnarkJac(gnark *bls12377.G2Jac) *G2PointAffine {
	var pointAffine bls12377.G2Affine
	pointAffine.FromJacobian(gnark)

	g.x.A0 = pointAffine.X.A0.Bits()
	g.x.A1 = pointAffine.X.A1.Bits()
	g.y.A0 = pointAffine.Y.A0.Bits()
	g.y.A1 = pointAffine.Y.A1.Bits()

	return g
}
