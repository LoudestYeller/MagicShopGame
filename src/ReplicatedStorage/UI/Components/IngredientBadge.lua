--!strict
local M = {}

export type Props = {
    icon: string?,   -- "rbxassetid://…" or content id
    name: string?,   -- optional tooltip-ish label
    qty: number?,    -- amount required
}

function M.create(theme: any, props: Props?): Frame
    local f = Instance.new("Frame")
    f.Name = "IngredientBadge"
    f.Size = UDim2.fromOffset(80, 80)
    f.BackgroundColor3 = theme.panel
    f.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = f

    local img = Instance.new("ImageLabel")
    img.Name = "Icon"
    img.BackgroundTransparency = 1
    img.Size = UDim2.fromScale(1, 1)
    img.Parent = f
    local ar = Instance.new("UIAspectRatioConstraint")
    ar.AspectRatio = 1
    ar.Parent = img
    if props and props.icon then img.Image = props.icon end

    local qty = Instance.new("TextLabel")
    qty.Name = "Qty"
    qty.AnchorPoint = Vector2.new(1, 1)
    qty.Position = UDim2.fromScale(1, 1)
    qty.Size = UDim2.fromOffset(28, 20)
    qty.BackgroundColor3 = theme.accent
    qty.BorderSizePixel = 0
    qty.TextColor3 = Color3.new(0,0,0)
    qty.Font = Enum.Font.GothamBold
    qty.TextSize = 14
    qty.Text = tostring(props and props.qty or 1)
    qty.Parent = f

    local qCorner = Instance.new("UICorner")
    qCorner.CornerRadius = UDim.new(0, 6)
    qCorner.Parent = qty

    if props and props.name then
        f.Name = props.name:gsub("%s+", "")
    end

    return f
end

return M