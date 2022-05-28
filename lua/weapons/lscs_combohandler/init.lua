AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function SWEP:Reload()
	if (self.NextReload or 0) > CurTime() then return end

	self.NextReload = CurTime() + 1

	self:SetActive( not self:GetActive() )
end

function SWEP:Think()
	local Active = self:GetActive()
	local ply = self:GetOwner()

	if Active ~= self.OldActive then
		self.OldActive = Active

		if Active then
			self:SetHoldType( ply:lscsGetCombo().HoldType )

			--self.Owner:EmitSound( "saber_turnon" )
		else
			self:SetHoldType( "normal" )

			--self.Owner:EmitSound( "saber_turnoff" )
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
