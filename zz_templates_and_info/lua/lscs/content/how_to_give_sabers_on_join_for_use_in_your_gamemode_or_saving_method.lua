
-- this will auto equip a blue lightsaber with yongli stance to the player. How you gonna do the saving... is not my problem. 

if CLIENT then return end

hook.Add( "PlayerInitialSpawn", "auto_equip_on_join", function( ply )
	local inventory = ply:lscsGetInventory()
	local equipped = ply:lscsGetEquipped()

	table.Empty( inventory ) -- clean the inventory, just in case
	table.Empty( equipped ) -- clean the equipped list, just in case

	inventory[ 1 ] = "item_saberhilt_katarn"
	inventory[ 2 ] = "item_crystal_sapphire"
	inventory[ 3 ] = "item_stance_yongli"
	--[[
	 alternative to above. However you have no control over what ID they end up being using ply:Give
	ply:Give("item_saberhilt_katarn")
	ply:Give("item_crystal_sapphire")
	ply:Give("item_stance_yongli")
	]]

	equipped[ 1 ] = true -- false would be left hand
	equipped[ 2 ] = true -- false would be left hand
	equipped[ 3 ] = true -- a saber stance can only be right hand

	ply:lscsBuildPlayerInfo() -- networks all the data and syncs it with client

	-- ply:Give("weapon_lscs") -- only needed if they dont have SWEP spawn permission from your admin mod.
						-- If they have permission they will from now on always spawn with this lightsaber unless they unequip it.
end )
