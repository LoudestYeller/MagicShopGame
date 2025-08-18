--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local okTheme, Theme = pcall(function() return require(ReplicatedStorage.UI.Theme) end)
if not okTheme then warn("[DisplayUI] Theme missing") return end

local okTpl, DisplayTpl = pcall(function()
    return require(ReplicatedStorage.UI.Templates.MakeDisplayUI)
end)
if not okTpl then warn("[DisplayUI] Template missing") return end

local screen, refs = DisplayTpl.build(Theme)
screen.Enabled = false
screen.Parent = player:WaitForChild("PlayerGui")

local function renderSlots(slots: { [number]: any })
    -- clear old (keep layout + EmptyLabel)
    for _, c in ipairs(refs.SlotsGrid:GetChildren()) do
        if not c:IsA("UIGridLayout") and c.Name ~= "EmptyLabel" then c:Destroy() end
    end

    local count = 0
    for slotId, slot in pairs(slots) do
        count += 1
        local card = Instance.new("Frame")
        card.Name = ("Slot_%s"):format(slotId)
        card.Size = UDim2.fromOffset(140, 100)
        card.BackgroundColor3 = Theme.panel
        card.BorderSizePixel = 0

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = card

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Text = tostring(slot.itemId) .. " x" .. tostring(slot.qty)
        name.Font = Enum.Font.Gotham
        name.TextSize = 14
        name.TextColor3 = Theme.text
        name.Size = UDim2.new(1, -10, 0, 20)
        name.Position = UDim2.new(0, 5, 0, 5)
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = card

        card.Parent = refs.SlotsGrid
    end

    refs.EmptyLabel.Visible = (count == 0)
end

-- Connect to toggle events and handle updates
local displayUpdated = ReplicatedStorage.Networking.DisplayCaseUpdated
if displayUpdated then
    displayUpdated.OnClientEvent:Connect(function(userId, snapshot)
        if type(userId) ~= "number" or type(snapshot) ~= "table" then
            warn("[DisplayUI] Bad payload from DisplayCaseUpdated")
            return
        end
        renderSlots(snapshot.slots or {})
    end)
end