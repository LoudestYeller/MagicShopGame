--!strict
local TutorialService = {}

-- Tutorial milestones
local TUTORIAL_STEPS = {
    "FirstGather",
    "FirstCraft", 
    "FirstStock",
    "FirstSale"
}

-- Completion rewards
local REWARDS = {
    cash = 100,
    items = { {id = "ember_shard", qty = 5}, {id = "beast_fat", qty = 3} },
    recipes = {"potion_warmth"}
}

function TutorialService.Init(self)
    -- Use direct Roblox services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerStorage = game:GetService("ServerStorage") 
    local RunService = game:GetService("RunService")
    
    -- Get other services via ServiceLoader
    local ServiceLoader = require(script.Parent.Parent.ServiceLoader)
    self.Data = ServiceLoader.requireService("DataService")
    
    print("[TutorialService] Init")
    
    -- Set up remote for tutorial toasts
    task.defer(function()
        self:_setupRemotes()
    end)
end

function TutorialService.Start(self) 
    print("[TutorialService] Start")
end

-- Track tutorial step completion
function TutorialService:TrackStep(plr: Player, step: string)
    local data = self.Data:Get(plr)
    if not data then return end
    
    -- Set up tutorial tracking structure
    if not data.analytics then data.analytics = {} end
    if not data.analytics.tutorial then data.analytics.tutorial = {} end
    
    if data.analytics.tutorial[step] then return end -- Already completed
    
    data.analytics.tutorial[step] = true
    print(("[TutorialService] %s completed: %s"):format(plr.Name, step))
    
    -- Send step completion feedback
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remotes = require(ReplicatedStorage.Networking.Remotes)
    if Remotes.TutorialToast then
        local messages = {
            FirstGather = "✅ First gather complete! Try crafting next.",
            FirstCraft = "🔨 Great crafting! Now list an item for sale.",
            FirstStock = "📦 Item listed! Wait for NPC buyers.",
            FirstSale = "💰 First sale! You're getting the hang of it!"
        }
        Remotes.TutorialToast:FireClient(plr, messages[step] or ("✅ %s complete!"):format(step))
    end
    
    -- Check if all steps complete
    local allDone = true
    for _, tutStep in ipairs(TUTORIAL_STEPS) do
        if not data.analytics.tutorial[tutStep] then
            allDone = false
            break
        end
    end
    
    if allDone and not data.analytics.tutorial.tutorialComplete then
        self:CompleteTutorial(plr)
    end
end

function TutorialService:_setupRemotes()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remotes = require(ReplicatedStorage.Networking.Remotes)
    -- Tutorial toasts handled via existing remotes for now
end

-- Award tutorial completion
function TutorialService:CompleteTutorial(plr: Player)
    local data = self.Data:Get(plr)
    if not data then return end
    
    data.analytics.tutorial.tutorialComplete = true
    
    -- Give rewards (now auto-broadcasts)
    self.Data:GiveCash(plr, REWARDS.cash)
    for _, item in ipairs(REWARDS.items) do
        self.Data:AddItem(plr, item.id, item.qty)
    end
    
    -- Add recipes
    if not data.discoveredRecipes then data.discoveredRecipes = {} end
    for _, recipe in ipairs(REWARDS.recipes) do
        data.discoveredRecipes[recipe] = true
    end
    
    -- Send completion toast to client
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Remotes = require(ReplicatedStorage.Networking.Remotes)
    if Remotes.TutorialToast then
        Remotes.TutorialToast:FireClient(plr, "🎉 Tutorial Complete! +100 cash, bonus items!")
    end
    
    print(("[TutorialService] 🎉 %s completed tutorial! Awarded %d cash, %d items, %d recipes"):format(
        plr.Name, REWARDS.cash, #REWARDS.items, #REWARDS.recipes
    ))
end

-- Helper methods for other services to call
function TutorialService:TrackGather(plr: Player) self:TrackStep(plr, "FirstGather") end
function TutorialService:TrackCraft(plr: Player) self:TrackStep(plr, "FirstCraft") end  
function TutorialService:TrackStock(plr: Player) self:TrackStep(plr, "FirstStock") end
function TutorialService:TrackSale(plr: Player) self:TrackStep(plr, "FirstSale") end

return TutorialService