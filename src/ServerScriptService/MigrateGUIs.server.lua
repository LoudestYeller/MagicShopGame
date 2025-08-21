local RS = game:GetService("ReplicatedStorage")

-- Create base GUIs in ReplicatedStorage
local function createBaseGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.Enabled = false
    gui.ResetOnSpawn = false
    
    -- Add a Frame as a container
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.fromScale(0.6, 0.7)
    frame.Position = UDim2.fromScale(0.2, 0.15)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    -- Add a title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = name
    title.Size = UDim2.fromScale(1, 0.1)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Parent = frame
    
    gui.Parent = RS
    print(("✅ Created base %s in ReplicatedStorage"):format(name))
    return gui
end

-- Create the base GUIs
local displayGui = createBaseGui("DisplayUI")
local craftingGui = createBaseGui("CraftingUI")

print("🎮 GUI migration complete - your UI scripts can now find these in ReplicatedStorage")