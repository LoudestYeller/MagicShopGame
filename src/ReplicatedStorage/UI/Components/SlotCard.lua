--!strict
-- Reusable display-slot card with hover + selected states
local TweenService = game:GetService("TweenService")

local M = {}

export type Props = {
    slotId: number?,
    icon: string?,      -- rbxassetid://… (optional)
    name: string?,      -- display name
    qty: number?,       -- quantity
    price: number?,     -- price (optional)
    selected: boolean?,
    onActivated: ((Frame) -> ())?, -- click handler
}

local function mkStroke(parent: GuiObject, color: Color3): UIStroke
    local s = Instance.new("UIStroke")
    s.Thickness = 2
    s.Color = color
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Transparency = 1        -- hidden by default
    s.Name = "SelectStroke"
    s.Parent = parent
    return s
end

function M.setSelected(card: Frame, isSelected: boolean)
    card:SetAttribute("Selected", isSelected and true or false)
    local stroke = card:FindFirstChild("SelectStroke") :: UIStroke?
    if stroke then
        stroke.Transparency = isSelected and 0 or 1
    end
end

function M.isCard(inst: Instance): boolean
    return inst:IsA("Frame") and inst:GetAttribute("_slotcard") == true
end

function M.setQty(card: Frame, qty: number)
    card:SetAttribute("Qty", qty)
    local qtyLabel = card:FindFirstChild("Qty") :: TextLabel?
    if qtyLabel then qtyLabel.Text = "x" .. tostring(qty) end
end

function M.setPrice(card: Frame, price: number?)
    card:SetAttribute("Price", price)
    local p = card:FindFirstChild("Price") :: TextLabel?
    if p then p.Text = price and ("$" .. tostring(price)) or "" end
end

function M.setIcon(card: Frame, image: string?)
    local img = (card:FindFirstChild("Icon") :: ImageLabel?) or (card:FindFirstChild("Body") and card.Body:FindFirstChild("Icon")) :: ImageLabel?
    if img then img.Image = image or "" end
end

function M.create(theme: any, props: Props?): Frame
    local hoverColor = theme.panelHover or theme.panel:Lerp(theme.accent, 0.1)

    local card = Instance.new("Frame")
    card.Name = "SlotCard"
    card.Size = UDim2.fromOffset(140, 100)
    card.BackgroundColor3 = theme.panel
    card.BorderSizePixel = 0
    card:SetAttribute("_slotcard", true)
    card:SetAttribute("SlotId", props and props.slotId or nil)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    local stroke = mkStroke(card, theme.accent)

    -- content wrapper
    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Size = UDim2.fromScale(1, 1)
    body.Parent = card

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = body

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Padding = UDim.new(0, 6)
    layout.Parent = body

    -- icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.fromOffset(40, 40)
    icon.Image = props and props.icon or ""
    icon.Parent = body
    local ar = Instance.new("UIAspectRatioConstraint")
    ar.AspectRatio = 1
    ar.Parent = icon

    -- name
    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.BackgroundTransparency = 1
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Font = Enum.Font.GothamMedium
    name.TextSize = 14
    name.TextColor3 = theme.text
    name.Size = UDim2.fromOffset(124, 18)
    name.Text = (props and props.name) or "Item"
    name.Parent = body

    -- meta row (qty + price)
    local meta = Instance.new("Frame")
    meta.Name = "Meta"
    meta.BackgroundTransparency = 1
    meta.Size = UDim2.fromOffset(124, 18)
    meta.Parent = body

    local metaLayout = Instance.new("UIListLayout")
    metaLayout.FillDirection = Enum.FillDirection.Horizontal
    metaLayout.Padding = UDim.new(0, 6)
    metaLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    metaLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    metaLayout.Parent = meta

    local qty = Instance.new("TextLabel")
    qty.Name = "Qty"
    qty.BackgroundTransparency = 1
    qty.Font = Enum.Font.GothamBold
    qty.TextSize = 14
    qty.TextColor3 = theme.text
    qty.Text = "x" .. tostring((props and props.qty) or 1)
    qty.Parent = meta

    local price = Instance.new("TextLabel")
    price.Name = "Price"
    price.BackgroundTransparency = 1
    price.Font = Enum.Font.Gotham
    price.TextSize = 14
    price.TextColor3 = theme.muted
    price.Text = (props and props.price) and ("$" .. tostring(props.price)) or ""
    price.Parent = meta

    -- hit target
    local hit = Instance.new("TextButton")
    hit.Name = "Hit"
    hit.BackgroundTransparency = 1
    hit.AutoButtonColor = false
    hit.Text = ""
    hit.Size = UDim2.fromScale(1, 1)
    hit.Parent = card

    -- hover behavior
    local tweenIn = TweenService:Create(card, TweenInfo.new(0.08), { BackgroundColor3 = hoverColor })
    local tweenOut = TweenService:Create(card, TweenInfo.new(0.12), { BackgroundColor3 = theme.panel })

    hit.MouseEnter:Connect(function()
        if not (card:GetAttribute("Selected")) then tweenIn:Play() end
    end)
    hit.MouseLeave:Connect(function()
        if not (card:GetAttribute("Selected")) then tweenOut:Play() end
    end)

    -- click behavior
    hit.Activated:Connect(function()
        local cb = props and props.onActivated
        if cb then cb(card) end
    end)

    -- initial state
    if props and props.selected then
        M.setSelected(card, true)
    else
        stroke.Transparency = 1
    end
    card:SetAttribute("Qty", props and props.qty or 1)
    card:SetAttribute("Price", props and props.price or nil)

    return card
end

return M