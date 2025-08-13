local RS = game:GetService("ReplicatedStorage")
local Items = require(RS.Shared.Items)

local Contracts = {}

function Contracts.assertId(id)
  assert(type(id)=="string", "id must be string")
  assert(id:match("^[a-z0-9_]+$"), "id must be snake_case")
  assert(Items[id] ~= nil, ("unknown item id: %s"):format(id))
end

return Contracts