local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Networking.Remotes)

local required = {
    "RequestInventory","InventorySnapshot","InventoryUpdated",
    "DisplayCaseRequest","DisplayCaseUpdated","CashUpdated",
}

for _, name in ipairs(required) do
    local r = Remotes.Get(name)
    if not (r and r:IsA("RemoteEvent")) then
        warn(("[Preflight] RemoteEvent missing or wrong type: %s"):format(name))
    end
end

print("[Preflight] Remotes OK")