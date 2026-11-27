//go:build tinygo

package main

// profileStart does nothing under TinyGo, which has no runtime/pprof CPU
// profiler. tinygo/profile.sh uses perf instead.
func profileStart() func() { return func() {} }
