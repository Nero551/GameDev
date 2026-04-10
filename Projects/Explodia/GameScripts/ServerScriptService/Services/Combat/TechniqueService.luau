local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local assets = ReplicatedStorage.Assets
local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local HitService = require(script.Parent.HitService)
local DataService = require(ServerScriptService.Services.Core.DataService)
local AIService = require(ServerScriptService.Services.NPC.AIService)
local StateService = require(game.ServerScriptService.Services.Core.StateService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)
local ActionVerifier = require(game.ReplicatedStorage.Modules.Helpers.ActionVerifier)

local Animations = require(game.ReplicatedStorage.Modules.Core.Animations)
local TechniqueData = require(game.ReplicatedStorage.Modules.Data.TechniqueData)
local ItemDataBase = require(ReplicatedStorage.Modules.Data.ItemDataBase)

local TechniqueService = {}
function TechniqueService:SetupTechniques(player)
	local techniques = DataService:GetTable(player, "Techniques")
	local folder = player:FindFirstChild("Techniques")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Techniques"
		folder.Parent = player

		local subFolder1 = Instance.new("Folder")
		subFolder1.Name = "Obtained"
		subFolder1.Parent = folder

		local subFolder2 = Instance.new("Folder")
		subFolder2.Name = "Equipped"
		subFolder2.Parent = folder
	end
	local obtained = folder:FindFirstChild("Obtained")
	local equipped = folder:FindFirstChild("Equipped")

	for _, techniqueID in ipairs(techniques.Obtained) do
		local value = obtained:FindFirstChild(techniqueID)
		if not value then
			value = Instance.new("StringValue")
			value.Name = techniqueID
			value.Parent = obtained
		end
	end

	for slotNumber, techniqueID in ipairs(techniques.Equipped) do
		local value = equipped:FindFirstChild(slotNumber)
		if not value then
			value = Instance.new("StringValue")
			value.Name = slotNumber
			value.Parent = equipped
			value:SetAttribute("TechniqueID", techniqueID)
		end
	end
end

function TechniqueService:ObtainTechnique(player, techniqueID)
	local techniques = DataService:GetTable(player, "Techniques")
	local techniqueData = TechniqueData:GetTechniqueData(techniqueID)
	if not techniqueData then
		return
	end

	for _, obtainedTech in ipairs(techniques.Obtained) do
		if obtainedTech == techniqueID then
			return
		end
	end

	table.insert(techniques.Obtained, techniqueID)

	local obtained = player:FindFirstChild("Techniques"):FindFirstChild("Obtained")
	local value = obtained:FindFirstChild(techniqueID)
	if not value then
		value = Instance.new("StringValue")
		value.Name = techniqueID
		value.Parent = obtained
	end
end

function TechniqueService:UnEquipTechnique(player, techniqueID)
	local techniques = DataService:GetTable(player, "Techniques")
	local techniqueData = TechniqueData:GetTechniqueData(techniqueID)

	if not techniqueData then
		return
	end

	local slotNumber = table.find(techniques.Equipped, techniqueID)

	if slotNumber then
		table.remove(techniques.Equipped, slotNumber)
		local equipped = player:FindFirstChild("Techniques"):FindFirstChild("Equipped")
		local value = equipped:FindFirstChild(tostring(slotNumber))
		if value then
			value:Destroy()
		end
	end


end

function TechniqueService:EquipTechnique(player, techniqueID)
	local techniques = DataService:GetTable(player, "Techniques")
	local techniqueData = TechniqueData:GetTechniqueData(techniqueID)

	if not techniqueData or not table.find(techniques.Obtained, techniqueID) then
		return
	end

	if #techniques.Equipped >= 12 then
		return
	end
	if table.find(techniques.Equipped, techniqueID) then
		return
	end
	table.insert(techniques.Equipped, techniqueID)
	local slotNumber = table.find(techniques.Equipped, techniqueID)

	local equipped = player:FindFirstChild("Techniques"):FindFirstChild("Equipped")
	local value = equipped:FindFirstChild(slotNumber)
	if not value then
		value = Instance.new("StringValue")
		value.Name = slotNumber
		value.Parent = equipped
	end
	value:SetAttribute("TechniqueID", techniqueID)

	print(techniques)
end

function TechniqueService:UseTechnique(character, techniqueSlot, mouse)
	local player = Players:GetPlayerFromCharacter(character)

	local techniqueID
	if player then
		local techniques = DataService:GetTable(player, "Techniques")
		techniqueID = techniques.Equipped[techniqueSlot]
	else
		techniqueID = AIService.ActiveAIs[character] and AIService.ActiveAIs[character].Techniques[techniqueSlot]
	end
	if not techniqueID then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")
	local itemData = ItemDataBase:GetItemData(VitalsService:GetVital(character, "ActiveHand"))
	local techniqueData = TechniqueData:GetTechniqueData(techniqueID)

	if not itemData then
		print("Weapon Data not found for Currently Active Hand", VitalsService:GetVital(character, "ActiveHand"))
		return
	end
	if not techniqueData then
		print("Technique data not found for:", techniqueID)
		return
	end
	if not ActionVerifier:CanTechnique(character, techniqueSlot) then
		return
	end

	if not table.find(techniqueData.AllowedWeaponSubTypes, itemData.SubType) then
		return
	end

	if player then
		--local inventory = DataService:GetTable(player, "Inventory")
		local techniques = DataService:GetTable(player, "Techniques")

		if not table.find(techniques.Equipped, techniqueID) or not table.find(techniques.Obtained, techniqueID) then
			return
		end

		---Checking Mastery---
		-- if inventory[VitalsService:GetVital(character, "ActiveHand")] then
		-- 	if inventory[VitalsService:GetVital(character, "ActiveHand")].Mastery < techniqueData.Mastery then
		-- 		NetworkingService:FireToClient(player, "PopUp", {
		-- 			["Mastery"] = inventory[VitalsService:GetVital(character, "ActiveHand")].Mastery,
		-- 			["RequiredMastery"] = techniqueData.Mastery,
		-- 		})
		-- 		return
		-- 	end
		-- end

		---Taking Mana/Stamina---
		if techniqueData.DamageType then
			if techniqueData.DamageType == "Physical" then
				local playerStamina = VitalsService:GetVital(character, "Stamina")
				if playerStamina.CurrentStamina < techniqueData.Cost then
					assets.Shared.MenuSounds.Error:Play()
					NetworkingService:FireToClient(player, "PopUp", {
						["TechniqueName"] = techniqueData.TechniqueName,
						["RequiredStamina"] = techniqueData.Cost,
					})
					return
				end
				VitalsService:ModifyVital(character, "Stamina", "ModifyStamina", {
					["StaminaChange"] = -techniqueData.Cost,
				})
			elseif techniqueData.DamageType == "Magic" then
				local playerMana = VitalsService:GetVital(character, "Mana")
				if playerMana.CurrentMana < techniqueData.Cost then
					assets.Shared.MenuSounds.Error:Play()
					NetworkingService:FireToClient(player, "PopUp", {
						["TechniqueName"] = techniqueData.TechniqueName,
						["RequiredMana"] = techniqueData.Cost,
					})
					return
				end
				VitalsService:ModifyVital(character, "Mana", "ModifyMana", {
					["ManaChange"] = -techniqueData.Cost,
				})
			end
		end

		NetworkingService:FireToClient(player, "CameraShake", 0.25)
	end

	---Animation---
	local animation =
		Animations:GetAnimation(humanoid, "Shared.Techniques." .. techniqueData.TechniqueName .. ".Animation")
	if not animation then
		warn("Animation Not Found")
		return
	end
	animation:Play()

	---Ability States---
	StateService:AddState(character, "Technique" .. techniqueSlot .. " Cooldown", techniqueData.Cooldown)
	StateService:AddState(character, "Invulnerable", 0.2)
	StateService:AddState(character, "Casting", animation.Length)

	animation:GetMarkerReachedSignal("Hit"):Once(function()
		local hrp = character:WaitForChild("HumanoidRootPart")

		---HitBox---
		local hitboxClone = assets.HitboxTemplate:Clone()
		if techniqueData.OnMouse and mouse then
			hitboxClone.Name = techniqueData.TechniqueName .. " Hitbox"
			hitboxClone.Size = techniqueData.HitBoxSize
			hitboxClone.Position = mouse
			hitboxClone.Parent = workspace.World.Hitboxes
		else
			hitboxClone.Name = techniqueData.TechniqueName .. " Hitbox"
			hitboxClone.Size = techniqueData.HitBoxSize
			hitboxClone.Position = hrp.Position
				+ techniqueData.HitBoxPosition
				+ hrp.CFrame.LookVector * techniqueData.HitBoxLookVector
			hitboxClone.Orientation = hrp.Orientation + techniqueData.HitBoxRotation
			hitboxClone.Parent = workspace.World.Hitboxes
		end

		---VFX---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "TechniqueVFX", {
			["VFX"] = assets.Shared.Techniques[techniqueData.TechniqueName].VFX,
			["HitBoxName"] = hitboxClone.Name,
			["Caster"] = character,
		})

		---Sound---
		NetworkingService:FireInRange("ClientEffects", hitboxClone.Position, nil, "TechniqueSound", {
			["Sound"] = assets.Shared.Techniques[techniqueData.TechniqueName].Activate,
			["HitBoxName"] = hitboxClone.Name,
		})
		Debris:AddItem(hitboxClone, animation.Length)

		---Damage---
		HitService:Apply(character, techniqueData, hitboxClone)
	end)
end

return TechniqueService
