// Command gopher-lua runs a Lua 5.1 script with github.com/yuin/gopher-lua,
// with its arguments in the arg table as the lua command sets them.
package main

import (
	"fmt"
	"os"

	lua "github.com/yuin/gopher-lua"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: gopher-lua script.lua [args...]")
		os.Exit(2)
	}
	stop := profileStart()
	state := lua.NewState()
	args := state.NewTable()
	for i, value := range os.Args[1:] {
		args.RawSetInt(i, lua.LString(value))
	}
	state.SetGlobal("arg", args)
	// os.exit leaves through os.Exit, so it stops the profile first.
	state.GetGlobal("os").(*lua.LTable).RawSetString("exit", state.NewFunction(func(l *lua.LState) int {
		stop()
		os.Exit(l.OptInt(1, 0))
		return 0
	}))
	if err := state.DoFile(os.Args[1]); err != nil {
		stop()
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	stop()
}
