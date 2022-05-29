hook.Add( "CalcView", "!!!simple_glowstickthirdperson",  function( ply, pos, angles, fov )
	if ply:GetViewEntity() ~= ply then return end

	local weapon = ply:GetActiveWeapon()

	if IsValid( weapon ) and weapon.LSCS and weapon.CalcView then
		local view = weapon:CalcView( ply, pos, angles, fov )

		return view
	end
end)