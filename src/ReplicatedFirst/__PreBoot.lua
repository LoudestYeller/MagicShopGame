--!strict
-- __PreBoot.lua - First script to run, sets up core modules
local RS = game:GetService("ReplicatedStorage")

print("[PreBoot] Setting up core folders...")

-- Create core folders
local Modules = RS:FindFirstChild("Modules") or Instance.new("Folder")
Modules.Name = "Modules"
Modules.Parent = RS

-- Create client modules
local function createClientRemotes()
    local ClientRemotes = Instance.new("ModuleScript")
    ClientRemotes.Name = "ClientRemotes"
    ClientRemotes.Source = [[
local RS = game:GetService("ReplicatedStorage")
local folder = RS:WaitForChild("Networking")
local cache = {}

local ClientRemotes = {}
function ClientRemotes.Get(name)
    cache[name] = cache[name] or folder:WaitForChild(name)
    return cache[name]
end

setmetatable(ClientRemotes, { __index = function(_, k) return ClientRemotes.Get(k) end })
return ClientRemotes
]]
    ClientRemotes.Parent = Modules
    print("[PreBoot] Created ClientRemotes module")
end

-- Initialize modules
createClientRemotes()

print("[PreBoot] Core setup complete")