local RuleEngine = require(script.Parent.RuleEngine)
local RecipeBook = {}
function RecipeBook.resolve(station, ingredientList, playerSeed)
    return RuleEngine.resolve(station, ingredientList, playerSeed)
end
return RecipeBook