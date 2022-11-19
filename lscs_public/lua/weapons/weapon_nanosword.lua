AddCSLuaFile()

SWEP.Base = "weapon_lscs"
DEFINE_BASECLASS( "weapon_lscs" )

SWEP.Category			= "[LSCS]"
SWEP.PrintName		= "Dragon's Tooth Sword"
SWEP.Author			= "Blu-x92 / Luna"

SWEP.Slot				= 0
SWEP.SlotPos			= 1

SWEP.Spawnable		= true
SWEP.AdminOnly		= true

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )

	if SERVER then
		self:SetHiltR("nanosword")
		self:SetBladeR("nanoparticles")
	end
end
