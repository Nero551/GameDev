local replicatedStorage = game:GetService("ReplicatedStorage")
local  players = game:GetService("Players")
local runService = game:GetService("RunService")

local StateService = require(game.ServerScriptService.Services.StateService)
local StateChecker = require(replicatedStorage.Modules.StateChecker)
local statusAilmentsData = require(replicatedStorage.Modules.Data.StatusAilmentsData)
local StatService = require(script.Parent.StatService)
local CharacterVitalsService = require(script.Parent.CharacterVitalsService)

local Connections = require(replicatedStorage.Modules.Connections)

local AilmentService = {}

function AilmentService:Burn(attacker,targetHit,ailmentName, normalDamage)

	local playerTarget = players:GetPlayerFromCharacter(targetHit)
	local playerAttacker = players:GetPlayerFromCharacter(attacker)
	local ailmentData = statusAilmentsData.Ailments[ailmentName]
	local ailmentDamage = normalDamage * ailmentData.DamagePercent
	
	if not StateChecker:CheckState(targetHit, ailmentData.State) then
		if playerTarget then
			StatService:ApplyBuffs(playerTarget, {["Defense"] = {Percent = -0.5}})
		end
	end	

	StateService:AddState(targetHit, ailmentData.State, ailmentData.BaseDuration, {
		["AilmentName"] = ailmentData.State,
		["LastProc"] = 	 (StateService.Status[targetHit][ailmentData.State] and
						 StateService.Status[targetHit][ailmentData.State].LastProc) or 0
	})
	Connections:AddConnection(targetHit, "Character", "Burning", runService.Heartbeat:Connect(function(dt)
		if not StateChecker:CheckState(targetHit, ailmentData.State) then

			if playerTarget then
				StatService:ApplyBuffs(playerTarget, {["Defense"] = {Percent = 0.5}})
			end
			Connections:RemoveConnection(targetHit , "Character", "Burning")
			return
		end

		StateService:AddState(
			targetHit,
			ailmentData.State,
			(StateService.Status[targetHit][ailmentData.State].Duration - dt),
			{
				["AilmentName"] = ailmentData.State,
				["LastProc"] = (StateService.Status[targetHit][ailmentData.State].LastProc or 0 ) + dt,
			}
		)

		if StateService.Status[targetHit][ailmentData.State] and
		 StateService.Status[targetHit][ailmentData.State].LastProc >= ailmentData.ProcEvery then

			CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				HealthChange = -ailmentDamage
			})
			if playerAttacker then
				replicatedStorage.Remotes.ShowDamage:FireClient(playerAttacker, ailmentDamage, false,false,false, ailmentName, ailmentData)
			end
			StateService:AddState(targetHit,
			 ailmentData.State,
			 (StateService.Status[targetHit][ailmentData.State].Duration - dt),
		 	 {
				["AilmentName"] = ailmentData.State,
				["LastProc"] = 0,
			})
		end	
	end))
end

function AilmentService:Bleed(attacker, targetHit, ailmentName, normalDamage)
	
	local playerAttacker = players:GetPlayerFromCharacter(attacker)
	local ailmentData = statusAilmentsData.Ailments[ailmentName]
	local targetHealth =  CharacterVitalsService:GetVital(targetHit ,"Health")
	local ailmentDamage = normalDamage * ailmentData.DamagePercent

	StateService:AddState(targetHit, ailmentData.State, ailmentData.BaseDuration, {
		["AilmentName"] = ailmentData.State,
		["LastProc"] = 0,
	})
	
	Connections:AddConnection(targetHit, "Character", "Bleeding", runService.Heartbeat:Connect(function(dt)
		if not StateChecker:CheckState(targetHit, ailmentData.State) then
			Connections:RemoveConnection(targetHit , "Character", "Bleeding")
			return
		end

		StateService:AddState(targetHit, ailmentData.State,
			StateService.Status[targetHit][ailmentData.State].Duration - dt,
			{
				["AilmentName"] = ailmentData.State,
				["LastProc"] = (StateService.Status[targetHit][ailmentData.State].LastProc or 0 ) + dt,
			})

		if StateService.Status[targetHit][ailmentData.State].LastProc >= ailmentData.ProcEvery then

			CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				HealthChange = -ailmentDamage
			})

			CharacterVitalsService:ModifyVital(attacker, "Health", "ModifyHealth", {
				["HealthChange"] = targetHealth.MaxHealth / 200
			})

			if playerAttacker then
				replicatedStorage.Remotes.ShowDamage:FireClient(playerAttacker, ailmentDamage, false,false,false, ailmentName, ailmentData)
			end
			StateService:AddState(targetHit, ailmentData.State,
				StateService.Status[targetHit][ailmentData.State].Duration - dt,
				{
					["AilmentName"] = ailmentData.State,
					["LastProc"] = 0,
				})
		end	
	end))
end

function AilmentService:Freeze(attacker, targetHit, ailmentName, normalDamage)
	local playerAttacker = players:GetPlayerFromCharacter(attacker)
	local ailmentData = statusAilmentsData.Ailments[ailmentName]
	
	local ailmentDamage = normalDamage * ailmentData.DamagePercent

	StateService:AddState(targetHit, ailmentData.State, ailmentData.BaseDuration)

	CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		HealthChange = -ailmentDamage
	})
	
	Connections:AddConnection(targetHit, "Character", "Freezing",runService.Heartbeat:Connect(function(dt)
		if not StateChecker:CheckState(targetHit, ailmentData.State) then
			Connections:RemoveConnection(targetHit , "Character", "Freezing")
			return
		end
			StateService:AddState(targetHit, ailmentData.State,
			 StateService.Status[targetHit][ailmentData.State].Duration - dt)
	end))
	
	if playerAttacker then
		replicatedStorage.Remotes.ShowDamage:FireClient(playerAttacker, ailmentDamage, false,false,false, ailmentName, ailmentData)
	end
end


return AilmentService
