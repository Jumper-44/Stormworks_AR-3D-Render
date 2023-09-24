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
--        simulator:setInputBool(1, screenConnection.isTouched)
--        simulator:setInputNumber(1, screenConnection.width)
--        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(7, screenConnection.touchX)
        simulator:setInputNumber(8, screenConnection.touchY)

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



---@class IKDTree
---@section IKDTree 1 _IKDTREE_
---@param k_dimensions interger
---@return table
IKDTree = function(k_dimensions)
    ---Returns the squared length between two points
    ---@param pointA table
    ---@param pointB table
    ---@return number
    local len2 = function(pointA, pointB)
        local sum = 0
        for i = 1, k_dimensions do
            local dis = pointA[i] - pointB[i]
            sum = sum + dis*dis
        end
        return sum
    end

    local tree_root = {leaf = true}

    return {
        len2 = len2;

        ---Inserts a point into the k-d tree
        ---@param point table
        IKDTree_insert = function(point)
            local function insertRecursive(root, cd, depth)
                if root.leaf then
                    root[#root+1] = point
                    if #root == 16 then -- Split node when it contains 16 points
                        table.sort(root, function(a, b) return a[cd] < b[cd] end)
                        root.leaf = false
                        root.split = 0.5 * (root[8][cd] + root[9][cd])
                        root.left = {leaf = true}
                        root.right = {leaf = true}
                        for i = 1, 8 do
                            root.left[i] = root[i]
                            root[i] = nil
                        end
                        for i = 9, 16 do
                            root.right[i - 8] = root[i]
                            root[i] = nil
                        end
                    end
                else
                    return insertRecursive(
                        point[cd] < root.split and root.left or root.right,
                        depth % k_dimensions + 1,
                        depth + 1
                    )
                end
            end

            insertRecursive(tree_root, 1, 1)
        end;

        ---Returns the nearest point(s) in k-d tree to param point up to param maxNeighbors
        ---Will set a value to root[i].len2 if node is traversed
        ---@param point table
        ---@param maxNeighbors integer
        ---@return table
        IKDTree_nearestNeighbors = function(point, maxNeighbors)
            local nearestPoints = {
                ---Insertion sort
                ---@param self table
                ---@param p table
                insert = function(self, p)
                    for i = 1, #self do
                        if p.len2 < self[i].len2 then
                            table.insert(self, i, p)
                            return
                        end
                    end
                    self[#self+1] = p
                end
            }

            local function nearestNeighborsRecursive(root, depth)
                local cd, nextBranch, ortherBranch = depth % k_dimensions + 1, root.right, root.left

                if root.leaf then
                    for i = 1, #root do
                        root[i].len2 = len2(point, root[i])
                        if #nearestPoints < maxNeighbors then
                            nearestPoints:insert(root[i])
                        else
                            if root[i].len2 < nearestPoints[maxNeighbors].len2 then
                                nearestPoints[maxNeighbors] = nil
                                nearestPoints:insert(root[i])
                            end
                        end
                    end
                else
                    if point[cd] < root.split then
                        nextBranch, ortherBranch = root.left, root.right
                    end

                    nearestNeighborsRecursive(nextBranch, depth+1)
                    local dist = point[cd] - root.split
                    if #nearestPoints < maxNeighbors or nearestPoints[maxNeighbors].len2 >= dist*dist then
                        nearestNeighborsRecursive(ortherBranch, depth+1)
                    end
                end
            end

            nearestNeighborsRecursive(tree_root, 0)
            return nearestPoints
        end;
    }
end
---@endsection _IKDTREE_

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

local OFFSET_LASER_CENTER_TO_FACE = 0.125 + 0.017
local PHI = (1 + 5^0.5) / 2
local PHI_SQUARED = PHI * PHI
local TAU = 2*math.pi
local LASER_SCAN_FUNCTION = function(time)
    local angle = TAU * (PHI * time % 1 - 0.5)
    local radius = 1.5 * (PHI_SQUARED * time % 1 - 0.5)
    return radius * math.cos(angle), radius * math.sin(angle)
end

local laser_xy_pivot_buffer = {}
local laser_xy_pivot_buffer_index = 1
local laser_xyz = {}


-- CONFIG
local TICK_DELAY = 6
local LASER_AMOUNT = 2
local OFFSET_GPS_TO_LASER = {Vec3(-0.25, 0, OFFSET_LASER_CENTER_TO_FACE), Vec3(0.25, 0, OFFSET_LASER_CENTER_TO_FACE)}
-- \CONFIG\


for i = 1, LASER_AMOUNT do
    laser_xy_pivot_buffer[i] = {x = {}, y = {}}
end
local position, angle, rotZYX
local tick = 0
local TIME_STEP = PHI/10
local LASER_TIME_STEP = TIME_STEP / LASER_AMOUNT
local kd_tree = IKDTree(3)

function onTick()
    is_laser_on = input.getBool(1)

    tick = tick + 1
    laser_xy_pivot_buffer_index = laser_xy_pivot_buffer_index % TICK_DELAY + 1

    position = Vec3(getNumber(1, 2, 3))
    angle = Vec3(getNumber(4, 5, 6))

    rotZYX = getRotationMatrixZYX(angle)

    for i = 1, LASER_AMOUNT do
        local laser_distance = input.getNumber(6 + i)

        if laser_distance > 0 and laser_distance < 4000 and laser_xy_pivot_buffer[i].x[laser_xy_pivot_buffer_index] ~= nil then
            local rY, rX = laser_xy_pivot_buffer[i].x[laser_xy_pivot_buffer_index], laser_xy_pivot_buffer[i].y[laser_xy_pivot_buffer_index]
            local dist = math.cos(rX) * laser_distance
            laser_xyz[i] = {
                MatMul3xVec3(rotZYX, OFFSET_GPS_TO_LASER[i]:add(Vec3(
                    math.sin(rY) * dist,
                    math.sin(rX) * laser_distance,
                    math.cos(rY) * dist
                )))
                :add(position)
                :unpack()
            }

            local nn = kd_tree.IKDTree_nearestNeighbors(laser_xyz[i], 1)
            if nn[1] == nil or nn[1].len2 > 0.01 then -- If nearest point in pointcloud is not too near then accept point
                kd_tree.IKDTree_insert(laser_xyz[i]);
            else
                laser_xyz[i][1] = 0
                laser_xyz[i][2] = 0
                laser_xyz[i][3] = 0
            end
        else
            laser_xyz[i] = {0,0,0}
        end

        local x, y = LASER_SCAN_FUNCTION(tick * TIME_STEP + (i-1) * LASER_TIME_STEP)

        if is_laser_on then
            laser_xy_pivot_buffer[i].x[laser_xy_pivot_buffer_index] = x / 8 * TAU
            laser_xy_pivot_buffer[i].y[laser_xy_pivot_buffer_index] = y / 8 * TAU
        else
            laser_xy_pivot_buffer[i].x[laser_xy_pivot_buffer_index] = nil
            laser_xy_pivot_buffer[i].y[laser_xy_pivot_buffer_index] = nil
        end

        local output_offset = (i - 1) * 5
        output.setNumber(output_offset + 1, x)
        output.setNumber(output_offset + 2, y)

        for j = 1, 3 do
            output.setNumber(output_offset + j + 2, laser_xyz[i][j])
        end
    end
end



--[[ DEBUG
function onDraw()
    screen.setColor(255, 255, 0)
    for i = 1, 3 do
        screen.drawText(2, (i-1)*7, laser_xyz[1][i])
    end
end
--]]