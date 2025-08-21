-- StarterPlayerScripts/CraftingBinder.client.lua
-- Adds prompts to crafting benches to open the crafting UI.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

local LOCAL = Players.LocalPlayer
local PG = LOCAL:WaitForChild("PlayerGui")

local function getGui()
    return PG:FindFirstChild("CraftingUI")
end

local function toggle()
    local g = getGui()
    if g then g.Enabled = not g.Enabled; print("[CraftingBinder] CraftingUI Enabled =", g.Enabled) end
end

local function attachPromptTo(bench: Instance)
    local part = bench:FindFirstChild("PromptAttachment") or bench:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Open Crafting"
        prompt.ObjectText = bench.Name
        prompt.KeyboardKeyCode = Enum.KeyCode.F
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 12
        prompt.Parent = part
    end
    if not prompt:GetAttribute("Bound") then
        prompt.Triggered:Connect(function()
            toggle()
        end)
        prompt:SetAttribute("Bound", true)
    end
end

local function findBenches()
    local shops = Workspace:FindFirstChild("Shops")
    if not shops then return end
    for _, shop in ipairs(shops:GetChildren()) do
        for _, v in ipairs(shop:GetChildren()) do
            if v.Name:lower():find("craftingbench") then
                attachPromptTo(v)
            end
        end
    end
end

-- Dev convenience: C toggles crafting (Studio)
UIS.InputBegan:Connect(function(io, gp)
    if io.KeyCode == Enum.KeyCode.C then toggle() end
end)

findBenches()
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Shops" then task.wait(0.1); findBenches() end
end)

print("🔨 [CraftingBinder] Ready! Press C to toggle or use prompt")