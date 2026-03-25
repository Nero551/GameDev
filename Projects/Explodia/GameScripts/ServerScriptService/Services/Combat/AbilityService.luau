local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CombatUtils = require(ServerScriptService.Modules.Utilities.CombatUtils)
local DataService = require(ServerScriptService.Services.Core.DataService)
local assets = ReplicatedStorage.Assets

local AbilityData = require(game.ReplicatedStorage.Modules.Data.AbilityData)

local StateService = require(game.ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
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
	local abilityData = AbilityData:GetAbilityData(tool.Name, abilityLetter)

	if not abilityData then
		print("Ability data not found for:", tool.Name .. abilityLetter)
		return
	end

	if player then
		local inventory = DataService:GetTable(player, "Inventory")
		local playerMana = VitalsService:GetVital(character, "Mana")
		if playerMana.CurrentMana < abilityData.Mana then
			assets.Shared.Sounds.Error:Play()
			NetworkingService:FireToClient(player, "PopUp", {
				["AbilityName"] = abilityData.AbilityName,
				["RequiredMana"] = abilityData.Mana,
			})
			return
		end
		if inventory[tool:GetAttribute("ID")] then
			if inventory[tool:GetAttribute("ID")].Mastery < abilityData.AbilityMastery then
				NetworkingService:FireToClient(player, "PopUp", {
					["Mastery"] = inventory[tool:GetAttribute("ID")].Mastery,
					["RequiredMastery"] = abilityData.AbilityMaster,
				})
				return
			end
		end

		NetworkingService:FireToClient(player, "CameraShake", 0.25)
		playerMana.CurrentMana = playerMana.CurrentMana - abilityData.Mana
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
			["VFX"] = assets.Weapons[tool.Name].Effects.Abilities[abilityLetter],
			["HitBoxName"] = hitboxClone.Name,
			["Caster"] = character,
		})

		---Sound---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "AbilitySound", {
			["Sound"] = assets.Weapons:FindFirstChild(tool.Name).Sounds.Abilities.Activate:FindFirstChild(abilityLetter),
			["HitBoxName"] = hitboxClone.Name,
		})

		---Damage---
		task.spawn(function()
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = { character, workspace.World.Hitboxes }

			local hit = {}
			local partsCollected = workspace:GetPartsInPart(hitboxClone, params)
			for _, part in partsCollected do
				if part.Parent and part.Parent:FindFirstChild("Humanoid") then
					local targetHit = part.Parent

					if StateChecker:CheckState(targetHit, "Invulnerable") then
						continue
					end

					local targetHumanoid: Humanoid = targetHit:FindFirstChild("Humanoid")
					if targetHumanoid and not hit[targetHumanoid] then
						hit[targetHumanoid] = true
						for Hit = 0, abilityData.Hits, 1 do
							CombatUtils:ApplyHit({
								["Attacker"] = character,
								["TargetHit"] = targetHit,
								["Tool"] = tool,
								["AbilityLetter"] = abilityLetter,
							})
							task.wait(abilityData.TimeBtwnHits)
						end
					end
				end
			end
		end)

		Debris:AddItem(hitboxClone, 1)
	end)
end

return AbilityService
