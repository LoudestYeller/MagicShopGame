local Players = game:GetService("Players")
local PlayerUtil = {}
function PlayerUtil.toPlayer(x)
    if typeof(x) ~= "Instance" then return nil end
    if x.ClassName == "Player" then return x end
    local m = x:FindFirstAncestorOfClass("Model") or x
    return Players:GetPlayerFromCharacter(m)
end
return PlayerUtil