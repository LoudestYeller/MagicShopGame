-- ReplicatedStorage/Modules/ClientRemotes.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local networking = ReplicatedStorage:WaitForChild("Networking", 10)
if not networking then
    error("[ClientRemotes] ReplicatedStorage.Networking folder not found (timeout).")
end

local Remotes = {}

function Remotes.get(name: string)
    local obj = networking:FindFirstChild(name)
    if obj then
        return obj
    end
    return networking:WaitForChild(name, 5)
end

setmetatable(Remotes, {
    __index = function(_, key)
        local obj = networking:FindFirstChild(key)
        if obj then
            return obj
        end
        return networking:WaitForChild(key, 5)
    end,
})

return Remotes