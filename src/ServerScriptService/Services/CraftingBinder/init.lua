--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local CraftingBinder = {}

local COOLDOWN = 0.75
local lastUse = {}

local function benchCategoryFrom(model: Instance): string
    -- By convention: CraftingBench_Potion / _Wand / _Talisman
    local n = model.Name:lower()
    if n:find("potion") then return "potion" end
    if n:find("wand") then return "wand" end
    if n:find("talisman") then return "talisman" end
    -- Fallback to attribute BenchType = "potion"/"wand"/"talisman"
    return (model:GetAttribute("BenchType") or "potion"):lower()
end

local function ensurePrompt(model: Model)
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)
        if not primary then return end
        prompt = Instance.new("ProximityPrompt")
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 10
        prompt.Parent = primary
    end
    local cat = benchCategoryFrom(model)
    prompt.ActionText = "Craft"
    prompt.ObjectText = (cat:gsub("^%l", string.upper)) .. " Bench"
    return prompt, cat
end

function CraftingBinder.Init(services)
    local RS = game:GetService("ReplicatedStorage")
    local Net = RS:WaitForChild("Networking")
    
    CraftingBinder.CraftingState = Net:WaitForChild("CraftingState")
    return true
end

function CraftingBinder:bindBench(model: Model)
    local prompt, cat = ensurePrompt(model)
    if not prompt then return end

    prompt.Triggered:Connect(function(player: Player)
        local now = os.clock()
        if lastUse[player] and (now - lastUse[player]) < COOLDOWN then return end
        lastUse[player] = now

        -- Send the "open" state to that player only
        if CraftingBinder.CraftingState then
            CraftingBinder.CraftingState:FireClient(player, {
                open = true,
                category = cat,
                bench = model,
            })
        else
            warn("[CraftingBinder] Missing CraftingState RemoteEvent")
        end
        print(("[CraftingBinder] %s used %s (%s)"):format(player.Name, model:GetFullName(), cat))
    end)
end

function CraftingBinder.Start()
    -- Bind all existing crafting benches and any new ones that appear
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("Model") and inst.Name:match("^CraftingBench_") then
            CraftingBinder:bindBench(inst)
        end
    end

    workspace.DescendantAdded:Connect(function(inst)
        if inst:IsA("Model") and inst.Name:match("^CraftingBench_") then
            CraftingBinder:bindBench(inst)
        end
    end)

    print("[CraftingBinder] Server binder loaded")
end

return CraftingBinder