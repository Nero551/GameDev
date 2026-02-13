local module = {}
module.OnMouse = false
module.HitReaction = "1"
module.BlockBreak = true
module.BlockDetoriation = nil
module.Damage = 50
module.Hits = 1
module.TimeBtwnHits = 0.2
module.AbilityCooldown = 20
module.HitBoxLookVector = 8
module.HitBoxSize = Vector3.new(5, 5.5, 70)
module.HitBoxPosition = Vector3.new(0, 0, 0)
module.HitBoxRotation = Vector3.new(0, 90, 0)
module.Mana = 1000
module.VFX = game.ReplicatedStorage.Assets.Weapons["Cid Sword"].Effects.AbilityEffects.Z_DimensionalCutVFX
module.Sound = game.ReplicatedStorage.Assets.Weapons["Cid Sword"].Sounds.Abilties.Z
module.Animation = "Weapons.Cid Sword.Animations.Abilities.V"
module.AbilityName = "I..AM...Atomic"
module.AbilityMastery = 500
module.AbilityRange = 10
--AbilityName
return module
