-- a fully working auto save and restore example can be found here:
-- https://github.com/Blu-x92/lscs_public/blob/main/zz_templates_and_info/lua/lscs/content/inventory_saver_example.lua



-- this script here will auto equip a blue lightsaber with yongli stance to the player:

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

	-- ply:lscsCraftSaber() -- if you are doing all the above stuff outside of PlayerInitialSpawn Hook you will have to call this function to force a lightsaber craft after the player is spawned.
end )

--[[
ply:lscsAddInventory( class_or_entity, equip_to_hand )

							equip_to_hand = 
					 				true -- equip to right hand
									false -- equip to left hand
					 				nil -- don't equip



to make your inventory save you would just read the inventory-table and the equipped table:

inventory = ply:lscsGetInventory()
equipped = ply:lscsGetEquipped()

and save them in whatever way you want. To restore them use the PlayerInitialSpawn example above. This will ensure all internal hooks and functions are called.


to clear the inventory you can just do:

ply:lscsWipeInventory( wipe_unequipped ) -- clears the entire inventory. If wipe_unequipped = true will only clear unequipped items from inventory. Server only


 more functions and info see:
 https://raw.githubusercontent.com/Blu-x92/LUNA_SWORD_COMBAT_SYSTEM/main/zz_templates_and_info/useful_lua_functions.txt

]]