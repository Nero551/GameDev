local replicatedStorage = game:GetService("ReplicatedStorage")
local  players = game:GetService("Players")
local runService = game:GetService("RunService")

local stateService = require(replicatedStorage.Modules.StateService)
local statusAilmentsData = require(replicatedStorage.Modules.Data.StatusAilmentsData)
local StatService = require(script.Parent.StatService)
local CharacterVitalsService = require(script.Parent.CharacterVitalsService)

local Connections = require(replicatedStorage.Modules.Connections)

local AilmentService = {}

function AilmentService:Burn(attacker,targetHit,ailmentName, normalDamage)
	
	local playerTarget = players:GetPlayerFromCharacter(targetHit)
	local playerAttacker = players:GetPlayerFromCharacter(attacker)
	local ailmentData = statusAilmentsData.Ailments[ailmentName]
	local characterAilments = CharacterVitalsService:GetVital(targetHit, "StatusAilments")	
	
	if stateService.checkState(targetHit, ailmentData.State) then

		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentDuration"] = ailmentData.BaseDuration,
			["AilmentTime"] = characterAilments[ailmentData.State].LastProc or 0
		})

		stateService.removeState(targetHit, ailmentData.State)
	end
	stateService.addState(targetHit, ailmentData.State, ailmentData.BaseDuration)
	local ailmentDamage = normalDamage * ailmentData.DamagePercent
	
	if not characterAilments[ailmentData.State] then
		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentTime"] = 0	,
		})
		
		if playerTarget then
			StatService:ApplyBuffs(playerTarget, {["Defense"] = {Percent = -0.5}})
		end
		
		Connections:AddConnection(targetHit, "Character", "Burning", runService.Heartbeat:Connect(function(dt)
			if not stateService.checkState(targetHit, ailmentData.State) then
				CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "RemoveAilment", {
					["AilmentName"] = ailmentData.State,
				})

				if playerTarget then
					StatService:ApplyBuffs(playerTarget, {["Defense"] = {Percent = 0.5}})
				end
				Connections:RemoveConnection(targetHit , "Character", "Burning")
				return
			end

			CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
				["AilmentName"] = ailmentData.State,
				["AilmentTime"] = (characterAilments[ailmentData.State].LastProc or 0 ) + dt,
				["AilmentDuration"] = (characterAilments[ailmentData.State].Duration or  ailmentData.BaseDuration) - dt,
			})
			if characterAilments[ailmentData.State].LastProc >= ailmentData.ProcEvery then

				CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
					HealthChange = -ailmentDamage
				})
				if playerAttacker then
					replicatedStorage.Remotes.ShowDamage:FireClient(playerAttacker, ailmentDamage, false,false,false, ailmentName, ailmentData)
				end
				CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
					["AilmentName"] = ailmentData.State,
					["AilmentTime"] = 0	,
					["AilmentDuration"] = (characterAilments[ailmentData.State].Duration or  ailmentData.BaseDuration)  - dt,

				})
			end	
		end))
	end
end

function AilmentService:Bleed(attacker, targetHit, ailmentName, normalDamage)
	
	local playerTarget = players:GetPlayerFromCharacter(targetHit)
	local playerAttacker = players:GetPlayerFromCharacter(attacker)
	
	local ailmentData = statusAilmentsData.Ailments[ailmentName]
	local characterAilments = CharacterVitalsService:GetVital(targetHit, "StatusAilments")	
	
	local targetHealth =  CharacterVitalsService:GetVital(targetHit ,"Health")

	if stateService.checkState(targetHit, ailmentData.State) then

		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentDuration"] = ailmentData.BaseDuration,
			["AilmentTime"] = characterAilments[ailmentData.State].LastProc or 0
		})

		stateService.removeState(targetHit, ailmentData.State)
	end
	stateService.addState(targetHit, ailmentData.State, ailmentData.BaseDuration)
	local ailmentDamage = normalDamage * ailmentData.DamagePercent

	if not characterAilments[ailmentData.State] then
		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentTime"] = 0	,
		})
		
		Connections:AddConnection(targetHit, "Character", "Bleeding", runService.Heartbeat:Connect(function(dt)
			if not stateService.checkState(targetHit, ailmentData.State) then
				CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "RemoveAilment", {
					["AilmentName"] = ailmentData.State,
				})
				Connections:RemoveConnection(targetHit , "Character", "Bleeding")
				return
			end

			CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
				["AilmentName"] = ailmentData.State,
				["AilmentTime"] = (characterAilments[ailmentData.State].LastProc or 0 ) + dt,
				["AilmentDuration"] = (characterAilments[ailmentData.State].Duration or  ailmentData.BaseDuration) - dt,
			})
			if characterAilments[ailmentData.State].LastProc >= ailmentData.ProcEvery then

				CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
					HealthChange = -ailmentDamage
				})

				CharacterVitalsService:ModifyVital(attacker, "Health", "ModifyHealth", {
					["HealthChange"] = targetHealth.MaxHealth / 200
				})

				if playerAttacker then
					replicatedStorage.Remotes.ShowDamage:FireClient(playerAttacker, ailmentDamage, false,false,false, ailmentName, ailmentData)
				end
				CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
					["AilmentName"] = ailmentData.State,
					["AilmentTime"] = 0	,
					["AilmentDuration"] = (characterAilments[ailmentData.State].Duration or  ailmentData.BaseDuration)  - dt,

				})
			end	
		end))
	end
end

function AilmentService:Freeze(attacker, targetHit, ailmentName, normalDamage)
	local playerTarget = players:GetPlayerFromCharacter(targetHit)
	local playerAttacker = players:GetPlayerFromCharacter(attacker)
	local ailmentData = statusAilmentsData.Ailments[ailmentName]
	local characterAilments = CharacterVitalsService:GetVital(targetHit, "StatusAilments")	
	

	if stateService.checkState(targetHit, ailmentData.State) then

		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentDuration"] = ailmentData.BaseDuration,
		})

		stateService.removeState(targetHit, ailmentData.State)
	end
	stateService.addState(targetHit, ailmentData.State, ailmentData.BaseDuration)
	local ailmentDamage = normalDamage * ailmentData.DamagePercent

	if not characterAilments[ailmentData.State] then
		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentDuration"] = ailmentData.BaseDuration
		})
	end	
	
	CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
		HealthChange = -ailmentDamage
	})
	
	Connections:AddConnection(targetHit, "Character", "Freezing",runService.Heartbeat:Connect(function(dt)
		if not stateService.checkState(targetHit, ailmentData.State) then
			CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "RemoveAilment", {
				["AilmentName"] = ailmentData.State,
			})
			Connections:RemoveConnection(targetHit , "Character", "Freezing")
			return
		end
		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentDuration"] = (characterAilments[ailmentData.State].Duration or  ailmentData.BaseDuration) - dt,
		})
	end))
	
	if playerAttacker then
		replicatedStorage.Remotes.ShowDamage:FireClient(playerAttacker, ailmentDamage, false,false,false, ailmentName, ailmentData)
	end
end

function AilmentService:Poison(attacker,targetHit,ailmentName,normalDamage)
	
	local playerTarget = players:GetPlayerFromCharacter(targetHit)
	local playerAttacker = players:GetPlayerFromCharacter(attacker)	
	
	local ailmentData = statusAilmentsData.Ailments[ailmentName]
	local characterAilments = CharacterVitalsService:GetVital(targetHit, "StatusAilments")	

	if stateService.checkState(targetHit, ailmentData.State) then

		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentDuration"] = ailmentData.BaseDuration,
			["AilmentTime"] = characterAilments[ailmentData.State].LastProc or 0
		})

		stateService.removeState(targetHit, ailmentData.State)
	end
	stateService.addState(targetHit, ailmentData.State, ailmentData.BaseDuration)
	local ailmentDamage = normalDamage * ailmentData.DamagePercent

	if not characterAilments[ailmentData.State] then
		CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
			["AilmentName"] = ailmentData.State,
			["AilmentTime"] = 0	,
		})
		
		Connections:AddConnection(targetHit, "Character", "Poisoned", runService.Heartbeat:Connect(function(dt)
			if not stateService.checkState(targetHit, ailmentData.State) then
				CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "RemoveAilment", {
					["AilmentName"] = ailmentData.State,
				})
				
				Connections:RemoveConnection(targetHit , "Character", "Poisoned")
				return
			end

			CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
				["AilmentName"] = ailmentData.State,
				["AilmentTime"] = (characterAilments[ailmentData.State].LastProc or 0 ) + dt,
				["AilmentDuration"] = (characterAilments[ailmentData.State].Duration or  ailmentData.BaseDuration) - dt,
			})
			if characterAilments[ailmentData.State].LastProc >= ailmentData.ProcEvery then

				CharacterVitalsService:ModifyVital(targetHit, "Health", "ModifyHealth", {
					HealthChange = -ailmentDamage
				})
				if playerAttacker then
					replicatedStorage.Remotes.ShowDamage:FireClient(playerAttacker, ailmentDamage, false,false,false, ailmentName, ailmentData)
				end
				CharacterVitalsService:ModifyVital(targetHit, "StatusAilments", "AddAilment", {
					["AilmentName"] = ailmentData.State,
					["AilmentTime"] = 0	,
					["AilmentDuration"] = (characterAilments[ailmentData.State].Duration or  ailmentData.BaseDuration)  - dt,

				})
			end	
		end))
	end
end

return AilmentService
