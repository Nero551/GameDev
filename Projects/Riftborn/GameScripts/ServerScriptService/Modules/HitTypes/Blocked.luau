local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.Core.NetworkingService)
--Defualt HitType

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = (ReplicatedStorage.Modules)
local StateChecker = require(modules.Helpers.StateChecker)

local ItemDataBase = require(modules.Data.ItemDataBase)

local FormulaApplier = require(modules.Helpers.FormulaApplier)
local Animations = require(modules.Core.Animations)
local CharacterVitalsService = require(game.ServerScriptService.Services.Combat.CharacterVitalsService)


return function(argumentData)
	
	local targetHit = argumentData.TargetHit
	local abilityData = argumentData.AbilityData
	local weaponUsed = argumentData.WeaponUsed
	local targetDefenseStat = argumentData.TargetDefenseStat
	local playerDamageStat = argumentData.PlayerDamageStat
	local npcDamage = argumentData.NPCDamage
	local player = argumentData.Player
	
	local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
	if not targetHumanoid then return end
	local animator = targetHumanoid:FindFirstChild("Animator")
	
	if StateChecker:CheckState(targetHit, "Invulnerable") then return end
	local M1Damage
	local AbilityDamage
	
	if abilityData then
		AbilityDamage = FormulaApplier:AbilityDamage({
			["AbilityData"] = abilityData,
			["TargetDefenseStat"] = targetDefenseStat,
			["PlayerDamageStat"] = playerDamageStat,
			["NPCDamage"] = npcDamage,	
			["Blocked"] = true
		})
		
		CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
			["HealthChange"] = -AbilityDamage

		})

		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound" , {
			["SoundName"] = "Shared.Sounds.AbilityBlock",
			["Parent"] = targetHit.HumanoidRootPart
		})
	else
		local foundWeaponData = ItemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
		if  foundWeaponData then
			
			M1Damage = FormulaApplier:M1Damage({
				["NPCDamage"] = npcDamage,
				["PlayerDamageStat"] = playerDamageStat,
				["TargetDefenseStat"] = targetDefenseStat,
				["FoundWeaponData"] = foundWeaponData,
				["Blocked"] = true,

			})
			
			CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				["HealthChange"] = -M1Damage

			})

			local randomNumber =  math.random(1,4)
			NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound" , {
				["SoundName"] = "Weapons."..weaponUsed.Name..".Sounds.Blocked."..tostring(randomNumber) ,
				["Parent"] = targetHit.HumanoidRootPart
			})
		end	
	end
	
	NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "BlockedHit" , {
		["Target"] = targetHit ,
		["weaponUsed"] = weaponUsed.Name,
		["BlockCounter"] = CharacterVitalsService:GetVital(targetHit, "BlockCounter")
	})
	
	task.spawn(function()
		local randomShrug = math.random(1,2)
		Animations:GetAnimation(animator, "Shared.Character.BlockReactions.BlockShrug"..tostring(randomShrug)):Play()
	end)
	
	if player then
		if AbilityDamage then
			NetworkingService:FireToClient(player , "ShowDamage", AbilityDamage, false, true)
		else
			NetworkingService:FireToClient(player , "ShowDamage", M1Damage, false, true)
		end
	end
	
end
