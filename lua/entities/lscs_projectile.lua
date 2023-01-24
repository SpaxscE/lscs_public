AddCSLuaFile()

ENT.Type            = "anim"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_BOTH 

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "SWEP" )
end

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/lscs/saber_throw.mdl" )

		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_NONE )

		local SWEP = self:GetSWEP()

		SWEP:SetActive( true )
		SWEP:SetProjectile( self )
		SWEP:CancelCombo( 100 )
		SWEP:SetDMGActive( true )

		self:PlayAnimation( "spin", 2.5 )

		self.SpawnTime = CurTime()
		self.StartThink = true

		self:DrawShadow( false )
	end

	function ENT:ResetProgress()
		self.Time = CurTime() + 1
	end

	function ENT:GetProgress()
		if not self.Time then
			return (2 + math.max(self.SpawnTime - CurTime(),-1)) / 2
		end

		return math.Clamp( (self.Time - CurTime()) / 2,0,1)
	end

	function ENT:CalcMove( ply )
		local FT = FrameTime()

		local ShootPos = ply:GetShootPos() 

		local trace = util.TraceLine( {
			start = ShootPos,
			endpos = ShootPos + ply:EyeAngles():Forward() * 5000,
			mask = MASK_SOLID_BRUSHONLY,
		} )

		local start = ShootPos - Vector(0,0,20)
		local sub = (trace.HitPos + trace.HitNormal * 20) - start
		local dir = sub:GetNormalized()
		local dist = math.min( sub:Length(), 800 )

		local TargetPos = start + dir * (dist * self:GetProgress() * 1.7)

		local MoveSub = TargetPos - self:GetPos()

		local MoveDist = math.min( MoveSub:Length() * 10, self:GetProgress() > 0.5 and 750 or 350 ) -- quick after throw, but slow on return
		local MoveDir = MoveSub:GetNormalized()

		local MoveSpeed = MoveDist * FT

		local Move = MoveDir * MoveSpeed

		self:SetPos( self:GetPos() + Move )

		local A = math.cos( math.rad(self:GetProgress() * 180 ) )
		self:SetAngles( ply:LocalToWorldAngles( Angle( math.min(A * 40,0),0,-A * 20 ) ) )
	end

	function ENT:CalcFP( ply, SWEP )
		local Time = CurTime()

		if (self._nextFP or 0) > Time then return end

		self._nextFP = Time + 1

		ply:lscsTakeForce( 5 )
		SWEP:DrainBP( 12 )

		if ply:lscsGetForce() > 0 then return end

		if not self.Returning then
			self.Returning = true
			ply._lscsThrownSaber:ResetProgress()
		end
	end

	function ENT:Think()
		self:NextThink( CurTime() )

		if self.StartThink then

			local SWEP = self:GetSWEP()

			if IsValid( SWEP ) then
				local ply = SWEP:GetOwner()

				if IsValid( ply ) then
					if not SWEP:GetActive() then
						self:Remove()

						return
					end

					self:CalcMove( ply )
					self:CalcFP( ply, SWEP )
	
					if (CurTime() - self.SpawnTime) > 0.5 then
						local Dist = (ply:GetShootPos() - self:GetPos()):Length()
						if self:GetProgress() <= 0.2 then
							if Dist <= 50 then
								ply:EmitSound("lscs/equip.mp3")
								self:Remove()
							end
						else
							if Dist <= 80 then
								ply:EmitSound("lscs/equip.mp3")
								self:Remove()
							end
						end
					end
				else
					self:Remove()
				end
			else
				self:Remove()
			end

		end

		return true
	end

	function ENT:OnRemove()
		local SWEP = self:GetSWEP()

		if not IsValid( SWEP ) then return end

		SWEP:SetProjectile( NULL )
		SWEP:SetDMGActive( false )
		SWEP:SetNextPrimaryAttack( CurTime() )

		local Active = SWEP:GetActive()

		if Active then
			SWEP:SetHoldType( SWEP:GetCombo().HoldType )
		else
			SWEP:SetHoldType( "normal" )
		end
	end

	function ENT:PlayAnimation( animation, playbackrate )
		playbackrate = playbackrate or 1

		local sequence = self:LookupSequence( animation )

		self:ResetSequence( sequence )
		self:SetPlaybackRate( playbackrate )
		self:SetSequence( sequence )
	end

	function ENT:UpdateTransmitState() 
		return TRANSMIT_ALWAYS
	end
else
	function ENT:Initialize()
		self.SND = CreateSound( self, "lscs/saber/saberspin_loop.wav" )
		self.SND:Play()
	end

	function ENT:OnRemove()
		if self.SND then
			self.SND:Stop()
		end
	end

	function ENT:Draw()
	end

	function ENT:DrawTranslucent()
		local SWEP = self:GetSWEP()

		if not IsValid( SWEP ) then return end

		self:SetupBones()

		SWEP:DrawWorldModelTranslucent( nil, self )
	end
end