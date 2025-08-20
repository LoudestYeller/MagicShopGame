-- ServerScriptService/Services/DataService.lua
-- v1.1 — in-memory profiles with auto-repair, no nil indexing on shutdown
local Players = game:GetService("Players")

local DataService = { Name = "DataService" }

function DataService:Init()
    self._profiles = self._profiles or {}
    print("[DataService] Studio detected - using in-memory storage")
end

function DataService:GetProfile(player: Player)
    assert(player and player.UserId, "DataService:GetProfile requires Player")
    local prof = self._profiles[player.UserId]
    if not prof then
        prof = { cash = 0, inv = {}, flags = { tutorial = { seen = false } } }
        self._profiles[player.UserId] = prof
    end
    -- soft repair
    prof.cash  = tonumber(prof.cash) or 0
    prof.inv   = type(prof.inv) == "table" and prof.inv or {}
    prof.flags = type(prof.flags) == "table" and prof.flags or { tutorial = { seen = false } }
    return prof
end

function DataService:SetProfile(player: Player, newProfile: table)
    assert(player and player.UserId, "DataService:SetProfile requires Player")
    self._profiles[player.UserId] = newProfile
end

function DataService:Start()
    Players.PlayerRemoving:Connect(function(plr)
        if self._profiles then
            -- keep it simple in Studio; clear reference to avoid "index nil with number"
            self._profiles[plr.UserId] = nil
        end
    end)
end

return DataService