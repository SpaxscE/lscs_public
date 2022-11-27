
function SWEP:SetNextDeflectAnim( time )
	self._nextDeflectAnim = time
end

function SWEP:CanPlayDeflectAnim()
	return (self._nextDeflectAnim or 0) < CurTime()
end

function SWEP:SetNextDeflect( time )
	self._nextDeflect = time
end

function SWEP:CanDeflect()
	if not self:GetActive() or not self:GetCombo().DeflectBullets then
		return false
	end

	return (self._nextDeflect or 0) < CurTime()
end

function SWEP:SetNextBlock( time )
	self._nextBlock = time
end

function SWEP:CanBlock()
	return (self._nextBlock or 0) < CurTime()
end

function SWEP:OnPerfectBlock( ply, a_, a_weapon )
	if net.Start("lscs_hitmarker") then
		net.WriteInt( 3, 4 )
		net.Send( ply )
	end

	if a_weapon:CurComboUnblockable() then
		self:DrainBP( a_weapon:GetBPDrainPerHit() * a_weapon:GetComboHits() )
	else
		a_weapon:AddHit( -0.25 )

		self._ResetHitTime = CurTime() + 5
		self:AddHit( 0.1 )
	end
end

function SWEP:OnNormalBlock( ply, a_, a_weapon )
	if net.Start("lscs_hitmarker") then
		net.WriteInt( 1, 4 )
		net.Send( a_ )
	end

	a_weapon._ResetHitTime = CurTime() + 10
	if not a_weapon:CurComboUnblockable() then
		a_weapon:AddHit( 0.05 )
	end

	self:DrainBP( a_weapon:GetBPDrainPerHit() * a_weapon:GetComboHits() )
end

function SWEP:OnBlock( ply, a_, a_weapon )
	if net.Start("lscs_hitmarker") then
		net.WriteInt( 2, 4 )
		net.Send( a_ )
	end

	a_weapon._ResetHitTime = CurTime() + 10
	if a_weapon:CurComboUnblockable() then
		a_weapon:AddHit( 0.05 )
	else
		a_weapon:AddHit( 0.1 )
	end

	self:DrainBP( a_weapon:GetBPDrainPerHit() * a_weapon:GetComboHits() )
end

function SWEP:AddHit( num )
	self:SetComboHits( math.Clamp(self:GetComboHits() + num,0,1) )

	if self:GetComboHits() == 0 then
		self._ResetHitTime = nil
	end
end

local BLOCKED_STANDARD = 1
local BLOCKED_STAGGER = 2
local BLOCKED_NOANIM = 3

-- defender performing block
function SWEP:Block( dmginfo )
	local BLOCK = LSCS_UNBLOCKED

	if not self:GetActive() or self:IsBrokenSaber() or self:IsThrown() then return BLOCK end

	local ply = self:GetOwner()

	if not IsValid( ply ) then return BLOCK end

	if not dmginfo:IsDamageType( DMG_ENERGYBEAM )
		and not dmginfo:IsDamageType( DMG_CLUB )
		and not dmginfo:IsDamageType( DMG_SLASH )
		and dmginfo:GetDamageType() ~= DMG_GENERIC then

		self:DrainBP() -- prevent 0 bp regeneration

		return BLOCK
	end

	local a_ = dmginfo:GetAttacker()
	local a_weapon = dmginfo:GetInflictor()
	local a_weapon_lscs = IsValid( a_weapon ) and a_weapon.LSCS

	local BLOCK_ANIM = BLOCKED_STANDARD

	if a_weapon_lscs and IsValid( a_ ) then
		local _pos = a_weapon:GetBlockPos()

		local BlockDistance = self:GetBlockDistanceTo( _pos )

		local AutoBlock = self:GetCombo().AutoBlock

		if self:IsComboActive() then
			if AutoBlock then
				if self:GetBlockPoints() <= 0 then self:DrainBP() return LSCS_UNBLOCKED end

				self:OnBlock( ply, a_, a_weapon )

				BLOCK = LSCS_BLOCK
				BLOCK_ANIM = BLOCKED_NOANIM
			else
				self:DrainBP() -- prevent 0 bp regeneration

				return LSCS_UNBLOCKED
			end
		else
			if BlockDistance < self:GetBlockDistanceNormal() then
				if BlockDistance < self:GetBlockDistancePerfect() then

					local effectdata = EffectData()
						effectdata:SetOrigin( dmginfo:GetDamagePosition())
						effectdata:SetNormal( Vector(0,0,1) )
						effectdata:SetRadius( 1 )
					util.Effect( "cball_bounce", effectdata, true, true )

					self:OnPerfectBlock( ply, a_, a_weapon )

					BLOCK = LSCS_BLOCK_PERFECT
				else
					if AutoBlock then
						if self:GetBlockPoints() <= 0 then self:DrainBP() return LSCS_UNBLOCKED end

						self:OnNormalBlock( ply, a_, a_weapon )

						BLOCK = LSCS_BLOCK_NORMAL
						BLOCK_ANIM = BLOCKED_STAGGER
					else
						self:DrainBP() -- prevent 0 bp regeneration

						return LSCS_UNBLOCKED
					end
				end
			else
				if AutoBlock then
					if self:GetBlockPoints() <= 0 then self:DrainBP() return LSCS_UNBLOCKED end

					self:OnBlock( ply, a_, a_weapon )

					BLOCK = LSCS_BLOCK
					BLOCK_ANIM = BLOCKED_STAGGER
				else
					self:DrainBP() -- prevent 0 bp regeneration

					return LSCS_UNBLOCKED
				end
			end
		end
	else
		if self:GetCombo().AutoBlock then
			BLOCK = LSCS_BLOCK_NONSABER
		else
			self:DrainBP() -- prevent 0 bp regeneration

			return LSCS_UNBLOCKED
		end
	end

	if BLOCK == LSCS_BLOCK_NONSABER and self:GetBlockPoints() <= 0 then
		BLOCK = LSCS_UNBLOCKED
		BLOCK_ANIM = BLOCKED_STAGGER
	end

	if self:CanPlayDeflectAnim() then
		if BLOCK_ANIM == BLOCKED_STANDARD then
			ply:lscsPlayAnimation( "block"..math.random(1,3) ) -- TODO: allow this to be changed in combo file

		elseif BLOCK_ANIM == BLOCKED_STAGGER then
			ply:lscsPlayAnimation( table.Random( LSCS.ComboInterupt ) )
		else
			-- dont do shit
		end

		self:SetNextDeflectAnim( CurTime() + 0.1 )

		if BLOCK > LSCS_UNBLOCKED then
			if BLOCK == LSCS_BLOCK_PERFECT then
				ply:EmitSound( "saber_pblock" )
			else
				if BLOCK == LSCS_BLOCK_NONSABER then
					ply:EmitSound( "saber_lighthit" )
				else
					ply:EmitSound( "saber_block" )
				end
			end
		end
	end

	if BLOCK == LSCS_BLOCK_NONSABER then
		local damage = dmginfo:GetDamage()

		dmginfo:SetDamage( math.max(damage - self:GetBlockPoints(),0) )

		self:DrainBP( damage )
	else
		if BLOCK == LSCS_UNBLOCKED then
			self:DrainBP() -- prevent 0 bp regeneration

			return BLOCK
		end

		dmginfo:SetDamage( 0 )
	end

	local effectdata = EffectData()
		effectdata:SetOrigin( dmginfo:GetDamagePosition() )
		effectdata:SetNormal( Vector(0,0,1) )
	util.Effect( "saber_block", effectdata, true, true )

	return BLOCK
end

function SWEP:DeflectBullet( attacker, trace, dmginfo, bullet )
	local ply = self:GetOwner()

	if not IsValid( ply ) then return end

	if not self:CanDeflect() or self:IsThrown() then ply:lscsSetShouldBleed( true ) return end

	local Forward = ply:EyeAngles():Forward()
	local BulletForward = bullet.Dir

	if LSCS:AngleBetweenVectors( Forward, bullet.Dir ) < 60 then
		ply:lscsSetShouldBleed( true )

		dmginfo:SetDamageType( bit.bor( dmginfo:GetDamageType(), DMG_PREVENT_PHYSICS_FORCE, DMG_REMOVENORAGDOLL ) )

		return
	end

	if ply:lscsGetForce() <= 0 then
		ply:lscsSetShouldBleed( true )
		ply:lscsTakeForce() -- prevent regeneration while under fire

		return
	end

	local att = dmginfo:GetAttacker()

	if self:IsComboActive() then
		if LSCS.ComboInterupt[ self.LastAttack ] and ply:lscsKeyDown( IN_ATTACK ) and IsValid( att ) and att:IsPlayer() and LSCS.AttackInterruptable then
			ply:lscsSetShouldBleed( false )

			self:CancelCombo( 0.3 )

			ply:lscsSetTimedMove()

			ply:lscsPlayAnimation( LSCS.ComboInterupt[ self.LastAttack ] )

			self:SetNextDeflectAnim( CurTime() + 0.5 )

			self:PingPongBullet( ply, trace.HitPos - BulletForward  * 50, dmginfo, bullet )
		else
			ply:lscsSetShouldBleed( true )

			return
		end

		return
	end

	if self:CanPlayDeflectAnim() then
		ply:lscsPlayAnimation( "block"..math.random(1,3) ) -- TODO: allow this to be changed in combo file
	end

	self:PingPongBullet( ply, trace.HitPos - BulletForward  * 50, dmginfo, bullet )

	return true
end

function SWEP:PingPongBullet( ply, pos, dmginfo, original_bullet )
	if self:IsBrokenSaber() then -- If someone equips a saber with no hilt or blade just play animations. Its funny
		ply:lscsSetShouldBleed( true )
		return
	end

	ply:lscsTakeForce( math.Clamp(dmginfo:GetDamage() * LSCS.BulletForceDrainMul, LSCS.BulletForceDrainMin, LSCS.BulletForceDrainMax) )

	ply:lscsSetShouldBleed( false )

	ply:EmitSound( "saber_deflect_bullet" )

	local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		effectdata:SetNormal( Vector(0,0,1) )
	util.Effect( "saber_block", effectdata, true, true )

	if not ply:lscsKeyDown( IN_ATTACK ) and not self:IsComboActive()  then
		for _, Blockable in pairs( LSCS.BulletTracerDeflectable ) do
			if original_bullet.TracerName and string.match( original_bullet.TracerName, Blockable ) then
				local bullet = table.Copy( original_bullet )
				local aimpos = ply:GetEyeTrace().HitPos

				local effectdata = EffectData()
					effectdata:SetStart( pos )
					effectdata:SetOrigin( aimpos )
					effectdata:SetEntity( self )
				util.Effect( bullet.TracerName, effectdata, true, true )

				timer.Simple(0.05, function() -- dont deflect at the same frame. Prevent infinite loop when saber v saber bullet deflecting
					if not IsValid( ply ) or not IsValid( self ) then return end

					bullet.Num	= 1
					bullet.Attacker = ply
					bullet.TracerName = ""
					bullet.Tracer = 0
					bullet.Src		= pos
					bullet.Dir		= (aimpos - pos):GetNormalized()
					bullet.IgnoreEntity = ply

					ply:FireBullets( bullet )
				end)

				break -- we got him
			end
		end
	end

	dmginfo:SetDamage( 0 )
	dmginfo:SetDamageType( DMG_REMOVENORAGDOLL )
end

function SWEP:BlockDMGinfoBullet( dmginfo )
	local ply = self:GetOwner()

	if not IsValid( ply ) then return end

	if not self:CanDeflect() or self:IsThrown() then ply:lscsSetShouldBleed( true ) return end

	local Forward = ply:EyeAngles():Forward()
	local BulletForward = dmginfo:GetDamageForce():GetNormalized()

	if LSCS:AngleBetweenVectors( Forward, BulletForward ) < 60 then
		ply:lscsSetShouldBleed( true )

		return
	end

	if ply:lscsGetForce() <= 0 then
		ply:lscsSetShouldBleed( true )
		ply:lscsTakeForce() -- prevent regeneration while under fire

		return
	end

	local att = dmginfo:GetAttacker()

	if self:IsComboActive() then return end

	if self:CanPlayDeflectAnim() then
		ply:lscsPlayAnimation( "block"..math.random(1,3) )
	end

	ply:lscsTakeForce( math.Clamp(dmginfo:GetDamage() * LSCS.BulletForceDrainMul, LSCS.BulletForceDrainMin, LSCS.BulletForceDrainMax) )

	ply:EmitSound( "saber_deflect_bullet" )

	local effectdata = EffectData()
		effectdata:SetOrigin( dmginfo:GetDamagePosition() )
		effectdata:SetNormal( Vector(0,0,1) )
	util.Effect( "saber_block", effectdata, true, true )

	-- lets keep this method consistent
	dmginfo:SetDamage( 0 )
	dmginfo:SetDamageType( DMG_REMOVENORAGDOLL )

	return true
end

-- callback function. This should maybe call a hook or something i dont know yet. Keeping it in in case the entire saber system will be reworked to support interrupting again
function SWEP:OnBlocked( BLOCK )
end
