AddCSLuaFile()

ENT.Type            = "anim"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.DoNotDuplicate = true

function ENT:SetupDataTables()
end

if SERVER then
	function ENT:SpawnFunction( ply, tr, ClassName )

		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 15 )
		ent:SetAngles( Angle(90,ply:EyeAngles().y,0) )
		ent.PreventTouch = true
		ent:Spawn()
		ent:Activate()
		ent:PhysWake()

		return ent
	end

	function ENT:Initialize()
	end

	function ENT:UpdateTransmitState() 
		return TRANSMIT_ALWAYS
	end

	function ENT:OnPickedUp( ply )
		ply:lscsAddInventory( self )
	end

	function ENT:DoPickup( ply )
		self:EmitSound( self.PickupSound )

		self:OnPickedUp( ply )
	end

	function ENT:OnRemove()
	end

	function ENT:Use( ply )
		self:DoPickup( ply )
	end

	function ENT:Think()
		return false
	end

	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
	end

	function ENT:PhysicsCollide( data, physobj )
	end

	function ENT:StartTouch( touch_ent )
		if self.PreventTouch then return end

		if not IsValid( touch_ent ) or not touch_ent:IsPlayer() then return end

		self:DoPickup( touch_ent )
	end

	function ENT:EndTouch( touch_ent )
	end

	function ENT:Touch( touch_ent )
	end
else
	function ENT:Initialize()
	end

	function ENT:OnRemove()
	end

	function ENT:Think()
	end

	function ENT:DrawTranslucent()
	end

	function ENT:Draw()
		self:DrawModel()
	end
end