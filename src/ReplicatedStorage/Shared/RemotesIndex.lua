local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Networking"):WaitForChild("Remotes")

return {
    -- Inventory remotes
    CashUpdated       = Remotes:WaitForChild("CashUpdated"),
    InventorySnapshot = Remotes:WaitForChild("InventorySnapshot"),
    InventoryUpdated  = Remotes:WaitForChild("InventoryUpdated"),
    RequestInventory  = Remotes:WaitForChild("RequestInventory"),
    
    -- Display case remotes
    DisplayCaseRequest= Remotes:WaitForChild("DisplayCaseRequest"),
    DisplayCaseUpdated= Remotes:WaitForChild("DisplayCaseUpdated"),
    ToggleDisplayCase = Remotes:WaitForChild("ToggleDisplayCase"),
    
    -- Crafting remotes
    RequestCraft      = Remotes:WaitForChild("RequestCraft"),
    ToggleCrafting    = Remotes:WaitForChild("ToggleCrafting"),
    CraftingState     = Remotes:WaitForChild("CraftingState"),
    CraftedToast      = Remotes:WaitForChild("CraftedToast"),
}