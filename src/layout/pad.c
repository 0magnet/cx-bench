/* Linked first in the layout b builds of the C and cx-llvm forms, so the
   code after it lands at another address. */
unsigned long long cxbench_layout_pad(unsigned long long *x, int n) {
	unsigned long long s = 0;
	for (int i = 0; i < n; i++) {
		s += x[i] * 2654435761ULL ^ (s >> 7);
		s ^= s << 13;
	}
	return s + 17;
}
