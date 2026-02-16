---ManaSystem---
local  players = game:GetService("Players")
local runService = game:GetService("RunService")
local repstor = game:GetService("ReplicatedStorage")
local remotes =   repstor.Remotes

local RegenService = require(script.Parent.Parent.Services.RegenService)

RegenService:ManaRegen()

RegenService:HealthRegen()

RegenService:FlashStepRegen()

RegenService:BlockCounterRegen()