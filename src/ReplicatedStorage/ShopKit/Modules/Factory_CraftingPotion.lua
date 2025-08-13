local M = {}

function M.Build()
    local m = Instance.new("Model")
    m.Name = "CraftingBench_Potion"
    m:SetAttribute("StationType", "Crafting")
    m:SetAttribute("StationId", "potion_bench_basic")
    m:SetAttribute("SocketType", "CraftingMain")

    local tablePart = Instance.new("Part")
    tablePart.Name = "Table"
    tablePart.Size = Vector3.new(8, 3, 4)
    tablePart.Anchored = true
    tablePart.Color = Color3.fromRGB(85, 72, 60)
    tablePart.Material = Enum.Material.WoodPlanks
    tablePart.Parent = m

    local cauldron = Instance.new("Part")
    cauldron.Name = "Cauldron"
    cauldron.Shape = Enum.PartType.Cylinder
    cauldron.Size = Vector3.new(3, 2, 3)
    cauldron.Anchored = true
    cauldron.Color = Color3.fromRGB(40, 40, 40)
    cauldron.Material = Enum.Material.Metal
    cauldron.CFrame = tablePart.CFrame * CFrame.new(0, 2.5, 0)
    cauldron.Parent = m

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Craft Potions"
    prompt.ObjectText = "Potion Bench"
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12
    prompt.Parent = tablePart

    m.PrimaryPart = tablePart
    return m
end

return M