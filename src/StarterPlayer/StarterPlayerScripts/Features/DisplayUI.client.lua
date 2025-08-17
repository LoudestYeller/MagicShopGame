--!strict
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Networking = RS:WaitForChild("Networking", 10)

-- Defensive helpers ----------------------------------------------------------
local function getRemoteEvent(name: string, timeout: number?): RemoteEvent?
    timeout = timeout or 5
    if not Networking then
        Networking = RS:WaitForChild("Networking", timeout)
        if not Networking then
            warn(("[DisplayUI] Networking folder missing (waited %ss)"):format(timeout))
            return nil
        end
    end
    local obj = Networking:FindFirstChild(name) or Networking:WaitForChild(name, timeout)
    if obj and obj:IsA("RemoteEvent") then
        return obj
    end
    warn(("[DisplayUI] RemoteEvent %s not available"):format(name))
    return nil
end

local function getRemoteFunction(name: string, timeout: number?): RemoteFunction?
    timeout = timeout or 5
    if not Networking then
        Networking = RS:WaitForChild("Networking", timeout)
        if not Networking then return nil end
    end
    local obj = Networking:FindFirstChild(name) or Networking:WaitForChild(name, timeout)
    if obj and obj:IsA("RemoteFunction") then
        return obj
    end
    warn(("[DisplayUI] RemoteFunction %s not available"):format(name))
    return nil
end

-- Hook DisplayCaseUpdated safely (retry if needed)
local function connectDisplayUpdates()
    local ev = getRemoteEvent("DisplayCaseUpdated", 10)
    if not ev then
        -- try a few times before giving up
        task.spawn(function()
            for _ = 1, 5 do
                task.wait(1)
                ev = getRemoteEvent("DisplayCaseUpdated", 5)
                if ev then break end
            end
            if not ev then
                warn("[DisplayUI] Could not connect to DisplayCaseUpdated after retries")
                return
            end
            ev.OnClientEvent:Connect(function(userId, displayData)
                -- update UI...
                print("[DisplayUI] Got display update:", userId, displayData)
            end)
        end)
        return
    end
    ev.OnClientEvent:Connect(function(userId, displayData)
        -- update UI...
        print("[DisplayUI] Got display update:", userId, displayData)
    end)
end

connectDisplayUpdates()

-- Handle display case toggle
local function setupDisplayUI()
    local displayFrame = RS:WaitForChild("DisplayUI", 10)
    if not displayFrame then
        warn("[DisplayUI] DisplayUI ScreenGui not found")
        return
    end
    print("[DisplayUI] UI found and ready")
end

-- Connect to toggle events with retry
local function connectToggleEvents()
    local ev = getRemoteEvent("ToggleDisplayCase", 10)
    if not ev then
        warn("[DisplayUI] Could not connect to ToggleDisplayCase")
        return
    end
    ev.OnClientEvent:Connect(function()
        setupDisplayUI()
    end)
end

connectToggleEvents()