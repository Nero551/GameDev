local players = game:GetService("Players")
local repstor = game:GetService("ReplicatedStorage")
local remotes = repstor.Remotes

local CharacterVitalsService = {}

CharacterVitalsService.CharacterVitals = {}
CharacterVitalsService.cachedModules = {}

for _,module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		CharacterVitalsService.cachedModules[module.Name] = require(module)
	end
	
end

local function CreateFolder(character, vitalsTable)

	for vitalName, data in pairs(vitalsTable) do
		if typeof(data) == "table" then
			for key, value in pairs(data) do
				character:SetAttribute(vitalName .. "_" .. key, value)
			end
		else
			character:SetAttribute(vitalName, data)
		end
	end
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
		AirJump = 3,
		
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
		CharacterVitalsService:Cleanup(character) -- remove old character vitals
	end)
	
	CreateFolder(character, CharacterVitalsService.CharacterVitals[character])
	
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
		vitalModule[funcName](vitalModule ,character, argumentData)
	end
	
	CreateFolder(character, CharacterVitalsService.CharacterVitals[character])
	
	local player = players:GetPlayerFromCharacter(character)
	if player then
		--remotes.UpdateVitals:FireClient(player, CharacterVitalsService.CharacterVitals[character])
	end

end

return CharacterVitalsService
