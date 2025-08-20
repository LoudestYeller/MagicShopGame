-- ReplicatedStorage/Shared/UI/ViewportIcon.lua
-- Creates a 3D icon inside a ViewportFrame using an item model.
-- Requires each model to have an Attachment named 'IconPivot' for framing.
-- Falls back to a generic placeholder if model missing.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemModels = ReplicatedStorage:FindFirstChild("ItemModels") -- Folder you (Claude) will create
local RunService = game:GetService("RunService")

local ViewportIcon = {}

local function cloneModelByName(name)
    if not ItemModels then return nil end
    local src = ItemModels:FindFirstChild(name)
    return src and src:Clone() or nil
end

local function ensureCamera(vp: ViewportFrame, pivotCFrame: CFrame, size: Vector3)
    local cam = Instance.new("Camera")
    cam.CFrame = pivotCFrame * CFrame.new(0, 0, size.Magnitude * 1.8) * CFrame.Angles(0, math.rad(180), 0)
    vp.CurrentCamera = cam
    cam.Parent = vp
end

function ViewportIcon.Populate(vp: ViewportFrame, modelName: string)
    vp:ClearAllChildren()

    local model = cloneModelByName(modelName)
    if not model then
        -- fallback placeholder
        local cube = Instance.new("Part")
        cube.Size = Vector3.new(1.5, 1.5, 1.5)
        cube.Color = Color3.fromRGB(90, 100, 120)
        cube.Material = Enum.Material.SmoothPlastic
        cube.Anchored = true
        cube.Name = "Placeholder"
        model = Instance.new("Model")
        cube.Parent = model
        model.PrimaryPart = cube
    else
        model.PrimaryPart = model:FindFirstChild("PrimaryPart") or model.PrimaryPart
        if not model.PrimaryPart then
            -- pick first BasePart
            for _,d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") then model.PrimaryPart = d; break end
            end
        end
    end

    model.Parent = vp
    local pivot = model.PrimaryPart and model.PrimaryPart.CFrame or CFrame.new()
    local iconPivot = model:FindFirstChild("IconPivot", true)
    if iconPivot and iconPivot:IsA("Attachment") then
        pivot = iconPivot.WorldCFrame
    end

    local _, size = model:GetBoundingBox()
    ensureCamera(vp, pivot, size)

    -- lighting
    local light = Instance.new("WorldModel")
    light.Parent = vp
    local sun = Instance.new("PointLight")
    sun.Brightness, sun.Range = 2, 16
    sun.Parent = model.PrimaryPart or model
end

return ViewportIcon