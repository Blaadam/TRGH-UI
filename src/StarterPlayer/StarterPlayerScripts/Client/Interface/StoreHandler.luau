local Handler = {}
--// Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local MainMenuUI = PlayerGui:WaitForChild("MainMenuUI")

local StoreUI = MainMenuUI.Menu.StoreFrame.Store
local StoreOptions = StoreUI.TipOptions

local HubContent = ReplicatedStorage:WaitForChild("HubContent")
local HubInformation = require(HubContent.HubInformation)
local Maid = require(HubContent.Packages.Maid).new()
local HubObjects = HubContent.Objects

local Client = LocalPlayer.PlayerScripts.Client

local Library = {
	ButtonEffect = require(Client.Misc.ButtonEffect),
}

local db = false

--// Functions

function GetGamepassData(assetID: number)
	return MarketplaceService:GetProductInfo(assetID, Enum.InfoType.GamePass)
end

function TabClicked(buttonName: string)
	for _, v in pairs(StoreOptions:GetChildren()) do
		if not v:IsA("TextButton") then
			continue
		end

		task.spawn(function()
			local OldStroke = v:FindFirstChild("UIStroke", true)
			if OldStroke then
				OldStroke:Destroy()
			end

			local Stroke: UIStroke = nil

			if v.Name == buttonName then
				Stroke = HubObjects.SelectedUIStroke:Clone()
			else
				Stroke = HubObjects.DefaultUIStroke:Clone()
			end

			Stroke.Name = "UIStroke"
			Stroke.Parent = v.bg

			local TabSection = string.sub(v.Name, 1, string.len(v.Name) - 2)

			local Frame: Frame = StoreOptions:FindFirstChild(TabSection .. "Frame")
			if Frame then
				Frame.Visible = v.Name == buttonName
			end
		end)
	end
end

--// Module Functions

function Handler:Initialise()
	--//// Gamepass Handling
	for _, v in pairs(StoreOptions.PassesFrame.Passes:GetChildren()) do
		if not v:IsA("Frame") then
			continue
		end
		v:Destroy()
	end

	for _, GamepassID in pairs(HubInformation.Gamepasses) do
		local Success, GamepassData = pcall(GetGamepassData, GamepassID)
		if not Success then
			print("No success :(")
			continue
		end

		local TemplateClone = HubObjects.GamepassTemplate:Clone()
		TemplateClone.PassName.Text = GamepassData.Name
		TemplateClone.Avatar.Image = "rbxassetid://" .. GamepassData.IconImageAssetId
		TemplateClone.CostHolder.Cost.Text = GamepassData.PriceInRobux or "error"
		Maid:GiveTask(TemplateClone.BuyBT.Activated:Connect(function()
			Library.ButtonEffect(TemplateClone.BuyBT)
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, GamepassID)
		end))

		TemplateClone.Parent = StoreOptions.PassesFrame.Passes
	end

	--//// Tab Handling

	for _, v in pairs(StoreOptions:GetChildren()) do
		if not v:IsA("TextButton") then
			continue
		end
		Maid:GiveTask(v.Activated:Connect(function()
			if db then
				return
			end
			db = true
			TabClicked(v.Name)
			Library.ButtonEffect(v)
			task.wait(0.35)
			db = false
		end))
	end
end

--// Return :)
return Handler
