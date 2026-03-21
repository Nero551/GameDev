local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
local StarterGui = game:GetService("StarterGui")

local Character = {}

local cachedModules = {}

for _,module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		cachedModules[module.Name] = ModuleLoader:Load("Client", module.Name)
	end
end


function Character:Init()
	local Player = game:GetService("Players").LocalPlayer
	local playerGui = Player:WaitForChild("PlayerGui")

	repeat
		task.wait()
	until #playerGui:GetDescendants() >= #StarterGui:GetDescendants()
	
	for moduleName,module in  pairs(cachedModules) do
		module()
	end
end


return Character
