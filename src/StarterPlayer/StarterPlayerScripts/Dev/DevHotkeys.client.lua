local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local function getRemote(name, kind) -- kind = "Event" | "Function"
    local Networking = ReplicatedStorage:WaitForChild("Networking")
    local obj = Networking:WaitForChild(name)
    if kind == "Event" then
        assert(obj:IsA("RemoteEvent"), string.format("[DevHotkeys] Remote '%s' expected RemoteEvent but is %s", name, obj.ClassName))
    elseif kind == "Function" then
        assert(obj:IsA("RemoteFunction"), string.format("[DevHotkeys] Remote '%s' expected RemoteFunction but is %s", name, obj.ClassName))
    else
        error(("Unknown remote kind '%s'"):format(tostring(kind)))
    end
    return obj
end

-- ✨ Use it for every remote you wire up:
local InventorySnapshot = getRemote("InventorySnapshot", "Function")
local InventoryUpdated  = getRemote("InventoryUpdated",  "Event")
local DisplayCaseRequest = getRemote("DisplayCaseRequest", "Function")
local DevGive           = getRemote("DevGive", "Event")

-- inventory cache
local inventory = {}

local function count(t) local n=0; for _ in pairs(t) do n+=1 end; return n end

-- Function to fetch current inventory
local function fetchInventory()
    local ok, full = pcall(function()
        return InventorySnapshot:InvokeServer()
    end)
    if not ok then
        warn("[DevHotkeys] Failed to fetch inventory:", full)
        return
    end
    
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
end

-- Fetch initial inventory
task.defer(fetchInventory)

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
    DevGive:FireServer("ember_shard", 3)
    DevGive:FireServer("beast_fat", 3)
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
    -- Example snapshot usage:
    local snapshot = DisplayCaseRequest:InvokeServer()
    -- (Use snapshot as needed in your hotkeys/tests)
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