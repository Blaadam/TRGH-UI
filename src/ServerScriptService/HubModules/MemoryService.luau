--[[
	Utilised for interactions in between experiences
	Last modified by blaadam, 2024-07-05
	
	local ServerData = {
		ServerID = nil,
		ReserveCode = nil,
		
		CurrentPlayers = {},
		MaxPlayers = 50,
		ReservedSpots = 5,
		
		RegionLocation = "Unknown",
		Ping = 0,
		
		Locked = false,
		Shutdown = false,
	}
]]

local Lib = {}

--// Services
local MemoryStoreService = game:GetService("MemoryStoreService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

--// Variables
local ServerRefreshRate = 1500
local PlayerCountData = DataStoreService:GetDataStore("PlayerCount")

local HubContent = ReplicatedStorage:WaitForChild("HubContent")

local SortedMaps = {}
local Queues = {}
local PlayerDebounce = {}
local PlayerActiveQueue = {}

local HubInformation = require(HubContent.HubInformation)
local BypassUsers = HubInformation.HubBypass

local VersionControl = "Test0_"
local ServerTiles = HubInformation.Tiles

--// Functions

function UpdatePlayers(PlaceId, ServerID, PlayerList)
	local Current = PlayerCountData:GetAsync(PlaceId .. "_" .. ServerID)
	if Current == nil then
		Current = PlayerCountData:SetAsync(PlaceId .. "_" .. ServerID, PlayerList)
	else
		PlayerCountData:UpdateAsync(PlaceId .. "_" .. ServerID, function()
			return PlayerList
		end)
	end
end

function GetPlayers(PlaceId, ServerID)
	local Current = PlayerCountData:GetAsync(PlaceId .. "_" .. ServerID)

	return Current
end

function GetSortedMap(PlaceId)
	local SortedMap = nil
	if SortedMaps[PlaceId] then
		SortedMap = SortedMaps[PlaceId]
	else
		SortedMaps[PlaceId] = MemoryStoreService:GetSortedMap(VersionControl .. PlaceId)
		SortedMap = SortedMaps[PlaceId]
	end

	return SortedMap
end

function GetQueue(PlaceId, ServerID)
	local Queue = nil
	if Queues[PlaceId .. "_" .. ServerID] then
		Queue = Queues[PlaceId .. "_" .. ServerID]
	else
		Queues[PlaceId .. "_" .. ServerID] = MemoryStoreService:GetQueue(PlaceId .. "_" .. ServerID, 30)
		Queue = Queues[PlaceId .. "_" .. ServerID]
	end

	return Queue
end

function GetServersByPlaceId(PlaceId)
	local Servers = {}

	local SortedMap = GetSortedMap(PlaceId)
	local RangeAsync = SortedMap:GetRangeAsync(0, 200)
	for _, ServerInfo in pairs(RangeAsync) do
		local ServerData = ServerInfo.value
		local Players = GetPlayers(PlaceId, ServerData.ServerID)
		ServerData.CurrentPlayers = Players
		table.insert(Servers, ServerData)
	end

	return Servers
end

function GetServerData(PlaceId, ServerID)
	local ServerData = GetSortedMap(PlaceId):GetAsync(ServerID)
	local PlayerList = GetPlayers(PlaceId, ServerID)
	ServerData.CurrentPlayers = PlayerList
	
	if not ServerData.ServerId then
		ServerData.ServerId = ServerID
	end

	return ServerData
end

function UpdateServerData(PlaceId, ServerID, ServerData)
	local ToUpdate = ServerData
	local PlayerList = ServerData.CurrentPlayers or {}
	ToUpdate.CurrentPlayers = {}

	local function transformFunction()
		return ToUpdate
	end

	if typeof(ToUpdate.RegionLocation) == "table" then
		ToUpdate.RegionLocation = ToUpdate.RegionLocation.countryCode .. "-" .. ToUpdate.RegionLocation.region
	end

	UpdatePlayers(PlaceId, ServerID, PlayerList)
	GetSortedMap(PlaceId):UpdateAsync(ServerID, transformFunction, ServerRefreshRate)
end

function DeleteServerData(PlaceId, ServerID)
	GetSortedMap(PlaceId):RemoveAsync(ServerID)
end

function CheckMod(Player)
	local isMod = false

	for _, v in pairs(BypassUsers) do
		if Player.UserId == v then
			isMod = true
			break
		end
	end

	if isMod then
		return isMod
	end

	return isMod
end

function canJoinServer(Player, Server)
	local can = false

	if #Server.CurrentPlayers < Server.MaxPlayers then
		can = true
	elseif
		#Server.CurrentPlayers >= Server.MaxPlayers
		and #Server.CurrentPlayers < (Server.MaxPlayers + Server.ReservedSpots)
	then
		if table.find(BypassUsers, Player.UserId) then
			can = true
		end
	end

	if Server.GameLocked and CheckMod(Player) then
		can = true
	elseif Server.GameLocked then
		can = false
	end

	return can
end

function GetPriorityLevel(Player)
	local PriorityLevel = {
		Regular = 0,
		QA = 1,
		Developer = 2,
	}

	local Priority = PriorityLevel.Regular

	pcall(function()
		if Player:GetRankInGroup(7132841) >= 252 then
			Priority = PriorityLevel.Developer
		elseif Player:GetRankInGroup(7132841) >= 2 then
			Priority = PriorityLevel.QA
		end
	end)

	return Priority
end

function GetPlaceData(PlaceId)
	local returnData = nil

	for _, TileData in pairs(ServerTiles) do
		if TileData.PlaceId == PlaceId then
			returnData = TileData
		end
	end

	return returnData
end

function GetQueueList(PlaceId, ServerID, Count)
	local Queue = GetQueue(PlaceId, ServerID)
	local QueueList, Id = Queue:ReadAsync(Count, false, 0)

	if Id then
		local success, err = pcall(function()
			Queue:RemoveAsync(Id)
		end)
		if not success then
			print("Error removing from queue: " .. err)
		end
	end
	return QueueList
end

function JoinServerQueue(Player, PlaceId, ServerID, Priority)
	local Queue = GetQueue(PlaceId, ServerID)
	local Success = false
	local AdjustedPriority = GetPriorityLevel(Player) or Priority or 0

	if Queue then
		local success, err = pcall(function()
			Queue:AddAsync(Player.UserId, ServerRefreshRate, AdjustedPriority)
		end)

		if success then
			Success = true
			PlayerActiveQueue[Player.UserId] = {
				PlaceId = PlaceId,
				ServerID = ServerID,
				InQueue = true,
			}
		else
			warn("Could not join queue: " .. err)
		end
	end

	return Success
end

function LeaveServerQueue(Player)
	local PlayerQueue = PlayerActiveQueue[Player.UserId]
	local Success = false

	if PlayerQueue then
		local Queue = GetQueue(PlayerQueue.PlaceId, PlayerQueue.ServerID)

		if Queue then
			local success, err = pcall(function()
				-- SOME METHOD TO REMOVE INDIVIDUALLY??
				Queue:AddAsync(Player.UserId, 1, 0)
			end)
			PlayerActiveQueue[Player.UserId] = {
				PlaceId = nil,
				ServerID = nil,
				InQueue = false,
			}
			if success then
				Success = true
				PlayerActiveQueue[Player.UserId] = nil
				print("Successfully exitted queue")
			else
				warn("Could not exit queue: " .. err)
			end
		end
	end

	return Success
end

function CreateServer(Player, PlaceId)
	local PlaceInfo = GetPlaceData(PlaceId) or { MaxPlayers = 70, DeveloperSlots = 2 }

	local ServerData = {
		ServerID = nil,
		ReserveCode = nil,

		CurrentPlayers = {},
		MaxPlayers = PlaceInfo.MaxPlayers,
		ReservedSpots = PlaceInfo.DeveloperSlots,

		StartTime = 0,
		RegionLocation = nil,
		Ping = 0,

		Locked = false,
		Shutdown = false,
	}

	local TeleportOptions = Instance.new("TeleportOptions")
	TeleportOptions.ShouldReserveServer = true

	local TeleportResult:TeleportAsyncResult = TeleportService:TeleportAsync(PlaceId, { Player }, TeleportOptions)
	
	if PlaceInfo.MaxPlayers > 1 then
		ServerData.ServerID = TeleportResult.PrivateServerId
		ServerData.ReserveCode = TeleportResult.ReservedServerAccessCode
		table.insert(ServerData.CurrentPlayers, Player.UserId)
		UpdatePlayers(PlaceId, ServerData.ServerID, ServerData.CurrentPlayers)
		ServerData.CurrentPlayers = {}
	end
	return ServerData
end

--// Module Functions
function Lib:JoinServerById(Player, PlaceId, ServerID)
	if PlayerDebounce[Player.UserId] == true then
		return
	end
	PlayerDebounce[Player.UserId] = true

	local ServerData = GetServerData(PlaceId, ServerID)

	if ServerData then
		if canJoinServer(Player, ServerData) then
			local function transformFunction()
				return ServerData
			end

			ServerData.CurrentPlayers = GetPlayers(PlaceId, ServerID)

			if not (table.find(ServerData.CurrentPlayers, Player.UserId)) then
				table.insert(ServerData.CurrentPlayers, Player.UserId)
			end
			ServerData.CurrentPlayers = {}
			GetSortedMap(PlaceId):UpdateAsync(ServerData.ServerID, transformFunction, ServerRefreshRate)
			TeleportService:TeleportToPrivateServer(PlaceId, ServerData.ReserveCode, { Player })

			task.delay(5, function()
				PlayerDebounce[Player.UserId] = nil
			end)

			return "Success"
		else
			local Queued = JoinServerQueue(Player, PlaceId, ServerID)

			if Queued == true then
				return "Server is full. Pending in queue. " .. GetPriorityLevel(Player)
			else
				return "Server is full. Could not queue."
			end
		end
	else
		return "No Server Found"
	end
end

function Lib:JoinServer(Player, PlaceId)
	if PlayerDebounce[Player.UserId] == true then
		return
	end
	PlayerDebounce[Player.UserId] = true

	local PlaceInfo = GetPlaceData(PlaceId)

	if PlaceInfo.MaxPlayers == 1 then
		print("Creating Server for 1 Player")
		CreateServer(Player, PlaceId)
		task.delay(30, function()
			PlayerDebounce[Player.UserId] = nil
		end)
		return "Success"
	else
		local Servers = GetServersByPlaceId(PlaceId)
		local ServerData = nil

		if Servers and #Servers > 0 then
			local tempData = {
				PlayerCount = 0,
				ServerID = nil,
			}

			for ServerID, Data in pairs(Servers) do
				if #Data.CurrentPlayers > tempData.PlayerCount or tempData.ServerID == nil then
					if canJoinServer(Player, Data) then
						tempData.ServerID = ServerID
						tempData.PlayerCount = #Data.CurrentPlayers
						ServerData = Data
						break
					end
				end
			end

			if ServerData then
				table.insert(ServerData.CurrentPlayers, Player.UserId)
				--UpdatePlayers(PlaceId,ServerData.ServerID,ServerData.CurrentPlayers)
				ServerData.CurrentPlayers = {}

				local function transformFunction()
					return ServerData
				end
				GetSortedMap(PlaceId):UpdateAsync(ServerData.ServerID, transformFunction, ServerRefreshRate)
				TeleportService:TeleportToPrivateServer(PlaceId, ServerData.ReserveCode, { Player })
				task.delay(10, function()
					PlayerDebounce[Player.UserId] = nil
				end)
				return "Success"
			else
				ServerData = CreateServer(Player, PlaceId)
				GetSortedMap(PlaceId):SetAsync(
					ServerData.ServerID,
					ServerData,
					ServerRefreshRate,
					#ServerData.CurrentPlayers
				)
				task.delay(30, function()
					PlayerDebounce[Player.UserId] = nil
				end)
				return "Success"
			end
		else
			ServerData = CreateServer(Player, PlaceId)
			GetSortedMap(PlaceId):SetAsync(
				ServerData.ServerID,
				ServerData,
				ServerRefreshRate,
				#ServerData.CurrentPlayers
			)
			task.delay(30, function()
				PlayerDebounce[Player.UserId] = nil
			end)
			return "Success"
		end
	end
end

function Lib:CreateServer(Player, PlaceId)
	if PlayerDebounce[Player.UserId] == true then
		return
	end
	PlayerDebounce[Player.UserId] = true

	local ServerData = CreateServer(Player, PlaceId)
	GetSortedMap(PlaceId):SetAsync(ServerData.ServerID, ServerData, ServerRefreshRate, #ServerData.CurrentPlayers)
	task.delay(30, function()
		PlayerDebounce[Player.UserId] = nil
	end)
	return "Success"
end

function Lib:GetServers(PlaceId)
	return GetServersByPlaceId(PlaceId)
end

function Lib:GetServerData(PlaceId, ServerID)
	return GetServerData(PlaceId, ServerID)
end

function Lib:UpdateServerData(PlaceId, ServerID, ServerData)
	return UpdateServerData(PlaceId, ServerID, ServerData)
end

function Lib:DeleteServer(PlaceId, ServerID)
	return DeleteServerData(PlaceId, ServerID)
end

function Lib:UpdatePlayerDatastore(PlaceId, ServerID, PlayerList)
	UpdatePlayers(PlaceId, ServerID, PlayerList)
end

function Lib:LeaveQueue(Player)
	LeaveServerQueue(Player)
end

function Lib:GetQueue(PlaceId, ServerID, Count)
	return GetQueueList(PlaceId, ServerID, Count)
end

function Lib:IsPlayerInQueue(Player, PlaceId, ServerID)
	local PlayerQueue = PlayerActiveQueue[Player.UserId]
	local is = false
	if PlayerQueue then
		if PlayerQueue.PlaceId == PlaceId and PlayerQueue.ServerID == ServerID and PlayerQueue.InQueue == true then
			is = true
		else
			is = false
		end
	end

	return is
end

--// Return
return Lib
