--[[

This module just creates a click effect.
Its taken from a few projects I've worked on, reliable but I will redo it eventually
- blaadam, 2024-07-05 @ 21:36pm BST

]]

function CircleClick(Button, X, Y)
    task.spawn(function()
        local save = Button.ClipsDescendants
		Button.ClipsDescendants = true

		local Circle = script:WaitForChild("Circle"):Clone()
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
		for i = 1, 10 do
			Circle.ImageTransparency = Circle.ImageTransparency + 0.01
			task.wait(Time / 10)
		end
		Circle:Destroy()
		Button.ClipsDescendants = save
    end)
end

return CircleClick
