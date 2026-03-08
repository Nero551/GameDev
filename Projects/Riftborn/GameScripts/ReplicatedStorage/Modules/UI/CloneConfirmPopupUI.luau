local Player  = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local playerGui = Player:WaitForChild("PlayerGui")

local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

return function()
	local confirmPopUp
	if confirmPopUp and confirmPopUp.Parent then
		return confirmPopUp
	end

	confirmPopUp = ReplicatedStorage.Assets.GUI.ConfirmPopUp:Clone()
	confirmPopUp.Parent = playerGui.PopUpGui
	confirmPopUp.Visible = false
	
	return confirmPopUp
end