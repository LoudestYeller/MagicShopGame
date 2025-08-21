# MagicShop Project Guide

This document outlines the architecture and coding patterns for the MagicShop game.

## Service Architecture

- Services are ModuleScripts in `ServerScriptService/Services`
- Each service exports an interface with `Init()` and `Start()` methods
- Services are loaded via `ServiceLoader` in a defined order
- Services communicate via direct requires (no events between services)

### Service Template
```lua
local Service = {}

function Service:Init()
    -- Set up dependencies, create remotes
    -- Do not reference other services here
end

function Service:Start()
    -- Connect events, start timers
    -- Safe to reference other services
end

return Service
```

## Remote Events

All remotes are created and validated in `RemotesService`. Services request remotes they need:

```lua
-- In a service:
local remotes = require("RemotesService")
local myRemote = remotes:GetRemote("RemoteName")
```

### Remote Naming Patterns

- Client → Server: `Request[Action]` (eg. RequestCraft)
- Server → Client: `[Thing]Updated` (eg. InventoryUpdated)
- Bidirectional: `Toggle[Feature]` (eg. ToggleCrafting)

## Client Architecture

- UI controllers go in `StarterPlayerScripts/Features/[Feature]`
- Each feature has its own folder with UI script + supporting modules
- UI controllers should be self-contained and not reference each other
- Use `UIBootstrap` to mount GUIs from ReplicatedStorage

### Client Template
```lua
local Players = game:GetService("Players")
local remotes = require(game:GetService("ReplicatedStorage").Remotes)

local Controller = {}

function Controller:Init()
    -- Set up UI, connect to remotes
end

function Controller:Start()
    -- Start any background tasks
end

return Controller
```

## Testing

- Test files go next to the module they test with `.spec.lua` extension
- Use TestEZ for unit tests
- Run tests via `npm run test` before committing

## Current Remotes List

Server → Client:
- InventoryUpdated
- CashUpdated
- DisplayCaseUpdated
- CraftingState
- CraftedToast

Client → Server:
- RequestCraft
- DisplayCaseRequest
- ToggleCrafting

## Code Style

- Use `game:GetService()` for services
- No global state - use modules and OOP patterns
- Remote validation happens in RemotesService
- Follow existing naming conventions in codebase
- Run StyLua + Selene before committing

## File Organization

```
src/
  ReplicatedStorage/
    Shared/           # Shared constants and types
    Remotes/          # Remote events (managed by RemotesService)
  ServerScriptService/
    Services/         # Core game services
    Setup/           # One-time setup scripts
  StarterPlayer/
    StarterPlayerScripts/
      Features/      # UI controllers by feature
```