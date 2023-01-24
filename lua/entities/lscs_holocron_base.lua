AddCSLuaFile()

ENT.Base = "lscs_pickupable"
DEFINE_BASECLASS( "lscs_pickupable" )

ENT.Spawnable		= false
ENT.AdminSpawnable		= false

ENT.PickupSound = "physics/metal/weapon_impact_soft3.wav"
ENT.ImpactHardSound = "Concrete_Block.ImpactHard"
ENT.ImpactSoftSound = "weapon.ImpactSoft"

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/lscs/holocron.mdl" )
		BaseClass.Initialize( self )
	end
end