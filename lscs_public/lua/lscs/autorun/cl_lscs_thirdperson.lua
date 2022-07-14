hook.Add( "CalcView", "!!!!!!!!!!!!simple_glowstickthirdperson",  function( ply, pos, angles, fov )
	if ply:GetViewEntity() ~= ply then return end -- when a player uses the camera tool for example

	local weapon = ply:GetActiveWeapon()

	if IsValid( weapon ) and weapon.LSCS and weapon.CalcView then

		if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end -- why would someone do that???

		-- sweps actually come with this exact CalcView function. So why do i do it like this? Just to piss you off with your thirdperson addon? Well nope its because garry's CalcView doesn't allow for DrawViewer = true... of course it doesn't because then it would have been useful
		local view = weapon:CalcView( ply, pos, angles, fov )

		return view
	end
end)