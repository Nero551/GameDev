local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)
--CombatService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local assets = ReplicatedStorage.Assets
local modules = ReplicatedStorage.Modules

local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)

local ActionVerifier = require(modules.ActionVerifier)
local StateService = require(game.ServerScriptService.Services.StateService)
local StateChecker = require(modules.StateChecker)
local HitApplier = require(script.Parent.Parent.Modules.Utilities.HitApplier)
local Animations = require(modules.Animations)

local CharacterVitalsService = require(script.Parent.CharacterVitalsService)

local CombatService = {
	hitTypes = {}
}

local function GetValidTool(tool, character)
	if tool and tool:GetAttribute("ToolLoaded") then return tool end
	
	local foundTool = character:FindFirstChildWhichIsA("Tool")
	if foundTool and foundTool:GetAttribute("ToolLoaded") then
		if ItemDataBase:GetItemData(foundTool:GetAttribute("ID")) then
			return foundTool
		end
	end
	return tool
end

---------requiring HitTypes
for _,module  in script.Parent.Parent.Modules.HitTypes:GetChildren() do
	if module:IsA("ModuleScript") then
		CombatService.hitTypes[module.Name] = require(module)
	end
end

function CombatService:Spawn(character)
	NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "SpawnVFX",
		{
			["Character"] = character
		}
	)
end

function CombatService:Died(character)
	character:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
		if character:GetAttribute("Health_CurrentHealth") <= 0 then
			StateService:AddState(character , "Dead")
		end
	end)	
end

function CombatService:Attack(character, tool:Tool?, player:Player?, npcDamage)
	
	local humanoid = character:WaitForChild("Humanoid")
	
	if not ActionVerifier:CanAttack(character) then return end
	
	tool = GetValidTool(tool, character)
	if not tool then return end
	
	local weaponData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
	
	if tool.Name ~= weaponData.Name then
 		return
	end
	
	
	--Playing Animations
	local lastSwing = CharacterVitalsService:GetVital(character, "LastSwing")
	local lastCombo = CharacterVitalsService:GetVital(character, "LastCombo")

	if (os.clock()-lastCombo) < weaponData.ComboCooldown then
		StateService:AddState(character, "ComboCooldown", weaponData.ComboCooldown)
		return
	end
	-- Reset swing if combo window expired
	if (os.clock() - lastSwing) >= weaponData.ComboResetTime then
		CharacterVitalsService:ModifyVital(character, "Combat", "ModifySwingNumber", {
			SwingNumberChange = 0
		})
	end

	CharacterVitalsService:ModifyVital(character, "Combat", "ModifySwingNumber", {
		SwingNumberChange = 1
	})

	local trueSwingNumber = CharacterVitalsService:GetVital(character, "SwingNumber")

	if trueSwingNumber >= 5 then
		
		CharacterVitalsService:ModifyVital(character, "Combat", "ModifySwingNumber", {SwingNumberChange = 0})
		trueSwingNumber = 5
		
		CharacterVitalsService:ModifyVital(character, "Combat", "ModifyLastCombo", {LastComboChange = os.clock()})
	end

	CharacterVitalsService:ModifyVital(character, "Combat", "ModifyLastSwing", {LastSwingChange = os.clock()})

	local swingName = "Weapons."..tool.Name..".Animations.Swings.L"..tostring(trueSwingNumber)
	
	local animationToPlay = Animations:GetAnimation(humanoid.Animator, swingName)
				
	--Attack States---
	StateService:AddState(character , "Attacking", (animationToPlay.Speed * animationToPlay.Length))
	StateService:AddState(character, "NoBlock", (animationToPlay.Speed * animationToPlay.Length)+.3)
	StateService:AddState(character , "NoJump", (animationToPlay.Speed * animationToPlay.Length)+.5)
	StateService:AddState(character , "NoSprint", (animationToPlay.Speed * animationToPlay.Length)+0.35)

	animationToPlay:Play()
	
	animationToPlay:GetMarkerReachedSignal("Hit"):Once(function()	
		
		if not StateChecker:CheckState(character,"Attacking") then return end
		
		if StateChecker:CheckState(character , "Stunned") then
			return
		end
		

		
		
		--Setting Hitbox
		local hitboxClone = assets.HitboxTemplate:Clone()
		hitboxClone.Name = "M1 Hitbox"
		hitboxClone.Parent = workspace.World.Hitboxes
		hitboxClone.Size = weaponData.Hitbox or Vector3.new(5,5.5,4)
		local weld = Instance.new("Weld")
		weld.Parent = hitboxClone
		weld.Part0 = character.HumanoidRootPart
		weld.Part1 = hitboxClone
		weld.C0 = CFrame.new(0 , 0 , -3)
		
		NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "Sound" , {
			["SoundName"] = "Weapons."..tool.Name..".Sounds.Swings."..tostring(trueSwingNumber) ,
			["Parent"] = character.HumanoidRootPart
		})
		
		task.spawn(function()
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {character , workspace.World.Hitboxes}

			local alreadyHit = {}
			
			---Damage---
			while hitboxClone.Parent do 

				local partsCollected = workspace:GetPartsInPart(hitboxClone , params)
				for _, part in partsCollected do 
					if part.Parent and part.Parent:FindFirstChild("Humanoid") then
						local targetHit = part.Parent
						if alreadyHit[targetHit] then
							continue
						end
						alreadyHit[targetHit] = true

						if StateChecker:CheckState(targetHit, "Invulnerable") then continue end
						
						if player then
							NetworkingService:FireToClient(player, "CameraShake", 0.1)
						end

						HitApplier:ApplyHit({
							["Player"] = player,
							["WeaponData"] = weaponData,
							["TargetHit"] = targetHit,
							["Tool"] = tool,
							["TrueSwingNumber"] = trueSwingNumber,
							["NPCDamage"] = npcDamage,
							["HitTypes"] = CombatService.hitTypes,
							["Character"] = character,							
						})
					end
				end
				task.wait()
			end
		end)
		Debris:AddItem(hitboxClone , 0.35)
	end)
end

function CombatService:Block(character, boolean, tool:Tool?)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		
		tool = GetValidTool(tool, character)
				
		local function StartBlocking()
			if not ActionVerifier:CanBlock(character) or not tool then return end
			--Block--
			local foundData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
			if foundData then

				StateService:AddState(character, "Blocking", nil,{["weaponName"] = tool.Name})

				------Block Animations------
				local blockAnim:AnimationTrack = Animations:GetAnimation(humanoid.Animator,"Weapons."..tool.Name..".Animations.Block.Idle") 
				blockAnim:Play()

			end
		end

		local function StopBlocking()
			local  blockingInstance = character:WaitForChild("Status"):FindFirstChild("Blocking")
			if blockingInstance then
				local weaponName = blockingInstance:GetAttribute("weaponName")
				if weaponName then
					Animations:GetAnimation(humanoid.Animator, "Weapons."..weaponName..".Animations.Block.Idle"):Stop(0.1)

				end
				StateService:RemoveState(character, "Blocking")

				StateService:AddState(character, "NoBlock", 0.3)
			end
		end

		character.Status.ChildAdded:Once(function(child)
			if not tool or not ActionVerifier:CanBlock(character) then
				StopBlocking()
			end	
		end)



		if boolean == true then
			StartBlocking()
			
		elseif boolean == false then
			StopBlocking()
			
		end
	end	
end

return CombatService
