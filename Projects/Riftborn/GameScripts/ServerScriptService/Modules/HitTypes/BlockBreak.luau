--Defualt HitType

local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)

return function(argumentData)
	
	local targetHit = argumentData.TargetHit
	local weaponUsed = argumentData.WeaponUsed
	local attacker = argumentData.Attacker
	
	if StateChecker:CheckState(targetHit, "Invulnerable") then return end

	local foundWeaponData = ItemDataBase:GetItemData(weaponUsed:GetAttribute("ID"))
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
			["Sound"] = ReplicatedStorage.Assets.Shared.Sounds.BlockBreak , 
			["Parent"] = targetHit.HumanoidRootPart
		})
		
		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "BlockBreakHit" , {
			["Target"] = targetHit ,
			["Weapon"] = weaponUsed,
		})
		
		Animations:GetAnimation(animator, "Shared.Character.BlockBreak"):Play()	
		--print("[BlockBreak] HitType Reached","From",attacker ,"To",targetHit ,"With", weaponUsed)
	end



end
