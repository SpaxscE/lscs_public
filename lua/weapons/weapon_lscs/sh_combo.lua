
function SWEP:GetCombo()
	local ply = self:GetOwner()

	if IsValid( ply ) then
		return ply:lscsGetCombo()
	else
		return LSCS:GetStance( "default" )
	end
end

function SWEP:GetComboObject( id )
	return self:GetCombo().Attacks[ id ]
end

function SWEP:StartCombo( ComboObj )
	local Time = CurTime()
	self.ComboStatus = 1
	self.CurCombo = {
		BeginTime = Time + ComboObj.Delay,
		BeginFunc = ComboObj.BeginAttack,
		SwingTime = ComboObj.Duration,
		FinishFunc = ComboObj.FinishAttack,
		FinishTime = (Time + ComboObj.Duration + ComboObj.Delay),
	}
end

function SWEP:FinishCombo()
	self.CurCombo = nil
	self.ComboStatus = nil
	self:FinishAttack()

	local ply = self:GetOwner()
	if IsValid( ply ) then
		ply:Freeze( false )
	end
end

function SWEP:HandleCombo()
	local Time = CurTime()
	local ply = self:GetOwner()

	if not IsValid( ply ) then
		self:FinishCombo()
		return
	end

	if self.ComboStatus == 1 then
		if self.CurCombo.BeginTime <= Time then
			self:BeginAttack()
			self.CurCombo.BeginFunc(self.CurCombo, self)
			self.ComboStatus = 2
		end
	end

	if self.ComboStatus == 2 then
		if (self.CurCombo.BeginTime + self.CurCombo.SwingTime) * 0.7 <= Time then
			self.ComboStatus = 3
		end
	end

	if self.ComboStatus == 3 then
		if self.CurCombo.FinishTime <= Time then
			self.CurCombo.FinishFunc(self.CurCombo, self)

			ply:Freeze( false )

			self:FinishCombo()
		end
	end
end

function SWEP:ComboThink()
	if self.CurCombo and self.ComboStatus then
		self:HandleCombo()
	end

	local ply = self:GetOwner()

	if IsValid( ply ) then
		if ply:lscsKeyDown( IN_ATTACK ) then
			self:DoCombo()
		end
	end
end

function SWEP:DoCombo()
	if not self:CanPrimaryAttack() then return end

	self:FinishCombo()

	local ply = self:GetOwner()

	local W = ply:lscsKeyDown( IN_FORWARD ) and "W" or "_"
	local A = ply:lscsKeyDown( IN_MOVELEFT ) and "A" or "_"
	local S = ply:lscsKeyDown( IN_BACK ) and "S" or "_"
	local D = ply:lscsKeyDown( IN_MOVERIGHT ) and "D" or "_"

	local ATTACK_DIR = W..A..S..D
	local Hack45Deg = false -- hack45Deg  is used so +45+ and -45- is counted as ___ so you can not switch between those to get a quickswing

	if ATTACK_DIR == "____" or ATTACK_DIR == "W___" then
		if ply:EyeAngles().p > 30 then
			ATTACK_DIR = "+45+"
			Hack45Deg = true
		end
		if ply:EyeAngles().p < -30 then
			ATTACK_DIR = "-45-"
			Hack45Deg = true
		end
	end

	if not ply:OnGround() then
		if self.LastAttack == "BACKFLIP" and (self:GetNextPrimaryAttack() + 0.5) > CurTime() then
			ATTACK_DIR = "SLAM"
		else
			if ply:lscsKeyDown( IN_JUMP ) then
				if ATTACK_DIR == "W___" then
					ATTACK_DIR = "FRONT_DASH"
				end

				if ATTACK_DIR == "__S_" then
					ATTACK_DIR = "BACKFLIP"
				end

				if ATTACK_DIR == "_A__" then
					ATTACK_DIR = "ROLL_LEFT"
				end

				if ATTACK_DIR == "___D" then
					ATTACK_DIR = "ROLL_RIGHT"
				end
			end
		end
	end

	self:SetActive( true )

	local ComboObj = self:GetComboObject( ATTACK_DIR )

	if not ComboObj then
		ComboObj = self:GetComboObject( "____" )
		ATTACK_DIR = "____"
	end

	if Hack45Deg then
		ATTACK_DIR = "____"
	end

	if self.LastAttack then
		local A = string.Explode( "", ATTACK_DIR )
		local B = string.Explode( "", self.LastAttack )

		if self.LastAttack == ATTACK_DIR or A[2] == B[2] or A[4] == B[4] or self.LastAttack == "____" then
			if (self:GetNextPrimaryAttack() + 0.5) > CurTime() then
				return
			end
		end
	end

	self:PlayAnimation( ComboObj.AttackAnim )

	local Time = CurTime() + ComboObj.Delay + ComboObj.Duration + 0.1
	self:SetNextPrimaryAttack( Time )
	self:SetGestureTime( Time )

	self.LastAttack = ATTACK_DIR

	--[[
	local BlockPos = self.BlockPos[ ATTACK_DIR ]
	if not BlockPos then
		BlockPos = self.BlockPos[ "____" ]
	end
	self:SetBlockPos( BlockPos )
	]]

	self:StartCombo( ComboObj )
end