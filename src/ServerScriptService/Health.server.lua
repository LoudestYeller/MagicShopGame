-- Wait for ServerMain to finish before doing health check
task.wait(0.5) -- Give ServerMain time to complete

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Use Remotes helper
local Remotes = require(RS.Modules.Remotes)

-- Count services and actual RemoteEvents
local servicesCount = #SSS.Services:GetChildren()
local remotesCount = 0
for _, child in ipairs(RS.Networking:GetChildren()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        remotesCount = remotesCount + 1
    end
end

-- Collect services by name and print full paths for duplicates
local ServicesRoot = game:GetService("ServerScriptService"):WaitForChild("Services")
local byName: {[string]: {Instance}} = {}

for _, inst in ServicesRoot:GetDescendants() do
    if inst:IsA("ModuleScript") then
        local t = byName[inst.Name]
        if not t then
            t = {}
            byName[inst.Name] = t
        end
        table.insert(t, inst)
    end
end

for name, list in pairs(byName) do
    if #list > 1 then
        -- Print all dupes with absolute paths
        warn(("⚠️  Duplicate service '%s' (%d copies):"):format(name, #list))
        for i, inst in ipairs(list) do
            warn(("    %d) %s"):format(i, inst:GetFullName()))
        end
    end
end

print(("✅ Health OK (%d services, %d remotes)"):format(servicesCount, remotesCount))