-- alternative to ply:SetVelocity. Much smoother client experience

local meta = FindMetaTable( "Player" )

if CLIENT then
	hook.Add( "CreateMove", "!!!lscs_movementoverride", function( cmd )
		local ply = LocalPlayer()

		if not ply._lscsTimedMove then ply._lscsTimedMove = {} end

		local Time = CurTime()

		if ply._lscsWalkTime then
			if ply._lscsWalkTime < CurTime() then
				ply._lscsWalkTime = nil
			else
				local max = ply:GetSlowWalkSpeed()

				cmd:SetForwardMove( math.Clamp( cmd:GetForwardMove(), -max, max ) )
				cmd:SetUpMove( math.Clamp( cmd:GetUpMove(), -max, max ) )
				cmd:SetSideMove( math.Clamp( cmd:GetSideMove(), -max, max ) )

				return
			end
		end

		if ply:InVehicle() or table.IsEmpty( ply._lscsTimedMove ) then return end

		local Move

		for id, obj in pairs( ply._lscsTimedMove ) do
			if (obj.start + obj.duration) <= Time then
				ply._lscsTimedMove[id] = nil
				continue
			end

			if obj.start <= Time then
				if not Move then
					Move = obj.move
				else
					Move = Move + obj.move
				end
			end
		end

		if not Move then return end

		if ply:GetMoveType() ~= MOVETYPE_WALK then return end

		cmd:ClearMovement()

		cmd:SetForwardMove( Move.x )
		cmd:SetUpMove( Move.z )
		cmd:SetSideMove( Move.y )
	end )

	function meta:lscsSetTimedMove( ID, time_start, time_duration, movement )
		self._lscsTimedMove[ ID ] = {
			start = time_start,
			duration = time_duration,
			move = movement,
		}
	end

	net.Receive( "lscs_nw_movement", function( len )
		local DoWhat = net.ReadBool()

		if DoWhat then
			LocalPlayer():lscsSetTimedMove( -1, CurTime(), 0.5, Vector(0,0,0) )
		else
			local DoHowLong = net.ReadFloat()

			LocalPlayer()._lscsWalkTime = CurTime() + DoHowLong
		end
	end)
else
	util.AddNetworkString( "lscs_nw_movement" )

	function meta:lscsSetTimedMove( ID )
		if ID then return end

		net.Start( "lscs_nw_movement" )
			net.WriteBool( true )
		net.Send( self )
	end

	function meta:lscsForceWalk( seconds )
		net.Start( "lscs_nw_movement" )
			net.WriteBool( false )
			net.WriteFloat( seconds )
		net.Send( self )
	end
end

hook.Add( "PlayerFootstep", "!!!lscs_CustomFootstep", function( ply, pos, foot, sound, volume, rf )
	local weapon = ply:GetActiveWeapon()

	if IsValid( weapon ) and weapon.LSCS then
		if weapon:GetGestureTime() > CurTime() then
			return true
		end
	end
end )

function meta:lscsClearTimedMove()
	if not self._lscsTimedMove then self._lscsTimedMove = {} end

	for ID, _ in pairs( self._lscsTimedMove ) do
		if ID ~= -1 then
			self._lscsTimedMove[ ID ] = nil
		end
	end
end
