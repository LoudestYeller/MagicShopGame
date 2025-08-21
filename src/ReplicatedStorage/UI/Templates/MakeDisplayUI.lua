--!strict
-- Build a consistent Display UI using Theme + Button components
local Button = require(script.Parent.Parent.Components.Button)

local M = {}

export type DisplayRefs = {
    ScreenGui: ScreenGui,
    Root: Frame,
    CloseButton: TextButton,

    -- main content
    SlotsGrid: ScrollingFrame,
    SlotsLayout: UIGridLayout,
    EmptyLabel: TextLabel,

    -- optional actions
    PutButton: TextButton,
    TakeButton: TextButton,
}

local function header(theme: any, parent: Instance): (TextLabel, TextButton)
    local bar = Instance.new("Frame")
    bar.Name = "TitleBar"
    bar.BackgroundTransparency = 1
    bar.Size = UDim2.new(1, 0, 0, 28)
    bar.Parent = parent

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Text = "Display Case"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = theme.text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(1, -36, 1, 0)
    title.Parent = bar

    local close = Button.create(theme, "X")
    close.Size = UDim2.fromOffset(32, 28)
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.new(1, 0, 0.5, 0)
    close.Parent = bar

    return title, close
end

function M.build(theme: any): (ScreenGui, DisplayRefs)
    local screen = Instance.new("ScreenGui")
    screen.Name = "DisplayUI"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 10

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.Size = UDim2.new(0.6, 0, 0.55, 0)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.BackgroundColor3 = theme.bg
    root.BorderSizePixel = 0
    root.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = root

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 16)
    pad.PaddingBottom = UDim.new(0, 16)
    pad.PaddingLeft = UDim.new(0, 16)
    pad.PaddingRight = UDim.new(0, 16)
    pad.Parent = root

    local _, closeBtn = header(theme, root)

    -- Body (grid + action bar)
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, 0, 1, -36)
    body.Position = UDim2.new(0, 0, 0, 32)
    body.Parent = root

    local list = Instance.new("ScrollingFrame")
    list.Name = "SlotsGrid"
    list.Active = true
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.ScrollBarThickness = 6
    list.BackgroundColor3 = theme.panel
    list.BorderSizePixel = 0
    list.Size = UDim2.new(1, 0, 1, -52)
    list.Parent = body
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = list

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 8)
    listPad.PaddingLeft = UDim.new(0, 8)
    listPad.PaddingRight = UDim.new(0, 8)
    listPad.PaddingBottom = UDim.new(0, 8)
    listPad.Parent = list

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.fromOffset(140, 100)
    grid.CellPadding = UDim2.fromOffset(8, 8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = list

    local empty = Instance.new("TextLabel")
    empty.Name = "EmptyLabel"
    empty.BackgroundTransparency = 1
    empty.Text = "No items on display yet."
    empty.Font = Enum.Font.Gotham
    empty.TextSize = 16
    empty.TextColor3 = theme.muted
    empty.Size = UDim2.new(1, -20, 0, 24)
    empty.Position = UDim2.new(0, 10, 0, 10)
    empty.TextXAlignment = Enum.TextXAlignment.Left
    empty.Parent = list

    -- Action bar
    local bar = Instance.new("Frame")
    bar.Name = "ActionBar"
    bar.BackgroundTransparency = 1
    bar.Size = UDim2.new(1, 0, 0, 44)
    bar.Position = UDim2.new(0, 0, 1, -44)
    bar.Parent = body

    local barLayout = Instance.new("UIListLayout")
    barLayout.FillDirection = Enum.FillDirection.Horizontal
    barLayout.Padding = UDim.new(0, 8)
    barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    barLayout.Parent = bar

    local putBtn = Button.create(theme, "Put Item")
    putBtn.Size = UDim2.fromOffset(120, 36)
    putBtn.Parent = bar

    local takeBtn = Button.create(theme, "Take Selected")
    takeBtn.Size = UDim2.fromOffset(140, 36)
    takeBtn.Parent = bar

    local refs: DisplayRefs = {
        ScreenGui = screen,
        Root = root,
        CloseButton = closeBtn,
        SlotsGrid = list,
        SlotsLayout = grid,
        EmptyLabel = empty,
        PutButton = putBtn,
        TakeButton = takeBtn,
    }
    return screen, refs
end

return M