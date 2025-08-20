-- StarterPlayerScripts/DisplayBinder.client.lua
-- Re-attaches a ProximityPrompt to the display counter and opens the Display UI.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")

local LOCAL = Players.LocalPlayer
local PG = LOCAL:WaitForChild("PlayerGui")

local function getGui()
    return PG:FindFirstChild("DisplayUI")
end

local function toggle()
    local g = getGui()
    if g then g.Enabled = not g.Enabled; print("[DisplayBinder] DisplayUI Enabled =", g.Enabled) end
end

local function setDisplayOpen(isOpen: boolean)
    local g = getGui()
    if g then g.Enabled = isOpen end
end

-- Attach a prompt to the counter part
local function attachPromptTo(modelOrPart: Instance)
    local part = modelOrPart:IsA("BasePart") and modelOrPart
        or (modelOrPart:FindFirstChild("PromptAttachment") or modelOrPart:FindFirstChildWhichIsA("BasePart"))
    if not part then return end

    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then
        prompt = Instance.new("ProximityPrompt")
        prompt.ActionText = "Open Display"
        prompt.ObjectText = "Counter"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 12
        prompt.Parent = part
    end

    -- LocalScript: Triggered has no player param; it's just you
    if not prompt:GetAttribute("Bound") then
        prompt.Triggered:Connect(function()
            toggle()
        end)
        prompt:SetAttribute("Bound", true)
    end
end

-- Find the counter the way your shop spawner places it
local function findCounter()
    local shops = Workspace:FindFirstChild("Shops")
    if not shops then return end

    -- support both names: DisplayCounter_Generic or anything containing "DisplayCounter"
    for _, shop in ipairs(shops:GetChildren()) do
        local counter = shop:FindFirstChild("DisplayCounter_Generic") or shop:FindFirstChildWhichIsA("Model")
        if counter then
            if counter.Name:lower():find("displaycounter") then
                -- Prefer an Attachment called PromptAttachment if present
                local attachment = counter:FindFirstChild("PromptAttachment")
                attachPromptTo(attachment or counter)
            end
        end
    end
end

-- Dev convenience: L toggles the display UI
UIS.InputBegan:Connect(function(io, gp)
    if io.KeyCode == Enum.KeyCode.L then toggle() end
end)

-- bootstrap
findCounter()
Workspace.ChildAdded:Connect(function(child)
    if child.Name == "Shops" then task.wait(0.1); findCounter() end
end)

print("📦 [DisplayBinder] Ready! Press L to toggle or use prompt")