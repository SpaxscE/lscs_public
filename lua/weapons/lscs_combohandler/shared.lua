
--SWEP.Base = "weapon_pvebase"
--DEFINE_BASECLASS( "weapon_pvebase" )
SWEP.Base = "weapon_base"

SWEP.Category			= "[LSCS]"

SWEP.PrintName		= "Sword Combat"
SWEP.Author			= "Blu-x92 / Luna"

SWEP.ViewModel		= ""
SWEP.WorldModel		= "models/error.mdl"

SWEP.Spawnable		= false
SWEP.AdminOnly		= false

SWEP.Primary.Automatic	= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo	= "none"

SWEP.RenderGroup = RENDERGROUP_BOTH 

SWEP.LSCS = true

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity",1, "hiltLH" )
	self:NetworkVar( "Entity",2, "hiltRH" )

	self:NetworkVar( "Bool",0, "Active" )
	self:NetworkVar( "Bool",1, "DMGActive" )
end

function SWEP:SetGestureTime( time )
	self.f_NextGesture = time
end

function SWEP:GetGestureTime()
	return self.f_NextGesture or 0
end

function SWEP:Initialize()
	self:SetHoldType( "normal" )
	self:DrawShadow( false )
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Holster( wep )
	return true
end

function SWEP:Deploy()
	return true
end

function SWEP:OwnerChanged()
end
