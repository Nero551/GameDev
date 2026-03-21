local ModuleLoader = require(game:GetService("ReplicatedStorage").Modules.Core.ModuleLoader)
return function()
	local RunService = game:GetService("RunService")
	local ItemDataBase = ModuleLoader:Load("Shared", "ItemDataBase")
	local Player = game:GetService("Players").LocalPlayer
	local character = Player.Character or Player.CharacterAdded:Wait()

	local StateChecker = ModuleLoader:Load("Shared", "StateChecker")

	local _stepConnection = RunService.RenderStepped:Connect(function()
		---Trails---
		local weapon = character:FindFirstChildWhichIsA("Tool")
		if weapon and ItemDataBase:GetItemData(weapon.Name) then
			---SprintTrails---
			if StateChecker:CheckState(character, "Sprinting")  then
				for _, model in character:GetChildren() do 
					if model:IsA("Model") and model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") == weapon.Name then
						for _, trail in model:GetDescendants() do
							if trail:IsA("Trail") and trail.Name == "SprintTrail" then
								trail.Enabled = true
							end
						end
					elseif model:IsA("Model") and model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") ~= weapon.Name then
						for _, trail in model:GetDescendants() do
							if trail:IsA("Trail") and trail.Name == "SprintTrail" then
								trail.Enabled = false
							end
						end	
					end
				end	
			elseif not StateChecker:CheckState(character, "Sprinting") then
				for _, trail in character:GetDescendants() do
					if trail:IsA("Trail") and trail.Name == "SprintTrail" then
						trail.Enabled = false
					end
				end	
			end

			--AttackTrails---
			if StateChecker:CheckState(character, "Attacking")  then
				for _, model in character:GetChildren() do 
					if model:IsA("Model") and model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") == weapon.Name then
						for _, trail in model:GetDescendants() do
							if trail:IsA("Trail") and trail.Name == "AttackTrail" then
								trail.Enabled = true
							end
						end
					elseif model:IsA("Model") and model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") ~= weapon.Name then
						for _, trail in model:GetDescendants() do
							if trail:IsA("Trail") and trail.Name == "AttackTrail" then
								trail.Enabled = false
							end	
						end		
					end			
				end	
			elseif not StateChecker:CheckState(character, "Attacking") then
				for _, trail in character:GetDescendants() do
					if trail:IsA("Trail") and trail.Name == "AttackTrail" then
						trail.Enabled = false
					end
				end	
			end	
		else
			for _, trail in character:GetDescendants() do
				if trail:IsA("Trail") then
					if  trail.Name == "SprintTrail"  or  trail.Name == "AttackTrail" then
						trail.Enabled = false
					end
				end
			end	
		end	
	end)
end
