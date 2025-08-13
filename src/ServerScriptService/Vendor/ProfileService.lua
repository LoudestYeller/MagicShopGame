-- ProfileService mock for Magic Shop Game
-- This is a simplified version for development - replace with real ProfileService in production

local ProfileService = {}
ProfileService.LoadedProfileCount = 0

local ProfileStore = {}
ProfileStore.__index = ProfileStore

function ProfileStore:LoadProfileAsync(profileKey, forceLoad)
    local profile = {
        Data = {},
        ProfileKey = profileKey,
        _reconciled = false,
        _released = false,
        _releaseCallbacks = {}
    }
    
    function profile:Reconcile()
        if not self._reconciled then
            -- Apply default values for missing keys
            self._reconciled = true
        end
    end
    
    function profile:Release()
        if not self._released then
            self._released = true
            for _, callback in ipairs(self._releaseCallbacks) do
                callback()
            end
        end
    end
    
    function profile:ListenToRelease(callback)
        table.insert(self._releaseCallbacks, callback)
    end
    
    ProfileService.LoadedProfileCount = ProfileService.LoadedProfileCount + 1
    return profile
end

function ProfileService.GetProfileStore(storeName, defaultData)
    local store = setmetatable({
        _storeName = storeName,
        _defaultData = defaultData or {}
    }, ProfileStore)
    
    return store
end

return ProfileService