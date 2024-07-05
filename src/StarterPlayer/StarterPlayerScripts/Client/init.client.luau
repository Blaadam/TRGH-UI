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
	StoreHandler = require(Interface.StoreHandler),
	ClientHub = require(Interface.ClientHub),
	InfoButtons = require(Interface.InfoButtons),
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

function SetupPlayerCamera()
	local Camera: Camera = workspace.Camera
	Camera.CameraType = Enum.CameraType.Scriptable

	repeat
		Camera.CameraType = Enum.CameraType.Scriptable
		task.wait()
	until Enum.CameraType.Scriptable == Camera.CameraType

	Camera.CFrame = game.Workspace.CameraPart.CFrame

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
end

--// Execution

LogInitialisation("Client Initialisation Begun", true)

task.spawn(function()
	pcall(SetupPlayerCamera)
end)

ClientLibrary.MenuButtons:Initialise(ClientLibrary.HubInformation.LimitedDealData)
LogInitialisation("Menu Buttons Initialised")

ClientLibrary.StoreHandler:Initialise()
LogInitialisation("Store Handler Initialised")

ClientLibrary.ClientHub:Initialise()
LogInitialisation("Client Hub Initialised")

ClientLibrary.InfoButtons:Initialise()
LogInitialisation("Info Buttons Initialised")

LogInitialisation("Client Initialisation Complete", true)
