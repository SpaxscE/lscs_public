-- alternative to ply:SetVelocity. Much smoother client experience

local meta = FindMetaTable( "Player" )

if CLIENT then
	hook.Add( "CreateMove", "!!!lscs_movementoverride", function( cmd )
		local ply = LocalPlayer()

		if not ply._lscsTimedMove then ply._lscsTimedMove = {} end

		if ply:InVehicle() or table.IsEmpty( ply._lscsTimedMove ) then return end

		local Move
		local Time = CurTime()

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
else
	-- todo: verify movement on server using startcommand so people cant cheat with cs lua on

	function meta:lscsSetTimedMove()
		-- todo: add networking in case this is only called serverside
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

	table.Empty( self._lscsTimedMove )
end
