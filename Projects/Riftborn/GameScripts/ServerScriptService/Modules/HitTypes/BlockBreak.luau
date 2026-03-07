--Defualt HitType

local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
local replicatedStorage = game:GetService("ReplicatedStorage")
local modules = (replicatedStorage.Modules)
local StateService = require(game.ServerScriptService.Services.StateService)
local StateChecker = require(modules.StateChecker)
local itemDataBase = require(modules.Data.ItemDataBase)
local animationsModule = require(modules.Animations)

return function(argumentData)
	
	local targetHit = argumentData.TargetHit
	local weaponUsed = argumentData.WeaponUsed
	local attacker = argumentData.Attacker
	
	if StateChecker:CheckState(targetHit, "Invulnerable") then return end

	local foundWeaponData = itemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
	if  foundWeaponData then
		local targetHumanoid:Humanoid = targetHit:FindFirstChild("Humanoid")
		if not targetHumanoid then return end
		local animator = targetHumanoid:FindFirstChild("Animator")
		
		StateService:AddState(targetHit , "Stunned" , 1.5)
		StateService:AddState(targetHit , "BlockBroken", 1.5)
		StateService:AddState(targetHit , "NoBlock" , 5)
        
		StateService:AddState(attacker, "In Combat", 20)
		StateService:AddState(targetHit, "In Combat", 20)
		
		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "Sound" , {
			["SoundName"] = "Shared.Sounds.BlockBreak" , 
			["Parent"] = targetHit.HumanoidRootPart
		})
		
		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "BlockBreakHit" , {
			["Target"] = targetHit ,
			["weaponUsed"] = weaponUsed.Name,
			["Duration"] = 1.5,
		})
		
		animationsModule:GetAnimation(animator, "Shared.Character.BlockBreak"):Play()	
		--print("[BlockBreak] HitType Reached","From",attacker ,"To",targetHit ,"With", weaponUsed)
	end



end
