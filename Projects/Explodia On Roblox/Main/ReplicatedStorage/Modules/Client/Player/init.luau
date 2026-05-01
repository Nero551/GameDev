local StarterGui = game:GetService("StarterGui")
local Player = {}
local cachedModules = {}

for _, module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		cachedModules[module.Name] = require(module)
	end
end

function Player:Init()
	local Player = game:GetService("Players").LocalPlayer
	local playerGui = Player:WaitForChild("PlayerGui")
	repeat
		task.wait()
	until #playerGui:GetDescendants() >= #StarterGui:GetDescendants()


	for moduleName, module in pairs(cachedModules) do
		local _,err = pcall(function()
			module()
		end)
		if err then
			warn("Module:",moduleName,"Failed To Load")
		end
	end
end

return Player
