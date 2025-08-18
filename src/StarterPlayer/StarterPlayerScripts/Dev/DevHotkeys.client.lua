-- Moving DevHotkeys to Dev folder
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Networking = ReplicatedStorage:WaitForChild("Networking")
local Remotes = {
    DisplayCaseRequest = Networking:WaitForChild("DisplayCaseRequest"),
    InventorySnapshot  = Networking:WaitForChild("InventorySnapshot"),
    InventoryUpdated   = Networking:WaitForChild("InventoryUpdated"),
    Dev_Grant = Networking:WaitForChild("Dev_Grant"),
    Dev_NPCBuy = Networking:WaitForChild("Dev_NPCBuy"),
    Dev_Give = Networking:WaitForChild("DevGive")
}

-- keep a local copy of the player's inventory
local inventory = {}

Remotes.InventorySnapshot.OnClientEvent:Connect(function(full)
    -- full is a map like {["Glowing Mushroom"]=1, ...}
    inventory = full or {}
end)

Remotes.InventoryUpdated.OnClientEvent:Connect(function(itemId, _delta, newQty)
    inventory[itemId] = newQty
    if newQty == 0 then inventory[itemId] = nil end
end)

local function pickFirstOwnedItem()
    for itemId, qty in pairs(inventory) do
        if qty and qty > 0 then
            return itemId, 1
        end
    end
end

local function placeOneOnDisplay()
    local itemId, qty = pickFirstOwnedItem()
    if not itemId then
        warn("[DevHotkeys] No items in inventory to place")
        return
    end
    local price = 10
    print(("[DevHotkeys] Placing %s x%d for %d"):format(itemId, qty, price))
    Remotes.DisplayCaseRequest:FireServer("PutOnDisplay", itemId, qty, price)
end

print("[DevHotkeys] Registering dev keys:")
print("  G = grant crafting materials")
print("  P = place potion on display")
print("  B = trigger NPC buy")
print("  F6 = give test items")

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.G then
        Remotes.Dev_Grant:FireServer()
        print("[DevHotkeys] Granting materials...")
    
    elseif input.KeyCode == Enum.KeyCode.P then
        placeOneOnDisplay()
    
    elseif input.KeyCode == Enum.KeyCode.B then
        Remotes.Dev_NPCBuy:FireServer(75)
        print("[DevHotkeys] Triggering NPC buy...")
    
    elseif input.KeyCode == Enum.KeyCode.F6 and Remotes.Dev_Give then
        Remotes.Dev_Give:FireServer("glowing_mushroom", 2)
        Remotes.Dev_Give:FireServer("shadow_moss", 2)
        Remotes.Dev_Give:FireServer("ember_shard", 1)
        Remotes.Dev_Give:FireServer("beast_fat", 1)
        print("[DevHotkeys] Granted test items")
    end
end)

print("[DevHotkeys] Dev keys ready")