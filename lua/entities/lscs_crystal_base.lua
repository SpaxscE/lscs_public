AddCSLuaFile()

ENT.Base = "lscs_pickupable"
DEFINE_BASECLASS( "lscs_pickupable" )

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.PickupSound = "physics/metal/metal_grenade_impact_hard1.wav"
ENT.ImpactHardSound = "Rock.ImpactHard"
ENT.ImpactSoftSound = "Rock.ImpactSoft"

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/props_junk/rock001a.mdl" )

		self:SetMaterial("lights/white")
		self:SetColor( LSCS:GetBlade( self.ID ).color_core )
		self:DrawShadow( false )

		self:SetModelScale( 0.5 )

		BaseClass.Initialize( self )
	end
else
	local mat = Material( "sprites/light_glow02_add" )
	function ENT:DrawTranslucent()
		self:DrawModel()

		if not self.col then
			self.col = LSCS:GetBlade( self.ID ).color_blur
		end

		render.SetMaterial( mat )
		render.DrawSprite( self:GetPos(), 64, 64, self.col )
	end

	function ENT:Draw()
	end
end