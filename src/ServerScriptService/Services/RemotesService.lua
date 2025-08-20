-- ServerScriptService/Services/RemotesService.lua
-- v1.1 — freezes remote schema to match clients exactly
local RS = game:GetService("ReplicatedStorage")

local RemotesService = { Name = "RemotesService" }

local MANIFEST = {
    Events    = { "InventoryUpdated", "ToggleCrafting", "CraftingState", "DisplayCaseUpdated", "DevGive" },
    Functions = { "InventorySnapshot", "DisplayCaseRequest", "RequestCraft" },
}

local function ensure(folder: Instance, name: string, className: string)
    local inst = folder:FindFirstChild(name)
    if inst and inst.ClassName ~= className then inst:Destroy(); inst = nil end
    if not inst then
        inst = Instance.new(className)
        inst.Name = name
        inst.Parent = folder
    end
    return inst
end

function RemotesService:Init()
    local networking = RS:FindFirstChild("Networking") or Instance.new("Folder")
    networking.Name = "Networking"
    networking.Parent = RS
    for _, n in ipairs(MANIFEST.Events) do ensure(networking, n, "RemoteEvent") end
    for _, n in ipairs(MANIFEST.Functions) do ensure(networking, n, "RemoteFunction") end
    print(("[RemotesService] All remotes ensured (%d events, %d functions)"):format(#MANIFEST.Events, #MANIFEST.Functions))
end

function RemotesService:Start() end

return RemotesService