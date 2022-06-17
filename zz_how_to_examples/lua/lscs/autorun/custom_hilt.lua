
local hilt = {}
hilt.PrintName = "MyHilt" -- nice name in the menu
hilt.Author = "Me" -- your name
hilt.id = "myhiltid" -- always lower case
hilt.mdl = "models/lscs/weapons/katarn.mdl" -- what model to use
hilt.info = {
	ParentData = { -- allows you to modify how the model is attached to the player. "RH" = Right Hand,  "LH" = Left Hand
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
	GetBladePos = function( ent ) -- GetBladePos allows you to modify where the blade is being rendered. By using a function you could in theory do all sort of crazy things without having to redo the model's attachments
		if not ent.BladeID1 then
			ent.BladeID1 = ent:LookupAttachment( "primary_blade" )
		end
		--if not ent.BladeID2 then
		--	ent.BladeID2 = ent:LookupAttachment( "secondary_blade" )
		--end

		local att1 = ent:GetAttachment( ent.BladeID1 )
		--local att2 = ent:GetAttachment( ent.BladeID2 )

		if att1 then -- and att2 then
			local blades = {
				[1] = {
					pos = att1.Pos,
					dir = att1.Ang:Up(),
				},
				--[2] = { -- add any amount of blades. Just increment the number
				--	pos = att2.Pos,
				--	dir = att2.Ang:Up(),
				--	no_trail = true, -- disable trail effect. Looks better when doing crossguards
				--}
			}
			return blades
		end
	end,
}
LSCS:RegisterHilt( hilt ) -- register it to the system. This will also register a new entity
