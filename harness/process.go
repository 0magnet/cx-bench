package main

import (
	"bufio"
	"bytes"
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strconv"
	"strings"
	"time"
)

// run is one start of a program, or one record of the harness.
type run struct {
	Kind    string           `json:"kind"`
	Form    string           `json:"form"`
	Bench   string           `json:"bench,omitempty"`
	Layout  string           `json:"layout,omitempty"`
	Size    int              `json:"size,omitempty"`
	LoadAvg float64          `json:"loadavg"`
	TotalNs int64            `json:"total_ns"`
	MarksNs map[string]int64 `json:"marks_ns,omitempty"`
	Hash    string           `json:"hash,omitempty"`
	Pass    bool             `json:"pass"`
	Error   string           `json:"error,omitempty"`
	// Server holds the elapsed time each server mode run reported, in us.
	Server []int64 `json:"server_us,omitempty"`
	// SelfUs holds loop1 and loop2 as the program timed them with -time=us.
	SelfUs []int64 `json:"self_us,omitempty"`
	Note   string  `json:"note,omitempty"`
}

func loadAverage() float64 {
	data, err := os.ReadFile("/proc/loadavg")
	if err != nil {
		return -1
	}
	value, _ := strconv.ParseFloat(strings.Fields(string(data))[0], 64)
	return value
}

// processRun starts argv, timestamps each marker byte as it arrives on the
// stderr pipe and returns the times from just before the start. stdin is
// written to the program and closed.
func processRun(argv, env []string, stdin string, timeout time.Duration) (marks map[string]int64, total time.Duration, stdout string, stderr string, err error) {
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	cmd := exec.CommandContext(ctx, argv[0], argv[1:]...)
	cmd.Env = env
	var out bytes.Buffer
	cmd.Stdout = &out
	if stdin != "" {
		cmd.Stdin = strings.NewReader(stdin)
	}
	pipe, err := cmd.StderrPipe()
	if err != nil {
		return nil, 0, "", "", err
	}
	marks = map[string]int64{}
	var text bytes.Buffer
	done := make(chan struct{})
	start := time.Now()
	if err = cmd.Start(); err != nil {
		return nil, 0, "", "", err
	}
	go func() {
		reader := bufio.NewReaderSize(pipe, 1)
		for {
			b, readErr := reader.ReadByte()
			if readErr != nil {
				break
			}
			at := time.Since(start)
			switch b {
			case 'S', '1', '2', 'F':
				key := string(b)
				if _, seen := marks[key]; !seen {
					marks[key] = at.Nanoseconds()
				}
			}
			text.WriteByte(b)
		}
		close(done)
	}()
	<-done
	err = cmd.Wait()
	total = time.Since(start)
	if ctx.Err() != nil {
		err = fmt.Errorf("timeout after %v", timeout)
	}
	io.Copy(io.Discard, pipe)
	return marks, total, out.String(), text.String(), err
}

// oneShot runs a benchmark once and checks the hash and pass line.
func oneShot(f form, layout, bench string, size int, want func(string, int) string, extra ...string) run {
	r := run{Kind: "run", Form: f.label(), Bench: bench, Layout: layout, Size: size}
	argv, err := f.script(layout, "--cmd", bench, strconv.Itoa(size))
	if err != nil {
		r.Error = err.Error()
		return r
	}
	argv = append(argv, extra...)
	r.LoadAvg = loadAverage()
	marks, total, stdout, stderr, err := processRun(argv, f.environment(layout), "", 30*time.Minute)
	r.TotalNs, r.MarksNs = total.Nanoseconds(), marks
	lines := strings.Split(strings.TrimRight(stdout, "\n"), "\n")
	if len(lines) >= 1 {
		r.Hash = strings.TrimSpace(lines[0])
	}
	r.Pass = err == nil && len(lines) >= 2 && lines[1] == bench+" pass"
	if want != nil {
		if expected := want(bench, size); expected != "" && expected != r.Hash {
			r.Pass = false
			r.Error = fmt.Sprintf("hash %s, want %s", r.Hash, expected)
		}
	}
	for _, line := range lines {
		if fields := strings.Fields(line); len(fields) == 4 && fields[0] == "time" && fields[1] == "us" {
			loop1, _ := strconv.ParseInt(strings.TrimPrefix(fields[2], "loop1="), 10, 64)
			loop2, _ := strconv.ParseInt(strings.TrimPrefix(fields[3], "loop2="), 10, 64)
			r.SelfUs = []int64{loop1, loop2}
		}
	}
	if !r.Pass && r.Error == "" {
		r.Error = fmt.Sprintf("%v: %s %s", err, strings.TrimSpace(stdout), strings.TrimSpace(stderr))
	}
	if f.caps["markers"] && r.Pass {
		if markers := markerOrder(stderr); markers != "S12F" {
			r.Pass = false
			r.Error = fmt.Sprintf("markers %q, want S12F", markers)
		}
	}
	return r
}

func markerOrder(stderr string) string {
	var order []byte
	for i := 0; i < len(stderr); i++ {
		switch stderr[i] {
		case 'S', '1', '2', 'F':
			order = append(order, stderr[i])
		}
	}
	return string(order)
}

// emptyRun starts the form's empty program.
func emptyRun(f form, layout string) run {
	r := run{Kind: "empty", Form: f.label(), Layout: layout}
	argv, err := f.script(layout, "--cmd", "empty")
	if err != nil {
		r.Error = err.Error()
		return r
	}
	r.LoadAvg = loadAverage()
	marks, total, _, stderr, err := processRun(argv, f.environment(layout), "", 5*time.Minute)
	r.TotalNs, r.MarksNs = total.Nanoseconds(), marks
	r.Pass = err == nil
	if err != nil {
		r.Error = fmt.Sprintf("%v: %s", err, stderr)
	}
	return r
}

// serverRun starts the form in server mode and runs one benchmark repeats
// times at size, then sends 0.
func serverRun(f form, bench string, size, repeats int) run {
	r := run{Kind: "server", Form: f.label(), Bench: bench, Size: size}
	argv, err := f.script("", "--cmd-server")
	if err != nil {
		r.Error = err.Error()
		return r
	}
	number := benchNumber(bench)
	var input strings.Builder
	for i := 0; i < repeats; i++ {
		fmt.Fprintf(&input, "%d %d us\n", number, size)
	}
	input.WriteString("0\n")
	r.LoadAvg = loadAverage()
	marks, total, stdout, stderr, err := processRun(argv, f.environment(""), input.String(), 30*time.Minute)
	r.TotalNs, r.MarksNs = total.Nanoseconds(), marks
	r.Pass = err == nil
	for _, line := range strings.Split(strings.TrimSpace(stdout), "\n") {
		fields := strings.Fields(line)
		if len(fields) < 3 || fields[0] != strconv.Itoa(number) {
			r.Pass = false
			continue
		}
		if r.Hash == "" {
			r.Hash = fields[1]
		} else if r.Hash != fields[1] {
			r.Pass = false
		}
		elapsed, _ := strconv.ParseInt(fields[2], 10, 64)
		r.Server = append(r.Server, elapsed)
		if len(fields) > 3 {
			r.Pass = false
		}
	}
	if len(r.Server) != repeats {
		r.Pass = false
	}
	if !r.Pass {
		r.Error = fmt.Sprintf("%v: %s %s", err, strings.TrimSpace(stdout), strings.TrimSpace(stderr))
	}
	return r
}

func benchNumber(bench string) int {
	for i, name := range benchNames {
		if name == bench {
			return i + 1
		}
	}
	return 0
}
