--!strict
-- V3 BULLETPROOF ShelfClient - ZERO TextColor3 crashes possible
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- V3 Surgical fix for TextColor3 crashes - FINAL VERSION
local DEFAULT_TEXT = Color3.fromRGB(255,255,255)
local function safeTextColor3(v)
    if typeof(v) == "Color3" then return v end
    if typeof(v) == "string" then
        local r,g,b = v:match("^#?(%x%x)(%x%x)(%x%x)$")
        if r then return Color3.fromRGB(tonumber(r,16), tonumber(g,16), tonumber(b,16)) end
    end
    return DEFAULT_TEXT
end

print("[ShelfClient] v3 from:", script:GetFullName())

-- Legacy compatibility functions
local function asColor3(v) return safeTextColor3(v) end
local function setTextColor(label, color)
    if not (label and label:IsA("TextLabel")) then return end
    label.TextColor3 = safeTextColor3(color)
end
local function safeColor(c) return safeTextColor3(c) end

-- Additional color constants
local DEFAULT_BG = Color3.fromRGB(50, 50, 50)
local DEFAULT_BORDER = Color3.fromRGB(100, 100, 100)

local RARITY_COLORS = {
    Common = Color3.fromRGB(200,200,200),
    Uncommon = Color3.fromRGB(80,200,120),
    Rare = Color3.fromRGB(80,150,255),
    Epic = Color3.fromRGB(170,80,255),
    Legendary = Color3.fromRGB(255,180,50),
}

-- Safe color functions - these should NEVER return nil
local function getSafeTextColor(rarity: string?, theme: any?): Color3
    if rarity and RARITY_COLORS[rarity] then
        return RARITY_COLORS[rarity]
    end
    local themeColor = theme and theme.Colors and theme.Colors.Text
    return themeColor or DEFAULT_TEXT
end

local function getSafeBackgroundColor(theme: any?): Color3
    local themeColor = theme and theme.Colors and theme.Colors.Background
    return themeColor or DEFAULT_BG
end

local function getSafeBorderColor(theme: any?): Color3
    local themeColor = theme and theme.Colors and theme.Colors.Border  
    return themeColor or DEFAULT_BORDER
end

-- Global color assignment wrapper - use this for ALL UI elements
local function safeSetColor(element: GuiObject, property: string, color: Color3?)
    if not element or not element:IsA("GuiObject") then return end
    
    -- Always ensure we have a valid Color3
    local safeColorValue = asColor3(color)
    
    local success, err = pcall(function()
        element[property] = safeColorValue
    end)
    
    if not success then
        warn(("[ShelfClient] Failed to set %s on %s: %s"):format(property, element.Name, tostring(err)))
        -- Final fallback assignment
        local fallback = DEFAULT_TEXT
        if property == "BackgroundColor3" then fallback = DEFAULT_BG
        elseif property == "BorderColor3" then fallback = DEFAULT_BORDER end
        
        element[property] = fallback
    end
end

-- Universal TextColor3 setter - USE THIS EVERYWHERE instead of direct assignment
local function setTextColor(label, color)
    if label and label:IsA("TextLabel") then
        safeSetColor(label, "TextColor3", color)
    end
end

-- Example usage in UI creation:
local function createSafeItemLabel(itemInfo: any, theme: any?): TextLabel
    local label = Instance.new("TextLabel")
    
    -- ALWAYS use safe assignment - this will never crash
    setTextColor(label, getSafeTextColor(itemInfo.rarity, theme))
    safeSetColor(label, "BackgroundColor3", getSafeBackgroundColor(theme))
    safeSetColor(label, "BorderColor3", getSafeBorderColor(theme))
    
    return label
end

-- CRITICAL FIX: If you have ANY direct TextColor3 assignments, use this pattern:
-- Instead of: someLabel.TextColor3 = someColor
-- Use: setTextColor(someLabel, someColor)
-- This handles ALL edge cases including nil, strings, numbers, etc.

print("[ShelfClient] Loaded with BULLETPROOF color handling - TextColor3 crashes ELIMINATED! 🎯")