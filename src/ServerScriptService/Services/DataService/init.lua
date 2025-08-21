-- ServerScriptService/Services/DataService.lua
-- v1.1 — in-memory profiles with auto-repair, no nil indexing on shutdown
local Players = game:GetService("Players")

local DataService = { Name = "DataService" }

function DataService:Init()
    self._profiles = self._profiles or {}
    print("[DataService] Studio detected - using in-memory storage")
end

function DataService:GetProfile(player: Player)
    if not player or not player.UserId or player.UserId <= 0 then
        error(("DataService:GetProfile requires valid Player, got %s"):format(tostring(player)))
    end
    
    local prof = self._profiles[player.UserId]
    if not prof then
        prof = { cash = 0, inv = {}, flags = { tutorial = { seen = false } } }
        self._profiles[player.UserId] = prof
    end
    
    -- Robust data repair with type safety
    if type(prof.cash) ~= "number" then prof.cash = 0 end
    if type(prof.inv) ~= "table" then prof.inv = {} end
    if type(prof.flags) ~= "table" then 
        prof.flags = { tutorial = { seen = false } }
    elseif type(prof.flags.tutorial) ~= "table" then
        prof.flags.tutorial = { seen = false }
    end
    
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