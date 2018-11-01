-- Define the hyper key.
hyper = {"shift", "cmd", "alt", "ctrl"}

-- Define contains function for arrays.
function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

