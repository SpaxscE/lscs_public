
-- this will auto equip a blue lightsaber with yongli stance to the player. How you gonna do the saving... is up to you. I will not force a system down your throat. Suggestions for hooks do on GitHub

if CLIENT then return end

hook.Add( "LSCS:OnPlayerFullySpawned", "ANY_HOOK_NAME_YOU_WANT", function( ply )
	local inventory = ply:lscsGetInventory()
	local equipped = ply:lscsGetEquipped()

	table.Empty( inventory ) -- clean the inventory, just in case
	table.Empty( equipped ) -- clean the equipped list, just in case

	inventory[ 1 ] = "item_saberhilt_katarn"
	equipped[ 1 ] = true -- false would be left hand

	inventory[ 2 ] = "item_crystal_sapphire"
	equipped[ 2 ] = true -- false would be left hand

	inventory[ 3 ] = "item_stance_yongli"
	equipped[ 3 ] = true -- a saber stance can only be right hand, and so do forcepowers

	inventory[ 4 ] = "item_force_heal"
	equipped[ 4 ] = true

	inventory[ 5 ] = "item_force_immunity"
	equipped[ 5 ] = true

	inventory[ 6 ] = "item_force_jump"
	equipped[ 6 ] = true

	inventory[ 7 ] = "item_force_pull"
	equipped[ 7 ] = true

	inventory[ 8 ] = "item_force_push"
	equipped[ 8 ] = true

	inventory[ 9 ] = "item_force_replenish"
	equipped[ 9 ] = true

	inventory[ 10 ] = "item_force_sense"
	equipped[ 10 ] = true

	ply:lscsSyncInventory()
	ply:lscsBuildPlayerInfo()

	-- ply:Give("weapon_lscs") -- only needed if they dont have SWEP spawn permission from your admin mod.
	ply:lscsCraftSaber()
end )
