local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")
local SSS     = game:GetService("ServerScriptService")

local Config           = require(RS.Shared.Config)
local DataService      = require(SSS.Services:WaitForChild("DataService"))
local ShopService      = SSS.Services:FindFirstChild("ShopService") and require(SSS.Services.ShopService)

local HealthService = { Name = "HealthService" }

local function classOK(inst, want) return inst and inst.ClassName == want end

local function checkRemotes()
    local f = RS:FindFirstChild("Networking")
    if not f then return false, "Networking folder missing" end
    for _, n in ipairs(Config.Remotes.Events) do
        local r = f:FindFirstChild(n); if not classOK(r, "RemoteEvent") then return false, ("RemoteEvent '%s' missing/wrong class"):format(n) end
    end
    for _, n in ipairs(Config.Remotes.Functions) do
        local r = f:FindFirstChild(n); if not classOK(r, "RemoteFunction") then return false, ("RemoteFunction '%s' missing/wrong class"):format(n) end
    end
    return true
end

local function validateProfile(plr)
    local ok, prof = pcall(function() return DataService:GetProfile(plr) end)
    if not ok or type(prof) ~= "table" then
        -- hard repair (reseed)
        local def = table.clone(Config.ProfileDefault)
        if DataService.SetProfile then pcall(DataService.SetProfile, DataService, plr, def) end
        return false, "profile-missing-reseed"
    end
    -- ensure shape (soft repair / fill defaults)
    prof.cash = tonumber(prof.cash) or 0
    prof.inv  = type(prof.inv) == "table" and prof.inv or {}
    prof.flags = type(prof.flags) == "table" and prof.flags or table.clone(Config.ProfileDefault.flags)
    return true
end

local function ensureShop(plr)
    if not ShopService or not ShopService.EnsureShop then return true end
    local ok = true
    local worked, err = pcall(function() ShopService:EnsureShop(plr) end)
    if not worked then ok = false end
    return ok
end

function HealthService:Init() end

function HealthService:Start()
    task.delay(Config.Health.initialDelay, function()
        while true do
            local remoteOK, rmsg = checkRemotes()
            local players = Players:GetPlayers()
            local profOK, profBad = true, 0
            for _, plr in ipairs(players) do
                local okProfile, why = validateProfile(plr)
                if not okProfile then profOK, profBad = false, profBad + 1 end
                ensureShop(plr) -- harmless if not implemented
            end

            if remoteOK and profOK then
                print(("✅ Health OK (%d players, %d events, %d functions)")
                    :format(#players, #Config.Remotes.Events, #Config.Remotes.Functions))
            else
                warn("⚠️ Health issues:")
                if not remoteOK then warn(" - Remotes:", rmsg) end
                if not profOK  then warn((" - Profiles repaired: %d"):format(profBad)) end
            end

            task.wait(Config.Health.cadence)
        end
    end)
end

return HealthService