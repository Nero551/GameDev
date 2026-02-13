local DataService = require(script.Parent.Parent.Services.DataService)

local ManaService = {}
---Create StatsFolder---
local function CreateManaValues(parent:Player?)
	
	local ManaFolder = parent:FindFirstChild("PlayerMana")
	
	if not ManaFolder then

		ManaFolder = Instance.new("Folder")
		ManaFolder.Parent = parent
		ManaFolder.Name = "PlayerMana"

		local currentMana = Instance.new("NumberValue")
		currentMana.Name = "CurrentMana"
		currentMana.Value = 0 -- 0.1 = 10%
		currentMana.Parent = ManaFolder

		local maxMana = Instance.new("NumberValue")
		maxMana.Name = "MaxMana"
		maxMana.Parent = ManaFolder
	end

end

function ManaService:SetupMana(player:Player)
	local playerStats = DataService:GetTable(player,"Stats")
	local playerMana = DataService:GetTable(player, "Mana")
	CreateManaValues(player)
	local statsFolder = player:WaitForChild("PlayerMana")
	local ManaStat = playerStats.Mana.Final
	local  maxMana = playerMana.MaxMana
	local currentMana = playerMana.CurrentMana
	maxMana = ManaStat * 5
	currentMana = ManaStat * 5
	statsFolder.MaxMana.Value = maxMana
	statsFolder.CurrentMana.Value = currentMana
	
end

function ManaService:UpdateMana(player:Player)
	local playerStats = DataService:GetTable(player,"Stats")
	local playerMana = DataService:GetTable(player, "Mana")
	
	local manaFolder = player:WaitForChild("PlayerMana")
	if playerStats then
		playerMana.MaxMana = playerStats.Mana.Final * 5
		playerMana.ManaRegen = (playerStats.Mana.Final * 5) / 100
		if playerMana.CurrentMana < 0  then
			playerMana.CurrentMana = 0
		end
		if playerMana.CurrentMana > playerMana.MaxMana then
			playerMana.CurrentMana = playerMana.MaxMana
		end
		manaFolder.MaxMana.Value = playerMana.MaxMana
		manaFolder.CurrentMana.Value = playerMana.CurrentMana
	end


end

function ManaService:ManaRegen(dt)
	for player, data in pairs(DataService.PlayerDatas) do
		if data.Mana.CurrentMana < data.Mana.MaxMana then
			data.Mana.CurrentMana = math.min(
				data.Mana.CurrentMana + data.Mana.ManaRegen * dt,
				data.Mana.MaxMana
			)

			ManaService:UpdateMana(player)
		end
	end
end

return ManaService
