--!strict
local Instance_new = Instance.new

local function makeSlotCard(theme)
    local card = Instance_new("Frame")
    card.Name = "SlotCard"
    card.BackgroundColor3 = theme.panel
    card.Size = UDim2.fromOffset(140, 160)
    card.BorderSizePixel = 0
    Instance_new("UICorner", card).CornerRadius = UDim.new(0, 10)

    -- Icon
    local icon = Instance_new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.fromOffset(80, 80)
    icon.Position = UDim2.new(0.5, 0, 0, 10)
    icon.AnchorPoint = Vector2.new(0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Parent = card

    -- Name
    local name = Instance_new("TextLabel")
    name.Name = "Name"
    name.Text = "Empty"
    name.Font = Enum.Font.Gotham
    name.TextSize = 14
    name.TextColor3 = theme.text
    name.BackgroundTransparency = 1
    name.Size = UDim2.new(1, -16, 0, 18)
    name.Position = UDim2.new(0, 8, 0, 96)
    name.Parent = card

    -- Qty / Price row (simple)
    local price = Instance_new("TextLabel")
    price.Name = "Price"
    price.Text = "$0"
    price.Font = Enum.Font.GothamBold
    price.TextSize = 14
    price.TextColor3 = theme.accent
    price.BackgroundTransparency = 1
    price.Size = UDim2.new(1, -16, 0, 18)
    price.Position = UDim2.new(0, 8, 0, 122)
    price.Parent = card

    return card
end

local M = {}

function M.build(theme)
    local screen = Instance_new("ScreenGui")
    screen.Name = "DisplayUI"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 10

    local root = Instance_new("Frame")
    root.Name = "Root"
    root.Size = UDim2.new(0.6, 0, 0.6, 0)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.BackgroundColor3 = theme.bg
    root.BorderSizePixel = 0
    root.Parent = screen
    Instance_new("UICorner", root).CornerRadius = UDim.new(0, 12)
    Instance_new("UIPadding", root).PaddingTop = UDim.new(0, 16)
    root:FindFirstChildOfClass("UIPadding").PaddingLeft = UDim.new(0, 16)
    root:FindFirstChildOfClass("UIPadding").PaddingRight = UDim.new(0, 16)
    root:FindFirstChildOfClass("UIPadding").PaddingBottom = UDim.new(0, 16)

    -- Title
    local title = Instance_new("TextLabel")
    title.Name = "Title"
    title.Text = "Display Case"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = theme.text
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -32, 0, 24)
    title.Parent = root

    -- Grid
    local grid = Instance_new("Frame")
    grid.Name = "Grid"
    grid.BackgroundTransparency = 1
    grid.Size = UDim2.new(1, 0, 1, -48)
    grid.Position = UDim2.new(0, 0, 0, 32)
    grid.Parent = root

    local layout = Instance_new("UIGridLayout")
    layout.CellSize = UDim2.fromOffset(140, 160)
    layout.CellPadding = UDim2.fromOffset(8, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = grid

    -- Pre-create 6 cards (controller can reuse/replace as needed)
    for i = 1, 6 do
        makeSlotCard(theme).Parent = grid
    end

    local refs = {
        Root = root,
        Grid = grid,
        Title = title,
    }
    return screen, refs
end

return M