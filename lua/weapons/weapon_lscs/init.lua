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

function SWEP:OnActiveChanged( oldActive, active )
	if oldActive == nil then return end

	if not self.IdleSound then return end

	if active then
		self.SaberHumSound = CreateSound(self, self.IdleSound)
		self.SaberHumSound:Play()
	else
		self:StopIdleSound()
	end
end

function SWEP:OnTick( active )
	local CurTime = CurTime()

	if (self.Next_Think or 0) > CurTime then return end

	if self.SaberHumSound then
		local go = self:GetDMGActive()

		self.SaberHumSound:ChangeVolume( go and 0 or 1, 0.2 )
		self.SaberHumSound:ChangePitch( go and 130 or 100, 0.15 )
	end

	self.Next_Think = CurTime + 0.05
end

function SWEP:StopIdleSound()
	if self.SaberHumSound then
		self.SaberHumSound:Stop()
		self.SaberHumSound = nil
	end
end

function SWEP:OnRemove()
	self:StopIdleSound()
end
