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
    simulator:setScreen(1, "5x5")

    simulator:setProperty("w", 160)
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

        --  CameraTransform with euler angles (0,0,0) and:
        --  simulator:setProperty("near", 0.25)
        --  simulator:setProperty("renderDistance", 1000)
        --  simulator:setProperty("sizeX", 0.7)
        --  simulator:setProperty("sizeY", 0.7)
        --  simulator:setProperty("positionOffsetX", 0)
        --  simulator:setProperty("positionOffsetY", 0.01)

        simulator:setInputNumber(1, 1.6398879024402608)
        simulator:setInputNumber(6, -1.6398879024402608)
        simulator:setInputNumber(10, -0.07676870836624368)
        simulator:setInputNumber(11, 1.0005742903860038)
        simulator:setInputNumber(12, 1.0)
        simulator:setInputNumber(13, -0.5742903860038647)

        simulator:setInputNumber(14, simulator:getSlider(1)*50)         -- cameraTranslation.x
        simulator:setInputNumber(15, simulator:getSlider(2)*50)         -- cameraTranslation.y
        simulator:setInputNumber(16, (simulator:getSlider(3)) * -100)   -- cameraTranslation.z
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
            --[[ point := {x[0;width], y[0;height], depth[0;1]} ]]
            point_buffer[#point_buffer+1] = {X*W*px_cx + px_cx_pos, Y*W*px_cy + px_cy_pos, Z*W}
        end
    end

    return point_buffer
end

local WorldToScreen_triangles = function(triangles)
    local triangle_buffer = {}


    return triangle_buffer
end
--#endregion Initialization



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


-- [[ debug in VSCode
local data = {}
for i = 1, 10000 do
    data[i] = {(math.random()-0.5)*100, (math.random()-0.5)*100, (math.random()-0.25)*100}
end

-- linearize depth[0;1]
-- zNear * zFar / (zFar + d * (zNear - zFar))
local n,f = 0.25, 1000
local n_mul_f = n*f
local n_sub_f = n-f
local t1,t2 = 0,0

function onDraw()
    t1 = os.clock()

    if isRendering then
        local points_buffer = WorldToScreen_points(data)

        for i = 1, #points_buffer do
            local d = n_mul_f/(f + points_buffer[i][3]*n_sub_f)

            screen.setColor(d, 255-d, 0, 200)
            screen.drawCircleF(points_buffer[i][1], points_buffer[i][2], 0.6)
        end

        screen.setColor(255,0,0)
        screen.drawText(0,10, "in view: "..#points_buffer)
    end

    t2 = os.clock()
    screen.drawText(0,0, string.format("Elapsed time (sec): %.3f", t2-t1))
end
-- ]]