local ffi = require("cffi")

-- strings are convertible to char pointers

local foo = "hello world"
local foop = ffi.cast("const char *", foo)

assert(ffi.string(foop) == "hello world")

-- pointer<->number conversions

local up = ffi.cast("uintptr_t", foop)
local op = ffi.cast("const char *", up)

assert(ffi.string(op) == "hello world")
assert(op == foop)

-- passing pointers as arrays is ok

local x = ffi.new("int[2]", {5, 10})
local xp = ffi.cast("int *", x)

local tap = ffi.cast("void (*)(int p[2])", function(p)
    assert((p[0] == 5) and (p[1] == 10))
end)

tap(x)
tap(xp)

tap:free()

-- string conversion to const byte pointers and const void *

ffi.cdef [[
    struct test_str_assign {
        const unsigned char *u;
        const signed char *s;
        const int8_t *i;
        const void *v;
        unsigned char *mut_u;
        const uint16_t *u16;
    };
]]
local t = ffi.new("struct test_str_assign")
t.u = "abc"
assert(ffi.string(t.u) == "abc")
t.s = "abc"
assert(ffi.string(t.s) == "abc")
t.i = "abc"
assert(ffi.string(t.i) == "abc")
t.v = "abc"
assert(ffi.string(t.v, 3) == "abc")

assert(not pcall(function() t.mut_u = "abc" end))
assert(not pcall(function() t.u16 = "abc" end))

-- pointer conversion between same-size integer types

ffi.cdef [[
    struct test_ptr_assign {
        unsigned int *u;
        unsigned char **ucp;
        const unsigned int *cu;
    };
]]
local pa = ffi.new("struct test_ptr_assign")
local i1 = ffi.new("int[1]")
pa.u = i1
assert(pa.u == ffi.cast("unsigned int *", i1))

local cp1 = ffi.new("char *[1]")
pa.ucp = cp1

pa.cu = i1

assert(not pcall(function() pa.u = ffi.new("char[4]") end))
assert(not pcall(function() pa.u = ffi.new("short[1]") end))
assert(not pcall(function() pa.u = ffi.new("int64_t[1]") end))
assert(not pcall(function() pa.u = ffi.new("float[1]") end))
assert(not pcall(function() pa.u = ffi.cast("const int *", i1) end))
assert(not pcall(function()
    local b = ffi.new("bool[1]")
    local p2 = ffi.new("struct { unsigned char *p; }")
    p2.p = b
end))
