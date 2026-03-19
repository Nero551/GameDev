local StarterGui = game:GetService("StarterGui")
local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.NetworkingService)

local Character = {}

local cachedModules = {}

for _,module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		cachedModules[module.Name] = require(module)
	end
end


function Character:Init()
	print("nice")
	local Player = game:GetService("Players").LocalPlayer
	local playerGui = Player:WaitForChild("PlayerGui")

	repeat
		task.wait()
	until #playerGui:GetDescendants() >= #StarterGui:GetDescendants()
	
	for moduleName,module in  pairs(cachedModules) do
		module()
	end
	NetworkingService:FireToServer("ClientReady")
end


return Character
