--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Networking = RS:WaitForChild("Networking")

local DisplayCaseService = {}
local store: {[number]: {}} = {}

function DisplayCaseService.Init(services)
    local DisplayCaseUpdated = Networking:WaitForChild("DisplayCaseUpdated")
    local DisplayCaseRequest = Networking:WaitForChild("DisplayCaseRequest")

    local function getCase(p: Player)
        local uid = p.UserId
        store[uid] = store[uid] or {}
        return store[uid]
    end

    function DisplayCaseRequest.OnServerInvoke(p: Player)
        return getCase(p)
    end

    DisplayCaseService.GetCase = function(p: Player)
        return getCase(p)
    end

    DisplayCaseService.RemoveFromDisplay = function(p: Player, index: number)
        local case = getCase(p)
        if case[index] then
            table.remove(case, index)
            DisplayCaseUpdated:FireClient(p, case)
        end
    end
end

return DisplayCaseService