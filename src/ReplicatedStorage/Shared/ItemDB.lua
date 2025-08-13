-- Temporary shim so old code that requires ItemDB keeps working.
-- Internally, we standardize on Shared/Items.lua.
local RS = game:GetService("ReplicatedStorage")
local Items = require(RS.Shared.Items)

local ItemDB = setmetatable({}, {
    __index = function(_, k) return Items[k] end
})

function ItemDB.Get(id)
    return Items[id]
end

function ItemDB.GetName(id)
    local it = Items[id]
    return it and it.name or id
end

function ItemDB.Exists(id)
    return Items[id] ~= nil
end

return ItemDB