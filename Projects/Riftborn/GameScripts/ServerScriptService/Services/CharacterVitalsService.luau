local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes
local connections = require(repstor.Modules.Connections)

local CharacterVitalsService = {}

CharacterVitalsService.CharacterVitals = {}
CharacterVitalsService.cachedModules = {}

local characterVitalsScripts = script.Parent.Parent.Modules.Utilities.CharacterVitalsScripts

for _,module in ipairs(characterVitalsScripts:GetChildren()) do
	if module:IsA("ModuleScript") then
		CharacterVitalsService.cachedModules[module.Name] = require(module)
	end
	
end

local function SyncAttributes(character: Model?, vitalsTable)
	if not character then return end

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



function CharacterVitalsService:Create(character)	
	if CharacterVitalsService.CharacterVitals[character] then
		return CharacterVitalsService.CharacterVitals[character]
	end
		
	CharacterVitalsService.CharacterVitals[character] = {
		Health = {
			CurrentHealth = 100,
			MaxHealth = 100,
			HealthRegen = 1,
		},
		Mana = {
			CurrentMana = 100,
			MaxMana = 100,
			ManaRegen = 1
		},

		FlashStep = {
			CurrentFlashStep = 3,
			MaxFlashStep = 3,
			
		},
		AirJump = {
			CurentAirJump = 3,
			MaxAirJump = 3
			
		},
		
		StatusAilments = {},
		
		WalkSpeed = 10,
		JumpPower = 50,
		
		CamVectors = {
			CamLook = 0,
			CamRight = 0,
		},
		
		BlockCounter = 0,
		LastCombo = 0,
		LastSwing = 0,
		SwingNumber = 0
	}
	
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		CharacterVitalsService.CharacterVitals[character].Health.HealthRegen = 0
		CharacterVitalsService:ModifyVital(character, "Health", "ModifyHealth", {
			["HealthChange"] = -CharacterVitalsService.CharacterVitals[character].Health.CurrentHealth

		})
		task.wait(3)
		CharacterVitalsService:Cleanup(character)
		connections:CleanupConnections(character)
	end)
	
	character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			CharacterVitalsService:Cleanup(character)
		end
	end)

	
	SyncAttributes(character, CharacterVitalsService.CharacterVitals[character])
	
	local player = players:GetPlayerFromCharacter(character)
	if player then
		--remotes.UpdateVitals:FireClient(player, CharacterVitalsService.CharacterVitals[character])
	end
	
	return CharacterVitalsService.CharacterVitals[character]
end

function CharacterVitalsService:Cleanup(character)
	if CharacterVitalsService.CharacterVitals[character] then
		CharacterVitalsService.CharacterVitals[character] = nil
	end
end

function CharacterVitalsService:GetVital(character, vitalName)
	if not CharacterVitalsService.CharacterVitals[character] then
		CharacterVitalsService:Create(character)
	end
	
	if CharacterVitalsService.CharacterVitals[character][vitalName] then
		return CharacterVitalsService.CharacterVitals[character][vitalName]
	end
end

function CharacterVitalsService:ModifyVital(character,vital, funcName , argumentData)	
	

	if not CharacterVitalsService.CharacterVitals[character] then
		CharacterVitalsService:Create(character)
	end
		
	local vitalModule = CharacterVitalsService.cachedModules[vital]
	
	if vitalModule then
		local func =  vitalModule[funcName]
		if typeof(func) == "function" then
			func(vitalModule, character, argumentData)
		else
			warn("Invalid vital modification:", vital, funcName)
		end
	end
	
	SyncAttributes(character, CharacterVitalsService.CharacterVitals[character])
	
	local player = players:GetPlayerFromCharacter(character)
	if player then
		--remotes.UpdateVitals:FireClient(player, CharacterVitalsService.CharacterVitals[character])
	end

end

return CharacterVitalsService
