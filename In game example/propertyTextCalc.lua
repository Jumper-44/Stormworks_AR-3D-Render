-- Normal LUA, no SW
-- Encoding data into string with base64, 6 chars per number
-- Run with F5

--#region base64 encode/decode
local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function float_to_base64(num)
    num = string.unpack("I", string.pack("f", num))
    local result = ""
    for i = 1, 6 do
        local index = ((num >> ((6 - i) * 6)) & 0x3F) + 1
        result = result .. string.sub(b64, index, index)
        num = num & ~(0x3F << ((6 - i) * 6))
    end
    return result
end

local function encode_base64(file, matrix, str_name)
    local maxTextPropertyChars = 128
    local floatToStrCharAmount = 6
    local row_len = #matrix[1]
    local columnPerPropertyText = maxTextPropertyChars // (floatToStrCharAmount * row_len)
    local totalPropertyTexts = math.ceil(#matrix/columnPerPropertyText)

    for i = 1, totalPropertyTexts do
        file:write(str_name..i.." ")
        for j = 1, columnPerPropertyText do
            if (i-1)*columnPerPropertyText+j <= #matrix then
                for k = 1, row_len do
                    file:write(float_to_base64(matrix[(i-1)*columnPerPropertyText+j][k]))
                end
            else
                break
            end
        end
        file:write("\n")
    end
end

--[[ Functions to use ingame of SW to read property data end decode
local b64 = property.getText("b64")

local function base64_to_float(str)
    local result = 0
    for i = 1, 6 do
        result = result | (b64:find(str:sub(i, i)) - 1 << ((6 - i) * 6))
    end
    return (string.unpack("f", string.pack("I",result)))
end

local decode_base64 = function(name_str, row_len)
    local matrix, property_iter, column, row = {}, 0, 1, 1
    repeat
        property_iter = property_iter + 1
        local str = property.getText(name_str..property_iter)
        for s in str:gmatch("......") do
            matrix[column] = matrix[column] or {}
            matrix[column][row] = base64_to_float(s)
            row = row + 1
            if row > row_len then
                column, row = column + 1, 1
            end
        end
    until str == ""

    return matrix
end
--]]
--#endregion base64 encode/decode




--#region data that will be encoded
local MatrixMultiplication = function(m1,m2)
    local r = {}
    for i=1,#m2 do
        r[i] = {}
        for j=1,#m1[1] do
            r[i][j] = 0
            for k=1,#m1 do
                r[i][j] = r[i][j] + m1[k][j] * m2[i][k]
            end
        end
    end
    return r
end

local unitCube = {
    {-0.5, -0.5, -0.5},
    { 0.5, -0.5, -0.5},
    { 0.5,  0.5, -0.5},
    {-0.5,  0.5, -0.5},
    {-0.5, -0.5,  0.5},
    { 0.5, -0.5,  0.5},
    { 0.5,  0.5,  0.5},
    {-0.5,  0.5,  0.5}
}
--[[
for i = 1, #unitCube do
    for j = 1, 3 do
        unitCube[i][j] = unitCube[i][j] + 0.5
    end
end
--]]

local cubeTriangleOrder = { -- CW wounding order
        {1, 2, 3}, -- Back face -z
        {1, 3, 4},
        {5, 7, 6}, -- Front face +z
        {5, 8, 7},
        {1, 5, 6}, -- Bottom face -y
        {1, 6, 2},
        {4, 3, 7}, -- Top face +y
        {4, 7, 8},
        {1, 4, 8}, -- Left face -x
        {1, 8, 5},
        {2, 6, 7}, -- Right face +x
        {2, 7, 3}
}
-- [[ Switching cubeTriangleOrder wounding order from CW to CCW
for i = 1, #cubeTriangleOrder do
    cubeTriangleOrder[i][1], cubeTriangleOrder[i][2] = cubeTriangleOrder[i][2], cubeTriangleOrder[i][1]
end
--]]

local ORIGIN_OFFSET = {10.25, 2.0, 3.25}
local MakeCube = function(vertex_data, triangle_data, color_data, translation, angle, scale, color, id_offset)
    local sx,sy,sz, cx,cy,cz = math.sin(angle[1]),math.sin(angle[2]),math.sin(angle[3]), math.cos(angle[1]),math.cos(angle[2]),math.cos(angle[3])
    local rotXYZ = { -- http://www.songho.ca/opengl/gl_anglestoaxes.html
        {cy*cz,     sx*sy*cz+cx*sz,     -cx*sy*cz+sx*sz },
        {-cy*sz,    -sx*sy*sz+cx*cz,    cx*sy*sz+sx*cz  },
        {sy,        -sx*cy,             cx*cy           }
    }

    -- Get vertices of rotated unitCube
    local vertices = MatrixMultiplication(rotXYZ, unitCube)

    for i = 1, 8 do
        vertex_data[i + id_offset*8] = {
            vertices[i][1]*scale[1] + translation[1] + ORIGIN_OFFSET[1],
            vertices[i][2]*scale[2] + translation[2] + ORIGIN_OFFSET[2],
            vertices[i][3]*scale[3] + translation[3] + ORIGIN_OFFSET[3],
            -- vertices_buffer[i + id_offset*8][4] = i + id_offset*8    -- vertex id
        }
    end

    -- write to triangle_buffer
    for i = 1, 12 do
        local id = i + id_offset*12
        triangle_data[id] = {
            cubeTriangleOrder[i][1] + id_offset*8,
            cubeTriangleOrder[i][2] + id_offset*8,
            cubeTriangleOrder[i][3] + id_offset*8
        }

        color_data[id] = {
            color[1],
            color[2],
            color[3]
        }
    end
end


local vertex_data = {}
local triangle_data = {}
local color_data = {}

-- Cubes are first rotated, scaled then translated
MakeCube(vertex_data, triangle_data, color_data, {0, 0, 0}, {0, 0, 0}, {0.25, 0.25, 0.25}, {0, 255, 0}, 0)
MakeCube(vertex_data, triangle_data, color_data, {0.25, 0.75, 2.25}, {0, 0, 0}, {0.25, 0.25, 0.75}, {255, 0, 0}, 1)
MakeCube(vertex_data, triangle_data, color_data, {1.5+0.125, 3.5, 4.25+0.125}, {0, 0, 0}, {0.5, 0.25, 0.5}, {255, 255, 0}, 2)
MakeCube(vertex_data, triangle_data, color_data, {4.0+0.125, 0.50+0.125, 2.0+0.125}, {0, 0, 0}, {1.0, 1.0, 1.0}, {0, 0, 255}, 3)
--#endregion data that will be encoded


local file_dir_str = "In game example/output.txt"
local file = io.open(file_dir_str, "w+")
if file then
    print("Opened file")

    encode_base64(file, vertex_data, "v")
    file:write("\n")

    encode_base64(file, triangle_data, "t")
    file:write("\n")

    encode_base64(file, color_data, "c")
    file:write("\n")

    file:close()
else
    print("Didn't open file")
end