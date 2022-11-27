
--[[
	v v v Blade v v v
]]
local blade = {}
blade.PrintName = "Sapphire"
blade.Author = "Blu-x92 / Luna"
blade.id = "sapphire"
blade.color_blur = Color(0,65,255)
blade.color_core = Color(255,255,255)
blade.length = 45
blade.width = 0.9
blade.widthWiggle = 0.6
blade.material_core_tip = Material( "lscs/effects/lightsaber_tip" )
blade.material_core = Material( "lscs/effects/lightsaber_core" )
blade.material_glow = Material( "lscs/effects/lightsaber_glow" )
blade.material_trail = Material( "lscs/effects/lightsaber_trail" )
blade.dynamic_light = true
blade.no_trail = false
blade.sounds = {
	Attack = "saber_hup",
	Attack1 = "saber_spin1",
	Attack2 = "saber_spin2",
	Attack3 = "saber_spin3",
	Activate = "saber_turnon",
	Disable = "saber_turnoff",
	Idle =  "saber_idle4",
}
LSCS:RegisterBlade( blade )

-- modify previous blade, only change what we need to change
blade.PrintName = "Rubin"
blade.id = "rubin"
blade.color_blur = Color(200,0,0)
blade.width = 0.8
blade.widthWiggle = 0.7
blade.sounds.Idle = "saber_idle2"
LSCS:RegisterBlade( blade ) -- then register new blade table

-- repeat ^^
blade.PrintName = "Smaragd"
blade.id = "smaragd"
blade.color_blur = Color(0,150,0)
blade.width = 0.9
blade.widthWiggle = 0.6
blade.sounds.Idle = "saber_idle5"
LSCS:RegisterBlade( blade )

-- repeat ^^
blade.PrintName = "Amethyst"
blade.id = "amethyst"
blade.color_blur = Color(200,0,200)
blade.width = 1
blade.widthWiggle = 0.2
blade.sounds.Idle = "saber_idle3"
LSCS:RegisterBlade( blade )

-- repeat ^^
blade.PrintName = "Citrine"
blade.id = "citrine"
blade.color_blur = Color(200,150,0)
blade.width = 0.9
blade.widthWiggle = 0.6
blade.sounds.Idle = "saber_idle1"
LSCS:RegisterBlade( blade )

-- repeat ^^
blade.PrintName = "Allnatt"
blade.id = "allnatt"
blade.color_blur = Color(200,200,0)
blade.width = 0.65
blade.widthWiggle = 1
blade.sounds.Idle = "saber_idle3"
LSCS:RegisterBlade( blade )

-- special case: model based blade
local blade = {}
blade.PrintName = "Nano Particles"
blade.Author = "Blu-x92 / Luna"
blade.id = "nanoparticles"
blade.color_blur = Color(0,127,255)
blade.color_core = Color(0,0,0)
blade.mdl = "models/lscs/weapons/nanosword_bladefx.mdl"
blade.mdl_poseparameter = "blade_retract"
blade.length = 27
blade.dynamic_light = true
blade.no_trail = false
blade.sounds = {
	Attack = "nanosword_hup",
	Attack1 = "nanosword_hup",
	Attack2 = "nanosword_hup",
	Attack3 = "nanosword_hup",
	Activate = "nanosword_turnon",
	Disable = "nanosword_turnoff",
	Idle =  "nanosword_idle",
}
LSCS:RegisterBlade( blade )
