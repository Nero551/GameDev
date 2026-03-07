local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)

local Player = {}

local cachedModules = {}

for _,module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		cachedModules[module.Name] = require(module)
	end
end


function Player:Init()
	for moduleName,module in  pairs(cachedModules) do
		module()
	end
	NetworkingService:FireToServer("ClientReady")
end


return Player
