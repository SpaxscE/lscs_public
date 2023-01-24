
function SWEP:GetBPDrainPerHit()
	return (self:GetCombo().BPDrainPerHit or 25)
end

function SWEP:GetMaxBlockPoints()
	local combo = self:GetCombo()

	return (combo.MaxBlockPoints or 100)
end

function SWEP:GetBlockDistanceNormal()
	return (self:GetCombo().BlockDistanceNormal or 60)
end

function SWEP:GetBlockDistancePerfect()
	return (self:GetCombo().BlockDistancePerfect or 20)
end

function SWEP:DrainBP( amount )
	if amount then
		self:SetBlockPoints( math.Clamp( self:GetBlockPoints() - amount,0, self:GetMaxBlockPoints()) )

		if amount > 0 then
			self.NextBPr = CurTime() + 2
		end
	else
		self.NextBPr = CurTime() + 2
	end
end

if SERVER then
	function SWEP:CalcBPRegen( CurTime )
		local ply = self:GetOwner()

		if not IsValid( ply ) then return end

		if (self.NextBPr or 0) < CurTime then
			self.NextBPr = CurTime + 0.3

			local MaxVal = self:GetMaxBlockPoints()
			if self:GetGestureTime() < CurTime and ply:OnGround() and ply:GetVelocity():Length() < 225 then
				self:SetBlockPoints( self:GetBlockPoints() + math.min(MaxVal - self:GetBlockPoints(),3) )
			else
				if not ply:OnGround() then
					self:DrainBP( 1 )
				end
			end
		end

		if self._ResetHitTime and self._ResetHitTime < CurTime then
			self._ResetHitTime = CurTime + 1

			self:AddHit( -0.1 )
		end
	end
end