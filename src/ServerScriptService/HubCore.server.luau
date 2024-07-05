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
	HubInformation = require(HubContent.HubInformation),
}

--// Execution
HubRemotes.HubFunction.OnServerInvoke = function(Player, RequestData)
	if not RequestData then
		return
	end

	if RequestData.Action == "PlayHospital" then
		Library.MemoryService:JoinServer(Player, Library.HubInformation.Tiles.Hospital.PlaceId)
	elseif RequestData.Action == "PlayGame" then
		if RequestData.ServerID then
			Library.MemoryService:JoinServerById(
				Player,
				Library.HubInformation.Tiles[RequestData.Place].PlaceId,
				RequestData.ServerID
			)
			return
		end
		Library.MemoryService:JoinServer(Player, Library.HubInformation.Tiles[RequestData.Place].PlaceId)
	elseif RequestData.Action == "GetServers" then
		Library.MemoryService:GetServers(Library.HubInformation.Tiles[RequestData.Place].PlaceId)
	end
end
