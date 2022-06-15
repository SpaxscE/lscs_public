
local meta = FindMetaTable( "Player" )

if SERVER then
	util.AddNetworkString( "lscs_animations" )

	function meta:lscsPlayAnimation( anim )
		net.Start( "lscs_animations" )
			net.WriteEntity( self )
			net.WriteBool( false )
			net.WriteString( anim )
		net.Broadcast()
	end
else
	-- just some gesture smoothing taken directly from my Jedi Academy saber. If someone has an idea how to replace the think player.getall please tell me. 
	-- In real tests this never made a difference in performance as the blade rendering is 10000 times worse than this
	hook.Add("Think", "!!!!lscs_unforgiveable_playerGetAll_loop_in_think_hook", function()
		local FT = FrameTime()
		local FT10 = FT * 10

		local Time = CurTime() 

		for _, ply in ipairs( player.GetAll() ) do
			local weapon = ply:GetActiveWeapon()

			if IsValid( weapon ) and weapon.LSCS then
				ply._lscsResetGestures = true

				local TargetWeight = weapon:GetGestureTime() > Time and 1 or 0
				ply._smGestureWeight = ply._smGestureWeight and ply._smGestureWeight + math.Clamp(TargetWeight - ply._smGestureWeight,-FT * 4,FT10) or 0
				ply:AnimSetGestureWeight( GESTURE_SLOT_ATTACK_AND_RELOAD, ply._smGestureWeight )

				local VCDWeight = ((ply.__sm_lscsVCD or 0) < Time) and 0 or (1 - ply._smGestureWeight)
				ply.__sm_lscsVCDWeight = ply.__sm_lscsVCDWeight and ply.__sm_lscsVCDWeight + math.Clamp(VCDWeight - ply.__sm_lscsVCDWeight,-FT10,FT10) or 0
				ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, ply.__sm_lscsVCDWeight )
			else
				if ply._lscsResetGestures then -- in case some other addon uses these slots. Lets not take them hostage by having weight set to 0
					ply._lscsResetGestures = nil
					ply.__sm_lscsVCD = nil

					ply:AnimSetGestureWeight( GESTURE_SLOT_ATTACK_AND_RELOAD, 1 )
					ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )

					ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, 1 )
					ply:AnimResetGestureSlot( GESTURE_SLOT_VCD )
				end
			end
		end
	end)

	net.Receive( "lscs_animations", function( len )
		local ply = net.ReadEntity()

		if not IsValid( ply ) then return end

		local IsAttackAnim = net.ReadBool()

		local seq = net.ReadString()

		if IsAttackAnim then
			local start = tonumber( net.ReadString() )

			if ply == LocalPlayer() then
				if ply.s_vcd_anim ~= seq then
					-- this should only get called when a prediction error occurs or while in singleplayer/as host
					ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD, ply:LookupSequence( seq ), start, true )
				end
			else
				ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD, ply:LookupSequence( seq ),start, true )
			end
		else
			local seqid = ply:LookupSequence( seq )

			ply.__sm_lscsVCD = CurTime() + 0.5
			ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_VCD, seqid,0, false )
		end
	end )
end
