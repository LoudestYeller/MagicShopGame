-- ReplicatedStorage/Modules/Remotes.lua
-- v1.1 — canonical remote accessor used by all client/server code
local RS = game:GetService("ReplicatedStorage")
local Folder = RS:WaitForChild("Networking")

local M = {}

function M.GetEvent(name: string)
    local r = Folder:WaitForChild(name)
    assert(r:IsA("RemoteEvent"), ("Remote '%s' is %s, expected RemoteEvent"):format(name, r.ClassName))
    return r
end

function M.GetFunction(name: string)
    local r = Folder:WaitForChild(name)
    assert(r:IsA("RemoteFunction"), ("Remote '%s' is %s, expected RemoteFunction"):format(name, r.ClassName))
    return r
end

return M