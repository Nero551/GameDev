local repstor = game:GetService("ReplicatedStorage")
local  players = game:GetService("Players")
local runService = game:GetService("RunService")

local statusAilmentsData = require(repstor.Modules.Data.StatusAilmentsData)
local StatService = require(script.Parent.StatService)
local CharacterVitalsService = require(script.Parent.CharacterVitalsService)


local SideEffectService = {}


function SideEffectService:BurnSideEffects(char:Model?, argumentData)
	local elapsed = 0
	local conn = 0
	local player = players:GetPlayerFromCharacter(char)
	
	if player then
		local characterAilments = CharacterVitalsService:GetVital(char, "StatusAilments")
		local burnEffectData = statusAilmentsData.Ailments.Burn
		
		
		StatService:ApplyBuffs(player, {["Defense"] = {Percent = -0.5}})
		
		conn = runService.Heartbeat:Connect(function(dt)
			elapsed = elapsed + dt
			if elapsed >= burnEffectData.BaseDuration then
				StatService:ApplyBuffs(player, { ["Defense"] = {Percent = 0.5}})
				elapsed = 0
				conn:Disconnect()
				conn = nil

			end
		end)
	end
end

function SideEffectService:BleedSideEffects(char:Model?, argumentData)
	local attacker:Model? = argumentData.Attacker
	local bleedEffectData = statusAilmentsData.Ailments.Bleed
	local elapsed
	local conn
	local charHealth =  CharacterVitalsService:GetVital(char ,"Health")
	
	
	CharacterVitalsService:ModifyVital(attacker, "Health", "ModifyHealth", {
		["HealthChange"] = charHealth.MaxHealth / 25		
	})

	conn = runService.Heartbeat:Connect(function(dt)
		elapsed = (elapsed or 0) + dt
		
		if elapsed >= bleedEffectData.ProcEvery then
			CharacterVitalsService:ModifyVital(attacker, "Health", "ModifyHealth", {
				["HealthChange"] = charHealth.MaxHealth / 200
			})
			elapsed = 0
		end
		
		if elapsed >= bleedEffectData.BaseDuration then
			conn:Disconnect()
			conn = nil

		end
	end)
end


return SideEffectService
