-- Author: Jumper
-- GitHub: https://github.com/Jumper-44



--#region vector class with ':' sugar syntax

---@section vec3
---@class vec3
---@field x number
---@field y number
---@field z number
---@field add fun(a:vec3, b:vec3):vec3
---@field sub fun(a:vec3, b:vec3):vec3
---@field scale fun(a:vec3, b:number):vec3
---@field dot fun(a:vec3, b:vec3):number
---@field cross fun(a:vec3, b:vec3):vec3
---@field len fun(a:vec3):number
---@field normalize fun(a:vec3):vec3
---@field unpack fun(a:vec3, ...:any):number, number, number, ...:any
---@field mult fun(a:vec3, b:vec3):vec3
---@field project fun(a:vec3, b:vec3):vec3
---@field reject fun(a:vec3, b:vec3):vec3
---@field tolocal fun(a:vec3, r:vec3, f:vec3, u:vec3):vec3
---@field toglobal fun(a:vec3, r:vec3, f:vec3, u:vec3):vec3
---@field tospherical fun(a:vec3, r:vec3, f:vec3, u:vec3, c?:vec3):vec3
---Convenient, but slow vector class with x|y|z hash entries and capable of using ':' sugar syntax for vector operations
---@param x? number
---@param y? number
---@param z? number
---@return vec3
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

---@section stoc_vec3
---spherical to cartesian conversion
---@param hor number
---@param ver number
---@param d? number
---@return vec3
function stoc_vec3(hor, ver, d)
    d = d or 1
    return vec3(math.sin(hor) * math.cos(ver) * d, math.cos(hor) * math.cos(ver) * d, math.sin(ver) * d)
end
---@endsection

---@section str2vec3
---comment
---@param str string
---@return vec3
function str2vec3(str) --separator , x,y,z
    local x, y, z = str:match("([^,]+),([^,]+),([^,]+)")
    return vec3(tonumber(x), tonumber(y), tonumber(z))
end
---@endsection

--#endregion

-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

--#region vector
-- Vector library with focus on reusing tables for operations

---@alias vec table
---@alias vec2d table
---@alias vec3d table
---@alias vec4d table

---@section str_to_vec
---Given a string with arbitrary length of the pattern "x,y,...,n" then return the table/vector {x, y, ..., n}
---@param str string
---@param _return? table if table given with array entries then elements will be inserted after #_return
---@return vec
function str_to_vec(str, _return)
    _return = _return or {}
    for v in str:gmatch("([^,]+)") do
        _return[#_return+1] = tonumber(v)
    end
    return _return
end
---@endsection

---@section vec_init2d
---Init 2d vector with array part
---@param x? number
---@param y? number
---@return vec2d
function vec_init2d(x, y)
    return {x or 0, y or 0}
end
---@endsection

---@section vec_init3d
---Init 3d vector with array part
---@param x? number
---@param y? number
---@param z? number
---@return vec3d
function vec_init3d(x, y, z)
    return {x or 0, y or 0, z or 0}
end
---@endsection

---@section vec_init
---comment
---@param rows integer
---@param _return? vec
---@return any
function vec_init(rows, _return)
    _return = _return or {}
    for i = 1, rows do
        _return[i] = 0
    end
    return _return
end
---@endsection

---@section vec_add
---comment
---@param a vec
---@param b vec
---@param _return vec
---@return any
function vec_add(a, b, _return)
    for i = 1, #a do
        _return[i] = a[i] + b[i]
    end
    return _return
end
---@endsection

---@section vec_sub
---comment
---@param a vec
---@param b vec
---@param _return vec
---@return any
function vec_sub(a, b, _return)
    for i = 1, #a do
        _return[i] = a[i] - b[i]
    end
    return _return
end
---@endsection

---@section vec_scale
---comment
---@param a vec
---@param scalar number
---@param _return vec
---@return any
function vec_scale(a, scalar, _return)
    for i = 1, #a do
        _return[i] = a[i] * scalar
    end
    return _return
end
---@endsection

---@section vec_mult
---Element-wise product (Vector Hadamard product)
---@param a vec
---@param b vec
---@param _return vec
---@return any
function vec_mult(a, b, _return)
    for i = 1, #a do
        _return[i] = a[i] * b[i]
    end
    return _return
end
---@endsection

---@section vec_sum
---Sum all elements of vector
---@param a vec
---@return number
function vec_sum(a)
    local sum = 0
    for i = 1, #a do
        sum = sum + a[i]
    end
    return sum
end
---@endsection

---@section vec_dot
---comment
---@param a vec
---@param b vec
---@return number
function vec_dot(a, b)
    local sum = 0
    for i = 1, #a do
        sum = sum + a[i]*b[i]
    end
    return sum
end
---@endsection

---@section vec_cross
---comment
---@param a vec
---@param b vec
---@param _return vec
---@return vec3d?
function vec_cross(a, b, _return)
    _return[1], _return[2], _return[3] =
        a[2]*b[3] - a[3]*b[2],
        a[3]*b[1] - a[1]*b[3],
        a[1]*b[2] - a[2]*b[1]
    return _return
end
---@endsection

---@section vec_det2d
---comment
---@param a vec
---@param b vec
---@return number
function vec_det2d(a, b)
    return a[1]*b[2] - a[2]*b[1]
end
---@endsection

---@section vec_det3d
---comment
---@param a vec
---@param b vec
---@param c vec
---@return number
function vec_det3d(a, b, c)
    return a[1]*b[2]*c[3] + b[1]*c[2]*a[3] + c[1]*a[2]*b[3] - c[1]*b[2]*a[3] - b[1]*a[2]*c[3] - a[1]*c[2]*b[3]
end
---@endsection

---@section vec_len
---comment
---@param a vec
---@return number
function vec_len(a)
    return vec_dot(a, a)^0.5
end
---@endsection

---@section vec_len2
---comment
---@param a vec
---@return number
function vec_len2(a)
    return vec_dot(a, a)
end
---@endsection

---@section vec_normalize
---comment
---@param a vec
---@param _return vec
---@return any
function vec_normalize(a, _return)
    return vec_scale(a, vec_len(a), _return)
end
---@endsection

---@section vec_clone
---comment
---@param a vec
---@param _return? vec
---@return any
function vec_clone(a, _return)
    _return = _return or {}
    for i = 1, #a do
        _return[i] = a[i]
    end
    return _return
end
---@endsection

---@section vec_invert
---comment
---@param a vec
---@param _return vec
---@return any
function vec_invert(a, _return)
    return vec_scale(a, -1, _return)
end
---@endsection

---@section vec_project
---comment
---@param a vec
---@param b vec
---@param _return vec
---@return any
function vec_project(a, b, _return)
    return vec_scale(b, vec_dot(a, b), _return)
end
---@endsection

---@section vec_reject
do
    local temp = {}
    ---comment
    ---@param a vec
    ---@param b vec
    ---@param _return vec
    ---@return any
    function vec_reject(a, b, _return)
        return vec_sub(a, vec_project(a, b, temp), _return)
    end
end
---@endsection

---@section vec_angle
---Returns angle between two vectors
---@param a vec
---@param b vec
---@return number radians
function vec_angle(a, b)
    return math.acos(vec_dot(a, b) / (vec_len(a) * vec_len(b)))
end
---@endsection

---@section vec_stoc
---spherical to cartesian conversion, in which y-axis is up
---@param horizontal_ang number
---@param vertical_ang number
---@param magnitude? number
---@param temp nil -- dirty local variable to reduce char
---@return any
function vec_stoc(horizontal_ang, vertical_ang, magnitude, temp)
    magnitude = magnitude or 1
    temp = math.cos(vertical_ang) * magnitude
    return {
        math.cos(horizontal_ang) * temp,
        math.sin(vertical_ang) * magnitude,
        math.sin(horizontal_ang) * temp
    }
end
---@endsection

---@section vec_ctos
---cartesian to spherical
---@param a vec
---@param temp nil -- dirty local to reduce char
---@return number, number, number
function vec_ctos(a, temp)
    temp = vec_len(a)
    return math.atan(a[3], a[1]), math.asin(a[2]/temp), temp
end
---@endsection


---@section vec_tolocal3d
---transposedMatrix-vector multiplication : _return = <b_x|b_y|b_z><sup>T</sup> * a  
---if matrix is orthonormal (i.e. rotation matrix) then the transpose is the same as inverse  
---a and b_x|y|z are expected to be 3D.  
---b_x|y|z are basis vectors
---@param a vec3d
---@param b_x vec3d
---@param b_y vec3d
---@param b_z vec3d
---@param _return vec
---@return any
function vec_tolocal3d(a, b_x, b_y, b_z, _return)
    _return[1], _return[2], _return[3] =
        vec_dot(b_x, a),
        vec_dot(b_y, a),
        vec_dot(b_z, a)
    return _return
end
---@endsection

---@section vec_toglobal3d
do
    local temp1, temp2 = {}, {}
    ---matrix-vector multiplication : _return = <b_x|b_y|b_z> * a  
    ---a and b_x|y|z are expected to be 3D.  
    ---b_x|y|z are basis vectors
    ---@param a vec3d
    ---@param b_x vec3d
    ---@param b_y vec3d
    ---@param b_z vec3d
    ---@param _return vec
    ---@return any
    function vec_toglobal3d(a, b_x, b_y, b_z, _return)
        return vec_add(
            vec_add(
                vec_scale(b_x, a[1], temp1),
                vec_scale(b_y, a[2], temp2),
                temp2
            ),
            vec_scale(b_z, a[3], temp1),
            _return
        )
    end
end
---@endsection

--#endregion

-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

--#region matrix

---@alias matrix table
---@alias matrix2x2 table
---@alias matrix3x3 table

---@section matrix_init
---init matrix : m[column][row]
---@param rows integer
---@param columns integer
---@param _return? matrix
---@return any
function matrix_init(rows, columns, _return)
    _return = _return or {}
    for i = 1, columns do
        _return[i] = _return[i] or {}
        for j = 1, rows do
            _return[i][j] = 0
        end
    end
    return _return
end
---@endsection

---@section matrix_initIdentity
---init identity matrix : m[column][row]
---@param rows integer
---@param columns integer
---@param _return? matrix
---@return any
function matrix_initIdentity(rows, columns, _return)
    _return = matrix_init(rows, columns, _return)
    for i = 1, math.min(rows, columns) do
        _return[i][i] = 1
    end
    return _return
end
---@endsection

---@section matrix_clone
---clone matrix
---@param m matrix
---@param _return? matrix
---@return any
function matrix_clone(m, _return)
    _return = _return or {}
    for i = 1, #m do
        _return[i] = _return[i] or {}
        for j = 1, #m[1] do
            _return[i][j] = m[i][j]
        end
    end
    return _return
end
---@endsection

---@section matrix_transpose
---matrix transpose
---@param m matrix
---@param _return? matrix -- Cannot be *@param* **m**
---@return any
function matrix_transpose(m, _return)
    _return = _return or {}
    for i = 1, #m[1] do
        _return[i] = _return[i] or {}
        for j = 1, #m do
            _return[i][j] = m[j][i]
        end
    end
    return _return
end
---@endsection

---@section matrix_mult
---matrix multiplication
---@param a matrix
---@param b matrix
---@param _return? matrix
---@return any
function matrix_mult(a, b, _return)
    _return = _return or {}
    for i=1, #b do
        _return[i] = _return[i] or {}
        for j=1, #a[1] do
            _return[i][j] = 0
            for k=1, #a do
                _return[i][j] = _return[i][j] + a[k][j] * b[i][k]
            end
        end
    end
    return _return
end
---@endsection

---@section matrix_multVec2d
---comment
---@param m matrix2x2
---@param v vec2d
---@param _return vec2d
---@return any
function matrix_multVec2d(m, v, _return)
    for i = 1, 2 do
        _return[i] = m[1][i]*v[1] + m[2][i]*v[2]
    end
    return _return
end
---@endsection

---@section matrix_multVec3d
---comment
---@param m matrix3x3
---@param v vec3d
---@param _return vec3d
---@return any
function matrix_multVec3d(m, v, _return)
    for i = 1, 3 do
        _return[i] = m[1][i]*v[1] + m[2][i]*v[2] + m[3][i]*v[3]
    end
    return _return
end
---@endsection

---@section matrix_multVec4d
---comment
---@param m matrix4x4
---@param v vec4d
---@param _return vec4d
---@return any
function matrix_multVec4d(m, v, _return)
    for i = 1, 4 do
        _return[i] = m[1][i]*v[1] + m[2][i]*v[2] + m[3][i]*v[3] + m[4][i]*v[4]
    end
    return _return
end
---@endsection

---@section matrix_getRotX
---Get 3d rotation matrix around x-axis
---@param angle number
---@param _return? matrix3x3
---@return any
function matrix_getRotX(angle, _return)
    _return = matrix_init(3, 3, _return)
    local s, c = math.sin(angle), math.cos(angle)
    _return[1][1] = 1
    _return[2][2] = c
    _return[2][3] = s
    _return[3][2] = -s
    _return[3][3] = c
    return _return
end
---@endsection

---@section matrix_getRotY
---Get 3d rotation matrix around y-axis
---@param angle number
---@param _return? matrix3x3
---@return any
function matrix_getRotY(angle, _return)
    _return = matrix_init(3, 3, _return)
    local s, c = math.sin(angle), math.cos(angle)
    _return[2][2] = 1
    _return[1][1] = c
    _return[1][3] = -s
    _return[3][1] = s
    _return[3][3] = c
    return _return
end
---@endsection

---@section matrix_getRotZ
---Get 3d rotation matrix around z-axis
---@param angle number
---@param _return? matrix3x3
---@return any
function matrix_getRotZ(angle, _return)
    _return = matrix_init(3, 3, _return)
    local s, c = math.sin(angle), math.cos(angle)
    _return[3][3] = 1
    _return[1][1] = c
    _return[1][2] = s
    _return[2][1] = -s
    _return[2][2] = c
    return _return
end
---@endsection

---@section matrix_getRot2d
---Get 2d rotation matrix (around z-axis)
---@param angle number
---@param _return? matrix2x2
---@return any
function matrix_getRot2d(angle, _return)
    _return = _return or matrix_init(2, 2, _return)
    local s, c = math.sin(angle), math.cos(angle)
    _return[1][1] = c
    _return[1][2] = s
    _return[2][1] = -s
    _return[2][2] = c
    return _return
end
---@endsection

---@section matrix_getRotZYX
---Get 3d rotation matrix of the order ZYX, intended when y-axis is up  
---https://www.songho.ca/opengl/gl_anglestoaxes.html
---@param angleX number
---@param angleY number
---@param angleZ number
---@param _return? matrix3x3
---@return any
function matrix_getRotZYX(angleX, angleY, angleZ, _return)
    _return = _return or matrix_init(3, 3, _return)
    local sx,sy,sz, cx,cy,cz = math.sin(angleX),math.sin(angleY),math.sin(angleZ), math.cos(angleX),math.cos(angleY),math.cos(angleZ)
    _return[1][1] = cy*cz
    _return[1][2] = cy*sz
    _return[1][3] = -sy
    _return[2][1] = -cx*sz + sx*sy*cz
    _return[2][2] = cx*cz + sx*sy*sz
    _return[2][3] = sx*cy
    _return[3][1] = sx*sz + cx*sy*cz
    _return[3][2] = -sx*cz + cx*sy*sz
    _return[3][3] = cx*cy
    return _return
end
---@endsection

---@section matrix_getRotZXY
---Get 3d rotation matrix of the order ZYX, intended when z-axis is up  
---https://www.songho.ca/opengl/gl_anglestoaxes.html
---@param angleX number
---@param angleY number
---@param angleZ number
---@param _return? matrix3x3
---@return any
function matrix_getRotZXY(angleX, angleY, angleZ, _return)
    _return = _return or matrix_init(3, 3, _return)
    local sx,sy,sz, cx,cy,cz = math.sin(angleX),math.sin(angleY),math.sin(angleZ), math.cos(angleX),math.cos(angleY),math.cos(angleZ)
    _return[1][1] = cz*cy-sz*sx*sy
    _return[1][2] = sz*cy+cz*sx*sy
    _return[1][3] = -cx*sy
    _return[2][1] = -sz*cx
    _return[2][2] = cz*cx
    _return[2][3] = sx
    _return[3][1] = cz*sy+sz*sx*cy
    _return[3][2] = sz*sy-cz*sx*cy
    _return[3][3] = cx*cy
    return _return
end
---@endsection

---@section matrix_getRotAroundAbitraryAxis
---https://www.songho.ca/opengl/gl_rotate.html
---@param angle number
---@param vec vec3d -- expected to be 3d unit vector
---@param _return? matrix3x3
---@return any
function matrix_getRotAroundAbitraryAxis(angle, vec, _return)
    _return = _return or matrix_init(3, 3, _return)
    local x, y, z, s, c, ic, X, Y, xy, xz, yz, sx, sy, sz
    x, y, z, s, c = vec[1], vec[2], vec[3], math.sin(angle), math.cos(angle)
    ic = 1 - c
    X, Y = ic*x, ic*y
    xy, xz, yz, sx, sy, sz = X*y, X*z, Y*z, s*x, s*y, s*z
    _return[1][1] = X*x + c
    _return[1][2] = xy + sz
    _return[1][3] = xz - sy
    _return[2][1] = xy - sz
    _return[2][2] = Y*y + c
    _return[2][3] = yz + sx
    _return[3][1] = xz + sy
    _return[3][2] = yz - sx
    _return[3][3] = ic*z*z + c
    return _return
end
---@endsection

--#endregion



---@section __vector_matrix_DEBUG__
-- [[ debug1
for t = 1, 5 do
    local t1, t2, t3

    t1 = os.clock()
    do
        for i = 1, 5e5 do
            local a = vec3(i, i)
            local b = a:add(a)
            local dot = a:dot(b)
        end
    end
    t2 = os.clock()
    do -- Not creating tables is a substantial performance difference
        local a = vec_init3d()
        local b = vec_init3d()
        for i = 1, 5e5 do
            a[1], a[2] = i, i
            vec_add(a, a, b)
            local dot = vec_dot(a, b)
        end
    end
    t3 = os.clock()

    print("("..t..")")
    print("time1: "..(t2 - t1))
    print("time2: "..(t3 - t2))
end
--]]

-- [[ debug2
for t = 1, 5 do
    local t1, t2

    t1 = os.clock()
    do
        local m = matrix_initIdentity(4,4)
        local r = matrix_initIdentity(4,4)
        local v = vec_normalize({1,2,3}, {})
        local vr = vec_init3d()
        for i = 1, 1e5 do
            matrix_getRotAroundAbitraryAxis(i, v, r)
            matrix_mult(r, r, m)
            matrix_multVec3d(m, v, vr)
        end
    end
    t2 = os.clock()

    print("time: "..(t2 - t1))
end
--]]
---@endsection