-- Moving DevHotkeys to Dev folder
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")

print("[DevHotkeys] Setting up dev keys...")

-- Get remotes
local Networking = RS:WaitForChild("Networking", 30)
if not Networking then
    warn("[DevHotkeys] Failed to find Networking folder")
    return
end

local function getRemote(name)
    local remote = Networking:WaitForChild(name, 30)
    if not remote then
        warn("[DevHotkeys] Failed to find remote:", name)
        return
    end
    print("[DevHotkeys] Found remote:", name)
    return remote
end

local Dev_Grant = getRemote("Dev_Grant")
local Dev_Place = getRemote("Dev_Place")
local Dev_NPCBuy = getRemote("Dev_NPCBuy")
local Dev_Give = getRemote("DevGive")

if not (Dev_Grant and Dev_Place and Dev_NPCBuy) then
    warn("[DevHotkeys] Missing required remotes")
    return
end

print("[DevHotkeys] Registering dev keys:")
print("  G = grant crafting materials")
print("  P = place potion on display")
print("  B = trigger NPC buy")
print("  F6 = give test items")

UIS.InputBegan:Connect(function(io, gp)
    if gp then return end
    
    if io.KeyCode == Enum.KeyCode.G then
        Dev_Grant:FireServer()
        print("[DevHotkeys] Granting materials...")
    
    elseif io.KeyCode == Enum.KeyCode.P then
        print("[DevHotkeys] Placing item on display...")
        
        local DisplayCaseRequest = getRemote("DisplayCaseRequest")
        local InventorySnapshot = getRemote("InventorySnapshot")
        if not (DisplayCaseRequest and InventorySnapshot) then return end

        -- Find first available item in inventory
        local ok, invOrErr = pcall(function()
            return InventorySnapshot:InvokeServer()
        end)
        if not ok then
            warn("[DevHotkeys] InventorySnapshot failed:", invOrErr)
            return
        end

        local itemId
        for id, qty in pairs(invOrErr or {}) do
            local n = tonumber(qty) or (type(qty) == "table" and tonumber(qty.qty))
            if n and n > 0 then
                itemId = id
                break
            end
        end

        if not itemId then
            warn("[DevHotkeys] No items in inventory to place.")
            return
        end

        -- Tell the server to put this on display
        DisplayCaseRequest:FireServer("PutOnDisplay", itemId, 1, 10)
    
    elseif io.KeyCode == Enum.KeyCode.B then
        Dev_NPCBuy:FireServer(75)
        print("[DevHotkeys] Triggering NPC buy...")
    
    elseif io.KeyCode == Enum.KeyCode.F6 and Dev_Give then
        Dev_Give:FireServer("glowing_mushroom", 2)
        Dev_Give:FireServer("shadow_moss", 2)
        Dev_Give:FireServer("ember_shard", 1)
        Dev_Give:FireServer("beast_fat", 1)
        print("[DevHotkeys] Granted test items")
    end
end)

print("[DevHotkeys] Dev keys ready")