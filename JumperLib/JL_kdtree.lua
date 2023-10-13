-- Author: Jumper
-- GitHub: https://github.com/Jumper-44



require('JumperLib.JL_list')
---kd-tree with focus on using integer ID for references rather than tables, but tables are still used in leaf nodes.  
---Full class minimized estimated to 1317 char  
---Requires 'JumperLib.list'  
---@section IKDTree 1 _IKDTREE_
---@param ... table -- expects ' {x,x,...,x},{y,y,...,y}, ..., {n,n,...,n} '
---@return IKDTree
IKDTree = function(...)
    local k_dimensions, len2, nodes, pointID, points, insertRecursive, removeRecursive, nearestPoints, maxNeighbors, insertSort, nearestNeighborsRecursive

    ---@class IKDTree
    ---@field len2 fun(pointA: integer, pointB: integer)
    ---@field IKDTree_insert fun(point: integer)
    ---@field IKDTree_remove fun(point: integer)
    ---@field IKDTree_nearestNeighbors fun(point: integer, maxReturnedNeighbors: integer): table
    ---@field pointsLen2 table
    local IKD_Tree, nSplit, nLeft, nRight, nPoints, newNodeBuffer, sortFunctions, pointsLen2 = {...}, {}, {}, {}, {}, {0, 0, 0, {}}, {}, {}

    k_dimensions = #IKD_Tree
    nodes = list({
        nSplit, -- split value
        nLeft, -- left node_id
        nRight, -- right node_id
        nPoints  -- pointID table or false, if table then it is a leaf node
    })
    nodes.insert(newNodeBuffer)

    ---Returns the squared length between two points
    ---@param pointA integer
    ---@param pointB integer
    ---@return number
    function len2(pointA, pointB)
        local sum = 0
        for i = 1, k_dimensions do
            local dis = IKD_Tree[i][pointA] - IKD_Tree[i][pointB]
            sum = sum + dis*dis
        end
        return sum
    end
    IKD_Tree.len2 = len2

    ---@section IKDTree_insert
    for cd = 1, k_dimensions do
        sortFunctions[cd] = function(a, b) return IKD_Tree[cd][a] < IKD_Tree[cd][b] end
    end

    function insertRecursive(nodeID, cd, depth)
        points = nPoints[nodeID]
        if points then -- is not false and therefore a table and leaf node
            points[#points+1] = pointID
            if #points == 16 then -- Split node when it contains 16 points
                table.sort(points, sortFunctions[cd])
                nSplit[nodeID] = 0.5 * (IKD_Tree[cd][points[8]] + IKD_Tree[cd][points[9]])

                --Remove points table reference from current node and reuse it in left node and init new table in right node and move the right half of points into right node
                nPoints[nodeID] = false
                newNodeBuffer[4] = points
                nLeft[nodeID] = nodes.insert(newNodeBuffer)
                newNodeBuffer[4] = {}
                nRight[nodeID] = nodes.insert(newNodeBuffer)
                for i = 9, 16 do
                    newNodeBuffer[4][i - 8] = points[i]
                    points[i] = nil
                end
            end
        else -- is internal node and therefore search further down the tree
            return insertRecursive(
                IKD_Tree[cd][pointID] < nSplit[nodeID] and nLeft[nodeID] or nRight[nodeID],
                depth % k_dimensions + 1,
                depth + 1
            )
        end
    end

    ---Inserts a point into the k-d tree
    ---@param point integer
    IKD_Tree.IKDTree_insert = function(point)
        pointID = point
        insertRecursive(1, 1, 1)
    end
    ---@endsection

    ---@section IKDTree_remove
    function removeRecursive(nodeID, cd, depth)
        points = nPoints[nodeID]
        if points then -- is not false and therefore a table and leaf node
            for i = 1, #points do
                if pointID == points[i] then
                    points[i] = points[#points]
                    points[#points] = nil
                end
            end
        else -- is internal node and therefore search further down the tree
            return removeRecursive(
            IKD_Tree[cd][pointID] < nSplit[nodeID] and nLeft[nodeID] or nRight[nodeID],
            depth % k_dimensions + 1,
            depth + 1
        )
        end
    end

    ---Finds leaf containing pointID and removes it from leaf.
    ---@param point table
    IKD_Tree.IKDTree_remove = function(point)
        pointID = point
        removeRecursive(1, 1, 1)
    end
    ---@endsection

    ---@section IKDTree_nearestNeighbors
    IKD_Tree.pointsLen2 = pointsLen2

    ---Insertion sort to local nearestPoints
    ---@param p table
    function insertSort(p)
        for i = 1, #nearestPoints do
            if pointsLen2[p] < pointsLen2[nearestPoints[i]] then
                table.insert(nearestPoints, i, p)
                return
            end
        end
        nearestPoints[#nearestPoints+1] = p
    end

    function nearestNeighborsRecursive(nodeID, depth)
        local cd, nextBranch, ortherBranch = depth % k_dimensions + 1, nRight[nodeID], nLeft[nodeID]

        points = nPoints[nodeID]
        if points then
            for i = 1, #points do
                pointsLen2[points[i]] = len2(pointID, points[i])
                if #nearestPoints < maxNeighbors then
                    insertSort(points[i])
                else
                    if pointsLen2[points[i]] < pointsLen2[nearestPoints[maxNeighbors]] then
                        nearestPoints[maxNeighbors] = nil
                        insertSort(points[i])
                    end
                end
            end
        else
            if IKD_Tree[cd][pointID] < nSplit[nodeID] then
                nextBranch, ortherBranch = ortherBranch, nextBranch
            end

            nearestNeighborsRecursive(nextBranch, depth+1)
            local dist = IKD_Tree[cd][pointID] - nSplit[nodeID]
            if #nearestPoints < maxNeighbors or pointsLen2[nearestPoints[maxNeighbors]] >= dist*dist then
                nearestNeighborsRecursive(ortherBranch, depth+1)
            end
        end
    end

    ---Returns the nearest point(s) in k-d tree to param point up to param maxNeighbors
    ---@param point integer
    ---@param maxReturnedNeighbors integer
    ---@return table
    IKD_Tree.IKDTree_nearestNeighbors = function(point, maxReturnedNeighbors)
        nearestPoints = {}
        pointID = point
        maxNeighbors = maxReturnedNeighbors
        nearestNeighborsRecursive(1, 0)
        return nearestPoints
    end
    ---@endsection

    return IKD_Tree
end
---@endsection _IKDTREE_



---kd-tree that does table references in nodes and for points
---Full class minimized estimated to 1013 char
---@section KDTree 1 _KDTree_
---@param k_dimensions integer
---@return KDTree
KDTree = function(k_dimensions)
    local IKD_Tree, len2, tree_root, pointID, insertRecursive, removeRecursive, nearestPoints, maxNeighbors, insertSort, nearestNeighborsRecursive

    ---@class KDTree
    ---@field len2 fun(pointA: table, pointB: table)
    ---@field KDTree_insert fun(point: table)
    ---@field KDTree_remove fun(point: table): table|nil
    ---@field KDTree_nearestNeighbors fun(point: table, maxReturnedNeighbors: integer): table
    IKD_Tree = {}
    tree_root = {leaf = true}

    ---Returns the squared length between two points
    ---@param pointA table
    ---@param pointB table
    ---@return number
    function len2(pointA, pointB)
        local sum = 0
        for i = 1, k_dimensions do
            local dis = pointA[i] - pointB[i]
            sum = sum + dis*dis
        end
        return sum
    end
    IKD_Tree.len2 = len2

    ---@section KDTree_insert
    function insertRecursive(root, cd, depth)
        if root.leaf then
            root[#root+1] = pointID
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
                pointID[cd] < root.split and root.left or root.right,
                depth % k_dimensions + 1,
                depth + 1
            )
        end
    end

    ---Inserts a point into the k-d tree
    ---@param point table
    IKD_Tree.KDTree_insert = function(point)
        pointID = point
        insertRecursive(tree_root, 1, 1)
    end
    ---@endsection

    ---@section KDTree_remove
    function removeRecursive(root, cd, depth)
        -- Could try to slightly balance tree if removing last or very few points in leaf
        if root.leaf then
            for i = 1, #root do
                if pointID == root[i] then
                    return table.remove(root, i)
                end
            end
            return
        else
            return removeRecursive(
            pointID[cd] < root.split and root.left or root.right,
            depth % k_dimensions + 1,
            depth + 1
        )
        end
    end

    ---Finds leaf containing point (assumed to be the same table and not contents/coordinates of point) and removes it from leaf.
    ---Returns found point or nil if not found.
    ---@param point table
    ---@return table|nil
    IKD_Tree.KDTree_remove = function(point)
        pointID = point
        return removeRecursive(tree_root, 1, 1)
    end
    ---@endsection

    ---@section KDTree_nearestNeighbors
    ---Insertion sort to local nearestPoints
    ---@param p table
    function insertSort(p)
        for i = 1, #nearestPoints do
            if p.len2 < nearestPoints[i].len2 then
                table.insert(nearestPoints, i, p)
                return
            end
        end
        nearestPoints[#nearestPoints+1] = p
    end

    function nearestNeighborsRecursive(root, depth)
        local cd, nextBranch, ortherBranch = depth % k_dimensions + 1, root.right, root.left

        if root.leaf then
            for i = 1, #root do
                root[i].len2 = len2(pointID, root[i])
                if #nearestPoints < maxNeighbors then
                    insertSort(root[i])
                else
                    if root[i].len2 < nearestPoints[maxNeighbors].len2 then
                        nearestPoints[maxNeighbors] = nil
                        insertSort(root[i])
                    end
                end
            end
        else
            if pointID[cd] < root.split then
                nextBranch, ortherBranch = root.left, root.right
            end

            nearestNeighborsRecursive(nextBranch, depth+1)
            local dist = pointID[cd] - root.split
            if #nearestPoints < maxNeighbors or nearestPoints[maxNeighbors].len2 >= dist*dist then
                nearestNeighborsRecursive(ortherBranch, depth+1)
            end
        end
    end

    ---Returns the nearest point(s) in k-d tree to param point up to param maxNeighbors
    ---Will set a value to root[i].len2 if node is traversed
    ---@param point table
    ---@param maxReturnedNeighbors integer
    ---@return table
    IKD_Tree.KDTree_nearestNeighbors = function(point, maxReturnedNeighbors)
        nearestPoints = {}
        pointID = point
        maxNeighbors = maxReturnedNeighbors
        nearestNeighborsRecursive(tree_root, 0)
        return nearestPoints
    end
    ---@endsection

    return IKD_Tree
end
---@endsection _KDTree_





---@section __IKDTree_DEBUG__
-- [[
do
    local s1, s2 = 1e6, 5e5
    local pointBuffer = {}
    local px,py,pz = {},{},{}
    local points = list({px,py,pz})
    local t = IKDTree(px,py,pz)
    local t1, t2
    local rand = math.random
    math.randomseed(123)

    for i = 1, s1 do
        pointBuffer[1] = (rand()-.5)*100
        pointBuffer[2] = (rand()-.5)*100
        pointBuffer[3] = (rand()-.5)*100
        points.insert(pointBuffer)
    end
    t1 = os.clock()
    for i = 1, s1 do
        t.IKDTree_insert(i)
    end
    print("IKDTree init: "..(os.clock()-t1))
    t1 = os.clock()
    for i = s2, s1 do
        t.IKDTree_remove(i)
    end
    print("IKDTree rem:  "..(os.clock()-t1))


    print("--- nearest neighbor ---")
    local time = {}
    for k = 1, 10 do -- IKDTree nearest neighbor
        local p = points.insert({(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100})

        t1 = os.clock()
        local tree_n = t.IKDTree_nearestNeighbors(p, 100)
        t2 = os.clock()

        local best, brute_n = 0x7fffffffffffffff, nil
        for i = 1, s2 do
            if t.len2(p, i) < best then
                best = t.len2(p, i)
                brute_n = i
            end
        end

        time[k] = t2-t1
        print("tree: "..t.len2(p, tree_n[1])..", brute: "..best..", is equal: "..tostring(tree_n[1]==brute_n)..", time: "..time[k])
    end

    local avg = 0
    for k = 1, #time do
        avg = avg + time[k]/#time
    end
    print("iterations: "..#time..", avg: "..avg)
end
--]]
---@endsection


---@section __KDTree_DEBUG__
--[[
do
    local points = {}
    local t = KDTree(3)
    local t1, t2
    local rand = math.random
    math.randomseed(123)

    for i = 1, 1e6 do
        points[i] = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}
    end
    t1 = os.clock()
    for i = 1, 1e6 do
        t.KDTree_insert(points[i])
    end
    print("KDTree init: "..(os.clock()-t1))
    t1 = os.clock()
    for i = 5e5, 1e6 do
        if not t.KDTree_remove(points[i]) then error("Failed to find and remove point in k-d tree") end
    end
    print("KDTree rem:  "..(os.clock()-t1))


    print("--- nearest neighbor ---")
    local time = {}
    for k = 1, 10 do -- KDTree nearest neighbor
        local p = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}

        t1 = os.clock()
        local tree_n = t.KDTree_nearestNeighbors(p, 100)
        t2 = os.clock()

        local best, brute_n = 0x7fffffffffffffff, nil
        for i = 1, #points do
            if t.len2(p, points[i]) < best then
                best = t.len2(p, points[i])
                brute_n = points[i]
            end
        end

        time[k] = t2-t1
        print("tree: "..t.len2(p, tree_n[1])..", brute: "..best..", is equal: "..tostring(tree_n[1]==brute_n)..", time: "..time[k])
    end

    local avg = 0
    for k = 1, #time do
        avg = avg + time[k]/#time
    end
    print("iterations: "..#time..", avg: "..avg)

--    do -- nearest neighbors
--        local p = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}
--
--        local brute_table = {}
--        for i = 1, #points do
--            brute_table[i] = points[i]
--            points[i].len2 = t.len2(p, points[i])
--        end
--        table.sort(brute_table, function(a, b) return a.len2 < b.len2 end)
--
--        print("--- KDTree nearest neighbors ---")
--        t1 = os.clock()
--        local tree_n = t.KDTree_nearestNeighbors(p, 200)
--        t2 = os.clock()
--        print("time: "..(t2-t1))
--        for i = 1, #tree_n do
--            print("tree: "..tree_n[i].len2..", brute: "..brute_table[i].len2..", is equal: "..tostring(tree_n[i] == brute_table[i]))
--        end
--    end
end
--]]
---@endsection