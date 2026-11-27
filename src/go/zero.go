//go:build !tinygo

package main

import "sync/atomic"

// benchZero is 0, read with an atomic load, so a compiler cannot hoist the
// work of a round out of the loop of rounds or fold a loop into a closed
// form. zero_tinygo.go is the TinyGo form.
var benchZero int32

func zero() int32 { return atomic.LoadInt32(&benchZero) }
