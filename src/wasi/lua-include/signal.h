// lua.c only installs a SIGINT handler; wasm has no signals.
#ifndef _BENCH_SIGNAL_H
#define _BENCH_SIGNAL_H
typedef int sig_atomic_t;
typedef void (*sighandler_t)(int);
#define SIGINT 2
#define SIG_DFL ((sighandler_t)0)
static inline sighandler_t signal(int s, sighandler_t h) { (void)s; (void)h; return SIG_DFL; }
#endif
