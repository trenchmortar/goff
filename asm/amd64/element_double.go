// Copyright 2020 ConsenSys Software Inc.
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

package amd64

import . "github.com/consensys/bavard/amd64"

func (f *ffAmd64) generateDouble() {
	// func header
	stackSize := 0
	if f.NbWords > SmallModulus {
		stackSize = f.NbWords * 8
	}
	registers := FnHeader("double", stackSize, 16)

	// registers
	x := registers.Pop()
	r := registers.Pop()
	t := registers.PopN(f.NbWords)

	MOVQ("res+0(FP)", r)
	MOVQ("x+8(FP)", x)

	f.Mov(x, t)
	f.Add(t, t)
	f.Reduce(&registers, t, r)

	RET()
}
