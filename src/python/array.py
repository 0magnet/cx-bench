"""Bubble sorts a reversed array of 150 once per round."""


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        nums = [0] * 150
        for _ in range(size):
            for i in range(150):
                nums[i] = 150 - i
            swaps = 0
            for i in range(149):
                for j in range(1, 150 - i):
                    if nums[j - 1] > nums[j]:
                        nums[j - 1], nums[j] = nums[j], nums[j - 1]
                        swaps += 1
            h = fnv(h, swaps)
            ok = ok and swaps == 11175
        for i in range(150):
            h = fnv(h, nums[i])
            ok = ok and (size == 0 or nums[i] == i + 1)
        return h, ok
    return run
