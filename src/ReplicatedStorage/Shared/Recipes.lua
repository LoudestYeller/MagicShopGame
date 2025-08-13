local RS = game:GetService("ReplicatedStorage")
local Items = require(RS.Shared.Items)

local Recipes = {}

local function keyFor(inputs)
  local t = {}
  for _,i in ipairs(inputs or {}) do
    for k=1,(i.qty or 1) do table.insert(t, i.id) end
  end
  table.sort(t)
  return table.concat(t, "+")
end

local MAP = {
  ["beast_fat+ember_shard"]       = {id="potion_healing", station="PotionBench"},
  ["frostleaf+glowing_mushroom"]  = {id="potion_healing", station="PotionBench"},
  ["crystal_flower+shadow_moss"]  = {id="salve_ice",      station="Enchanter"},
}

function Recipes.Combine(inputs, station, tier)
  local k = keyFor(inputs)
  local e = MAP[k]
  if e and (not e.station or e.station == station) then
    return {id = e.id}
  end
  return nil
end

return Recipes