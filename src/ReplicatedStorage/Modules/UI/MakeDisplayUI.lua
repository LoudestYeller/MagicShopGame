-- Builds a proper DisplayUI ScreenGui with a header, close button, and a slots grid.
-- Returns the ScreenGui (not parented).
local function mk(name, class)
    local inst = Instance.new(class)
    inst.Name = name
    return inst
end

return function()
    local gui = mk("DisplayUI", "ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 5

    local main = mk("MainFrame", "Frame")
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.fromOffset(620, 420)
    main.BackgroundColor3 = Color3.fromRGB(26, 28, 34)
    main.BorderSizePixel = 0
    main.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Color = Color3.fromRGB(70, 75, 90)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = main

    local header = mk("Header", "TextLabel")
    header.Size = UDim2.new(1, -48, 0, 36)
    header.Position = UDim2.fromOffset(16, 12)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = "Display Case"
    header.TextSize = 22
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextColor3 = Color3.fromRGB(235, 240, 255)
    header.Parent = main

    local close = mk("CloseButton", "TextButton")
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(1, -12, 0, 10)
    close.Size = UDim2.fromOffset(32, 28)
    close.Text = "✕"
    close.Font = Enum.Font.Gotham
    close.TextSize = 18
    close.BackgroundColor3 = Color3.fromRGB(46, 50, 60)
    close.TextColor3 = Color3.fromRGB(230, 230, 235)
    close.AutoButtonColor = true
    close.Parent = main
    local closeCorner = Instance.new("UICorner", close)
    closeCorner.CornerRadius = UDim.new(0, 6)

    -- Slots grid
    local slotsFrame = mk("Slots", "ScrollingFrame")
    slotsFrame.Size = UDim2.new(1, -24, 1, -70)
    slotsFrame.Position = UDim2.fromOffset(12, 54)
    slotsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    slotsFrame.ScrollBarThickness = 6
    slotsFrame.Active = true
    slotsFrame.BackgroundTransparency = 1
    slotsFrame.Parent = main

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.fromOffset(140, 120)
    grid.CellPadding = UDim2.fromOffset(10, 10)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.FillDirectionMaxCells = 4
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Left
    grid.Parent = slotsFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingTop = UDim.new(0, 4)
    pad.Parent = slotsFrame

    return gui
end