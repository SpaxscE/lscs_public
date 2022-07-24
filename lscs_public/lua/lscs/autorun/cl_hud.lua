
LSCS_HUD_POINTS_FORCE = 1
LSCS_HUD_POINTS_BLOCK = 2
LSCS_HUD_POINTS_ADVANTAGE = 3
LSCS_HUD_STANCE = 4

function LSCS:HUDShouldHide( LSCS_HUD )
	local ShouldDraw = hook.Run( "LSCS:HUDShouldDraw", LSCS_HUD )

	if ShouldDraw == false then return true end

	return not LSCS.DrawHud
end
