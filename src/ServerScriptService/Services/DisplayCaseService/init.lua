local ServicesFolder   = script:FindFirstAncestor("Services") or script.Parent
local Players          = game:GetService("Players")

local RemotesService   = require(ServicesFolder:WaitForChild("RemotesService"))
local DataService      = require(ServicesFolder:WaitForChild("DataService"))

local DisplayCaseService = {}
DisplayCaseService.__index = DisplayCaseService

function DisplayCaseService:Start()
    print("[DisplayCaseService] Start")
    -- ✅ pass strings, not tables
    local DisplayCaseRequest = RemotesService:Get("DisplayCaseRequest")
    self._DisplayCaseUpdated = RemotesService:Get("DisplayCaseUpdated")

    DisplayCaseRequest.OnServerEvent:Connect(function(player, action, payload)
        if action == "PutOnDisplay" then
            self:PutOnDisplay(player, payload)
        elseif action == "TakeFromDisplay" then
            self:TakeFromDisplay(player, payload)
        else
            warn("[DisplayCaseService] Unknown action:", action)
        end
    end)
end

local function ensureCase(userId)
    local p = DataService:Get(userId)
    if not p then return end
    p.display = p.display or { slots = {}, nextId = 1 }
    return p.display, p
end

function DisplayCaseService:GetCase(playerOrUserId)
    local userId = typeof(playerOrUserId) == "Instance" and playerOrUserId.UserId or tonumber(playerOrUserId)
    assert(userId, "[DisplayCaseService] GetCase: need Player or userId")
    local case = ensureCase(userId)
    return case
end

function DisplayCaseService:_broadcast(userId)
    local plr = Players:GetPlayerByUserId(userId)
    if not plr then return end
    local case = ensureCase(userId)
    if not case then return end
    self._DisplayCaseUpdated:FireClient(plr, userId, case)
end

function DisplayCaseService:PutOnDisplay(player, itemId)
    local userId = player.UserId
    local case = ensureCase(userId); if not case then return end
    table.insert(case.slots, { id = tostring(itemId), uid = case.nextId })
    case.nextId += 1
    print(("[DisplayCaseService] PutOnDisplay user=%d, item=%s, slots=%d"):format(userId, tostring(itemId), #case.slots))
    self:_broadcast(userId) -- ✅ immediate UI broadcast
end

function DisplayCaseService:TakeFromDisplay(player, uid)
    local userId = player.UserId
    local case = ensureCase(userId); if not case then return end
    for i,slot in ipairs(case.slots) do
        if slot.uid == uid then table.remove(case.slots, i) break end
    end
    print(("[DisplayCaseService] TakeFromDisplay user=%d, uid=%s, slots=%d"):format(userId, tostring(uid), #case.slots))
    self:_broadcast(userId) -- ✅ immediate UI broadcast
end

return DisplayCaseService