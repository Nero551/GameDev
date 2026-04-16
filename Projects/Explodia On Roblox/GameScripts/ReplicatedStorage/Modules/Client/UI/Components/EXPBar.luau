local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
return function(menu)
	local player = Players.LocalPlayer
	local level = player:WaitForChild("Level")
	local currentEXP = level:FindFirstChild("CurrentEXP")
	local requiredEXP = level:FindFirstChild("RequiredEXP")

	local expBG = UIManager:GetUI(menu, "EXPBG")
	local expFill = expBG:FindFirstChild("EXPFill")
	local expNumber = expBG:FindFirstChild("EXPNumber")

	local function UpdateEXP()
		local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local ratio = currentEXP:GetAttribute("Amount") / requiredEXP:GetAttribute("Amount")
		ratio = math.clamp(ratio, 0, 1)

		TweenService:Create(expFill, info, { Size = UDim2.fromScale(ratio, 1) }):Play()
		expNumber.Text = math.round(currentEXP:GetAttribute("Amount"))
			.. " / "
			.. math.round(requiredEXP:GetAttribute("Amount"))
	end

	UpdateEXP()
	currentEXP:GetAttributeChangedSignal("Amount"):Connect(UpdateEXP)
	requiredEXP:GetAttributeChangedSignal("Amount"):Connect(UpdateEXP)
end
