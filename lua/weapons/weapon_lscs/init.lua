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

function SWEP:Think()
	self:ComboThink()

	local Active = self:GetActive()

	if Active ~= self.OldActive then
		self.OldActive = Active

		if Active then
			self:SetHoldType( self:GetCombo().HoldType )
		else
			self:SetHoldType( "normal" )
		end
	end
end

function SWEP:OnRemove()
end

function SWEP:EmitSoundUnpredicted( name )
	-- dirty... but works. Its the only easy way i know how to break prediction
	timer.Simple(0, function()
		if not IsValid( self ) then return end
		self:EmitSound( name )
	end)
end
