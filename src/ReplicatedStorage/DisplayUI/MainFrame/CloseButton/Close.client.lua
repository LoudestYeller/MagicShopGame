-- Runs after the ScreenGui is cloned into PlayerGui
local btn = script.Parent :: TextButton

local function findScreenGui(inst: Instance): ScreenGui?
    while inst and not inst:IsA("ScreenGui") do
        inst = inst.Parent
    end
    return inst
end

btn.Activated:Connect(function()
    local sg = findScreenGui(btn)
    if sg then
        sg.Enabled = false
    end
end)