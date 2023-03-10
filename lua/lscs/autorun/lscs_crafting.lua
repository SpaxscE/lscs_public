
local meta = FindMetaTable( "Player" )

if SERVER then
	util.AddNetworkString( "lscs_craft_saber" )

	function meta:lscsCraftSaber( dont_mess_with_pickup_notifications )
		local HiltR, HiltL = self:lscsGetHilt()
		local BladeR, BladeL = self:lscsGetBlade()

		-- allow updating but don't allow spawning if the gamemode forbids it
		local SWEP = self:GetWeapon( "weapon_lscs" )
		local OldBP

		if IsValid( SWEP ) then
			OldBP = SWEP:GetBlockPoints()
		else
			if hook.Run( "PlayerGiveSWEP", self, "weapon_lscs", weapons.Get( "weapon_lscs" ) ) == false then
				self:ChatPrint("[LSCS] - You don't have permission to spawn this SWEP.")

				return
			end
		end

		self:StripWeapon( "weapon_lscs" )

		if not dont_mess_with_pickup_notifications then self:SetSuppressPickupNotices( true ) end
		self:Give("weapon_lscs")
		if not dont_mess_with_pickup_notifications then self:SetSuppressPickupNotices( false) end

		self:SelectWeapon( "weapon_lscs" )

		self:EmitSound("lscs/equip.mp3")

		local weapon = self:GetWeapon( "weapon_lscs" )

		if IsValid( weapon ) then
			weapon:SetHiltR( HiltR or "" )
			weapon:SetHiltL( HiltL or "" )

			if HiltR and HiltR ~= "" then
				weapon:SetBladeR( BladeR or "" )
			end
			if HiltL and HiltL ~= "" then
				weapon:SetBladeL( BladeL or "" )
			end

			if OldBP then weapon:SetBlockPoints( OldBP ) end
		end

		hook.Run( "LSCS:OnPlayerCraftedSaber", self, weapon )
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
