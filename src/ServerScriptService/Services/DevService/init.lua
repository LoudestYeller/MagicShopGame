--!strict
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Services = SSS:WaitForChild("Services")
local ServiceLoader = require(SSS.ServiceLoader)
local DataService = ServiceLoader.requireService("DataService")

local Networking = RS.Networking
local DevGive = Networking:FindFirstChild("DevGive") or Instance.new("RemoteEvent", Networking)
DevGive.Name = "DevGive"

DevGive.OnServerEvent:Connect(function(player, itemId: string, qty: number)
    if not RunService:IsStudio() then return end
    if not player or not player.Name then
        warn("[DevGive] Invalid player:", tostring(player))
        return
    end
    if not itemId then
        warn("[DevGive] Missing itemId")
        return
    end
    qty = math.max(1, qty or 1)
    local function s(x)
        if typeof(x) == "Instance" then return x.Name end
        return tostring(x)
    end
    print(("[DevGive] Giving %s x%d to %s"):format(s(itemId), qty, s(player)))
    DataService:AddItem(player, itemId, qty)
    print(("[DevGive] Successfully gave %s x%d to %s"):format(s(itemId), qty, s(player)))
    
    -- Track first gather for tutorial
    local TutorialService = ServiceLoader.requireService("TutorialService")
    if TutorialService then
        TutorialService:TrackGather(player)
    end
end)

return {}