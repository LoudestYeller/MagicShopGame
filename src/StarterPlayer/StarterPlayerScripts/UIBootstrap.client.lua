-- UIBootstrap.client.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local function ensureUi(name: string, title: string, hint: string)
    local ui = ReplicatedStorage:FindFirstChild(name)
    if not ui or not ui:IsA("ScreenGui") then
        print(("[UIBootstrap] %s missing; creating simple fallback"):format(name))
        ui = Instance.new("ScreenGui")
        ui.Name = name
        ui.IgnoreGuiInset = true
        ui.ResetOnSpawn = false
        ui.Enabled = false

        local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.fromScale(0.5, 0.5)
        frame.Size = UDim2.fromOffset(560, 380)
        frame.BackgroundColor3 = Color3.fromRGB(26, 26, 31)
        frame.Parent = ui

        local header = Instance.new("TextLabel")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 36)
        header.BackgroundTransparency = 1
        header.Text = title
        header.TextColor3 = Color3.new(1, 1, 1)
        header.Font = Enum.Font.GothamBold
        header.TextScaled = true
        header.Parent = frame

        local close = Instance.new("TextButton")
        close.Name = "CloseButton"
        close.Text = "✕"
        close.AnchorPoint = Vector2.new(1, 0)
        close.Position = UDim2.new(1, -4, 0, -4)
        close.Size = UDim2.fromOffset(28, 28)
        close.BackgroundColor3 = Color3.fromRGB(51, 51, 64)
        close.TextColor3 = Color3.new(1, 1, 1)
        close.AutoButtonColor = true
        close.Parent = frame
        close.Activated:Connect(function() ui.Enabled = false end)

        local hintLbl = Instance.new("TextLabel")
        hintLbl.Name = "Hint"
        hintLbl.BackgroundTransparency = 1
        hintLbl.Position = UDim2.fromOffset(4, 44)
        hintLbl.Size = UDim2.new(1, -8, 1, -56)
        hintLbl.TextWrapped = true
        hintLbl.Text = hint
        hintLbl.TextColor3 = Color3.fromRGB(217, 217, 230)
        hintLbl.Parent = frame

        -- parent to RS so binder + other scripts find it in the usual spot
        ui.Parent = ReplicatedStorage
    end

    if not pg:FindFirstChild(name) then
        local clone = ui:Clone()
        clone.Parent = pg
        print(("[UIBootstrap] Mounted %s (Enabled=%s)"):format(name, tostring(clone.Enabled)))
    end
end

ensureUi("DisplayUI", "Display Case", "Press L to toggle • Items you place on display will appear here.")
ensureUi("CraftingUI", "Crafting", "Press C to toggle • Use a bench to access full crafting.")

print("🎮 [UIBootstrap] UI setup complete")