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



function onTick()
    isRendering = input.getBool(1)

    if isRendering then
        cameraTransform = {getNumber(1,2,3,4,5,6,7,8,9,10,11,12,13)}
        cameraTranslation = {getNumber(14,15,16)}
    end
end


function onDraw()
    if isRendering then

    end
end
