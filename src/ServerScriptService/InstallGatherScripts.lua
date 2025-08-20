-- ServerScriptService/InstallGatherScripts.lua
-- v1.2 — attaches/maintains GatherScript on ANY *_Node models (even if they spawn later)
local SSS = game:GetService("ServerScriptService")
local WS  = workspace

local function canonicalId(model: Instance)
    local m = model
    if m and m:GetAttribute("ItemId") then
        local a = m:GetAttribute("ItemId")
        if type(a) == "string" and a ~= "" then return a end
    end
    local base = m.Name:gsub("_Node$", "")
    return (base:gsub("%s+", "_"):lower())
end

local GATHER_SOURCE = [[
local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local InventoryService = require(SSS.Services:WaitForChild("InventoryService"))

local function canonicalId(model)
    local a = model:GetAttribute("ItemId")
    if a and a ~= "" then return a end
    local base = (model.Name:gsub("_Node$",""))
    return (base:gsub("%s+","_"):lower())
end

local function award(triggerer)
    local plr = triggerer
    if not plr:IsA("Player") then
        plr = Players:GetPlayerFromCharacter(triggerer)
    end
    if not plr then return end
    local id = canonicalId(script.Parent)
    InventoryService:Add(plr, id, 1)
    print(("🌿 %s gathered %s"):format(plr.Name, id))
end

local prompt = script.Parent:FindFirstChildOfClass("ProximityPrompt")
if prompt then
    prompt.Triggered:Connect(award)
else
    local click = script.Parent:FindFirstChildOfClass("ClickDetector")
    if click then click.MouseClick:Connect(award) end
end
]]

local function attachGather(model: Instance)
    if not (model:IsA("Model") and model.Name:match("_Node$")) then return false end
    local s = model:FindFirstChild("GatherScript")
    if not s or not s:IsA("Script") then
        if s then s:Destroy() end
        s = Instance.new("Script")
        s.Name = "GatherScript"
        s.Parent = model
    end
    s.Source = GATHER_SOURCE
    if not model:GetAttribute("ItemId") then
        model:SetAttribute("ItemId", canonicalId(model))
    end
    return true
end

local count = 0
for _, d in ipairs(WS:GetDescendants()) do
    if attachGather(d) then count += 1 end
end
print(("[Installer] GatherScript attached to %d nodes"):format(count))

-- keep future spawns patched too
WS.DescendantAdded:Connect(function(d)
    attachGather(d)
end)