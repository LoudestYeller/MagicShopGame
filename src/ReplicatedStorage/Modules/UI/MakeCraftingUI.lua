-- Builds a proper CraftingUI ScreenGui with recipe list, details, and a craft button.
-- Returns the ScreenGui (not parented).
local function mk(name, class)
    local inst = Instance.new(class)
    inst.Name = name
    return inst
end

return function()
    local gui = mk("CraftingUI", "ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 6

    local main = mk("MainFrame", "Frame")
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.fromOffset(720, 460)
    main.BackgroundColor3 = Color3.fromRGB(26, 28, 34)
    main.BorderSizePixel = 0
    main.Parent = gui

    local corner = Instance.new("UICorner", main)
    corner.CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Color = Color3.fromRGB(70, 75, 90)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local header = mk("Header", "TextLabel")
    header.Size = UDim2.new(1, -48, 0, 36)
    header.Position = UDim2.fromOffset(16, 12)
    header.BackgroundTransparency = 1
    header.Font = Enum.Font.GothamBold
    header.Text = "Crafting"
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

    -- Left column: recipe list
    local list = mk("RecipeList", "ScrollingFrame")
    list.Size = UDim2.new(0, 260, 1, -70)
    list.Position = UDim2.fromOffset(12, 54)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ScrollBarThickness = 6
    list.Active = true
    list.BackgroundColor3 = Color3.fromRGB(32, 34, 42)
    list.BorderSizePixel = 0
    list.Parent = main
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 10)
    local listPad = Instance.new("UIPadding", list)
    listPad.PaddingTop = UDim.new(0, 6); listPad.PaddingLeft = UDim.new(0, 6)
    local listLayout = Instance.new("UIListLayout", list)
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Right column: details
    local details = mk("Details", "Frame")
    details.Size = UDim2.new(1, -296, 1, -70)
    details.Position = UDim2.fromOffset(284, 54)
    details.BackgroundColor3 = Color3.fromRGB(32, 34, 42)
    details.BorderSizePixel = 0
    details.Parent = main
    Instance.new("UICorner", details).CornerRadius = UDim.new(0, 10)
    local pad = Instance.new("UIPadding", details)
    pad.PaddingTop = UDim.new(0, 12); pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12); pad.PaddingBottom = UDim.new(0, 12)

    local nameLabel = mk("ItemName", "TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 28)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = "Select a recipe"
    nameLabel.TextSize = 20
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextColor3 = Color3.fromRGB(235, 240, 255)
    nameLabel.Parent = details

    local ingredients = mk("IngredientsList", "Frame")
    ingredients.Size = UDim2.new(1, 0, 1, -80)
    ingredients.Position = UDim2.fromOffset(0, 34)
    ingredients.BackgroundTransparency = 1
    ingredients.Parent = details
    local ingLayout = Instance.new("UIListLayout", ingredients)
    ingLayout.Padding = UDim.new(0, 6)
    ingLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local craft = mk("CraftButton", "TextButton")
    craft.AnchorPoint = Vector2.new(1, 1)
    craft.Position = UDim2.new(1, 0, 1, 0)
    craft.Size = UDim2.fromOffset(140, 40)
    craft.Text = "Craft"
    craft.Font = Enum.Font.GothamMedium
    craft.TextSize = 18
    craft.BackgroundColor3 = Color3.fromRGB(68, 176, 110)
    craft.TextColor3 = Color3.fromRGB(15, 20, 18)
    craft.AutoButtonColor = true
    craft.Parent = details
    Instance.new("UICorner", craft).CornerRadius = UDim.new(0, 10)

    return gui
end