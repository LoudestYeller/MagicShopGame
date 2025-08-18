--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Service = {}

-- Daily trends - rolled each day, affects prices by tag
Service.DailyTrends = {
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
function Service:RollDailyTrends()
    for tag, _ in pairs(self.DailyTrends) do
        -- Random modifier between 0.85 and 1.25 (±15-25%)
        self.DailyTrends[tag] = 0.85 + math.random() * 0.4
    end
    print("[NPCSalesService] Daily trends updated:", self.DailyTrends)
end

function Service:AttemptAutoPurchase(player, npcBudget)
    if not self.Display then return false end
    if not player or not player.UserId then return false end
    local case = self.Display:GetCase(player.UserId)
    local best
    local bestValue = -math.huge

    for slotId, slot in pairs(case.slots) do
        local trend = self.DailyTrends[slot.itemId] or 1.0
        local p = slot.price or priceFor(slot.itemId, nil, trend)
        if p <= npcBudget and p > bestValue then 
            best = slot
            bestValue = p
        end
    end
    
    if not best then return false end

    self.Display:TakeFromDisplay(player, best.slotId, 1)
    self.Data:GiveCash(player, bestValue)
    RemotesService.Get("CashUpdated"):FireClient(player, self.Data:GetCash(player))
    RemotesService.Get("CraftedToast"):FireClient(player, ("Sold %s for %d!"):format(best.itemId, bestValue))
    
    -- Track tutorial progress
    if self.Tutorial then
        self.Tutorial:TrackSale(player)
    end

    return true
end

function Service.Init(self)
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
    
    -- Set up remote for getting daily trends
    local RemotesService = ServiceLoader.requireService("RemotesService")
    if RemotesService then
        local GetDailyTrends = RemotesService.Get("GetDailyTrends")
        if GetDailyTrends and GetDailyTrends:IsA("RemoteFunction") then
            GetDailyTrends.OnServerInvoke = function()
                return self.DailyTrends
            end
        end
    end
    
    print("[NPCSalesService] Init")
end

function Service.Start(self)
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
                self:AttemptAutoPurchase(plr, 50)
            end
        end
    end)
end

return Service