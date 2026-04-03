local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local HitService = require(script.Parent.HitService)
local DataService = require(ServerScriptService.Services.Core.DataService)
local assets = ReplicatedStorage.Assets

local TechniqueData = require(game.ReplicatedStorage.Modules.Data.TechniqueData)

local StateService = require(game.ServerScriptService.Services.Core.StateService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)

local TechniqueService = {}

function TechniqueService:SetupTechniques(player)
	local techniques = DataService:GetTable(player, "Techniques")
	local folder = player:FindFirstChild("Techniques")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Techniques"
		folder.Parent = player

		local subFolder1 = Instance.new("Folder")
		subFolder1.Name = "Obtained"
		subFolder1.Parent = folder

		local subFolder2 = Instance.new("Folder")
		subFolder2.Name = "Equipped"
		subFolder2.Parent = folder
	end
	local obtained = folder:FindFirstChild("Obtained")
	local equipped = folder:FindFirstChild("Equipped")

	for _, techniqueID in ipairs(techniques.Obtained) do
		local value = obtained:FindFirstChild(techniqueID)
		if not value then
			value = Instance.new("StringValue")
			value.Name = techniqueID
			value.Parent = obtained
		end
	end

	for techniqueID, weaponID in ipairs(techniques.Equipped) do
		local value = equipped:FindFirstChild(techniqueID)
		if not value then
			value = Instance.new("StringValue")
			value.Name = techniqueID
			value.Parent = equipped
			value:SetAttribute("WeaponID", weaponID)
		end
	end
end

function TechniqueService:CheckWeaponType(weaponData, techniqueData)
	if techniqueData.WeaponType[weaponData.Type] then
		return true
	end
	return
end

function TechniqueService:ObtainTechnique(player, techniqueID)
	local techniques = DataService:GetTable(player, "Techniques")
	local techniqueData = TechniqueData:GetTechniqueData(techniqueID)
	if not techniqueData then
		return
	end
	if techniques.Obtained[techniqueID] then
		return
	end

	table.insert(techniques.Obtained, techniqueID)


	local obtained = player:FindFirstChild("Techniques"):FindFirstChild("Obtained")
	local value = obtained:FindFirstChild(techniqueID)
	if not value then
		value = Instance.new("StringValue")
		value.Name = techniqueID
		value.Parent = obtained
	end
end

function TechniqueService:RemoveTechnique(player, techniqueID)
	local techniques = DataService:GetTable(player, "Techniques")
	if techniques.Obtained[techniqueID] then
		table.remove(techniques.Obtained, techniqueID)
	end

	if techniques.Equipped[techniqueID] then
		TechniqueService:UnEquipTechnique(player, techniqueID)
	end
	local obtained = player:FindFirstChild("Techniques"):FindFirstChild("Obtained")
	local value = obtained:FindFirstChild(techniqueID)
	if  value then
		value:Destroy()
	end
end

function TechniqueService:UnEquipTechnique(player, techniqueID)
	local techniques = DataService:GetTable(player, "Techniques")

	if techniques.Equipped[techniqueID] then
		techniques.Equipped[techniqueID] = nil
	end

	local equipped = player:FindFirstChild("Techniques"):FindFirstChild("Equipped")
	local value = equipped:FindFirstChild(techniqueID)
	if value then
		value:Destroy()
	end
end

function TechniqueService:EquipTechnique(player, techniqueID)
	local techniques = DataService:GetTable(player, "Techniques")
	local techniqueData = TechniqueData:GetTechniqueData(techniqueID)
	local Equipped = DataService:GetTable(player, "Equipped")

	if not techniqueData then
		return
	end
	if not table.find(techniques.Obtained, techniqueID) then
		return
	end

	for _, weaponType in ipairs(techniqueData.WeaponType) do
		if Equipped[weaponType] then
			techniques.Equipped[techniqueID] = Equipped[weaponType]
		end
	end

	local equipped = player:FindFirstChild("Techniques"):FindFirstChild("Equipped")
	local value = equipped:FindFirstChild(techniqueID)
	if not value then
		value = Instance.new("StringValue")
		value.Name = techniqueID
		value.Parent = equipped
	end
end

function TechniqueService:UseTechnique(character, techniqueLetter, mouse)
	local player = Players:GetPlayerFromCharacter(character)
	local tool = character:FindFirstChildWhichIsA("Tool")
	if not tool then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")
	local weaponData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
	local techniqueData = TechniqueData:GetTechniqueData(weaponData.Abilities[techniqueLetter])

	if not ActionVerifier:CanTechnique(character, techniqueLetter) then
		return
	end

	if not techniqueData then
		print("Technique data not found for:", tool.Name .. techniqueLetter)
		return
	end

	if not TechniqueService:CheckWeaponType(weaponData, techniqueData) then
		return
	end

	if player then
		local inventory = DataService:GetTable(player, "Inventory")
		if techniqueData.DamageType then
			if techniqueData.DamageType == "Physical" then
				local playerStamina = VitalsService:GetVital(character, "Stamina")
				if playerStamina.CurrentStamina < techniqueData.Cost then
					assets.Shared.MenuSounds.Error:Play()
					NetworkingService:FireToClient(player, "PopUp", {
						["AbilityName"] = techniqueData.AbilityName,
						["RequiredStamina"] = techniqueData.Cost,
					})
					return
				end
			elseif techniqueData.DamageType == "Magic" then
				local playerMana = VitalsService:GetVital(character, "Mana")
				if playerMana.CurrentMana < techniqueData.Cost then
					assets.Shared.MenuSounds.Error:Play()
					NetworkingService:FireToClient(player, "PopUp", {
						["AbilityName"] = techniqueData.AbilityName,
						["RequiredMana"] = techniqueData.Mana,
					})
					return
				end
			end
		end

		if inventory[tool:GetAttribute("ID")] then
			if inventory[tool:GetAttribute("ID")].Mastery < techniqueData.AbilityMastery then
				NetworkingService:FireToClient(player, "PopUp", {
					["Mastery"] = inventory[tool:GetAttribute("ID")].Mastery,
					["RequiredMastery"] = techniqueData.AbilityMastery,
				})
				return
			end
		end

		NetworkingService:FireToClient(player, "CameraShake", 0.25)
		VitalsService:ModifyVital(character, "Mana", "ModifyMana", {
			["ManaChange"] = -techniqueData.Mana,
		})
	end

	---CoolDown---
	local cooldownTime = techniqueData.AbilityCooldown

	---Animation---
	local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
	local animation: AnimationTrack =
		Animations:GetAnimation(humanoid, "Weapons." .. tool.Name .. ".Animations.Abilities." .. techniqueLetter)
	if not animation then
		warn("Animation Not Found")
		return
	end
	animation:Play()

	---Ability States---
	StateService:AddState(character, "Ability" .. techniqueLetter .. " Cooldown", cooldownTime)
	StateService:AddState(character, "Invulnerable", 0.2)
	StateService:AddState(character, "Casting", animation.Length)

	animation:GetMarkerReachedSignal("Hit"):Once(function()
		local hrp = character:WaitForChild("HumanoidRootPart")

		---HitBox---
		local hitboxClone = assets.HitboxTemplate:Clone()
		if techniqueData.OnMouse and mouse then
			hitboxClone.Name = techniqueData.AbilityName .. " Hitbox"
			hitboxClone.Size = techniqueData.HitBoxSize
			hitboxClone.Position = mouse
			hitboxClone.Parent = workspace.World.Hitboxes
		else
			hitboxClone.Name = techniqueData.AbilityName .. " Hitbox"
			hitboxClone.Size = techniqueData.HitBoxSize
			hitboxClone.Position = hrp.Position
				+ techniqueData.HitBoxPosition
				+ hrp.CFrame.LookVector * techniqueData.HitBoxLookVector
			hitboxClone.Orientation = hrp.Orientation + techniqueData.HitBoxRotation
			hitboxClone.Parent = workspace.World.Hitboxes
		end

		---VFX---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "AbilityVFX", {
			["VFX"] = assets.Shared.Abilities[weaponData.Abilities[techniqueLetter]].VFX,
			["HitBoxName"] = hitboxClone.Name,
			["Caster"] = character,
		})

		---Sound---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "AbilitySound", {
			["Sound"] = assets.Shared.Abilities[weaponData.Abilities[techniqueLetter]].Activate,
			["HitBoxName"] = hitboxClone.Name,
		})
		Debris:AddItem(hitboxClone, 1)
		---Damage---
		HitService:Apply(character, techniqueData, tool, hitboxClone)
	end)
end




return TechniqueService