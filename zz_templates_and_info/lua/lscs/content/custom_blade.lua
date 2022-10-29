local blade = {}
blade.PrintName = "MyBlade" -- nice name in the menu
blade.Author = "Me"
blade.id = "mybladeid" -- internal ID. Always lower case.
--blade.Spawnable = false  -- uncomment to unlist in q-menu
blade.color_blur = Color(0,65,255)
blade.color_core = Color(255,255,255)
--blade.mdl = "models/lscs/weapons/nanosword_bladefx.mdl" -- use a model as blade?
--blade.mdl_poseparameter = "blade_retract" -- pose parameter to retract the blade. Should go from 0-1
blade.length = 45 -- blade length
blade.width = 0.9 -- width
blade.widthWiggle = 0.6 -- how much "noise" the blade has idling
blade.material_core_tip = Material( "lscs/effects/lightsaber_tip" ) -- material of the inner cores blade-tip
blade.material_core = Material( "lscs/effects/lightsaber_core" ) -- material of the inner cores blade
blade.material_glow = Material( "lscs/effects/lightsaber_glow" ) -- glow sprite effect
blade.material_trail = Material( "lscs/effects/lightsaber_trail" ) -- what material to use for the trail
blade.dynamic_light = true -- show dynamic light?
blade.no_trail = false -- disable trail?
blade.sounds = {
	Attack = "saber_hup", -- called when the combo file calls SWEP:DoAttackSound() or SWEP:DoAttackSound(nil, NUMBER_HAND) where NUMBER_HAND being SWEP.HAND_LEFT or SWEP.HAND_RIGHT or nil for both sabers
	Attack1 = "saber_spin1", -- SWEP:DoAttackSound( 1, NUMBER_HAND) for NUMBER_HAND see comment above
	Attack2 = "saber_spin2", -- SWEP:DoAttackSound( 2, NUMBER_HAND) for NUMBER_HAND see comment above
	Attack3 = "saber_spin3", -- SWEP:DoAttackSound( 3, NUMBER_HAND) for NUMBER_HAND see comment above
	Activate = "saber_turnon",
	Disable = "saber_turnoff",
	Idle =  "lscs/saber/saberhum4.wav",
}
LSCS:RegisterBlade( blade ) -- register it to the system. This will also register a new entity
