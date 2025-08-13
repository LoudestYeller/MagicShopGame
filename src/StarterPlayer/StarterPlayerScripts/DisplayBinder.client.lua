local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.RemotesIndex)

local function tryBind(inst)
    if not inst:IsA("ProximityPrompt") then return end
    local part = inst.Parent
    local model = part and part.Parent
    if not (model and model:IsA("Model")) then return end

    if model:GetAttribute("StationType") == "DisplayCounter" or model.Name == "DisplayCounter" then
        print(("[DisplayBinder] Binding prompt for %s"):format(model.Name))
        inst.Triggered:Connect(function(player)
            print(("[DisplayBinder] %s activated display counter"):format(player.Name))
            Remotes.ToggleDisplayCase:FireServer()
        end)
    end
end

for _, d in ipairs(workspace:GetDescendants()) do tryBind(d) end
workspace.DescendantAdded:Connect(tryBind)

print("[DisplayBinder] Client binder loaded")