local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)
local HitService = require(script.Parent.HitService)
local DataService = require(ServerScriptService.Services.Core.DataService)
local assets = ReplicatedStorage.Assets

local AbilityData = require(game.ReplicatedStorage.Modules.Data.AbilityData)

local StateService = require(game.ServerScriptService.Services.Core.StateService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)

local AbilityService = {}

function AbilityService:UseAbility(character, abilityLetter, mouse)
	local player = Players:GetPlayerFromCharacter(character)
	local tool = character:FindFirstChildWhichIsA("Tool")
	if not tool then
		return
	end

	if not ActionVerifier:CanAbility(character, abilityLetter) then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")
	local weaponData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
	local abilityData = AbilityData:GetAbilityData(weaponData.Abilities[abilityLetter])

	if not abilityData then
		print("Ability data not found for:", tool.Name .. abilityLetter)
		return
	end

	if player then
		local inventory = DataService:GetTable(player, "Inventory")
		if abilityData.DamageType then
			if abilityData.DamageType == "Physical" then
				local playerStamina = VitalsService:GetVital(character, "Stamina")
				if playerStamina.CurrentStamina < abilityData.Cost then
					assets.Shared.MenuSounds.Error:Play()
					NetworkingService:FireToClient(player, "PopUp", {
						["AbilityName"] = abilityData.AbilityName,
						["RequiredStamina"] = abilityData.Cost,
					})
					return
				end
			elseif abilityData.DamageType == "Magic" then
				local playerMana = VitalsService:GetVital(character, "Mana")
				if playerMana.CurrentMana < abilityData.Cost then
					assets.Shared.MenuSounds.Error:Play()
					NetworkingService:FireToClient(player, "PopUp", {
						["AbilityName"] = abilityData.AbilityName,
						["RequiredMana"] = abilityData.Mana,
					})
					return
				end
			end
		end

		if inventory[tool:GetAttribute("ID")] then
			if inventory[tool:GetAttribute("ID")].Mastery < abilityData.AbilityMastery then
				NetworkingService:FireToClient(player, "PopUp", {
					["Mastery"] = inventory[tool:GetAttribute("ID")].Mastery,
					["RequiredMastery"] = abilityData.AbilityMastery,
				})
				return
			end
		end

		NetworkingService:FireToClient(player, "CameraShake", 0.25)
		VitalsService:ModifyVital(character, "Mana", "ModifyMana", {
			["ManaChange"] = -abilityData.Mana,
		})
	end

	---CoolDown---
	local cooldownTime = abilityData.AbilityCooldown

	---Animation---
	local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
	local animation: AnimationTrack =
		Animations:GetAnimation(humanoid, "Weapons." .. tool.Name .. ".Animations.Abilities." .. abilityLetter)
	if not animation then
		warn("Animation Not Found")
		return
	end
	animation:Play()

	---Ability States---
	StateService:AddState(character, "Ability" .. abilityLetter .. " Cooldown", cooldownTime)
	StateService:AddState(character, "Invulnerable", 0.2)
	StateService:AddState(character, "Casting", animation.Length)

	animation:GetMarkerReachedSignal("Hit"):Once(function()
		local hrp = character:WaitForChild("HumanoidRootPart")

		---HitBox---
		local hitboxClone = assets.HitboxTemplate:Clone()
		if abilityData.OnMouse and mouse then
			hitboxClone.Name = abilityData.AbilityName .. " Hitbox"
			hitboxClone.Size = abilityData.HitBoxSize
			hitboxClone.Position = mouse
			hitboxClone.Parent = workspace.World.Hitboxes
		else
			hitboxClone.Name = abilityData.AbilityName .. " Hitbox"
			hitboxClone.Size = abilityData.HitBoxSize
			hitboxClone.Position = hrp.Position
				+ abilityData.HitBoxPosition
				+ hrp.CFrame.LookVector * abilityData.HitBoxLookVector
			hitboxClone.Orientation = hrp.Orientation + abilityData.HitBoxRotation
			hitboxClone.Parent = workspace.World.Hitboxes
		end

		---VFX---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "AbilityVFX", {
			["VFX"] = assets.Shared.Abilities[weaponData.Abilities[abilityLetter]].VFX,
			["HitBoxName"] = hitboxClone.Name,
			["Caster"] = character,
		})

		---Sound---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "AbilitySound", {
			["Sound"] = assets.Shared.Abilities[weaponData.Abilities[abilityLetter]].Activate,
			["HitBoxName"] = hitboxClone.Name,
		})
		Debris:AddItem(hitboxClone, 1)
		---Damage---
		HitService:Apply(character, abilityData, tool, hitboxClone)
	end)
end

return AbilityService
