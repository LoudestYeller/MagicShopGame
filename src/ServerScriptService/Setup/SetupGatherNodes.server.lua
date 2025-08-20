local CollectionService = game:GetService("CollectionService")
local TAG = "GatherNode"

-- Get all gathering resources in Forest
local function setupForestNodes()
    local forest = workspace:FindFirstChild("Forest")
    if not forest then return end

    for _, node in ipairs(forest:GetDescendants()) do
        if node:GetAttribute("ItemId") then
            print(("[SetupGatherNodes] Tagging node: %s -> %s"):format(
                node:GetFullName(), 
                node:GetAttribute("ItemId")
            ))
            CollectionService:AddTag(node, TAG)
        end
    end
end

setupForestNodes()

print("[SetupGatherNodes] Complete - run InstallGatherScripts to attach behavior")