local M = {}

function M.Build()
    local m = Instance.new("Model")
    m.Name = "Banner_A"
    m:SetAttribute("StationType", "Decor")
    m:SetAttribute("StationId", "banner_a")
    m:SetAttribute("SocketType", "Decor")

    local cloth = Instance.new("Part")
    cloth.Name = "Cloth"
    cloth.Size = Vector3.new(4, 6, 0.2)
    cloth.Anchored = true
    cloth.Color = Color3.fromRGB(120, 40, 40)
    cloth.Material = Enum.Material.Fabric
    cloth.Parent = m

    m.PrimaryPart = cloth
    return m
end

return M