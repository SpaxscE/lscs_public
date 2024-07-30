
if SERVER then
	util.AddNetworkString( "lscs_force_anims" )
	util.AddNetworkString( "lscs_force_use" )
	util.AddNetworkString( "lscs_start_jump" )

	function LSCS:PlayVCDSequence( ply, anim, start )
		start = start or 0

		if not IsValid( ply ) then return end

		net.Start( "lscs_force_anims" ) 
			net.WriteEntity( ply )
			net.WriteString( anim )
			net.WriteFloat( start )
		net.Broadcast()

		ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_GRENADE, ply:LookupSequence( anim ), start, true )
	end

	function LSCS:ForceApply( Ent, Vel, att )
		if Ent.Alive and not Ent:Alive() then return end
		if Ent.GetObserverMode and Ent:GetObserverMode() ~= OBS_MODE_NONE then return end

		if hook.Run( "LSCS:PlayerCanManipulate", att, Ent ) then return end

		local StartPos = att:GetShootPos()
		local EndPos = Ent:LocalToWorld( Ent:OBBCenter() )

		local tr = util.TraceLine( {
			start = StartPos,
			endpos = EndPos,
			mask = MASK_SHOT,
			filter = att,
		} )

		if tr.Entity ~= Ent then return end

		if Ent.loco then
			Ent:SetPos( Ent:GetPos() + Vector(0,0,50) )
			Ent.loco:SetVelocity( Vel )
			local effectdata = EffectData()
				effectdata:SetOrigin( Ent:GetPos() )
				effectdata:SetEntity( Ent )
			util.Effect( "force_effects", effectdata, true, true )
		else
			local Phys = Ent:GetPhysicsObject()

			if IsValid( Phys ) and not Ent:IsPlayer() then
				Ent:SetPhysicsAttacker( att, 5 )

				if Phys:IsMotionEnabled() and Ent:GetMoveType() ~= MOVETYPE_NONE then
					Phys:Wake()

					if Ent:GetClass() == "prop_ragdoll" then
						for i = 1, Ent:GetPhysicsObjectCount() do
							local bone = Ent:GetPhysicsObjectNum( i )

							if bone and bone.IsValid and bone:IsValid() then
								bone:AddVelocity(  Vel )
							end
						end
					else
						if Ent:IsNPC() and Ent:GetMoveType() == MOVETYPE_STEP then
							local d = DamageInfo()
							d:SetDamage( 50 )
							d:SetDamageForce( Vel * 100 )
							d:SetAttacker( att )
							d:SetDamageType( DMG_CRUSH ) 
							d:SetDamagePosition( EndPos )

							Ent:TakeDamageInfo( d )
						else
							Phys:SetVelocity( Vel )
						end
					end

					local effectdata = EffectData()
						effectdata:SetOrigin( Ent:GetPos() )
						effectdata:SetEntity( Ent )
					util.Effect( "force_effects", effectdata, true, true )
				end
			else
				if Ent.IsPlayer and Ent:IsPlayer() then
					local effectdata = EffectData()
						effectdata:SetOrigin( Ent:GetPos() )
						effectdata:SetEntity( Ent )
					util.Effect( "force_effects", effectdata, true, true )

					if Ent:OnGround() then
						Ent:SetPos( Ent:GetPos() + Vector(0,0,10) )
					end

					Ent:SetVelocity( Vel )
				end
			end
		end
	end

	hook.Add( "StartCommand", "!!!!!!lscs_forcejumpforcer", function( ply, cmd )
		if (ply._lscsForceJumpTime or 0) > CurTime() then
			cmd:SetButtons( bit.bor( cmd:GetButtons(), IN_JUMP ) )
		end
	end )

	local TICK_MIN = 1/14
	local NEXT_THINK = 0

	hook.Add( "Think", "!!!!lscs_unforgiveable_playerGetAll_loop_in_think_hook", function()
		local TIME = CurTime()

		if FrameTime() <= TICK_MIN then -- below this tickrate we run risk skipping the correct timing...
			if NEXT_THINK > TIME then return end

			NEXT_THINK = TIME + 0.1 -- slow it down to be nice to the server. The HUD is specifically designed to mask this slow updating.
		end

		for _, ply in ipairs( player.GetAll() ) do
			hook.Run( "LSCS:PlayerForcePowerThink", ply, TIME )

			if (ply._lscsNextForceRegen or 0) > TIME then continue end

			if not ply:InVehicle() then
				if not ply:OnGround() and ply:GetMoveType() ~= MOVETYPE_NOCLIP then continue end
			end

			ply:lscsSetForce( math.min(ply:lscsGetForce() + ply:lscsGetForceRegenAmount(),ply:lscsGetMaxForce()) )
		end
	end )

	net.Receive( "lscs_force_use", function( len, ply )
		if not IsValid( ply ) then return end
		if not ply:Alive() then return end

		if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end

		local ID = net.ReadInt( 8 )
		local Activate = net.ReadBool()
		local ForcePowers = ply:lscsGetForceAbilities()

		local selectedF = ForcePowers[ ID ]

		if not selectedF then return end

		local item = selectedF.item

		if not item then return end

		if not ply._lscsUsedPowers then
			ply._lscsUsedPowers = {}
		end

		if Activate then
			ply._lscsUsedPowers[ ID ] = true

			ProtectedCall( function() LSCS.Force[ item.id ].StartUse( ply ) end )
		else
			if ply._lscsUsedPowers[ ID ] then
				ply._lscsUsedPowers[ ID ] = nil

				ProtectedCall( function() LSCS.Force[ item.id ].StopUse( ply ) end )
			end
		end
	end )

	hook.Add( "LSCS:OnPlayerEquippedItem", "!!!!lscs_forcepower_equip_handler", function( ply, item )
		if not IsValid( ply ) or not item then return end

		if item.type == "force" then
			ProtectedCall( function() LSCS.Force[ item.id ].Equip( ply ) end )
		end
	end)

	hook.Add( "LSCS:OnPlayerUnEquippedItem", "!!!!lscs_forcepower_unequip_handler", function( ply, item )
		if not IsValid( ply ) or not item then return end

		if item.type == "force" then
			ProtectedCall( function() LSCS.Force[ item.id ].UnEquip( ply ) end )
		end
	end)

	hook.Add( "PlayerDeath", "!!!!lscs_forcepower_playerdeath", function( ply )
		if not ply._lscsUsedPowers then return end

		local ForcePowers = ply:lscsGetForceAbilities()

		net.Start("lscs_force_use")
			net.WriteInt( table.Count( ply._lscsUsedPowers ), 9 )

			for ID, _ in pairs( ply._lscsUsedPowers ) do

				ProtectedCall( function() LSCS.Force[ ForcePowers[ ID ].item.id ].StopUse( ply ) end )

				net.WriteInt( ID, 8 )

				ply._lscsUsedPowers[ ID ]= nil
			end

		net.Send( ply )
	end )
else
	local X = ScrW() - 110
	local Y = ScrH() - 100

	local circles = include("includes/circles/circles.lua") -- i love this thing

	-- removed for performance optimization
	--local FP_BG = circles.New(CIRCLE_OUTLINED, 86, 0, 0, 22)
	--FP_BG:SetX( X )
	--FP_BG:SetY( Y )

	local FP = circles.New(CIRCLE_OUTLINED, 85, 0, 0, 20)
	FP:SetX( X )
	FP:SetY( Y )

	local smAlpha = 0

	local ForceIcon = Material( "lscs/ui/force_hud.png" )
	local ForceBG = Material( "lscs/ui/hud_fp.png" ) -- added for performance optimization

	hook.Add( "InitPostEntity", "!!!lscs_bullshit", function()
		local ply = LocalPlayer()
		ply._lscsOldIsMax = CurTime() - 1
	end )

	hook.Add( "HUDPaint", "!!!!lscs_ShowForceMana", function()
		if LSCS:HUDShouldHide( LSCS_HUD_POINTS_FORCE ) then return end

		local ply = LocalPlayer()

		if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end

		local Time = CurTime()

		local F = ply:lscsGetForce()
		local Fmax = ply:lscsGetMaxForce()
		local wep = ply:GetActiveWeapon()

		local IsMax = F == Fmax

		if IsMax then
			if not ply._lscsOldIsMax then
				ply._lscsOldIsMax = Time + 5 -- fade out in 5 seconds
			end
		else
			ply._lscsOldIsMax = nil
		end

		local smRate = RealFrameTime()
		local tAlpha = (IsMax and ply._lscsOldIsMax < Time) and 0 or 1

		smAlpha = smAlpha + math.Clamp(tAlpha - smAlpha,-smRate * 3,smRate * 6)

		if IsValid( wep ) and wep.LSCS then
			if ply:InVehicle() then
				if ply:GetAllowWeaponsInVehicle() then
					smAlpha = 1
				end
			else
				smAlpha = 1
			end
		end

		if smAlpha == 0 then return end

		local segmentLength = 5
		local segmentSpace = 15
		local segmentDist = segmentLength + segmentSpace
		local segmentActiveValue = (260 / Fmax) * F

		surface.SetMaterial( ForceIcon )
		surface.SetDrawColor( Color( 0, 0, 0, 200 * smAlpha ) )
		surface.DrawTexturedRectRotated( X + 5, Y + 15, 124,124, 0 )
		surface.DrawTexturedRectRotated( X + 5, Y + 15, 132,132, 0 )
		surface.SetDrawColor( Color( 255, 255, 255, 255 * smAlpha ) )
		surface.DrawTexturedRectRotated( X + 5, Y + 15, 128,128, 0 )

		-- added for performance optimization
		surface.SetMaterial( ForceBG )
		surface.SetDrawColor( Color( 0, 0, 0, 200 * smAlpha ) )
		surface.DrawTexturedRect( X - 146, Y - 156, 256,256, 0 )

		draw.NoTexture()

		--FP_BG:SetColor( Color(0, 0, 0, 200 * smAlpha) ) -- removed for performance optimization
		FP:SetColor( Color(0, 127, 255, 255 * smAlpha) )

		-- the way im using circles is probably not ideal...  but fuck it, it looks so awesome.  This is probably the thing that will pop up in your profiler
		local Offset = 150
		for A = 0, 260 - segmentDist, segmentDist do
			local Start = Offset + A
			-- removed for performance optimization
			--FP_BG:SetStartAngle( Start - 1 )
			--FP_BG:SetEndAngle( Start  + segmentLength + 1 )
			--FP_BG()

			if A < segmentActiveValue then
				FP:SetStartAngle( Start  )
				FP:SetEndAngle( Start  + segmentLength )
				FP()
			end
		end
	end )

	net.Receive( "lscs_start_jump", function( len )
		local ply = LocalPlayer()

		ply.m_bJumping = true

		ply.m_bFirstJumpFrame = true
		ply.m_flJumpStartTime = CurTime()

		ply:AnimRestartMainSequence()
	end )

	net.Receive( "lscs_force_anims", function( len )
		local ply = net.ReadEntity()
		
		if not IsValid( ply ) then return end

		local seq = net.ReadString()
		local start = net.ReadFloat()

		ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_GRENADE, ply:LookupSequence( seq ), start, true )
	end )
end