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
    local MatrixMultiplication = function(m1,m2)local r = {}for i=1,#m2 do r[i] = {}for j=1,#m1[1] do r[i][j] = 0 for k=1,#m1 do r[i][j] = r[i][j] + m1[k][j] * m2[i][k] end end end return r end
    local MatrixTranspose = function(m)local r = {}for i=1,#m[1] do r[i] = {}for j=1,#m do r[i][j] = m[j][i]end end return r end
    local getRotationMatrixZYX = function(ang)
        local sx,sy,sz, cx,cy,cz = math.sin(ang.x),math.sin(ang.y),math.sin(ang.z), math.cos(ang.x),math.cos(ang.y),math.cos(ang.z)
        return {
            {cy*cz,                 cy*sz,               -sy,       0},
            {-cx*sz + sx*sy*cz,     cx*cz + sx*sy*sz,    sx*cy,     0},
            {sx*sz + cx*sy*cz,      -sx*cz + cx*sy*sz,   cx*cy,     0},
            {0,                     0,                   0,         1}
        }
    end
    local translationMatrix = {{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}}
    local w, h, near, far, sizeX, sizeY, pxOffsetX, pxOffsetY = 288, 160, 0.25, 1000, 0.7 * 1.8, 0.7, 0, 0.01
    local n = near + 0.625
    local f = far
    local r = sizeX/2  + pxOffsetX
    local l = -sizeX/2 + pxOffsetX
    local t = sizeY/2  + pxOffsetY
    local b = -sizeY/2 + pxOffsetY
    local perspectiveProjectionMatrix = {
        {2*n/(r-l),         0,              0,              0},
        {0,                 2*n/(b-t),      0,              0},
        {-(r+l)/(r-l),      -(b+t)/(b-t),   f/(f-n),        1},
        {0,                 0,              -f*n/(f-n),     0}
    }

    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "9x5")

    simulator:setProperty("w", w)
    simulator:setProperty("h", h)
    simulator:setProperty("pxOffsetX", pxOffsetX)
    simulator:setProperty("pxOffsetY", pxOffsetY)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, true) -- screenConnection.isTouched)

        local cameraTranslation = {x = simulator:getSlider(1)*10, y = simulator:getSlider(2)*10, z = (simulator:getSlider(3)-0.5) * -50}
        local ang = {x = simulator:getSlider(4) * math.pi, y = simulator:getSlider(5) * math.pi, z = simulator:getSlider(6) * math.pi}
        translationMatrix[4][1], translationMatrix[4][2], translationMatrix[4][3] = -cameraTranslation.x, -cameraTranslation.y, -cameraTranslation.z

        local cameraTransformMatrix = MatrixMultiplication(perspectiveProjectionMatrix, MatrixMultiplication(MatrixTranspose(getRotationMatrixZYX(ang)), translationMatrix))

        for i = 1, 4 do
            for j = 1, 4 do
                simulator:setInputNumber((i-1)*4 + j, cameraTransformMatrix[i][j])
            end
        end
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]





--#region Render Function(s)
--#region Settings
local px_cx, px_cy = property.getNumber("w")/2, property.getNumber("h")/2
local px_cx_pos, px_cy_pos = px_cx + property.getNumber("pxOffsetX"), px_cy + property.getNumber("pxOffsetY")
--#endregion Settings

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
--#endregion Render Function(s)


local cameraTransform = {}
function onTick()
    isRendering = input.getBool(1)

    if isRendering then
        for i = 1, 16 do
            cameraTransform[i] = input.getNumber(i)
        end
    end
end


function onDraw()
    if isRendering then

    end
end


--#region VSCode onDraw() examples
----------------------------------------------------
-- It is only for VSCode due to the os.time() function, which is removed ingame of Stormworks Lua. It is at the start and end of onDraw() examples
-- There are two onDraw() examples. One for drawing points and another for triangles
-- To try example, set a spacing for '--[[code]]' to '-- [[code]]' and run in VSCode with F6
-- Sliders 1-3 moves the cameraTranslation and 4-6 for rotation
----------------------------------------------------

--[[ debug in VSCode for drawing points with WorldToScreen_points()
do
    local point_buffer = { x = {}, y = {}, z = {}, sx = {}, sy = {}, sz = {}, isVisible = {} }
    local rand = math.random
    for i = 1, 1E4 do -- init point cloud
        point_buffer.x[i] = (rand()-0.5)*50
        point_buffer.y[i] = (rand()-0.5)*50
        point_buffer.z[i] = (rand())*100

        -- init tables indices as array
        point_buffer.sx[i] = 0
        point_buffer.sy[i] = 0
        point_buffer.sz[i] = 0
        point_buffer.isVisible[i] = false
    end

    local n,f = 0.25+0.625, 1000
    local n_mul_f = n*f
    local n_sub_f = n-f
    local t1,t2,t3 = 0,0,0

    function onDraw()
        if isRendering then
            t1 = os.clock()
            WorldToScreen_points(cameraTransform, point_buffer)
            t2 = os.clock()

            local isVisible, sx, sy, sz = point_buffer.isVisible, point_buffer.sx, point_buffer.sy, point_buffer.sz
            local sColor, dCircleF, inView = screen.setColor, screen.drawCircleF, 0

            sColor(255, 255, 0, 200)
            for i = 1, #isVisible do
                if isVisible[i] then
                    inView = inView + 1

                    local d = n_mul_f/(f + sz[i]*n_sub_f) *2   -- zNear * zFar / (zFar + d * (zNear - zFar))
                    sColor(d, 255-d, 0, 200) -- setting color is quite expensive

                    dCircleF(sx[i], sy[i], 0.6)
                end
            end
            t3 = os.clock()

            screen.setColor(255,0,0)
            screen.drawText(0,00, "in view: "..inView)
            screen.drawText(0,10, string.format("Time Calc (sec): %.3f", t2-t1))
            screen.drawText(0,20, string.format("Time Draw (sec): %.3f", t3-t2))
        end
    end
end
--]]













--[[ debug in VSCode for drawing traingles with WorldToScreen_triangles()
do
    local MatMul3xVec3 = function(m, x,y,z)
        return
            m[1][1]*x + m[2][1]*y + m[3][1]*z,
            m[1][2]*x + m[2][2]*y + m[3][2]*z,
            m[1][3]*x + m[2][3]*y + m[3][3]*z
    end

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

    local MakeCube = function(vertex_buffer, triangle_buffer, translation, size)
        local vx, vy, vz, vsx, vsy, vsz, frame, inNearAndFar, isVisible = vertex_buffer.x, vertex_buffer.y, vertex_buffer.z, vertex_buffer.sx, vertex_buffer.sy, vertex_buffer.sz, vertex_buffer.frame, vertex_buffer.inNearAndFar, vertex_buffer.isVisible
        local vertex_buffer_size = #vx
        local triangle_buffer_size = #triangle_buffer

        for i = 1, 8 do
            local v_id = i + vertex_buffer_size

            -- init vertices world position
            vx[v_id] = unitCubePoints[i][1]*size + translation[1]
            vy[v_id] = unitCubePoints[i][2]*size + translation[2]
            vz[v_id] = unitCubePoints[i][3]*size + translation[3]

            -- init tables indices as array
            vsx[v_id] = 0
            vsy[v_id] = 0
            vsz[v_id] = 0
            frame[v_id] = 0
            inNearAndFar[v_id] = false
            isVisible[v_id] = false
        end

        -- Make triangle_buffer
        for i = 1, 12 do
            triangle_buffer[i + triangle_buffer_size] = {
                vertex_buffer_size + cubeTriangleOrder[i][2], -- Swap these 2 to change wounding order of CCW and CW
                vertex_buffer_size + cubeTriangleOrder[i][1], -- 
                vertex_buffer_size + cubeTriangleOrder[i][3],
                0,
                cubeColors[i][1],
                cubeColors[i][2],
                cubeColors[i][3]
            }
        end

        return triangle_buffer
    end

    local UpdateCubeVertices = function(vertex_buffer, vertices_startPointer, cubesTranslation, cubesRotationUpdate)
        local vx, vy, vz = vertex_buffer.x, vertex_buffer.y, vertex_buffer.z

        for i = 1, 8 do
            local vertex_id = vertices_startPointer + i
            local x,y,z = vx[vertex_id], vy[vertex_id], vz[vertex_id]                           -- read vertex data

            x, y, z = x - cubesTranslation[1], y - cubesTranslation[2], z - cubesTranslation[3] -- subtract translation
            x, y, z = MatMul3xVec3(cubesRotationUpdate, x, y, z)                                -- rotate cube/vertex in local space around origin
            x, y, z = x + cubesTranslation[1], y + cubesTranslation[2], z + cubesTranslation[3] -- add translation back

            vx[vertex_id], vy[vertex_id], vz[vertex_id] = x, y, z                               -- update vertex data
        end
    end

    --#region init_cubes
    local cubesAmount = 500
    local cubesTranslation = {}
    local cubesRotationUpdate = {}
    local vertex_buffer = { x = {}, y = {}, z = {}, sx = {}, sy = {}, sz = {}, frame = {}, inNearAndFar = {}, isVisible = {} }
    local triangle_list = {}

    local rand = math.random
    for i = 1, cubesAmount do
        cubesTranslation[i] = {(rand()-0.5)*150, (rand()-0.5)*150, rand()*150}

        local angX, angY, angZ = (rand()-0.5)*0.1, (rand()-0.5)*0.1, (rand()-0.5)*0.1
        local sx,sy,sz, cx,cy,cz = math.sin(angX),math.sin(angY),math.sin(angZ), math.cos(angX),math.cos(angY),math.cos(angZ)
        cubesRotationUpdate[i] = { -- http://www.songho.ca/opengl/gl_anglestoaxes.html
            {cy*cz,     sx*sy*cz+cx*sz,     -cx*sy*cz+sx*sz },
            {-cy*sz,    -sx*sy*sz+cx*cz,    cx*sy*sz+sx*cz  },
            {sy,        -sx*cy,             cx*cy           }
        }

        MakeCube(vertex_buffer, triangle_list, cubesTranslation[i], rand()*7+1)
    end
    --#endregion init_cubes

    local t1,t2,t3 = 0,0,0
    local frameCount = 0

    function onDraw()
        if isRendering then
            frameCount = frameCount + 1

            for i = 1, cubesAmount do -- Updating cube rotation
                local vertices_startPointer = (i-1) * 8
                UpdateCubeVertices(vertex_buffer, vertices_startPointer, cubesTranslation[i], cubesRotationUpdate[i])
            end

            t1 = os.clock()
            local triangle_buffer = WorldToScreen_triangles(cameraTransform, vertex_buffer, triangle_list, frameCount)
            t2 = os.clock()

            local sx, sy = vertex_buffer.sx, vertex_buffer.sy
            for i = 1, #triangle_buffer do
                local tri = triangle_buffer[i]
                local v1, v2, v3 = tri[1], tri[2], tri[3]

                if tri then
                    screen.setColor(tri[5], tri[6], tri[7], 200)
                    screen.drawTriangleF(sx[v1], sy[v1], sx[v2], sy[v2], sx[v3], sy[v3])
                end
            end
            t3 = os.clock()

            screen.setColor(255,255,255)
            screen.drawText(0,0, "Tri in view: "..#triangle_buffer)
        end

        screen.setColor(255, 255, 255)
        screen.drawText(0,10, string.format("Time Calc (sec): %.3f", t2-t1))
        screen.drawText(0,20, string.format("Time Draw (sec): %.3f", t3-t2))
    end
end
--]]
--#endregion VSCode onDraw() examples