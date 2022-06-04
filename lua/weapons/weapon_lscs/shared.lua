
--SWEP.Base = "weapon_pvebase"
--DEFINE_BASECLASS( "weapon_pvebase" )
SWEP.Base = "weapon_base"

SWEP.Category			= "[LSCS]"

SWEP.PrintName		= "#lscsGlowstick"
SWEP.Author			= "Blu-x92 / Luna"

SWEP.ViewModel		= "models/weapons/c_arms.mdl"
SWEP.WorldModel		= "models/props_junk/PopCan01a.mdl"

SWEP.Spawnable		= false
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

SWEP.LSCS = true

SWEP._tblHilt = {}
SWEP._tblBlade = {}

SWEP.HAND_RIGHT = 1
SWEP.HAND_LEFT = 2
SWEP.HAND_STRING = {
	[SWEP.HAND_RIGHT] = "RH",
	[SWEP.HAND_LEFT] = "LH",
}

SWEP.AttackSound = "weapons/iceaxe/iceaxe_swing1.wav"
SWEP.ActivateSound = ""
SWEP.DisableSound = ""
SWEP.IdleSound = ""

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool",0, "Active" )
	self:NetworkVar( "Bool",1, "NWDMGActive" )

	self:NetworkVar( "Float",0, "NWNextAttack" )
	self:NetworkVar( "Float",1, "NWGestureTime" )

	self:NetworkVar( "String",0, "HiltR")
	self:NetworkVar( "String",1, "HiltL")
	self:NetworkVar( "String",2, "BladeR")
	self:NetworkVar( "String",3, "BladeL")
end

function SWEP:GetHiltData()
	local HiltR = self:GetHiltR()
	local HiltL = self:GetHiltL()

	if self._oldHiltR ~= HiltR then
		self._oldHiltR = HiltR
		self._HiltR = LSCS:GetHilt( HiltR )

		self._tblHilt[self.HAND_RIGHT] = self._HiltR

		if CLIENT then
			self:UpdateWorldModel(self.HAND_RIGHT, self._HiltR)
		end
	end

	if self._oldHiltL ~= HiltL then
		self._oldHiltL = HiltL
		self._HiltL = LSCS:GetHilt( HiltL )

		self._tblHilt[self.HAND_LEFT] = self._HiltR

		if CLIENT then
			self:UpdateWorldModel(self.HAND_LEFT, self._HiltL)
		end
	end

	return self._tblHilt
end

function SWEP:GetBladeData()
	local BladeR = self:GetBladeR()
	local BladeL = self:GetBladeL()

	if self._oldBladeR ~= BladeR then
		self._oldBladeR = BladeR
		self._BladeR = LSCS:GetBlade( BladeR )

		self._tblBlade[1] = self._BladeR
	end

	if self._oldBladeL ~= BladeL then
		self._oldBladeL = BladeL
		self._BladeL = LSCS:GetBlade( BladeL )

		self._tblBlade[2] = self._BladeL
	end

	return self._tblBlade
end

function SWEP:BuildSounds()
	for _, data in pairs( self:GetBladeData() ) do
		local SND = data.sounds
		if SND then
			self.AttackSound = SND.Attack
			self.ActivateSound = SND.Activate
			self.DisableSound = SND.Disable
			self.IdleSound = SND.Idle
			break
		end
	end
end

function SWEP:SetDMGActive( active )
	self.b_dmgActive = active
	if SERVER then
		self:SetNWDMGActive( active )
	end
end

function SWEP:GetDMGActive()
	if CLIENT then
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
	return math.max( (self.f_NextAttack or 0), self:GetNWNextAttack())
end

function SWEP:CanPrimaryAttack()
	return self:GetNextPrimaryAttack() < CurTime()
end

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self:DrawShadow( false )
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:DoAttackSound()
	self:EmitSound( self.AttackSound )
end

function SWEP:Holster( wep )
	self:SetActive( false )

	self:FinishCombo()

	self:Think()

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
	end
end

function SWEP:Deploy()
	return true
end

function SWEP:OwnerChanged()
end

function SWEP:Think()
	self:ComboThink()

	local Active = self:GetActive()

	if Active ~= self.OldActive then
		self.OldActive = Active

		if Active then
			self:BuildSounds()

			self:SetHoldType( self:GetCombo().HoldType )
			self:EmitSound( self.ActivateSound )
		else
			self:SetHoldType( "normal" )
			self:EmitSound( self.DisableSound )
		end
	end
end

