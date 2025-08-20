--!strict
local SSS = game:GetService("ServerScriptService")

local ORDER = {
    "RemotesService",      -- must run first (creates Networking + remotes)
    "DataService",
    "HealthService",       -- early for monitoring
    "InventoryService",
    "DisplayCaseService",
    "CraftingService",
    "NPCSalesService",
    "TutorialService",
    "ShopService",
    "CraftingBinder",
}

local Services: {[string]: any} = {}
local ctx = {
    remotes = {}, -- RemotesService will populate this
}

local function requireSafe(path: Instance, name: string)
    local ok, mod = pcall(function() return require(path) end)
    if not ok then
        warn(("[ServiceLoader] Failed to require %s: %s"):format(name, tostring(mod)))
        return nil, mod
    end
    return mod :: any
end

local function callSafe(svc, method, ...)
  local f = svc[method]
  if type(f) == "function" then
    local ok, err = pcall(f, svc, ...)
    if not ok then warn(("[ServiceLoader] %s.%s error: %s"):format(svc.Name or tostring(svc), method, err)) end
  else
    warn(("[ServiceLoader] %s missing %s()"):format(svc.Name or tostring(svc), method))
  end
end

local ServiceLoader = {}
ServiceLoader.Services = Services  -- Expose services table

function ServiceLoader.Init()
    for _, name in ipairs(ORDER) do
        local modScript = SSS.Services:FindFirstChild(name)
        if not modScript then
            warn(("[ServiceLoader] Missing ModuleScript for %s"):format(name))
        else
            local mod = requireSafe(modScript, name)
            if mod then Services[name] = mod end
        end
    end

    for _, name in ipairs(ORDER) do
        local svc = Services[name]
        if svc then
            -- Pass Services table to every service so they can access each other
            callSafe(svc, "Init", Services)
            print(("[ServiceLoader] Init succeeded for %s"):format(name))
            -- RemotesService populates ctx.remotes after its Init
            if name == "RemotesService" and type(ctx.remotes) ~= "table" then
                ctx.remotes = {}
            end
        end
    end
end

function ServiceLoader.Start()
    for _, name in ipairs(ORDER) do
        local svc = Services[name]
        if svc then
            callSafe(svc, "Start", Services)
            print(("[ServiceLoader] Start succeeded for %s"):format(name))
        end
    end
end

return ServiceLoader