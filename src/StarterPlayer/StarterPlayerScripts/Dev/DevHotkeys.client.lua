-- Moving DevHotkeys to Dev folder
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Networking = ReplicatedStorage:FindFirstChild("Networking") or ReplicatedStorage
local DisplayCaseRequest = Networking:WaitForChild("DisplayCaseRequest")
local InventorySnapshot = Networking:WaitForChild("InventorySnapshot")
local InventoryUpdated = Networking:WaitForChild("InventoryUpdated")

local function countKeys(t) local n=0; for _ in pairs(t) do n+=1 end; return n end

local inventory = {}

InventorySnapshot.OnClientEvent:Connect(function(full)
    inventory = full or {}
    print(("[DevHotkeys] Snapshot received; items=%d"):format(countKeys(inventory)))
end)

InventoryUpdated.OnClientEvent:Connect(function(itemId, _delta, newQty)
    if newQty and newQty > 0 then
        inventory[itemId] = newQty
    else
        inventory[itemId] = nil
    end
    print(("[DevHotkeys] Updated %s -> %s"):format(itemId, tostring(inventory[itemId])))
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
    print(("[DevHotkeys] Placing %s x%d @%d"):format(itemId, qty, price))
    DisplayCaseRequest:FireServer("PutOnDisplay", itemId, qty, price)
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