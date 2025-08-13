local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(plr)
    local ps = plr:WaitForChild("PlayerScripts", 10)
    if not ps then return end
    local client = ps:FindFirstChild("Client")
    local stray = ps:FindFirstChild("ShelfClient")
    if stray and client and client:FindFirstChild("ShelfClient") then
        warn("[Cleanup] Removing stray ShelfClient at PlayerScripts root")
        stray:Destroy()
    end
end)