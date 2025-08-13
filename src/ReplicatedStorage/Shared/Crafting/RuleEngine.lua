local Ingredients = require(script.Parent.IngredientDB)
local Effects     = require(script.Parent.EffectsDB)
local Named       = require(script.Parent.RecipesDB)

local RuleEngine = {}

-- oppositions diminish stability if mixed
local oppositions = { fire="frost", frost="fire", light="shadow", shadow="light", air="earth", earth="air" }

-- dominant tag → default effect (procedural)
local tagToEffect = { fire="warmth", frost="frostward", air="haste", shadow="stealth",
                      life="regen", light="luminous", metal="thorns", luck="luck", toxin="antidote" }

-- build name→id map so players can send "Glowing Mushroom" or "glowing_mush"
local NameToId = (function()
    local m = {}
    for id,info in pairs(Ingredients) do
        m[string.lower(id)] = id
        m[string.lower(info.name)] = id
    end
    return m
end)()

local function normalizeIds(inputs)
    local out = {}
    for _,s in ipairs(inputs or {}) do
        local k = string.lower(tostring(s)):gsub("%s+", "_")
        local id = Ingredients[k] and k or NameToId[k]
        if id then table.insert(out, id) end
    end
    return out
end

local function canonicalKey(ids)
    table.sort(ids)
    return table.concat(ids, "+")
end

local function collectTags(ids)
    local tags, raritySum = {}, 0
    for _,id in ipairs(ids) do
        local ing = Ingredients[id]
        if ing then
            raritySum += (ing.rarity or 1)
            for _,t in ipairs(ing.tags or {}) do tags[t]=(tags[t] or 0)+1 end
        end
    end
    return tags, raritySum
end

local function dominantTag(tags)
    local best,score = nil,-1
    for t,v in pairs(tags) do if v > score then best,score = t,v end end
    return best
end

local function baseStability(station, tags)
    local s = (station=="PotionBench" and 0.85) or (station=="Enchanter" and 0.80) or (station=="Forge" and 0.90) or 0.80
    for t,_ in pairs(tags) do
        local opp = oppositions[t]
        if opp and tags[opp] then s -= 0.15 end
    end
    return math.clamp(s, 0.1, 0.95)
end

function RuleEngine.resolve(station, rawInputs, playerSeed)
    -- normalize to canonical ids
    local ids = normalizeIds(rawInputs)
    if #ids == 0 then return { ok=false, reason="invalid_recipe" } end

    -- 1) named recipe wins
    local key = canonicalKey(table.clone(ids))
    local named = Named[station] and Named[station][key]
    if named then
        return {
            ok=true, id=named.id, gives=named.gives, needs=named.needs,
            effect=named.effect, tier=named.tier, xp=named.xp, stability=named.stability
        }
    end

    -- 2) procedural outcome from tags/rarity
    local tags, raritySum = collectTags(ids)
    local dom = dominantTag(tags)
    local effectId = tagToEffect[dom]
    if not effectId then return { ok=false, reason="invalid_recipe" } end

    local tier = math.clamp((raritySum + #ids - 1), 1, 4)
    local stab = baseStability(station, tags)
    local bias = (type(playerSeed)=="number" and (playerSeed - 0.5)*0.1) or 0
    local stability = math.clamp(stab + bias, 0.1, 0.98)

    local productId = (station=="Enchanter" and ("charm_"..effectId))
                   or (station=="Forge"     and ("plating_"..effectId))
                   or ("potion_"..effectId)

    -- infer needs straight from inputs (1 each)
    local needs = {}
    for _,id in ipairs(ids) do needs[id] = (needs[id] or 0) + 1 end

    return {
        ok=true, id=productId, gives={ [productId]=1 }, needs=needs,
        effect=effectId, tier=tier, xp=4 + tier*2, stability=stability
    }
end

return RuleEngine