AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_combo.lua" )
include( "shared.lua" )
include("sh_combo.lua")

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
	local Hilt1 = self:GethiltLH()
	local Hilt2 = self:GethiltRH()

	if IsValid( Hilt1 ) then
		Hilt1:Remove()
	end

	if IsValid( Hilt2 ) then
		Hilt2:Remove()
	end
end

function SWEP:OnRemove()
	local Hilt1 = self:GethiltLH()
	local Hilt2 = self:GethiltRH()

	if IsValid( Hilt1 ) then
		Hilt1:Remove()
	end

	if IsValid( Hilt2 ) then
		Hilt2:Remove()
	end
end
