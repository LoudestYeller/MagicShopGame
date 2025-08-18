local Services          = script.Parent
local Players           = game:GetService("Players")
local RemotesService    = require(Services:WaitForChild("RemotesService"))
local DataService       = require(Services:WaitForChild("DataService"))

local DisplayCaseService = {}
DisplayCaseService.__index = DisplayCaseService

function DisplayCaseService:Start()
    print("[DisplayCaseService] Start")

    -- ✅ strings only:
    local DisplayCaseRequest = RemotesService:Get("DisplayCaseRequest")
    self.DisplayCaseUpdated  = RemotesService:Get("DisplayCaseUpdated")

    DisplayCaseRequest.OnServerEvent:Connect(function(player, action, payload)
        if action == "PutOnDisplay" then
            self:PutOnDisplay(player, payload)        -- payload = itemId string
        elseif action == "TakeFromDisplay" then
            self:TakeFromDisplay(player, payload)     -- payload = uid number
        else
            warn("[DisplayCaseService] Unknown action:", action)
        end
    end)
end

-- minimal case store using DataService
local function ensureCase(userId)
    local profile = DataService:Get(userId)
    if not profile then return end
    profile.display = profile.display or { slots = {}, nextId = 1 }
    return profile.display
end

function DisplayCaseService:GetCase(playerOrUserId)
    local userId = typeof(playerOrUserId) == "Instance" and playerOrUserId.UserId or tonumber(playerOrUserId)
    assert(userId, "[DisplayCaseService] GetCase: need Player or userId")
    return ensureCase(userId)
end

function DisplayCaseService:_broadcast(userId)
    local plr = Players:GetPlayerByUserId(userId)
    if not plr then return end
    local case = ensureCase(userId)
    if not case then return end
    self.DisplayCaseUpdated:FireClient(plr, userId, case)  -- ✅ immediate UI sync
end

function DisplayCaseService:PutOnDisplay(player, itemId)
    local userId = player.UserId
    local case = ensureCase(userId); if not case then return end
    table.insert(case.slots, { id = tostring(itemId), uid = case.nextId })
    case.nextId += 1
    print(("[DisplayCaseService] PutOnDisplay user=%d item=%s slots=%d"):format(userId, tostring(itemId), #case.slots))
    self:_broadcast(userId)
end

function DisplayCaseService:TakeFromDisplay(player, uid)
    local userId = player.UserId
    local case = ensureCase(userId); if not case then return end
    for i,slot in ipairs(case.slots) do
        if slot.uid == uid then table.remove(case.slots, i) break end
    end
    print(("[DisplayCaseService] TakeFromDisplay user=%d uid=%s slots=%d"):format(userId, tostring(uid), #case.slots))
    self:_broadcast(userId)
end

return DisplayCaseService