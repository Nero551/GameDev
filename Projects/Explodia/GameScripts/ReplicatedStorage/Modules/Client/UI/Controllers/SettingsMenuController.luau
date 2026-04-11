local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local UIHelper = require(ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(ReplicatedStorage.Modules.Client.UI.UIManager)
local NetworkingService = require(ReplicatedStorage.Modules.Core.NetworkingService)
local SettingsMenuController = {}

local player = Players.LocalPlayer

function SettingsMenuController:Options()
	local settings = player:FindFirstChild("Settings")
	local OptionsFrame = UIManager:GetUI("SettingsMenu", "Options")
	local MainFrame = UIManager:GetUI("SettingsMenu", "Main")
	for _, config in settings:GetChildren() do
		local option = OptionsFrame:FindFirstChild(config.Name .. "Option")
		if not option then
			option = UIManager:CloneUI(
				"SettingsMenu",
				config.Name .. "Option",
				ReplicatedStorage.Assets.UI.SettingsOption,
				"Options"
			)
            option.OptionName.Text = config.Name
			UIHelper:ClickEffects(option,0.975)
			UIHelper:HoverEffects(option,1.05)

			option.MouseButton1Click:Connect(function()
				local wantedFrame = MainFrame:FindFirstChild(option.Name:split("Option")[1] .. "Frame")
				if wantedFrame then
					for _, frame in MainFrame:GetChildren() do
						if frame:IsA("ScrollingFrame") or frame:IsA("Frame") then
                            if frame ~= wantedFrame then
								frame.Visible = false                            
                            end
						end
					end
					wantedFrame.Visible = true
				end
			end)
		end
	end
end

function SettingsMenuController:Keybinds()
	local listeningForSlot = nil
	local KeybindOrder = {}
	local keybinds = player:FindFirstChild("Settings"):FindFirstChild("Keybinds")
	local keybindsFrame = UIManager:GetUI("SettingsMenu", "KeybindsFrame")

	for keybind, key in pairs(keybinds:GetAttributes()) do
		table.insert(KeybindOrder, keybind)
	end
	table.sort(KeybindOrder)

	local function UpdateKeys()
		for _, keybind in ipairs(KeybindOrder) do
			local key = keybinds:GetAttribute(keybind)
			if key then
				local keySlot = keybindsFrame:FindFirstChild(keybind)
				if not keySlot then
					keySlot = UIManager:CloneUI(
						"SettingsMenu",
						keybind,
						ReplicatedStorage.Assets.UI.KeyBindSlot,
						"KeybindsFrame"
					)

					keySlot.Key.MouseButton1Click:Connect(function()
						listeningForSlot = keySlot
					end)
				end
				keySlot.Keybind.Text = keybind
				keySlot.Key.TextLabel.Text = key
			end
		end
	end

	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then
			return
		end
		if not listeningForSlot then
			return
		end

		---If Another Keybind Is Using Key---
		for _, keybind in ipairs(KeybindOrder) do
			if keybind ~= listeningForSlot.Name then
				local key = keybinds:GetAttribute(keybind)
				if key then
					if key == inp.KeyCode.Name then
						return
					end
				end
			end
		end

		NetworkingService:FireToServer("ChangeKeybind", listeningForSlot.Name, inp.KeyCode.Name)
		listeningForSlot = nil
	end)

	UpdateKeys()
	keybinds.AttributeChanged:Connect(UpdateKeys)
end

return SettingsMenuController
