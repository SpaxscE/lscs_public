
if SERVER then
	util.AddNetworkString( "lscs_animations" )
else

	hook.Add("Think", "!!!!lscs_unforgiveable_playerGetAll_loop_in_think_hook", function()
		local FT = FrameTime()

		for _, ply in ipairs( player.GetAll() ) do
			local weapon = ply:GetActiveWeapon()

			if IsValid( weapon ) and weapon.LSCS then
				local TargetWeight = weapon:GetGestureTime() > CurTime() and 1 or 0

				ply._smGestureWeight = ply._smGestureWeight and ply._smGestureWeight + math.Clamp(TargetWeight - ply._smGestureWeight,-FT * 4,FT * 10) or 0

				ply:AnimSetGestureWeight( GESTURE_SLOT_ATTACK_AND_RELOAD, ply._smGestureWeight )
			end
		end
	end)

	net.Receive( "lscs_animations", function( len )
		local ply = net.ReadEntity()
		
		if not IsValid( ply ) then return end

		local seq = net.ReadString()

		if ply == LocalPlayer() then
			if ply.s_vcd_anim ~= seq then
				ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD, ply:LookupSequence( seq ),0, true )
			end
		else
			ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD, ply:LookupSequence( seq ),0, true )
		end
	end )
end
