-- Define the hyper key.
hyper = {"shift", "cmd", "alt", "ctrl", "fn", "numpad"}

-- Define contains function for arrays.
function contains (arr, val)
    for index, value in ipairs (arr) do
        if value == val then
            return true
        end
    end
    return false
end
