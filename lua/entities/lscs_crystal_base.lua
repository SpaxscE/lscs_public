AddCSLuaFile()

ENT.Base = "lscs_pickupable"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.PickupSound = "physics/metal/metal_grenade_impact_hard1.wav"
ENT.ImpactHardSound = "Rock.ImpactHard"
ENT.ImpactSoftSound = "Rock.ImpactSoft"

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/props_junk/rock001a.mdl" )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		self:SetMaterial("lights/white")
		self:SetColor( LSCS:GetBlade( self.ID ).color_core )
		self:DrawShadow( false )

		self:SetTrigger( not self.PreventTouch ) -- this will make it so you can use ply:Give() and the player will automatically pick it up, but if spawned using the q-menu it wont
	end

	function ENT:OnPickedUp( ply )
	end

	function ENT:PhysicsCollide( data, physobj )
		if data.Speed > 60 and data.DeltaTime > 0.2 then
			if data.Speed > 200 then
				self:EmitSound( self.ImpactHardSound )
			else
				self:EmitSound(  self.ImpactSoftSound )
			end
		end
	end
else
	function ENT:Initialize()
		self:SetModelScale( 0.5 )
	end

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