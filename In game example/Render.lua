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

    simulator:setProperty("Laser_amount", 2)
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


require('JumperLib.Math.JL_matrix_transformations')
require('JumperLib.JL_general')



local px_cx, px_cy = property.getNumber("w")/2, property.getNumber("h")/2
local px_cx_pos, px_cy_pos = px_cx + property.getNumber("pxOffsetX"), px_cy + property.getNumber("pxOffsetY")

-- Getting near and far to linearize depth
-- zNear * zFar / (zFar + d * (zNear - zFar))
local near, far = property.getNumber("near"), property.getNumber("far")
local n_mul_f = near*far
local n_sub_f = near-far
local cameraTransform = {}
--#endregion Initialization

--#region Render Function(s)
---point_buffer = {
--- x = {},
--- y = {},
--- z = {},
--- sx = {},
--- sy = {},
--- sz = {},
--- isVisible = {}
---}
---@param cameraTransform table
---@param point_buffer table
local WorldToScreen_points = function(cameraTransform, point_buffer)
    for i = 1, #point_buffer.x do
        local X, Y, Z, W =
            point_buffer.x[i],
            point_buffer.y[i],
            point_buffer.z[i],
            1

            X,Y,Z,W =
            cameraTransform[1]*X + cameraTransform[5]*Y + cameraTransform[9]*Z + cameraTransform[13],
            cameraTransform[2]*X + cameraTransform[6]*Y + cameraTransform[10]*Z + cameraTransform[14],
            cameraTransform[3]*X + cameraTransform[7]*Y + cameraTransform[11]*Z + cameraTransform[15],
            cameraTransform[4]*X + cameraTransform[8]*Y + cameraTransform[12]*Z + cameraTransform[16]

        point_buffer.isVisible[i] = 0<=Z and Z<=W  and  -W<=X and X<=W  and  -W<=Y and Y<=W
        if point_buffer.isVisible[i] then
            W = 1/W
            point_buffer.sx[i] = X*W*px_cx + px_cx_pos      -- [0, width]
            point_buffer.sy[i] = Y*W*px_cy + px_cy_pos      -- [0, height]
            point_buffer.sz[i] = Z*W                        -- [0, 1]   NOT linear
        end
    end
end

---vertex_buffer = {
--- x = {},
--- y = {},
--- z = {},
--- sx = {},
--- sy = {},
--- sz = {},
--- frame = {},
--- inNearAndFar = {},
--- isVisible = {}
---}                                            
---triangle_buffer = {v1_id, v2_id, v3_id, centroid_depth, r, g, b}                 
---frameCount is a number which is unique for each call, so just increment it.
---@param cameraTransform table
---@param vertex_buffer table
---@param triangle_buffer table
---@param frameCount number
---@return table
local WorldToScreen_triangles = function(cameraTransform, vertex_buffer, triangle_buffer, frameCount)
    local vx, vy, vz, sx, sy, sz, vframe, visVisible, vinNearAndFar, new_triangle_buffer =
        vertex_buffer.x,  vertex_buffer.y,  vertex_buffer.z,
        vertex_buffer.sx, vertex_buffer.sy, vertex_buffer.sz,
        vertex_buffer.frame, vertex_buffer.isVisible, vertex_buffer.inNearAndFar, {}

    for i = 1, #triangle_buffer do
        local currentTriangle = triangle_buffer[i]
        for j = 1, 3 do
            local vertex_id = currentTriangle[j]

            if vframe[vertex_id] ~= frameCount then -- is the transformed vertex NOT already calculated
                local X, Y, Z, W =
                    vx[vertex_id],
                    vy[vertex_id],
                    vz[vertex_id],
                    1

                X,Y,Z,W =
                    cameraTransform[1]*X + cameraTransform[5]*Y + cameraTransform[9]*Z + cameraTransform[13],
                    cameraTransform[2]*X + cameraTransform[6]*Y + cameraTransform[10]*Z + cameraTransform[14],
                    cameraTransform[3]*X + cameraTransform[7]*Y + cameraTransform[11]*Z + cameraTransform[15],
                    cameraTransform[4]*X + cameraTransform[8]*Y + cameraTransform[12]*Z + cameraTransform[16]

                vinNearAndFar[vertex_id] = 0<=Z and Z<=W
                if vinNearAndFar[vertex_id] then -- Is vertex between near and far plane
                    visVisible[vertex_id] = -W<=X and X<=W  and  -W<=Y and Y<=W -- Is vertex in frustum (excluded near and far plane test)

                    W = 1/W
                    sx[vertex_id] = X*W*px_cx + px_cx_pos
                    sy[vertex_id] = Y*W*px_cy + px_cy_pos
                    sz[vertex_id] = Z*W
                end
            end
        end

        local v1, v2, v3 = currentTriangle[1], currentTriangle[2], currentTriangle[3]
        if -- (Most average cases) determining if triangle is visible / should be rendered
            vinNearAndFar[v1] and vinNearAndFar[v2] and vinNearAndFar[v3]                                           -- Are all vertices within near and far plane
            and (visVisible[v1] or visVisible[v2] or visVisible[v3])                                                -- and atleast 1 visible in frustum
            and (sx[v1]*sy[v2] - sx[v2]*sy[v1] + sx[v2]*sy[v3] - sx[v3]*sy[v2] + sx[v3]*sy[v1] - sx[v1]*sy[v3] > 0) -- and is the triangle facing the camera (backface culling CCW. Flip '>' for CW. Can be removed if triangles aren't consistently ordered CCW/CW)
        then
            currentTriangle[4] = sz[v1] + sz[v2] + sz[v3] -- centroid depth for sort
            new_triangle_buffer[#new_triangle_buffer+1] = currentTriangle
        end
    end

    table.sort(new_triangle_buffer, function(t1,t2) return t1[4] > t2[4] end) -- painter's algorithm | triangle centroid depth sort
    return new_triangle_buffer
end
--#endregion

--#region property_read_base64
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
--#endregion

local VERTEX_DATA, TRIANGLE_DATA, COLOR_DATA = decode_base64("v", 3), decode_base64("t", 3), decode_base64("c", 3)
local vertex_buffer, triangle_list, triangle_buffer = {x={}, y={}, z={}, sx={}, sy={}, sz={}, frame={}, inNearAndFar={}, isVisible={}}, {}, {}
local rigGPS, rigAng, LASER_AMOUNT, laserPoints = {}, {}, property.getNumber("Laser_amount"), {x = {}, y = {}, z = {}, sx = {}, sy = {}, sz = {}, isVisible = {}} 
local rotationMatrixZYX, tempVec3d, frame = matrix_init(3, 3), vec_init3d(), 0

for i = 1, #TRIANGLE_DATA do
    triangle_list[i] = {
        TRIANGLE_DATA[i][1],
        TRIANGLE_DATA[i][2],
        TRIANGLE_DATA[i][3],
        0,
        COLOR_DATA[i][1],
        COLOR_DATA[i][2],
        COLOR_DATA[i][3]
    }
end

function onTick()
    isRendering = input.getBool(1)
    if input.getBool(2) then -- laser clear
        laserPoints.x = {}
        laserPoints.y = {}
        laserPoints.z = {}
    end

    if isRendering then
        for i = 1, 16 do
            cameraTransform[i] = input.getNumber(i)
        end

        vec_init3d(rigGPS, getNumber3(17,18,19))
        vec_init3d(rigAng, getNumber3(20,21,22))

        for i = 1, LASER_AMOUNT do
            local i_offset = (i-1) * 3
            vec_init3d(tempVec3d, getNumber3(23+i_offset, 24+i_offset, 25+i_offset))

            if tempVec3d[1] ~= 0 and tempVec3d[2] ~= 0 then
                local id = #laserPoints.x+1
                laserPoints.x[id] = tempVec3d[1]
                laserPoints.y[id] = tempVec3d[2]
                laserPoints.z[id] = tempVec3d[3]
            end
        end
    end
end

function onDraw()
    if isRendering then
        frame = frame + 1

        -- laserPoints
        WorldToScreen_points(cameraTransform, laserPoints)
        local isVisible, sx, sy, sz, laserInView = laserPoints.isVisible, laserPoints.sx, laserPoints.sy, laserPoints.sz, 0
        for i = 1, #laserPoints.x do
            if isVisible[i] then
                laserInView = laserInView + 1
                -- zNear * zFar / (zFar + d * (zNear - zFar))
                local dis = n_mul_f / (far + sz[i]*n_sub_f)
                screen.setColor(dis, 255/dis, dis*10%255, 150)
                screen.drawCircleF(sx[i], sy[i], math.max(2.5 - dis, 0.6))
            end
        end

        -- triangles
        matrix_getRotZYX(rigAng[1], rigAng[2], rigAng[3], rotationMatrixZYX)
        matrix_mult(rotationMatrixZYX, VERTEX_DATA, vertex_buffer)
        for i = 1, #VERTEX_DATA do
            vec_add(
                matrix_multVec3d(rotationMatrixZYX, VERTEX_DATA[i], tempVec3d),
                rigGPS,
                tempVec3d -- return
            )
            vertex_buffer.x[i] = tempVec3d[1]
            vertex_buffer.y[i] = tempVec3d[2]
            vertex_buffer.z[i] = tempVec3d[3]
        end

        triangle_buffer = WorldToScreen_triangles(cameraTransform, vertex_buffer, triangle_list, frame)
        sx, sy = vertex_buffer.sx, vertex_buffer.sy
        for i = 1, #triangle_buffer do
            local tri = triangle_buffer[i]
            local v1, v2, v3 = tri[1], tri[2], tri[3]
            if tri then
                screen.setColor(tri[5], tri[6], tri[7], 225)
                screen.drawTriangleF(sx[v1], sy[v1], sx[v2], sy[v2], sx[v3], sy[v3])

                screen.setColor(255,255,255,100) -- wireframe color
                screen.drawTriangle(sx[v1], sy[v1], sx[v2], sy[v2], sx[v3], sy[v3])
            end
        end

        screen.setColor(255,255,0, 100)
        screen.drawText(0,7, "L:"..laserInView)
        screen.drawText(0,14, "T:"..#triangle_buffer)
    end
end