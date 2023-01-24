AddCSLuaFile()

ENT.Type            = "anim"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.DoNotDuplicate = true

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
end

function ENT:PlayAnimation( animation, playbackrate )
	playbackrate = playbackrate or 1

	local sequence = self:LookupSequence( animation )

	self:ResetSequence( sequence )
	self:SetPlaybackRate( playbackrate )
	self:SetSequence( sequence )
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
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self:SetTrigger( true )

		self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	end

	function ENT:UpdateTransmitState() 
		return TRANSMIT_ALWAYS
	end

	function ENT:DoPickup( ply )
		ply:EmitSound( self.PickupSound )
		ply:lscsAddInventory( self )
	end

	function ENT:OnRemove()
	end

	function ENT:Use( ply )
		self:DoPickup( ply )
	end

	function ENT:Think()
		if self.DieTime and self.DieTime < CurTime() then
			self:Remove()
		end
		
		self:NextThink( CurTime() )
		return true
	end

	function ENT:OnTakeDamage( dmginfo )
		self:TakePhysicsDamage( dmginfo )
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

	function ENT:Think()
	end

	function ENT:OnRemove()
	end

	function ENT:DrawTranslucent()
	end

	function ENT:Draw()
		self:DrawModel()
	end
end