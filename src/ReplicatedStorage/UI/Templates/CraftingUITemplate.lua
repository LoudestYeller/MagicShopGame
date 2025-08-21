--!strict
local RecipeRow = require(script.Parent.Parent.Components.RecipeRow)
local Button = require(script.Parent.Parent.Components.Button)

local M = {}

export type CraftingRefs = {
    Root: Frame,
    CloseButton: TextButton,
    RecipesList: ScrollingFrame,
    RecipesLayout: UIListLayout,
    DetailsPanel: Frame,
    DetailName: TextLabel,
    DetailIcon: ImageLabel,
    IngredientsGrid: Frame,
    IngredientsLayout: UIGridLayout,
    QtyMinus: TextButton,
    QtyPlus: TextButton,
    QtyLabel: TextLabel,
    CraftButton: TextButton,
    ScreenGui: ScreenGui,
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
    title.Text = "Crafting"
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

function M.build(theme: any): (ScreenGui, CraftingRefs)
    local screen = Instance.new("ScreenGui")
    screen.Name = "CraftingUI"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = 11

    local root = Instance.new("Frame")
    root.Name = "Root"
    root.Size = UDim2.new(0.7, 0, 0.65, 0)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.BackgroundColor3 = theme.bg
    root.BorderSizePixel = 0
    root.Parent = screen

    local rootCorner = Instance.new("UICorner")
    rootCorner.CornerRadius = UDim.new(0, 12)
    rootCorner.Parent = root

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 16)
    pad.PaddingBottom = UDim.new(0, 16)
    pad.PaddingLeft = UDim.new(0, 16)
    pad.PaddingRight = UDim.new(0, 16)
    pad.Parent = root

    local title, closeBtn = header(theme, root)
    title.Position = UDim2.new(0, 0, 0, 0)

    -- Two-column body
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Size = UDim2.new(1, 0, 1, -36)
    body.Position = UDim2.new(0, 0, 0, 32)
    body.Parent = root

    local columns = Instance.new("UIListLayout")
    columns.FillDirection = Enum.FillDirection.Horizontal
    columns.Padding = UDim.new(0, 12)
    columns.Parent = body

    -- Left: Recipes List
    local left = Instance.new("Frame")
    left.Name = "Left"
    left.BackgroundTransparency = 1
    left.Size = UDim2.new(0.42, 0, 1, 0)
    left.Parent = body

    local list = Instance.new("ScrollingFrame")
    list.Name = "RecipesList"
    list.Active = true
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.ScrollBarThickness = 6
    list.BackgroundColor3 = theme.panel
    list.BorderSizePixel = 0
    list.Size = UDim2.new(1, 0, 1, 0)
    list.Parent = left
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = list

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 8)
    listPad.PaddingLeft = UDim.new(0, 8)
    listPad.PaddingRight = UDim.new(0, 8)
    listPad.PaddingBottom = UDim.new(0, 8)
    listPad.Parent = list

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    -- Right: Details
    local right = Instance.new("Frame")
    right.Name = "Right"
    right.BackgroundColor3 = theme.panel
    right.BorderSizePixel = 0
    right.Size = UDim2.new(0.58, 0, 1, 0)
    right.Parent = body

    local rightCorner = Instance.new("UICorner")
    rightCorner.CornerRadius = UDim.new(0, 10)
    rightCorner.Parent = right

    local rightPad = Instance.new("UIPadding")
    rightPad.PaddingTop = UDim.new(0, 12)
    rightPad.PaddingLeft = UDim.new(0, 12)
    rightPad.PaddingRight = UDim.new(0, 12)
    rightPad.PaddingBottom = UDim.new(0, 12)
    rightPad.Parent = right

    local detailName = Instance.new("TextLabel")
    detailName.Name = "DetailName"
    detailName.BackgroundTransparency = 1
    detailName.Text = "Select a recipe"
    detailName.Font = Enum.Font.GothamBold
    detailName.TextSize = 20
    detailName.TextColor3 = theme.text
    detailName.TextXAlignment = Enum.TextXAlignment.Left
    detailName.Size = UDim2.new(1, 0, 0, 24)
    detailName.Parent = right

    local detailIcon = Instance.new("ImageLabel")
    detailIcon.Name = "DetailIcon"
    detailIcon.BackgroundTransparency = 1
    detailIcon.Size = UDim2.fromOffset(96, 96)
    detailIcon.Position = UDim2.new(0, 0, 0, 34)
    detailIcon.Parent = right
    local iconAspect = Instance.new("UIAspectRatioConstraint")
    iconAspect.AspectRatio = 1
    iconAspect.Parent = detailIcon

    local ingredientsLabel = Instance.new("TextLabel")
    ingredientsLabel.BackgroundTransparency = 1
    ingredientsLabel.Text = "Ingredients"
    ingredientsLabel.Font = Enum.Font.GothamBold
    ingredientsLabel.TextSize = 16
    ingredientsLabel.TextColor3 = theme.text
    ingredientsLabel.TextXAlignment = Enum.TextXAlignment.Left
    ingredientsLabel.Position = UDim2.new(0, 0, 0, 142)
    ingredientsLabel.Size = UDim2.new(1, 0, 0, 20)
    ingredientsLabel.Parent = right

    local ingredients = Instance.new("Frame")
    ingredients.Name = "IngredientsGrid"
    ingredients.BackgroundTransparency = 1
    ingredients.Position = UDim2.new(0, 0, 0, 168)
    ingredients.Size = UDim2.new(1, 0, 0, 120)
    ingredients.Parent = right

    local ingredientsLayout = Instance.new("UIGridLayout")
    ingredientsLayout.CellSize = UDim2.fromOffset(80, 80)
    ingredientsLayout.CellPadding = UDim2.fromOffset(8, 8)
    ingredientsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ingredientsLayout.Parent = ingredients

    -- Quantity & Craft
    local bar = Instance.new("Frame")
    bar.Name = "ActionBar"
    bar.BackgroundTransparency = 1
    bar.Size = UDim2.new(1, 0, 0, 44)
    bar.Position = UDim2.new(0, 0, 1, -48)
    bar.Parent = right

    local barLayout = Instance.new("UIListLayout")
    barLayout.FillDirection = Enum.FillDirection.Horizontal
    barLayout.Padding = UDim.new(0, 8)
    barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    barLayout.Parent = bar

    local minus = Button.create(theme, "-")
    minus.Size = UDim2.fromOffset(36, 36)
    minus.Parent = bar

    local qty = Instance.new("TextLabel")
    qty.Name = "QtyLabel"
    qty.BackgroundTransparency = 1
    qty.Text = "1"
    qty.Font = Enum.Font.GothamBold
    qty.TextSize = 18
    qty.TextColor3 = theme.text
    qty.Size = UDim2.fromOffset(40, 36)
    qty.Parent = bar

    local plus = Button.create(theme, "+")
    plus.Size = UDim2.fromOffset(36, 36)
    plus.Parent = bar

    local craft = Button.create(theme, "Craft")
    craft.Size = UDim2.fromOffset(140, 36)
    craft.AnchorPoint = Vector2.new(1, 0)
    craft.Position = UDim2.new(1, 0, 0, 0)
    craft.Parent = bar

    local refs: CraftingRefs = {
        ScreenGui = screen,
        Root = root,
        CloseButton = closeBtn,
        RecipesList = list,
        RecipesLayout = listLayout,
        DetailsPanel = right,
        DetailName = detailName,
        DetailIcon = detailIcon,
        IngredientsGrid = ingredients,
        IngredientsLayout = ingredientsLayout,
        QtyMinus = minus,
        QtyPlus = plus,
        QtyLabel = qty,
        CraftButton = craft,
    }
    return screen, refs
end

return M