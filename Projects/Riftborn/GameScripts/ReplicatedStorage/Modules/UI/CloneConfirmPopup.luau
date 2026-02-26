local player  = game:GetService("Players").LocalPlayer
local repstor = game:GetService("ReplicatedStorage")
local tween = game:GetService("TweenService")

local playerGui = player:WaitForChild("PlayerGui")

local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return function()
	local confirmPopUp
	if confirmPopUp and confirmPopUp.Parent then
		return confirmPopUp
	end

	confirmPopUp = repstor.Assets.GUI.ConfirmPopUp:Clone()
	confirmPopUp.Parent = playerGui.PopUpGui
	confirmPopUp.Visible = false
	
	return confirmPopUp
end