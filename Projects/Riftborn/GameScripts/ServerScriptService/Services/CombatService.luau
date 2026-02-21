--CombatService
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local players = game:GetService("Players")

local assets = replicatedStorage.Assets
local modules = replicatedStorage.Modules
local remotes = replicatedStorage.Remotes

local itemDataBase = require(replicatedStorage.Modules.Data.ItemDataBase)

local ActionVerifier = require(modules.ActionVerifier)
local stateService = require(modules.StateService)
local DataService = require(script.Parent.Parent.Services.DataService)
local HitApplier = require(script.Parent.Parent.Modules.Utilities.HitApplier)
local animationsModule = require(modules.Animations)

local CharacterVitalsService = require(script.Parent.CharacterVitalsService)


local CombatService = {
	hitTypes = {}
}

local function GetValidTool(tool, character)
	if tool and tool:GetAttribute("ToolLoaded") then return tool end
	
	local foundTool = character:FindFirstChildWhichIsA("Tool")
	if foundTool and foundTool:GetAttribute("ToolLoaded") then
		if itemDataBase:GetItemData(foundTool:GetAttribute("ID")) then
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
	remotes.ClientEffects:FireAllClients("SpawnVFX",
		{
			["Character"] = character
		}
	)
end

function CombatService:Died(character)
	local statusFolder = character:WaitForChild("Status", math.huge)
	local humanoid:Humanoid = character:WaitForChild("Humanoid" , math.huge)

	character:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
		if character:GetAttribute("Health_CurrentHealth") <= 0 then
			stateService.addState(character , "Dead")
		end
	end)	
end

function CombatService:Attack(character, tool:Tool, player:Player, npcDamage)
	
	local humanoid = character:WaitForChild("Humanoid")
	
	if not ActionVerifier:CanAttack(character) then return end
	
	tool = GetValidTool(tool, character)
	if not tool then return end
	
	local weaponData = itemDataBase:GetItemData(tool:GetAttribute("ID"))
	
	if tool.Name ~= weaponData.Name then
 		return
	end
	
	local animationsFolder = assets.Weapons[tool.Name].Animations
	
	--Playing Animations
	local lastSwing = CharacterVitalsService:GetVital(character, "LastSwing")
	local lastCombo = CharacterVitalsService:GetVital(character, "LastCombo")
	local swingNumber = CharacterVitalsService:GetVital(character, "SwingNumber")

	if (os.clock()-lastCombo) < weaponData.ComboCooldown then
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
	
	local animationToPlay:AnimationTrack? = animationsModule:GetAnimation(humanoid.Animator, swingName)
				
	---Attack States---
	stateService.addState(character , "Attacking", (animationToPlay.Speed * animationToPlay.Length))
	stateService.addState(character, "NoBlock", (animationToPlay.Speed * animationToPlay.Length)+.3)
	stateService.addState(character , "NoJump", (animationToPlay.Speed * animationToPlay.Length)+.5)
	stateService.addState(character , "NoSprint", (animationToPlay.Speed * animationToPlay.Length)+0.35)

	animationToPlay:Play()
	
	animationToPlay:GetMarkerReachedSignal("Hit"):Once(function()	
		
		if not stateService.checkState(character,"Attacking") then return end
		
		if stateService.checkState(character , "Stunned") then
			return
		end
		

		
		
		--Setting Hitbox
		local hitboxClone = assets.HitboxTemplate:Clone()
		hitboxClone.Name = "M1 Hitbox"
		hitboxClone.Parent = workspace.World.Hitboxes
		local weld = Instance.new("Weld")
		weld.Parent = hitboxClone
		weld.Part0 = character.HumanoidRootPart
		weld.Part1 = hitboxClone
		weld.C0 = CFrame.new(0 , 0 , -3)
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
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

						if stateService.checkState(targetHit, "Invulnerable") then continue end
						
						
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
		debris:AddItem(hitboxClone , 0.35)
	end)
end

function CombatService:Block(character, boolean, tool:Tool)
	
	local humanoid:Humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		
		tool = GetValidTool(tool, character)
				
		local function StartBlocking()
			if not ActionVerifier:CanBlock(character) then return end
			if not tool then return end
			--Block--
			local foundData = itemDataBase:GetItemData(tool:GetAttribute("ID"))
			if foundData then

				stateService.addState(character, "Blocking", nil,{["weaponName"] = tool.Name})

				------Block Animations------
				local blockAnim:AnimationTrack = animationsModule:GetAnimation(humanoid.Animator,"Weapons."..tool.Name..".Animations.Block.Idle") 
				blockAnim:Play()

			end
		end
		
		local function StopBlocking()
			local  blockingInstance = character:WaitForChild("Status"):FindFirstChild("Blocking")
			if blockingInstance then
				local weaponName = blockingInstance:GetAttribute("weaponName")
				if weaponName then
					animationsModule:GetAnimation(humanoid.Animator, "Weapons."..weaponName..".Animations.Block.Idle"):Stop(0.1)

				end
				blockingInstance:Destroy()

				stateService.addState(character, "NoBlock", 0.3)
			end
		end


		if boolean == true then
			StartBlocking()
			
		elseif boolean == false then
			StopBlocking()
			
		end
		
		if not tool then
			StopBlocking()
		end	
	end	
end

return CombatService