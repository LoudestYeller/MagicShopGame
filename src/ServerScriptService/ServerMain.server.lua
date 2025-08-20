--!strict
local ServiceLoader = require(script.Parent:WaitForChild("ServiceLoader"))

print("🚀 Starting MagicShop server...")
print("🧭 ServerMain source: " .. script:GetFullName())
print("📋 MagicShop 0.1.0-dev4")
print("🔧 Initializing services...")

ServiceLoader.Init()
print("✅ All services initialized")

print("🚀 Starting all services...")
ServiceLoader.Start()

print("🛡️ Mirroring cleanup guard activated")
print("✅ Mirroring guard system active")