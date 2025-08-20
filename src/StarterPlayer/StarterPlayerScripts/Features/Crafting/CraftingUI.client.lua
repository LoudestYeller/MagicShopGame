--!strict
-- Features/Crafting/CraftingUI.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Core modules
local Remotes = require(ReplicatedStorage.Modules.Remotes)

-- put these AT THE TOP
local isCrafting = false
local currentStation = nil
local stationEffects = {}

local function init()
    print("[CraftingUI] 📡 Loading remotes...")

    print("[CraftingUI] 💬 Setting up handlers...")

    -- Network handlers
    local CraftingState = Remotes.GetEvent("CraftingState")
    local ToggleCrafting = Remotes.GetEvent("ToggleCrafting")
    local RequestCraft = Remotes.GetFunction("RequestCraft")
    
    ToggleCrafting.OnClientEvent:Connect(function(station)
        if isCrafting then
            stopCrafting()
        else
            startCrafting(station)
        end
    end)

    local CraftedToast = Remotes.GetEvent("CraftedToast")
    CraftedToast.OnClientEvent:Connect(function(msg)
        print("[CraftingUI] Successfully crafted:", msg)
    end)

    print("[CraftingUI] ✅ Ready")
end

task.spawn(init)

-- Crafting modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local RecipesDB = require(Shared.Crafting.RecipesDB)
local IngredientDB = require(Shared.Crafting.IngredientDB)
local EffectsDB = require(Shared.Crafting.EffectsDB)

-- Services
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

-- Core crafting logic
local function startCrafting(station)
    if not Remotes then return end
    if isCrafting then return end
    
    isCrafting = true
    currentStation = station
    
    -- Get station type
    local stationType = station:GetAttribute("StationType") or "potion"
    local recipes = RecipesDB:GetRecipesForStation(stationType)
    
    -- Update UI state
    ToggleCrafting:FireServer(true)
    
    -- Cache station effects
    stationEffects = {}
    for _, item in ipairs(EffectsDB.GetStationEffects(station)) do
        stationEffects[item.id] = item.value
    end
end

local function stopCrafting()
    if not Remotes then return end
    if not isCrafting then return end
    
    isCrafting = false
    currentStation = nil
    stationEffects = {}
    ToggleCrafting:FireServer(false)
end

-- Clean up on character removal
Players.LocalPlayer.CharacterRemoving:Connect(function()
    stopCrafting()
end)

print("🔨 CraftingUI loaded! Bench-gated; no 'C' shortcut.")