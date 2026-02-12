--CombatService
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local players = game:GetService("Players")

local assets = replicatedStorage.Assets
local modules = replicatedStorage.Modules
local remotes = replicatedStorage.Remotes

local animationsFolder = assets.Animations
local itemDataBase = require(replicatedStorage.Modules.ItemDataBase)

local ActionVerifier = require(modules.ActionVerifier)
local stateService = require(modules.StateService)
local DataService = require(script.Parent.Parent.ServerModules.DataService)


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
for _,module  in script.Parent.Parent.ServerModules.HitTypes:GetChildren() do
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

	task.spawn(function()
		local coreFolder = character:WaitForChild("Core", math.huge)
		local animationModule = require(coreFolder.Animations)
		animationModule.loadAnims(humanoid.Animator ,assets.Animations.Character)
	end)
	humanoid.Died:Once(function()
		stateService.addState(character , "Dead")
	end)	
end

function CombatService:Attack(character, tool:Tool, player:Player, npcDamage)
	
	
	
	if not ActionVerifier:CanAttack(character) then return end
	
	tool = GetValidTool(tool, character)
	if not tool then return end
	
	local weaponData = itemDataBase:GetItemData(tool:GetAttribute("ID"))
	
	if tool.Name ~= weaponData.Name then
 		return
	end
	local configurationFolder = character:FindFirstChild("Configuration")
	if not configurationFolder then return end

	--Playing Animations
	local coreFolder = character.Core
	local animationsModule = require(coreFolder.Animations)

	local lastSwing = configurationFolder.LastSwing
	local lastCombo = configurationFolder.LastCombo
	local swingNumber = configurationFolder.SwingNumber

	if (os.clock()-lastCombo.Value) < weaponData.ComboCooldown then
		
		return
	end
	if (os.clock()-lastSwing.Value) >= weaponData.ComboResetTime then
		swingNumber.Value = 0
	end
	for  connectionName , connection in animationsModule.connections do
		if string.find(connectionName, tool.Name..".Swings") then
			animationsModule.connections[connectionName]:Disconnect()
			animationsModule.connections[connectionName] = nil
		end
	end
	local trueSwingNumber =  nil
	swingNumber.Value += 1
	trueSwingNumber = swingNumber.Value
	if swingNumber.Value >= 5 then
		swingNumber.Value = 0
		trueSwingNumber = 5
		lastCombo.Value = os.clock()
	end
	lastSwing.Value = os.clock()
	local swingName = "Weapons."..tool.Name..".Swings.L"..tostring(trueSwingNumber)
	local animationToPlay:AnimationTrack = animationsModule.loadedAnimations[swingName]
	
	---Attack States---
	stateService.addState(character , "Attacking", animationToPlay.Length)
	stateService.addState(character, "NoBlock", animationToPlay.Length+.3)
	stateService.addState(character , "NoJump", animationToPlay.Length+.5)
	stateService.addState(character , "NoSprint", animationToPlay.Length+0.35)

	animationToPlay:Play()

	animationsModule.connections[swingName] = animationToPlay:GetMarkerReachedSignal("Hit"):Once(function()	
		
		if not stateService.checkState(character,"Attacking") then return end
		
		if stateService.checkState(character , "Stunned") then
			return
		end
		
		replicatedStorage.Remotes.ClientEffects:FireAllClients("Sound" , {
			["SoundName"] = "Weapons."..tool.Name..".Swings."..tostring(trueSwingNumber) ,
			["Parent"] = character.HumanoidRootPart
		})
		
		
		
		--Setting Hitbox
		hitboxClone = assets.HItboxTemplate:Clone()
		hitboxClone.Name = "M1 Hitbox"
		hitboxClone.Parent = workspace.World.Hitboxes
		local weld = Instance.new("Weld")
		weld.Parent = hitboxClone
		weld.Part0 = character.HumanoidRootPart
		weld.Part1 = hitboxClone
		weld.C0 = CFrame.new(0 , 0 , -3)
		
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

						if stateService.checkState(targetHit, "Invulnerable") then return end
						
						local playerDamageStat
						local playerCriticalDamageStat
						local playerCriticalRateStat
						local targetDefenseStat = 0
						if player then
							local playerStats = DataService:GetTable(player,"Stats")
							playerDamageStat = playerStats[weaponData.Type].Final
							playerCriticalDamageStat = playerStats.CriticalDamage.Percent + weaponData.CriticalDamage + 1
							playerCriticalRateStat = (playerStats.CriticalRate.Percent + weaponData.CriticalRate) * 100
						end

						if players:GetPlayerFromCharacter(targetHit) then
							targetDefenseStat = DataService:GetTable(players:GetPlayerFromCharacter(targetHit), "Stats").Defense.Final 
						end
						
						---BlockBreakCounter---
						local status = targetHit:FindFirstChild("Status")
						if not status then return end
						local blockCounter = status:WaitForChild("BlockCounter")

						local isBlocking = stateService.checkState(targetHit, "Blocking")

						if isBlocking then
							---BlockBreak---
							if blockCounter.Value == 4 then
								blockCounter.Value = 0
								blockCounter.Value = math.clamp(blockCounter.Value, 0 , 4)
								CombatService.hitTypes["BlockBreak"](character , targetHit , tool)	

							else
								---Do Blocked HitType----
								blockCounter.Value += 1
								blockCounter.Value = math.clamp(blockCounter.Value, 0 , 4)
								CombatService.hitTypes["Blocked"](character , targetHit ,
									tool, playerDamageStat, targetDefenseStat, player , nil, npcDamage)
							end
						else
							---Critical HitType---
							if playerCriticalDamageStat and playerCriticalRateStat then
								if math.random(0 , 100) <= playerCriticalRateStat then
									CombatService.hitTypes["Critical"](character , targetHit , tool ,trueSwingNumber,
										(trueSwingNumber == 5 and true or false),  playerDamageStat , playerCriticalDamageStat,
										targetDefenseStat, player, nil	, npcDamage)
								end	
							else
								-----Defualt HitType---
								print(tool, tool.Parent)
								CombatService.hitTypes["Default"](character , targetHit, tool, trueSwingNumber,
									(trueSwingNumber == 5 and true or false), playerDamageStat, targetDefenseStat,
									player ,nil, npcDamage)
							end
						end
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

		local coreFolder = character:FindFirstChild("Core")
		if not coreFolder then return end
		
		local animationsModule = coreFolder:FindFirstChild("Animations")
		if not animationsModule then return end
		
		local loadedAnimations = require(animationsModule).loadedAnimations
		
		local function StartBlocking()
			if not ActionVerifier:CanBlock(character) then return end
			if not tool then return end
			--Block--
			local foundData = itemDataBase:GetItemData(tool:GetAttribute("ID"))
			if foundData then

				stateService.addState(character, "Blocking", nil,{["weaponName"] = tool.Name})

				------Block Animations------
				local blockAnim:AnimationTrack = loadedAnimations["Weapons."..tool.Name..".Block.Idle"]
				blockAnim:Play()

			end
		end
		
		local function StopBlocking()
			local  blockingInstance = character:WaitForChild("Status"):FindFirstChild("Blocking")
			if blockingInstance then
				local weaponName = blockingInstance:GetAttribute("weaponName")
				if weaponName then
					loadedAnimations["Weapons."..weaponName..".Block.Idle"]:Stop(0.1)

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