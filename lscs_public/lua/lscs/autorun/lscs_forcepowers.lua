

if SERVER then
	local NEXT_THINK = 0
	hook.Add( "Think", "!!!!lscs_unforgiveable_playerGetAll_loop_in_think_hook", function()
		local TIME = CurTime()

		if NEXT_THINK > TIME then return end

		NEXT_THINK = TIME + 0.25 -- slow it down, by alot. The HUD is specifically designed to mask this slow updating.

		for _, ply in ipairs( player.GetAll() ) do
			if not ply:OnGround() or (ply._lscsNextForceRegen or 0) > TIME then continue end

			ply:lscsSetForce( math.min(ply:lscsGetForce() + 2.5,ply:lscsGetMaxForce()) )
		end
	end )
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

		local X = ScrW() - 110
		local Y = ScrH() - 100

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
end