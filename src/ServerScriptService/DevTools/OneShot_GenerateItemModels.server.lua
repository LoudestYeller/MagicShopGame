-- ServerScriptService/DevTools/OneShot_GenerateItemModels.server.lua
-- One-shot generator: builds placeholder models for item icons.
-- Studio-only; disables itself after success.

-- ✅ Requirements this generator guarantees:
--  - ReplicatedStorage/ItemModels folder exists
--  - Each model is named by snake_case id (e.g., "glowing_mushroom")
--  - Model has PrimaryPart
--  - Model has Attachment named "IconPivot" for Viewport framing
--  - Parts are anchored; materials & base colors set
--  - Safe to re-run (skips existing models), and then script disables itself

local RUN_ONCE_FLAG = "ItemModelsGenerated"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Create/locate folders
local ItemModels = ReplicatedStorage:FindFirstChild("ItemModels") or Instance.new("Folder")
ItemModels.Name = "ItemModels"
ItemModels.Parent = ReplicatedStorage

-- If we already generated once and all targets exist, disable self.
local function allExist(names)
    for _, n in ipairs(names) do
        if not ItemModels:FindFirstChild(n) then
            return false
        end
    end
    return true
end

-- 🧾 Items we will generate
local TARGETS = {
    "glowing_mushroom",
    "shadow_moss",
    "frostleaf",
    "crystal_flower",
    "ember_shard",
    "beast_fat",
    "potion_healing",
    "potion_frostward",
    "salve_ice",
    "charm_frost",
}

if allExist(TARGETS) then
    warn("[ModelGen] All item models already exist; disabling.")
    script.Disabled = true
    return
end

-- 🎨 Palette helpers
local Palette = {
    stone  = Color3.fromRGB(120, 130, 150),
    leaf   = Color3.fromRGB(76, 160, 110),
    moss   = Color3.fromRGB(50, 90, 70),
    mush   = Color3.fromRGB(235, 85, 110),
    stem   = Color3.fromRGB(235, 220, 200),
    ice    = Color3.fromRGB(150, 190, 255),
    cryst  = Color3.fromRGB(145, 100, 255),
    ember  = Color3.fromRGB(255, 90, 70),
    fat    = Color3.fromRGB(255, 240, 190),
    glass  = Color3.fromRGB(210, 230, 255),
    gem    = Color3.fromRGB(90, 220, 255),
    metal  = Color3.fromRGB(200, 210, 220),
}

-- 🔧 Part helpers
local function part(name, size, color, parent, shape) -- shape: "Block"|"Ball"|"Cylinder"
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.CanCollide = false
    p.CastShadow = false
    p.Size = size or Vector3.new(1,1,1)
    p.Color = color or Palette.stone
    p.Material = Enum.Material.SmoothPlastic
    if shape == "Ball" then p.Shape = Enum.PartType.Ball end
    if shape == "Cylinder" then p.Shape = Enum.PartType.Cylinder end
    p.Parent = parent
    return p
end

local function wedge(name, size, color, parent)
    local w = Instance.new("WedgePart")
    w.Name = name
    w.Anchored = true
    w.CanCollide = false
    w.CastShadow = false
    w.Size = size or Vector3.new(1,1,1)
    w.Color = color or Palette.stone
    w.Material = Enum.Material.SmoothPlastic
    w.Parent = parent
    return w
end

local function neonize(p)
    p.Material = Enum.Material.Neon
    return p
end

local function glass(p, transparency)
    p.Material = Enum.Material.Glass
    p.Transparency = transparency or 0.25
    p.Color = Palette.glass
    return p
end

-- 📐 Model helper
local function finalizeModel(model: Model, primary: BasePart)
    model.PrimaryPart = primary
    -- Center model around origin for consistent viewport framing
    -- (We assume we placed parts near 0; nothing fancy here.)

    -- Compute bbox to offset IconPivot a touch above center
    local _, size = model:GetBoundingBox()
    local iconPivot = Instance.new("Attachment")
    iconPivot.Name = "IconPivot"
    iconPivot.Position = Vector3.new(0, size.Y * 0.15, 0) -- slight upward bias
    iconPivot.Parent = primary
    return model
end

local function mkModel(name, builderFn)
    if ItemModels:FindFirstChild(name) then
        print(("[-] %s exists; skipping"):format(name))
        return
    end
    local m = Instance.new("Model")
    m.Name = name
    builderFn(m)
    m.Parent = ItemModels
    print(("[+] Generated %s"):format(name))
end

-- ==========================
-- 🧱 Builders per item
-- ==========================

-- 1) glowing_mushroom (stem + cap)
mkModel("glowing_mushroom", function(m)
    local stem = part("Stem", Vector3.new(0.5, 1.7, 0.5), Palette.stem, m, "Cylinder")
    stem.CFrame = CFrame.new(0, 0.85, 0) * CFrame.Angles(0, 0, math.rad(0))

    local cap = part("Cap", Vector3.new(2.0, 1.0, 2.0), Palette.mush, m, "Ball")
    cap.CFrame = CFrame.new(0, 1.7, 0)

    -- tiny glow on cap
    local glow = part("Glow", Vector3.new(1.6, 0.8, 1.6), Palette.mush, m, "Ball")
    neonize(glow)
    glow.Transparency = 0.2
    glow.CFrame = CFrame.new(0, 1.7, 0)

    finalizeModel(m, stem)
end)

-- 2) shadow_moss (low clump)
mkModel("shadow_moss", function(m)
    for i=1,4 do
        local bump = part("Bump"..i, Vector3.new(0.9, 0.5, 0.9), Palette.moss, m, "Ball")
        bump.CFrame = CFrame.new((i-2.5)*0.5, 0.25, ((i%2==0) and 0.4 or -0.4))
    end
    finalizeModel(m, m:FindFirstChild("Bump1"))
end)

-- 3) frostleaf (flat, icey leaf)
mkModel("frostleaf", function(m)
    local base = wedge("Leaf", Vector3.new(2.4, 0.2, 1.2), Palette.ice, m)
    base.CFrame = CFrame.new(0, 0.1, 0) * CFrame.Angles(0, math.rad(25), 0)
    finalizeModel(m, base)
end)

-- 4) crystal_flower (clustered shards)
mkModel("crystal_flower", function(m)
    for i=1,5 do
        local shard = wedge("Shard"..i, Vector3.new(0.4, 1.6, 0.6), Palette.cryst, m)
        neonize(shard)
        local ang = math.rad((i-1) * 72)
        shard.CFrame = CFrame.new(math.cos(ang)*0.35, 0.8, math.sin(ang)*0.35)
            * CFrame.Angles(0, ang, math.rad(-20))
    end
    finalizeModel(m, m:FindFirstChild("Shard1"))
end)

-- 5) ember_shard (jagged neon shard)
mkModel("ember_shard", function(m)
    local core = wedge("Core", Vector3.new(0.6, 1.8, 0.6), Palette.ember, m)
    neonize(core)
    core.CFrame = CFrame.new(0, 0.9, 0) * CFrame.Angles(math.rad(-15), math.rad(20), 0)
    local chip = wedge("Chip", Vector3.new(0.3, 0.8, 0.3), Palette.ember, m)
    neonize(chip)
    chip.CFrame = CFrame.new(0.25, 0.4, -0.15) * CFrame.Angles(0, math.rad(40), math.rad(10))
    finalizeModel(m, core)
end)

-- 6) beast_fat (soft blob)
mkModel("beast_fat", function(m)
    local a = part("BlobA", Vector3.new(1.1, 0.9, 1.1), Palette.fat, m, "Ball")
    a.CFrame = CFrame.new(-0.25, 0.45, 0)
    local b = part("BlobB", Vector3.new(1.0, 0.7, 1.0), Palette.fat, m, "Ball")
    b.CFrame = CFrame.new(0.35, 0.35, -0.1)
    finalizeModel(m, a)
end)

-- 7) potion_healing (simple bottle + red liquid)
mkModel("potion_healing", function(m)
    local bottle = part("Bottle", Vector3.new(1.4, 2.2, 1.4), Palette.glass, m, "Cylinder")
    glass(bottle, 0.35)
    bottle.CFrame = CFrame.new(0, 1.1, 0)

    local neck = part("Neck", Vector3.new(0.6, 0.5, 0.6), Palette.glass, m, "Cylinder")
    glass(neck, 0.35)
    neck.CFrame = CFrame.new(0, 2.1, 0)

    local liquid = part("Liquid", Vector3.new(1.2, 1.1, 1.2), Palette.ember, m, "Cylinder")
    liquid.CFrame = CFrame.new(0, 0.65, 0)

    finalizeModel(m, bottle)
end)

-- 8) potion_frostward (blue liquid)
mkModel("potion_frostward", function(m)
    local bottle = part("Bottle", Vector3.new(1.4, 2.2, 1.4), Palette.glass, m, "Cylinder")
    glass(bottle, 0.35)
    bottle.CFrame = CFrame.new(0, 1.1, 0)

    local neck = part("Neck", Vector3.new(0.6, 0.5, 0.6), Palette.glass, m, "Cylinder")
    glass(neck, 0.35)
    neck.CFrame = CFrame.new(0, 2.1, 0)

    local liquid = part("Liquid", Vector3.new(1.2, 1.1, 1.2), Palette.ice, m, "Cylinder")
    liquid.CFrame = CFrame.new(0, 0.65, 0)

    finalizeModel(m, bottle)
end)

-- 9) salve_ice (low jar + fill)
mkModel("salve_ice", function(m)
    local jar = part("Jar", Vector3.new(1.8, 1.2, 1.8), Palette.glass, m, "Cylinder")
    glass(jar, 0.45)
    jar.CFrame = CFrame.new(0, 0.6, 0)

    local fill = part("Fill", Vector3.new(1.6, 0.6, 1.6), Palette.ice, m, "Cylinder")
    fill.CFrame = CFrame.new(0, 0.4, 0)

    finalizeModel(m, jar)
end)

-- 10) charm_frost (medallion + gem)
mkModel("charm_frost", function(m)
    local disc = part("Disc", Vector3.new(1.8, 0.25, 1.8), Palette.metal, m, "Cylinder")
    disc.CFrame = CFrame.new(0, 0.13, 0)

    local gem = part("Gem", Vector3.new(0.8, 0.4, 0.8), Palette.gem, m, "Ball")
    neonize(gem)
    gem.CFrame = CFrame.new(0, 0.35, 0)

    finalizeModel(m, disc)
end)

print("[ModelGen] Generation complete.")
-- Disable the script so it won't run next Studio session.
script.Disabled = true