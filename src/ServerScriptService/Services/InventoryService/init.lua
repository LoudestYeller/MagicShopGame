-- ServerScriptService/Services/InventoryService.lua
-- v1.2 — accepts Player/Character, dict or string adds; binds InventorySnapshot and logs binding
local RS      = game:GetService("ReplicatedStorage")
local SSS     = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Networking  = RS:WaitForChild("Networking")
local DataService = require(SSS.Services:WaitForChild("DataService"))

local InventoryService = { Name = "InventoryService" }

function InventoryService:Init()
    self._evUpdated  = Networking:WaitForChild("InventoryUpdated")   :: RemoteEvent
    self._fnSnapshot = Networking:WaitForChild("InventorySnapshot")  :: RemoteFunction
    self._evDevGive  = Networking:FindFirstChild("DevGive")          :: RemoteEvent?
end

-- Normalize Player/Character/descendant -> Player
local function toPlayer(x: Instance?)
    if not x then return nil end
    if x:IsA("Player") then return x end
    local model = x:FindFirstAncestorOfClass("Model") or x
    return Players:GetPlayerFromCharacter(model)
end

function InventoryService:_inv(playerLike: Instance)
    local plr = toPlayer(playerLike)
    assert(plr, "InventoryService:_inv expects Player/Character")
    local prof = DataService:GetProfile(plr)
    prof.inv = prof.inv or {}
    return prof.inv, plr
end

local function cloneDict(t: table?)
    local out = {}
    for k, v in pairs(t or {}) do out[k] = v end
    return out
end

-- Accept (player, dict) or (player, itemId, qty)
function InventoryService:Add(playerLike: Instance, itemOrDict: any, qty: number?)
    if type(itemOrDict) == "table" and qty == nil then
        for id, q in pairs(itemOrDict) do
            self:Add(playerLike, id, q)
        end
        return
    end
    assert(type(itemOrDict) == "string" and itemOrDict ~= "", "Add expects itemId")
    local amount = tonumber(qty) or 1

    local inv, plr = self:_inv(playerLike)
    inv[itemOrDict] = (inv[itemOrDict] or 0) + amount
    self._evUpdated:FireClient(plr, cloneDict(inv))
end

function InventoryService:Snapshot(playerLike: Instance)
    local inv = select(1, self:_inv(playerLike))
    return cloneDict(inv)
end

function InventoryService:Start()
    local THIS = self
    self._fnSnapshot.OnServerInvoke = function(player: Player)
        return THIS:Snapshot(player)
    end
    print("[InventoryService] Snapshot bound ✔")

    if self._evDevGive then
        self._evDevGive.OnServerEvent:Connect(function(player: Player, payload: any, qty: number?)
            if type(payload) == "table" then
                THIS:Add(player, payload)
            elseif type(payload) == "string" then
                THIS:Add(player, payload, qty or 1)
            end
        end)
    end
end

return InventoryService