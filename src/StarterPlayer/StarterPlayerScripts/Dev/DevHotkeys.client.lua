local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local Networking = ReplicatedStorage:WaitForChild("Networking")
local remotes = {
    DisplayCaseRequest = Networking:WaitForChild("DisplayCaseRequest"),
    InventorySnapshot = Networking:WaitForChild("InventorySnapshot"),
    InventoryUpdated = Networking:WaitForChild("InventoryUpdated"),
    DevGive = Networking:WaitForChild("DevGive")
}

-- inventory cache
local inventory = {}

local function count(t) local n=0; for _ in pairs(t) do n+=1 end; return n end

InventorySnapshot.OnClientEvent:Connect(function(full)
    local out = {}
    if type(full) == "table" then
        if #full > 0 then
            -- array form: { {id=?, qty=?}, ... } or { { "id", qty }, ... }
            for _, row in ipairs(full) do
                local id  = (type(row)=="table") and (row.id or row.itemId or row.name or row[1]) or tostring(row)
                local qty = (type(row)=="table") and (row.qty or row.quantity or row.q or row[2]) or 1
                if id then out[tostring(id)] = tonumber(qty) or 0 end
            end
        else
            -- dict form: { [id] = qty }
            for k,v in pairs(full) do
                out[tostring(k)] = tonumber(v) or 0
            end
        end
    end
    inventory = out
    print(("[DevHotkeys] Snapshot items=%d"):format(count(inventory)))
end)

InventoryUpdated.OnClientEvent:Connect(function(a,b,c)
    -- Accept dict/array-of-pairs OR (id, delta, newQty) OR ({id=.., qty/newQty=..})
    if type(a) == "table" and not a.id and not a.itemId and not a.name then
        local changed = 0
        if #a > 0 then
            for _, row in ipairs(a) do
                local id  = row.id or row.itemId or row.name or row[1]
                local qty = row.newQty or row.qty or row.quantity or row[2]
                if id then
                    id = tostring(id); qty = tonumber(qty) or 0
                    inventory[id] = (qty > 0) and qty or nil
                    changed += 1
                end
            end
        else
            for k,v in pairs(a) do
                local id, qty = tostring(k), tonumber(v) or 0
                inventory[id] = (qty > 0) and qty or nil
                changed += 1
            end
        end
        print(("[DevHotkeys] InventoryUpdated(dict) changed=%d"):format(changed))
        return
    end

    local id = (type(a)=="table") and (a.id or a.itemId or a.name) or a
    local newQty = (type(a)=="table") and (a.newQty or a.qty or a.quantity) or c or b
    if not id then
        warn("[DevHotkeys] InventoryUpdated: missing id; payload types:", type(a), type(b), type(c))
        return
    end
    id = tostring(id); newQty = tonumber(newQty) or 0
    inventory[id] = (newQty > 0) and newQty or nil
    print(("[DevHotkeys] %s -> %d"):format(id, newQty))
end)

local function grant()
    print("[DevHotkeys] Granting materials...")
    remotes.DevGive:FireServer("ember_shard", 3)
    remotes.DevGive:FireServer("beast_fat", 3)
end

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
    remotes.DisplayCaseRequest:FireServer("PutOnDisplay", itemId, qty, price)
end

-- Hotkeys
print("[DevHotkeys] Registering dev keys:")
print("  G = grant crafting materials")
print("  P = place first owned item on display")
print("  B = trigger NPC buy")

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.G then
        grant()
    elseif input.KeyCode == Enum.KeyCode.P then
        placeOneOnDisplay()
    end
end)