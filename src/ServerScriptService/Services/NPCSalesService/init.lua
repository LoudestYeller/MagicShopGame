local RS  = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local DataService        = require(SSS.Services.DataService.init)
local InventoryService   = require(SSS.Services.InventoryService.init)
local DisplayCaseService = require(SSS.Services.DisplayCaseService.init)
local Networking         = RS:WaitForChild("Networking")
local Guard              = require(SSS.Lib.Guard)

local NPCSalesService = { Name = "NPCSalesService", _running = false }

function NPCSalesService:Init()
  self.Data      = DataService
  self.Inventory = InventoryService
  self.Display   = DisplayCaseService
  self.Remotes   = Networking
  print("[NPCSalesService] Init")
end

local function try(fn, ...)
  local ok, err = pcall(fn, ...)
  if not ok then warn("[NPCSalesService] loop error:", err) end
end

-- example safe op (stub your real logic here)
function NPCSalesService:AttemptAutoPurchase()
  if not self.Data or not self.Inventory or not self.Display then return end
  -- do nothing if player list empty etc…
end

function NPCSalesService:Start()
  print("[NPCSalesService] Start")
  self._running = true
  Guard.loop("NPCSales", function() self:AttemptAutoPurchase() end, 10)
end

return NPCSalesService