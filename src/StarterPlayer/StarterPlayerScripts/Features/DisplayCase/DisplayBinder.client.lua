-- StarterPlayer/.../DisplayBinder.client.lua
-- Binds 'L' to open/close the Display UI via its module API. No yield on unknown objects.

local ContextActionService = game:GetService("ContextActionService")

local DisplayUI = require(script.Parent:WaitForChild("DisplayUI"))

local open = false
local function toggle()
    open = not open
    if open then
        print("[DisplayBinder] DisplayUI Enabled = true")
        DisplayUI.Open()
    else
        print("[DisplayBinder] DisplayUI Enabled = false")
        DisplayUI.Close()
    end
end

local function onAction(_, state)
    if state == Enum.UserInputState.Begin then
        toggle()
    end
end

ContextActionService:BindAction("ToggleDisplayUI", onAction, false, Enum.KeyCode.L)
print("📦 [DisplayBinder] Ready! Press L to toggle or use prompt")