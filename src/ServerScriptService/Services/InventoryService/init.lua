--!strict
local SSS = game:GetService("ServerScriptService")
local Services = SSS:WaitForChild("Services")
local DataServiceModule = Services:WaitForChild("DataService")
local DataService = require(DataServiceModule:IsA("ModuleScript") and DataServiceModule or DataServiceModule:WaitForChild("init"))

local InventoryService = {}

-- Module-level service references
local TutorialService = nil

-- Optional lifecycle for ServiceLoader (safe no-ops)
function InventoryService.Init(self, ctx) 
    self._ctx = ctx
    if ctx and ctx.GetService then
        TutorialService = ctx:GetService("TutorialService")
    end
end
function InventoryService.Start(self) end

local function addItem(player: Player, itemId: string, qty: number)
    assert(player and player:IsA("Player"), "player must be a Player")
    assert(type(itemId) == "string", "itemId must be a string")
    qty = math.max(1, qty or 1)
    -- ✅ correct order
    DataService:AddItem(player, itemId, qty)
end

function InventoryService.Add(player: Player, itemId: string, qty: number)
    addItem(player, itemId, qty)
    -- Track tutorial progress (gathering)
    if TutorialService then
        TutorialService:TrackGather(player)
    end
end

-- Helpers if you need them elsewhere
function InventoryService:Get(player: Player)
    return DataService:Get(player)
end

function InventoryService:Remove(player: Player, itemId: string, qty: number): boolean
    return DataService:RemoveItem(player, itemId, qty)
end

return InventoryService