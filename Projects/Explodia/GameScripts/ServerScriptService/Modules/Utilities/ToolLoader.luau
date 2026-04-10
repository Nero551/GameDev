return function(tool)
	--toolloader
	if tool:GetAttribute("ToolLoaded", true) then
		return
	end

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local assets = ReplicatedStorage.Assets
	local weaponModels = assets.Weapons[tool.Name].Model

	local character = (tool.Parent.Parent.ClassName == "Player" and tool.Parent.Parent.Character) or tool.Parent
	local humanoid = character:WaitForChild("Humanoid")

	local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
	local animsFolder = assets.Weapons[tool.Name].Animations
	Animations:LoadAnimations(humanoid, animsFolder)

	if
		weaponModels:FindFirstChild(tool.Name .. "_Equipped")
		and weaponModels:FindFirstChild(tool.Name .. "_UnEquipped")
	then
		local unEquippedModel = character:FindFirstChild(tool.Name .. "_UnEquipped")
		if not unEquippedModel then
			unEquippedModel = weaponModels:FindFirstChild(tool.Name .. "_UnEquipped"):Clone()
			unEquippedModel.Parent = character

			local weld = unEquippedModel:FindFirstChildWhichIsA("Motor6D")
			weld.Part1 = character.Torso
		end

		local equipedModel = character:FindFirstChild(tool.Name .. "_Equipped")
		if not equipedModel then
			equipedModel = weaponModels:FindFirstChild(tool.Name .. "_Equipped"):Clone()
			equipedModel.Parent = character

			local weld: Motor6D = equipedModel:FindFirstChildWhichIsA("Motor6D")
			weld.Part0 = character:FindFirstChild("Right Arm")
		end

		equipedModel:SetAttribute("EquipState", false)
		unEquippedModel:SetAttribute("EquipState", false)

		local function toggleEquipped(isEquipped: boolean)
			if isEquipped then
				equipedModel:SetAttribute("EquipState", true)
				unEquippedModel:SetAttribute("EquipState", false)
				for _, v in unEquippedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if v.Name ~= "Handle" then
							v.Transparency = 1
						end
					end
				end
				for _, v in equipedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if v.Name ~= "Handle" then
							v.Transparency = 0
						end
					end
				end
			else
				equipedModel:SetAttribute("EquipState", false)
				unEquippedModel:SetAttribute("EquipState", true)
				for _, v in unEquippedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if v.Name ~= "Handle" then
							v.Transparency = 0
						end
					end
				end
				for _, v in equipedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if v.Name ~= "Handle" then
							v.Transparency = 1
						end
					end
				end
			end
		end

		toggleEquipped(false)
		tool.Equipped:Connect(function()
			toggleEquipped(true)
		end)

		tool.Unequipped:Connect(function()
			toggleEquipped(false)
		end)

		equipedModel:SetAttribute("WeaponModel", true)
		equipedModel:SetAttribute("WeaponName", tool.Name)
		unEquippedModel:SetAttribute("WeaponModel", true)
		unEquippedModel:SetAttribute("WeaponName", tool.Name)
	end
	tool:SetAttribute("ToolLoaded", true)
end
