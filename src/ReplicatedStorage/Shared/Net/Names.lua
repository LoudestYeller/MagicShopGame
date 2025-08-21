*** Begin File
-- Canonical networking manifest used by RemotesService and clients.
-- Do not add/remove without updating both ends.
return {
Events = {
"InventoryUpdated",
"ToggleCrafting",
"CraftingState",
"DisplayCaseUpdated",
"DevGive",
},
Functions = {
"InventorySnapshot",
"DisplayCaseRequest",
"RequestCraft",
},
}
*** End File