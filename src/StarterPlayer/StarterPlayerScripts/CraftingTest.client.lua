--!strict
-- Test crafting remote integration
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Wait for remotes to be available
local CraftingRemotes
pcall(function()
    CraftingRemotes = require(ReplicatedStorage.Networking.CraftingRemotes)
end)

if not CraftingRemotes then
    warn("[CraftingTest] CraftingRemotes not available")
    return
end

-- Listen for successful crafting
local CraftedToast = CraftingRemotes.Get("CraftedToast")
if CraftedToast then
    CraftedToast.OnClientEvent:Connect(function(itemId)
        print("🎉 [CraftingTest] Successfully crafted:", itemId)
        -- Could show UI toast here
    end)
end

-- Test crafting with T key (simple test)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.T then
        -- Test crafting: ember_shard + beast_fat = potion_warmth (PotionBench)
        local testInputs = {
            {id = "ember_shard", qty = 1},
            {id = "beast_fat", qty = 1}
        }
        
        print("🧪 [CraftingTest] Attempting to craft potion_warmth...")
        CraftingRemotes.Get("RequestCraft"):FireServer("PotionBench", testInputs, 1)
    end
end)

print("🧪 [CraftingTest] Loaded! Press T to test crafting (needs ember_shard + beast_fat)")