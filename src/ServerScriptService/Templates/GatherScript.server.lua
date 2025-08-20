local SSS = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local InventoryService = require(SSS.Services:WaitForChild("InventoryService"))

local function canonicalId(model)
  local a = model:GetAttribute("ItemId"); if a and a ~= "" then return a end
  local base = (model.Name:gsub("_Node$","")); return (base:gsub("%s+","_"):lower())
end

local function award(triggerer)
  local plr = triggerer
  if not plr:IsA("Player") then plr = Players:GetPlayerFromCharacter(triggerer) end
  if not plr then return end
  InventoryService:Add(plr, canonicalId(script.Parent), 1)
end

local prompt = script.Parent:FindFirstChildOfClass("ProximityPrompt")
if prompt then prompt.Triggered:Connect(award)
else local click = script.Parent:FindFirstChildOfClass("ClickDetector"); if click then click.MouseClick:Connect(award) end end