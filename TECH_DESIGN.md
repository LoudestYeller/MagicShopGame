# Magic Shop — Technical Design (TDD)

Files (Rojo synced):
ReplicatedStorage/
  Shared/
    Items.lua
    Recipes.lua
    Theme.lua
    Contracts.lua
    Version.lua
  Networking/
    Remotes.lua
    CraftingRemotes.lua
ServerScriptService/
  ServerMain.server.lua
  ServiceLoader.lua
  Health.server.lua
  Cleanup.server.lua
  Services/
    DataService.lua
    InventoryService.lua
    CraftingService.lua
    DisplayCaseService.lua
    NPCSalesService.lua
    TutorialService.lua
StarterPlayer/StarterPlayerScripts/Client/
  (all client UIs incl. CraftingUIController.client.lua)

Contracts:
- IDs are snake_case strings; names only for UI.
- DataService:
  Get(player|userId) -> profile
  AddItem(player|userId, id, qty)
  RemoveItem(player|userId, id, qty) -> bool
  Emits Remotes.InventoryUpdated; serves InventorySnapshot.
- CraftingService:
  On RequestCraft(player, station, inputs:{ {id,qty} }, tier),
  validate vs DataService + Recipes.Combine; add result; CraftedToast.
- DisplayCaseService:
  ListItem/EditListing/RemoveListing; emits DisplayCaseUpdated.
- Client UIs:
  bootstrap via InventorySnapshot, then subscribe to InventoryUpdated.

Invariants:
- One remote registry (Networking/Remotes.lua).
- Flat services (single ModuleScript each).
- Health check prints "✅ Health OK (n services, m remotes)" once on boot.