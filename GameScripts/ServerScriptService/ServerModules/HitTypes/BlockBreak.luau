--Defualt HitType

local replicatedStorage = game:GetService("ReplicatedStorage")
local assets = replicatedStorage.Assets
local modules = (replicatedStorage.Modules)
local stateService = require(modules.StateService)
local itemDataBase = require(modules.ItemDataBase)

return function(attacker:Model , targetHit:Model , weaponUsed:Tool?)
	if stateService.checkState(targetHit, "Invulnerable") then return end

	local foundWeaponData = itemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
	if  foundWeaponData then
		local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
		if not targetHumanoid then return end
		stateService.addState(targetHit , "Stunned" , 1.5)
		stateService.addState(targetHit , "BlockBroken", 1.5)
		stateService.addState(targetHit , "NoBlock" , 5)
		
		stateService.addState(attacker, "In Combat", 20)
		stateService.addState(targetHit, "In Combat", 20)
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
			["SoundName"] = "BlockBreak" , 
			["Parent"] = targetHit.HumanoidRootPart
		})
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("BlockBreakHit" , {
			["Target"] = targetHit ,
			["weaponUsed"] = weaponUsed.Name,
			["Duration"] = 1.5,
		})
		
		
		
		if targetHit:FindFirstChild("Core") then
			local animationsModule = require(targetHit.Core.Animations)
			animationsModule.loadedAnimations["Character.BlockBreak"]:Play()
		else
			local animator: Animator = targetHumanoid:FindFirstChild("Animator")
			if animator then
				local blockBreakAnim  = animator:LoadAnimation(assets.Animations.Character.BlockBreak)
				blockBreakAnim:Play()
			end
		end

		
		--print("[BlockBreak] HitType Reached","From",attacker ,"To",targetHit ,"With", weaponUsed)
	end



end