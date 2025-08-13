--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Items = require(ReplicatedStorage.Shared.Items)

local NPCSalesService = {}

-- Daily trends - rolled each day, affects prices by tag
NPCSalesService.DailyTrends = {
    Fire = 1.0,
    Frost = 1.0,
    Water = 1.0,
    Earth = 1.0,
    Void = 1.0,
    Pure = 1.0,
    Catalytic = 1.0,
    Viscous = 1.0,
    Rare = 1.0,
}

-- Roll new trends (called daily or on server start)
function NPCSalesService:RollDailyTrends()
    for tag, _ in pairs(self.DailyTrends) do
        -- Random modifier between 0.85 and 1.25 (±15-25%)
        self.DailyTrends[tag] = 0.85 + math.random() * 0.4
    end
    print("[NPCSalesService] Daily trends updated:", self.DailyTrends)
end

local function priceBand(itemId: string, quality: number, trends: {}?): (number, number)
    local def = Items[itemId]; if not def then return 1, 9999 end
    local base = def.baseValue or 10
    local rarity = def.rarity or 1
    local q = math.max(1, quality or 1)
    
    -- Apply base calculations
    local floor = math.floor(base * (1 + 0.2*(rarity-1)) * (1 + 0.1*(q-1)))
    local ceil  = math.floor(floor * 1.6)
    
    -- Apply trend modifiers if available - use highest matching trend
    if trends and def.tags then
        local bestTrend = 1.0
        for _, tag in ipairs(def.tags) do
            if trends[tag] and trends[tag] > bestTrend then
                bestTrend = trends[tag]
            end
        end
        -- Cap trend impact to prevent extreme swings
        bestTrend = math.clamp(bestTrend, 0.7, 1.4)
        floor = math.floor(floor * bestTrend)
        ceil = math.floor(ceil * bestTrend)
    end
    
    return floor, ceil
end

function NPCSalesService.Init(self)
    -- Use direct Roblox services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage") 
    local ServerStorage = game:GetService("ServerStorage")
    local RunService = game:GetService("RunService")
    
    -- Get other services via ServiceLoader
    local ServiceLoader = require(script.Parent.Parent.ServiceLoader)
    self.Data = ServiceLoader.requireService("DataService")
    self.Display = ServiceLoader.requireService("DisplayCaseService")
    self.Tutorial = ServiceLoader.requireService("TutorialService")
    
    print("[NPCSalesService] Init")
end

function NPCSalesService.Start(self)
    print("[NPCSalesService] Start")
    
    -- Roll initial daily trends
    self:RollDailyTrends()
    
    -- Daily trend refresh (every 24 hours in real time, 10 minutes for testing)
    task.spawn(function()
        while true do
            task.wait(600) -- 10 minutes for testing (change to 86400 for daily)
            self:RollDailyTrends()
        end
    end)
    
    -- NPC purchasing loop
    task.spawn(function()
        while true do
            task.wait(8 + math.random(0,4)) -- throttled purchases
            for _,plr in ipairs(Players:GetPlayers()) do
                local pdata = self.Data and self.Data:Get(plr)
                if pdata then
                    local d = pdata.display
                    if d and #d > 0 then
                        -- Find a reasonably priced item to buy
                        local pick = nil
                        local def = nil
                        local low, high = 0, 0
                        
                        -- First try random item
                        local randomPick = d[math.random(1,#d)]
                        local randomDef = Items[randomPick.itemId]
                        if randomDef then
                            local randomLow, randomHigh = priceBand(randomPick.itemId, 1, self.DailyTrends)
                            if randomPick.price >= randomLow and randomPick.price <= randomHigh then
                                pick, def, low, high = randomPick, randomDef, randomLow, randomHigh
                            end
                        end
                        
                        -- If random pick was overpriced, try alternatives
                        if not pick then
                            for _, altItem in ipairs(d) do
                                local altDef = Items[altItem.itemId]
                                if altDef then
                                    local altLow, altHigh = priceBand(altItem.itemId, 1, self.DailyTrends)
                                    if altItem.price >= altLow and altItem.price <= altHigh then
                                        pick, def, low, high = altItem, altDef, altLow, altHigh
                                        break
                                    end
                                end
                            end
                        end
                        
                        if pick and def then
                            -- NPC buys 1 (later: variable qty)
                            local qty = 1
                            if pick.qty >= qty then
                                -- credit seller with notifications
                                self.Data:GiveCash(plr, pick.price * qty)
                                pick.qty -= qty
                                if pick.qty <= 0 then
                                    table.remove(d, pick.slot)
                                end
                                -- broadcast updated display
                                local Remotes = require(ReplicatedStorage.Networking.Remotes)
                                Remotes.DisplayCaseUpdated:FireAllClients(plr.UserId, d)
                                
                                -- Determine which trend was used
                                local usedTrend, usedMult = "base", 1.0
                                if def.tags then
                                    for _, tag in ipairs(def.tags) do
                                        if self.DailyTrends[tag] and self.DailyTrends[tag] > usedMult then
                                            usedTrend = tag
                                            usedMult = self.DailyTrends[tag]
                                        end
                                    end
                                end
                                
                                print(("[NPCSales] bought %s @%d (trend: %s x%.2f) from %s"):format(
                                    pick.itemId, pick.price, usedTrend, usedMult, plr.Name
                                ))
                                
                                -- Track tutorial progress
                                if self.Tutorial then
                                    self.Tutorial:TrackSale(plr)
                                end
                            end
                        else
                            -- All items overpriced
                            if math.random() < 0.05 then -- 5% chance to log
                                print(("[NPCSales] %s: all items overpriced, skipping"):format(plr.Name))
                            end
                        end
                    end
                end
            end
        end
    end)
end

return NPCSalesService