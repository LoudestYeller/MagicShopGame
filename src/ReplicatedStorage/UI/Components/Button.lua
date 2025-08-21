--!strict
local M = {}

function M.create(theme: any, label: string): TextButton
    local btn = Instance.new("TextButton")
    btn.Name = "Button"
    btn.Size = UDim2.fromOffset(120, 36)
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = theme.accent
    btn.Text = label
    btn.TextColor3 = Color3.new(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = theme.muted
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = theme.accent:Lerp(Color3.new(1,1,1), 0.08)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = theme.accent
    end)

    return btn
end

return M