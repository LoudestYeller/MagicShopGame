-- ServerScriptService/DevTools/GeneratePlaceholderModels.server.lua
-- One-shot generator for placeholder item models used in ViewportFrame icons.
-- Creates ReplicatedStorage/Assets/ItemModels/<snake_case_id> with:
--  - PrimaryPart "Body"
--  - Attachment "IconPivot" for consistent camera framing
--  - Built-in light for readable thumbnails

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if not RunService:IsStudio() then
    warn("[GeneratePlaceholderModels] Skipping (not Studio).")
    return
end

local function ensureFolder(parent, name)
    return parent:FindFirstChild(name) or Instance.new("Folder", parent)
end

local Assets = ReplicatedStorage:FindFirstChild("Assets") or Instance.new("Folder")
Assets.Name = "Assets"
Assets.Parent = ReplicatedStorage

local ItemModels = Assets:FindFirstChild("ItemModels") or Instance.new("Folder")
ItemModels.Name = "ItemModels"
ItemModels.Parent = Assets

local ITEMS = {
    -- Base ingredients
    "glowing_mushroom",
    "shadow_moss",
    "frostleaf",
    "crystal_flower",
    "ember_shard",
    "beast_fat",
    -- Crafted items
    "potion_healing",
    "potion_frostward",
    "salve_ice",
    "charm_frost",
}

local PALETTE = {
    glowing_mushroom = Color3.fromRGB(235, 250, 200),
    shadow_moss     = Color3.fromRGB( 30,  70,  50),
    frostleaf       = Color3.fromRGB(160, 220, 255),
    crystal_flower  = Color3.fromRGB(180, 120, 255),
    ember_shard     = Color3.fromRGB(255, 145,  95),
    beast_fat       = Color3.fromRGB(245, 230, 200),

    potion_healing  = Color3.fromRGB(220,  40,  60),
    potion_frostward= Color3.fromRGB( 90, 220, 255),
    salve_ice       = Color3.fromRGB(205, 240, 255),
    charm_frost     = Color3.fromRGB(110, 150, 200),
}

for _, id in ipairs(ITEMS) do
    local existing = ItemModels:FindFirstChild(id)
    if existing then existing:Destroy() end

    local model = Instance.new("Model")
    model.Name = id

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(1.6, 1.6, 1.6)
    body.Color = PALETTE[id] or Color3.fromRGB(200, 200, 200)
    body.Material = Enum.Material.SmoothPlastic
    body.Anchored = true
    body.CanCollide = false
    body.TopSurface = Enum.SurfaceType.Smooth
    body.BottomSurface = Enum.SurfaceType.Smooth
    body.Parent = model
    model.PrimaryPart = body

    -- attachment used by the UI camera for consistent framing
    local pivot = Instance.new("Attachment")
    pivot.Name = "IconPivot"
    pivot.Position = Vector3.new(0, 0.6, 0)
    pivot.Parent = body

    -- soft point light so thumbnails read on light/dark themes
    local lamp = Instance.new("PointLight")
    lamp.Range = 12
    lamp.Brightness = 2
    lamp.Parent = body

    model.Parent = ItemModels
end

print("✅ Generated placeholder ItemModels under ReplicatedStorage/Assets/ItemModels")