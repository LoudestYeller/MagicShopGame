local CollectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local TEMPLATE = SSS.Templates:WaitForChild("GatherScript") -- your template

local TAG = "GatherNode" -- <- make sure your nodes have this exact tag

local function ensureScript(node: Instance)
    if node:FindFirstChild("GatherScript") then return end
    local s = TEMPLATE:Clone()
    s.Parent = node
end

for _,node in ipairs(CollectionService:GetTagged(TAG)) do
    ensureScript(node)
end

CollectionService:GetInstanceAddedSignal(TAG):Connect(ensureScript)

print(("[Installer] GatherScript attached to %d nodes"):format(#CollectionService:GetTagged(TAG)))