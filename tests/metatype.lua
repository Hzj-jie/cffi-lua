local ffi = require("cffi")

ffi.cdef [[
    typedef struct foo {
        int x;
        int y;
    } foo;
]]

local new_called = 0

local foo = ffi.metatype("foo", {
    __new = function(self, x, y)
        new_called = new_called + 1
        return ffi.new("foo", x, y)
    end,

    __index = {
        named_ctor = function(x, y)
            return ffi.new("foo", x, y)
        end,

        sum = function(self)
            return self.x + self.y
        end
    },

    __len = function(self) return self.x end,
    __unm = function(self) return self.y end,
})

assert(new_called == 0)

local x = foo(5, 10)
assert(x.x == 5)
assert(x.y == 10)
assert(x:sum() == 15)
assert(#x == 5)
assert(-x == 10)

assert(new_called == 1)

local x = foo(5, 10)
assert(new_called == 2)

local x = foo.named_ctor(500, 1000)
assert(x.x == 500)
assert(x.y == 1000)
assert(x:sum() == 1500)

assert(new_called == 2)

-- metatype __eq with non-cdata
ffi.cdef [[
    typedef struct eq_test_s {
        int a;
    } eq_test_s;
]]
local eq_t = ffi.metatype("eq_test_s", {
    __eq = function(a, b)
        return true
    end,
})
local s = eq_t(1)
assert(debug.getmetatable(s).__eq(s, {}) == true)
assert(debug.getmetatable(s).__eq(s, 3) == true)
assert(debug.getmetatable(s).__eq(s, nil) == true)
local p = ffi.cast("eq_test_s *", 1)
assert(debug.getmetatable(p).__eq(p, nil) == false)

-- cdata payload accessor
local payload_fn = debug.getmetatable(s).__cdata_payload
assert(type(payload_fn) == "userdata")
assert(payload_fn == debug.getmetatable(p).__cdata_payload)
