--!strict
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Services = SSS:WaitForChild("Services")
local DataService = require(Services.DataService:FindFirstChild("init") or Services.DataService)

local Networking = RS:FindFirstChild("Networking") or Instance.new("Folder", RS)
Networking.Name = "Networking"
local DevGive = Networking:FindFirstChild("DevGive") or Instance.new("RemoteEvent", Networking)
DevGive.Name = "DevGive"

DevGive.OnServerEvent:Connect(function(player, itemId: string, qty: number)
    if not RunService:IsStudio() then return end
    if not player or not player.Name then
        warn("[DevGive] Invalid player:", tostring(player))
        return
    end
    qty = math.max(1, qty or 1)
    print(("[DevGive] Giving %s x%d to %s (type: %s)"):format(itemId, qty, player.Name, typeof(player)))
    DataService:AddItem(player, itemId, qty)
    print(("[DevGive] Successfully gave %s x%d to %s"):format(itemId, qty, player.Name))
    
    -- Track first gather for tutorial
    local TutorialService = require(Services.TutorialService:FindFirstChild("init") or Services.TutorialService)
    if TutorialService then
        TutorialService:TrackGather(player)
    end
end)

return {}