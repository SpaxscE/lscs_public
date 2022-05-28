AddCSLuaFile()

ENT.Base = "lscs_hilt"

ENT.PrintName = "Nanosword [DeusEx]"
ENT.Author = "Blu-x92 / Luna"
ENT.Category = "[LSCS]"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MDL = "models/lscs/weapons/nanosword.mdl"
ENT.MDL_INFO = {
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
}

ENT.BladeLength = 30

ENT.SwingSound = "saber_hup"