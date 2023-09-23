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
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

local getNumber = function(...)
    local r = {...}
    for i = 1, #r do r[i] = input.getNumber(r[i]) end
    return table.unpack(r)
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

local MatMul3xVec3 = function(m,v)
    return Vec3(
        m[1][1]*v.x + m[2][1]*v.y + m[3][1]*v.z,
        m[1][2]*v.x + m[2][2]*v.y + m[3][2]*v.z,
        m[1][3]*v.x + m[2][3]*v.y + m[3][3]*v.z
    )
end

local getRotationMatrixZYX = function(ang)
    local sx,sy,sz, cx,cy,cz = math.sin(ang.x),math.sin(ang.y),math.sin(ang.z), math.cos(ang.x),math.cos(ang.y),math.cos(ang.z)
    return {
        {cy*cz,                 cy*sz,               -sy  },
        {-cx*sz + sx*sy*cz,     cx*cz + sx*sy*sz,    sx*cy},
        {sx*sz + cx*sy*cz,      -sx*cz + cx*sy*sz,   cx*cy}
    }
end


local LASER_AMOUNT = 2
local OFFSET_GPS_TO_LASER = {Vec3(-0.25, 0, 0.125), Vec3(0.25, 0, 0.125)}
--local LASER_DIRECTION = {Vec3(0, 0, 1), Vec3(0, 0, 1)}
local LASER_SCAN_FUNCTION = {
    function(time) return math.cos(time), math.sin(time)   end,
    function(time) return math.cos(time), math.sin(time)   end
}


local TICK_DELAY = 5
local laser_xy_pivot_buffer = {}
local laser_xy_pivot_buffer_index = 1
local laser_xyz = {}

for i = 1, #LASER_AMOUNT do
    laser_xy_pivot_buffer[i] = {x = {}, y = {}}
end


local position, angle, rotZYX

local tick = 0
function onTick()
    tick = tick + 1

    position = Vec3(getNumber(1, 2, 3))
    angle = Vec3(getNumber(4, 5, 6))

    rotZYX = getRotationMatrixZYX(angle)


    for i = 1, #LASER_AMOUNT do
        local laser_distance = input.getNumber[6 + i]
        local buffer_index = (laser_xy_pivot_buffer_index - TICK_DELAY -1) % TICK_DELAY +1

        local x, y = LASER_SCAN_FUNCTION[i](tick * 0.0166)
        laser_xy_pivot_buffer[i].x[laser_xy_pivot_buffer_index] = x
        laser_xy_pivot_buffer[i].y[laser_xy_pivot_buffer_index] = y

        if laser_distance > 0 and laser_distance < 4000 and laser_xy_pivot_buffer[i].x[buffer_index] ~= nil then
            local angAzi, angEle = math.atan(laser_xy_pivot_buffer[i].x[buffer_index]), math.atan(laser_xy_pivot_buffer[i].y[buffer_index])
            local len = laser_distance * math.cos(angEle)
            laser_xyz[i] = {
                MatMul3xVec3(rotZYX, OFFSET_GPS_TO_LASER[i]:add( Vec3(math.sin(angAzi)*len, math.sin(angEle)*laser_distance, math.cos(angAzi)*len) ))
                :add(position)
                :unpack()
            }
        else
            laser_xyz[i] = {0,0,0}
        end

        local output_offset = (i - 1) * 5

        output.setNumber(output_offset + 1, x)
        output.setNumber(output_offset + 2, y)

        for j = 1, 3 do
            output.setNumber(output_offset + j + 2, laser_xyz[j])
        end
    end

    laser_xy_pivot_buffer_index = laser_xy_pivot_buffer_index % TICK_DELAY + 1
end



