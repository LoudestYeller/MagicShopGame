--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = require(Modules:WaitForChild("Remotes"))
local PriceBook = require(ReplicatedStorage.Shared.PriceBook)

-- State
local dailyTrends = nil

-- UI helpers
local function updatePriceSuggestion(itemId: string, qtyInput: TextBox, priceInput: TextBox)
    local qty = tonumber(qtyInput.Text) or 1
    local suggested = PriceBook.getSuggestedPrice(itemId, qty, dailyTrends)
    priceInput.PlaceholderText = ("Suggested: %d"):format(suggested)
end

local function setupDisplayUI()
    -- Get daily trends on open
    if not dailyTrends then
        local ok, trends = pcall(function()
            return Remotes.GetDailyTrends:InvokeServer()
        end)
        if ok and trends then
            dailyTrends = trends
            print("[DisplayUI] Got daily trends:", dailyTrends)
        else
            warn("[DisplayUI] Failed to get daily trends:", trends)
        end
    end

    -- Hook up quantity/price inputs
    local displayFrame = script.Parent:WaitForChild("DisplayFrame")
    local qtyInput = displayFrame:WaitForChild("QuantityInput")
    local priceInput = displayFrame:WaitForChild("PriceInput")
    local itemSelect = displayFrame:WaitForChild("ItemSelect")

    -- Update price suggestion when item/qty changes
    itemSelect.Changed:Connect(function(prop)
        if prop == "Selected" then
            local itemId = itemSelect.Selected
            if itemId then
                updatePriceSuggestion(itemId, qtyInput, priceInput)
            end
        end
    end)

    qtyInput.Changed:Connect(function(prop)
        if prop == "Text" then
            local itemId = itemSelect.Selected
            if itemId then
                updatePriceSuggestion(itemId, qtyInput, priceInput)
            end
        end
    end)
end

-- Connect to toggle events
Remotes.ToggleDisplayCase.OnClientEvent:Connect(function()
    setupDisplayUI()
end)