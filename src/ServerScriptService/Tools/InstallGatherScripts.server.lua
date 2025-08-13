local SSS = game:GetService("ServerScriptService")
local Templates = SSS:WaitForChild("Templates")
local template = Templates:FindFirstChild("GatherScript")
if not template then
    warn("[Installer] GatherScript template NOT found at ServerScriptService/Templates/GatherScript")
    return
end

local count = 0
for _,d in ipairs(workspace:GetDescendants()) do
    if d:IsA("BasePart") and d:GetAttribute("ItemId") then
        local old = d:FindFirstChild("GatherScript")
        if old then old:Destroy() end
        local s = template:Clone()
        s.Name = "GatherScript"
        s.Parent = d
        count += 1
    end
end
print(("[Installer] GatherScript attached to %d nodes"):format(count))