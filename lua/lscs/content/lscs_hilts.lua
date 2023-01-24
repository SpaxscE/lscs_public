
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


-- modify previous hilt, only change what we need to change
hilt.PrintName = "Vibro Sword"
hilt.Author = "Blu-x92 / Luna"
hilt.Spawnable = false -- special case, not spawnable from menu
hilt.id = "vibrosword"
hilt.mdl = "models/lscs/weapons/vibrosword.mdl"
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
