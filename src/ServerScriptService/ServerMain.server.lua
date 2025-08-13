print("🚀 Starting MagicShop server...")
print("🧭 ServerMain source:", script:GetFullName())

local RS = game:GetService("ReplicatedStorage")
local ok,version = pcall(function() return require(RS.Shared.Version) end)
if not ok then version = "0.1.0-dev4" end
print(("📋 MagicShop %s"):format(version))

-- Wait for RemotesService to create all remotes first
local Networking = RS:WaitForChild("Networking")
local RemotesFolder = Networking:WaitForChild("Remotes")
print("📡 RemotesService ready")

local ServiceLoader = require(script.Parent:WaitForChild("ServiceLoader"))

print("🔧 Initializing all services...")
ServiceLoader.InitAll()
print("✅ All services initialized")

print("🚀 Starting all services...")
ServiceLoader.StartAll()
print("🛡️ Mirroring cleanup guard activated")
print("✅ Mirroring guard system active")