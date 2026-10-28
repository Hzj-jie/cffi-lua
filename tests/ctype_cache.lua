local ffi = require("cffi")

local function check(name, fn)
    local ok, err = pcall(fn)
    if not ok then
        error(("%s failed: %s"):format(name, tostring(err)))
    end
end

check("identity", function()
    local a = ffi.typeof("int *")
    assert(rawequal(a, ffi.typeof("int *")))
end)

check("anon_struct", function()
    local a = ffi.typeof("struct { int a; }")
    local b = ffi.typeof("struct { int a; }")
    assert(not rawequal(a, b))
    assert(not ffi.istype(a, ffi.new(b)))
end)

check("param", function()
    local _ = ffi.typeof("$ *", ffi.typeof("int"))
    local q = ffi.typeof("$ *", ffi.typeof("char"))
    assert(ffi.istype(q, ffi.cast("char *", nil)))
end)

check("late_typedef", function()
    assert(not pcall(ffi.typeof, "cache_late_t"))
    ffi.cdef("typedef int cache_late_t;")
    assert(ffi.sizeof("cache_late_t") == 4)
end)

check("fwd_struct", function()
    ffi.cdef("struct cache_fwd;")
    local _ = ffi.typeof("struct cache_fwd *")
    ffi.cdef("struct cache_fwd { int x; double y; };")
    local s = ffi.new("struct cache_fwd")
    local p = ffi.cast("struct cache_fwd *", s)
    p.x = 7
    p.y = 2.5
    assert(s.x == 7 and s.y == 2.5)
end)

check("vla", function()
    assert(ffi.sizeof(ffi.new("int[?]", 3)) == 12)
    assert(ffi.sizeof(ffi.new("int[?]", 5)) == 20)
end)

check("weak", function()
    local w = setmetatable({}, { __mode = "v" })
    w[1] = ffi.typeof("short *")
    collectgarbage()
    collectgarbage()
    assert(w[1] == nil)
end)
