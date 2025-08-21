--!strict
local Button = require(script.Parent.Button)

local M = {}

export type Refs = {
    Icon: ImageLabel,
    Name: TextLabel,
    Info: TextLabel,
    CraftButton: TextButton,
    Root: Frame,
}

-- props are optional; controller can set later
export type Props = {
    name: string?,
    icon: string?, -- rbxassetid://… or content id
    info: string?, -- e.g. "Cost: 2 shrooms • 1 fat"
    canCraft: boolean?,
}

function M.create(theme: any, props: Props?): (Frame, Refs)
    local row = Instance.new("Frame")
    row.Name = "RecipeRow"
    row.Size = UDim2.new(1, -8, 0, 64)
    row.BackgroundColor3 = theme.panel
    row.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = row

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = row

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = row

    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.fromOffset(42, 42)
    icon.Parent = row

    local aspect = Instance.new("UIAspectRatioConstraint")
    aspect.AspectRatio = 1
    aspect.Parent = icon

    -- Text group
    local textGroup = Instance.new("Frame")
    textGroup.BackgroundTransparency = 1
    textGroup.Size = UDim2.new(1, -220, 1, 0)
    textGroup.Parent = row

    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.Padding = UDim.new(0, 2)
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Parent = textGroup

    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.BackgroundTransparency = 1
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Font = Enum.Font.GothamBold
    name.TextSize = 16
    name.TextColor3 = theme.text
    name.Size = UDim2.new(1, 0, 0, 20)
    name.Parent = textGroup

    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.BackgroundTransparency = 1
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Font = Enum.Font.Gotham
    info.TextSize = 14
    info.TextColor3 = theme.muted
    info.Size = UDim2.new(1, 0, 0, 18)
    info.Parent = textGroup

    -- Craft button
    local craftBtn = Button.create(theme, "Craft")
    craftBtn.AnchorPoint = Vector2.new(1, 0.5)
    craftBtn.Position = UDim2.new(1, -8, 0.5, 0)
    craftBtn.Parent = row

    -- apply initial props
    if props then
        if props.icon then icon.Image = props.icon end
        if props.name then name.Text = props.name end
        if props.info then info.Text = props.info end
        if props.canCraft ~= nil then
            craftBtn.AutoButtonColor = props.canCraft
            craftBtn.Active = props.canCraft
            craftBtn.BackgroundColor3 = props.canCraft and theme.accent or theme.muted
        end
    end

    local refs: Refs = {
        Root = row,
        Icon = icon,
        Name = name,
        Info = info,
        CraftButton = craftBtn,
    }
    return row, refs
end

return M