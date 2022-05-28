hook.Add( "SetupMove", "!!!lscs_movementoverride", function( ply, mv, cmd )
	local wep = ply:GetActiveWeapon()

	if not IsValid( wep ) or not wep.LSCS then return end

	local Move = wep:GetMove()
	if Move:Length() == 0 then return end

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