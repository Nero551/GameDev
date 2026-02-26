local TitleData = {}
TitleData.Titles = {
	["title_0000000001"] = {
		Name = "Singularity",
		Type = "Title",
		Color = {
			{Color = "63, 33, 130", Position = 0},
			{Color = "130, 163, 255", Position = 0.5},
			{Color = "149, 20, 255", Position = 1},
			
		},
		Buffs = {
			CriticalRate = {Percent = 0.5},
			Health = {Percent = 0.5, Flat = 5},
		}
	}	
	,
	["title_0000000002"] = {
		Name = "Destroyer",
		Type = "Title",
		Buffs = {
			CriticalRate = {Percent = 0.5},
			Melee = {Percent = 0.5},
		}
	}	
	,
	["title_0000000003"] = {
		Name = "Cosmic Traveler",
		Type = "Title",
		Color = {
			{Color = "2, 0, 36", Position = 0},
			{Color = "9, 9, 121", Position = 0.5},
			{Color = "0, 212, 255", Position = 1},

		},
		Buffs = {
			CriticalRate = {Percent = 0.1},
			Melee = {Percent = 0.5},
			Sword = {Flat = 50},
			CriticalDamage = {Percent = 1},
		}
	}	
	,
}









function TitleData:GetTitleID(title)
	if not title then return nil end
	
	for id, data in pairs(self.Titles) do
		if data.Name == title then
			return id
		end
	end

	return nil
end

return TitleData
