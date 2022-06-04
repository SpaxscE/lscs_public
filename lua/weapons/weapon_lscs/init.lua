AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_combo.lua" )
AddCSLuaFile( "sh_animations.lua" )
include( "shared.lua" )
include("sh_combo.lua")
include("sh_animations.lua")

function SWEP:Reload()
	if (self.NextReload or 0) > CurTime() then return end

	self.NextReload = CurTime() + 1

	self:SetActive( not self:GetActive() )
end

function SWEP:OnRemove()
end
