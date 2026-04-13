local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
--CombatService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local HitService = require(script.Parent.HitService)
local Connections = require(ReplicatedStorage.Modules.Core.Connections)
local ItemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local CombatService = {}

function CombatService:Spawn(character)
	NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "SpawnVFX", {
		["Character"] = character,
	})
end

function CombatService:Died(character)
	Connections:AddConnection(
		character,
		"Character",
		"Death",
		character:GetAttributeChangedSignal("Health_CurrentHealth"):Connect(function()
			if character:GetAttribute("Health_CurrentHealth") <= 0 then
				StateService:AddState(character, "Dead")
				Connections:RemoveConnection(character, "Character", "Death")
			end
		end)
	)
end

--TODO When adding projectile attacks , split basic attack into two paths/functions
--TODO Maybe even add ProjectileService
--TODO one melee and other projectile , use same setup when adding HeavyAttack

function CombatService:BasicAttack(character)
	local humanoid = character:WaitForChild("Humanoid")
	local itemID = VitalsService:GetVital(character, "ActiveHand")

	if not ActionVerifier:CanBasicAttack(character) or itemID == "" then
		return
	end
	local weaponData = ItemDataBase:GetItemData(itemID)

	--Playing Animations
	local lastSwing = VitalsService:GetVital(character, "LastSwing")
	local lastCombo = VitalsService:GetVital(character, "LastCombo")

	if (os.clock() - lastCombo) < weaponData.ComboCooldown then
		StateService:AddState(character, "ComboCooldown", weaponData.ComboCooldown)
		return
	end
	-- Reset swing if combo window expired
	if (os.clock() - lastSwing) >= weaponData.ComboResetTime then
		VitalsService:ModifyVital(character, "Combat", "ModifySwingNumber", {
			SwingNumberChange = 0,
		})
	end

	VitalsService:ModifyVital(character, "Combat", "ModifySwingNumber", {
		SwingNumberChange = 1,
	})

	local trueSwingNumber = VitalsService:GetVital(character, "SwingNumber")

	if trueSwingNumber >= 5 then
		VitalsService:ModifyVital(character, "Combat", "ModifySwingNumber", { SwingNumberChange = 0 })
		trueSwingNumber = 5

		VitalsService:ModifyVital(character, "Combat", "ModifyLastCombo", { LastComboChange = os.clock() })
	end

	VitalsService:ModifyVital(character, "Combat", "ModifyLastSwing", { LastSwingChange = os.clock() })

	local swingName = "Weapons." .. weaponData.Name .. ".Animations.Swings.L" .. tostring(trueSwingNumber)
	local animationToPlay = Animations:GetAnimation(humanoid, swingName)

	--Attack States---
	StateService:AddState(character, "Attacking", (animationToPlay.Speed * animationToPlay.Length))
	StateService:AddState(character, "NoBlock", (animationToPlay.Speed * animationToPlay.Length) + 0.3)
	StateService:AddState(character, "NoJump", (animationToPlay.Speed * animationToPlay.Length) + 0.5)
	StateService:AddState(character, "NoSprint", (animationToPlay.Speed * animationToPlay.Length) + 0.35)

	animationToPlay:Play()

	animationToPlay:GetMarkerReachedSignal("Hit"):Once(function()
		if not StateChecker:CheckState(character, "Attacking") then
			return
		end

		if StateChecker:CheckState(character, "Stunned") then
			return
		end

		--Setting Hitbox
		local hitboxClone = ReplicatedStorage.Assets.HitboxTemplate:Clone()
		hitboxClone.Name = "M1 Hitbox"
		hitboxClone.Parent = workspace.World.Hitboxes
		hitboxClone.Size = weaponData.Hitbox or Vector3.new(5, 5.5, 4)
		local weld = Instance.new("Weld")
		weld.Parent = hitboxClone
		weld.Part0 = character.HumanoidRootPart
		weld.Part1 = hitboxClone
		weld.C0 = CFrame.new(0, 0, -3)

		NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "Sound", {
			["Sound"] = ReplicatedStorage.Assets.Weapons
				:FindFirstChild(weaponData.Name).Sounds.Swings
				:FindFirstChild(tostring(trueSwingNumber)),
			["Parent"] = character.HumanoidRootPart,
		})
		Debris:AddItem(hitboxClone, 0.35)

		if Players:GetPlayerFromCharacter(character) then
			NetworkingService:FireToClient(Players:GetPlayerFromCharacter(character), "CameraShake", 0.1)
		end

		HitService:Apply(character, weaponData, hitboxClone, trueSwingNumber)
	end)
end

function CombatService:HeavyAttack(character) end

function CombatService:Block(character, boolean)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then
		local function StartBlocking()
			local itemID = VitalsService:GetVital(character, "ActiveHand")
			local weaponData = ItemDataBase:GetItemData(itemID)
			if not ActionVerifier:CanBlock(character) or itemID == "" then
				return
			end
			--Block--
			local foundData = ItemDataBase:GetItemData(itemID)
			if foundData then
				StateService:AddState(character, "Blocking", nil, { ["weaponName"] = weaponData.Name })

				------Block Animations------
				local blockAnim: AnimationTrack =
					Animations:GetAnimation(humanoid, "Weapons." .. weaponData.Name .. ".Animations.Block.Idle")
				blockAnim:Play()
			end
		end

		local function StopBlocking()
			local blockingInstance = character:WaitForChild("State"):FindFirstChild("Blocking")
			if blockingInstance then
				local weaponName = blockingInstance:GetAttribute("weaponName")
				if weaponName then
					Animations:GetAnimation(humanoid, "Weapons." .. weaponName .. ".Animations.Block.Idle")
					Animations:GetAnimation(humanoid, "Weapons." .. weaponName .. ".Animations.Block.Idle"):Stop(0.1)
				end
				StateService:RemoveState(character, "Blocking")

				StateService:AddState(character, "NoBlock", 0.3)
			end
		end

		character.State.ChildAdded:Once(function(child)
			if StateChecker:CheckState(character, "Blocking") then
				if VitalsService:GetVital(character, "ActiveHand") == "" or not ActionVerifier:CanBlock(character) then
					StopBlocking()
				end
			end
		end)

		if boolean == 1 then
			StartBlocking()
		elseif boolean == 0 then
			StopBlocking()
		end
	end
end

return CombatService
