local module = {}
module.OnMouse = false
module.HitReaction = "1"
module.BlockBreak = false
module.BlockDetoriation = 1
module.Damage = 50
module.Hits = 3
module.TimeBtwnHits = 0.2
module.AbilityCooldown = 20
module.HitBoxLookVector = 0
module.HitBoxSize = Vector3.new(15, 3.75, 15)
module.HitBoxPosition = Vector3.new(0, 0, 0)
module.HitBoxRotation = Vector3.new(0, 0, 0)
module.VFX = game.ReplicatedStorage.Assets.Weapons.Katana.Effects.AbilityEffects.C_DimensionalSpinVFX
module.Sound = game.ReplicatedStorage.Assets.Weapons.Katana.Sounds.Abilties.C
module.Mana = 300
module.Animation = "Weapons.Katana.Animations.Abilities.C"
module.AbilityName = "Dimensional Spin"
module.AbilityMastery = 100
module.AbilityRange = 10

return module
