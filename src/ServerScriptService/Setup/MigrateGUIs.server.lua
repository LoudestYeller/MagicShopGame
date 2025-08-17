local RS = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local REQUIRED = { "DisplayUI", "CraftingUI" }

local function ensureGui(name: string)
    -- If already present in ReplicatedStorage, done.
    local existing = RS:FindFirstChild(name)
    if existing then return existing end

    -- If artist placed it in StarterGui, move it to ReplicatedStorage (our convention).
    local fromStarter = StarterGui:FindFirstChild(name)
    if fromStarter then
        fromStarter.Parent = RS
        print(("[MigrateGUIs] Moved %s from StarterGui → ReplicatedStorage"):format(name))
        return fromStarter
    end

    -- Otherwise create a harmless placeholder so binders/UIBootstrap don't explode.
    local screen = Instance.new("ScreenGui")
    screen.Name = name
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true
    screen.Parent = RS

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(0.4, 0.08)
    lbl.Position = UDim2.fromScale(0.3, 0.05)
    lbl.BackgroundTransparency = 0.25
    lbl.TextScaled = true
    lbl.Text = name .. " (placeholder)"
    lbl.Parent = screen

    print(("[MigrateGUIs] Created placeholder %s in ReplicatedStorage"):format(name))
    return screen
end

for _, name in ipairs(REQUIRED) do
    ensureGui(name)
end