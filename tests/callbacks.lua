local ffi = require("cffi")

-- named args
local called = false
local cb = ffi.cast("void (*)(char const *arg1, int arg2)", function(arg1, arg2)
    assert(ffi.string(arg1) == "hello world")
    assert(ffi.tonumber(arg2) == 5)
    called = true
end)

cb("hello world", 5)
assert(called)

-- setting different callback
local called2 = false
cb:set(function() called2 = true end)

cb("foo", 10)
assert(called2)

cb:free()

-- unnamed args
local called3 = false
local cb2 = ffi.cast("void (*)(int, double)", function(a, b)
    assert(a == 5)
    assert(b == 3.14)
    called3 = true
end)

cb2(5, 3.14)
assert(called3)

cb2:free()

-- funcs in structs

ffi.cdef [[
    struct test {
        void (*cb)();
    };
]]

local st = ffi.new("struct test")

local called, called2 = false, false

-- this also works, but it will leak memory!
--st.cb = function() called = true end
--assert(not called)
--st.cb()
--assert(called)

local cb3 = ffi.cast("void (*)()", function() called2 = true end)
st.cb = cb3
assert(not called2)
st.cb()
assert(called2)
cb3:free()

-- NULL function pointers
assert(ffi.cast("void (*)()", 0) == ffi.nullptr)
assert(ffi.new("void (*)()") == ffi.nullptr)
assert(ffi.new("void (*)()", nil) == ffi.nullptr)

local st2 = ffi.new("struct test")
assert(st2.cb == ffi.nullptr)

if ffi.cast("int *", 0) == nil then
    assert(ffi.cast("void (*)()", 0) == nil)
    assert(ffi.new("void (*)()") == nil)
    assert(ffi.new("void (*)()", nil) == nil)
    assert(st2.cb == nil)
end

local ok, err = pcall(function()
    local fn = ffi.cast("void (*)()", 0)
    fn()
end)
assert(not ok and err:find("attempt to call a NULL function pointer"))

local ok2, err2 = pcall(function()
    st2.cb()
end)
assert(not ok2 and err2:find("attempt to call a NULL function pointer"))
