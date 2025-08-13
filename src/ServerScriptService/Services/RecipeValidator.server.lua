-- ServerScriptService/Services/RecipeValidator.lua
-- Validates single recipes and whole recipe databases.
-- Also provides a canonical key builder for inputs (sorted "id1+id2+...").

local M = {}

-- ////// Configuration //////

-- Extend this set as you add benches
local VALID_BENCHES = {
    PotionBench = true,
    Enchanter = true,
    Forge = true,
    WandTable = true,
}

-- Optional: set of valid item IDs to catch typos. Keep nil to skip.
-- Example usage elsewhere:
--    RecipeValidator.setValidItems({ ember_shard=true, beast_fat=true })
local VALID_ITEMS: {[string]: boolean}? = nil

function M.setValidBenches(list: {string})
    table.clear(VALID_BENCHES)
    for _, b in ipairs(list) do VALID_BENCHES[b] = true end
end

function M.setValidItems(setOrList: any)
    VALID_ITEMS = {}
    if typeof(setOrList) == "table" then
        local isArray = (#setOrList > 0)
        if isArray then
            for _, id in ipairs(setOrList) do VALID_ITEMS[id] = true end
        else
            for id, ok in pairs(setOrList) do if ok then VALID_ITEMS[id] = true end end
        end
    end
end

-- ////// Utilities //////

local function isNonEmptyString(v:any): boolean
    return typeof(v) == "string" and #v > 0
end

local function isPosInt(v:any): boolean
    return typeof(v) == "number" and v >= 1 and v % 1 == 0
end

local function push(t, msg) table.insert(t, msg) end

-- Build a canonical key for a list of ingredients: "a+b+c" (sorted by id)
function M.canonicalKeyFromInputs(inputs: {{id:string, qty:number}}): string
    local ids = {}
    for _, ing in ipairs(inputs or {}) do
        if ing and ing.id then table.insert(ids, tostring(ing.id)) end
    end
    table.sort(ids)
    return table.concat(ids, "+")
end

-- ////// Core validation //////

-- Validates a single ingredient entry.
local function validateIngredient(ing:any, where:string, i:number, errors:{string})
    if typeof(ing) ~= "table" then
        return push(errors, ("%s[%d] must be a table"):format(where, i))
    end
    if not isNonEmptyString(ing.id) then
        push(errors, ("%s[%d].id must be non-empty string"):format(where, i))
    elseif VALID_ITEMS and not VALID_ITEMS[ing.id] then
        push(errors, ("%s[%d].id '%s' not found in item index"):format(where, i, tostring(ing.id)))
    end
    if not isPosInt(ing.qty) then
        push(errors, ("%s[%d].qty must be a positive integer"):format(where, i))
    end
end

-- Validate one recipe object
function M.validate(recipe:any): (boolean, {string}?)
    local errors = {}

    if typeof(recipe) ~= "table" then
        return false, {"Recipe must be a table"}
    end

    -- bench
    if not isNonEmptyString(recipe.bench) then
        push(errors, "bench must be a non-empty string")
    elseif not VALID_BENCHES[recipe.bench] then
        push(errors, "bench '"..tostring(recipe.bench).."' is not in VALID_BENCHES")
    end

    -- inputs
    if typeof(recipe.inputs) ~= "table" or #recipe.inputs < 1 then
        push(errors, "inputs must be an array with at least 1 ingredient")
    else
        for i, ing in ipairs(recipe.inputs) do
            validateIngredient(ing, "inputs", i, errors)
        end
    end

    -- outputs
    if typeof(recipe.outputs) ~= "table" or #recipe.outputs < 1 then
        push(errors, "outputs must be an array with at least 1 ingredient")
    else
        for i, ing in ipairs(recipe.outputs) do
            validateIngredient(ing, "outputs", i, errors)
        end
    end

    -- optional craft time (seconds)
    if recipe.time ~= nil and not isPosInt(recipe.time) then
        push(errors, "time must be a positive whole number of seconds if provided")
    end

    -- optional difficulty / xp, keep loose but sane if present
    if recipe.difficulty ~= nil and typeof(recipe.difficulty) ~= "number" then
        push(errors, "difficulty must be a number if provided")
    end
    if recipe.xp ~= nil and not isPosInt(recipe.xp) then
        push(errors, "xp must be a positive integer if provided")
    end

    -- duplicate ingredient IDs in inputs/outputs (warn, as some designs allow stacks)
    local seenIn, seenOut = {}, {}
    if typeof(recipe.inputs) == "table" then
        for _, ing in ipairs(recipe.inputs) do
            if ing and ing.id then
                if seenIn[ing.id] then push(errors, "inputs has duplicate id: "..ing.id) end
                seenIn[ing.id] = true
            end
        end
    end
    if typeof(recipe.outputs) == "table" then
        for _, ing in ipairs(recipe.outputs) do
            if ing and ing.id then
                if seenOut[ing.id] then push(errors, "outputs has duplicate id: "..ing.id) end
                seenOut[ing.id] = true
            end
        end
    end

    return #errors == 0, (#errors > 0 and errors or nil)
end

-- Validate an entire recipes table (map or array). Returns ok, errorMap
function M.validateAll(recipes:any): (boolean, {[string]: {string}})
    local errorMap: {[string]: {string}} = {}

    if typeof(recipes) ~= "table" then
        return false, { ["<root>"] = {"Recipes must be a table"} }
    end

    local allOk = true
    for key, rec in pairs(recipes) do
        local ok, errs = M.validate(rec)
        if not ok then
            allOk = false
            errorMap[tostring(key)] = errs
        end
    end

    -- Optional: check for canonical key collisions if keys are strings
    -- (only runs if recipe keys look like "a+b+c" style)
    local seen = {}
    for key, rec in pairs(recipes) do
        if typeof(key) == "string" and typeof(rec) == "table" and typeof(rec.inputs) == "table" then
            local canon = M.canonicalKeyFromInputs(rec.inputs)
            if canon ~= "" then
                if seen[canon] and seen[canon] ~= key then
                    allOk = false
                    errorMap[key] = errorMap[key] or {}
                    table.insert(errorMap[key], ("canonical key collision with '%s' (canon '%s')"):format(tostring(seen[canon]), canon))
                else
                    seen[canon] = key
                end
            end
        end
    end

    return allOk, errorMap
end

-- ////// Boot validation for our current recipe format //////

-- Validate our current RecipesDB format and IngredientDB
local function validateCurrentSystem()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    local success, result = pcall(function()
        local Shared = ReplicatedStorage:WaitForChild("Shared")
        local CraftingFolder = Shared:WaitForChild("Crafting")
        local Ingredients = require(CraftingFolder:WaitForChild("IngredientDB"))
        local RecipesDB = require(CraftingFolder:WaitForChild("RecipesDB"))
        
        -- Set up valid items from IngredientDB
        M.setValidItems(Ingredients)
        
        local totalRecipes = 0
        local stationCount = 0
        local errors = {}
        
        for station, recipes in pairs(RecipesDB) do
            stationCount = stationCount + 1
            for recipeKey, recipeData in pairs(recipes) do
                totalRecipes = totalRecipes + 1
                
                -- Validate that ingredients in 'needs' exist
                if recipeData.needs then
                    for itemId, qty in pairs(recipeData.needs) do
                        if not Ingredients[itemId] then
                            table.insert(errors, ("Recipe %s.%s needs unknown ingredient: %s"):format(station, recipeKey, itemId))
                        end
                    end
                end
                
                -- Validate recipe key is canonical (sorted)
                local ingredients = {}
                for ingredient in string.gmatch(recipeKey, "([^+]+)") do
                    table.insert(ingredients, ingredient)
                end
                table.sort(ingredients)
                local canonical = table.concat(ingredients, "+")
                if canonical ~= recipeKey then
                    table.insert(errors, ("Recipe key %s.%s is not canonical, should be: %s"):format(station, recipeKey, canonical))
                end
            end
        end
        
        if #errors > 0 then
            warn("[RecipeValidator] Found issues:")
            for _, err in ipairs(errors) do
                warn("  " .. err)
            end
        else
            print(("[RecipeValidator] ✅ OK: %d stations, %d named recipes, all ingredients valid"):format(stationCount, totalRecipes))
        end
        
        return stationCount, totalRecipes, #errors
    end)
    
    if not success then
        warn("[RecipeValidator] Failed to validate:", result)
        return false
    end
    
    return true
end

-- Run validation on startup
validateCurrentSystem()

return M