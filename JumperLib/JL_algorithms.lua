-- Author: Jumper
-- GitHub: https://github.com/Jumper-44


---@section clamp
---Clamp the value x in the range [s;l]
---@param x number
---@param s number
---@param l number
---@return number
clamp = function(x,s,l)
    return x < s and s or x > l and l or x
end
---@endsection