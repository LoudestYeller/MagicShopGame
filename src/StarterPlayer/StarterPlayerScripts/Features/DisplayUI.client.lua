--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local okTheme, Theme = pcall(function() return require(ReplicatedStorage.UI.Theme) end)
if not okTheme then warn("[DisplayUI] Theme missing") return end

local okTpl, DisplayTpl = pcall(function()
    return require(ReplicatedStorage.UI.Templates.MakeDisplayUI)
end)
if not okTpl then warn("[DisplayUI] Template missing") return end

local RenderSlots = require(ReplicatedStorage.UI.Render.RenderSlots)

-- Build / mount UI
local screen, refs = DisplayTpl.build(Theme)
screen.Enabled = false
screen.Parent = player:WaitForChild("PlayerGui")

-- State
local selectedSlotId: number? = nil

-- Update handling
local function onDisplayUpdate(userId: number, display: { slots: { [number]: any } })
    RenderSlots.render(Theme, refs.SlotsGrid, display.slots, {
        selectedId = selectedSlotId,
        onSelect = function(id, slot)
            selectedSlotId = id
            -- enable buttons when something is selected
            if refs.TakeButton then refs.TakeButton.AutoButtonColor = true end
        end,
    })
end

-- Connect to toggle events and handle updates
local displayUpdated = ReplicatedStorage.Networking.DisplayCaseUpdated
if displayUpdated then
    displayUpdated.OnClientEvent:Connect(function(userId, snapshot)
        if type(userId) ~= "number" or type(snapshot) ~= "table" then
            warn("[DisplayUI] Bad payload from DisplayCaseUpdated")
            return
        end
        onDisplayUpdate(userId, snapshot)
    end)
end

-- Example: take button
refs.TakeButton.Activated:Connect(function()
    if not selectedSlotId then return end
    -- e.g. Remotes.DisplayCaseRequest:FireServer("TakeFromDisplay", selectedSlotId, 1)
end)