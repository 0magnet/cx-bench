// _start for a wasip1 command: the wasi-libc TinyGo builds has no crt1.
#include <stdlib.h>
#include <wasi/api.h>
extern void __wasm_call_ctors(void);
extern int __main_void(void) __attribute__((weak));
extern int __main_argc_argv(int, char **) __attribute__((weak));
__attribute__((export_name("_start"))) void _start(void) {
	__wasm_call_ctors();
	if (!__main_argc_argv)
		exit(__main_void());
	size_t argc = 0, size = 0;
	(void)__wasi_args_sizes_get(&argc, &size);
	char **argv = malloc((argc + 1) * sizeof(char *));
	char *buf = malloc(size ? size : 1);
	(void)__wasi_args_get((uint8_t **)argv, (uint8_t *)buf);
	argv[argc] = 0;
	exit(__main_argc_argv((int)argc, argv));
}
