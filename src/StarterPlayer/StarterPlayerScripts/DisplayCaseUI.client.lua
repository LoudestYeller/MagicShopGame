--!strict
-- Display Case UI: Stock → Set Price → List → Buy
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemotesIndex"))

-- All remotes are now directly accessible via Remotes table

-- UI State
local displayGui
local inventoryFrame
local displayFrame
local cashLabel
local isOpen = false

-- Data from server
local inventory = {}
local displayItems = {}
local playerCash = 0

local function safeColor(c)
    if typeof(c) == "Color3" then return c end
    return Color3.fromRGB(255,255,255)
end

-- Create the main UI
local function createDisplayCaseUI()
    displayGui = Instance.new("ScreenGui")
    displayGui.Name = "DisplayCaseUI"
    displayGui.Parent = playerGui
    displayGui.Enabled = false
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    mainFrame.Parent = displayGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.7, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
    title.Text = "Display Case - Stock & List Items"
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Cash display
    cashLabel = Instance.new("TextLabel")
    cashLabel.Size = UDim2.new(0.25, 0, 0.1, 0)
    cashLabel.Position = UDim2.new(0.7, 0, 0, 0)
    cashLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    cashLabel.TextColor3 = safeColor(Color3.fromRGB(255, 215, 0))
    cashLabel.Text = "Cash: 0¤"
    cashLabel.TextScaled = true
    cashLabel.Font = Enum.Font.SourceSansBold
    cashLabel.Parent = mainFrame
    
    -- Left side: Inventory (what you can stock)
    inventoryFrame = Instance.new("ScrollingFrame")
    inventoryFrame.Size = UDim2.new(0.45, 0, 0.8, 0)
    inventoryFrame.Position = UDim2.new(0.025, 0, 0.15, 0)
    inventoryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inventoryFrame.BorderSizePixel = 1
    inventoryFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    inventoryFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    inventoryFrame.ScrollBarThickness = 8
    inventoryFrame.Parent = mainFrame
    
    local inventoryLabel = Instance.new("TextLabel")
    inventoryLabel.Size = UDim2.new(0.45, 0, 0.05, 0)
    inventoryLabel.Position = UDim2.new(0.025, 0, 0.1, 0)
    inventoryLabel.BackgroundTransparency = 1
    inventoryLabel.TextColor3 = safeColor(Color3.fromRGB(200, 200, 200))
    inventoryLabel.Text = "Your Inventory"
    inventoryLabel.TextScaled = true
    inventoryLabel.Font = Enum.Font.SourceSans
    inventoryLabel.Parent = mainFrame
    
    -- Right side: Current Display (what's listed)
    displayFrame = Instance.new("ScrollingFrame")
    displayFrame.Size = UDim2.new(0.45, 0, 0.8, 0)
    displayFrame.Position = UDim2.new(0.525, 0, 0.15, 0)
    displayFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    displayFrame.BorderSizePixel = 1
    displayFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    displayFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    displayFrame.ScrollBarThickness = 8
    displayFrame.Parent = mainFrame
    
    local displayLabel = Instance.new("TextLabel")
    displayLabel.Size = UDim2.new(0.45, 0, 0.05, 0)
    displayLabel.Position = UDim2.new(0.525, 0, 0.1, 0)
    displayLabel.BackgroundTransparency = 1
    displayLabel.TextColor3 = safeColor(Color3.fromRGB(200, 200, 200))
    displayLabel.Text = "Items Listed"
    displayLabel.TextScaled = true
    displayLabel.Font = Enum.Font.SourceSans
    displayLabel.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.1, 0, 0.05, 0)
    closeButton.Position = UDim2.new(0.85, 0, 0.02, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
    closeButton.Text = "X"
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        toggleDisplayCase()
    end)
end

-- Update inventory display
local function updateInventoryUI()
    -- Clear existing
    for _, child in ipairs(inventoryFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local yPos = 0
    for itemId, qty in pairs(inventory) do
        if qty > 0 then
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 40)
            itemFrame.Position = UDim2.new(0, 5, 0, yPos)
            itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            itemFrame.BorderSizePixel = 1
            itemFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
            itemFrame.Parent = inventoryFrame
            
            local itemLabel = Instance.new("TextLabel")
            itemLabel.Size = UDim2.new(0.6, 0, 1, 0)
            itemLabel.Position = UDim2.new(0, 5, 0, 0)
            itemLabel.BackgroundTransparency = 1
            itemLabel.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
            itemLabel.Text = ("%s (x%d)"):format(itemId, qty)
            itemLabel.TextXAlignment = Enum.TextXAlignment.Left
            itemLabel.TextScaled = true
            itemLabel.Font = Enum.Font.SourceSans
            itemLabel.Parent = itemFrame
            
            local listButton = Instance.new("TextButton")
            listButton.Size = UDim2.new(0.35, 0, 0.8, 0)
            listButton.Position = UDim2.new(0.6, 0, 0.1, 0)
            listButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
            listButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
            listButton.Text = "List (Fee: 5%)"
            listButton.TextScaled = true
            listButton.Font = Enum.Font.SourceSans
            listButton.Parent = itemFrame
            
            -- Only enable if we have quantity
            if qty <= 0 then
                listButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                listButton.Text = "No Stock"
            end
            
            listButton.MouseButton1Click:Connect(function()
                if qty <= 0 then return end
                -- Simple fixed price for now - TODO: add price input dialog
                local price = 10
                local fee = math.max(1, math.floor(price * 0.05))
                print(("🏪 Listing %s x1 for %d¤ (fee: %d¤)"):format(itemId, price, fee))
                Remotes.DisplayCaseRequest:FireServer("LIST", {item = itemId, qty = 1, price = price})
            end)
            
            yPos = yPos + 45
        end
    end
    
    inventoryFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- helper to build a tiny editor on the item frame
local function showEditPopup(itemFrame, item, Remotes)
    local popup = Instance.new("Frame")
    popup.Name = "EditPopup"
    popup.Size = UDim2.new(1, 0, 1, 0)
    popup.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    popup.BackgroundTransparency = 0.25
    popup.Parent = itemFrame
    popup.ZIndex = 50

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 180, 0, 100)
    panel.Position = UDim2.new(0.5, -90, 0.5, -50)
    panel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    panel.BorderSizePixel = 0
    panel.ZIndex = 51
    panel.Parent = popup

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 18)
    title.Position = UDim2.new(0, 5, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Edit Listing"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.new(1,1,1)
    title.ZIndex = 52
    title.Parent = panel

    local priceBox = Instance.new("TextBox")
    priceBox.Size = UDim2.new(0.5, -8, 0, 24)
    priceBox.Position = UDim2.new(0, 5, 0, 30)
    priceBox.PlaceholderText = "Price"
    priceBox.Text = tostring(item.price or "")
    priceBox.ZIndex = 52
    priceBox.Parent = panel

    local qtyBox = Instance.new("TextBox")
    qtyBox.Size = UDim2.new(0.5, -8, 0, 24)
    qtyBox.Position = UDim2.new(0.5, 3, 0, 30)
    qtyBox.PlaceholderText = "Qty"
    qtyBox.Text = tostring(item.qty or "")
    qtyBox.ZIndex = 52
    qtyBox.Parent = panel

    local save = Instance.new("TextButton")
    save.Size = UDim2.new(0.5, -8, 0, 28)
    save.Position = UDim2.new(0, 5, 0, 62)
    save.Text = "Save"
    save.ZIndex = 52
    save.Parent = panel

    local cancel = Instance.new("TextButton")
    cancel.Size = UDim2.new(0.5, -8, 0, 28)
    cancel.Position = UDim2.new(0.5, 3, 0, 62)
    cancel.Text = "Cancel"
    cancel.ZIndex = 52
    cancel.Parent = panel

    cancel.MouseButton1Click:Connect(function()
        popup:Destroy()
    end)

    save.MouseButton1Click:Connect(function()
        local newPrice = tonumber(priceBox.Text)
        local newQty = tonumber(qtyBox.Text)
        if not newPrice or newPrice < 1 then newPrice = item.price end
        if not newQty or newQty < 1 then newQty = item.qty end
        Remotes.DisplayCaseRequest:FireServer("UPDATE", item.listingId, newPrice, newQty)
        popup:Destroy()
    end)
end

-- Update display items UI
local function updateDisplayUI()
    -- Clear existing
    for _, child in ipairs(displayFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local yPos = 0
    for i, item in ipairs(displayItems) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -10, 0, 40)
        itemFrame.Position = UDim2.new(0, 5, 0, yPos)
        itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        itemFrame.BorderSizePixel = 1
        itemFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        itemFrame.Parent = displayFrame
        
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Size = UDim2.new(0.4, 0, 1, 0)
        itemLabel.Position = UDim2.new(0, 5, 0, 0)
        itemLabel.BackgroundTransparency = 1
        itemLabel.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
        itemLabel.Text = ("%s x%d @ %d¤"):format(item.item or item.itemId, item.qty, item.price)
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.TextScaled = true
        itemLabel.Font = Enum.Font.SourceSans
        itemLabel.Parent = itemFrame
        
        local editButton = Instance.new("TextButton")
        editButton.Size = UDim2.new(0.25, 0, 0.8, 0)
        editButton.Position = UDim2.new(0.42, 0, 0.1, 0)
        editButton.BackgroundColor3 = Color3.fromRGB(80, 120, 160)
        editButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
        editButton.Text = "Edit"
        editButton.TextScaled = true
        editButton.Font = Enum.Font.SourceSans
        editButton.Parent = itemFrame
        
        editButton.MouseButton1Click:Connect(function()
            print(("✏️ Edit %s"):format(item.itemId or item.item or "unknown"))
            showEditPopup(itemFrame, item, Remotes)
        end)
        
        local removeButton = Instance.new("TextButton")
        removeButton.Size = UDim2.new(0.28, 0, 0.8, 0)
        removeButton.Position = UDim2.new(0.69, 0, 0.1, 0)
        removeButton.BackgroundColor3 = Color3.fromRGB(160, 80, 80)
        removeButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
        removeButton.Text = "Remove"
        removeButton.TextScaled = true
        removeButton.Font = Enum.Font.SourceSans
        removeButton.Parent = itemFrame
        
        removeButton.MouseButton1Click:Connect(function()
            print(("🗑️ Removing %s from display listingId %s"):format(item.itemId or item.item or "unknown", tostring(item.listingId)))
            Remotes.DisplayCaseRequest:FireServer("REMOVE", item.listingId)
        end)
        
        yPos = yPos + 45
    end
    
    displayFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- Update cash display
local function updateCashDisplay()
    cashLabel.Text = ("Cash: %d¤"):format(playerCash)
end

-- Request fresh inventory data from server
local function requestInventoryUpdate()
    -- Request fresh inventory
    -- Server pushes inventory automatically, just request display case data  
    Remotes.DisplayCaseRequest:FireServer("GET")
end

-- Toggle display case UI
function toggleDisplayCase()
    isOpen = not isOpen
    displayGui.Enabled = isOpen
    
    if isOpen then
        requestInventoryUpdate()
        updateCashDisplay()
        updateInventoryUI()
        updateDisplayUI()
    end
end

-- Listen for remote events
Remotes.DisplayCaseUpdated.OnClientEvent:Connect(function(userId, displayList)
    print(("[DisplayCaseUI] Received update for userId=%s, list length=%d"):format(tostring(userId), displayList and #displayList or 0))
    if userId == player.UserId then
        displayItems = displayList or {}
        print(("[DisplayCaseUI] Updated my display items, count=%d"):format(#displayItems))
        if isOpen then
            updateDisplayUI()
        end
    end
end)

-- Listen for cash updates (if available)
if Remotes.CashUpdated then
    Remotes.CashUpdated.OnClientEvent:Connect(function(newCash)
        playerCash = newCash or 0
        if isOpen then
            updateCashDisplay()
        end
    end)
end

-- Listen for inventory updates (if available)
if Remotes.InventoryUpdated then
    Remotes.InventoryUpdated.OnClientEvent:Connect(function(newInventory)
        inventory = newInventory or {}
        if isOpen then
            updateInventoryUI()
        end
    end)
end

-- Mock inventory update (in real game this would come from server)
local function mockInventoryUpdate()
    inventory = {
        ember_shard = 5,
        beast_fat = 3,
        frost_petals = 2,
        potion_warmth = 1,
        charm_frost = 1,
    }
    if isOpen then
        updateInventoryUI()
    end
end

-- Initialize
createDisplayCaseUI()
mockInventoryUpdate()

-- Keybind to toggle (L for List/Display)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        toggleDisplayCase()
    end
end)

-- Listen for remote toggle from display counter
Remotes.ToggleDisplayCase.OnClientEvent:Connect(function()
    toggleDisplayCase()
end)

print("📦 DisplayCaseUI loaded! Press L to open Display Case")