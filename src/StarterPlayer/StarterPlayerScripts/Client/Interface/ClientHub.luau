local module = {}
--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local MainMenuUI = PlayerGui:WaitForChild("MainMenuUI")

local GameHub = MainMenuUI.Menu.GameHubFrame.GameHub
local TeleportOptions = GameHub.TeleportsArea.Area
local ServerBrowser = GameHub.Servers.ServersArea.Contents
local ServerBrowser_Area = GameHub.Servers.Area

local HubContent = ReplicatedStorage:WaitForChild("HubContent")
local HubInformation = require(HubContent.HubInformation)
local Maid = require(HubContent.Packages.Maid).new()
local HubObjects = HubContent.Objects

--// Functions

function CleanUp()
	Maid:DoCleaning()
end

function Refresh()
	CleanUp()
	module:Initialise()
end

function GetPlayerImage(UserID)
	return Players:GetUserThumbnailAsync(UserID, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size60x60)
end

function IsFriended(Player: Player, OtherUserID: number)
	return Player:IsFriendsWith(OtherUserID)
end

function LoadServers(CodeName, TileData)
	Refresh()
	GameHub.Servers.Visible = true
	GameHub.TeleportsArea.Visible = false

	for _, v in pairs(ServerBrowser:GetChildren()) do
		if not v:IsA("Frame") then
			continue
		end

		v:Destroy()
	end

	local ActiveServers = HubContent.Remotes.HubFunction:InvokeServer({
		Action = "GetServers",
		Place = CodeName,
	})

	local PlayersOnline = 0
	local FriendsPlaying = 0

	for index, ServerData in pairs(ActiveServers) do
		local NewServer = HubObjects.ServerTemplate:Clone()
		for _, v in pairs(NewServer.PlayerList.Contents:GetChildren()) do
			if not v:IsA("ImageLabel") then
				continue
			end

			v:Destroy()
		end

		NewServer.ServerName.Text = `Server #{tostring(index)}   ({ServerData.ServerID})`
		NewServer.GameIcon.Image = TileData.Image[math.random(1, #TileData.Image)]

		for _, UserID in pairs(ServerData.CurrentPlayers) do
			local Success, AvatarLink = pcall(GetPlayerImage, UserID)
			if not Success then
				continue
			end

			local AvatarImage = HubObjects.AvatarTemplate:Clone()
			AvatarImage.Image = AvatarLink

			AvatarImage.Parent = NewServer.PlayerList.Contents

			PlayersOnline = PlayersOnline + 1

			local Success_, IsFriends = pcall(IsFriended, LocalPlayer, UserID)
			if Success_ and IsFriends then
				FriendsPlaying = FriendsPlaying + 1
			end
		end

		NewServer.Parent = ServerBrowser
	end

    ServerBrowser_Area.TotalOnline.Text = `{tostring(PlayersOnline)} Online`
    ServerBrowser_Area.FriendsInGame.Text = `{tostring(FriendsPlaying)} Friends In-Game`
end

--// Module Functions

function module:Initialise()
	Maid:GiveTask(GameHub.Servers.Area.BackBT.Activated:Connect(function()
		GameHub.Servers.Visible = false
		GameHub.TeleportsArea.Visible = true
	end))

	for _, v in pairs(TeleportOptions:GetChildren()) do
		local TileData = HubInformation.Tiles[v.Name]
		if not TileData then
			continue
		end
		v.GameTitle.Text = TileData.Name
		v.GameIcon.Image = TileData.Image[math.random(1, #TileData.Image)]

		Maid:GiveTask(v.PlayBtn.Activated:Connect(function()
			HubContent.Remotes.HubFunction:InvokeServer({
				Action = "PlayGame",
				Place = v.Name,
			})
		end))

		Maid:GiveTask(v.ServersBtn.Activated:Connect(function()
			LoadServers(v.Name, TileData)
		end))
	end
end

--// Return :)
return module
