--!strict
-- Services
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Modules
local Shared = RS:WaitForChild("Shared")
local Items = require(Shared:WaitForChild("Items"))
local CraftingFolder = Shared:WaitForChild("Crafting")
local IngredientDB = require(CraftingFolder:WaitForChild("IngredientDB"))

-- Core dependencies
local ServiceLoader = require(script.Parent.Parent.ServiceLoader)
local DataService = ServiceLoader.requireService("DataService")
local RemotesService = ServiceLoader.requireService("RemotesService")
local Remotes = RemotesService

-- Constants
local MIN_PRICE = 1
local MIN_QUANTITY = 1
local MAX_QUANTITY = 999
local MAX_LISTINGS_PER_PLAYER = 12
local COOLDOWN = 0.5 -- seconds between actions

-- Rate limiting
local lastAction = {}
local function checkRateLimit(player: Player): boolean
    local now = os.clock()
    local last = lastAction[player] or 0
    if now - last < COOLDOWN then
        warn(("[DisplayCaseService] Rate limit hit for %s"):format(player.Name))
        return false
    end
    lastAction[player] = now
    return true
end

-- Utilities
local function normalizeItemId(v:any): string?
    if not v then return nil end
    v = tostring(v)
    
    -- Check Items module first (glowing_mushroom style)
    if Items[v] then return v end
    
    -- Check IngredientDB (glowing_mush style) 
    if IngredientDB[v] then return v end
    
    -- Try snake_case conversion
    local snake = v:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
    if Items[snake] then return snake end
    if IngredientDB[snake] then return snake end
    
    -- Try display name lookup in Items
    for id, def in pairs(Items) do
        if def.name == v then return id end
    end
    
    -- Try display name lookup in IngredientDB
    for id, def in pairs(IngredientDB) do
        if def.name == v then return id end
    end
    
    return nil
end

local function validateListingPayload(payload: any): (boolean, string?)
    if typeof(payload) ~= "table" then
        return false, "Payload must be a table"
    end
    
    local rawItem = payload.item or payload.itemId
    local qty = tonumber(payload.qty)
    local price = tonumber(payload.price)
    
    if type(rawItem) ~= "string" then
        return false, "Item must be a string"
    end
    
    if not qty or qty < MIN_QUANTITY or qty > MAX_QUANTITY or qty % 1 ~= 0 then
        return false, ("Quantity must be an integer between %d and %d"):format(MIN_QUANTITY, MAX_QUANTITY)
    end
    
    if not price or price < MIN_PRICE then
        return false, ("Price must be at least %d"):format(MIN_PRICE)
    end
    
    return true
end

-- Service
local DisplayCaseService = {}
function DisplayCaseService.GetCase(playerOrUserId)
    local userId = (typeof(playerOrUserId) == "Instance") and playerOrUserId.UserId or tonumber(playerOrUserId)
    assert(userId, "[DisplayCaseService] GetCase: need Player or userId")
    return DataService:GetDisplay(userId)
end

function DisplayCaseService:GetDisplayCaseData(player)
    return self.Listings[player.UserId] or {}
end

function DisplayCaseService.Snapshot(playerOrUserId)
    local userId = (typeof(playerOrUserId) == "Instance") and playerOrUserId.UserId or tonumber(playerOrUserId)
    local c = caseByUser[userId]
    return { slots = c and c.slots or {} }
end

function DisplayCaseService:HandleList(player: Player, payload: any)
    -- Rate limit check
    if not checkRateLimit(player) then return end
    
    -- Validate payload
    local ok, err = validateListingPayload(payload)
    if not ok then
        warn(("[DisplayCaseService] Invalid LIST payload from %s: %s"):format(player.Name, err))
        self:SendDisplayCase(player) -- Send current state back
        return
    end
    
    -- Normalize item ID
    local rawItem = payload.item or payload.itemId
    local item = normalizeItemId(rawItem)
    if not item then
        warn(("[DisplayCaseService] %s tried to list unknown item: %s"):format(player.Name, tostring(rawItem)))
        self:SendDisplayCase(player)
        return
    end
    
    -- Check listing limit
    local userListings = self.Listings[player.UserId] or {}
    if #userListings >= MAX_LISTINGS_PER_PLAYER then
        warn(("[DisplayCaseService] %s hit listing limit (%d)"):format(player.Name, MAX_LISTINGS_PER_PLAYER))
        self:SendDisplayCase(player)
        return
    end
    
    -- Verify & consume items
    local qty = tonumber(payload.qty)
    if not DataService:HasItems(player, {[item] = qty}) then
        warn(("[DisplayCaseService] %s doesn't have %s x%d to list"):format(player.Name, item, qty))
        self:SendDisplayCase(player)
        return
    end
    
    -- Create listing
    DataService:ConsumeItems(player, {[item] = qty})
    self.Listings[player.UserId] = self.Listings[player.UserId] or {}
    
    table.insert(self.Listings[player.UserId], {
        item = item,
        itemId = item, -- Compatibility
        qty = qty,
        price = tonumber(payload.price),
        listingId = HttpService:GenerateGUID(false)
    })
    
    print(("[DisplayCaseService] %s listed %s x%d for %d¤"):format(
        player.Name, item, qty, tonumber(payload.price)))
    
    self:SendDisplayCase(player)
end

function DisplayCaseService:HandleRemove(player: Player, listingId: string)
    -- Rate limit check
    if not checkRateLimit(player) then return end
    
    local userListings = self.Listings[player.UserId]
    if not userListings then
        warn("[DisplayCaseService] No listings for user")
        return
    end
    
    -- Find and validate listing
    local foundIndex, listing
    for i, item in ipairs(userListings) do
        if item.listingId == listingId then
            foundIndex = i
            listing = item
            break
        end
    end
    
    if not listing then
        warn("[DisplayCaseService] Listing not found: "..tostring(listingId))
        return
    end
    
    -- Return items to inventory
    local itemId = listing.item or listing.itemId
    local qty = listing.qty or 1
    local itemName = (Items[itemId] and Items[itemId].name) or itemId
    
    DataService:AddItem(player, itemName, qty)
    table.remove(userListings, foundIndex)
    
    print(("[DisplayCaseService] Removed listing %s and returned %s x%d"):format(
        listingId, tostring(itemName), qty))
    
    self:SendDisplayCase(player)
end

function DisplayCaseService:HandleUpdate(player: Player, listingId: string, newPrice: number?, newQty: number?)
    -- Rate limit check
    if not checkRateLimit(player) then return end
    
    local userListings = self.Listings[player.UserId]
    if not userListings then
        warn("[DisplayCaseService] No listings for user")
        return
    end
    
    -- Find and validate listing
    local listing
    for _, item in ipairs(userListings) do
        if item.listingId == listingId then
            listing = item
            break
        end
    end
    
    if not listing then
        warn("[DisplayCaseService] Listing not found: "..tostring(listingId))
        return
    end
    
    -- Update valid fields
    if newPrice and newPrice >= MIN_PRICE then
        listing.price = math.floor(newPrice)
    end
    
    if newQty and newQty >= MIN_QUANTITY and newQty <= MAX_QUANTITY and newQty % 1 == 0 then
        listing.qty = newQty
    end
    
    print(("[DisplayCaseService] Updated %s -> price=%d qty=%d"):format(
        listingId, listing.price, listing.qty))
    
    self:SendDisplayCase(player)
end

function DisplayCaseService:HandleToggle(player: Player)
    -- Rate limit check
    if not checkRateLimit(player) then return end
    
    -- Send toggle event back to client to show/hide UI
    Remotes.ToggleDisplayCase:FireClient(player)
end

function DisplayCaseService:Init()
    print("[DisplayCaseService] Init")
    
    local DisplayCaseRequest = RemotesService.Get("DisplayCaseRequest")
    DisplayCaseRequest.OnServerEvent:Connect(function(player, action, payload)
        if action == "Place" then
            self:PlaceOnDisplay(player, payload.itemId, payload.qty or 1, payload.price)
        elseif action == "Take" then
            self:TakeFromDisplay(player, payload.slotId, payload.qty or 1)
        end
    end)
end

function DisplayCaseService.PlaceOnDisplay(player, itemId, qty, price)
    print("[DisplayCaseService] Placing", itemId, "x", qty, "for", price)
    local userId = player.UserId
    if not DataService:HasItems(player, {[itemId] = qty}) then return end
    DataService:ConsumeItems(player, {[itemId] = qty})

    local c = self:GetCase(userId)
    local id = c.nextId
    c.nextId += 1
    c.slots[id] = { slotId=id, itemId=itemId, qty=qty, price=price }

    -- Notify the owner's client that display changed
    DataService:BroadcastDisplay(player)
end

function DisplayCaseService:TakeFromDisplay(player, slotId, qty)
    local userId = player.UserId
    local c = self:GetCase(userId)
    local slot = c.slots[slotId]; if not slot then return end
    local n = math.min(qty, slot.qty)
    DataService:AddItem(player, slot.itemId, n)
    slot.qty -= n
    if slot.qty <= 0 then c.slots[slotId] = nil end
    -- Notify the owner's client that display changed
    DataService:BroadcastDisplay(player)
end

function DisplayCaseService:Start()
    print("[DisplayCaseService] Start")
end

return DisplayCaseService