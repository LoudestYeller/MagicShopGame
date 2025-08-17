-- UIBootstrap: ensures DisplayUI and CraftingUI exist in ReplicatedStorage,
-- then mounts clones (disabled) into PlayerGui.
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local function ensureFolder(parent, name)
    local f = parent:FindFirstChild(name)
    if not f then
        f = Instance.new("Folder")
        f.Name = name
        f.Parent = parent
    end
    return f
end

local function tryRequire(moduleScript)
    local ok, mod = pcall(require, moduleScript)
    if ok then return mod end
    warn(("[UIBootstrap] require failed for %s: %s"):format(moduleScript:GetFullName(), tostring(mod)))
    return nil
end

local function buildViaModule(screenName, moduleName)
    local uiFolder = ensureFolder(ensureFolder(RS, "Modules"), "UI")
    local maker = uiFolder:FindFirstChild(moduleName)
    if maker and maker:IsA("ModuleScript") then
        local make = tryRequire(maker)
        if typeof(make) == "function" then
            local gui = make()
            if gui and gui:IsA("ScreenGui") then
                gui.Name = screenName
                gui.Parent = RS -- canonical copy
                print(("[UIBootstrap] Built %s from %s"):format(screenName, moduleName))
                return gui
            end
        end
    end
    return nil
end

local function getOrCreate(screenName, makerModule)
    local existing = RS:FindFirstChild(screenName)
    if existing and existing:IsA("ScreenGui") then
        return existing
    end
    local built = buildViaModule(screenName, makerModule)
    if built then return built end

    -- Should not happen after we add prefab modules, but keep a safe fallback.
    warn(("[UIBootstrap] %s missing; creating minimal fallback"):format(screenName))
    local sg = Instance.new("ScreenGui")
    sg.Name = screenName
    sg.Parent = RS
    return sg
end

local function mountToPlayerGui(screenName, makerModule)
    local src = getOrCreate(screenName, makerModule)
    local clone = src:Clone()
    clone.Enabled = false
    clone.Parent = pg

    -- wire close buttons if present
    local close = clone:FindFirstChild("CloseButton", true)
    if close and close:IsA("TextButton") then
        close.MouseButton1Click:Connect(function()
            clone.Enabled = false
        end)
    end

    print(("[UIBootstrap] Mounted %s (Enabled=false)"):format(screenName))
    return clone
end

mountToPlayerGui("DisplayUI", "MakeDisplayUI")
mountToPlayerGui("CraftingUI", "MakeCraftingUI")
print("🎮 [UIBootstrap] UI setup complete")