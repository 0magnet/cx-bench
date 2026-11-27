package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
)

// expectedHashes holds the hash of each benchmark at each size, from
// expected.txt and, for a size it lacks, from hashCompute.
type expectedHashes struct {
	root   string
	hashes map[string]string
	added  bool
}

func expectedKey(bench string, size int) string { return bench + " " + strconv.Itoa(size) }

func expectedLoad(root string) (*expectedHashes, error) {
	e := &expectedHashes{root: root, hashes: map[string]string{}}
	file, err := os.Open(filepath.Join(root, "expected.txt"))
	if err != nil {
		return nil, err
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		fields := strings.Fields(scanner.Text())
		if len(fields) != 3 || strings.HasPrefix(fields[0], "#") {
			continue
		}
		size, err := strconv.Atoi(fields[1])
		if err != nil {
			return nil, fmt.Errorf("expected.txt: %q", scanner.Text())
		}
		e.hashes[expectedKey(fields[0], size)] = fields[2]
	}
	return e, scanner.Err()
}

// want returns the hash of bench at size. A size expected.txt lacks is
// computed from the math and added, and save writes it.
func (e *expectedHashes) want(bench string, size int) string {
	if hash, found := e.hashes[expectedKey(bench, size)]; found {
		return hash
	}
	hash := strconv.FormatUint(hashCompute(bench, size), 10)
	e.hashes[expectedKey(bench, size)] = hash
	e.added = true
	return hash
}

func (e *expectedHashes) save() error {
	keys := make([]string, 0, len(e.hashes))
	for key := range e.hashes {
		keys = append(keys, key)
	}
	sort.Slice(keys, func(i, j int) bool {
		bi, si := splitKey(keys[i])
		bj, sj := splitKey(keys[j])
		if bi != bj {
			return benchNumber(bi) < benchNumber(bj)
		}
		return si < sj
	})
	var b strings.Builder
	b.WriteString("# benchmark size hash\n")
	b.WriteString("# The FNV-1a hash every form prints for run(size), one pass of size rounds.\n")
	b.WriteString("# Computed from the math by harness/hashmath.go, which its test checks\n")
	b.WriteString("# against the hashes the Go form printed. Every form agrees with it.\n")
	for _, key := range keys {
		fmt.Fprintf(&b, "%s %s\n", key, e.hashes[key])
	}
	return os.WriteFile(filepath.Join(e.root, "expected.txt"), []byte(b.String()), 0o644)
}

func splitKey(key string) (string, int) {
	fields := strings.Fields(key)
	size, _ := strconv.Atoi(fields[1])
	return fields[0], size
}

// expectedCommand adds the sizes 1, 2 and 3 of every benchmark and every
// size a results directory used to expected.txt.
func expectedCommand(root string, args []string) error {
	flags := flag.NewFlagSet("expected", flag.ExitOnError)
	in := flags.String("in", "", "results directory whose sizes to add")
	flags.Parse(args)
	e, err := expectedLoad(root)
	if err != nil {
		return err
	}
	for _, bench := range benchNames {
		for size := 1; size <= 3; size++ {
			e.want(bench, size)
		}
	}
	if *in != "" {
		runs, err := runsLoad(filepath.Join(*in, "raw.jsonl"))
		if err != nil {
			return err
		}
		for _, r := range runs {
			if r.Bench != "" && r.Size > 0 {
				e.want(r.Bench, r.Size)
			}
		}
	}
	return e.save()
}
