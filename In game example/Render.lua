-- Author: Jumper
-- GitHub: https://github.com/Jumper-44
-- Workshop: https://steamcommunity.com/profiles/76561198084249280/myworkshopfiles/
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "9x5")

    simulator:setProperty("w", 288)
    simulator:setProperty("h", 160)
    simulator:setProperty("pxOffsetX", 0)
    simulator:setProperty("pxOffsetY", 0)

    simulator:setProperty("b64", "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

    simulator:setProperty("v1", "BBIgAAA/8AAABASAAABBJgAAA/8AAABASAAABBJgAABACAAABASAAABBIgAABACAAABASAAABBIgAAA/8AAABAWAAABBJgAAA/8AAABAWAAABBJgAABACAAABAWAAA")
    simulator:setProperty("v2", "BBIgAABACAAABAWAAABBKgAABAKAAABApAAABBLgAABAKAAABApAAABBLgAABAOAAABApAAABBKgAABAOAAABApAAABBKgAABAKAAABAvAAABBLgAABAKAAABAvAAA")
    simulator:setProperty("v3", "BBLgAABAOAAABAvAAABBKgAABAOAAABAvAAABBOgAABArAAABA7AAABBQgAABArAAABA7AAABBQgAABAtAAABA7AAABBOgAABAtAAABA7AAABBOgAABArAAABA/AAA")
    simulator:setProperty("v4", "BBQgAABArAAABA/AAABBQgAABAtAAABA/AAABBOgAABAtAAABA/AAABBXgAABACAAABAnAAABBbgAABACAAABAnAAABBbgAABASAAABAnAAABBXgAABASAAABAnAAA")
    simulator:setProperty("v5", "BBXgAABACAAABAvAAABBbgAABACAAABAvAAABBbgAABASAAABAvAAABBXgAABASAAABAvAAA")

    simulator:setProperty("t1", "BAAAAAA/gAAABAQAAABAQAAAA/gAAABAgAAABA4AAABAoAAABAwAAABBAAAABAoAAABA4AAABAoAAAA/gAAABAwAAABAwAAAA/gAAABAAAAABAQAAABAgAAABA4AAA")
    simulator:setProperty("t2", "BA4AAABAgAAABBAAAABAgAAAA/gAAABBAAAABBAAAAA/gAAABAoAAABAwAAABAAAAABA4AAABA4AAABAAAAABAQAAABBIAAABBEAAABBMAAABBMAAABBEAAABBQAAA")
    simulator:setProperty("t3", "BBcAAABBUAAABBYAAABBgAAABBUAAABBcAAABBUAAABBEAAABBYAAABBYAAABBEAAABBIAAABBMAAABBQAAABBcAAABBcAAABBQAAABBgAAABBQAAABBEAAABBgAAA")
    simulator:setProperty("t4", "BBgAAABBEAAABBUAAABBYAAABBIAAABBcAAABBcAAABBIAAABBMAAABBkAAABBiAAABBmAAABBmAAABBiAAABBoAAABBuAAABBqAAABBsAAABBwAAABBqAAABBuAAA")
    simulator:setProperty("t5", "BBqAAABBiAAABBsAAABBsAAABBiAAABBkAAABBmAAABBoAAABBuAAABBuAAABBoAAABBwAAABBoAAABBiAAABBwAAABBwAAABBiAAABBqAAABBsAAABBkAAABBuAAA")
    simulator:setProperty("t6", "BBuAAABBkAAABBmAAABB0AAABByAAABB2AAABB2AAABByAAABB4AAABB+AAABB6AAABB8AAABCAAAABB6AAABB+AAABB6AAABByAAABB8AAABB8AAABByAAABB0AAA")
    simulator:setProperty("t7", "BB2AAABB4AAABB+AAABB+AAABB4AAABCAAAABB4AAABByAAABCAAAABCAAAABByAAABB6AAABB8AAABB0AAABB+AAABB+AAABB0AAABB2AAA")

    simulator:setProperty("c1", "AAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAA")
    simulator:setProperty("c2", "AAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAA")
    simulator:setProperty("c3", "BDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAA")
    simulator:setProperty("c4", "BDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAA")
    simulator:setProperty("c5", "BDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAABDfwAABDfwAAAAAAAA")
    simulator:setProperty("c6", "BDfwAABDfwAAAAAAAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAA")
    simulator:setProperty("c7", "AAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAAAAAAAAAAAAAABDfwAA")

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, true) -- screenConnection.isTouched)
        for i = 1, 16 do simulator:setInputNumber(i, 0) end

        --  Current CameraTransform settings with euler angles (0,0,0):
        --  simulator:setProperty("near", 0.25)
        --  simulator:setProperty("renderDistance", 1000)
        --  simulator:setProperty("sizeX", 0.7 * (288/160))
        --  simulator:setProperty("sizeY", 0.7)
        --  simulator:setProperty("positionOffsetX", 0)
        --  simulator:setProperty("positionOffsetY", 0.01)

        simulator:setInputNumber(1, 0.9110488346890337)
        simulator:setInputNumber(6, -1.6398879024402608)
        simulator:setInputNumber(10, -0.07676870836624368)
        simulator:setInputNumber(11, 1.0005742903860038)
        simulator:setInputNumber(12, 1.0)
        simulator:setInputNumber(13, -0.5742903860038647)

        simulator:setInputNumber(14, simulator:getSlider(1)*10)         -- cameraTranslation.x
        simulator:setInputNumber(15, simulator:getSlider(2)*10)         -- cameraTranslation.y
        simulator:setInputNumber(16, (simulator:getSlider(3)-0.5) * -50)   -- cameraTranslation.z
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]





--#region Settings
local px_cx, px_cy = property.getNumber("w")/2, property.getNumber("h")/2
local px_cx_pos, px_cy_pos = px_cx + property.getNumber("pxOffsetX"), px_cy + property.getNumber("pxOffsetY")
--#endregion Settings

--#region Initialization
local getNumber = function(...)
    local r = {...}
    for i = 1, #r do r[i] = input.getNumber(r[i]) end
    return table.unpack(r)
end

local cameraTransform, cameraTranslation = {}, {}
--#endregion Initialization

--#region Render Function(s)
local WorldToScreen_points = function(points)
    local point_buffer = {}

    for i = 1, #points do
        local X, Y, Z, W =
            points[i][1] - cameraTranslation[1],
            points[i][2] - cameraTranslation[2],
            points[i][3] - cameraTranslation[3],
            0

        X,Y,Z,W =
            cameraTransform[1]*X + cameraTransform[5]*Y + cameraTransform[9]*Z,                         -- + cameraTransform[13],
            cameraTransform[2]*X + cameraTransform[6]*Y + cameraTransform[10]*Z,                        -- + cameraTransform[14],
            cameraTransform[3]*X + cameraTransform[7]*Y + cameraTransform[11]*Z + cameraTransform[13],  -- + cameraTransform[15],
            cameraTransform[4]*X + cameraTransform[8]*Y + cameraTransform[12]*Z                         -- + cameraTransform[16]

        -- is the point within the frustum
        if 0<=Z and Z<=W  and  -W<=X and X<=W  and  -W<=Y and Y<=W then
            W = 1/W
            -- point := {x[0;width], y[0;height], depth[0;1]}
            point_buffer[#point_buffer+1] = {X*W*px_cx + px_cx_pos, Y*W*px_cy + px_cy_pos, Z*W}
        end
    end

    return point_buffer
end

-- A triangle_buffer consist of {v1, v2, v3, color}
-- 'v = {x,y,z,id}'
-- 'color = {r,g,b}'
-- The 5th index for every triangle will be set to {tv1, tv2, tv3, triangle_depth}' by the function. 'tv' is the triangle transformed vertex
local WorldToScreen_triangles = function(triangle_buffer, isRemovingOutOfViewTriangles)
    local vertices_buffer = {}

    for i = #triangle_buffer, 1, -1 do -- Reverse iteration, so indexes can be removed from triangle_buffer while traversing if 'isRemovingOutOfViewTriangles == true'
        local currentTriangle, transformed_vertices = triangle_buffer[i], {}

        -- Loop is for finding or calculating the 3 transformed_vertices of currentTriangle
        for j = 1, 3 do
            local currentVertex = currentTriangle[j]
            local id = currentVertex[4]

            if vertices_buffer[id] == nil then -- is the transformed vertex NOT already calculated
                local X, Y, Z, W =
                    currentVertex[1] - cameraTranslation[1],
                    currentVertex[2] - cameraTranslation[2],
                    currentVertex[3] - cameraTranslation[3],
                    0

                X,Y,Z,W =
                    cameraTransform[1]*X + cameraTransform[5]*Y + cameraTransform[9]*Z,                         -- + cameraTransform[13],
                    cameraTransform[2]*X + cameraTransform[6]*Y + cameraTransform[10]*Z,                        -- + cameraTransform[14],
                    cameraTransform[3]*X + cameraTransform[7]*Y + cameraTransform[11]*Z + cameraTransform[13],  -- + cameraTransform[15],
                    cameraTransform[4]*X + cameraTransform[8]*Y + cameraTransform[12]*Z                         -- + cameraTransform[16]

                if 0<=Z and Z<=W then -- Is vertex between near and far plane
                    local w = 1/W
                    transformed_vertices[j] = {
                        X*w*px_cx + px_cx_pos, -- x
                        Y*w*px_cy + px_cy_pos, -- y
                        Z*w,                   -- z | depth[0;1]
                        -W<=X and X<=W  and  -W<=Y and Y<=W -- Is vertex in frustum
                    }
                    vertices_buffer[id] = transformed_vertices[j]
                else
                    vertices_buffer[id] = false
                    transformed_vertices[j] = false
                end
            else
                transformed_vertices[j] = vertices_buffer[id]
            end
        end

        local v1, v2, v3 = transformed_vertices[1], transformed_vertices[2], transformed_vertices[3]
        if
            v1 and v2 and v3                                                                            -- Are all vertices within near and far plane
            and (v1[4] or v2[4] or v3[4])                                                               -- and atleast 1 visible in frustum
            and (v1[1]*v2[2] - v2[1]*v1[2] + v2[1]*v3[2] - v3[1]*v2[2] + v3[1]*v1[2] - v1[1]*v3[2] > 0) -- and is the triangle facing the camera (backface culling CCW. Flip '>' for CW. Can be removed if triangles aren't consistently ordered CCW/CW)
        then
            currentTriangle[5] = {
                v1,
                v2,
                v3,
                (1/3)*(v1[3] + v2[3] + v3[3]) -- triangle depth for doing painter's algorithm
            }
        elseif isRemovingOutOfViewTriangles then
            table.remove(triangle_buffer, i)
        else
            currentTriangle[5] = false
        end
    end

    -- painter's algorithm
    table.sort(triangle_buffer,
        function(t1,t2)
            return t1[5] and t2[5] and (t1[5][4] > t2[5][4])
        end
    )
end
--#endregion Render Function(s)

--#region custom
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

local getRotationMatrixZYX = function(ang)
    local sx,sy,sz, cx,cy,cz = math.sin(ang[1]),math.sin(ang[2]),math.sin(ang[3]), math.cos(ang[1]),math.cos(ang[2]),math.cos(ang[3])
    return {
        {cy*cz,                 cy*sz,              -sy  },
        {-cx*sz + sx*sy*cz,     cx*cz + sx*sy*sz,   sx*cy},
        {sx*sz + cx*sy*cz,      -sx*cz + cx*sy*sz,  cx*cy}
    }
end
--#endregion custom

local VERTEX_DATA, TRIANGLE_DATA, COLOR_DATA = decode_base64("v", 3), decode_base64("t", 3), decode_base64("c", 3)
local vertex_buffer, triangle_buffer = {}, {}

function onTick()
    isRendering = input.getBool(1)

    if isRendering then
        cameraTransform = {getNumber(1,2,3,4,5,6,7,8,9,10,11,12,13)}
        cameraTranslation = {getNumber(14,15,16)}


        rigGPS = {getNumber(17,18,19)}
        rigAng = {getNumber(20,21,22)}
    end
end


function onDraw()
    if isRendering then
        vertex_buffer = MatrixMultiplication(getRotationMatrixZYX(rigAng), VERTEX_DATA)
        for i = 1, #VERTEX_DATA do
            for k = 1, 3 do
                vertex_buffer[i][k] = vertex_buffer[i][k] + rigGPS[k]
            end
            vertex_buffer[i][4] = i -- set unique id
        end

        for i = 1, #TRIANGLE_DATA do
            triangle_buffer[i] = {
                vertex_buffer[ TRIANGLE_DATA[i][1] ],
                vertex_buffer[ TRIANGLE_DATA[i][2] ],
                vertex_buffer[ TRIANGLE_DATA[i][3] ],
                COLOR_DATA[i]
            }
        end

        WorldToScreen_triangles(triangle_buffer, true)
        for i = 1, #triangle_buffer do
            local tri = triangle_buffer[i][5]

            if tri then
                local color = triangle_buffer[i][4]
                screen.setColor(color[1], color[2], color[3], 225)
                screen.drawTriangleF(tri[1][1], tri[1][2], tri[2][1], tri[2][2], tri[3][1], tri[3][2])

                screen.setColor(255,255,255,100) -- wireframe color
                screen.drawTriangle(tri[1][1], tri[1][2], tri[2][1], tri[2][2], tri[3][1], tri[3][2])
            end
        end

    end
end
