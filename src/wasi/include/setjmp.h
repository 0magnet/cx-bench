#ifndef _SETJMP_H
#define _SETJMP_H
typedef unsigned long long jmp_buf[8];
int setjmp(jmp_buf) __attribute__((returns_twice));
_Noreturn void longjmp(jmp_buf, int);
#define _setjmp setjmp
#define _longjmp longjmp
#endif
