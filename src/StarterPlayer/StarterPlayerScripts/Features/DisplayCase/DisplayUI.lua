-- StarterPlayer/.../DisplayUI.lua
-- Renders a simple list of items with Viewport icons. Opens via DisplayBinder toggle.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local ItemRegistry = require(ReplicatedStorage.Shared.Data.ItemRegistry)
local ViewportIcon = require(ReplicatedStorage.Shared.UI.ViewportIcon)
local player = Players.LocalPlayer

local DisplayUpdated = Remotes.GetEvent("DisplayCaseUpdated")
local DisplayRequest = Remotes.GetFunction("DisplayCaseRequest")

-- Build UI  
local playerGui = player:WaitForChild("PlayerGui")
local screen = Instance.new("ScreenGui")
screen.Name = "DisplayUI"
screen.ResetOnSpawn = false
screen.Enabled = false
screen.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.36, 0.46)
frame.Position = UDim2.fromScale(0.32, 0.27)
frame.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
frame.BorderSizePixel = 0
frame.Parent = screen

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = frame

local list = Instance.new("Frame")
list.BackgroundTransparency = 1
list.Size = UDim2.fromScale(1, 1)
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = list

-- Row template
local function makeRow()
    local row = Instance.new("Frame")
    row.Name = "Row"
    row.Size = UDim2.new(1, -20, 0, 64)
    row.BackgroundColor3 = Color3.fromRGB(32, 36, 42)
    row.BorderSizePixel = 0

    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = row

    local icon = Instance.new("ViewportFrame")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(64,64)
    icon.Position = UDim2.fromOffset(8, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.CurrentCamera = nil
    icon.Parent = row

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Position = UDim2.fromOffset(84, 8)
    nameLabel.Size = UDim2.new(1, -180, 0, 24)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = "Item"
    nameLabel.TextColor3 = Color3.fromRGB(235, 240, 255)
    nameLabel.TextSize = 18
    nameLabel.Parent = row

    local qty = Instance.new("TextLabel")
    qty.Name = "Qty"
    qty.Position = UDim2.new(1, -76, 0, 8)
    qty.Size = UDim2.fromOffset(64, 24)
    qty.AnchorPoint = Vector2.new(1, 0)
    qty.BackgroundTransparency = 1
    qty.Font = Enum.Font.Gotham
    qty.TextXAlignment = Enum.TextXAlignment.Right
    qty.Text = "x1"
    qty.TextColor3 = Color3.fromRGB(200, 210, 230)
    qty.TextSize = 16
    qty.Parent = row

    return row
end

local pool = {} -- simple row pool

local function getRow()
    local row = table.remove(pool)
    if row then row.Parent = list; row.Visible = true; return row end
    return makeRow()
end

local function releaseAll()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") and child.Name == "Row" then
            child.Visible = false
            child.Parent = nil
            table.insert(pool, child)
        end
    end
end

local function prettyName(id)
    local meta = ItemRegistry[id]
    return (meta and meta.name) or id
end

local function modelNameFor(id)
    local meta = ItemRegistry[id]
    return (meta and meta.model) or id
end

local function renderCase(state)
    releaseAll()
    -- state is a dictionary: { ["itemId"] = count, ... }
    for itemId, count in pairs(state or {}) do
        if count > 0 then
            local row = getRow()
            row.Parent = list

            row.Name.Text = prettyName(itemId)
            row.Qty.Text = "x"..tostring(count)

            ViewportIcon.Populate(row.Icon, modelNameFor(itemId))
        end
    end
end

-- Public API for binder
local M = {}

-- When UI opens, fetch a fresh snapshot
local function onUIShown()
    local snapshot = DisplayRequest:InvokeServer()
    renderCase(snapshot)
end

function M.Open()
    screen.Enabled = true
    onUIShown()
end

function M.Close()
    screen.Enabled = false
end

-- Live updates from the server (only apply if they are for this player)
DisplayUpdated.OnClientEvent:Connect(function(userId, newState)
    if userId == player.UserId and screen.Enabled then
        renderCase(newState)
    end
end)

return M