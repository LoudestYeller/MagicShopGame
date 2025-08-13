local M = {}

function M.Build()
    local m = Instance.new("Model")
    m.Name = "DisplayCounter_Generic"
    m:SetAttribute("StationType", "DisplayCounter")
    m:SetAttribute("StationId", "display_generic")
    m:SetAttribute("SocketType", "CounterMain")

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(12, 4, 3)
    base.Anchored = true
    base.Color = Color3.fromRGB(95, 80, 72)
    base.Material = Enum.Material.Wood
    base.Parent = m

    local glass = Instance.new("Part")
    glass.Name = "Glass"
    glass.Size = Vector3.new(12, 2, 0.2)
    glass.Anchored = true
    glass.Transparency = 0.5
    glass.Color = Color3.fromRGB(200, 200, 200)
    glass.Material = Enum.Material.Glass
    glass.CFrame = base.CFrame * CFrame.new(0, 3, -1.4)
    glass.Parent = m

    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Browse Goods"
    prompt.ObjectText = "Display Counter"
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12
    prompt.Parent = base

    m.PrimaryPart = base
    return m
end

return M