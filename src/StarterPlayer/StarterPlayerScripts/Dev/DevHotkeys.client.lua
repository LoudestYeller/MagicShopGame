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

local function safeName(x)
    if typeof(x) == "Instance" then return x.Name end
    if type(x) == "table" then return x.id or x.itemId or x.name or "table" end
    return tostring(x)
end

InventorySnapshot.OnClientEvent:Connect(function(full)
    -- server may send a dict or an array of {id, qty}; support both
    local out = {}
    if type(full) == "table" then
        local looksArray = (#full > 0)
        if looksArray then
            for _, row in ipairs(full) do
                local id = (type(row) == "table") and (row.id or row.itemId or row.name) or row
                local q  = (type(row) == "table") and (row.qty or row.quantity or row.q or row.amount) or 1
                if id then out[id] = tonumber(q) or 1 end
            end
        else
            -- assume { [id]=qty }
            for k,v in pairs(full) do
                out[tostring(k)] = tonumber(v) or 0
            end
        end
    end
    inventory = out
    print(("[DevHotkeys] Snapshot items=%d"):format((function(t)local n=0;for _ in pairs(t) do n+=1 end;return n end)(inventory)))
end)

InventoryUpdated.OnClientEvent:Connect(function(a, b, c)
    -- Accept either (itemId, delta, newQty) or ({id, qty}) or ({id, delta, newQty})
    local id, newQty

    if type(a) == "table" then
        id     = a.id or a.itemId or a.name
        newQty = a.newQty or a.qty or a.quantity or c  -- some servers send delta/newQty separate
    else
        id     = a
        newQty = c or b  -- accept either (id, delta, newQty) or (id, newQty)
    end

    id = id and tostring(id) or nil
    newQty = tonumber(newQty)

    if id then
        if newQty and newQty > 0 then
            inventory[id] = newQty
        else
            inventory[id] = nil
        end
        print(("[DevHotkeys] Inventory %s -> %s"):format(id, tostring(inventory[id])))
    else
        warn("[DevHotkeys] InventoryUpdated: missing id; payload types:", type(a), type(b), type(c))
    end
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