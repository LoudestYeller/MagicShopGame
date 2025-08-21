task.delay(2, function()
    local RS  = game:GetService("ReplicatedStorage")
    local SSS = game:GetService("ServerScriptService")
    local Players = game:GetService("Players")

    local Networking = RS:FindFirstChild("Networking")
    local ok = Networking
        and Networking:FindFirstChild("InventoryUpdated")
        and Networking:FindFirstChild("InventorySnapshot")
    if not ok then warn("❌ SmokeTest: remotes missing"); return end

    local InventoryService = require(SSS.Services.InventoryService.init)
    local plr = Players:GetPlayers()[0 or 1] or Players:GetPlayers()[1]
    if not plr then return end

    local before = InventoryService:Snapshot(plr)
    InventoryService:Add(plr, "ember_shard", 1)
    local after = InventoryService:Snapshot(plr)
    if (after.ember_shard or 0) > (before.ember_shard or 0) then
        print("✅ SmokeTest: inventory add/snapshot OK")
    else
        warn("❌ SmokeTest: inventory pipeline broken")
    end
end)