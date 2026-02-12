local runService = game:GetService("RunService")
local itemDataBase = require(game.ReplicatedStorage.Modules.Data.ItemDataBase)
local character = script.Parent.Parent
local stateService = require(game.ReplicatedStorage.Modules.StateService)

local stepConnection = runService.RenderStepped:Connect(function()
	---Trails---
	local weapon = character:FindFirstChildWhichIsA("Tool")
	if weapon and itemDataBase:GetItemData(weapon.Name) then
		---SprintTrails---
		if stateService.checkState(character, "Sprinting")  then
			for _, model:Model? in character:GetChildren() do 
				if model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") == weapon.Name then
					for _, trail:Trail? in model:GetDescendants() do
						if trail:IsA("Trail") and trail.Name == "SprintTrail" then
							trail.Enabled = true
						end
					end
				elseif model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") ~= weapon.Name then
					for _, trail:Trail? in model:GetDescendants() do
						if trail:IsA("Trail") and trail.Name == "SprintTrail" then
							trail.Enabled = false
						end
					end	
				end
			end	
		elseif not stateService.checkState(character, "Sprinting") then
			for _, trail:Trail? in character:GetDescendants() do
				if trail:IsA("Trail") and trail.Name == "SprintTrail" then
					trail.Enabled = false
				end
			end	
		end

		--AttackTrails---
		if stateService.checkState(character, "Attacking")  then
			for _, model:Model? in character:GetChildren() do 
				if model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") == weapon.Name then
					for _, trail:Trail? in model:GetDescendants() do
						if trail:IsA("Trail") and trail.Name == "AttackTrail" then
							trail.Enabled = true
						end
					end
				elseif model:GetAttribute("WeaponModel") == true and model:GetAttribute("WeaponName") ~= weapon.Name then
					for _, trail:Trail? in model:GetDescendants() do
						if trail:IsA("Trail") and trail.Name == "AttackTrail" then
							trail.Enabled = false
						end	
					end		
				end			
			end	
		elseif not stateService.checkState(character, "Attacking") then
			for _, trail:Trail? in character:GetDescendants() do
				if trail:IsA("Trail") and trail.Name == "AttackTrail" then
					trail.Enabled = false
				end
			end	
		end	
	else
		for _, trail:Trail? in character:GetDescendants() do
			if trail:IsA("Trail") then
				if  trail.Name == "SprintTrail"  or  trail.Name == "AttackTrail" then
					trail.Enabled = false
				end
			end
		end	
	end	
end)