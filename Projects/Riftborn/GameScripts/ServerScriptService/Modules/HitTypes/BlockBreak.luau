--Defualt HitType

local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)
local itemDataBase = require(modules.Data.ItemDataBase)
local animationsModule = require(modules.Animations)

return function(argumentData)
	
	local targetHit = argumentData.TargetHit
	local weaponUsed = argumentData.WeaponUsed
	local attacker = argumentData.Attacker
	
	if stateService.checkState(targetHit, "Invulnerable") then return end

	local foundWeaponData = itemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
	if  foundWeaponData then
		local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
		if not targetHumanoid then return end
		local animator = targetHumanoid:FindFirstChild("Animator")
		
		stateService.addState(targetHit , "Stunned" , 1.5)
		stateService.addState(targetHit , "BlockBroken", 1.5)
		stateService.addState(targetHit , "NoBlock" , 5)
		
		stateService.addState(attacker, "In Combat", 20)
		stateService.addState(targetHit, "In Combat", 20)
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
			["SoundName"] = "Shared.Sounds.BlockBreak" , 
			["Parent"] = targetHit.HumanoidRootPart
		})
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockBreakHit" , {
			["Target"] = targetHit ,
			["weaponUsed"] = weaponUsed.Name,
			["Duration"] = 1.5,
		})
		
		animationsModule:GetAnimation(animator, "Shared.Character.BlockBreak"):Play()	
		--print("[BlockBreak] HitType Reached","From",attacker ,"To",targetHit ,"With", weaponUsed)
	end



end