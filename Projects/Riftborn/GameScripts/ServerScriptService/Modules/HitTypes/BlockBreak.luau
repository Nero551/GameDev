local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
--Defualt HitType

local NetworkingService = ModuleLoader:Load("Shared", "NetworkingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = (ReplicatedStorage.Modules)
local StateService = ModuleLoader:Load("Server", "StateService")
local StateChecker = ModuleLoader:Load("Shared", "StateChecker")
local ItemDataBase = ModuleLoader:Load("Shared", "ItemDataBase")
local Animations = ModuleLoader:Load("Shared", "Animations")

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
			["SoundName"] = "Shared.Sounds.BlockBreak" , 
			["Parent"] = targetHit.HumanoidRootPart
		})
		
		NetworkingService:FireInRange("ClientEffects", targetHit.HumanoidRootPart.Position, nil, "BlockBreakHit" , {
			["Target"] = targetHit ,
			["weaponUsed"] = weaponUsed.Name,
			["Duration"] = 1.5,
		})
		
		Animations:GetAnimation(animator, "Shared.Character.BlockBreak"):Play()	
		--print("[BlockBreak] HitType Reached","From",attacker ,"To",targetHit ,"With", weaponUsed)
	end



end
