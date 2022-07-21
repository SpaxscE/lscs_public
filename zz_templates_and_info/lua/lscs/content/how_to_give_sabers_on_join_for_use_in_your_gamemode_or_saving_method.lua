
-- this will auto equip a blue lightsaber with yongli stance to the player. How you gonna do the saving... is up to you. I will not force a system down your throat. Suggestions for hooks do on GitHub

if CLIENT then return end

hook.Add( "LSCS:OnPlayerFullySpawned", "ANY_HOOK_NAME_YOU_WANT", function( ply )
	local inventory = ply:lscsGetInventory()
	local equipped = ply:lscsGetEquipped()

	table.Empty( inventory ) -- clean the inventory, just in case
	table.Empty( equipped ) -- clean the equipped list, just in case

	inventory[ 1 ] = "item_saberhilt_katarn"
	inventory[ 2 ] = "item_crystal_sapphire"
	inventory[ 3 ] = "item_stance_yongli"
	inventory[ 4 ] = "item_force_heal"
	inventory[ 5 ] = "item_force_immunity"
	inventory[ 6 ] = "item_force_jump"
	inventory[ 7 ] = "item_force_pull"
	inventory[ 8 ] = "item_force_push"
	inventory[ 9 ] = "item_force_replenish"
	inventory[ 10 ] = "item_force_sense"

	equipped[ 1 ] = true -- false would be left hand
	equipped[ 2 ] = true -- false would be left hand
	equipped[ 3 ] = true -- a saber stance can only be right hand, and so do forcepowers
	equipped[ 4 ] = true
	equipped[ 5 ] = true
	equipped[ 6 ] = true
	equipped[ 7 ] = true
	equipped[ 8 ] = true
	equipped[ 9 ] = true
	equipped[ 10 ] = true

	ply:lscsSyncInventory()
	ply:lscsBuildPlayerInfo()

	-- ply:Give("weapon_lscs") -- only needed if they dont have SWEP spawn permission from your admin mod.
	ply:lscsCraftSaber()
end )
