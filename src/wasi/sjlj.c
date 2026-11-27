// setjmp/longjmp for clang -mllvm -wasm-enable-sjlj, the algorithm of
// wasi-libc libc-top-half/musl/src/setjmp/wasm32/rt.c (not in TinyGo's copy).
#include <stdint.h>
#include <stddef.h>
struct jmp_buf_impl { void *func_invocation_id; uint32_t label; struct { void *env; int val; } arg; };
void __wasm_setjmp(void *env, uint32_t label, void *func_invocation_id) {
	struct jmp_buf_impl *jb = env;
	if (label == 0 || func_invocation_id == NULL) __builtin_trap();
	jb->func_invocation_id = func_invocation_id;
	jb->label = label;
}
uint32_t __wasm_setjmp_test(void *env, void *func_invocation_id) {
	struct jmp_buf_impl *jb = env;
	return jb->func_invocation_id == func_invocation_id ? jb->label : 0;
}
void __wasm_longjmp(void *env, int val) {
	struct jmp_buf_impl *jb = env;
	jb->arg.env = env;
	jb->arg.val = val ? val : 1;
	__builtin_wasm_throw(1, &jb->arg);
}
__asm__(".globl __c_longjmp\n.tagtype __c_longjmp i32\n__c_longjmp:\n");
