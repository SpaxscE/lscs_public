AddCSLuaFile()

ENT.Base = "lscs_hilt"

ENT.PrintName = "Lightsaber [Kyle Katarn]"
ENT.Author = "Blu-x92 / Luna"
ENT.Category = "[LSCS]"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MDL = "models/blu/jedi/saberhilt/katarn.mdl"
ENT.MDL_INFO = {
	["RH"] = {
		bone = "ValveBiped.Bip01_R_Hand",
		pos = Vector(4.25, -1.5, -2.5),
		ang = Angle(-85, 90, 0),
	},
	["LH"] = {
		bone = "ValveBiped.Bip01_L_Hand",
		pos = Vector(4.25, -1.5, 2.5),
		ang = Angle(85, 90, 0),
	},
}

