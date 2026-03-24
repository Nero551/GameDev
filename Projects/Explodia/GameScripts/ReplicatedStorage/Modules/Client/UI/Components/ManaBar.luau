local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
return function(menu)
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local ManaBG = UIManager:GetUI(menu, "ManaBG")
	local ManaFill = ManaBG:FindFirstChild("ManaFill")
	local ManaNumber = ManaBG:FindFirstChild("ManaNumber")
	local Stroke = ManaBG:FindFirstChild("Stroke")

	UIHelper:RotateGradient(ManaFill:FindFirstChild("UIGradient"))
	UIHelper:RotateGradient(Stroke:FindFirstChild("UIGradient"))

	local function UpdateMana()
		local CurrentMana = char:GetAttribute("Mana_CurrentMana")
		local MaxMana = char:GetAttribute("Mana_MaxMana")
		local info = TweenInfo.new(0.04, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
		TweenService:Create(ManaFill, info, { Size = UDim2.fromScale(CurrentMana / MaxMana, 1) }):Play()
		ManaNumber.Text = math.round(CurrentMana) .. "/" .. math.round(MaxMana)
	end

	UpdateMana()
	char:GetAttributeChangedSignal("Mana_CurrentMana"):Connect(UpdateMana)
	char:GetAttributeChangedSignal("Mana_MaxMana"):Connect(UpdateMana)
end
