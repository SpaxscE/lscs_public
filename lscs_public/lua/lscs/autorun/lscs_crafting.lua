
local meta = FindMetaTable( "Player" )

if SERVER then
	util.AddNetworkString( "lscs_craft_saber" )

	function meta:lscsCraftSaber()
		local HiltR, HiltL = self:lscsGetHilt()
		local BladeR, BladeL = self:lscsGetBlade()

		-- allow updating but don't allow spawning if the gamemode forbids it
		if not IsValid( self:GetWeapon( "weapon_lscs" ) ) then
			if hook.Run( "PlayerGiveSWEP", self, "weapon_lscs", weapons.Get( "weapon_lscs" ) ) == false then
				self:ChatPrint("[LSCS] - You don't have permission to spawn this SWEP.")

				return
			end
		end

		self:StripWeapon( "weapon_lscs" )

		self:SetSuppressPickupNotices( true )
		self:Give("weapon_lscs")
		self:SetSuppressPickupNotices( false )

		self:SelectWeapon( "weapon_lscs" )

		self:EmitSound("lscs/equip.mp3")

		local weapon = self:GetWeapon( "weapon_lscs" )

		if IsValid( weapon ) then
			weapon:SetHiltR( HiltR or "" )
			weapon:SetHiltL( HiltL or "" )
			weapon:SetBladeR( BladeR or "" )
			weapon:SetBladeL( BladeL or "" )
		end
	end

	net.Receive( "lscs_craft_saber", function( len, ply )
		ply:lscsCraftSaber()
	end )
else
	function meta:lscsCraftSaber()
		net.Start( "lscs_craft_saber" )
		net.SendToServer()
	end
end
