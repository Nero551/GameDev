local module = {}
module.OnMouse = false
module.HitReaction = "1"
module.BlockBreak = true
module.BlockDetoriation = nil
module.Damage = 10
module.Hits = 1
module.TimeBtwnHits = 0.2
module.AbilityCooldown = 10
module.HitBoxLookVector = 8
module.HitBoxSize = Vector3.new(5, 5.5, 70)
module.HitBoxPosition = Vector3.new(0, 0, 0)
module.HitBoxRotation = Vector3.new(0, 90, 0)
module.VFX = game.ReplicatedStorage.Assets.Effects.AbilityEffects.Katana.Z_DimensionalCutVFX
module.Sound = game.ReplicatedStorage.Assets.Sounds.Weapons.Katana.Abilties.Z
module.Mana = 100
module.Animation = "Weapons.Katana.Abilities.Z"
module.AbilityName = "Dimensional Cut"
module.AbilityMastery = 0
module.AbilityRange = 10

--AbilityName
return module
