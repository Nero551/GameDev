return function(tool)
	--toolloader
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local debris = game:GetService("Debris")
	local assets = replicatedStorage.Assets
	local weaponModels = assets.Weapons[tool.Name].Model
	local player :Player = tool.Parent.Parent



	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid: Humanoid = character:WaitForChild("Humanoid", math.huge)
	local  animator:Animator = humanoid.Animator

	local coreFolder = character:WaitForChild("Core" , math.huge)
	local animsModule = require(replicatedStorage.Modules.Animations)
	local animsFolder = assets.Weapons[tool.Name].Animations
	animsModule:loadAnims(animator , animsFolder)
	
	if weaponModels:FindFirstChild(tool.Name.."_Equipped") or weaponModels:FindFirstChild(tool.Name.."_UnEquipped")  then
		
		local unEquippedModel = weaponModels:WaitForChild(tool.Name):WaitForChild(tool.Name.."_UnEquipped"):Clone()
		unEquippedModel.Weld.Part1 = character.Torso
		unEquippedModel.Parent = character

		local equipedModel:Model = weaponModels:WaitForChild(tool.Name):WaitForChild(tool.Name.."_Equipped"):Clone()
		equipedModel.Parent = character
		local weld:Motor6D = equipedModel.HandleWeld
		weld.Part0 = character:FindFirstChild("Right Arm")

		equipedModel:SetAttribute("EquipState", false) 
		unEquippedModel:SetAttribute("EquipState", false) 

		local function toggleEquipped(isEquipped:boolean)
			if isEquipped then
				equipedModel:SetAttribute("EquipState", true)
				unEquippedModel:SetAttribute("EquipState", false) 
				for _,v in unEquippedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if  v.Name ~= "Handle"  then
							v.Transparency = 1
						end
					end
				end
				for _,v in equipedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if  v.Name ~= "Handle"  then
							v.Transparency = 0
						end
					end	
				end

			else
				equipedModel:SetAttribute("EquipState", false)
				unEquippedModel:SetAttribute("EquipState", true) 
				for _,v in unEquippedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if  v.Name ~= "Handle"  then
							v.Transparency = 0
						end
					end	
				end
				for _,v in equipedModel:GetDescendants() do
					if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part") or v:IsA("UnionOperation") then
						if  v.Name ~= "Handle"  then
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
		
	else
		print("No Weapon Model For "..tool.Name)
	end
	tool:SetAttribute("ToolLoaded", true)
end