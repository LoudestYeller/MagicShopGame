local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("RemotesIndex"))
local Items = require(Shared:WaitForChild("Items"))

-- Always resolve the *Folder* and its children by WaitForChild
local CraftingFolder = Shared:WaitForChild("Crafting")
local IngredientDB = require(CraftingFolder:WaitForChild("IngredientDB"))

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

local ServiceLoader = require(script.Parent.Parent.ServiceLoader)
local DataService = ServiceLoader.requireService("DataService")

local DisplayCaseService = {}
DisplayCaseService.Listings = {} -- { [userId] = { {item="", qty=1, price=10}, ... } }

local HttpService = game:GetService("HttpService")
local function uid(plr) return plr.UserId end

function DisplayCaseService:SendDisplayCase(player)
    local listings = self.Listings[player.UserId] or {}
    Remotes.DisplayCaseUpdated:FireClient(player, player.UserId, listings)
end

function DisplayCaseService:GetDisplayCaseData(player)
    return self.Listings[player.UserId] or {}
end

function DisplayCaseService:Init()
    print("[DisplayCaseService] Init")
end

function DisplayCaseService:Start()
    print("[DisplayCaseService] Start")
    
    -- Handle toggle display case (from counter interaction)
    Remotes.ToggleDisplayCase.OnServerEvent:Connect(function(player)
        print(("[DisplayCaseService] %s requested toggle display case"):format(player.Name))
        Remotes.ToggleDisplayCase:FireClient(player)
    end)
    
    -- Handle display case requests
    Remotes.DisplayCaseRequest.OnServerEvent:Connect(function(player, action, arg1, arg2, arg3)
        if action == "GET" then
            -- Send current display case data
            self:SendDisplayCase(player)
        elseif action == "LIST" then
            -- New authoritative listing system with normalization
            local payload = arg1
            -- Back-compat: accept legacy (item, qty, price) args
            if typeof(payload) ~= "table" then
                local legacyItem, legacyQty, legacyPrice = arg1, arg2, arg3
                payload = { item = legacyItem, qty = legacyQty, price = legacyPrice }
            end
            if typeof(payload) ~= "table" then
                warn(("[DisplayCaseService] LIST requires payload table from %s"):format(player.Name))
                return
            end
            
            local rawItem = payload.item or payload.itemId
            local qty = tonumber(payload.qty) or 1  
            local price = tonumber(payload.price) or 1
            if type(rawItem) ~= "string" or type(qty) ~= "number" or type(price) ~= "number" then
                warn(("[DisplayCaseService] Invalid LIST payload from %s: item=%s, qty=%s, price=%s"):format(
                    player.Name, tostring(rawItem), tostring(qty), tostring(price)))
                return
            end

            -- Normalize item ID to canonical form
            local item = normalizeItemId(rawItem)
            if not item then
                print(("[DisplayCaseService] %s tried to list unknown item: %s"):format(player.Name, tostring(rawItem)))
                -- Send current listings back (no change)
                Remotes.DisplayCaseUpdated:FireClient(player, player.UserId, self.Listings[player.UserId] or {})
                return
            end

            -- Verify & consume items using canonical ID
            local ok = DataService:HasItems(player, {[item] = qty})
            if not ok then
                print(("[DisplayCaseService] %s doesn't have %s x%d to list"):format(player.Name, item, qty))
                -- Send current listings back (no change)
                Remotes.DisplayCaseUpdated:FireClient(player, player.UserId, self.Listings[player.UserId] or {})
                return
            end

            DataService:ConsumeItems(player, {[item] = qty})

            local uid = player.UserId
            self.Listings[uid] = self.Listings[uid] or {}
            local listingId = HttpService:GenerateGUID(false)
            
            -- Canonical listing structure
            table.insert(self.Listings[uid], {
                item = item,        -- Canonical field
                itemId = item,      -- Compatibility field  
                qty = qty, 
                price = price,
                listingId = listingId
            })

            print(("[DisplayCaseService] %s listed %s x%d for %d¤ (normalized from %s)"):format(player.Name, item, qty, price, rawItem))
            
            -- Broadcast new list to the owner
            Remotes.DisplayCaseUpdated:FireClient(player, uid, self.Listings[uid])
            
        elseif action == "REMOVE" then
            local listingId = arg1
            print(("[DisplayCaseService] %s requested REMOVE %s"):format(player.Name, tostring(listingId)))

            local userListings = self.Listings[player.UserId]
            if not userListings then
                warn("[DisplayCaseService] No listings for user")
                return
            end

            -- Find listing by listingId
            local foundIndex = nil
            local listing = nil
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

            -- Return the item(s) to inventory using canonical ID
            local itemId = listing.item or listing.itemId
            local qty = listing.qty or 1
            
            -- Convert canonical ID to display name for DataService
            local itemName = (Items[itemId] and Items[itemId].name) or itemId
            DataService:AddItem(player, itemName, qty)

            -- Remove listing from array
            table.remove(userListings, foundIndex)

            -- Send fresh list to owner
            Remotes.DisplayCaseUpdated:FireClient(player, player.UserId, userListings)
            print(("[DisplayCaseService] Removed listing %s and returned %s x%d"):format(listingId, tostring(itemName), qty))
            
        elseif action == "UPDATE" then
            local listingId, newPrice, newQty = arg1, tonumber(arg2), tonumber(arg3)
            
            print(("[DisplayCaseService] %s requested UPDATE %s -> price=%s qty=%s")
                :format(player.Name, tostring(listingId), tostring(newPrice), tostring(newQty)))

            local userListings = self.Listings[player.UserId]
            if not userListings then 
                warn("[DisplayCaseService] No listings for user")
                return 
            end

            -- Find listing by listingId
            local listing = nil
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

            -- Basic validation and update
            if newPrice and (newPrice >= 1) then
                listing.price = math.floor(newPrice)
            end
            if newQty and (newQty >= 1 and newQty % 1 == 0) then
                listing.qty = newQty
            end

            -- Push fresh list back to owner
            Remotes.DisplayCaseUpdated:FireClient(player, player.UserId, userListings)
            print(("[DisplayCaseService] Updated %s -> price=%d qty=%d")
                :format(listingId, listing.price, listing.qty))
                
        else
            warn(("[DisplayCaseService] Unknown action '%s' from %s"):format(tostring(action), player.Name))
        end
    end)
end

return DisplayCaseService