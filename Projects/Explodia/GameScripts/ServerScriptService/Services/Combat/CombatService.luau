local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
--CombatService
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local CombatUtils = require(ServerScriptService.Modules.Utilities.CombatUtils)
local Connections = require(ReplicatedStorage.Modules.Core.Connections)
local assets = ReplicatedStorage.Assets
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

function CombatService:Attack(character)
	local humanoid = character:WaitForChild("Humanoid")
	local tool = character:FindFirstChildWhichIsA("Tool")

	if not ActionVerifier:CanAttack(character) or not tool then
		return
	end
	local weaponData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))

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

	local swingName = "Weapons." .. tool.Name .. ".Animations.Swings.L" .. tostring(trueSwingNumber)

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
		local hitboxClone = assets.HitboxTemplate:Clone()
		hitboxClone.Name = "M1 Hitbox"
		hitboxClone.Parent = workspace.World.Hitboxes
		hitboxClone.Size = weaponData.Hitbox or Vector3.new(5, 5.5, 4)
		local weld = Instance.new("Weld")
		weld.Parent = hitboxClone
		weld.Part0 = character.HumanoidRootPart
		weld.Part1 = hitboxClone
		weld.C0 = CFrame.new(0, 0, -3)

		NetworkingService:FireInRange("ClientEffects", character.HumanoidRootPart.Position, nil, "Sound", {
			["Sound"] = assets.Weapons
				:FindFirstChild(tool.Name).Sounds.Swings
				:FindFirstChild(tostring(trueSwingNumber)),
		})
		Debris:AddItem(hitboxClone, 0.35)

		local params = OverlapParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = { character, workspace.World.Hitboxes }

		---Damage---
		local Targets = {}
		for _, part in workspace:GetPartsInPart(hitboxClone, params) do
			local target = part:FindFirstAncestorOfClass("Model")
			local humanoid = target and target:FindFirstChild("Humanoid")
			if target and humanoid and not Targets[target] then
				Targets[target] = true
			end
		end

		if Players:GetPlayerFromCharacter(character) then
			NetworkingService:FireToClient(Players:GetPlayerFromCharacter(character), "CameraShake", 0.1)
		end
		for targetHit, _ in pairs(Targets) do
			if StateChecker:CheckState(targetHit, "Invulnerable") then
				continue
			end
			CombatUtils:ApplyHit({
				["Attacker"] = character,
				["TargetHit"] = targetHit,
				["Tool"] = tool,
				["TrueSwingNumber"] = trueSwingNumber,
			})
		end
	end)
end

function CombatService:Block(character, boolean)
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local tool = character:FindFirstChildWhichIsA("Tool")
			local function StartBlocking()
				if not ActionVerifier:CanBlock(character) or not tool then
					return
				end
				--Block--
				local foundData = ItemDataBase:GetItemData(tool:GetAttribute("ID"))
				if foundData then
					StateService:AddState(character, "Blocking", nil, { ["weaponName"] = tool.Name })

					------Block Animations------
					local blockAnim: AnimationTrack =
						Animations:GetAnimation(humanoid, "Weapons." .. tool.Name .. ".Animations.Block.Idle")
					blockAnim:Play()
				end
			end

			local function StopBlocking()
				local blockingInstance = character:WaitForChild("Status"):FindFirstChild("Blocking")
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

			character.Status.ChildAdded:Once(function(child)
				if StateChecker:CheckState(character, "Blocking") then
					if not tool or not ActionVerifier:CanBlock(character) then
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
