local RS = game:GetService("ReplicatedStorage")
local Networking = RS:WaitForChild("Networking")

local NAMES = { "RequestCraft", "ToggleCrafting", "CraftingState", "CraftedToast" }

local cache = {}
for _, name in ipairs(NAMES) do
    local ev = Networking:FindFirstChild(name) or Instance.new("RemoteEvent")
    ev.Name = name
    ev.Parent = Networking
    cache[name] = ev
end

local CraftingRemotes = {}
function CraftingRemotes.Get(name) return cache[name] end
setmetatable(CraftingRemotes, { __index = function(_, k) return cache[k] end })
print("[CraftingRemotes] Ready:", table.concat(NAMES, ", "))
return CraftingRemotes