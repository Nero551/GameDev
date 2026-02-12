local repstor = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local remotes = repstor.Remotes
local TitleService = require(script.Parent.Parent.ServerModules.TitleService)


remotes.EquipTitle.OnServerEvent:Connect(function(player, titleID)
	TitleService:EquipTitle(player, titleID)
end)


remotes.UnEquipTitle.OnServerEvent:Connect(function(player)
	TitleService:UnEquipTitle(player)
end)