-- Moving CraftingTest to Dev folder
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Core modules
local Remotes = require(ReplicatedStorage.Modules.Remotes)

local function init()
    print("[CraftingTest] Loading remotes...")
    print("[CraftingTest] Ready")
end

task.spawn(init)

-- Dev hotkeys
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T and Remotes then
        local result = Remotes.GetFunction("RequestCraft"):InvokeServer({
            station = "potion",
            ingredients = {
                {itemId = "ember_shard", qty = 1},
                {itemId = "beast_fat", qty = 1}
            }
        })
        print("[CraftingTest] Result:", result)
    end
end)

print("🧪 [CraftingTest] Loaded! Press T to test crafting (needs ember_shard + beast_fat)")