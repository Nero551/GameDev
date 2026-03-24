local NetworkingService = require(game.ReplicatedStorage.Modules.Core.NetworkingService)
local  Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local StateService = require(game.ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local StatusAilmentsData = require(game.ReplicatedStorage.Modules.Data.StatusAilmentsData)
local StatService = require(game.ServerScriptService.Services.Profile.StatService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)

local AilmentService = {}

function AilmentService:Burn(attacker,targetHit,ailmentName, normalDamage)

	local playerTarget = Players:GetPlayerFromCharacter(targetHit)
	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	local ailmentData = StatusAilmentsData.Ailments[ailmentName]
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
	Connections:AddConnection(targetHit, "Character", "Burning", RunService.Heartbeat:Connect(function(dt)
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

			VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				HealthChange = -ailmentDamage
			})
			if playerAttacker then
				NetworkingService:FireToClient(playerAttacker, "ShowDamage", ailmentDamage, false,false,false, ailmentName)
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
	
	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	local ailmentData = StatusAilmentsData.Ailments[ailmentName]
	local targetHealth =  VitalsService:GetVital(targetHit ,"Health")
	local ailmentDamage = normalDamage * ailmentData.DamagePercent

	StateService:AddState(targetHit, ailmentData.State, ailmentData.BaseDuration, {
		["AilmentName"] = ailmentData.State,
		["LastProc"] = 0,
	})
	
	Connections:AddConnection(targetHit, "Character", "Bleeding", RunService.Heartbeat:Connect(function(dt)
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

			VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
				HealthChange = -ailmentDamage
			})

			VitalsService:ModifyVital(attacker, "Health", "ModifyHealth", {
				["HealthChange"] = targetHealth.MaxHealth / 200
			})

			if playerAttacker then
				NetworkingService:FireToClient(playerAttacker, "ShowDamage", ailmentDamage, false,false,false, ailmentName)
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
	local playerAttacker = Players:GetPlayerFromCharacter(attacker)
	local ailmentData = StatusAilmentsData.Ailments[ailmentName]
	
	local ailmentDamage = normalDamage * ailmentData.DamagePercent

	StateService:AddState(targetHit, ailmentData.State, ailmentData.BaseDuration)

	VitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		HealthChange = -ailmentDamage
	})
	
	Connections:AddConnection(targetHit, "Character", "Freezing",RunService.Heartbeat:Connect(function(dt)
		if not StateChecker:CheckState(targetHit, ailmentData.State) then
			Connections:RemoveConnection(targetHit , "Character", "Freezing")
			return
		end
			StateService:AddState(targetHit, ailmentData.State,
			 StateService.Status[targetHit][ailmentData.State].Duration - dt)
	end))
	
	if playerAttacker then
		NetworkingService:FireToClient(playerAttacker, "ShowDamage", ailmentDamage, false,false,false, ailmentName)
	end
end


return AilmentService
