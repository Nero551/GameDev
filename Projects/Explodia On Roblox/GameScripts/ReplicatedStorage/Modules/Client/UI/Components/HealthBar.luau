local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)

return function(menu)
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local healthBG = UIManager:GetUI(menu, "HealthBG")
	local healthFill = healthBG:FindFirstChild("HealthFill")
	local healthNumber = healthBG:FindFirstChild("HealthNumber")
	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function UpdateHealth()
		local currentHealth = char:GetAttribute("Health_CurrentHealth")
		local maxHealth = char:GetAttribute("Health_MaxHealth")
		TweenService:Create(healthFill, info, { Size = UDim2.fromScale(currentHealth / maxHealth, 1) }):Play()
		healthNumber.Text = math.round(currentHealth) .. " / " .. math.round(maxHealth)
	end

	UpdateHealth()
	char:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(UpdateHealth)
	char:GetAttributeChangedSignal("Health_MaxHealth"):Connect(UpdateHealth)
end
