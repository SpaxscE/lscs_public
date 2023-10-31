
if SERVER then
	util.AddNetworkString( "lscs_cancelattack" )

	function SWEP:CancelCombo( delay )
		self:SetNextPrimaryAttack( math.max(self:GetNextPrimaryAttack(),CurTime()) + (delay or 0) )

		self:FinishCombo()
		self:StopAnimation()

		net.Start( "lscs_cancelattack" )
			net.WriteEntity( self )
		net.Broadcast()
	end
else
	function SWEP:CancelCombo()
		self:FinishCombo()
		self:StopAnimation()
	end

	net.Receive( "lscs_cancelattack", function( len )
		local ent = net.ReadEntity()
		if not IsValid( ent ) or not ent.LSCS then return end

		ent:CancelCombo()
	end )
end

function SWEP:CurComboUnblockable()
	return self:GetAnimHasCancelAnim()
end

function SWEP:GetCombo()
	local CurStance = self:GetNWStance()

	if CurStance == -1 then
		return LSCS:GetStance( self:GetLockedCombo() )
	end

	local ply = self:GetOwner()

	if IsValid( ply ) then
		local combo = ply:lscsGetCombo()

		if CurStance > #combo then
			self:SetNWStance( 1 )
		end

		return LSCS:GetStance( combo[ self:GetNWStance() ] )
	else
		return LSCS:GetStance( "default" )
	end
end

function SWEP:GetComboObject( id )
	return self:GetCombo().Attacks[ id ]
end

function SWEP:StartCombo( ComboObj )
	self.AttackActive = true

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
	self.AttackActive = nil
	self.CurCombo = nil
	self.ComboStatus = nil
	self:FinishAttack()
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

			ProtectedCall( function() self.CurCombo.BeginFunc( self, ply ) end )

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

			ProtectedCall( function() self.CurCombo.FinishFunc( self, ply ) end )
			
			self:FinishCombo()
		end
	end
end

function SWEP:ComboThink()
	if self.CurCombo and self.ComboStatus then
		self:HandleCombo()
		
		local ply = self:GetOwner()

		if IsValid( ply ) then
			local ID = ply:LookupAttachment( "anim_attachment_RH" )
			local att = ply:GetAttachment( ID )

			if att then
				self:SetBlockPos( att.Pos )
			end
		end
	else
		self:SetBlockPos( Vector(0,0,0) )
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

	if not ply:lscsKeyDown( IN_SPEED ) and not ply:lscsKeyDown( IN_JUMP ) then
		if ATTACK_DIR == "____" or ATTACK_DIR == "W___" then
			if ply:EyeAngles().p > 15 then
				if self:GetComboObject( "+45+" ) then
					ATTACK_DIR = "+45+"
					Hack45Deg = true
				end

			elseif ply:EyeAngles().p < -15 then
				if self:GetComboObject( "-45-" ) then
					ATTACK_DIR = "-45-"
					Hack45Deg = true
				end
			else
				if ATTACK_DIR == "W___" then
					if self:GetComboObject(  "-45-" ) then
						ATTACK_DIR =  "-45-"
						Hack45Deg = true
					end
				end
			end
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

	self:PlayAnimation( ComboObj.AttackAnim, ComboObj.AttackAnimStart )

	local Time = CurTime() + ComboObj.Delay + ComboObj.Duration + 0.1
	self:SetNextPrimaryAttack( Time )
	self:SetGestureTime( Time )

	self.LastAttack = ATTACK_DIR

	if isstring( LSCS.ComboInterupt[ ATTACK_DIR ] ) then
		self:SetAnimHasCancelAnim( false )
	else
		self:SetAnimHasCancelAnim( true )
		self:DrainBP( 15 )
	end

	self:StartCombo( ComboObj )
end

function SWEP:IsComboActive()
	return self.ComboStatus ~= nil
end