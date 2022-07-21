
-- this will auto equip a blue lightsaber with yongli stance to the player. How you gonna do the saving... is up to you. I will not force a system down your throat. Suggestions for hooks do on GitHub

if CLIENT then return end

hook.Add( "PlayerInitialSpawn", "ANY_HOOK_NAME_YOU_WANT", function( ply )
	ply:lscsAddInventory( "item_saberhilt_katarn", true ) -- give katarn saberhilt to right hand. Left Hand would be "false"
	ply:lscsAddInventory( "item_crystal_sapphire", true ) -- give katarn saber crystal to right hand. Left Hand would be "false"
	ply:lscsAddInventory( "item_stance_yongli", true ) -- stances can only be "true" as they are right hand only
	ply:lscsAddInventory( "item_force_heal", true ) -- so are forcepowers
	ply:lscsAddInventory( "item_force_immunity", true )
	ply:lscsAddInventory( "item_force_jump", true )
	ply:lscsAddInventory( "item_force_pull", true )
	ply:lscsAddInventory( "item_force_push", true )
	ply:lscsAddInventory( "item_force_replenish", true )
	ply:lscsAddInventory( "item_force_sense", true )

	-- ply:Give("weapon_lscs") -- only needed if they dont have SWEP spawn permission from your admin mod.
end )
