-- ReplicatedStorage/Shared/Data/ItemRegistry.lua
-- Single registry of all items. UI/Models read from here.

return {
    glowing_mushroom = { name = "Glowing Mushroom", model = "glowing_mushroom", stack = true },
    shadow_moss      = { name = "Shadow Moss",      model = "shadow_moss",      stack = true },
    frostleaf        = { name = "Frostleaf",        model = "frostleaf",        stack = true },
    crystal_flower   = { name = "Crystal Flower",   model = "crystal_flower",   stack = true },
    ember_shard      = { name = "Ember Shard",      model = "ember_shard",      stack = true },
    beast_fat        = { name = "Beast Fat",        model = "beast_fat",        stack = true },

    potion_healing   = { name = "Healing Potion",   model = "potion_healing",   stack = true },
    potion_frostward = { name = "Frostward Potion", model = "potion_frostward", stack = true },
    salve_ice        = { name = "Ice Salve",        model = "salve_ice",        stack = true },
    charm_frost      = { name = "Frost Charm",      model = "charm_frost",      stack = true },
}