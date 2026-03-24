local function GetTool(toolName)
	for _,item:Tool in game.ServerStorage.Tools:GetDescendants() do
		if item:IsA("Tool") then
			if item.Name == toolName then
				return item
			end
		end
	end
	return
end

local MobData = {}
MobData.Mobs = {
	["Zombie"] = {
		Type = "Enemy",
		Tool = GetTool("Fist"),
		Level = 1200,
		Wander = true,
		WanderRadius = 50,
		DetectionRange = 100,
		AttackRange = 6,
		WalkSpeed = 10,
		RunSpeed = 32,
		Damage = 1,
		Health = 150,
		Drops = {
			["Yen"] = 1000,
			["Fracta"] = 20,
			["EXP"] = 2000,
			ItemDrops = {
				["Blue Crystal"] = {Amount =  1},
				["Flaming Tails"] = {Amount =  1},
				["Cid Sword"] = {Amount =  1},
				["Vision Head"] = {Amount =  1},
			}
		}
	}
	,	
}


return MobData
