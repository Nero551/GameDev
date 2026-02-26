local remotes = game:GetService("ReplicatedStorage").Remotes


local Character = {}

local cachedModules = {}

for _,module in ipairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		cachedModules[module.Name] = require(module)
	end
end


function Character:Init()
	
	local player = game:GetService("Players").LocalPlayer
	local playerGUI = player:WaitForChild("PlayerGui")
	local DeepGUI = playerGUI:WaitForChild("StyleGuide"):WaitForChild("Big Text"):WaitForChild("UIGradient")
	
	for moduleName,module in  pairs(cachedModules) do
		module()
	end
	remotes.ClientReady:FireServer()
end


return Character
