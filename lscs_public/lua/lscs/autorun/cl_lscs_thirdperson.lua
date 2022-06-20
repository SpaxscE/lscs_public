hook.Add( "CalcView", "!!!simple_glowstickthirdperson",  function( ply, pos, angles, fov )
	if ply:GetViewEntity() ~= ply then return end

	local weapon = ply:GetActiveWeapon()

	if IsValid( weapon ) and weapon.LSCS and weapon.CalcView then

		if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end -- why would someone do that???

		local view = weapon:CalcView( ply, ply:lscsGetViewOrigin(), ply:EyeAngles(), fov )

		return view
	end
end)