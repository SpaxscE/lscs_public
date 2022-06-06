AddCSLuaFile()

ENT.Type            = "anim"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.DoNotDuplicate = true

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar( "Bool",0, "Active" )
	self:NetworkVar( "Entity",0, "Player" )
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

	function ENT:OnPickedUp( ply )
		ply:lscsAddInventory( self )
	end

	function ENT:DoPickup( ply )
		ply:EmitSound( self.PickupSound )

		self:OnPickedUp( ply )
	end

	function ENT:OnRemove()
	end

	function ENT:Use( ply )
		local Owner = self:GetPlayer()

		if IsValid( Owner ) then
			if ply == Owner then
				self:DoPickup( Owner )
			end

			return
		end

		self:SetPlayer( ply )
		self:TurnOn()
	end

	function ENT:Think()
		local Active =  self:GetActive()

		if Active then
			local ply = self:GetPlayer()
			local Pos = self:GetPos()

			if not IsValid( ply ) or (Pos - ply:GetPos()):Length() > 300 then
				self:TurnOff()
				self:SetPlayer( NULL )
			end

			local PhysObj = self:GetPhysicsObject()

			if IsValid( PhysObj ) then
				local FT = FrameTime()
				local Mass = PhysObj:GetMass()

				local Force = (ply:GetShootPos() - self:GetPos() - self:GetVelocity() * 2) * Mass

				PhysObj:ApplyForceCenter( Force * FT )

				local P = math.cos( CurTime() )
				local Y = math.sin( CurTime() )
				local R = math.cos( CurTime() * 2 )
				PhysObj:AddAngleVelocity( Vector(P,Y,R) - PhysObj:GetAngleVelocity() * 0.1 )
			end
		end

		self:NextThink( CurTime() )

		return true
	end

	function ENT:TurnOn()
		self:SetActive( true )

		local PhysObj = self:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:EnableGravity( false )
		end
	end

	function ENT:TurnOff()
		self:SetActive( false )

		local PhysObj = self:GetPhysicsObject()
		if IsValid( PhysObj ) then
			PhysObj:EnableGravity( true )
		end
	end

	function ENT:PlayAnimation( animation, playbackrate )
		playbackrate = playbackrate or 1

		local sequence = self:LookupSequence( animation )

		self:ResetSequence( sequence )
		self:SetPlaybackRate( playbackrate )
		self:SetSequence( sequence )
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
	end

	function ENT:EndTouch( touch_ent )
	end

	function ENT:Touch( touch_ent )
		if self.DisablePickup then return end

		if self.PreventTouch and touch_ent ~= self:GetPlayer() then return end

		if not IsValid( touch_ent ) or not touch_ent:IsPlayer() then return end

		self:DoPickup( touch_ent )

		self.DisablePickup = true
	end
else
	function ENT:Initialize()
	end

	function ENT:Think()
		local Dist = (LocalPlayer():GetViewEntity():GetPos() - self:GetPos()):Length()
		local Active = self:GetActive() and Dist < 1000

		if Active then
			if not self.sndLOOP then
				self.sndLOOP = CreateSound( self, "ambient/levels/citadel/citadel_drone_loop1.wav" )
				self.sndLOOP:PlayEx(0.25,100)
			end
		else
			if self.sndLOOP then
				self.sndLOOP:Stop()
				self.sndLOOP = nil
			end
		end
	end

	function ENT:OnRemove()
		if self.sndLOOP then
			self.sndLOOP:Stop()
			self.sndLOOP = nil
		end
	end

	local mat = Material( "sprites/light_glow02_add" )
	function ENT:DrawTranslucent()
		self:DrawModel()

		if not self:GetActive() then return end

		render.SetMaterial( mat )
		render.DrawSprite( self:GetPos(), 16, 16, Color(255,255,255) )
		render.DrawSprite( self:GetPos(), 64, 64, Color(127,255,255) )
	end

	function ENT:Draw()
		self:DrawModel()
	end
end