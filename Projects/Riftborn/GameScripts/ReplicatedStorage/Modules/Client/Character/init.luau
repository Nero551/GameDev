local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)

local Character = {}

local cachedModules = {}

for _,module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		cachedModules[module.Name] = require(module)
	end
end


function Character:Init()
	
	local Player = game:GetService("Players").LocalPlayer
	local playerGUI = Player:WaitForChild("PlayerGui")
	playerGUI:WaitForChild("StyleGuide"):WaitForChild("Big Text"):WaitForChild("UIGradient")
	
	for moduleName,module in  pairs(cachedModules) do
		module()
	end
	NetworkingService:FireToServer("ClientReady")
end


return Character
