// node wasi.mjs prog.wasm [args...] runs a wasm32-wasip1 command module
// under node:wasi with stdin, stdout and stderr, and the file system at
// CXBENCH_PREOPEN (the repository) opened at the same path.
import { readFileSync } from "node:fs";
import { WASI } from "node:wasi";
import process from "node:process";

const file = process.argv[2];
const root = process.env.CXBENCH_PREOPEN || process.cwd();
const wasi = new WASI({
	version: "preview1",
	args: [file, ...process.argv.slice(3)],
	env: {},
	preopens: { [root]: root },
	returnOnExit: true,
});
const module = await WebAssembly.compile(readFileSync(file));
const instance = await WebAssembly.instantiate(module, wasi.getImportObject());
process.exitCode = wasi.start(instance);
