-- Author: Jumper
-- GitHub: https://github.com/Jumper-44

--require('Jumper_lib.list')


---comment
---@section IKDTree 1 _IKDTREE_
---@param k_dimensions integer
---@return IKDTree
IKDTree = function(k_dimensions)
    local IKD_Tree, len2, tree_root, pointID, insertRecursive, removeRecursive, nearestPoints, maxNeighbors, insertSort, nearestNeighborsRecursive

    ---@class IKDTree
    ---@field len2 function
    ---@field IKDTree_insert function
    ---@field IKDTree_remove function
    ---@field IKDTree_nearestNeighbors function
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

    ---@section IKDTree_insert
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
    IKD_Tree.IKDTree_insert = function(point)
        pointID = point
        insertRecursive(tree_root, 1, 1)
    end
    ---@endsection

    ---@section IKDTree_remove
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
    IKD_Tree.IKDTree_remove = function(point)
        pointID = point
        return removeRecursive(tree_root, 1, 1)
    end
    ---@endsection

    ---@section IKDTree_nearestNeighbors
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
    IKD_Tree.IKDTree_nearestNeighbors = function(point, maxReturnedNeighbors)
        nearestPoints = {}
        pointID = point
        maxNeighbors = maxReturnedNeighbors
        nearestNeighborsRecursive(tree_root, 0)
        return nearestPoints
    end
    ---@endsection

    return IKD_Tree
end
---@endsection _IKDTREE_




---comment
---@section KDTree 1 _KDTREE_
---@param k_dimensions integer
---@return table
KDTree = function(k_dimensions)
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

        ---@section KDTree_insert
        ---Inserts a point into the k-d tree
        ---@param point table
        KDTree_insert = function(point)
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
        ---@endsection

        ---@section KDTree_remove
        ---Finds leaf containing point (assumed to be the same table and not contents/coordinates of point) and removes it from leaf.
        ---Returns found point or nil if not found.
        ---@param point table
        ---@return table|nil
        KDTree_remove = function(point)
            local function removeRecursive(root, cd, depth)
                -- Could try to slightly balance tree if removing last or very few points in leaf
                if root.leaf then
                    for i = 1, #root do
                        if point == root[i] then
                            return table.remove(root, i)
                        end
                    end
                    return
                else
                    return removeRecursive(
                    point[cd] < root.split and root.left or root.right,
                    depth % k_dimensions + 1,
                    depth + 1
                )
                end
            end

            return removeRecursive(tree_root, 1, 1)
        end;
        ---@endsection

        ---@section KDTree_nearestNeighbors
        ---Returns the nearest point(s) in k-d tree to param point up to param maxNeighbors
        ---Will set a value to root[i].len2 if node is traversed
        ---@param point table
        ---@param maxNeighbors integer
        ---@return table
        KDTree_nearestNeighbors = function(point, maxNeighbors)
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
        ---@endsection
    }
end
---@endsection _KDTREE_





---@section __IKDTree_DEBUG__
-- [[
do
    local points = {}
    local t = IKDTree(3)
    local t1, t2
    local rand = math.random
    math.randomseed(123)

    t1 = os.clock()
    for i = 1, 1e6 do
        points[i] = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}
        t.IKDTree_insert(points[i])
    end
    print("IKDTree init: "..(os.clock()-t1))
    t1 = os.clock()
    for i = 5e5, 1e6 do
        if not t.IKDTree_remove(points[i]) then error("Failed to find and remove point in k-d tree") end
        points[i] = nil
    end
    print("IKDTree rem:  "..(os.clock()-t1))


    print("--- nearest neighbor ---")
    local time = {}
    for k = 1, 10 do -- IKDTree nearest neighbor
        local p = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}

        t1 = os.clock()
        local tree_n = t.IKDTree_nearestNeighbors(p, 100)
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

    do -- nearest neighbors
        local p = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}

        local brute_table = {}
        for i = 1, #points do
            brute_table[i] = points[i]
            points[i].len2 = t.len2(p, points[i])
        end
        table.sort(brute_table, function(a, b) return a.len2 < b.len2 end)

        print("--- IKDTree nearest neighbors ---")
        t1 = os.clock()
        local tree_n = t.IKDTree_nearestNeighbors(p, 200)
        t2 = os.clock()
        print("time: "..(t2-t1))
--        for i = 1, #tree_n do
--            print("tree: "..tree_n[i].len2..", brute: "..brute_table[i].len2..", is equal: "..tostring(tree_n[i] == brute_table[i]))
--        end
    end
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

    t1 = os.clock()
    for i = 1, 1e6 do
        points[i] = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}
        t.KDTree_insert(points[i])
    end
    print("KDTree init: "..(os.clock()-t1))
    t1 = os.clock()
    for i = 5e5, 1e6 do
        if not t.KDTree_remove(points[i]) then error("Failed to find and remove point in k-d tree") end
        points[i] = nil
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

    do -- nearest neighbors
        local p = {(rand()-.5)*100, (rand()-.5)*100, (rand()-.5)*100}

        local brute_table = {}
        for i = 1, #points do
            brute_table[i] = points[i]
            points[i].len2 = t.len2(p, points[i])
        end
        table.sort(brute_table, function(a, b) return a.len2 < b.len2 end)

        print("--- KDTree nearest neighbors ---")
        t1 = os.clock()
        local tree_n = t.KDTree_nearestNeighbors(p, 200)
        t2 = os.clock()
        print("time: "..(t2-t1))
--        for i = 1, #tree_n do
--            print("tree: "..tree_n[i].len2..", brute: "..brute_table[i].len2..", is equal: "..tostring(tree_n[i] == brute_table[i]))
--        end
    end
end
--]]
---@endsection