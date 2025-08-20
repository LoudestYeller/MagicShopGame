local RS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")

local function cleanupDuplicates(targetName, oldNames)
    for _,container in ipairs({RS, SG}) do
        for _,oldName in ipairs(oldNames) do
            local old = container:FindFirstChild(oldName)
            if old and old:IsA("ScreenGui") then
                old:Destroy()
                print(("🧹 Removed duplicate GUI: %s from %s"):format(oldName, container.Name))
            end
        end
    end
end

cleanupDuplicates("DisplayUI", {"DisplayCaseUI"})
cleanupDuplicates("CraftingUI", {"Crafting"})