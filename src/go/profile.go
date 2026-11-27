//go:build !tinygo

package main

import (
	"os"
	"runtime/pprof"
)

// profileStart writes a CPU profile to CXBENCH_CPUPROFILE, for go/profile.sh.
// View it with go tool pprof.
func profileStart() func() {
	path := os.Getenv("CXBENCH_CPUPROFILE")
	if path == "" {
		return func() {}
	}
	file, err := os.Create(path)
	if err != nil {
		panic(err)
	}
	if err := pprof.StartCPUProfile(file); err != nil {
		panic(err)
	}
	return func() {
		pprof.StopCPUProfile()
		file.Close()
	}
}
