-- Author: Jumper
-- GitHub: https://github.com/Jumper-44

---@section list
---Table/list in which removed entries are marked for removal and overwritten by new inserted values.
---@param elements table -- expects: {{}, {}, ..., {}}
---@param removed_id nil -- dirty local to reduce char
---@param id nil -- dirty local to reduce char
---@return table
function list(elements, removed_id, id)
    removed_id = {}

    ---@param new_elements table
    ---@return integer -- returns the given id to new_elements
    elements.insert = function(new_elements)
        id = #removed_id > 0 and table.remove(removed_id) or #elements[1]+1
        for i = 1, #elements do
            elements[i][id] = new_elements[i]
        end
        return id
    end

    ---Assumes removed index is in range
    ---@param index integer
    elements.remove = function(index)
        removed_id[#removed_id+1] = index
    end
    return elements
end
---@endsection


--[[ debug
do
    local arr = list({{},{},{}})
    local buffer = {}

    local t1, t2, t3, t4

    t1 = os.clock()
    for i = 1, 1e6 do
        buffer[1] = i
        buffer[2] = i % 3
        buffer[3] = i % 2 == 0

        arr.insert(buffer)
    end
    t2 = os.clock()
    for i = 1, 1e6 do
        arr.remove(i)
    end
    t3 = os.clock()
    for i = 1, 1e6 do
        buffer[1] = i
        buffer[2] = i % 5
        buffer[3] = i % 3 == 0

        arr.insert(buffer)
    end
    t4 = os.clock()

    print(t2-t1)
    print(t3-t2)
    print(t4-t3)
end
--]]