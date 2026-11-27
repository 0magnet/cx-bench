// libc pieces Lua links that some TinyGo builds of wasi-libc leave out. C
// locale, ASCII. system, tmpfile and tmpnam fail as on a host without them.
// Weak, so a wasi-libc that has them wins.
#include <stdio.h>
#include <time.h>
#define WEAK __attribute__((weak))
WEAK int isalnum(int c) { return (unsigned)(c | 32) - 'a' < 26 || (unsigned)c - '0' < 10; }
WEAK int iscntrl(int c) { return (unsigned)c < 32 || c == 127; }
WEAK int ispunct(int c) { return c > 32 && c < 127 && !isalnum(c); }
WEAK int isxdigit(int c) { return (unsigned)c - '0' < 10 || (unsigned)(c | 32) - 'a' < 6; }
WEAK int tolower(int c) { return (unsigned)c - 'A' < 26 ? c | 32 : c; }
WEAK int toupper(int c) { return (unsigned)c - 'a' < 26 ? c & 0x5f : c; }
WEAK const char __utc[] = "UTC";
WEAK clock_t clock(void) {
	struct timespec ts;
	clock_gettime(CLOCK_MONOTONIC, &ts);
	return (clock_t)(ts.tv_sec * CLOCKS_PER_SEC + ts.tv_nsec / (1000000000 / CLOCKS_PER_SEC));
}
WEAK int system(const char *cmd) { return cmd ? -1 : 0; }
WEAK FILE *tmpfile(void) { return NULL; }
WEAK char *tmpnam(char *s) { (void)s; return NULL; }
