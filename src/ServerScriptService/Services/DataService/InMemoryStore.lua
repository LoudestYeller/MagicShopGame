-- === InMemoryStore.lua ===
local InMemoryStore = {}
InMemoryStore._profiles = {}

function InMemoryStore:Load(player)
    local p = self._profiles[player.UserId]
    if not p then
        p = { cash = 50, inv = {} }
        self._profiles[player.UserId] = p
    end
    return p
end

function InMemoryStore:Release(player)
    self._profiles[player.UserId] = nil
end

return InMemoryStore