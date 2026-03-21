local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

---@class ModuleLoader
---@field Server table<string, any>
---@field Client table<string, any>
---@field Shared table<string, any>
local ModuleLoader = {}

local moduleInstances = {
	Server = {},
	Shared = {},
	Client = {},
}

local cachedModules = {
	Server = {},
	Shared = {},
	Client = {},
}

local function RegisterModule(bucketName, module)
	if module:IsA("ModuleScript") then
		moduleInstances[bucketName][module.Name] = module
	end
end

for _, module in ServerScriptService:GetDescendants() do
	RegisterModule("Server", module)
end

for _, module in ReplicatedStorage.Modules:GetDescendants() do
	if string.find(module:GetFullName(), ".Client.") then
		RegisterModule("Client", module)
	else
		RegisterModule("Shared", module)
	end
end

---@generic T
---@param type "Server"|"Client"|"Shared"
---@param moduleName string
---@return T
function ModuleLoader:Load(moduleType, moduleName)
	if moduleType == "Server" and not RunService:IsServer() then
		return warn("Attempted to load a server module from the client:", moduleName)
	end

	if moduleType == "Client" and not RunService:IsClient() then
		return warn("Attempted to load a client module from the server:", moduleName)
	end

	local cached = cachedModules[moduleType]
	if not cached then
		return warn("Invalid module type:", moduleType)
	end

	if cached[moduleName] then
		return cached[moduleName]
	end

	local module = moduleInstances[moduleType][moduleName]
	if not module then
		return warn("Module doesn't exist:", moduleType, moduleName)
	end

	cached[moduleName] = require(module)
	return cached[moduleName]
end

return ModuleLoader
