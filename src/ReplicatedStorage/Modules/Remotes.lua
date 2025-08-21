local RS = game:GetService("ReplicatedStorage")
local Folder = RS:WaitForChild("Networking")

local Remotes = {}

function Remotes.GetEvent(name: string): RemoteEvent
local r = Folder:WaitForChild(name)
assert(r:IsA("RemoteEvent"), ("Remote '%s' is %s; expected RemoteEvent"):format(name, r.ClassName))
return r
end

function Remotes.GetFunction(name: string): RemoteFunction
local r = Folder:WaitForChild(name)
assert(r:IsA("RemoteFunction"), ("Remote '%s' is %s; expected RemoteFunction"):format(name, r.ClassName))
return r
end