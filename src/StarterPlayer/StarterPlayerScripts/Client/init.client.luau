--!strict

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

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

function SetupPlayerCamera()
	local Camera:Camera = workspace.Camera
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = game.Workspace.CameraPart.CFrame

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end

--// Execution

LogInitialisation("Client Initialisation Begun", true)

task.spawn(function()
	pcall(SetupPlayerCamera)
end)

ClientLibrary.MenuButtons:Initialise(LoadGame, ClientLibrary.HubInformation.LimitedDealData)
LogInitialisation("Menu Buttons Initialised")

ClientLibrary.StoreHandler:Initialise()
LogInitialisation("Store Handler Initialised")

LogInitialisation("Client Initialisation Complete", true)
