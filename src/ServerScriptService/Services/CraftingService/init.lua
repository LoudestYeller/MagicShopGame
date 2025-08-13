local RS = game:GetService("ReplicatedStorage")
local Shared = RS:WaitForChild("Shared")
local Remotes = require(Shared:WaitForChild("RemotesIndex"))
local Items = require(Shared:WaitForChild("Items"))

-- Always resolve the *Folder* and its children by WaitForChild
local CraftingFolder = Shared:WaitForChild("Crafting")
local RecipeBook = require(CraftingFolder:WaitForChild("RecipeBook"))
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

local CraftingService = {}

function CraftingService.Init()
    print("[CraftingService] Init")
end

function CraftingService.Start()
    print("[CraftingService] Start")
    print("[CraftingService] Connecting to RequestCraft:", Remotes.RequestCraft)

    local ok, err = pcall(function()
        Remotes.RequestCraft.OnServerEvent:Connect(function(player, station, ingredients)
            ingredients = ingredients or {}
            print(("[CraftingService] Craft request from %s -> %s with %d items")
                :format(player.Name, tostring(station), #ingredients))

            -- Convert client format {itemId, qty} to simple string array for resolver
            local ingredientList = {}
            for _, input in ipairs(ingredients) do
                local rawItemId = input.itemId or input.id
                local qty = input.qty or 1
                
                -- Normalize ingredient ID to canonical form
                local itemId = normalizeItemId(rawItemId)
                if not itemId then
                    print(("[CraftingService] Unknown ingredient: %s (skipping)"):format(tostring(rawItemId)))
                    Remotes.CraftingState:FireClient(player, "fail", station, "unknown_ingredient:"..tostring(rawItemId))
                    return
                end
                
                print(("[CraftingService] Processing ingredient: %s -> %s x%d"):format(tostring(rawItemId), itemId, qty))
                -- Add each quantity as separate entries
                for i = 1, qty do
                    table.insert(ingredientList, itemId)
                end
            end
            
            print(("[CraftingService] Final ingredient list (canonical): %s"):format(table.concat(ingredientList, ", ")))

            local seed = DataService:GetAttunementSeed(player)
            local result = RecipeBook.resolve(station, ingredientList, seed)

            if not result or not result.ok then
                Remotes.CraftingState:FireClient(player, "fail", "No matching recipe")
                return
            end

            -- Build needs table for canonical IDs but convert to display names for DataService
            local needsCanonical = result.needs
            if not needsCanonical then
                needsCanonical = {}
                for _,id in ipairs(ingredientList) do needsCanonical[id] = (needsCanonical[id] or 0) + 1 end
            end
            
            -- Convert canonical IDs to display names for DataService
            local needsDisplayNames = {}
            for canonicalId, qty in pairs(needsCanonical) do
                local displayName = (Items[canonicalId] and Items[canonicalId].name) or canonicalId
                needsDisplayNames[displayName] = qty
            end

            local has = DataService:HasItems(player, needsDisplayNames)
            if not has then
                local missing = {}
                local pdata = DataService:Get(player)
                for displayName, reqQty in pairs(needsDisplayNames) do
                    local have = (pdata.inventory[displayName] or 0)
                    if have < reqQty then
                        table.insert(missing, displayName)
                    end
                end
                local missingList = table.concat(missing, ", ")
                Remotes.CraftingState:FireClient(player, "fail", "Missing: "..missingList)
                return
            end

            -- stability roll
            if math.random() > (result.stability or 0.85) then
                DataService:ConsumeItems(player, needsDisplayNames) -- design choice: consume on failure
                Remotes.CraftingState:FireClient(player, "fail", "Unstable reaction")
                return
            end

            -- Consume inputs using display names
            DataService:ConsumeItems(player, needsDisplayNames)
            
            -- Grant outputs using display names
            for giveId, qty in pairs(result.gives) do
                local displayName = (Items[giveId] and Items[giveId].name) or giveId
                DataService:AddItem(player, displayName, qty)
            end

            Remotes.CraftingState:FireClient(player, "success")
            Remotes.CraftedToast:FireClient(player, result.gives)
        end)

        Remotes.ToggleCrafting.OnServerEvent:Connect(function(player, isOpen)
            Remotes.CraftingState:FireClient(player, isOpen and "open" or "close")
        end)
    end)

    if not ok then
        warn("[CraftingService] Failed to connect to remotes:", err)
    else
        print("[CraftingService] Remote handlers connected successfully")
    end
end

return CraftingService