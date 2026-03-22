local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
return function(menu)
	local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
	local healthBG = UIManager:GetUI(menu, "HealthBG")
	local healthFill: ImageLabel = healthBG:FindFirstChild("HealthFill")
	local healthText: TextLabel = healthBG:FindFirstChild("HealthText")
	local healthNumber: TextLabel = healthBG:FindFirstChild("HealthNumber")
	local Stroke = healthBG:FindFirstChild("Stroke")

	UIHelper:RotateGradient(healthFill:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(Stroke:FindFirstChild("UIGradient"))

	local info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local info2 = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local function UpdateHealth()
		local currentHealth = char:GetAttribute("Health_CurrentHealth")
		local maxHealth = char:GetAttribute("Health_MaxHealth")
		TweenService:Create(healthFill, info, { Size = UDim2.fromScale(currentHealth / maxHealth, 1) }):Play()
		healthNumber.Text = math.round(currentHealth) .. "/" .. math.round(maxHealth)

		if maxHealth / 3 > currentHealth then
			TweenService:Create(healthNumber, info2, { TextColor3 = Color3.fromRGB(255, 140, 150) }):Play()
			TweenService:Create(healthText, info2, { TextColor3 = Color3.fromRGB(255, 140, 150) }):Play()
		else
			TweenService:Create(healthNumber, info2, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
			TweenService:Create(healthText, info2, { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end
	end

	char:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(UpdateHealth)
	char:GetAttributeChangedSignal("Health_MaxHealth"):Connect(UpdateHealth)
end
