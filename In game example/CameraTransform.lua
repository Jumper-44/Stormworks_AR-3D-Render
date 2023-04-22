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
    simulator:setProperty("near", 0.25)
    simulator:setProperty("renderDistance", 1000)
    simulator:setProperty("sizeX", 0.7 * 1.8)
    simulator:setProperty("sizeY", 0.7)
    simulator:setProperty("positionOffsetX", 0)
    simulator:setProperty("positionOffsetY", 0.01)

    simulator:setProperty("tick", 0)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, true) -- screenConnection.isTouched)
        --[[
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)
        --]]

        simulator:setInputNumber(1, (simulator:getSlider(1) - 0) * 10)
        simulator:setInputNumber(2, (simulator:getSlider(2) - 0) * 10)
        simulator:setInputNumber(3, (simulator:getSlider(3) - 0.5) * 25)
        simulator:setInputNumber(4, (simulator:getSlider(4)) * math.pi*2)
        simulator:setInputNumber(5, (simulator:getSlider(5)) * math.pi*2)
        simulator:setInputNumber(6, (simulator:getSlider(6)) * math.pi*2)
        simulator:setInputNumber(7, simulator:getSlider(7))
        simulator:setInputNumber(8, simulator:getSlider(8))

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)

    end;
end
---@endsection

--[====[ IN-GAME CODE ]====]





--#region Initialization
local tau = math.pi*2
local Clamp = function(x,s,l) return x < s and s or x > l and l or x end

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

local MatMul3xVec3 = function(m,v)
    return {
        x = m[1][1]*v.x + m[2][1]*v.y + m[3][1]*v.z,
        y = m[1][2]*v.x + m[2][2]*v.y + m[3][2]*v.z,
        z = m[1][3]*v.x + m[2][3]*v.y + m[3][3]*v.z
    }
end

local MatrixTranspose = function(m)
    local r = {}
    for i=1,#m[1] do
        r[i] = {}
        for j=1,#m do
            r[i][j] = m[j][i]
        end
    end
    return r
end

-- Vector3 Class
local function Vec3(x,y,z) return
    {x=x or 0; y=y or 0; z=z or 0;
    add =       function(a,b)   return Vec3(a.x+b.x, a.y+b.y, a.z+b.z) end;
    sub =       function(a,b)   return Vec3(a.x-b.x, a.y-b.y, a.z-b.z) end;
    scale =     function(a,b)   return Vec3(a.x*b, a.y*b, a.z*b) end;
    dot =       function(a,b)   return (a.x*b.x + a.y*b.y + a.z*b.z) end;
    cross =     function(a,b)   return Vec3(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x) end;
    len =       function(a)     return a:dot(a)^0.5 end;
    normalize = function(a)     return a:scale(1/a:len()) end;
    unpack =    function(a,...) return a.x, a.y, a.z, ... end}
end

local currentGPS, previousGPS = Vec3(), Vec3() -- Y-axis is up
local currentAng, previousAng = Vec3(), Vec3() -- Euler angles
local isRendering, isFemale = false, false
local perspectiveProjectionMatrix, rotationMatrixYXZ, cameraTransformMatrix, cameraTranslation = {}, {}, {}, Vec3()
local OFFSET = {}
--#endregion Initialization

--#region Settings
local SCREEN = {
    w = property.getNumber("w"),
    h = property.getNumber("h"),
    near = property.getNumber("near") + 0.625,
    far = property.getNumber("renderDistance"),
    sizeX = property.getNumber("sizeX"),
    sizeY = property.getNumber("sizeY"),
    positionOffsetX = property.getNumber("positionOffsetX"),
    positionOffsetY = property.getNumber("positionOffsetY")
}

SCREEN.r = SCREEN.sizeX/2  + SCREEN.positionOffsetX
SCREEN.l = -SCREEN.sizeX/2 + SCREEN.positionOffsetX
SCREEN.t = SCREEN.sizeY/2  + SCREEN.positionOffsetY
SCREEN.b = -SCREEN.sizeY/2 + SCREEN.positionOffsetY

OFFSET.GPS_to_camera = Vec3(
    property.getNumber("x"),
    property.getNumber("y"),
    property.getNumber("z")
)

OFFSET.tick = property.getNumber("tick")
--#endregion Settings


function onTick()
    isRendering = input.getBool(1)
    output.setBool(1, isRendering)

    if isRendering then
        isFemale = input.getBool(2)

        currentGPS = Vec3(input.getNumber(1), input.getNumber(2), input.getNumber(3))
        currentAng = Vec3(input.getNumber(4), input.getNumber(5), input.getNumber(6))

        local lookX, lookY = input.getNumber(7), input.getNumber(8)

        --{ Position & Rotation Estimation }--
        currentGPS, previousGPS = currentGPS:add( currentGPS:sub(previousGPS):scale(OFFSET.tick) ), currentGPS
        currentAng, previousAng = currentAng:add( currentAng:sub(previousAng):scale(OFFSET.tick) ), currentAng
        --------------------------------------

        -- CameraTransform calculation
        do ------{ Player Head Position }------
            local headAzimuthAng =    Clamp(lookX, -0.277, 0.277) * 0.408 * tau -- 0.408 is to make 100° to 40.8°
            local headElevationAng =  Clamp(lookY, -0.125, 0.125) * 0.9 * tau + 0.404 + math.abs(headAzimuthAng/0.7101) * 0.122 -- 0.9 is to make 45° to 40.5°, 0.404 rad is 23.2°. 0.122 rad is 7° at max yaw.

            local distance = math.cos(headAzimuthAng) * 0.1523
            head_position_offset = Vec3(
                math.sin(headAzimuthAng) * 0.1523,
                math.sin(headElevationAng) * distance -(isFemale and 0.141 or 0.023),
                math.cos(headElevationAng) * distance +(isFemale and 0.132 or 0.161)
            )
            -----------------------------------


            --{ Perspective Projection Matrix Setup }--
            local n = SCREEN.near - head_position_offset.z
            local f = SCREEN.far
            local r = SCREEN.r    - head_position_offset.x
            local l = SCREEN.l    - head_position_offset.x
            local t = SCREEN.t    - head_position_offset.y
            local b = SCREEN.b    - head_position_offset.y

            -- Looking down the +Z axis, +X is right and +Y is up. Projects to x|y:coordinates [-1;1], z:depth [0;1], w:homogeneous coordinate
            perspectiveProjectionMatrix = {
                {2*n/(r-l),         0,              0,              0},
                {0,                 2*n/(b-t),      0,              0},
                {-(r+l)/(r-l),      -(b+t)/(b-t),   f/(f-n),        1},
                {0,                 0,              -f*n/(f-n),     0}
            }
            ------------------------------------------


            ------{ Rotation Matrix Setup }-----
            local sx,sy,sz, cx,cy,cz = math.sin(currentAng.x),math.sin(currentAng.y),math.sin(currentAng.z), math.cos(currentAng.x),math.cos(currentAng.y),math.cos(currentAng.z)

            -- http://www.songho.ca/opengl/gl_anglestoaxes.html
            rotationMatrixYXZ = {
                {cy*cz + sx*sy*sz,      cx*sz,      cy*sx*sz - sy*cz,       0},
                {sx*sy*cz - cy*sz,      cx*cz,      sy*sz + cy*sx*cz,       0},
                {sy*cx,                 -sx,        cx*cy,                  0},
                {0,                     0,          0,                      1}
            }
            -----------------------------------

            -- No translationMatrix due to just subtracting cameraTranslation before matrix multiplication of the cameraTransform
            cameraTranslation = currentGPS:add(MatMul3xVec3(rotationMatrixYXZ, OFFSET.GPS_to_camera:add(head_position_offset)))

            cameraTransformMatrix = MatrixMultiplication(perspectiveProjectionMatrix, MatrixTranspose(rotationMatrixYXZ))
        end

        for i = 1, 3 do
            for j = 1, 4 do
                output.setNumber((i-1)*4 + j, cameraTransformMatrix[i][j])
            end
        end

        output.setNumber(13, cameraTransformMatrix[4][3])
        output.setNumber(14, cameraTranslation.x)
        output.setNumber(15, cameraTranslation.y)
        output.setNumber(16, cameraTranslation.z)
    end

end