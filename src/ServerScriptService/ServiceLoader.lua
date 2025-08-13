local SSS = game:GetService("ServerScriptService")
local ServicesFolder = SSS:WaitForChild("Services")

local function moduleFor(name: string)
    local node = ServicesFolder:WaitForChild(name)
    if node:IsA("ModuleScript") then return node end
    -- Folder service: prefer a child ModuleScript named "init", or any ModuleScript
    local init = node:FindFirstChild("init")
    if init and init:IsA("ModuleScript") then return init end
    local any = node:FindFirstChildWhichIsA("ModuleScript")
    assert(any, ("Service %s missing ModuleScript"):format(name))
    return any
end

local function requireService(name: string)
    local ok, result = pcall(function()
        return require(moduleFor(name))
    end)
    if not ok then
        warn(("[ServiceLoader] Failed to require %s: %s"):format(name, result))
        return nil
    end
    return result
end

local order = {
    "DataService","InventoryService","CraftingService",
    "DisplayCaseService","NPCSalesService","TutorialService","DevService"
}

local ServiceLoader = {}
ServiceLoader.requireService = requireService

local services = {}

function ServiceLoader.InitAll()
    for _,n in ipairs(order) do
        local s = requireService(n)
        if s then
            services[n] = s
            if s.Init then
                local ok, err = pcall(s.Init, s)
                s.__inited = ok
                if not ok then 
                    warn(("[ServiceLoader] Init failed for %s: %s"):format(n, err))
                else
                    print(("[ServiceLoader] Init succeeded for %s"):format(n))
                end
            else
                s.__inited = true -- No Init method means success
            end
        end
    end
end

function ServiceLoader.StartAll()
    for _,n in ipairs(order) do
        local s = services[n]
        if s and s.__inited and s.Start then
            local ok, err = pcall(s.Start, s)
            if not ok then 
                warn(("[ServiceLoader] Start failed for %s: %s"):format(n, err))
            else
                print(("[ServiceLoader] Start succeeded for %s"):format(n))
            end
        elseif s and not s.__inited then
            print(("[ServiceLoader] Skipping Start for %s (Init failed)"):format(n))
        end
    end
end

return ServiceLoader