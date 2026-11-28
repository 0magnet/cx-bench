//go:build tinygo

package main

import "runtime/volatile"

// benchZero is 0, read as a volatile load. TinyGo turns an atomic load of a
// global nothing writes into the constant 0, so zero.go would not stop LLVM
// from precomputing a round.
var benchZero uint32

func zero() int32 { return int32(volatile.LoadUint32(&benchZero)) }
