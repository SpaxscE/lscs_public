
--SWEP.Base = "weapon_pvebase"
--DEFINE_BASECLASS( "weapon_pvebase" )
SWEP.Base = "weapon_base"

SWEP.Category			= "[LSCS]"

SWEP.PrintName		= "#lscsGlowstick"
SWEP.Author			= "Blu-x92 / Luna"

SWEP.ViewModel		= "models/weapons/c_arms.mdl"
SWEP.WorldModel		= "models/lscs/weapons/katarn.mdl"

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic		= false
SWEP.Secondary.Ammo		= "none"

SWEP.RenderGroup = RENDERGROUP_BOTH 

SWEP.AutoSwitchFrom = false

SWEP.LSCS = true

SWEP._tblHilt = {}
SWEP._tblBlade = {}

SWEP.HAND_RIGHT = 1
SWEP.HAND_LEFT = 2
SWEP.HAND_STRING = {
	[SWEP.HAND_RIGHT] = "RH",
	[SWEP.HAND_LEFT] = "LH",
}

SWEP.CachedSounds = {
	[SWEP.HAND_RIGHT]	= {
		AttackSound = "",
		AttackSound1 = "",
		AttackSound2 = "",
		AttackSound3 = "",
		ActivateSound = "",
		DisableSound = "",
		IdleSound = "",
	},
	[SWEP.HAND_LEFT] = {
		AttackSound = "",
		AttackSound1 = "",
		AttackSound2 = "",
		AttackSound3 = "",
		ActivateSound = "",
		DisableSound = "",
		IdleSound = "",
	},
}

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool",0, "Active" )
	self:NetworkVar( "Bool",1, "NWDMGActive" )
	self:NetworkVar( "Bool",2, "AnimHasCancelAnim" )

	self:NetworkVar( "Float",0, "NWNextAttack" )
	self:NetworkVar( "Float",1, "NWGestureTime" )
	self:NetworkVar( "Float",2, "Length" )
	self:NetworkVar( "Float",3, "ComboHits" )

	self:NetworkVar( "Int",0, "NWStance" )
	self:NetworkVar( "Int",1, "BlockPoints" )

	self:NetworkVar( "Vector",0, "BlockPos" )

	self:NetworkVar( "String",0, "HiltR")
	self:NetworkVar( "String",1, "HiltL")
	self:NetworkVar( "String",2, "BladeR")
	self:NetworkVar( "String",3, "BladeL")

	self:NetworkVar( "Entity",0, "Projectile" )

	if SERVER then
		self:SetNWStance( 1 )
	end
end

function SWEP:IsThrown()
	return IsValid( self:GetProjectile() )
end

function SWEP:GetHiltData( hand )
	local HiltR = self:GetHiltR()
	local HiltL = self:GetHiltL()

	if self._oldHiltR ~= HiltR then
		self._oldHiltR = HiltR

		local _HiltR = LSCS:GetHilt( HiltR )

		self._tblHilt[self.HAND_RIGHT] = _HiltR

		if CLIENT then
			self:UpdateWorldModel(self.HAND_RIGHT, _HiltR)
		end
	end

	if self._oldHiltL ~= HiltL then
		self._oldHiltL = HiltL

		local _HiltL = LSCS:GetHilt( HiltL )

		self._tblHilt[self.HAND_LEFT] = _HiltL

		if CLIENT then
			self:UpdateWorldModel(self.HAND_LEFT, _HiltL)
		end
	end

	if hand then
		return self._tblHilt[ hand ]
	else
		return self._tblHilt
	end
end

function SWEP:GetBladeData( hand )
	local BladeR = self:GetBladeR()
	local BladeL = self:GetBladeL()

	if self._oldBladeR ~= BladeR then
		self._oldBladeR = BladeR
		self._tblBlade[1] = LSCS:GetBlade( BladeR )
	end

	if self._oldBladeL ~= BladeL then
		self._oldBladeL = BladeL
		self._tblBlade[2] = LSCS:GetBlade( BladeL )
	end

	if hand then
		return self._tblBlade[ hand ]
	else
		return self._tblBlade
	end
end

function SWEP:BuildSounds()
	if self:IsBrokenSaber() then return end

	for hand = 1, 2 do
		local data = self:GetBladeData()[ hand ]

		if data then
			local SND = data.sounds

			self.CachedSounds[ hand ] = {
				AttackSound = (SND.Attack or ""),
				AttackSound1 = (SND.Attack1 or ""),
				AttackSound2 = (SND.Attack2 or ""),
				AttackSound3 = (SND.Attack3 or ""),
				ActivateSound = (SND.Activate or ""),
				DisableSound = (SND.Disable or ""),
				IdleSound = (SND.Idle or ""),
			}
		else
			self.CachedSounds[ hand ] = {
				AttackSound = "",
				AttackSound1 = "",
				AttackSound2 = "",
				AttackSound3 = "",
				ActivateSound = "",
				DisableSound = "",
				IdleSound = "",
			}
		end
	end
end

function SWEP:SetDMGActive( active )
	if SERVER then
		self:SetNWDMGActive( active )
	else
		self.b_dmgActive = active
	end
end

function SWEP:GetDMGActive()
	if CLIENT and not self:IsThrown() then
		if self:GetOwner() ~= LocalPlayer() then
			return self:GetNWDMGActive()
		else
			return self.b_dmgActive
		end
	else
		return self:GetNWDMGActive()
	end
end

function SWEP:SetNextPrimaryAttack( time )
	self:SetNWNextAttack( time )
	self.f_NextAttack = time
end

function SWEP:GetNextPrimaryAttack()
	if game.SinglePlayer() then
		return (self.f_NextAttack or 0) -- singleplayer IS a prediction error
	else
		return math.max( (self.f_NextAttack or 0), self:GetNWNextAttack()) -- first variable is for prediction, second variable for correcting when the server responds.
	end
end

function SWEP:CanPrimaryAttack()
	return self:GetNextPrimaryAttack() < CurTime()
end

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self:DrawShadow( false )
	self:SetNextPrimaryAttack( CurTime() + 1 )
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
	if self:IsThrown() then return end

	local CurStance = self:GetNWStance()

	if CurStance == -1 then return end

	self:SetNWStance( CurStance + 1 )
end

function SWEP:DoAttackSound( N, hand )
	if not self:GetDMGActive() then return end

	if hand then
		if hand == self.HAND_LEFT and not self:GetCombo().LeftSaberActive then return end -- this is gay

		if N then
			if N == 1 then
				self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound1 )
			elseif N == 2 then
				self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound2 )
			elseif N == 3 then
				self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound3 )
			else
				self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound )
			end
		else
			self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound )
		end
	else
		for hand = self.HAND_RIGHT, self.HAND_LEFT do
			if hand == self.HAND_LEFT and not self:GetCombo().LeftSaberActive then continue end -- this is gay

			if N then
				if N == 1 then
					self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound1 )
				elseif N == 2 then
					self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound2 )
				elseif N == 3 then
					self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound3 )
				else
					self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound )
				end
			else
				self:EmitSoundUnpredicted( self.CachedSounds[ hand ].AttackSound )
			end
		end
	end
end

function SWEP:Holster( wep )
	self:SetActive( false )
	self:SetLength( 0 )

	self:FinishCombo()

	self:Think()

	if SERVER then
		local ply = self:GetOwner()
		if IsValid( ply ) and ply:IsPlayer() then
			ply:lscsSetShouldBleed( true )
		end
	end

	return true
end

function SWEP:BeginAttack()
	self:SetDMGActive( true )
end

function SWEP:FinishAttack()
	self:SetDMGActive( false )

	local ply = self:GetOwner()
	if IsValid( ply ) then
		ply:lscsClearTimedMove()
		ply:Freeze( false )
	end

	self:SetBlockPos( Vector(0,0,0) )
end

function SWEP:Deploy()
	return true
end

function SWEP:OwnerChanged()
end

function SWEP:IsBrokenSaber()
	if not self._IsBroken then
		local Hilt1 = self:GetHiltR() == "" and 0 or 1
		local Hilt2 = self:GetHiltL() == "" and 0 or 1
		local Blade1 = self:GetBladeR() == "" and 0 or 1
		local Blade2 = self:GetBladeL() == "" and 0 or 1

		self._IsBroken = ((Hilt1 + Blade1) ~= 2 and (Hilt2 + Blade2) ~= 2)
	end

	return self._IsBroken
end

function SWEP:Think()
	self:ComboThink()

	local Active = self:GetActive()
	local Stance = self:GetStance()

	local FT = FrameTime()
	local Length = self:GetLength()

	self:SetLength( Length + math.Clamp((Active and 1 or 0) - Length,-FT * 1.5,FT * 3) )

	if Active ~= self.OldActive then
		self.OldActive = Active

		if Active then
			self:BuildSounds()

			self:SetHoldType( self:GetCombo().HoldType )

			self:EmitSoundUnpredicted( self.CachedSounds[1].ActivateSound )

			if self:GetCombo().LeftSaberActive then
				self:EmitSoundUnpredicted( self.CachedSounds[2].ActivateSound )
			end
		else
			self:SetHoldType( "normal" )

			self:EmitSoundUnpredicted( self.CachedSounds[1].DisableSound )

			if self:GetCombo().LeftSaberActive then
				self:EmitSoundUnpredicted( self.CachedSounds[2].DisableSound )
			end
		end

		self:OnActiveChanged( self.OldActive, Active )
	end

	if Stance ~= self.OldStance then
		if self:GetActive() then
			self:SetHoldType( self:GetCombo().HoldType )
		end

		self.OldStance = Stance
	end
	
	self:OnTick( Active )
end

function SWEP:AimDistanceTo( _pos )
	local ply = self:GetOwner()

	if not IsValid( ply ) then return 0 end

	local Pos = ply:lscsGetViewOrigin()
	local EndPos = Pos + ply:EyeAngles():Forward() * 500

	return util.DistanceToLine( Pos, EndPos, _pos )
end

function SWEP:GetBlockDistanceTo( _pos )
	local ply = self:GetOwner()

	if not IsValid( ply ) then return 100 end

	local BlockDistance = self:AimDistanceTo( _pos )

	if ply:WorldToLocal( _pos ).x < 0 then
		BlockDistance = 100
	end

	return BlockDistance
end