--!strict

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// Variables
local Interface = script:WaitForChild("Interface")
local HubContent = ReplicatedStorage:WaitForChild("HubContent")

local ClientLibrary = {
	HubInformation = require(HubContent.HubInformation),
	MenuButtons = require(Interface.MenuButtons),
	StoreHandler = require(Interface.StoreHandler)
}

--// Functions

function LogInitialisation(Msg, WarnMsg)
	if RunService:IsStudio() then
		if WarnMsg then
			warn(Msg)
			return
		end

		print(Msg)
	end
end

function LoadGame()
	print("Game is loaded!")
	--@TODO: Write a procedure which loads the user into the experience after the Loading Screen.
end

--// Execution

LogInitialisation("Client Initialisation Begun", true)

ClientLibrary.MenuButtons:Initialise(LoadGame, ClientLibrary.HubInformation.LimitedDealData)
LogInitialisation("Menu Buttons Initialised")

ClientLibrary.StoreHandler:Initialise()
LogInitialisation("Store Handler Initialised")

LogInitialisation("Client Initialisation Complete", true)
