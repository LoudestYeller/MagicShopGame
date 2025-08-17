--!strict
--!strict

export type DailyTrends = {[string]: number}

local PriceBook = {
    -- Basic ingredients
    glowing_mushroom = 5,
    shadow_moss = 5,
    ember_shard = 10,
    beast_fat = 8,
    
    -- Tier 1 potions
    warmth_potion = 25,
    sight_potion = 25,
    health_potion = 30,
    
    -- Tier 2 potions
    strength_potion = 45,
    speed_potion = 45,
    jump_potion = 40,
}

function PriceBook.getSuggestedPrice(itemId: string, qty: number?, trends: DailyTrends?): number
    local base = PriceBook[itemId] or 0
    local trend = trends and trends[itemId] or 1.0
    return math.floor(base * trend + 0.5) * (qty or 1)
end

return PriceBook