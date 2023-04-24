-- Normal LUA, no SW
-- Encoding data into string with base64, 6 chars per number
-- Run with F5

--#region base64 encode/decode
local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function float_to_base64(num)
    num = string.unpack("I", string.pack("f", num))
    local result = ""
    for i = 1, 6 do
        local index = ((num >> ((6 - i) * 6)) & 0x3F) + 1
        result = result .. string.sub(b64, index, index)
        num = num & ~(0x3F << ((6 - i) * 6))
    end
    return result
end

local function encode_base64(file, matrix, str_name)
    local maxTextPropertyChars = 128
    local floatToStrCharAmount = 6
    local row_len = #matrix[1]
    local columnPerPropertyText = maxTextPropertyChars // (floatToStrCharAmount * row_len)
    local totalPropertyTexts = math.ceil(#matrix/columnPerPropertyText)

    for i = 1, totalPropertyTexts do
        file:write(str_name..i.." ")
        for j = 1, columnPerPropertyText do
            if (i-1)*columnPerPropertyText+j <= #matrix then
                for k = 1, row_len do
                    file:write(float_to_base64(matrix[(i-1)*columnPerPropertyText+j][k]))
                end
            else
                break
            end
        end
        file:write("\n")
    end
end

--[[ Functions to use ingame of SW to read property data and decode
local b64 = property.getText("b64")

local function base64_to_float(str)
    local result = 0
    for i = 1, 6 do
        result = result | (b64:find(str:sub(i, i)) - 1 << ((6 - i) * 6))
    end
    return (string.unpack("f", string.pack("I",result)))
end

local decode_base64 = function(name_str, row_len)
    local matrix, property_iter, column, row = {}, 0, 1, 1
    repeat
        property_iter = property_iter + 1
        local str = property.getText(name_str..property_iter)
        for s in str:gmatch("......") do
            matrix[column] = matrix[column] or {}
            matrix[column][row] = base64_to_float(s)
            row = row + 1
            if row > row_len then
                column, row = column + 1, 1
            end
        end
    until str == ""

    return matrix
end
--]]
--#endregion base64 encode/decode



-- Example matrix data to encode
local unitCube = {
    {-0.5, -0.5, -0.5},
    { 0.5, -0.5, -0.5},
    { 0.5,  0.5, -0.5},
    {-0.5,  0.5, -0.5},
    {-0.5, -0.5,  0.5},
    { 0.5, -0.5,  0.5},
    { 0.5,  0.5,  0.5},
    {-0.5,  0.5,  0.5}
}



local file_dir_str = "Template/output.txt"
local file = io.open(file_dir_str, "w+")
if file then
    print("Opened file")

    encode_base64(file, unitCube, "v")
    file:write("\n")

    file:close()
else
    print("Didn't open file")
end