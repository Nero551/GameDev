local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)

return function(menu)
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local staminaBG = UIManager:GetUI(menu, "StaminaBG")
	local staminaFill = staminaBG:FindFirstChild("StaminaFill")
	local staminaNumber = staminaBG:FindFirstChild("StaminaNumber")

	UIHelper:RotateGradient(staminaFill:FindFirstChild("UIGradient"),16)
	UIHelper:RotateGradient(staminaBG:FindFirstChild("MainStroke"):FindFirstChild("UIGradient"), 16)

	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function UpdateStamina()
		local currentStamina = char:GetAttribute("Stamina_CurrentStamina")
		local maxStamina = char:GetAttribute("Stamina_MaxStamina")
		TweenService:Create(staminaFill, info, { Size = UDim2.fromScale(currentStamina / maxStamina, 1) }):Play()
		staminaNumber.Text = math.round(currentStamina) .. "/" .. math.round(maxStamina)
	end

	UpdateStamina()
	char:GetAttributeChangedSignal("Stamina_CurrentStamina"):Connect(UpdateStamina)
	char:GetAttributeChangedSignal("Stamina_MaxStamina"):Connect(UpdateStamina)
end
