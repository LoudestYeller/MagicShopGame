-- ShopKit main module
-- Provides access to shop building and management tools

local ShopKit = {}

-- Re-export all the modules for convenience
ShopKit.Catalog = require(script.Modules.ShopCatalog)
ShopKit.SocketBinder = require(script.Modules.SocketBinder)

-- Factory modules
ShopKit.Factories = {
    Shell = require(script.Modules.Factory_Shell),
    DisplayCounter = require(script.Modules.Factory_DisplayCounter),
    CraftingPotion = require(script.Modules.Factory_CraftingPotion),
    Banner = require(script.Modules.Factory_Banner),
}

return ShopKit