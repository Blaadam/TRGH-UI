local effect = {}

--// Services
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local EffectTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

--// Functions

function NewItem(CLassType: string, Data: table, Child: table)
	local Asset = Instance.new(CLassType)

	for VarName, VarValue in pairs(Data) do
		Asset[VarName] = VarValue
	end

	if Child then
		Child[2].Parent = Asset
		NewItem(table.unpack(Child))
	end

	return Asset
end

--// Variable-Function Assignment
local EffectUI = PlayerGui:FindFirstChild("TransitionEffectUI")
	or NewItem("ScreenGui", {
		Name = "TransitionEffectUI",
		Parent = PlayerGui,
		IgnoreGuiInset = true,
	}, {
		"Frame",
		{
			Name = "SolidColorFrame",
			Visible = true,
			Transparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
		},
	})

--// Module Function

function effect:TweenTransition(Frame1: Frame, Frame2: Frame, FramePos1: UDim2, FramePos2: UDim2)
	if Frame1 then
		local FrameTween =
			TweenService:Create(Frame1, EffectTweenInfo, { Position = FramePos1 or UDim2.new(0.5, 0, 1.5, 0) })
		task.wait(0.1)
		FrameTween:Play()
		Debris:AddItem(FrameTween, EffectTweenInfo.Time + 0.1)
	end

	if Frame2 then
		local FrameTween =
			TweenService:Create(Frame2, EffectTweenInfo, { Position = FramePos2 or UDim2.new(0.5, 0, 0.5, 0) })
		task.wait(0.1)
		FrameTween:Play()
		Debris:AddItem(FrameTween, EffectTweenInfo.Time + 0.1)
	end
end

function effect:SolidColourTransition(
	Frame1: Frame,
	Frame2: Frame,
	SolidColor: Color3,
	FramePos1: UDim2,
	FramePos2: UDim2,
	NoRepeat: boolean
)
	if Frame1 then
		local FrameTween =
			TweenService:Create(Frame1, EffectTweenInfo, { Position = FramePos1 or UDim2.new(0.5, 0, 1.5, 0) })
		task.wait(0.1)
		FrameTween:Play()
		Debris:AddItem(FrameTween, EffectTweenInfo.Time + 0.1)
	end

	local Tween1 = TweenService:Create(EffectUI.SolidColorFrame, EffectTweenInfo, { Transparency = 0 })
	EffectUI.SolidColorFrame.BackgroundColor3 = SolidColor or Color3.fromRGB(0, 0, 0)
	Tween1:Play()
	Tween1.Completed:Wait()
	Debris:AddItem(Tween1)

	task.wait(0.75)

	if Frame2 then
		local FrameTween =
			TweenService:Create(Frame2, EffectTweenInfo, { Position = FramePos2 or UDim2.new(0.5, 0, 0.5, 0) })
		task.wait(0.1)
		FrameTween:Play()
		Debris:AddItem(FrameTween, EffectTweenInfo.Time + 0.1)
	end

	if NoRepeat then
		return
	end

	local Tween2 = TweenService:Create(EffectUI.SolidColorFrame, EffectTweenInfo, { Transparency = 1 })
	EffectUI.SolidColorFrame.BackgroundColor3 = SolidColor or Color3.fromRGB(0, 0, 0)
	Tween2:Play()
	Tween2.Completed:Wait()
	Debris:AddItem(Tween2)
end

return effect
