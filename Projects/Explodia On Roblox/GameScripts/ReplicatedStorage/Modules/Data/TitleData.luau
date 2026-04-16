local TitleData = {}
TitleData.Titles = {
	["title_0000000001"] = {
		Name = "Singularity",
		Type = "Title",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 33, 130)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 163, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(149, 20, 255)),
		}),
		Buffs = {
			CriticalRate = { Percent = 0.5 },
			Health = { Percent = 0.5, Flat = 5 },
		},
	},
	["title_0000000002"] = {
		Name = "Destroyer",
		Type = "Title",
		Buffs = {
			CriticalRate = { Percent = 0.5 },
			Melee = { Percent = 0.5 },
		},
	},
	["title_0000000003"] = {
		Name = "Cosmic Traveler",
		Type = "Title",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(2,0,36)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9,9,121)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0,212,255))
		}),
		Buffs = {
			CriticalRate = { Percent = 0.1 },
			Melee = { Percent = 0.5 },
			Sword = { Flat = 50 },
			CriticalDamage = { Percent = 1 },
		},
	},
}

function TitleData:GetTitleID(title)
	if not title then
		return nil
	end

	for id, data in pairs(self.Titles) do
		if data.Name == title then
			return id
		end
	end

	return nil
end

return TitleData
