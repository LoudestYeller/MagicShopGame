--!strict
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")

local function listDupes(root: Instance, className: string, label: string)
    local buckets: {[string]: {Instance}} = {}
    for _, inst in ipairs(root:GetDescendants()) do
        if inst.ClassName == className then
            local t = buckets[inst.Name]
            if not t then t = {}; buckets[inst.Name] = t end
            table.insert(t, inst)
        end
    end
    for name, arr in pairs(buckets) do
        if #arr > 1 then
            warn(("⚠️  Duplicate %s '%s' (%d copies):"):format(label, name, #arr))
            for i, inst in ipairs(arr) do
                warn(("    %d) %s"):format(i, inst:GetFullName()))
            end
        end
    end
end

-- Services
listDupes(SSS:WaitForChild("Services"), "ModuleScript", "service")

-- Remotes
local Net = RS:FindFirstChild("Networking")
if Net then
    listDupes(Net, "RemoteEvent", "RemoteEvent")
    listDupes(Net, "RemoteFunction", "RemoteFunction")
end