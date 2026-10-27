local ffi = require("cffi")
local L = require("testlib")

ffi.cdef [[
    size_t test_strlen(char const *str);
    size_t test_strlen_void(void const *str) __asm__("test_strlen");
]]

local ret = ffi.tonumber(L.test_strlen("hello world"))
assert(ret == 11)

local ret = ffi.tonumber(L.test_strlen_void("hello world"))
assert(ret == 11)

assert(type(ffi.nullptr) == "userdata")
assert(tonumber(ffi.new("int64_t", 7)) == nil)

-- verify luaopen_ffi entrypoint is exported
local tl_path = os.getenv("CFFI_PATH") or "./build"
local open_fn = package.loadlib(tl_path .. "/cffi.so", "luaopen_ffi")
assert(type(open_fn) == "function")

local orig_type, orig_tonumber = _G.type, _G.tonumber
local ffi_mod = open_fn()
assert(type(ffi_mod.nullptr) == "cdata")
assert(type({}) == "table")
assert(tonumber("ff", 16) == 255)
assert(tonumber(ffi_mod.new("int64_t", 7)) == 7)
assert(tonumber(ffi_mod.nullptr) == nil)
_G.type, _G.tonumber = orig_type, orig_tonumber
