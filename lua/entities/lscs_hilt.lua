AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName = "LSCS Basescript"
ENT.Author = "Blu-x92 / Luna"
ENT.Category = "[LSCS]"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.LSCSfilter = true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "BelongTo" )
	self:NetworkVar( "Entity",1, "Weapon" )

	self:NetworkVar( "Bool",0, "Active" )
	self:NetworkVar( "Bool",1, "LeftHand" )

	self:NetworkVar( "Vector",0, "BladeColor" )

	if SERVER then
		self:SetBladeColor( Vector(0,65,255) )
	end
end

function ENT:IsOwned()
	return IsValid( self:GetBelongTo() )
end

function ENT:DoAttackSound()
	if self.SwingSound then
		self:EmitSoundUnpredicted( self.SwingSound )
	end
end

function ENT:GetOwningEnt()
	local Owner = self:GetBelongTo()

	if IsValid( Owner ) then
		return Owner
	else
		return self
	end
end

if SERVER then
	function ENT:SpawnFunction( ply, tr, ClassName )

		if not tr.Hit then return end

		local ent = ents.Create( ClassName )
		ent:SetPos( tr.HitPos + tr.HitNormal * 15 )
		ent:SetAngles( Angle(90,ply:EyeAngles().y,0) )
		ent:Spawn()
		ent:Activate()
		ent:PhysWake()

		return ent

	end

	function ENT:Initialize()
		self:SetModel( self.MDL )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		self:SetTrigger( true )
	end

	function ENT:UpdateTransmitState() 
		return TRANSMIT_ALWAYS
	end

	function ENT:DoPickup( ply, LH )
		self:SetBelongTo( ply )
		self:SetLeftHand( LH )

		self:SetParent( ply )
		self:SetLocalPos( Vector(0,0,70) )
		self:SetLocalAngles( angle_zero )

		self:SetTransmitWithParent( true )

		self:DrawShadow( false )

		self:EmitSound( "items/ammo_pickup.wav" )
	end

	function ENT:EmitSoundUnpredicted( name )
		timer.Simple(0, function()
			if not IsValid( self ) then return end

			self:GetOwningEnt():EmitSound( name )
		end)
	end

	function ENT:GiveTo( ply )
		if self:IsOwned() then return end
		if not IsValid( ply ) or not ply:IsPlayer() or not ply:Alive() then return end

		if not ply:HasWeapon( "lscs_combohandler" ) then
			ply:Give( "lscs_combohandler" )
		end

		ply:SelectWeapon( "lscs_combohandler" )

		local wep = ply:GetWeapon( "lscs_combohandler" )

		if IsValid( wep ) then
			local LH = wep:GethiltLH()
			local RH = wep:GethiltRH()

			if not IsValid( RH ) then
				wep:SethiltRH( self, false )
				self:SetWeapon( wep )
				self:DoPickup( ply )

				return
			end
	
			if not IsValid( LH ) then
				wep:SethiltLH( self )
				self:SetWeapon( wep )
				self:DoPickup( ply, true )
			end
		end
	end

	function ENT:OnRemove()
		local ply = self:GetBelongTo()

		if not IsValid( ply ) then return end

		local wep = ply:GetWeapon( "lscs_combohandler" )

		if IsValid( wep ) then
			local LH = wep:GethiltLH()
			local RH = wep:GethiltRH()

			if not IsValid( RH ) or not IsValid( LH ) then
				ply:StripWeapon( "lscs_combohandler" )
			end
		end
	end

	function ENT:Use( ply )
		self:GiveTo( ply )
	end

	function ENT:Think()
		return false
	end

	function ENT:OnTakeDamage( dmginfo )
	end

	function ENT:StartTouch( touch_ent )
		self:GiveTo( touch_ent )
	end

	function ENT:EndTouch( touch_ent )
	end

	function ENT:Touch( touch_ent )
	end

	function ENT:PhysicsCollide( data, physobj )
	end
else
	function ENT:EmitSoundUnpredicted( name )
	end

	function ENT:SetLength( n )
		self.sm_length = n
	end

	function ENT:GetMaxLength()
		return self.BladeLength
	end

	function ENT:GetLength()
		return (self.sm_length or 0)
	end

	function ENT:CalcBlade( target_ent )
		if not IsValid( target_ent ) then return end

		if not self.attChecked then
			self.BladeID1 = target_ent:LookupAttachment( "primary_blade" )
			self.BladeID2 = target_ent:LookupAttachment( "secondary_blade" )

			self.attChecked = true
		end

		local att1 = target_ent:GetAttachment( self.BladeID1 )
		local att2 = target_ent:GetAttachment( self.BladeID2 )

		if att1 then
			self:BladeEffectsPrimary( att1 )
		end

		if att2 then
			self:BladeEffectsSecondary( att2 )
		end
	end

	function ENT:BladeEffectsPrimary( att )
		self:DoBladeTrace( att.Pos, att.Ang:Up(), 2 )
	end

	function ENT:BladeEffectsSecondary( att )
		self:DoBladeTrace( att.Pos, att.Ang:Up(), 2 )
	end

	function ENT:DoIdleImpactEffects( trace )
	end

	function ENT:DoBladeTrace( pos, dir, size )
		local Length = self:GetLength()

		local min = Vector( -size, -size, -size )
		local max = Vector( size, size, size )

		local trace = util.TraceHull( {
			start = pos,
			endpos = pos + dir * Length,
			mins = min,
			maxs = max,
			mask = MASK_SHOT_HULL,
			filter = function( ent ) 
				if ent == self or ent == self:GetBelongTo() or ent == self:GetWeapon() or ent.LSCSfilter then return false end

				return true
			end
		} )

		if IsValid( trace.Entity ) and not self:GetDMGActive() then
			if (self.GenericFX or 0) < CurTime() then
				self.GenericFX = CurTime() + 0.05

				self:DoIdleImpactEffects( trace )
			end
		end

		if self:GetDMGActive() then
			debugoverlay.SweptBox( pos, pos + dir * Length, min, max, dir:Angle(), 10, Color( 255, 0, 0 ) )
		else
			self.prev_hitpos = nil
			self.prev_hitnormal = nil
		end

		local wep = self:GetWeapon()

		if IsValid( wep ) then
			self:CalcBladeDamage( trace.Hit, trace.HitPos, trace.HitNormal, trace.Entity, wep:GetOwner(), min, max )
		else
			-- unowned dmg code here
		end

		return trace
	end

	function ENT:CalcBladeDamage( bHit, vPos, vDir, hitEnt, ply )
		local start_pos = ply:GetShootPos()
		local aimDir = ply:GetAimVector()
		local dmgActive = self:GetDMGActive()

		local bHitWall = bHit and not IsValid( hitEnt )
		if self.HitWall ~= bHitWall then
			self.HitWall = bHitWall
			if not bHitWall then
				self:EmitSound( "saber_hitwall" )
			end
		end

		if self.prev_hitpos and self.prev_hitnormal then
			local _pos = self.prev_hitpos
			local _dir = self.prev_hitnormal
			local dir = (vPos - _pos):GetNormalized()

			local dist = math.Round( (vPos - _pos):Length() , 0 )

			if dist > 0 then
				for i = 1.5, dist,1.5 do
					local trace = util.TraceHull( {
						start = start_pos,
						endpos = _pos + dir * i + aimDir * 5,
						mins = Vector( -2, -2, -2 ),
						maxs = Vector( 2, 2, 2 ),
						mask = MASK_SHOT_HULL,
						filter = function( ent ) 
							if ent == self or ent == self:GetBelongTo() or ent == self:GetWeapon() or ent.LSCSfilter then return false end

							return true
						end
					} )

					debugoverlay.SweptBox( start_pos, _pos + dir * i + aimDir * 5, min, max, (start_pos -  (_pos + dir * i + aimDir * 5)):Angle(), 10, Color( 0, 100, 255 ) )

					if trace.Hit and not IsValid( trace.Entity ) then
						local effectdata = EffectData()
							effectdata:SetOrigin( trace.HitPos )
							effectdata:SetNormal( trace.HitNormal )
						util.Effect( "saber_hitwall", effectdata, true, true )
					end

					if dmgActive then
						self:NWDamage( trace.Entity, trace.HitPos, trace.HitNormal )
					end
				end
			else
				if dmgActive then
					self:NWDamage( hitEnt, vPos, vDir )
				else
					if not IsValid( hitEnt ) then
						local effectdata = EffectData()
							effectdata:SetOrigin( vPos )
							effectdata:SetNormal( vDir )
						util.Effect( "saber_hitwall", effectdata, true, true )

						sound.Play(Sound( "saber_hitwall_spark" ), vPos, 75)
					end
				end
			end
		else
			if not IsValid( hitEnt ) and bHitWall then
				local effectdata = EffectData()
					effectdata:SetOrigin( vPos )
					effectdata:SetNormal( vDir )
				util.Effect( "saber_hitwall", effectdata, true, true )

				sound.Play(Sound( "saber_hitwall_spark" ), vPos, 75)
			end
		end

		self.prev_hitpos = vPos
		self.prev_hitnormal = vDir
	end

	function ENT:GetDMGActive()
		local wep = self:GetWeapon()
		if IsValid( wep ) then
			return wep:GetDMGActive()
		else
			return self:GetActive()
		end
	end

	function ENT:Initialize()
		self.WorldModel = ClientsideModel( self.MDL )
		self.WorldModel:SetNoDraw(true)
	end

	function ENT:OnRemove()
		if IsValid( self.WorldModel ) then
			self.WorldModel:Remove()
		end
	end

	function ENT:IsActive()
		local wep = self:GetWeapon()
		local active = self:GetActive()

		if IsValid( wep ) then
			active = wep:GetActive()
		end

		return active
	end

	function ENT:OnActiveChanged( oldActive, active )
		if oldActive == nil then return end

		if active then
			if self.TurnOnSound then
				self:GetOwningEnt():EmitSound( self.TurnOnSound )
			end
		else
			if self.TurnOffSound then
				self:GetOwningEnt():EmitSound( self.TurnOffSound )
			end
		end
	end

	function ENT:Think()
		local active = self:IsActive()

		local FT = FrameTime()
		local Length = self:GetLength()
		local targetLength = active and self:GetMaxLength() or 0

		self:SetLength( Length + math.Clamp(targetLength - Length,-FT * 100,FT * 200) )

		if self._oldActive ~= active then
			self:OnActiveChanged( self._oldActive, active )

			self._oldActive = active
		end
	end

	function ENT:DrawEquippedTranslucent( flags )
		local ply = self:GetBelongTo()
		local WorldModel = self.WorldModel

		local active = ply:GetActiveWeapon():GetClass() == "lscs_combohandler"

		local data = self.MDL_INFO[ (self:GetLeftHand() and "LH" or "RH") ]

		local offsetVec = data.pos
		local offsetAng = data.ang

		local boneid = ply:LookupBone( data.bone )

		if not boneid then return end

		local matrix = ply:GetBoneMatrix( boneid )
		if not matrix then return end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		WorldModel:SetPos( newPos )
		WorldModel:SetAngles( newAng )
		WorldModel:SetupBones()
		WorldModel:DrawModel()

		self:CalcBlade( WorldModel )
	end

	function ENT:DrawEquipped( flags )
	end

	function ENT:DrawTranslucent()
	end

	function ENT:NWDamage( hitEnt, vPos, vDir )
		if not IsValid( hitEnt ) then return end

		local curtime = CurTime()

		hitEnt.HitTime = hitEnt.HitTime or 0

		if hitEnt.HitTime < curtime then
			hitEnt.HitTime = curtime + 0.15

			if self:GetBelongTo() == LocalPlayer() then
				net.Start( "lscs_saberdamage" ) 
					net.WriteEntity( hitEnt )
					net.WriteVector( vPos )
					net.WriteVector( vDir )
				net.SendToServer()
			end
		end
	end

	function ENT:Draw()
		if self:IsOwned() then return end

		self:DrawModel()
		self:CalcBlade( self )
	end
end