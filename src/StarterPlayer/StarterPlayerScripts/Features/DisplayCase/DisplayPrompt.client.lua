-- StarterPlayerScripts/Features/DisplayCase/DisplayPrompt.client.lua
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer

local function openDisplayUI()
    local pg = player:WaitForChild("PlayerGui")
    local gui = pg:FindFirstChild("DisplayUI") or pg:WaitForChild("DisplayUI", 3)
    if gui then
        gui.Enabled = true
    else
        warn("[DisplayPrompt] DisplayUI not found")
    end
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, triggerer)
    if triggerer ~= player then return end
    if prompt.Name ~= "OpenDisplayPrompt" then return end

    -- Optional future owner-gate:
    -- local ownerId = prompt:GetAttribute("OwnerUserId")
    -- if ownerId and ownerId ~= player.UserId then return end

    openDisplayUI()
end)