local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networking = ReplicatedStorage:FindFirstChild("Networking") or Instance.new("Folder")
Networking.Name = "Networking"
Networking.Parent = ReplicatedStorage

local Remotes = Networking:FindFirstChild("Remotes") or Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = Networking

local function ensureRemoteEvent(name)
    local ev = Remotes:FindFirstChild(name)
    if not ev then
        ev = Instance.new("RemoteEvent")
        ev.Name = name
        ev.Parent = Remotes
    end
    return ev
end

-- Create all RemoteEvents here:
ensureRemoteEvent("CashUpdated")
ensureRemoteEvent("DisplayCaseRequest")
ensureRemoteEvent("DisplayCaseUpdated")
ensureRemoteEvent("InventorySnapshot")
ensureRemoteEvent("InventoryUpdated")
ensureRemoteEvent("RequestInventory")
ensureRemoteEvent("RequestCraft")
ensureRemoteEvent("ToggleCrafting")
ensureRemoteEvent("CraftingState")
ensureRemoteEvent("CraftedToast")
ensureRemoteEvent("ToggleDisplayCase")
ensureRemoteEvent("DevGive")  -- Dev shortcuts

print("[RemotesService] All remotes created")
return Remotes