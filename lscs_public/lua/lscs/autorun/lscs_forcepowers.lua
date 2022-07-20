
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

	local function Jump( ply, TIME )
		if not ply._lscsAssistedJump then return end

		if ply:OnGround() then
			ply._lscsCanForceJump = true
			ply._lscsPlayedJumpSound = false
			ply._lscsJumpForceTaken = nil
		end

		local JUMP = ply:KeyDown( IN_JUMP )

		if JUMP ~= ply._lscsOldJump then
			ply._lscsOldJump = JUMP
			if JUMP then
				ply._lscsJumpTime = TIME + 0.1
			else
				if not ply:OnGround() then
					ply._lscsCanForceJump = false
				end
			end
		end

		if JUMP and ply:lscsGetForce() > 0 and (ply._lscsJumpForceTaken or 0) < 35 and ply._lscsCanForceJump and (ply._lscsJumpTime or 0) < TIME and not ply:OnGround() then
			ply:lscsSuppressFalldamage( TIME + 5 )
			ply:SetVelocity( Vector(0,0,100) + Angle(0,ply:EyeAngles().y,0):Forward() * 5 )
			ply:lscsTakeForce( 2.5 )
			ply._lscsJumpForceTaken = ply._lscsJumpForceTaken and ply._lscsJumpForceTaken + 2.5 or 0

			if not ply._lscsPlayedJumpSound then
				ply._lscsPlayedJumpSound = true

				net.Start( "lscs_start_jump" )
				net.Send( ply )

				ply:EmitSound("lscs/force/jump.mp3")
			end
		end
	end

	local function Protect( ply, TIME )
		if not ply:GetNWBool( "_lscsForceProtect", false ) then return end

		local effectdata = EffectData()
			effectdata:SetOrigin( ply:GetPos() )
			effectdata:SetEntity( ply )
		util.Effect( "force_block_active", effectdata, true, true )

		ply:lscsTakeForce()

		if (ply._lscsBlockTime or 0) < TIME then
			ply:SetNWBool( "_lscsForceProtect", false )
		end
	end

	local function Sense( ply, TIME )
		if not ply:GetNWBool( "_lscsForceSense", false ) then return end

		ply:lscsTakeForce()

		if (ply._lscsSenseTime or 0) < TIME then
			ply:SetNWBool( "_lscsForceSense", false )
		end
	end

	function LSCS:PlayerForcePowerThink( ply, TIME )
		if not ply:Alive() or ply:GetObserverMode() ~= OBS_MODE_NONE then
			ply:SetNWBool( "_lscsForceSense", false )
			ply:SetNWBool( "_lscsForceProtect", false )

			return
		end

		Jump( ply, TIME )
		Protect( ply, TIME )
		Sense( ply, TIME )
	end

	hook.Add( "StartCommand", "StartCommandExample", function( ply, cmd )
		if (ply._lscsForceJumpTime or 0) > CurTime() then
			cmd:SetButtons( bit.bor( cmd:GetButtons(), IN_JUMP ) )
		end
	end )

	local NEXT_THINK = 0
	hook.Add( "Think", "!!!!lscs_unforgiveable_playerGetAll_loop_in_think_hook", function()
		local TIME = CurTime()

		if NEXT_THINK > TIME then return end

		NEXT_THINK = TIME + 0.1 -- slow it down to be nice to the server. The HUD is specifically designed to mask this slow updating.

		for _, ply in ipairs( player.GetAll() ) do
			LSCS:PlayerForcePowerThink( ply, TIME )

			if not ply:OnGround() or (ply._lscsNextForceRegen or 0) > TIME then continue end

			ply:lscsSetForce( math.min(ply:lscsGetForce() + 1,ply:lscsGetMaxForce()) )
		end
	end )

	net.Receive( "lscs_force_use", function( len, ply )
		if not IsValid( ply ) then return end

		local ID = net.ReadInt( 8 )
		local Activate = net.ReadBool()
		local ForcePowers = ply:lscsGetForceAbilities()

		local name = ForcePowers[ ID ].item.id

		if not name then return end

		if Activate then
			ProtectedCall( function() 
				LSCS.Force[ name ].StartUse( ply )
			end )
		else
			ProtectedCall( function() 
				LSCS.Force[ name ].StopUse( ply )
			end )
		end
	end )

	hook.Add( "LSCS:OnPlayerEquippedItem", "!!!!lscs_forcepower_equip_handler", function( ply, item )
		if item.type == "force" then
			ProtectedCall( function() 
				LSCS.Force[ item.id ].Equip( ply )
			end)
		end
	end)

	hook.Add( "LSCS:OnPlayerUnEquippedItem", "!!!!lscs_forcepower_unequip_handler", function( ply, item )
		if item.type == "force" then
			ProtectedCall( function() 
				LSCS.Force[ item.id ].UnEquip( ply )
			end)
		end
	end)
else
	local X = ScrW() - 110
	local Y = ScrH() - 100

	local circles = include("lscs/autorun/cl_circles.lua") -- i love this thing

	local FP_BG = circles.New(CIRCLE_OUTLINED, 86, 0, 0, 22)
	FP_BG:SetX( X )
	FP_BG:SetY( Y )

	local FP = circles.New(CIRCLE_OUTLINED, 85, 0, 0, 20)
	FP:SetX( X )
	FP:SetY( Y )

	local smAlpha = 0

	local ForceIcon = Material( "lscs/ui/force_hud.png" )

	hook.Add( "InitPostEntity", "!!!lscs_bullshit", function()
		local ply = LocalPlayer()
		ply._lscsOldIsMax = CurTime() - 1
	end )

	hook.Add( "HUDPaint", "!!!!lscs_ShowForceMana", function()
		local ply = LocalPlayer()

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
			smAlpha = 1
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

		draw.NoTexture()

		FP_BG:SetColor( Color(0, 0, 0, 200 * smAlpha) )
		FP:SetColor( Color(0, 127, 255, 255 * smAlpha) )

		-- the way im using circles is probably not ideal...  but fuck it, it looks so awesome.  This is probably the thing that will pop up in your profiler
		local Offset = 150
		for A = 0, 260 - segmentDist, segmentDist do
			local Start = Offset + A
			FP_BG:SetStartAngle( Start - 1 )
			FP_BG:SetEndAngle( Start  + segmentLength + 1 )
			FP_BG()

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