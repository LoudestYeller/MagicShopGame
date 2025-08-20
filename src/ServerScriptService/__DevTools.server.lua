local RunService = game:GetService("RunService")
if not RunService:IsStudio() then return end

-- Core setup (runs before RemotesService)
local RS = game:GetService("ReplicatedStorage")
local Networking = Instance.new("Folder")
Networking.Name = "Networking"
Networking.Parent = RS

print("[DevTools] Setting up dev remotes...")

-- Dev remotes setup
local function ensureRemote(name)
    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = Networking
    print("[DevTools] Created remote:", name)
    return remote
end

local Dev_Grant = ensureRemote("Dev_Grant")
local Dev_Place = ensureRemote("Dev_Place")
local Dev_NPCBuy = ensureRemote("Dev_NPCBuy")

-- Initialize services (after remotes ready)
local SSS = game:GetService("ServerScriptService")
task.defer(function()
    local ServiceLoader = require(SSS.ServiceLoader)
    local DataService = ServiceLoader.requireService("DataService")
    local NPCSalesService = ServiceLoader.requireService("NPCSalesService")

    -- Set up handlers
    Dev_Grant.OnServerEvent:Connect(function(player)
        DataService:AddItem(player, "ember_shard", 3)
        DataService:AddItem(player, "beast_fat", 3)
    end)

    Dev_Place.OnServerEvent:Connect(function(player, itemId, price, qty)
        qty = qty or 1
        -- Use new DisplayCaseService API
        local DisplayCaseService = ServiceLoader.requireService("DisplayCaseService")
        if DisplayCaseService and DisplayCaseService.PutOnDisplay then
            DisplayCaseService.PutOnDisplay(player.UserId, itemId, qty)
        end
    end)

    Dev_NPCBuy.OnServerEvent:Connect(function(player, budget)
        budget = tonumber(budget) or 75
        if NPCSalesService.AttemptAutoPurchase then
            NPCSalesService:AttemptAutoPurchase(player, budget)
        end
    end)
end)

print("[DevTools] Dev remotes ready")