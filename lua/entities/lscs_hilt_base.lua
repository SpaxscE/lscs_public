AddCSLuaFile()

ENT.Base = "lscs_pickupable"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.PickupSound = "physics/metal/weapon_impact_soft3.wav"
ENT.ImpactHardSound = "weapon.ImpactHard"
ENT.ImpactSoftSound = "weapon.ImpactSoft"

if SERVER then
	function ENT:Initialize()
		self:SetModel( self.MDL )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		self:SetTrigger( not self.PreventTouch ) -- this will make it so you can use ply:Give() and the player will automatically pick it up, but if spawned using the q-menu it wont
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
end