-- ReplicatedStorage/Client/UI/IconHelper.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local M = {}

local Assets = ReplicatedStorage:WaitForChild("Assets")
local ItemModels = Assets:WaitForChild("ItemModels")

local function itemIdFromName(name: string): string
    return name:lower():gsub("%s+", "_")
end

function M.setViewportIcon(vpf: ViewportFrame, itemName: string)
    if not vpf then return end
    vpf:ClearAllChildren()

    local camera = Instance.new("Camera")
    camera.Parent = vpf
    vpf.CurrentCamera = camera

    local id = itemIdFromName(itemName)
    local src = ItemModels:FindFirstChild(id)
    if not src then
        warn(("[IconHelper] Missing ItemModel for %s (%s)"):format(itemName, id))
        return
    end

    local clone = src:Clone()
    clone.Parent = vpf

    local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
    if not primary then return end

    local pivot = primary:FindFirstChild("IconPivot")
    local focusPos = pivot and pivot.WorldPosition or clone:GetPivot().Position

    -- Simple 3/4 camera view
    camera.CFrame = CFrame.new(focusPos + Vector3.new(2.2, 1.3, 2.2), focusPos)
end

return M