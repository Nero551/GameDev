local VitalsService = {}

VitalsService.CharacterVitals = {}
VitalsService.cachedModules = {}

for _, module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		VitalsService.cachedModules[module.Name] = require(module)
	end
end

local function SyncAttributes(character: Model?, vitalsTable)
	if not character then
		return
	end

	-- Recursive function to flatten tables and set attributes
	local function FlattenAndSet(prefix, tbl)
		for key, value in pairs(tbl) do
			local attrName = prefix and (prefix .. "_" .. key) or key

			if typeof(value) == "table" then
				-- recurse into the table
				FlattenAndSet(attrName, value)
			else
				character:SetAttribute(attrName, value)
			end
		end
	end

	FlattenAndSet(nil, vitalsTable)
end

function VitalsService:Create(character)
	if VitalsService.CharacterVitals[character] then
		return VitalsService.CharacterVitals[character]
	end

	VitalsService.CharacterVitals[character] = {
		Health = {
			CurrentHealth = 100,
			MaxHealth = 100,
			HealthRegen = 1,
		},
		Mana = {
			CurrentMana = 100,
			MaxMana = 100,
			ManaRegen = 1,
		},

		FlashStep = {
			CurrentFlashStep = 3,
			MaxFlashStep = 3,
		},

		InHand = "",
		WalkSpeed = 10,
		JumpPower = 50,

		BlockCounter = 0,
		LastCombo = 0,
		LastSwing = 0,
		SwingNumber = 0,
	}

	SyncAttributes(character, VitalsService.CharacterVitals[character])

	return VitalsService.CharacterVitals[character]
end

function VitalsService:Cleanup(character)
	if VitalsService.CharacterVitals[character] then
		VitalsService.CharacterVitals[character] = nil
	end
end

function VitalsService:GetVital(character, vitalName)
	if not VitalsService.CharacterVitals[character] then
		VitalsService:Create(character)
	end

	if VitalsService.CharacterVitals[character][vitalName] then
		return VitalsService.CharacterVitals[character][vitalName]
	end
	return
end

function VitalsService:ModifyVital(character, vital, funcName, argumentData)
	if not VitalsService.CharacterVitals[character] then
		VitalsService:Create(character)
	end

	local vitalModule = VitalsService.cachedModules[vital]

	if vitalModule then
		local func = vitalModule[funcName]
		if typeof(func) == "function" then
			func(vitalModule, character, argumentData)
		else
			warn("Invalid vital modification:", vital, funcName)
		end
	end
	SyncAttributes(character, VitalsService.CharacterVitals[character])
end

return VitalsService
