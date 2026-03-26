local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local DamageService = require(script.Parent.DamageService)

local StateService = require(game.ServerScriptService.Services.Core.StateService)
local StateChecker = require(game.ReplicatedStorage.Modules.Helpers.StateChecker)
local StatusEffectsData = require(game.ReplicatedStorage.Modules.Data.StatusEffectsData)
local StatService = require(game.ServerScriptService.Services.Profile.StatService)
local VitalsService = require(game.ServerScriptService.Services.Combat.VitalsService)

local Connections = require(game.ReplicatedStorage.Modules.Core.Connections)

local StatusEffectsService = {}

function StatusEffectsService:Burn(attacker, targetHit, statusEffectName, normalDamage, targetDefense)
	local playerTarget = Players:GetPlayerFromCharacter(targetHit)
	local statusEffectData = StatusEffectsData.StatusEffects[statusEffectName]

	if not StateChecker:CheckState(targetHit, statusEffectData.State) then
		if playerTarget then
			StatService:ApplyBuffs(playerTarget, { ["Defense"] = { Percent = -0.5 } })
		end
	end

	StateService:AddState(targetHit, statusEffectData.State, statusEffectData.BaseDuration, {
		["StatusEffectName"] = statusEffectData.State,
		["LastProc"] = (
			StateService.State[targetHit][statusEffectData.State]
			and StateService.State[targetHit][statusEffectData.State].LastProc
		) or 0,
	})
	Connections:AddConnection(
		targetHit,
		"Character",
		"Burning",
		RunService.Heartbeat:Connect(function(dt)
			if not StateChecker:CheckState(targetHit, statusEffectData.State) then
				if playerTarget then
					StatService:ApplyBuffs(playerTarget, { ["Defense"] = { Percent = 0.5 } })
				end
				Connections:RemoveConnection(targetHit, "Character", "Burning")
				return
			end

			StateService:AddState(
				targetHit,
				statusEffectData.State,
				(StateService.State[targetHit][statusEffectData.State].Duration - dt),
				{
					["StatusEffectName"] = statusEffectData.State,
					["LastProc"] = (StateService.State[targetHit][statusEffectData.State].LastProc or 0) + dt,
				}
			)

			if
				StateService.State[targetHit][statusEffectData.State]
				and StateService.State[targetHit][statusEffectData.State].LastProc >= statusEffectData.ProcEvery
			then
				DamageService[statusEffectName .. "Damage"](DamageService, attacker, targetHit, normalDamage, targetDefense)
				StateService:AddState(
					targetHit,
					statusEffectData.State,
					(StateService.State[targetHit][statusEffectData.State].Duration - dt),
					{
						["StatusEffectName"] = statusEffectData.State,
						["LastProc"] = 0,
					}
				)
			end
		end)
	)
end

function StatusEffectsService:Bleed(attacker, targetHit, statusEffectName, normalDamage,targetDefense)
	local statusEffectData = StatusEffectsData.StatusEffects[statusEffectName]
	local targetHealth = VitalsService:GetVital(targetHit, "Health")

	StateService:AddState(targetHit, statusEffectData.State, statusEffectData.BaseDuration, {
		["StatusEffectName"] = statusEffectData.State,
		["LastProc"] = 0,
	})

	Connections:AddConnection(
		targetHit,
		"Character",
		"Bleeding",
		RunService.Heartbeat:Connect(function(dt)
			if not StateChecker:CheckState(targetHit, statusEffectData.State) then
				Connections:RemoveConnection(targetHit, "Character", "Bleeding")
				return
			end

			StateService:AddState(
				targetHit,
				statusEffectData.State,
				StateService.State[targetHit][statusEffectData.State].Duration - dt,
				{
					["StatusEffectName"] = statusEffectData.State,
					["LastProc"] = (StateService.State[targetHit][statusEffectData.State].LastProc or 0) + dt,
				}
			)

			if StateService.State[targetHit][statusEffectData.State].LastProc >= statusEffectData.ProcEvery then
				DamageService[statusEffectName .. "Damage"](DamageService, attacker, targetHit, normalDamage,targetDefense)
				VitalsService:ModifyVital(attacker, "Health", "ModifyHealth", {
					["HealthChange"] = targetHealth.MaxHealth / 200,
				})
				StateService:AddState(
					targetHit,
					statusEffectData.State,
					StateService.State[targetHit][statusEffectData.State].Duration - dt,
					{
						["StatusEffectName"] = statusEffectData.State,
						["LastProc"] = 0,
					}
				)
			end
		end)
	)
end

function StatusEffectsService:Freeze(attacker, targetHit, statusEffectName, normalDamage,targetDefense)
	local statusEffectData = StatusEffectsData.StatusEffects[statusEffectName]

	StateService:AddState(targetHit, statusEffectData.State, statusEffectData.BaseDuration)
	DamageService[statusEffectName .. "Damage"](DamageService, attacker, targetHit, normalDamage,targetDefense)

	Connections:AddConnection(
		targetHit,
		"Character",
		"Freezing",
		RunService.Heartbeat:Connect(function(dt)
			if not StateChecker:CheckState(targetHit, statusEffectData.State) then
				Connections:RemoveConnection(targetHit, "Character", "Freezing")
				return
			end
			StateService:AddState(
				targetHit,
				statusEffectData.State,
				StateService.State[targetHit][statusEffectData.State].Duration - dt
			)
		end)
	)
end

return StatusEffectsService
