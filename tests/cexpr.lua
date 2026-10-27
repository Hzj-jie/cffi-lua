local ffi = require("cffi")

ffi.cdef [[
    typedef enum {
        A = 1 << 0,
        B = 1 << 1,
        AB = A | B,
        C = 1 << 2,
        D = 1 << 3,
        E = 1 << 4,
        F = 1 << 5,
        G = 1 << 6,
        AC = A | C,
        ABC = AB | C,
        ALL = ABC | D | E | F | G
    } Test;
]]

assert(ffi.C.A == 1)
assert(ffi.C.B == 2)
assert(ffi.C.AB == 3)
assert(ffi.C.C == 4)
assert(ffi.C.D == 8)
assert(ffi.C.E == 16)
assert(ffi.C.F == 32)
assert(ffi.C.G == 64)
assert(ffi.C.AC == 5)
assert(ffi.C.ABC == 7)
assert(ffi.C.ALL == 127)

ffi.cdef [[
    enum test_enum_bounds {
        BOUND_NEG = -1,
        BOUND_ZERO = 0,
        BOUND_INT_MAX = 2147483647,
        BOUND_UINT_SIGN = 2147483648,
        BOUND_HEX = 0x80000000,
        BOUND_UINT_MAX = 4294967295,
        BOUND_HEX_MAX = 0xffffffff,
    };
]]

assert(ffi.C.BOUND_NEG == -1)
assert(ffi.C.BOUND_ZERO == 0)
assert(ffi.C.BOUND_INT_MAX == 2147483647)
assert(ffi.C.BOUND_UINT_SIGN == 2147483648)
assert(ffi.C.BOUND_HEX == 2147483648)
assert(ffi.C.BOUND_UINT_MAX == 4294967295)
assert(ffi.C.BOUND_HEX_MAX == 4294967295)

ffi.cdef [[
    static const int SC_A = 4294967295;
    static const int SC_B = 2147483648;
    static const int SC_C = 0x80000000;
    static const unsigned int SC_U = 0xFFFFFFFF;
    static const int SC_MULTI_1 = 10, SC_MULTI_2 = 20;
]]

assert(ffi.C.SC_A == -1)
assert(ffi.C.SC_B == -2147483648)
assert(ffi.C.SC_C == -2147483648)
assert(ffi.C.SC_U == 4294967295)
assert(ffi.C.SC_MULTI_1 == 10)
assert(ffi.C.SC_MULTI_2 == 20)
