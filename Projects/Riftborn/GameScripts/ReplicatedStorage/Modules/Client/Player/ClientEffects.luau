local NetworkingService = require(game:GetService("ReplicatedStorage").Modules.Core.NetworkingService)
return function()
	--ClientEffects

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local  modules = ReplicatedStorage:WaitForChild("Modules")

	local remotes = ReplicatedStorage:WaitForChild("Remotes")

	local cachedEffects = {}

	for  _, module in modules.Client.Effects:GetChildren() do
		if module:IsA("ModuleScript") then
			cachedEffects[module.Name] = require(module)
		end


	end
	NetworkingService:OnClientEvent("ClientEffects", function(action :string , arguementData:any)
		local foundEffect = cachedEffects[action] 
		if foundEffect then
			foundEffect(arguementData)

		end
	end)
end