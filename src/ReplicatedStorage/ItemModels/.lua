-- Model: charm_frost
local model = Instance.new('Model')
model.Name = 'charm_frost'

local part = Instance.new('Part')
part.Name = 'PrimaryPart'
part.Size = Vector3.new(2, 2, 2)
part.Color = Color3.fromRGB(255,255,100)
part.Material = Enum.Material.Neon
part.Anchored = true
part.Parent = model
model.PrimaryPart = part

local attachment = Instance.new('Attachment')
attachment.Name = 'IconPivot'
attachment.CFrame = CFrame.new(0, 0, 0)
attachment.Parent = part

local light = Instance.new('PointLight')
light.Brightness = 1.5
light.Range = 8
light.Color = Color3.fromRGB(255,255,100)
light.Parent = part

return model
