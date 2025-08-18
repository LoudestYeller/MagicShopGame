--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local okTheme, Theme = pcall(function() return require(ReplicatedStorage.UI.Theme) end)
if not okTheme then warn("[CraftingUI] Theme missing") return end

local okTpl, CraftingTpl = pcall(function()
    return require(ReplicatedStorage.UI.Templates.CraftingUITemplate)
end)
if not okTpl then warn("[CraftingUI] Template missing") return end

local screen, refs = CraftingTpl.build(Theme)
screen.Enabled = false
screen.Parent = player:WaitForChild("PlayerGui")

-- Example: populate the list (replace with your real recipe list)
local okRow, RecipeRow = pcall(function()
    return require(ReplicatedStorage.UI.Components.RecipeRow)
end)
if not okRow then warn("[CraftingUI] RecipeRow missing") return end

local function addRecipe(name: string, icon: string, info: string, canCraft: boolean)
    local row, r = RecipeRow.create(Theme, {name=name, icon=icon, info=info, canCraft=canCraft})
    row.Parent = refs.RecipesList
    r.CraftButton.MouseButton1Click:Connect(function()
        -- fire your RequestCraft remote here with selected qty, etc.
    end)
    row.InputBegan:Connect(function(input)
        -- when selected, update details panel
        refs.DetailName.Text = name
        refs.DetailIcon.Image = icon
        -- TODO: render ingredients into refs.IngredientsGrid
    end)
end
-- addRecipe("Health Tonic", "rbxassetid://<id>", "Cost: 2 shrooms • 1 fat", true)