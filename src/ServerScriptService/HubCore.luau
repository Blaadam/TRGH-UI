--// Services
local ServerScriptService = game:GetService("ServerScriptService")

--// Variables
local HubModules = ServerScriptService:WaitForChild("HubModules")

--// Functions
local Library = {
    MemoryService = require(HubModules.MemoryService)
}

--// Execution