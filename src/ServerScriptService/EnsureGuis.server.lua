-- src/ServerScriptService/EnsureGuis.server.lua
local RS = game:GetService("ReplicatedStorage")

local REQUIRED = { "DisplayUI", "CraftingUI" }

local function ensureGui(name: string)
    -- Already a proper ScreenGui?
    local existing = RS:FindFirstChild(name)
    if existing and existing:IsA("ScreenGui") then
        return existing
    end
    -- If something else with that name exists, replace it.
    if existing then
        existing:Destroy()
    end

    -- Create a minimal placeholder so UIBootstrap/Binders never fail.
    local screen = Instance.new("ScreenGui")
    screen.Name = name
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.Parent = RS

    local lbl = Instance.new("TextLabel")
    lbl.AnchorPoint = Vector2.new(0.5, 0)
    lbl.Position = UDim2.new(0.5, 0, 0, 10)
    lbl.Size = UDim2.new(0, 520, 0, 42)
    lbl.BackgroundTransparency = 0.25
    lbl.TextScaled = true
    lbl.Text = name .. " (placeholder)"
    lbl.Parent = screen

    print(("[EnsureGuis] Created placeholder %s in ReplicatedStorage"):format(name))
    return screen
end

for _, n in ipairs(REQUIRED) do
    ensureGui(n)
end