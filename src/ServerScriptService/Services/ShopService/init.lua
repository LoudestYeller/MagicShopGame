--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")

local function attachDisplayPrompt(counterModel: Model, owner: Player)
    local target = counterModel.PrimaryPart or counterModel:FindFirstChildWhichIsA("BasePart")
    if not target then
        warn("[ShopService] No BasePart on DisplayCounter to attach prompt")
        return
    end

    -- de-dupe
    local existing = target:FindFirstChild("OpenDisplayPrompt")
    if existing then existing:Destroy() end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "OpenDisplayPrompt"
    prompt.ObjectText = "Display Case"
    prompt.ActionText = "Open"
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
    prompt:SetAttribute("OwnerUserId", owner.UserId) -- future owner-gating
    prompt.Parent = target
end

local ShopService = {}

-- Get ShopKit modules
local function loadShopKit()
    print("[ShopService] 📦 Loading ShopKit...")
    
    local ShopKit = ReplicatedStorage:WaitForChild("ShopKit", 10)
    if not ShopKit then
        warn("[ShopService] ShopKit not found - shop spawning disabled")
        return false
    end

    local Modules = ShopKit:WaitForChild("Modules", 5)
    if not Modules then
        warn("[ShopService] ShopKit.Modules not found - shop spawning disabled") 
        return false
    end

    -- Try the new cleaner approach first
    local success, Kit = pcall(function()
        return require(ReplicatedStorage.ShopKit)
    end)

    if success then
        print("[ShopService] ✅ Using ShopKit main module")
        return Kit
    end

    -- Fallback to individual modules
    print("[ShopService] ℹ️ Falling back to individual modules")
    return {
        Catalog = require(Modules:WaitForChild("ShopCatalog")),
        SocketBinder = require(Modules:WaitForChild("SocketBinder"))
    }
end

function ShopService.Init(services)
    -- Store context
    ShopService._services = services
    
    -- Load ShopKit
    local ShopKit = loadShopKit()
    if not ShopKit then return false end
    
    ShopService.ShopKit = ShopKit
    ShopService.ShopsFolder = Workspace:FindFirstChild("Shops") or Instance.new("Folder", Workspace)
    ShopService.ShopsFolder.Name = "Shops"

    -- Connect to players joining
    Players.PlayerAdded:Connect(function(player)
        ShopService:SpawnDefaultShop(player)
    end)

    print("[ShopService] 💬 Init")
    return true
end

function ShopService:SpawnDefaultShop(player: Player)
    print(("[ShopService] 🏪 Creating shop for %s"):format(player.Name))
    
    -- Create shell
    local shell = self.ShopKit.Catalog.BuildDefaultShell()
    shell.Parent = self.ShopsFolder
    shell:PivotTo(CFrame.new(0, 0, 0)) -- TODO: Plot system
    shell:SetAttribute("OwnerId", player.UserId)
    
    print(("[ShopService] Shell created: %s at position %s"):format(
        shell.Name, tostring(shell:GetPivot().Position)))

    -- Mount default stations
    for _, entry in ipairs(self.ShopKit.Catalog.DefaultStations) do
        local station = entry.build()
        local success = self.ShopKit.SocketBinder.MountAtSocket(shell, entry.socket, station)
        if success then
            print(("[ShopService] Mounted %s at %s"):format(station.Name, entry.socket))
            -- Add prompt to display counter
            if station.Name == "DisplayCounter_Generic" then
                attachDisplayPrompt(station, player)
            end
        else
            warn(("[ShopService] Failed to mount %s at %s"):format(station.Name, entry.socket))
        end
    end
    
    print(("[ShopService] Shop complete for %s"):format(player.Name))
    return shell
end

function ShopService.Start()
    print("[ShopService] 💬 Start")

    -- Spawn shops for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        ShopService:SpawnDefaultShop(player)
    end
end

return ShopService