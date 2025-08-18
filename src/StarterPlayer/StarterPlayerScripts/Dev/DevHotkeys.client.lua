-- StarterPlayer/StarterPlayerScripts/Dev/DevHotkeys.client.lua

local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local UserInputService   = game:GetService("UserInputService")  -- ✅ not nil
local player             = Players.LocalPlayer

-- Remotes live under ReplicatedStorage.Networking in your project
local Networking         = ReplicatedStorage:FindFirstChild("Networking") or ReplicatedStorage
local DisplayCaseRequest = Networking:WaitForChild("DisplayCaseRequest")
local InventorySnapshot  = Networking:WaitForChild("InventorySnapshot")
local InventoryUpdated   = Networking:WaitForChild("InventoryUpdated")
local DevGive            = Networking:FindFirstChild("DevGive")
local Dev_NPCBuy         = Networking:FindFirstChild("Dev_NPCBuy")

-- Helpers
local function nameOf(x)
    if typeof(x) == "Instance" then return x.Name end
    if type(x) == "table" then return "table" end
    return tostring(x)
end
local function printf(fmt, ...)
    -- avoid format errors from non-strings
    local args = {...}
    for i = 1, #args do args[i] = nameOf(args[i]) end
    print(string.format(fmt, table.unpack(args)))
end
local function countKeys(t) local n=0; for _ in pairs(t) do n+=1 end; return n end

-- Local inventory cache { [itemId] = qty }
local inventory = {}

-- Keep a copy of last crafted item id (if you later want a hotkey for it)
local lastCraftedId = nil

-- Listen for server-driven inventory state
InventorySnapshot.OnClientEvent:Connect(function(full)
    inventory = full or {}
    printf("[DevHotkeys] Snapshot received; items=%d", countKeys(inventory))
end)

InventoryUpdated.OnClientEvent:Connect(function(itemId, _delta, newQty)
    if newQty and newQty > 0 then
        inventory[itemId] = newQty
    else
        inventory[itemId] = nil
    end
    printf("[DevHotkeys] Updated %s -> %s", itemId, tostring(inventory[itemId]))
end)

-- Picking logic: first item you own
local function pickFirstOwnedItem()
    for itemId, qty in pairs(inventory) do
        if qty and qty > 0 then
            return itemId, 1
        end
    end
end

-- Actions
local function grantDevItems()
    if DevGive then
        printf("[DevHotkeys] Granting materials...")
        DevGive:FireServer()
    else
        warn("[DevHotkeys] DevGive remote missing")
    end
end

local function triggerNPCBuy()
    if Dev_NPCBuy then
        printf("[DevHotkeys] Triggering NPC buy...")
        Dev_NPCBuy:FireServer()
    else
        warn("[DevHotkeys] Dev_NPCBuy remote missing")
    end
end

local function placeOneOnDisplay()
    local itemId, qty = pickFirstOwnedItem()
    if not itemId then
        warn("[DevHotkeys] No items in inventory to place")
        return
    end
    local price = 10
    printf("[DevHotkeys] Placing %s x%d @%d", itemId, qty, price)
    DisplayCaseRequest:FireServer("PutOnDisplay", itemId, qty, price)
end

-- Hotkeys
printf("[DevHotkeys] Registering dev keys:")
print("  G = grant crafting materials")
print("  P = place first owned item on display")
print("  B = trigger NPC buy")
print("  F6 = give test items (alias of G)")

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.F6 then
        grantDevItems()
    elseif input.KeyCode == Enum.KeyCode.B then
        triggerNPCBuy()
    elseif input.KeyCode == Enum.KeyCode.P then
        placeOneOnDisplay()
    end
end)