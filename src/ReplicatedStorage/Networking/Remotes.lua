local RS = game:GetService("ReplicatedStorage")
local Networking = RS:FindFirstChild("Networking") or Instance.new("Folder", RS)
Networking.Name = "Networking"

local NAMES = {
    "CashUpdated","DisplayCaseRequest","DisplayCaseUpdated",
    "InventorySnapshot","InventoryUpdated","RequestInventory",
}

local cache = {}
for _, name in ipairs(NAMES) do
    local ev = Networking:FindFirstChild(name) or Instance.new("RemoteEvent")
    ev.Name = name
    ev.Parent = Networking
    cache[name] = ev
end

local Remotes = {}
function Remotes.Get(name) return cache[name] end
setmetatable(Remotes, { __index = function(_, k) return cache[k] end })
print("[Remotes] Ready:", table.concat(NAMES, ", "))
return Remotes