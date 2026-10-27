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

-- verify luaopen_ffi entrypoint is exported
local tl_path = os.getenv("CFFI_PATH") or "./build"
local open_fn = package.loadlib(tl_path .. "/cffi.so", "luaopen_ffi")
assert(type(open_fn) == "function")
