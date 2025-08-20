local Config = {}

-- Remote schema: MATCH CLIENTS EXACTLY
Config.Remotes = {
    Events    = { "InventoryUpdated", "ToggleCrafting", "CraftingState", "DisplayCaseUpdated", "DevGive" },
    Functions = { "InventorySnapshot", "DisplayCaseRequest", "RequestCraft" },
}

-- Profile defaults (expand as needed)
Config.ProfileDefault = {
    cash = 0,
    inv  = {},     -- [itemId] = qty
    flags = {      -- example player flags
        tutorial = { seen = false },
    },
}

-- Health intervals (seconds)
Config.Health = {
    initialDelay = 2,
    cadence      = 10,
}

return Config