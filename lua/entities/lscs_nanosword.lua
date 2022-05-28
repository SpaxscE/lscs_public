AddCSLuaFile()

ENT.Base = "lscs_hilt"

ENT.PrintName = "Nanosword [DeusEx]"
ENT.Author = "Blu-x92 / Luna"
ENT.Category = "[LSCS]"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MDL = "models/weapons/w_nanosword_hd.mdl"
ENT.MDL_INFO = {
	["RH"] = {
		bone = "ValveBiped.Bip01_R_Hand",
		pos = Vector(7, -2.5, 0),
		ang = Angle(85, 15, 90),
	},
	["LH"] = {
		bone = "ValveBiped.Bip01_L_Hand",
		pos = Vector(6, 1.5, -1.5),
		ang = Angle(-60, 15, -90),
	},
}

