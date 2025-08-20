-- ServerScriptService/Services/CraftingService.lua
-- v1.1 — remote stubs so clients never hang on RequestCraft/ToggleCrafting
local RS = game:GetService("ReplicatedStorage")
local Networking = RS:WaitForChild("Networking")

local CraftingService = { Name = "CraftingService" }

function CraftingService:Init()
    self._evToggle  = Networking:WaitForChild("ToggleCrafting")  :: RemoteEvent
    self._evState   = Networking:WaitForChild("CraftingState")   :: RemoteEvent
    self._fnRequest = Networking:WaitForChild("RequestCraft")    :: RemoteFunction
    print("[CraftingService v1.1] Init")
end

function CraftingService:Start()
    self._fnRequest.OnServerInvoke = function(player, recipeId, inputs)
        -- Minimal stub to unblock UI; replace with real crafting later
        return { ok = true, outItem = "potion_healing", qty = 1, reason = "stub" }
    end
end

return CraftingService