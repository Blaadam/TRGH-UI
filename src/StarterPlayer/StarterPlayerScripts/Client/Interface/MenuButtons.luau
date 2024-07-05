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

local ButtonsFrame = MainMenuUI.Menu.MenuFrame.ButtonsArea

local ClientModules = {
	TransitionEffect = require(Client.Interface.TransitionEffect),
	ButtonEffect = require(Client.Misc.ButtonEffect)
}

local HubContent = ReplicatedStorage:WaitForChild("HubContent")
local Packages = HubContent:WaitForChild("Packages")

local MaidModule = require(Packages.Maid)
local Maid = MaidModule.new()

--// Functions

--// Module Function

function module:Initialise(SpecialDeal)
	--//// Main Buttons

	--// Load Game
	Maid:GiveTask(ButtonsFrame.PlayBT.Activated:Connect(function()
		ClientModules.ButtonEffect(ButtonsFrame.PlayBT)
		ClientModules.TransitionEffect:SolidColourTransition(
			MainMenuUI.Menu.MenuFrame,
			nil,
			Color3.fromHex("#353535"),
			nil,
			nil,
			true
		)

		HubContent.Remotes.HubFunction:InvokeServer({
			Action = "PlayHospital"
		})
	end))

	--// Game Store
	Maid:GiveTask(ButtonsFrame.StoreBT.Activated:Connect(function()
		ClientModules.ButtonEffect(ButtonsFrame.StoreBT)
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.MenuFrame, MainMenuUI.Menu.StoreFrame)
	end))

	Maid:GiveTask(MainMenuUI.Menu.StoreFrame.Store.CloseBT.Activated:Connect(function()
		ClientModules.ButtonEffect(MainMenuUI.Menu.StoreFrame.Store.CloseBT)
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.StoreFrame, MainMenuUI.Menu.MenuFrame)
	end))

	--// Game Info

	Maid:GiveTask(ButtonsFrame.GameInfoBT.Activated:Connect(function()
		ClientModules.ButtonEffect(ButtonsFrame.GameInfoBT)
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.MenuFrame, MainMenuUI.Menu.GameInfoFrame)
	end))

	Maid:GiveTask(MainMenuUI.Menu.GameInfoFrame.GameInfo.CloseBT.Activated:Connect(function()
		ClientModules.ButtonEffect(MainMenuUI.Menu.GameInfoFrame.GameInfo.CloseBT)
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.GameInfoFrame, MainMenuUI.Menu.MenuFrame)
	end))

	--// Game Hub

	Maid:GiveTask(ButtonsFrame.GameHubBT.Activated:Connect(function()
		ClientModules.ButtonEffect(ButtonsFrame.GameHubBT)
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.MenuFrame, MainMenuUI.Menu.GameHubFrame)
	end))

	Maid:GiveTask(MainMenuUI.Menu.GameHubFrame.GameHub.CloseBT.Activated:Connect(function()
		ClientModules.ButtonEffect(MainMenuUI.Menu.GameHubFrame.GameHub.CloseBT)
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.GameHubFrame, MainMenuUI.Menu.MenuFrame)
	end))

	--//// Screen Defaulting

	task.spawn(function()
		ClientModules.TransitionEffect:TweenTransition(nil, MainMenuUI.Menu.MenuFrame)
	end)
	task.spawn(function()
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.StoreFrame, nil)
	end)
	task.spawn(function()
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.GameInfoFrame, nil)
	end)
	task.spawn(function()
		ClientModules.TransitionEffect:TweenTransition(MainMenuUI.Menu.GameHubFrame, nil)
	end)

	--//// Special Deal Content

	if not SpecialDeal then
		ButtonsFrame.LimitedDeal.Visible = false
		return
	end

	local GamepassData: GamepassDataStructure

	pcall(function()
		local ProductInfo = MarketplaceService:GetProductInfo(SpecialDeal.GamepassID, Enum.InfoType.GamePass)

		if ProductInfo then
			GamepassData = {
				Name = ProductInfo.Name,
				Description = ProductInfo.Description,
				IconImageAssetId = ProductInfo.IconImageAssetId,
				ProductId = ProductInfo.ProductId,
				PriceInRobux = ProductInfo.PriceInRobux,
			}
		end
	end)

	if not GamepassData then
		ButtonsFrame.LimitedDeal.Visible = false
		return
	end

	Maid:GiveTask(ButtonsFrame.LimitedDeal.BuyBT.Activated:Connect(function()
		ClientModules.ButtonEffect(ButtonsFrame.LimitedDeal.BuyBT)
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, SpecialDeal.GamepassID)
	end))

	ButtonsFrame.LimitedDeal.GamepassTitle.Text = GamepassData.Name
	ButtonsFrame.LimitedDeal.Body.Text = GamepassData.Description
	ButtonsFrame.LimitedDeal.NewCost.Text = GamepassData.PriceInRobux
	ButtonsFrame.LimitedDeal.GamepassIcon.Image = "rbxassetid://" .. GamepassData.IconImageAssetId

	ButtonsFrame.LimitedDeal.OldCost.Text = SpecialDeal.OldCost
end

--// Return :)
return module
