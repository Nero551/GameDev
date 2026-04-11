local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ReturnButton = require(ReplicatedStorage.Modules.Client.UI.Components.ReturnButton)
local TechniqueData = require(ReplicatedStorage.Modules.Data.TechniqueData)
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local UIHelper = require(game.ReplicatedStorage.Modules.Client.UI.Helpers.UIHelper)
local UIManager = require(game.ReplicatedStorage.Modules.Client.UI.UIManager)

local TechniqueMenuController = {}

local player = Players.LocalPlayer

function TechniqueMenuController:TopBar()
	ReturnButton("TechniquesMenu")
end

function TechniqueMenuController:Techniques()
	local techniques = player:WaitForChild("Techniques")

	local techniqueFrame = UIManager:GetUI("TechniquesMenu", "TechniquesScrollingFrame")
	local infoFrame = UIManager:GetUI("TechniquesMenu", "InfoFrame")
	local infoImage = infoFrame.Icon
	local infoName = infoFrame.TechniqueName.TextLabel
	local infoDamageType = infoFrame.DamageType
	local infoDescription = infoFrame.Description

	local equipIcon = infoFrame:FindFirstChild("Equip")
	local equipButton = equipIcon:FindFirstChild("EquipButton")
	local unequipButton = equipIcon:FindFirstChild("UnEquipButton")

	local IconSelected = nil
	local PrevIconSelected = nil

	infoFrame.Visible = false

	for _, techniqueSlot in techniqueFrame:GetChildren() do
		if techniqueSlot:IsA("ImageButton") then
			techniqueSlot:Destroy()
		end
	end
	local function UpdateUI(child: Instance, remove)
		infoFrame.Visible = false
		local techniqueID = child.Name
		local techniqueData = TechniqueData:GetTechniqueData(techniqueID)

		local techniqueSlot = techniqueFrame:FindFirstChild(techniqueID)
		if techniqueSlot and remove then
			techniqueSlot:Destroy()
			return
		end

		if not techniqueSlot then
			techniqueSlot = UIManager:CloneUI(
				"TechniquesMenu",
				techniqueID,
				ReplicatedStorage.Assets.UI.TechniqueSlot,
				"TechniquesScrollingFrame"
			)
			UIHelper:ClickEffects(techniqueSlot)
			UIHelper:HoverEffects(techniqueSlot)

			local border = techniqueSlot:FindFirstChild("Border")
			UIHelper:RotateGradient(border:FindFirstChild("UIGradient"))

			local info = TweenInfo.new(0.125, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			techniqueSlot.MouseEnter:Connect(function()
				techniqueSlot.ImageColor3 = Color3.fromHex("#eeeeee")
				if IconSelected ~= techniqueSlot then
					TweenService:Create(border, info, { ImageColor3 = Color3.fromRGB(200, 200, 200) }):Play()
				end
			end)

			techniqueSlot.MouseLeave:Connect(function()
				techniqueSlot.ImageColor3 = Color3.fromHex("#ffffff")
				if IconSelected ~= techniqueSlot then
					TweenService:Create(border, info, { ImageColor3 = Color3.fromRGB(145, 145, 145) }):Play()
				end
			end)

			techniqueSlot.MouseButton1Click:Connect(function()
				PrevIconSelected = IconSelected
				IconSelected = techniqueSlot
				if IconSelected ~= nil then
					TweenService:Create(IconSelected.Border, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) })
						:Play()
				end
				if PrevIconSelected ~= nil and PrevIconSelected ~= IconSelected then
					TweenService:Create(PrevIconSelected.Border, info, { ImageColor3 = Color3.fromRGB(145, 145, 145) })
						:Play()
				end

				---Info Setup---
				infoFrame.Visible = true
				infoFrame:SetAttribute("TechniqueName", techniqueSlot.Name)
				infoFrame:SetAttribute("TechniqueID", techniqueID)
				infoImage.Image = techniqueData.Icon
				infoName.Text = techniqueData.TechniqueName
				infoDescription.Text = techniqueData.Description
				infoDamageType.Text = techniqueData.DamageType
				equipIcon.Visible = true

				TweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
				TweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()
				equipButton.Visible = true
				unequipButton.Visible = false
				for _, equippedTech in techniques.Equipped:GetChildren() do
					if equippedTech:GetAttribute("TechniqueID") == techniqueID then
						TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
						TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()
						equipButton.Visible = false
						unequipButton.Visible = true
					end
				end
			end)
		end

		local equippedIcon = techniqueSlot:FindFirstChild("EquippedIcon")
		for _, equippedTech in techniques.Equipped:GetChildren() do
			if equippedTech:GetAttribute("TechniqueID") == techniqueID then
				equippedIcon.Visible = true
			else
				equippedIcon.Visible = false
			end
		end
		techniqueSlot.Image = techniqueData.Icon
	end

	for _, child in techniques.Obtained:GetChildren() do
		UpdateUI(child)
	end

	techniques.Obtained.ChildAdded:Connect(function(child)
		UpdateUI(child)
	end)

	techniques.Obtained.ChildRemoved:Connect(function(child)
		UpdateUI(child, true)
	end)
end

function TechniqueMenuController:Equip()
	local techniques = player:WaitForChild("Techniques")

	local techniqueFrame = UIManager:GetUI("TechniquesMenu", "TechniquesScrollingFrame")
	local infoFrame = UIManager:GetUI("TechniquesMenu", "InfoFrame")
	local box = infoFrame:FindFirstChild("Equip")
	local equipButton = box:FindFirstChild("EquipButton")
	local unequipButton = box:FindFirstChild("UnEquipButton")
	local info = TweenInfo.new(0.0625, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)

	UIHelper:HoverEffects(box)
	UIHelper:ClickEffects(equipButton)
	UIHelper:ClickEffects(unequipButton)

	box.MouseEnter:Connect(function()
		TweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(55, 67, 122) }):Play()
	end)

	box.MouseLeave:Connect(function()
		TweenService:Create(box, info, { ImageColor3 = Color3.fromRGB(255, 255, 255) }):Play()
	end)

	equipButton.MouseButton1Click:Connect(function()
		local techniqueID = infoFrame:GetAttribute("TechniqueID")
		NetworkingService:FireToServer("EquipTechnique", techniqueID)
		TweenService:Create(equipButton, info, { TextTransparency = 1 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 0 }):Play()

		task.wait(info.Time)
		equipButton.Visible = false
		unequipButton.Visible = true
	end)

	unequipButton.MouseButton1Click:Connect(function()
		local techniqueID = infoFrame:GetAttribute("TechniqueID")
		NetworkingService:FireToServer("UnequipTechnique", techniqueID)
		TweenService:Create(equipButton, info, { TextTransparency = 0 }):Play()
		TweenService:Create(unequipButton, info, { TextTransparency = 1 }):Play()

		task.wait(info.Time)
		equipButton.Visible = true
		unequipButton.Visible = false
	end)

	techniques.Equipped.ChildAdded:Connect(function(child)
		local slot = techniqueFrame:FindFirstChild(child:GetAttribute("TechniqueID"))
		if slot then
			slot:FindFirstChild("EquippedIcon").Visible = true
		end
	end)
	techniques.Equipped.ChildRemoved:Connect(function(child)
		local slot = techniqueFrame:FindFirstChild(child:GetAttribute("TechniqueID"))
		if slot then
			slot:FindFirstChild("EquippedIcon").Visible = false
		end
	end)
end

function TechniqueMenuController:Search()
	local techniqueFrame = UIManager:GetUI("TechniquesMenu", "TechniquesScrollingFrame")
	local searchBox = UIManager:GetUI("TechniquesMenu", "SearchBox")

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = searchBox.Text:lower()

		for _, slot in techniqueFrame:GetChildren() do
			if slot:IsA("Frame") then
				local techniqueData = TechniqueData:GetTechniqueData(slot.Name)
				if not techniqueData then
					continue
				end
				local techniqueName = techniqueData.TechniqueName:lower()

				if text == "" then
					slot.Visible = true
				else
					slot.Visible = false

					for word in string.gmatch(techniqueName, "%S+") do
						if string.sub(word, 1, #text) == text then
							slot.Visible = true
							break
						end
					end
				end
			end
		end
	end)
end

function TechniqueMenuController:EquippedTechniques()
	local techniques = player:FindFirstChild("Techniques")
	local equippedTechsFrame = UIManager:GetUI("TechniquesMenu", "EquippedTechniquesFrame")
	local keybinds = player:FindFirstChild("Settings"):FindFirstChild("Keybinds")

	local function UpdateKeys()
		for _, techSlot in equippedTechsFrame:GetChildren() do
			if keybinds:GetAttribute(techSlot.Name) then
				techSlot.Letter.Text = keybinds:GetAttribute(techSlot.Name)
			end
		end
	end

	local function UpdateTechniques()
		for _, equippedTech in equippedTechsFrame:GetChildren() do
			if equippedTech:IsA("TextButton") then
				local techSlot = techniques.Equipped:FindFirstChild(equippedTech.Name:split("Technique")[2])
				if techSlot then
					local techniqueID = techSlot:GetAttribute("TechniqueID")
					local techniqueData = TechniqueData:GetTechniqueData(techniqueID)
					if techniqueData then
						equippedTech.TechniqueName.Text = techniqueData.TechniqueName
					end
				else
					equippedTech.TechniqueName.Text = ""
				end
			end
		end
	end

	UpdateTechniques()
	techniques.Equipped.ChildAdded:Connect(UpdateTechniques)
	techniques.Equipped.ChildRemoved:Connect(UpdateTechniques)

	UpdateKeys()
	keybinds.AttributeChanged:Connect(UpdateKeys)
end

return TechniqueMenuController
