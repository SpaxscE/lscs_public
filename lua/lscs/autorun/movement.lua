-- should, in theory, keep prediction working while taking control away from the player. In reality, it doesnt, but its still better than ply:SetVelocity as it fixes teleporting issues on low tickrate/fps

local meta = FindMetaTable( "Player" )

hook.Add( "SetupMove", "!!!lscs_movementoverride", function( ply, mv, cmd )
	if not ply._lscsTimedMove then ply._lscsTimedMove = {} end

	if table.IsEmpty( ply._lscsTimedMove ) then return end

	local Move = Vector(0,0,0)
	local Time = CurTime()

	for id, obj in pairs( ply._lscsTimedMove ) do
		if (obj.start + obj.duration) <= Time then
			ply._lscsTimedMove[id] = nil
			continue
		end

		if obj.start <= Time then
			Move = Move + obj.move
		end
	end

	if ply:GetMoveType() ~= MOVETYPE_WALK then return end

	cmd:ClearMovement()

	mv:SetForwardSpeed( Move.x )
	mv:SetUpSpeed( Move.z )
	mv:SetSideSpeed( Move.y )

	cmd:SetForwardMove( Move.x )
	cmd:SetUpMove( Move.z )
	cmd:SetSideMove( Move.y )
end )

hook.Add( "PlayerFootstep", "!!!lscs_CustomFootstep", function( ply, pos, foot, sound, volume, rf )
	local weapon = ply:GetActiveWeapon()

	if IsValid( weapon ) and weapon.LSCS then
		if weapon:GetGestureTime() > CurTime() then
			return true
		end
	end
end )

function meta:lscsSetTimedMove( ID, time_start, time_duration, movement )
	self._lscsTimedMove[ ID ] = {
		start = time_start,
		duration = time_duration,
		move = movement,
	}
end

function meta:lscsClearTimedMove()
	if not self._lscsTimedMove then self._lscsTimedMove = {} end

	table.Empty( self._lscsTimedMove )
end
