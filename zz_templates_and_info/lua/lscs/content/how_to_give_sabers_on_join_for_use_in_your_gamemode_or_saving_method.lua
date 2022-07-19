
-- this will auto equip a blue lightsaber with yongli stance to the player. How you gonna do the saving... is up to you. I will not force a system down your throat. Suggestions for hooks do on GitHub

if CLIENT then return end

hook.Add( "PlayerInitialSpawn", "auto_equip_on_join", function( ply )
	ply:Give("item_saberhilt_katarn")
	ply:Give("item_crystal_sapphire")
	ply:Give("item_stance_yongli")

	-- ply:Give("weapon_lscs") -- only needed if they dont have SWEP spawn permission from your admin mod.
						-- If they have permission they will from now on always spawn with this lightsaber unless they unequip it.

	-- If you give the items outside PlayerInitialSpawn you will need to call ply:lscsCraftSaber() to force the player to craft a lightsaber
end )
