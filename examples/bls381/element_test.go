// Copyright 2020 ConsenSys AG
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

// Code generated by goff (v0.3.3) DO NOT EDIT

package fp

import (
	"crypto/rand"
	"math/big"
	"math/bits"
	"testing"

	"github.com/leanovate/gopter"
	"github.com/leanovate/gopter/prop"
)

func TestELEMENTCorrectnessAgainstBigInt(t *testing.T) {
	modulus := Modulus()
	cmpEandB := func(e *Element, b *big.Int, name string) {
		var _e big.Int
		if e.FromMont().ToBigInt(&_e).Cmp(b) != 0 {
			t.Fatal(name, "failed")
		}
	}
	var modulusMinusOne, one big.Int
	one.SetUint64(1)

	modulusMinusOne.Sub(modulus, &one)

	var n int
	if testing.Short() {
		n = 20
	} else {
		n = 500
	}

	sAdx := supportAdx

	for i := 0; i < n; i++ {
		if i == n/2 && sAdx {
			supportAdx = false // testing without adx instruction
		}
		// sample 3 random big int
		b1, _ := rand.Int(rand.Reader, modulus)
		b2, _ := rand.Int(rand.Reader, modulus)
		b3, _ := rand.Int(rand.Reader, modulus) // exponent

		// adding edge cases
		// TODO need more edge cases
		switch i {
		case 0:
			b3.SetUint64(0)
			b1.SetUint64(0)
		case 1:
			b2.SetUint64(0)
		case 2:
			b1.SetUint64(0)
			b2.SetUint64(0)
		case 3:
			b3.SetUint64(0)
		case 4:
			b3.SetUint64(1)
		case 5:
			b3.SetUint64(^uint64(0))
		case 6:
			b3.SetUint64(2)
			b1.Set(&modulusMinusOne)
		case 7:
			b2.Set(&modulusMinusOne)
		case 8:
			b1.Set(&modulusMinusOne)
			b2.Set(&modulusMinusOne)
		}

		var bMul, bAdd, bSub, bDiv, bNeg, bLsh, bInv, bExp, bSquare big.Int

		// e1 = mont(b1), e2 = mont(b2)
		var e1, e2, eMul, eAdd, eSub, eDiv, eNeg, eLsh, eInv, eExp, eSquare Element
		e1.SetBigInt(b1)
		e2.SetBigInt(b2)

		// (e1*e2).FromMont() === b1*b2 mod q ... etc
		eSquare.Square(&e1)
		eMul.Mul(&e1, &e2)
		eAdd.Add(&e1, &e2)
		eSub.Sub(&e1, &e2)
		eDiv.Div(&e1, &e2)
		eNeg.Neg(&e1)
		eInv.Inverse(&e1)
		eExp.Exp(e1, b3)
		eLsh.Double(&e1)

		// same operations with big int
		bAdd.Add(b1, b2).Mod(&bAdd, modulus)
		bMul.Mul(b1, b2).Mod(&bMul, modulus)
		bSquare.Mul(b1, b1).Mod(&bSquare, modulus)
		bSub.Sub(b1, b2).Mod(&bSub, modulus)
		bDiv.ModInverse(b2, modulus)
		bDiv.Mul(&bDiv, b1).
			Mod(&bDiv, modulus)
		bNeg.Neg(b1).Mod(&bNeg, modulus)

		bInv.ModInverse(b1, modulus)
		bExp.Exp(b1, b3, modulus)
		bLsh.Lsh(b1, 1).Mod(&bLsh, modulus)

		cmpEandB(&eSquare, &bSquare, "Square")
		cmpEandB(&eMul, &bMul, "Mul")
		cmpEandB(&eAdd, &bAdd, "Add")
		cmpEandB(&eSub, &bSub, "Sub")
		cmpEandB(&eDiv, &bDiv, "Div")
		cmpEandB(&eNeg, &bNeg, "Neg")
		cmpEandB(&eInv, &bInv, "Inv")
		cmpEandB(&eExp, &bExp, "Exp")

		cmpEandB(&eLsh, &bLsh, "Lsh")

		// legendre symbol
		if e1.Legendre() != big.Jacobi(b1, modulus) {
			t.Fatal("legendre symbol computation failed")
		}
		if e2.Legendre() != big.Jacobi(b2, modulus) {
			t.Fatal("legendre symbol computation failed")
		}

		// these are slow, killing circle ci
		if n <= 10 {
			// sqrt
			var eSqrt Element
			var bSqrt big.Int
			bSqrt.ModSqrt(b1, modulus)
			eSqrt.Sqrt(&e1)
			cmpEandB(&eSqrt, &bSqrt, "Sqrt")
		}
	}
	supportAdx = sAdx
}

func TestELEMENTSetInterface(t *testing.T) {
	// TODO
	t.Skip("not implemented")
}

func TestELEMENTIsRandom(t *testing.T) {
	for i := 0; i < 50; i++ {
		var x, y Element
		x.SetRandom()
		y.SetRandom()
		if x.Equal(&y) {
			t.Fatal("2 random numbers are unlikely to be equal")
		}
	}
}

func TestByte(t *testing.T) {

	modulus := Modulus()

	// test values
	var bs [3][]byte
	r1, _ := rand.Int(rand.Reader, modulus)
	bs[0] = r1.Bytes() // should be r1 as Element
	r2, _ := rand.Int(rand.Reader, modulus)
	r2.Add(modulus, r2)
	bs[1] = r2.Bytes() // should be r2 as Element
	var tmp big.Int
	tmp.SetUint64(0)
	bs[2] = tmp.Bytes() // should be 0 as Element

	// witness values as Element
	var el [3]Element
	el[0].SetBigInt(r1)
	el[1].SetBigInt(r2)
	el[2].SetUint64(0)

	// check conversions
	for i := 0; i < 3; i++ {
		var z Element
		z.SetBytes(bs[i])
		if !z.Equal(&el[i]) {
			t.Fatal("SetBytes fails")
		}
		// check conversion Element to Bytes
		b := z.Bytes()
		z.SetBytes(b)
		if !z.Equal(&el[i]) {
			t.Fatal("Bytes fails")
		}
	}
}

// -------------------------------------------------------------------------------------------------
// benchmarks
// most benchmarks are rudimentary and should sample a large number of random inputs
// or be run multiple times to ensure it didn't measure the fastest path of the function

var benchResElement Element

func BenchmarkInverseELEMENT(b *testing.B) {
	var x Element
	x.SetRandom()
	benchResElement.SetRandom()
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		benchResElement.Inverse(&x)
	}

}
func BenchmarkExpELEMENT(b *testing.B) {
	var x Element
	x.SetRandom()
	benchResElement.SetRandom()
	b1, _ := rand.Int(rand.Reader, Modulus())
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Exp(x, b1)
	}
}

func BenchmarkDoubleELEMENT(b *testing.B) {
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Double(&benchResElement)
	}
}

func BenchmarkAddELEMENT(b *testing.B) {
	var x Element
	x.SetRandom()
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Add(&x, &benchResElement)
	}
}

func BenchmarkSubELEMENT(b *testing.B) {
	var x Element
	x.SetRandom()
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Sub(&x, &benchResElement)
	}
}

func BenchmarkNegELEMENT(b *testing.B) {
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Neg(&benchResElement)
	}
}

func BenchmarkDivELEMENT(b *testing.B) {
	var x Element
	x.SetRandom()
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Div(&x, &benchResElement)
	}
}

func BenchmarkFromMontELEMENT(b *testing.B) {
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.FromMont()
	}
}

func BenchmarkToMontELEMENT(b *testing.B) {
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.ToMont()
	}
}
func BenchmarkSquareELEMENT(b *testing.B) {
	benchResElement.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Square(&benchResElement)
	}
}

func BenchmarkSqrtELEMENT(b *testing.B) {
	var a Element
	a.SetRandom()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Sqrt(&a)
	}
}

func BenchmarkMulELEMENT(b *testing.B) {
	x := Element{
		17644856173732828998,
		754043588434789617,
		10224657059481499349,
		7488229067341005760,
		11130996698012816685,
		1267921511277847466,
	}
	benchResElement.SetOne()
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		benchResElement.Mul(&benchResElement, &x)
	}
}

func TestELEMENTreduce(t *testing.T) {
	q := Element{
		13402431016077863595,
		2210141511517208575,
		7435674573564081700,
		7239337960414712511,
		5412103778470702295,
		1873798617647539866,
	}

	var testData []Element
	{
		a := q
		a[5]--
		testData = append(testData, a)
	}
	{
		a := q
		a[0]--
		testData = append(testData, a)
	}
	{
		a := q
		a[5]++
		testData = append(testData, a)
	}
	{
		a := q
		a[0]++
		testData = append(testData, a)
	}
	{
		a := q
		testData = append(testData, a)
	}

	for _, s := range testData {
		expected := s
		reduce(&s)
		expected.testReduce()
		if !s.Equal(&expected) {
			t.Fatal("reduce failed")
		}
	}

}

func (z *Element) testReduce() *Element {

	// if z > q --> z -= q
	// note: this is NOT constant time
	if !(z[5] < 1873798617647539866 || (z[5] == 1873798617647539866 && (z[4] < 5412103778470702295 || (z[4] == 5412103778470702295 && (z[3] < 7239337960414712511 || (z[3] == 7239337960414712511 && (z[2] < 7435674573564081700 || (z[2] == 7435674573564081700 && (z[1] < 2210141511517208575 || (z[1] == 2210141511517208575 && (z[0] < 13402431016077863595))))))))))) {
		var b uint64
		z[0], b = bits.Sub64(z[0], 13402431016077863595, 0)
		z[1], b = bits.Sub64(z[1], 2210141511517208575, b)
		z[2], b = bits.Sub64(z[2], 7435674573564081700, b)
		z[3], b = bits.Sub64(z[3], 7239337960414712511, b)
		z[4], b = bits.Sub64(z[4], 5412103778470702295, b)
		z[5], _ = bits.Sub64(z[5], 1873798617647539866, b)
	}
	return z
}

// -------------------------------------------------------------------------------------------------
// Gopter tests

func TestELEMENTMul(t *testing.T) {

	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 10000

	properties := gopter.NewProperties(parameters)

	genA := gen()
	genB := gen()

	properties.Property("Having the receiver as operand should output the same result", prop.ForAll(
		func(a, b testPairElement) bool {
			var c, d Element
			d.Set(&a.element)
			c.Mul(&a.element, &b.element)
			a.element.Mul(&a.element, &b.element)
			b.element.Mul(&d, &b.element)
			return a.element.Equal(&b.element) && a.element.Equal(&c) && b.element.Equal(&c)
		},
		genA,
		genB,
	))

	properties.Property("Operation result must match big.Int result", prop.ForAll(
		func(a, b testPairElement) bool {
			var c Element
			c.Mul(&a.element, &b.element)

			var d, e big.Int
			d.Mul(&a.bigint, &b.bigint).Mod(&d, Modulus())

			return c.FromMont().ToBigInt(&e).Cmp(&d) == 0
		},
		genA,
		genB,
	))

	properties.Property("Operation result must be smaller than modulus", prop.ForAll(
		func(a, b testPairElement) bool {
			var c Element
			c.Mul(&a.element, &b.element)
			return !c.biggerOrEqualModulus()
		},
		genA,
		genB,
	))

	properties.Property("Assembly implementation must be consistent with generic one", prop.ForAll(
		func(a, b testPairElement) bool {
			var c, d Element
			c.Mul(&a.element, &b.element)
			_mulGeneric(&d, &a.element, &b.element)
			return c.Equal(&d)
		},
		genA,
		genB,
	))

	properties.TestingRun(t, gopter.ConsoleReporter(false))
}

func TestELEMENTSquare(t *testing.T) {

	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 10000

	properties := gopter.NewProperties(parameters)

	genA := gen()

	properties.Property("Having the receiver as operand should output the same result", prop.ForAll(
		func(a testPairElement) bool {
			var b Element
			b.Square(&a.element)
			a.element.Square(&a.element)
			return a.element.Equal(&b)
		},
		genA,
	))

	properties.Property("Operation result must match big.Int result", prop.ForAll(
		func(a testPairElement) bool {
			var b Element
			b.Square(&a.element)

			var d, e big.Int
			d.Mul(&a.bigint, &a.bigint).Mod(&d, Modulus())

			return b.FromMont().ToBigInt(&e).Cmp(&d) == 0
		},
		genA,
	))

	properties.Property("Operation result must be smaller than modulus", prop.ForAll(
		func(a testPairElement) bool {
			var b Element
			b.Square(&a.element)
			return !b.biggerOrEqualModulus()
		},
		genA,
	))

	properties.Property("Square(x) == Mul(x,x)", prop.ForAll(
		func(a testPairElement) bool {
			var b, c Element
			b.Square(&a.element)
			c.Mul(&a.element, &a.element)
			return c.Equal(&b)
		},
		genA,
	))

	properties.Property("Assembly implementation must be consistent with generic one", prop.ForAll(
		func(a testPairElement) bool {
			var c, d Element
			c.Square(&a.element)
			_squareGeneric(&d, &a.element)
			return c.Equal(&d)
		},
		genA,
	))

	properties.TestingRun(t, gopter.ConsoleReporter(false))
}

func TestELEMENTFromMont(t *testing.T) {

	parameters := gopter.DefaultTestParameters()
	parameters.MinSuccessfulTests = 10000

	properties := gopter.NewProperties(parameters)

	genA := gen()

	properties.Property("Assembly implementation must be consistent with generic one", prop.ForAll(
		func(a testPairElement) bool {
			c := a.element
			d := a.element
			c.FromMont()
			_fromMontGeneric(&d)
			return c.Equal(&d)
		},
		genA,
	))

	properties.TestingRun(t, gopter.ConsoleReporter(false))
}

type testPairElement struct {
	element Element
	bigint  big.Int
}

func (z *Element) biggerOrEqualModulus() bool {
	if z[5] > qElement[5] {
		return true
	}
	if z[5] < qElement[5] {
		return false
	}

	if z[4] > qElement[4] {
		return true
	}
	if z[4] < qElement[4] {
		return false
	}

	if z[3] > qElement[3] {
		return true
	}
	if z[3] < qElement[3] {
		return false
	}

	if z[2] > qElement[2] {
		return true
	}
	if z[2] < qElement[2] {
		return false
	}

	if z[1] > qElement[1] {
		return true
	}
	if z[1] < qElement[1] {
		return false
	}

	return z[0] >= qElement[0]
}

func gen() gopter.Gen {
	return func(genParams *gopter.GenParameters) *gopter.GenResult {
		var g testPairElement

		g.element = Element{
			genParams.NextUint64(),
			genParams.NextUint64(),
			genParams.NextUint64(),
			genParams.NextUint64(),
			genParams.NextUint64(),
			genParams.NextUint64(),
		}
		if qElement[5] != ^uint64(0) {
			g.element[5] %= (qElement[5] + 1)
		}

		for g.element.biggerOrEqualModulus() {
			g.element = Element{
				genParams.NextUint64(),
				genParams.NextUint64(),
				genParams.NextUint64(),
				genParams.NextUint64(),
				genParams.NextUint64(),
				genParams.NextUint64(),
			}
			if qElement[5] != ^uint64(0) {
				g.element[5] %= (qElement[5] + 1)
			}
		}

		g.element.ToBigIntRegular(&g.bigint)
		genResult := gopter.NewGenResult(g, gopter.NoShrinker)
		return genResult
	}
}
