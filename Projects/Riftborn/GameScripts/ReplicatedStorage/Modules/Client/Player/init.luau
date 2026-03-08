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
end


return Player
