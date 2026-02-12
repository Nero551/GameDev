--ClientEffects

local replicatedStorage = game:GetService("ReplicatedStorage")
local  modules = replicatedStorage:WaitForChild("Modules")

local remotes = replicatedStorage:WaitForChild("Remotes")

local cachedEffects = {}

for  _, module in modules.ClientEffects:GetChildren() do
	if module:IsA("ModuleScript") then
		cachedEffects[module.Name] = require(module)
	end


end
remotes.ClientEffects.OnClientEvent:Connect(function(action :string , arguementData:any)
	local foundEffect = cachedEffects[action] 
	if foundEffect then
		foundEffect(arguementData)
		
		
	end
end)