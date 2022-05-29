
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

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool",0, "Active" )
	self:NetworkVar( "Bool",1, "NWDMGActive" )

	self:NetworkVar( "Float",0, "NWNextAttack" )
	self:NetworkVar( "Float",1, "NWGestureTime" )

	self:NetworkVar( "Vector",1, "BladeColor" )

	self:NetworkVar( "String",0, "MDL")

	if SERVER then
		self:SetMDL( "models/lscs/weapons/katarn.mdl" )
		self:SetBladeColor( Vector(0,65,255) )
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
end

function SWEP:Holster( wep )
	self:SetActive( false )

	self:FinishCombo()

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
