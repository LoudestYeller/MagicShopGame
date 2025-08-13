--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = {}
DataService._profiles = {}
DataService._profileObjects = {} -- Store actual profile objects for proper release
DataService._profilesByUserId = {} -- Key by UserId for reliability

-- Use in-memory storage in Studio, ProfileService in production
local USE_MEMORY = RunService:IsStudio()

local ProfileService
if not USE_MEMORY then
    local ok, mod = pcall(function()
        return require(script.Parent.Parent:FindFirstChild("Vendor") and script.Parent.Parent.Vendor:FindFirstChild("ProfileService"))
    end)
    if ok and mod then
        ProfileService = mod
        print("[DataService] Using ProfileService for data persistence")
    else
        warn("[DataService] ProfileService not found. Falling back to in-memory storage.")
        USE_MEMORY = true
    end
else
    print("[DataService] Studio detected - using in-memory storage")
end

local DEFAULT = {
    cash = 50,
    shop = {
        level = 1,
        rooms = {},
        stations = { PotionBench = 1, Enchanter = 0, Forge = 0, WandTable = 0 },
    },
    inventory = {}, -- [itemId] = qty
    display = {},   -- array of {slot:number, itemId:string, qty:number, price:number}
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

function DataService:Init()
    print("[DataService] Init")
    if ProfileService then
        self.Store = ProfileService.GetProfileStore("MagicShop/PlayerData_v1", DEFAULT)
    end

    Players.PlayerAdded:Connect(function(plr)
        self:Load(plr)
    end)

    Players.PlayerRemoving:Connect(function(plr)
        self:Release(plr)
    end)
    
    -- Set up remote handlers
    task.defer(function()
        self:_setupRemotes()
    end)
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
    local success, Remotes = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemotesIndex"))
    end)
    if success and Remotes then
        Remotes.CashUpdated:FireClient(plr, p.cash)
    end
end

-- Add/Remove now accept Player or userId
function DataService:AddItem(plrOrId, id: string, qty: number)
    print(("[DataService] AddItem called with arg1: %s (type: %s), arg2: %s (type: %s), arg3: %s"):format(
        tostring(plrOrId), typeof(plrOrId), 
        tostring(id), typeof(id),
        tostring(qty)
    ))
    
    local p = self:Get(plrOrId)
    local plr = asPlayer(plrOrId)
    if not p then
        warn("[DataService] AddItem FAILED - invalid player")
        return
    end
    if not plr then
        warn("[DataService] AddItem FAILED - could not resolve player from:", tostring(plrOrId))
        return
    end
    qty = math.max(1, qty or 1)
    p.inventory[id] = (p.inventory[id] or 0) + qty
    print(("[DataService] Added %s x%d to %s, now have %d"):format(id, qty, plr.Name, p.inventory[id]))
    self:_broadcastInventory(plrOrId)
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
    local success, Remotes = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemotesIndex"))
    end)
    if success and Remotes then
        Remotes.InventoryUpdated:FireClient(plr, p.inventory)
        print(("[DataService] Sent inventory to %s: %s"):format(plr.Name, game:GetService("HttpService"):JSONEncode(p.inventory)))
    else
        warn("[DataService] Failed to broadcast - RemotesIndex not available")
    end
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

function DataService:_setupRemotes()
    local success, Remotes = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("RemotesIndex"))
    end)
    if not success then
        warn("[DataService] Failed to load RemotesIndex, retrying in 1s")
        task.wait(1)
        return self:_setupRemotes()
    end
    
    -- Handle RequestInventory requests (using the correct remote name)
    Remotes.RequestInventory.OnServerEvent:Connect(function(plr)
        local p = self:Get(plr)
        if p then
            Remotes.InventorySnapshot:FireClient(plr, p.inventory)
            Remotes.CashUpdated:FireClient(plr, p.cash)
            print(("[DataService] Sent inventory to %s: %s"):format(plr.Name, game:GetService("HttpService"):JSONEncode(p.inventory)))
        end
    end)
end


return DataService