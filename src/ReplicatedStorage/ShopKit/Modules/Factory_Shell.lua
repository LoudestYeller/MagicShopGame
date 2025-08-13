local M = {}

local function part(name, size, cf, color)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.Anchored = true
    p.Material = Enum.Material.Slate
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    return p
end

local function socket(name, parent, cf)
    local a = Instance.new("Attachment")
    a.Name = name
    a.CFrame = cf
    a.Parent = parent
    return a
end

function M.Build()
    local model = Instance.new("Model")
    model.Name = "ShopShell_v1"

    local W, D, H = 56, 36, 18
    local floor = part("Floor", Vector3.new(W,1,D), CFrame.new(0,0,0), Color3.fromRGB(76,66,54))
    local ceiling = part("Ceiling", Vector3.new(W,1,D), CFrame.new(0,H,0), Color3.fromRGB(60,60,60))
    local wallF = part("Wall_Front", Vector3.new(W,H,1), CFrame.new(0,H/2, D/2), Color3.fromRGB(80,70,65))
    local wallB = part("Wall_Back",  Vector3.new(W,H,1), CFrame.new(0,H/2,-D/2), Color3.fromRGB(80,70,65))
    local wallL = part("Wall_Left",  Vector3.new(1,H,D), CFrame.new(-W/2,H/2,0), Color3.fromRGB(80,70,65))
    local wallR = part("Wall_Right", Vector3.new(1,H,D), CFrame.new( W/2,H/2,0), Color3.fromRGB(80,70,65))

    -- Door opening on front wall (simple visual gap)
    wallF.Size = Vector3.new(W, H, 1)
    -- (Optional: actually cut a hole with separate parts; we'll skip for placeholder)

    floor.Parent = model
    ceiling.Parent = model
    wallF.Parent = model
    wallB.Parent = model
    wallL.Parent = model
    wallR.Parent = model

    model.PrimaryPart = floor

    -- SOCKETS (+Z outward)
    socket("Socket:Counter_Main",  floor, CFrame.new( 16, 0, 10))        -- front-right area
    socket("Socket:Crafting_Main", floor, CFrame.new(-16, 0,-10))        -- back-left area
    socket("Socket:Decor_Wall_Front_L", wallF, CFrame.new(-18, 8, 0))
    socket("Socket:Decor_Wall_Front_R", wallF, CFrame.new( 18, 8, 0))
    socket("Socket:Decor_Wall_Back_L",  wallB, CFrame.new(-18, 8, 0))
    socket("Socket:Decor_Wall_Back_R",  wallB, CFrame.new( 18, 8, 0))
    socket("Socket:Expansion_Left",  floor, CFrame.new(-W/2 - 2, 0, 0))
    socket("Socket:Expansion_Right", floor, CFrame.new( W/2 + 2, 0, 0))
    socket("Socket:Expansion_Back",  floor, CFrame.new( 0, 0, -D/2 - 2))
    socket("Socket:Display_Window_1", wallF, CFrame.new(0, 5, 0))

    model:SetAttribute("OwnerId", 0)
    return model
end

return M