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
                v1[3] + v2[3] + v3[3] -- triangle depth for doing painter's algorithm
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


--#region VSCode onDraw() examples
----------------------------------------------------
-- It is only for VSCode due to the os.time() function, which is removed ingame of Stormworks LUA. It is at the start and end of onDraw() examples
-- There are two onDraw() examples. One for drawing points and another for triangles
-- To try example, set a spacing for '--[[code]]' to '-- [[code]]' and run in VSCode with F6
-- Sliders 1-3 moves the cameraTranslation
----------------------------------------------------

--[[ debug in VSCode for drawing points with WorldToScreen_points()
do
    local data = {}
    local rand = math.random
    for i = 1, 1E3 do
        data[i] = {(rand()-0.5)*50, (rand()-0.5)*50, (rand())*100}
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
            screen.drawText(0,00, "in view: "..#points_buffer)
        end

        t2 = os.clock()
        screen.drawText(0,10, string.format("Elapsed time (sec): %.3f", t2-t1))
    end
end
--]]


--[[ debug in VSCode for drawing traingles with WorldToScreen_triangles()
do
    local MatrixMultiplication = function(m1,m2) local r = {}for i=1,#m2 do r[i] = {}for j=1,#m1[1] do r[i][j] = 0 for k=1,#m1 do r[i][j] = r[i][j] + m1[k][j] * m2[i][k]end end end return r end

    --#region local unit cube data
    local unitCubePoints = {
        {-0.5, -0.5, -0.5},
        { 0.5, -0.5, -0.5},
        { 0.5,  0.5, -0.5},
        {-0.5,  0.5, -0.5},
        {-0.5, -0.5,  0.5},
        { 0.5, -0.5,  0.5},
        { 0.5,  0.5,  0.5},
        {-0.5,  0.5,  0.5}
    }

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

    local cubeColors = {
        {255, 255, 0}, -- Back face -z (Yellow)
        {255, 255, 0},
        {0, 255, 0}, -- Front face +z (Green)
        {0, 255, 0},
        {0, 255, 255}, -- Bottom face -y (Cyan)
        {0, 255, 255},
        {0, 0, 255}, -- Top face +y (Blue)
        {0, 0, 255},
        {255, 0, 255}, -- Left face -x (Magenta)
        {255, 0, 255},
        {255, 0, 0}, -- Right face +x (Red)
        {255, 0, 0}
    }
    --#endregion local unit cube data

    local MakeCube = function(triangle_buffer, translation, angle, size, id_offset)
        local sx,sy,sz, cx,cy,cz = math.sin(angle[1]),math.sin(angle[2]),math.sin(angle[3]), math.cos(angle[1]),math.cos(angle[2]),math.cos(angle[3])
        local rotXYZ = { -- http://www.songho.ca/opengl/gl_anglestoaxes.html
            {cy*cz,     sx*sy*cz+cx*sz,     -cx*sy*cz+sx*sz },
            {-cy*sz,    -sx*sy*sz+cx*cz,    cx*sy*sz+sx*cz  },
            {sy,        -sx*cy,             cx*cy           }
        }

        -- Get vertices of rotated unitCube
        local vertices = MatrixMultiplication(rotXYZ, unitCubePoints)

        for i = 1, 8 do
            -- set vertex id
            vertices[i][4] = i + id_offset*8

            for j = 1, 3 do
                -- Scale rotated unitCube by 'size' and add translation
                vertices[i][j] = vertices[i][j]*size + translation[j]
            end
        end

        -- Make triangle_buffer
        for i = 1, 12 do
            triangle_buffer[i + id_offset*12] = {
                vertices[ cubeTriangleOrder[i][2] ], -- Swap these 2 to change wounding order of CCW and CW
                vertices[ cubeTriangleOrder[i][1] ], -- 
                vertices[ cubeTriangleOrder[i][3] ],
                cubeColors[i]
            }
        end

        return triangle_buffer
    end


    local cubesAmount = 200
    local cubesPos = {}
    local cubesSize = {}
    local cubesAng = {}

    local rand = math.random
    for i = 1, cubesAmount do
        cubesPos[i] = {(rand()-0.5)*150, (rand()-0.5)*150, rand()*150}
        cubesSize[i] = rand()*7+1
        cubesAng[i] = {ang = {0, 0, 0}, deltaChange = {(rand()-0.5)*0.1, (rand()-0.5)*0.1, (rand()-0.5)*0.1}}
    end

    local t1,t2 = 0,0
    local changingSize = 0.1

    function onDraw()
        t1 = os.clock()

        if isRendering then
            local triangle_buffer = {}

            changingSize = changingSize + 0.05
            MakeCube(triangle_buffer, {3, 3, 30}, {0, 0, 0}, math.sin(changingSize)*4, 0)

            for i = 1, cubesAmount do
                for j = 1, 3 do
                    cubesAng[i].ang[j] = cubesAng[i].ang[j] + cubesAng[i].deltaChange[j]
                end
                MakeCube(triangle_buffer, cubesPos[i], cubesAng[i].ang, cubesSize[i], i)
            end

            WorldToScreen_triangles(triangle_buffer, true)

            for i = 1, #triangle_buffer do
                local tri = triangle_buffer[i][5]

                if tri then
                    local color = triangle_buffer[i][4]
                    screen.setColor(color[1], color[2], color[3], 200)
                    screen.drawTriangleF(tri[1][1], tri[1][2], tri[2][1], tri[2][2], tri[3][1], tri[3][2])
                end
            end

            screen.setColor(255,255,255)
            screen.drawText(0,0, "#Tri_Buffer: "..#triangle_buffer)
        end

        t2 = os.clock()
        screen.setColor(255, 255, 255)
        screen.drawText(0,10, string.format("Elapsed time (sec): %.3f", t2-t1))
    end
end
--]]
--#endregion VSCode onDraw() examples