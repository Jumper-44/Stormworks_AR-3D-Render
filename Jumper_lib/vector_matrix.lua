-- Author: Jumper
-- GitHub: https://github.com/Jumper-44


---@section vec3
---Convenient vector class with hash entries and capable of using ':' sugar syntax
---@param x number | nil
---@param y number | nil
---@param z number | nil
---@return table
function vec3(x,y,z) return {
    x=x or 0,
    y=y or 0,
    z=z or 0,
    add         = function(a,b)     return vec3(a.x+b.x,a.y+b.y,a.z+b.z) end,
    sub         = function(a,b)     return vec3(a.x-b.x,a.y-b.y,a.z-b.z) end,
    scale       = function(a,b)     return vec3(a.x*b,a.y*b,a.z*b) end,
    dot         = function(a,b)     return a.x*b.x+a.y*b.y+a.z*b.z end,
    cross       = function(a,b)     return vec3(a.y*b.z-a.z*b.y,a.z*b.x-a.x*b.z,a.x*b.y-a.y*b.x) end,
    len         = function(a)       return a:dot(a)^0.5 end,
    normalize   = function(a)       return a:scale(1/a:len()) end,
    unpack      = function(a,...)   return a.x,a.y,a.z,... end,
    clone       = function(a)       return vec3(a.x,a.y,a.z) end,
    mult        = function(a,b)     return vec3(a.x*b.x,a.y*b.y,a.z*b.z) end,
    project     = function(a,b)     return b:scale(a:dot(b)) end,
    reject      = function(a,b)     return a:sub(a:project(b)) end,
    tolocal     = function(a,r,f,u) return vec3(r:dot(a),f:dot(a),u:dot(a)) end,
    toglobal    = function(a,r,f,u) return r:scale(a.x):add(f:scale(a.y)):add(u:scale(a.z)) end,
    tospherical = function(a,r,f,u,c) local b = a:tolocal(r,f,u):sub(c or vec3()) return vec3(math.atan(b.x,b.y),math.asin(b.z/(b:len()))) end
} end
---@endsection



---@section vec_init2d
---Init 2d vector with array part
---@param x number | nil
---@param y number | nil
---@return table
vec_init2d = function(x, y)
    return {x or 0, y or 0}
end
---@endsection

---@section vec_init3d
---Init 3d vector with array part
---@param x number | nil
---@param y number | nil
---@param z number | nil
---@return table
vec_init3d = function(x, y, z)
    return {x or 0, y or 0, z or 0}
end
---@endsection

---@section vec_add
---comment
---@param a table
---@param b table
---@param _return table
vec_add = function(a, b, _return)
    for i = 1, #a do
        _return[i] = a[i] + b[i]
    end
end
---@endsection

---@section vec_sub
---comment
---@param a table
---@param b table
---@param _return table
vec_sub = function(a, b, _return)
    for i = 1, #a do
        _return[i] = a[i] - b[i]
    end
end
---@endsection

---@section vec_scale
---comment
---@param a table
---@param scalar number
---@param _return table
vec_scale = function(a, scalar, _return)
    for i = 1, #a do
        _return[i] = a[i] * scalar
    end
end
---@endsection

---@section vec_dot
---comment
---@param a table
---@param b table
---@return number
vec_dot = function(a, b)
    local sum = 0
    for i = 1, #a do
        sum = sum + a[i]*b[i]
    end
    return sum
end
---@endsection

---@section vec_cross
---comment
---@param a table
---@param b table
---@param _return table
vec_cross = function(a, b, _return)
    _return[1], _return[2], _return[3] =
        a[2]*b[3] - a[3]*b[2],
        a[3]*b[1] - a[1]*b[3],
        a[1]*b[2] - a[2]*b[1]
end
---@endsection





--[[ debug
for t = 1, 5 do
    local t1, t2, t3

    t1 = os.clock()
--    do
--        for i = 1, 5e5 do
--            local a = vec3(i, i)
--            local b = a:add(a)
--            local dot = a:dot(b)
--        end
--    end
    t2 = os.clock()
    do
        local b = Vec3_init()
        for i = 1, 5e5 do
            local a = Vec3_init(i, i)
            Vec3_add(a, a, b)
            local dot = Vec3_dot(a, b)
        end
    end
    t3 = os.clock()

    print("("..t..")")
    print("time1: "..(t2 - t1))
    print("time2: "..(t3 - t2))
end
--]]