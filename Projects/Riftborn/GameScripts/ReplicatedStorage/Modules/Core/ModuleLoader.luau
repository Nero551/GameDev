local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ModuleLoader = {}

local cachedModules = {
	Server = {},
	Shared = {},
	Client = {},
}

for _, module in ServerScriptService:GetDescendants() do
	if module:IsA("ModuleScript") then
		cachedModules.Server[module.Name] = module
	end
end

for _, module in ReplicatedStorage.Modules:GetDescendants() do
	if module:IsA("ModuleScript") then
		if string.find(module:GetFullName(), "Client") then
			cachedModules.Client[module.Name] = module
		else
			cachedModules.Shared[module.Name] = module
		end
	end
end

print(cachedModules)

function ModuleLoader:Load(type, moduleName)
	if type == "Server" then
		if RunService:IsServer() then
			if cachedModules.Server[moduleName] then
				return require(cachedModules.Server[moduleName])
			end
		end
	end
	if type == "Client" then
		if RunService:IsClient() then
			if cachedModules.Client[moduleName] then
				return require(cachedModules.Client[moduleName])
			end
		end
	end
	if type == "Shared" then
		if cachedModules.Shared[moduleName] then
			return require(cachedModules.Shared[moduleName])
		end
	end

	return warn("Module Doesn't Exist")
end

return ModuleLoader
