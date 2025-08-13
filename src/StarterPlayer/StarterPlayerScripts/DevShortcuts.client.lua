-- Studio-only quick give: press F6 to get common test items
local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local Networking = RS:WaitForChild("Networking")
local DevGive = Networking:WaitForChild("DevGive")

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        DevGive:FireServer("glowing_mushroom", 2)
        DevGive:FireServer("shadow_moss", 2)
        DevGive:FireServer("ember_shard", 1)
        DevGive:FireServer("beast_fat", 1)
        warn("[DevShortcuts] Granted test items")
    end
end)