local MovementConfig = {}

MovementConfig.DashConfig = {
	StudsPerSecond = 80,
	DashCooldown = 1.5,
}

MovementConfig.FlashstepConfig = {
	FlashstepDuration = 1,
	FlashstepEndlag = 0.05,
	
}

MovementConfig.WallRunConfig = {
	WalkRunSpeed = 24,
	StickForce = 20,
	MaxDuration = 5,
	
}

return MovementConfig
