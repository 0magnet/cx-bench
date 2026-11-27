// Command harness verifies, times and reports the cx-bench forms. It starts
// every program through the form's run.sh --cmd, so it knows nothing about
// languages, and timestamps the phase markers each program writes to stderr
// on one clock for all forms. See ../README.md.
//
//	harness verify  [-forms f,g] [-size N]          hashes, markers and server mode
//	harness measure [-forms f,g] -out results/DATE  sizing, runs, sweep, layout, server
//	harness report  -in results/DATE                results.md and chart.png
//	harness expected [-in results/DATE]             add sizes to expected.txt, from the math
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func usage() {
	fmt.Fprintln(os.Stderr, "usage: harness verify|measure|report|expected [flags], see -h of each")
	os.Exit(2)
}

// repoRoot is the directory above the harness, found from the working
// directory or CXBENCH_ROOT.
func repoRoot() string {
	if root := os.Getenv("CXBENCH_ROOT"); root != "" {
		return root
	}
	dir, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	for {
		if _, err := os.Stat(filepath.Join(dir, "src", "form.sh")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			fmt.Fprintln(os.Stderr, "harness: run inside the cx-bench repository or set CXBENCH_ROOT")
			os.Exit(2)
		}
		dir = parent
	}
}

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	root := repoRoot()
	args := os.Args[2:]
	var err error
	switch os.Args[1] {
	case "verify":
		err = verifyCommand(root, args)
	case "measure":
		err = measureCommand(root, args)
	case "report":
		err = reportCommand(root, args)
	case "expected":
		err = expectedCommand(root, args)
	default:
		usage()
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, "harness:", err)
		os.Exit(1)
	}
}
