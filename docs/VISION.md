# MagicShop Vision & Engineering Rules
**Pillars**
1) Shop-first loop: gather → craft → display → sell → upgrade.
2) Server-authoritative economy (inventory/cash never trust client).
3) Services pattern: `Init()` then `Start()`; loaded via `ServiceLoader.requireService`.
4) Remotes: server-only via `RemotesService`; clients never create remotes.
5) UI control: only DisplayBinder / CraftingBinder toggle screens.
6) Reliability: clear logs; graceful nil-guards; no hidden globals.
7) Performance: avoid tight loops; debounce remotes; throttle UI updates.
8) Style: Luau types; pass Selene; formatted by Stylua.

**File layout**
- `src/ServerScriptService/Services/<Name>/init.lua` exports service table
- `src/StarterPlayer/StarterPlayerScripts/*Binder.client.lua` own UI toggles
- `src/ReplicatedStorage/Networking/*` remotes registry only