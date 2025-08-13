local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[ShopSpawner] Waiting for ShopKit...")

-- Wait for ShopKit to be available
local ShopKit = ReplicatedStorage:WaitForChild("ShopKit", 10)
if not ShopKit then
    warn("[ShopSpawner] ShopKit not found - shop spawning disabled")
    return
end

local Modules = ShopKit:WaitForChild("Modules", 5)
if not Modules then
    warn("[ShopSpawner] ShopKit.Modules not found - shop spawning disabled") 
    return
end

print("[ShopSpawner] Loading ShopKit modules...")

-- Try the new cleaner approach first
local success, ShopKit = pcall(function()
    return require(ReplicatedStorage.ShopKit)
end)

local Catalog, Binder
if success then
    print("[ShopSpawner] Using ShopKit main module")
    Catalog = ShopKit.Catalog
    Binder = ShopKit.SocketBinder
else
    print("[ShopSpawner] Falling back to individual modules")
    Catalog = require(Modules:WaitForChild("ShopCatalog"))
    Binder  = require(Modules:WaitForChild("SocketBinder"))
end

local Remotes = require(ReplicatedStorage.Shared.RemotesIndex)

local SHOPS_FOLDER = Workspace:FindFirstChild("Shops") or Instance.new("Folder", Workspace)
SHOPS_FOLDER.Name = "Shops"

local PLOT_ORIGIN = CFrame.new(0, 0, 0) -- change later for plots

local function spawnDefaultShop(player: Player)
    print(("[ShopSpawner] Creating shop for %s"):format(player.Name))
    
    local shell = Catalog.BuildDefaultShell()
    shell.Parent = SHOPS_FOLDER
    shell:PivotTo(PLOT_ORIGIN)
    shell:SetAttribute("OwnerId", player.UserId)
    
    print(("[ShopSpawner] Shell created: %s at position %s"):format(shell.Name, tostring(shell:GetPivot().Position)))

    for _, entry in ipairs(Catalog.DefaultStations) do
        local station = entry.build()
        local success = Binder.MountAtSocket(shell, entry.socket, station)
        if success then
            print(("[ShopSpawner] Mounted %s at %s"):format(station.Name, entry.socket))
        else
            warn(("[ShopSpawner] Failed to mount %s at %s"):format(station.Name, entry.socket))
        end
    end
    
    print(("[ShopSpawner] Shop complete for %s"):format(player.Name))
end

Players.PlayerAdded:Connect(spawnDefaultShop)

print("[ShopSpawner] Service started")