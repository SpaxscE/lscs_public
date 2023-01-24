
local function Validate( ply )
	if not ply:Alive() or ply:GetViewEntity() ~= ply then return false end -- when a player uses the camera tool for example

	local weapon = ply:GetActiveWeapon()

	if not IsValid( weapon ) or not weapon.LSCS then return false end -- not holding our lightsaber

	if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return false end -- use vehicle view in vehicles

	return true
end

-- this is the main camera. If all goes to plan this should do the job
hook.Add( "CalcView", "!!!!!!!!!!!!simple_glowstickthirdperson",  function( ply, pos, angles, fov )
	if not Validate( ply ) then return end

	local view = {}
	view.origin = ply:lscsGetViewOrigin()
	view.angles = ply:EyeAngles()
	view.fov = fov
	view.drawviewer = true

	ply._lscsCalcViewTime = CurTime() + 0.1

	return view
end )

-- this is used for when the CalcView hook somehow doesn't get called but the SWEP:CalcView function is. If the hook fails this will probably fail aswell tho
hook.Add( "ShouldDrawLocalPlayer", "!!!!!!!!!!!!simple_glowstickthirdperson",  function( ply )
	if (ply._lscsCalcViewTime or 0) < CurTime() then return end

	if not Validate( ply ) then return end

	return true
end )
