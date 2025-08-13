-- Wait for ServerMain to finish before doing health check
task.wait(0.5) -- Give ServerMain time to complete

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

-- Wait for RemotesService to finish creating all remotes
local networking = RS:WaitForChild("Networking")
local remotesFolder = networking:WaitForChild("Remotes")

-- Count services and actual RemoteEvents
local servicesCount = #SSS.Services:GetChildren()
local remotesCount = 0
for _, child in ipairs(remotesFolder:GetChildren()) do
    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
        remotesCount = remotesCount + 1
    end
end

-- Check for duplicate services (safety net)
local services = SSS:WaitForChild("Services")
local seen = {}
for _,child in ipairs(services:GetChildren()) do
    if seen[child.Name] then
        warn("⚠️  Duplicate service:", child.Name, child:GetFullName(), "and", seen[child.Name]:GetFullName())
    else
        seen[child.Name] = child
    end
end

print(("✅ Health OK (%d services, %d remotes)"):format(servicesCount, remotesCount))