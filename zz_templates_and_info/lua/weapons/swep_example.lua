-- this script will add a pre-assembled lightsaber to your q-menu

AddCSLuaFile()

SWEP.Base = "weapon_lscs"
DEFINE_BASECLASS( "weapon_lscs" )

SWEP.Category			= "[LSCS]"
SWEP.PrintName		= "Vibro Sword"
SWEP.Author			= "Blu-x92 / Luna"

SWEP.Slot				= 0
SWEP.SlotPos			= 3

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )

	if SERVER then
		self:SetHiltR("vibrosword") -- which hilt to use
		--self:SetHiltL("vibrosword") -- left hand hilt

		self:SetBladeR("nanoparticles") -- which blade to use
		self:SetBladeL("nanoparticles") --left hand blade

		--self:SetStance("butterfly") -- assigns a stance override to this saber
	end
end
