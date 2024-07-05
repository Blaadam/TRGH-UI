--[[

This module just creates a click effect.
Its taken from a few projects I've worked on, reliable but I will redo it eventually
- blaadam, 2024-07-05 @ 21:36pm BST

]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- local SpecialButtonNames = {
-- 	"CloseBtn",
-- 	"CloseBT",
-- 	"BuyBT",
-- 	"BuyBtn"
-- }

function MakeCircleInstance()
	local Image: ImageLabel = Instance.new("ImageLabel")
	Image.BackgroundTransparency = 1
	Image.Image = "rbxassetid://266543268"
	Image.ImageColor3 = Color3.new(0, 0, 0)
	Image.ImageTransparency = 0.9
	Image.Size = UDim2.new(0, 0, 0, 0)
	return Image
end

function MakeSound()
	local Sound:Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://6895079853"
	Sound.Volume = 0.1
	Sound.Parent = workspace
	Sound.PlayOnRemove = true
	Sound:Destroy()
end

function CircleClick(Button, X, Y)
	if not X then
		X = Mouse.X
	end

	if not Y then
		Y = Mouse.Y
	end

	local IsCloseBtn = true-- nil ~= table.find(SpecialButtonNames, Button.Name)

	task.spawn(function()
		local OriginalSettings = {}
		local UIGradient = Button:FindFirstChild("UIStroke", true)

		if UIGradient and IsCloseBtn then
			OriginalSettings.Parent = UIGradient.Parent
			OriginalSettings.ApplyStrokeMode = UIGradient.ApplyStrokeMode

			UIGradient.Parent = Button
			UIGradient.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		end

		local save = Button.ClipsDescendants
		Button.ClipsDescendants = true

		local Circle = MakeCircleInstance()
		Circle.Parent = Button
		local NewX = X - Circle.AbsolutePosition.X
		local NewY = Y - Circle.AbsolutePosition.Y
		Circle.Position = UDim2.new(0, NewX, 0, NewY)

		local Size = 0
		if Button.AbsoluteSize.X > Button.AbsoluteSize.Y or Button.AbsoluteSize.X == Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.X * 1.5
		elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
			Size = Button.AbsoluteSize.Y * 1.5
		end

		MakeSound()

		local Time = 0.5
		Circle:TweenSizeAndPosition(
			UDim2.new(0, Size, 0, Size),
			UDim2.new(0.5, -Size / 2, 0.5, -Size / 2),
			"Out",
			"Quad",
			Time,
			false,
			nil
		)
		for _ = 1, 10 do
			Circle.ImageTransparency = Circle.ImageTransparency + 0.01
			task.wait(Time / 10)
		end
		Circle:Destroy()
		Button.ClipsDescendants = save

		if UIGradient and IsCloseBtn then
			if UIGradient.Parent ~= nil then
				UIGradient.Parent = OriginalSettings.Parent
			end
			UIGradient.ApplyStrokeMode = OriginalSettings.ApplyStrokeMode
		end
	end)
end

return CircleClick
