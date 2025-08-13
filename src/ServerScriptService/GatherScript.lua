-- Workspace.Forest.<Node>.GatherScript
local SSS = game:GetService("ServerScriptService")
local Inventory = require(SSS.Services.InventoryService)

local node = script.Parent
local ITEM_ID  = node:GetAttribute("ItemId") or "glowing_mushroom" -- ✅ ID, not display name
local QTY      = node:GetAttribute("Qty") or 1
local prompt   = node:FindFirstChildWhichIsA("ProximityPrompt") or node:FindFirstChildOfClass("ClickDetector")
local busy = false

local function disableNode(on)
    if prompt then
        if prompt:IsA("ProximityPrompt") then prompt.Enabled = not on else prompt.MaxActivationDistance = on and 0 or 20 end
    end
    node.Transparency = on and 1 or 0
end

local function grant(player)
    print(("🌿 %s gathered %s"):format(player.Name, ITEM_ID))
    Inventory.Add(player, ITEM_ID, QTY) -- ✅ correct param order + ID
end

local function trigger(player)
    if busy then return end
    busy = true
    grant(player)
    disableNode(true)
    task.delay(node:GetAttribute("Cooldown") or 10, function()
        disableNode(false)
        busy = false
    end)
end

if prompt then
    if prompt:IsA("ProximityPrompt") then
        prompt.Triggered:Connect(trigger) -- ProximityPrompt passes player directly
    else
        prompt.MouseClick:Connect(function(player) -- ClickDetector passes player as first param
            trigger(player)
        end)
    end
end