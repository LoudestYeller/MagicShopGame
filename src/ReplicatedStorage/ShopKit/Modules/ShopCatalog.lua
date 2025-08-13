local ShellFactory   = require(script.Parent.Factory_Shell)
local CounterFactory = require(script.Parent.Factory_DisplayCounter)
local PotionFactory  = require(script.Parent.Factory_CraftingPotion)
local BannerFactory  = require(script.Parent.Factory_Banner)

local Catalog = {}

function Catalog.BuildDefaultShell()
    return ShellFactory.Build()
end

Catalog.DefaultStations = {
    { socket = "Socket:Counter_Main",  build = CounterFactory.Build },
    { socket = "Socket:Crafting_Main", build = PotionFactory.Build },
    { socket = "Socket:Decor_Wall_Front_L", build = BannerFactory.Build },
}

return Catalog