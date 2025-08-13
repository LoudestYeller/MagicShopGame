-- Temporary test script to manually spawn a shop
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Simple shop builder (inline for testing)
local function buildTestShop()
    local model = Instance.new("Model")
    model.Name = "TestShop"
    
    -- Simple room
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(56, 1, 36)
    floor.Position = Vector3.new(0, 0, 0)
    floor.Anchored = true
    floor.Color = Color3.fromRGB(76, 66, 54)
    floor.Material = Enum.Material.Slate
    floor.Parent = model
    
    -- Walls
    local frontWall = Instance.new("Part")
    frontWall.Name = "FrontWall"
    frontWall.Size = Vector3.new(56, 18, 1)
    frontWall.Position = Vector3.new(0, 9, 18)
    frontWall.Anchored = true
    frontWall.Color = Color3.fromRGB(80, 70, 65)
    frontWall.Material = Enum.Material.Slate
    frontWall.Parent = model
    
    local backWall = Instance.new("Part")
    backWall.Name = "BackWall"
    backWall.Size = Vector3.new(56, 18, 1)
    backWall.Position = Vector3.new(0, 9, -18)
    backWall.Anchored = true
    backWall.Color = Color3.fromRGB(80, 70, 65)
    backWall.Material = Enum.Material.Slate
    backWall.Parent = model
    
    local leftWall = Instance.new("Part")
    leftWall.Name = "LeftWall"
    leftWall.Size = Vector3.new(1, 18, 36)
    leftWall.Position = Vector3.new(-28, 9, 0)
    leftWall.Anchored = true
    leftWall.Color = Color3.fromRGB(80, 70, 65)
    leftWall.Material = Enum.Material.Slate
    leftWall.Parent = model
    
    local rightWall = Instance.new("Part")
    rightWall.Name = "RightWall"
    rightWall.Size = Vector3.new(1, 18, 36)
    rightWall.Position = Vector3.new(28, 9, 0)
    rightWall.Anchored = true
    rightWall.Color = Color3.fromRGB(80, 70, 65)
    rightWall.Material = Enum.Material.Slate
    rightWall.Parent = model
    
    -- Ceiling
    local ceiling = Instance.new("Part")
    ceiling.Name = "Ceiling"
    ceiling.Size = Vector3.new(56, 1, 36)
    ceiling.Position = Vector3.new(0, 18, 0)
    ceiling.Anchored = true
    ceiling.Color = Color3.fromRGB(60, 60, 60)
    ceiling.Material = Enum.Material.Slate
    ceiling.Parent = model
    
    model.PrimaryPart = floor
    return model
end

local function addDisplayCounter(shop)
    local counter = Instance.new("Model")
    counter.Name = "DisplayCounter"
    counter:SetAttribute("StationType", "DisplayCounter")
    
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(12, 4, 3)
    base.Position = Vector3.new(16, 2, 10)  -- front-right area
    base.Anchored = true
    base.Color = Color3.fromRGB(95, 80, 72)
    base.Material = Enum.Material.Wood
    base.Parent = counter
    
    local glass = Instance.new("Part")
    glass.Name = "Glass"
    glass.Size = Vector3.new(12, 2, 0.2)
    glass.Position = Vector3.new(16, 5, 8.6)
    glass.Anchored = true
    glass.Transparency = 0.5
    glass.Color = Color3.fromRGB(200, 200, 200)
    glass.Material = Enum.Material.Glass
    glass.Parent = counter
    
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Browse Goods"
    prompt.ObjectText = "Display Counter"
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12
    prompt.Parent = base
    
    counter.PrimaryPart = base
    counter.Parent = shop
    return counter
end

local function addCraftingBench(shop)
    local bench = Instance.new("Model")
    bench.Name = "CraftingBench"
    bench:SetAttribute("StationType", "Crafting")
    
    local table = Instance.new("Part")
    table.Name = "Table"
    table.Size = Vector3.new(8, 3, 4)
    table.Position = Vector3.new(-16, 1.5, -10)  -- back-left area
    table.Anchored = true
    table.Color = Color3.fromRGB(85, 72, 60)
    table.Material = Enum.Material.WoodPlanks
    table.Parent = bench
    
    local cauldron = Instance.new("Part")
    cauldron.Name = "Cauldron"
    cauldron.Shape = Enum.PartType.Cylinder
    cauldron.Size = Vector3.new(3, 2, 3)
    cauldron.Position = Vector3.new(-16, 4, -10)
    cauldron.Anchored = true
    cauldron.Color = Color3.fromRGB(40, 40, 40)
    cauldron.Material = Enum.Material.Metal
    cauldron.Parent = bench
    
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Craft Potions"
    prompt.ObjectText = "Potion Bench"
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 12
    prompt.Parent = table
    
    bench.PrimaryPart = table
    bench.Parent = shop
    return bench
end

-- Spawn shop when player joins
local function spawnTestShop(player)
    print(("[TestShopSpawn] Creating test shop for %s"):format(player.Name))
    
    local shop = buildTestShop()
    addDisplayCounter(shop)
    addCraftingBench(shop)
    
    shop.Parent = workspace
    shop:MoveTo(Vector3.new(0, 1, 0))
    
    print(("[TestShopSpawn] Test shop spawned at origin"):format())
end

-- Connect to players joining
Players.PlayerAdded:Connect(spawnTestShop)

-- Also spawn for existing players
for _, player in pairs(Players:GetPlayers()) do
    spawnTestShop(player)
end

print("[TestShopSpawn] Test shop spawner ready")