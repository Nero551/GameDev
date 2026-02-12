local module = {}
module.OnMouse = false
module.HitReaction = "1"
module.BlockBreak = false
module.BlockDetoriation = 1
module.Damage = 75
module.Hits = 2
module.TimeBtwnHits = 0.2
module.AbilityCooldown = 15
module.HitBoxLookVector = 10
module.HitBoxSize = Vector3.new(25, 44.5, 50)
module.HitBoxPosition = Vector3.new(0, 15, 0)
module.HitBoxRotation = Vector3.new(0, 90, 0)
module.VFX = game.ReplicatedStorage.Assets.Effects.AbilityEffects.Katana.X_DimensionalSlashVFX
module.Sound = game.ReplicatedStorage.Assets.Sounds.Weapons.Katana.Abilties.X
module.Mana = 200
module.Animation = "Weapons.Katana.Abilities.X"
module.AbilityName = "Dimensional Slash"
module.AbilityMastery = 50
module.AbilityRange = 10

return module
