local ffi = require("cffi")

ffi.cdef [[
    struct foo {
        char a;
        char b;
        char c;
        char d;
    };
]]

local buf = ffi.new("char[256]")
assert(ffi.sizeof(buf) == 256)

ffi.copy(buf, "hello world")
assert(ffi.string(buf) == "hello world")
assert(ffi.string(buf + 6) == "world")

ffi.fill(buf, ffi.sizeof(buf))
assert(ffi.string(buf) == "")

ffi.fill(buf, 8, string.byte("A"))
assert(ffi.string(buf) == "AAAAAAAA")

ffi.fill(buf, 32)
ffi.copy(buf, "hello world", 5)
assert(ffi.string(buf) == "hello")

-- https://github.com/q66/cffi-lua/issues/10
-- make sure passing through lua strings works
assert(ffi.string("hello world") == "hello world")
assert(ffi.string("hello world", 4) == "hell")

-- https://github.com/q66/cffi-lua/issues/61
buf = ffi.new("struct foo[3]")
elem = buf[1]
sb = string.byte("x")
ffi.fill(elem, 2, sb)
assert(elem.a == sb)
assert(elem.b == sb)
assert(elem.c == 0)
assert(elem.d == 0)

-- struct cdata value as destination in copy and fill
local s = ffi.new("struct foo")
ffi.fill(s, 2, sb)
assert(s.a == sb)
assert(s.b == sb)
assert(s.c == 0)
assert(s.d == 0)

ffi.copy(s, "1234", 4)
assert(s.a == string.byte("1"))
assert(s.b == string.byte("2"))
assert(s.c == string.byte("3"))
assert(s.d == string.byte("4"))
