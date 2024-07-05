--!strict
local module = {}

--// Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Types
export type GamepassDataStructure = {
	Name: string,
	Description: string,
	IconImageAssetId: number,
	ProductId: number,
	PriceInRobux: number,
}

--// Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local MainMenuUI = PlayerGui:WaitForChild("MainMenuUI")

local Client = LocalPlayer.PlayerScripts.Client

local InfoOptions = MainMenuUI.Menu.GameInfoFrame.GameInfo.TipOptions

local ClientModules = {
	TransitionEffect = require(Client.Interface.TransitionEffect),
	ButtonEffect = require(Client.Misc.ButtonEffect)
}

local HubContent = ReplicatedStorage:WaitForChild("HubContent")
local Packages = HubContent:WaitForChild("Packages")

local MaidModule = require(Packages.Maid)
local Maid = MaidModule.new()

--// Functions

--// Module Functions

function module:Initialise()
    Maid:GiveTask(InfoOptions.Apply.InterviewBT.Activated:Connect(function()
        ClientModules.ButtonEffect(InfoOptions.Apply.InterviewBT)
		
		ClientModules.TransitionEffect:SolidColourTransition(
			MainMenuUI.Menu.GameInfoFrame,
			nil,
			Color3.fromHex("#353535"),
			nil,
			nil,
			true
		)

		HubContent.Remotes.HubFunction:InvokeServer({
			Action = "PlayGame",
            Place = "InterviewCenter"
		})
    end))

    
    Maid:GiveTask(InfoOptions.Apply.QuizCenterBT.Activated:Connect(function()
        ClientModules.ButtonEffect(InfoOptions.Apply.QuizCenterBT)
		
		ClientModules.TransitionEffect:SolidColourTransition(
			MainMenuUI.Menu.GameInfoFrame,
			nil,
			Color3.fromHex("#353535"),
			nil,
			nil,
			true
		)

		HubContent.Remotes.HubFunction:InvokeServer({
			Action = "PlayGame",
            Place = "QuizCenter"
		})
    end))

    
    Maid:GiveTask(InfoOptions.Apply.RankCenterBT.Activated:Connect(function()
        ClientModules.ButtonEffect(InfoOptions.Apply.RankCenterBT)
		
		ClientModules.TransitionEffect:SolidColourTransition(
			MainMenuUI.Menu.GameInfoFrame,
			nil,
			Color3.fromHex("#353535"),
			nil,
			nil,
			true
		)

		HubContent.Remotes.HubFunction:InvokeServer({
			Action = "PlayGame",
            Place = "RankCenter"
		})
    end))

end

--// Return :)
return module