
--[[
	v v v Hilt v v v
]]
local hilt = {}
hilt.PrintName = "Katarn"
hilt.Author = "Blu-x92 / Luna"
hilt.id = "katarn"
hilt.mdl = "models/lscs/weapons/katarn.mdl"
hilt.info = {
	ParentData = {
		["RH"] = {
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector(4.25, -1.5, -1),
			ang = Angle(172, 0, 10),
		},
		["LH"] = {
			bone = "ValveBiped.Bip01_L_Hand",
			pos = Vector(4.25, -1.5, 1),
			ang = Angle(8, 0, -10),
		},
	},
	GetBladePos = function( ent )
		if not ent.BladeID then
			ent.BladeID = ent:LookupAttachment( "primary_blade" )
		end

		local att = ent:GetAttachment( ent.BladeID )

		if att then
			local blades = {
				[1] = {
					pos = att.Pos,
					dir = att.Ang:Up(),
				}
			}
			return blades
		end
	end,
}
LSCS:RegisterHilt( hilt )

-- modify previous hilt, only change what we need to change
hilt.PrintName = "Nano Sword"
hilt.Author = "Salza"
hilt.id = "nanosword"
hilt.mdl = "models/lscs/weapons/nanosword.mdl"
LSCS:RegisterHilt( hilt )


-- entirely new  hilt
local hilt = {}
hilt.PrintName = "Staff"
hilt.Author = "Blu-x92 / Luna"
hilt.id = "guard"
hilt.mdl = "models/lscs/weapons/staff.mdl"
hilt.info = {
	ParentData = {
		["RH"] = {
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector(4.25, -1.5, -1),
			ang = Angle(172, 0, 10),
		},
		["LH"] = {
			bone = "ValveBiped.Bip01_L_Hand",
			pos = Vector(4.25, -1.5, 1),
			ang = Angle(8, 0, -10),
		},
	},
	GetBladePos = function( ent )
		if not ent.BladeID1 then
			ent.BladeID1 = ent:LookupAttachment( "primary_blade" )
		end
		if not ent.BladeID2 then
			ent.BladeID2 = ent:LookupAttachment( "secondary_blade" )
		end

		local att1 = ent:GetAttachment( ent.BladeID1 )
		local att2 = ent:GetAttachment( ent.BladeID2 )

		if att1 and att2 then
			local blades = {
				[1] = {
					pos = att1.Pos,
					dir = att1.Ang:Up(),
				},
				[2] = {
					pos = att2.Pos,
					dir = att2.Ang:Up(),
				}
			}
			return blades
		end
	end,
}
LSCS:RegisterHilt( hilt )


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
	Activate = "saber_turnon",
	Disable = "saber_turnoff",
	Idle =  "saber/saberhum4.wav",
}
LSCS:RegisterBlade( blade )

-- modify previous blade, only change what we need to change
blade.PrintName = "Rubin"
blade.id = "rubin"
blade.color_blur = Color(200,0,0)
blade.width = 0.8
blade.widthWiggle = 0.7
blade.sounds.Idle = "saber/saberhum2.wav"
LSCS:RegisterBlade( blade ) -- then register new blade table

-- repeat ^^
blade.PrintName = "Smaragd"
blade.id = "smaragd"
blade.color_blur = Color(0,150,0)
blade.width = 0.9
blade.widthWiggle = 0.6
blade.sounds.Idle = "saber/saberhum5.wav"
LSCS:RegisterBlade( blade )

-- repeat ^^
blade.PrintName = "Amethyst"
blade.id = "amethyst"
blade.color_blur = Color(200,0,200)
blade.width = 1
blade.widthWiggle = 0.2
blade.sounds.Idle = "saber/saberhum3.wav"
LSCS:RegisterBlade( blade )

-- repeat ^^
blade.PrintName = "Citrine"
blade.id = "citrine"
blade.color_blur = Color(200,150,0)
blade.width = 0.9
blade.widthWiggle = 0.6
blade.sounds.Idle = "saber/saberhum1.wav"
LSCS:RegisterBlade( blade )

-- repeat ^^
blade.PrintName = "Allnatt"
blade.id = "allnatt"
blade.color_blur = Color(200,200,0)
blade.width = 0.65
blade.widthWiggle = 1
blade.sounds.Idle = "saber/saberhum3.wav"
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
	Activate = "nanosword_turnon",
	Disable = "nanosword_turnoff",
	Idle =  "nanosword_idle",
}
LSCS:RegisterBlade( blade )
