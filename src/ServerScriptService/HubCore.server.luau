--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Variables
local HubContent = ReplicatedStorage:WaitForChild("HubContent")
local HubRemotes = HubContent:WaitForChild("Remotes")

local HubModules = ServerScriptService:WaitForChild("HubModules")

--// Functions
local Library = {
	MemoryService = require(HubModules.MemoryService),
	HubInformation = require(HubContent.HubInformation)
}

--// Execution
HubRemotes.HubEvent.OnServerEvent:Connect(function(Player, RequestData)
	if not RequestData then return end

	if RequestData.Action == "PlayHospital" then
		Library.MemoryService:JoinServer(Player, Library.HubInformation.Tiles.Hospital.PlaceId)
	end

end)