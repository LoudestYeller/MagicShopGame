--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServiceLoader = require(ServerScriptService.ServiceLoader)

-- Remote setup
local remotes = {} -- [name] = RemoteEvent
local required = {
    "CashUpdated",
    "InventorySnapshot",
    "InventoryUpdated",
    "DisplayCaseUpdated"
}

local DataService = {}
DataService._profiles = {}
DataService._profileObjects = {} -- Store actual profile objects for proper release
DataService._profilesByUserId = {} -- Key by UserId for reliability

-- Use in-memory storage in Studio, ProfileService in production
local USE_MEMORY = RunService:IsStudio()
local ProfileService

local function resolvePlayer(p)
    if typeof(p) == "Instance" and p:IsA("Player") then return p end
    if typeof(p) == "number" then return Players:GetPlayerByUserId(p) end
    if typeof(p) == "string" then
        return Players:FindFirstChild(p) or Players:GetPlayerByUserId(tonumber(p) or -1)
    end
    return nil
end

local DEFAULT = {
    cash = 50,
    shop = {
        level = 1,
        rooms = {},
        stations = { PotionBench = 1, Enchanter = 0, Forge = 0, WandTable = 0 },
    },
    inventory = {}, -- [itemId] = qty
    display = { slots = {}, nextId = 1 }, -- DisplayCaseService state
    discoveredRecipes = {},
    analytics = {},
}

function DataService:_deepCopy(t)
    local c = {}
    for k,v in pairs(t) do
        if type(v) == "table" then c[k] = self:_deepCopy(v) else c[k] = v end
    end
    return c
end

local function setupRemotes()
    local RemotesService = ServiceLoader.requireService("RemotesService")
    if not RemotesService then
        warn("[DataService] Failed to get RemotesService")
        return false
    end

    -- Initialize all required remotes
    for _, name in ipairs(required) do
        local remote = RemotesService.Get(name)
        if not remote then
            warn("[DataService] Remote not found in RemotesService:", name)
            return false
        end
        remotes[name] = remote
        print("[DataService] Cached remote:", remote:GetFullName())

        -- Verify remote is a valid RemoteEvent
        if not remote:IsA("RemoteEvent") then
            warn("[DataService] Invalid remote type for", name, "-", remote.ClassName)
            return false
        end
    end

    print("[DataService] All remotes set up:", table.concat(required, ", "))
    return true
end

function DataService:Init()
    print("[DataService] Init")
    
    local RemotesService = ServiceLoader.requireService("RemotesService")
    if not RemotesService then
        warn("[DataService] Failed to get RemotesService")
        return false
    end

    -- Set up remotes first (needed for inventory broadcasts)
    local remoteList = table.concat(required, ", ")
    print("[DataService] Setting up remotes: " .. remoteList)
    for _, name in ipairs(required) do
        local remote = RemotesService.Get(name)
        if not remote then
            warn("[DataService] Failed to get remote:", name)
            return false
        end
        remotes[name] = remote
    end
    print("[DataService] All remotes ready")

    -- Load ProfileService for persistent data
    if not USE_MEMORY then
        local ok, mod = pcall(function()
            return require(ServerScriptService.Vendor.ProfileService)
        end)
        if ok and mod then
            ProfileService = mod
            self.Store = ProfileService.GetProfileStore("MagicShop/PlayerData_v1", DEFAULT)
            print("[DataService] Using ProfileService for data persistence")
        else
            warn("[DataService] ProfileService not found. Falling back to in-memory storage.")
            USE_MEMORY = true
        end
    else
        print("[DataService] Studio detected - using in-memory storage")
    end

    -- Load data for existing players
    for _, plr in ipairs(Players:GetPlayers()) do
        self:Load(plr)
    end

    Players.PlayerAdded:Connect(function(plr)
        self:Load(plr)
    end)

    Players.PlayerRemoving:Connect(function(plr)
        self:Release(plr)
    end)
    
    return true
end

function DataService:Start() end

function DataService:Load(plr: Player)
    if USE_MEMORY then
        self._profiles[plr] = self:_deepCopy(DEFAULT)
        self._profilesByUserId[plr.UserId] = self._profiles[plr]
        -- Broadcast initial inventory
        task.defer(function()
            self:_broadcastInventory(plr)
        end)
        return true
    end

    local profile = self.Store:LoadProfileAsync("Player_"..plr.UserId, "ForceLoad")
    if not profile then
        warn("[DataService] Failed to load, using defaults:", plr.UserId)
        self._profiles[plr] = self:_deepCopy(DEFAULT)
        return false
    end

    profile:Reconcile()
    profile:ListenToRelease(function()
        self._profiles[plr] = nil
        self._profileObjects[plr] = nil
        plr:Kick("Data released")
    end)

    if plr.Parent ~= Players then
        profile:Release()
        return false
    end

    self._profiles[plr] = profile.Data
    self._profileObjects[plr] = profile
    self._profilesByUserId[plr.UserId] = profile.Data
    
    -- Broadcast initial inventory
    task.defer(function()
        self:_broadcastInventory(plr)
    end)
    
    return true
end

function DataService:GetDisplay(plrOrId)
    local p = self:Get(plrOrId)
    if not p then return nil end
    if not p.display then
        p.display = { slots = {}, nextId = 1 }
    end
    return p.display
end

function DataService:Release(plr: Player)
    if USE_MEMORY then
        self._profiles[plr] = nil
        self._profilesByUserId[plr.UserId] = nil
        return
    end
    -- ProfileService profiles auto-release when player leaves
    local profile = self._profileObjects[plr]
    if profile then
        profile:Release()
        self._profileObjects[plr] = nil
    end
    self._profiles[plr] = nil
    self._profilesByUserId[plr.UserId] = nil
end

-- Get profile by Player or userId
function DataService:Get(plrOrId)
    local userId = typeof(plrOrId) == "Instance" and plrOrId.UserId or plrOrId
    return self._profilesByUserId[userId]
end

-- Helper: resolve Player from Player or userId
local function asPlayer(plrOrId)
    if typeof(plrOrId) == "Instance" then return plrOrId end
    return Players:GetPlayerByUserId(plrOrId)
end

function DataService:GiveCash(plr: Player, amount: number)
    local p = self:Get(plr)
    if not p then return end
    p.cash = math.max(0, (p.cash or 0) + amount)
    
    -- Broadcast cash update to client
    if remotes.CashUpdated then
        remotes.CashUpdated:FireClient(plr, p.cash)
    end
end

-- Add/Remove now accept Player or userId
function DataService:AddItem(plrOrId, id: string, qty: number)
    local player = resolvePlayer(plrOrId)
    if not player then
        warn(("[DataService] AddItem FAILED - invalid player arg (%s)"):format(typeof(plrOrId)))
        return false
    end
    
    local p = self:Get(player)
    if not p then
        warn("[DataService] AddItem FAILED - no data for player:", player.Name)
        return false
    end
    qty = math.max(1, qty or 1)
    p.inventory[id] = (p.inventory[id] or 0) + qty
    print(("[DataService] Added %s x%d to %s, now have %d"):format(id, qty, player.Name, p.inventory[id]))
    self:_broadcastInventory(player)
end

function DataService:RemoveItem(plrOrId, id: string, qty: number): boolean
    local p = self:Get(plrOrId)
    local plr = asPlayer(plrOrId)
    if not p then
        warn("[DataService] RemoveItem FAILED - invalid player")
        return false
    end
    local have = p.inventory[id] or 0
    if have < qty then return false end
    p.inventory[id] = have - qty
    if p.inventory[id] <= 0 then p.inventory[id] = nil end
    print(("[DataService] Removed %s x%d from %s"):format(id, qty, plr.Name))
    self:_broadcastInventory(plrOrId)
    return true
end

-- Check if player has required items
function DataService:HasItems(plrOrId, requirements: {[string]: number}): boolean
    local p = self:Get(plrOrId)
    if not p then return false end
    
    for itemId, reqQty in pairs(requirements) do
        local have = p.inventory[itemId] or 0
        if have < reqQty then
            return false
        end
    end
    return true
end

-- Consume multiple items atomically
function DataService:ConsumeItems(plrOrId, items: {[string]: number}): boolean
    local p = self:Get(plrOrId)
    if not p then return false end
    
    -- First verify we have everything
    for itemId, qty in pairs(items) do
        local have = p.inventory[itemId] or 0
        if have < qty then
            return false
        end
    end
    
    -- Then consume all items
    for itemId, qty in pairs(items) do
        p.inventory[itemId] = (p.inventory[itemId] or 0) - qty
        if p.inventory[itemId] <= 0 then
            p.inventory[itemId] = nil
        end
    end
    
    self:_broadcastInventory(plrOrId)
    return true
end

-- Helper to broadcast inventory to client
function DataService:_broadcastInventory(plrOrId)
    local p = self:Get(plrOrId)
    local plr = asPlayer(plrOrId)
    if not p or not plr then return end

    -- Send inventory update
    if remotes.InventoryUpdated then
        remotes.InventoryUpdated:FireClient(plr, p.inventory)
    else
        warn("[DataService] InventoryUpdated remote missing!")
    end

    -- Send display case update
    if remotes.DisplayCaseUpdated then
        if not p.display then
            p.display = { slots = {}, nextId = 1 }
        end
        remotes.DisplayCaseUpdated:FireClient(plr, plr.UserId, p.display)
    else
        warn("[DataService] DisplayCaseUpdated remote missing!")
    end

    print(("[DataService] Sent inventory to %s: %s"):format(plr.Name, game:GetService("HttpService"):JSONEncode(p.inventory)))
end

-- Get player-specific attunement seed for crafting uniqueness (0..1)
function DataService:GetAttunementSeed(player)
    self._attune = self._attune or {}
    local uid = player.UserId
    local s = self._attune[uid]
    if not s then
        -- Stable per user: seed RNG by UserId so it doesn't change every session
        local rng = Random.new(uid)
        s = rng:NextNumber() -- 0..1
        self._attune[uid] = s
    end
    return s
end

return DataService