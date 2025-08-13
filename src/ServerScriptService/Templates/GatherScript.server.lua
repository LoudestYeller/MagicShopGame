local SSS = game:GetService("ServerScriptService")
local Inventory = require(SSS.Services.InventoryService)

local node = script.Parent
local ITEM_ID  = node:GetAttribute("ItemId") or "glowing_mushroom"
local QTY      = node:GetAttribute("Qty") or 1
local COOLDOWN = node:GetAttribute("Cooldown") or 10
local prompt   = node:FindFirstChildWhichIsA("ProximityPrompt") or node:FindFirstChildOfClass("ClickDetector")
local busy = false

local function setEnabled(on)
    if prompt then
        if prompt:IsA("ProximityPrompt") then prompt.Enabled = on else prompt.MaxActivationDistance = on and 20 or 0 end
    end
    node.Transparency = on and 0 or 1
end

local function grant(player: Player)
    print(("🌿 %s gathered %s"):format(player.Name, ITEM_ID))
    Inventory.Add(player, ITEM_ID, QTY)
end

local function trigger(player: Player)
    if busy then return end
    busy = true; grant(player); setEnabled(false)
    task.delay(COOLDOWN, function() setEnabled(true); busy=false end)
end

if prompt then
    if prompt:IsA("ProximityPrompt") then prompt.Triggered:Connect(trigger) else prompt.MouseClick:Connect(trigger) end
end