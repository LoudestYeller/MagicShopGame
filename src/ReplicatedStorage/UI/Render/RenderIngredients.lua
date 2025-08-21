--!strict
local IngredientBadge = require(script.Parent.Parent.Components.IngredientBadge)

local M = {}

-- items: { {icon="rbxassetid://…", name="Glowing Mushroom", qty=2}, ... }
function M.render(theme: any, grid: Instance, items: {any}?)
    if not items then
        for _, c in ipairs(grid:GetChildren()) do
            if not c:IsA("UIGridLayout") and not c:IsA("UIListLayout") then c:Destroy() end
        end
        return
    end

    -- clear old (keep layout objects)
    for _, c in ipairs(grid:GetChildren()) do
        if not c:IsA("UIGridLayout") and not c:IsA("UIListLayout") then c:Destroy() end
    end

    for _, it in ipairs(items) do
        local badge = IngredientBadge.create(theme, {
            icon = it.icon,
            name = it.name or it.itemId,
            qty = it.qty or 1,
        })
        badge.Parent = grid
    end
end

return M