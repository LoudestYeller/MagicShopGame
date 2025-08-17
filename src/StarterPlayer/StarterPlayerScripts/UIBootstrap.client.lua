local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local function getOrCreateFromRS(guiName: string): ScreenGui?
    local sg = RS:FindFirstChild(guiName)
    if sg and sg:IsA("ScreenGui") then
        return sg
    end
    -- self-heal: create a placeholder so we never break
    local placeholder = Instance.new("ScreenGui")
    placeholder.Name = guiName
    placeholder.ResetOnSpawn = false
    placeholder.IgnoreGuiInset = true
    placeholder.Parent = RS

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 520, 0, 42)
    lbl.Position = UDim2.new(0.5, -260, 0, 10)
    lbl.BackgroundTransparency = 0.25
    lbl.TextScaled = true
    lbl.Text = guiName .. " (placeholder)"
    lbl.Parent = placeholder

    warn(("[UIBootstrap] %s missing; created placeholder in ReplicatedStorage"):format(guiName))
    return placeholder
end

local function mountOne(preferred, alternates)
    -- prefer an existing ScreenGui in PlayerGui
    local gui = PlayerGui:FindFirstChild(preferred)
    if not gui then
        -- get or create ScreenGui from ReplicatedStorage
        local src = getOrCreateFromRS(preferred)
        if src then
            gui = src:Clone()
            gui.Enabled = false
            gui.ResetOnSpawn = false
            gui.Parent = PlayerGui
        end
    end
    -- disable alternates so openers don't race
    for _,alt in ipairs(alternates) do
        local a = PlayerGui:FindFirstChild(alt) or RS:FindFirstChild(alt)
        if a and a:IsA("ScreenGui") then
            if a.Parent ~= PlayerGui then
                a = a:Clone(); a.Parent = PlayerGui
            end
            a.Enabled = false
            a.Name = alt .. "_Disabled"
        end
    end
    if gui then
        print(("[UIBootstrap] Mounted %s (Enabled=%s)"):format(gui.Name, tostring(gui.Enabled)))
    else
        warn("[UIBootstrap] Missing ScreenGui: " .. preferred)
    end
    return gui
end

local displayGui = mountOne("DisplayUI", {"DisplayCaseUI"})
local craftingGui = mountOne("CraftingUI", {"Crafting"})

print("🎮 [UIBootstrap] UI setup complete")