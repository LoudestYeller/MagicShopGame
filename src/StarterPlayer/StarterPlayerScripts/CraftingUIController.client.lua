--!strict
-- Minimal Crafting UI: pick station + inputs, call server
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remotes to be ready
local RS = game:GetService("ReplicatedStorage")
local ItemDB = require(RS:WaitForChild("Shared"):WaitForChild("ItemDB"))
local Remotes = require(RS:WaitForChild("Shared"):WaitForChild("RemotesIndex"))

-- All remotes are now accessed via Remotes table

-- Sanity prints (temporary)
print("RC", Remotes.RequestCraft, Remotes.RequestCraft and Remotes.RequestCraft.ClassName)
print("TC", Remotes.ToggleCrafting, Remotes.ToggleCrafting and Remotes.ToggleCrafting.ClassName)

-- UI State
local craftingGui
local stationFrame
local inputsFrame
local craftButton
local toastLabel
local isOpen = false

-- Crafting State
local selectedStation = "PotionBench"
local selectedInputs = {} -- [itemId] = qty
local inventory = {}

-- Forward declarations
local updateStationUI
local updateInputsUI

-- Server automatically pushes inventory on PlayerAdded, no need to request
-- Inventory updates will come via InventoryUpdated events

-- Station options
local STATIONS = {"PotionBench", "Enchanter", "WandTable"}

-- Recipe names for toasts
local RecipeNames = {
    potion_warmth = "Potion of Warmth",
    potion_healing = "Healing Potion",
    charm_frost = "Frost Charm",
    wand_basic = "Basic Wand",
    -- Add more as needed...
}

-- Toast notification system
local function toast(title, text, duration)
    -- Quick system toast; wrap in pcall for Studio
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title;
            Text = text;
            Duration = duration or 3;
        })
    end)
end

local function safeColor(c)
    if typeof(c) == "Color3" then return c end
    return Color3.fromRGB(255,255,255)
end

-- Show toast notification
local function showToast(message: string)
    if toastLabel then
        toastLabel.Text = message
        toastLabel.Visible = true
        task.spawn(function()
            task.wait(2)
            if toastLabel then
                toastLabel.Visible = false
            end
        end)
    end
end

-- Attempt to craft with selected inputs
local function attemptCraft()
    if not next(selectedInputs) then
        showToast("Select ingredients first!")
        return
    end
    
    -- Convert to server format
    local inputs = {}
    for itemId, qty in pairs(selectedInputs) do
        table.insert(inputs, {itemId = itemId, qty = qty})
    end
    
    print(("🔨 Crafting at %s with %d ingredients"):format(selectedStation, #inputs))
    
    -- Debug logging
    print("[CraftingUI] RequestCraft:", Remotes.RequestCraft, Remotes.RequestCraft and Remotes.RequestCraft.ClassName)
    print("[CraftingUI] ToggleCrafting:", Remotes.ToggleCrafting, Remotes.ToggleCrafting and Remotes.ToggleCrafting.ClassName)
    
    -- Fire to server
    Remotes.RequestCraft:FireServer(selectedStation, inputs, 1)
    
    -- Clear selections
    selectedInputs = {}
    if isOpen then
        updateInputsUI()
    end
end

-- Update station button colors
updateStationUI = function()
    if stationFrame then
        for _, btn in ipairs(stationFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                if btn.Text == selectedStation then
                    btn.BackgroundColor3 = Color3.fromRGB(80, 120, 160)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                end
            end
        end
    end
end

-- Update inputs display
updateInputsUI = function()
    if not inputsFrame then return end
    
    -- Clear existing
    for _, child in ipairs(inputsFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local yPos = 0
    for itemId, qty in pairs(inventory) do
        if qty > 0 then
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 35)
            itemFrame.Position = UDim2.new(0, 5, 0, yPos)
            itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            itemFrame.BorderSizePixel = 1
            itemFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
            itemFrame.Parent = inputsFrame
            
            -- Highlight if selected
            if selectedInputs[itemId] and selectedInputs[itemId] > 0 then
                itemFrame.BackgroundColor3 = Color3.fromRGB(80, 100, 60)
            end
            
            local itemLabel = Instance.new("TextLabel")
            itemLabel.Size = UDim2.new(0.7, 0, 1, 0)
            itemLabel.Position = UDim2.new(0, 5, 0, 0)
            itemLabel.BackgroundTransparency = 1
            itemLabel.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
            itemLabel.Text = ("%s (have: %d, using: %d)"):format(itemId, qty, selectedInputs[itemId] or 0)
            itemLabel.TextXAlignment = Enum.TextXAlignment.Left
            itemLabel.TextScaled = true
            itemLabel.Font = Enum.Font.SourceSans
            itemLabel.Parent = itemFrame
            
            local addButton = Instance.new("TextButton")
            addButton.Size = UDim2.new(0.12, 0, 0.8, 0)
            addButton.Position = UDim2.new(0.72, 0, 0.1, 0)
            addButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
            addButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
            addButton.Text = "+"
            addButton.TextScaled = true
            addButton.Font = Enum.Font.SourceSansBold
            addButton.Parent = itemFrame
            
            addButton.MouseButton1Click:Connect(function()
                local using = selectedInputs[itemId] or 0
                if using < qty then
                    selectedInputs[itemId] = using + 1
                    updateInputsUI()
                end
            end)
            
            local removeButton = Instance.new("TextButton")
            removeButton.Size = UDim2.new(0.12, 0, 0.8, 0)
            removeButton.Position = UDim2.new(0.85, 0, 0.1, 0)
            removeButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
            removeButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
            removeButton.Text = "-"
            removeButton.TextScaled = true
            removeButton.Font = Enum.Font.SourceSansBold
            removeButton.Parent = itemFrame
            
            removeButton.MouseButton1Click:Connect(function()
                local using = selectedInputs[itemId] or 0
                if using > 0 then
                    selectedInputs[itemId] = using - 1
                    if selectedInputs[itemId] == 0 then
                        selectedInputs[itemId] = nil
                    end
                    updateInputsUI()
                end
            end)
            
            yPos = yPos + 40
        end
    end
    
    inputsFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
end

-- Toggle crafting UI
local function toggleCrafting()
    isOpen = not isOpen
    if craftingGui then
        craftingGui.Enabled = isOpen
        
        if isOpen then
            -- Server pushes inventory automatically, just update UI
            updateStationUI()
            updateInputsUI()
        end
    end
end

-- Create main crafting UI
local function createCraftingUI()
    craftingGui = Instance.new("ScreenGui")
    craftingGui.Name = "CraftingUI"
    craftingGui.Parent = playerGui
    craftingGui.Enabled = false
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    mainFrame.Parent = craftingGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.8, 0, 0.1, 0)
    title.Position = UDim2.new(0.1, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    title.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
    title.Text = "Crafting Station"
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0.1, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.85, 0, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
    closeButton.Text = "X"
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        toggleCrafting()
    end)
    
    -- Station selection
    stationFrame = Instance.new("Frame")
    stationFrame.Size = UDim2.new(0.9, 0, 0.15, 0)
    stationFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
    stationFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    stationFrame.BorderSizePixel = 1
    stationFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    stationFrame.Parent = mainFrame
    
    local stationLabel = Instance.new("TextLabel")
    stationLabel.Size = UDim2.new(0.3, 0, 1, 0)
    stationLabel.Position = UDim2.new(0, 0, 0, 0)
    stationLabel.BackgroundTransparency = 1
    stationLabel.TextColor3 = safeColor(Color3.fromRGB(200, 200, 200))
    stationLabel.Text = "Station:"
    stationLabel.TextScaled = true
    stationLabel.Font = Enum.Font.SourceSans
    stationLabel.Parent = stationFrame
    
    -- Station buttons
    for i, station in ipairs(STATIONS) do
        local stationBtn = Instance.new("TextButton")
        stationBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
        stationBtn.Position = UDim2.new(0.3 + (i-1) * 0.22, 0, 0.1, 0)
        stationBtn.BackgroundColor3 = station == selectedStation and Color3.fromRGB(80, 120, 160) or Color3.fromRGB(80, 80, 80)
        stationBtn.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
        stationBtn.Text = station
        stationBtn.TextScaled = true
        stationBtn.Font = Enum.Font.SourceSans
        stationBtn.Parent = stationFrame
        
        stationBtn.MouseButton1Click:Connect(function()
            selectedStation = station
            updateStationUI()
        end)
    end
    
    -- Input selection area
    inputsFrame = Instance.new("ScrollingFrame")
    inputsFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
    inputsFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
    inputsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inputsFrame.BorderSizePixel = 1
    inputsFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
    inputsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    inputsFrame.ScrollBarThickness = 8
    inputsFrame.Parent = mainFrame
    
    local inputsLabel = Instance.new("TextLabel")
    inputsLabel.Size = UDim2.new(0.9, 0, 0.05, 0)
    inputsLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
    inputsLabel.BackgroundTransparency = 1
    inputsLabel.TextColor3 = safeColor(Color3.fromRGB(200, 200, 200))
    inputsLabel.Text = "Select Ingredients (click to add/remove)"
    inputsLabel.TextScaled = true
    inputsLabel.Font = Enum.Font.SourceSans
    inputsLabel.Parent = mainFrame
    
    -- Craft button
    craftButton = Instance.new("TextButton")
    craftButton.Size = UDim2.new(0.4, 0, 0.08, 0)
    craftButton.Position = UDim2.new(0.3, 0, 0.85, 0)
    craftButton.BackgroundColor3 = Color3.fromRGB(80, 160, 80)
    craftButton.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
    craftButton.Text = "Craft!"
    craftButton.TextScaled = true
    craftButton.Font = Enum.Font.SourceSansBold
    craftButton.Parent = mainFrame
    
    craftButton.MouseButton1Click:Connect(function()
        attemptCraft()
    end)
    
    -- Toast notification (hidden by default)
    toastLabel = Instance.new("TextLabel")
    toastLabel.Size = UDim2.new(0.4, 0, 0.1, 0)
    toastLabel.Position = UDim2.new(0.3, 0, 0.45, 0)
    toastLabel.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
    toastLabel.BorderSizePixel = 2
    toastLabel.BorderColor3 = Color3.fromRGB(100, 200, 100)
    toastLabel.TextColor3 = safeColor(Color3.fromRGB(255, 255, 255))
    toastLabel.Text = "Crafted something!"
    toastLabel.TextScaled = true
    toastLabel.Font = Enum.Font.SourceSansBold
    toastLabel.Visible = false
    toastLabel.Parent = craftingGui
end



-- Listen for inventory updates
Remotes.InventoryUpdated.OnClientEvent:Connect(function(newInventory)
    inventory = newInventory or {}
    print("[CraftingUI] Inventory updated:", inventory)
    if isOpen then
        updateInputsUI()
    end
end)

-- Listen for inventory snapshots
Remotes.InventorySnapshot.OnClientEvent:Connect(function(snapshot)
    inventory = snapshot or {}
    print("[CraftingUI] Inventory snapshot:", inventory)
    if isOpen then
        updateInputsUI()
    end
end)

-- Listen for crafting state changes
Remotes.CraftingState.OnClientEvent:Connect(function(state, recipeId, info)
    if state == "success" then
        toast("Crafted!", ("Made %s"):format(RecipeNames[recipeId] or tostring(recipeId)))
    elseif state == "open" then
        -- optional: open panel animation
    elseif state == "close" then
        -- optional: close panel animation
    elseif state == "fail" then
        local reason = tostring(info or "unknown")
        toast("Craft failed", reason, 4)
    end
end)

-- Listen for crafting results (secondary toast system)
Remotes.CraftedToast.OnClientEvent:Connect(function(outputs)
    local HttpService = game:GetService("HttpService")
    local outputsStr = "items"
    if type(outputs) == "table" then
        outputsStr = HttpService:JSONEncode(outputs)
    end
    toast("Success", ("Crafted: %s"):format(outputsStr))
end)

-- Initialize
createCraftingUI()

-- Keybind to toggle (C for Craft)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.C then
        toggleCrafting()
    end
end)

print("🔨 CraftingUI loaded! Press C to open Crafting Station")