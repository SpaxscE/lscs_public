local meta = FindMetaTable( "Player" )

if SERVER then
	util.AddNetworkString( "lscs_inventory" )
	util.AddNetworkString( "lscs_inventory_refresh" )
	util.AddNetworkString( "lscs_sync" )
	util.AddNetworkString( "lscs_equip" )

	function meta:lscsAddInventory( class_or_entity, equip )
		local item = class_or_entity

		if IsEntity( class_or_entity ) then
			item = class_or_entity:GetClass()
		end

		local index = 1 -- start at 1
		for _,_ in ipairs( self:lscsGetInventory() ) do
			index = index + 1 -- lets find an empty slot. Thanks to ipairs nature it will automatically stop at an empty slot
		end

		if hook.Run( "LSCS:PlayerInventory", self, item, index ) then return end

		if self._lscsNetworkingReady then
			net.Start( "lscs_inventory" )
				net.WriteBool( true )
				net.WriteInt( index, 8 )
				net.WriteString( item )
			net.Send( self )
		end

		self:lscsGetInventory()[ index ] = item

		if isbool( equip ) then -- this makes sure we can not equip two hilts or blades in one hand
			local object = LSCS:ClassToItem( item )

			if object then
				local type = object.type

				if type == "hilt" or type == "crystal" then
					self:lscsClearEquipped( type, equip )
				end
			end
		end

		self:lscsEquipItem( index, equip )

		if IsEntity( class_or_entity ) then
			class_or_entity:Remove()
		end
	end

	function meta:lscsEquipItem( index, hand )
		local class = self:lscsGetInventory()[ index ]
		if not class then return end

		local WasEquipped = self:lscsGetEquipped()[ index ]
		self:lscsGetEquipped()[ index ] = hand

		if self._lscsNetworkingReady then
			net.Start( "lscs_equip" )
				net.WriteInt( index, 8 )
				if hand == true then
					net.WriteInt( 1, 3 )
				elseif hand == false then
					net.WriteInt( 0, 3 )
				else
					net.WriteInt( -1, 3 )
				end
			net.Send( self )
		end

		self:lscsBuildPlayerInfo()

		if isbool( hand ) then
			hook.Run( "LSCS:OnPlayerEquippedItem", self, LSCS:ClassToItem( class ) )
		else
			if isbool( WasEquipped ) then
				hook.Run( "LSCS:OnPlayerUnEquippedItem", self, LSCS:ClassToItem( class ) )
			end
		end
	end

	net.Receive( "lscs_equip", function( len, ply )
		local inventory = ply:lscsGetInventory()
		local equipped = ply:lscsGetEquipped()

		local index = net.ReadInt( 8 )
		local equip = net.ReadInt( 3 )

		if inventory[ index ] then
			if equip == 1 then
				ply:EmitSound( "lscs/equip.mp3" )
				equipped[ index ] = true

			elseif equip == 0 then
				ply:EmitSound( "lscs/equip.mp3" )
				equipped[ index ] = false

			else
				if isbool( equipped[ index ] ) then
					equipped[ index ] = nil
					ply:EmitSound( "weapons/sniper/sniper_zoomout.wav" )
				end
			end
		else
			equipped[ index ] = nil
		end

		ply:lscsBuildPlayerInfo()

		if equip == 0 or equip == 1 then
			hook.Run( "LSCS:OnPlayerEquippedItem", ply, LSCS:ClassToItem( inventory[ index ] ) )
		else
			hook.Run( "LSCS:OnPlayerUnEquippedItem", ply, LSCS:ClassToItem( inventory[ index ] ) )
		end
	end )

	function meta:lscsSyncInventory()
		if not self._lscsNetworkingReady then return end

		local inv = self:lscsGetInventory()
		local eq = self:lscsGetEquipped()

		local num = table.Count( inv )

		net.Start( "lscs_sync" )
			net.WriteInt( num, 8 )
			for index, item in pairs( inv ) do
				net.WriteInt( index, 8 )

				local IsEquipped = eq[ index ]
				if IsEquipped == true then
					net.WriteInt( 1, 3 )
				elseif IsEquipped == false then
					net.WriteInt( 0, 3 )
				else
					net.WriteInt( -1, 3 )
				end

				net.WriteString( item )
			end
		net.Send( self )
	end

	function meta:lscsWipeInventory( wipe_unequipped )
		if wipe_unequipped then
			local inv = self:lscsGetInventory()
			local eq = self:lscsGetEquipped()

			for id, item in pairs( inv ) do
				if eq[ id ] == nil then
					inv[ id ] = nil
				end
			end
		else
			local inv = self:lscsGetInventory()
			local eq = self:lscsGetEquipped()

			self:StripWeapon( "weapon_lscs" )

			for id, class in pairs( self:lscsGetInventory() ) do
				if isbool( eq[ id ] ) then
					hook.Run( "LSCS:OnPlayerUnEquippedItem", self, LSCS:ClassToItem( class ) )
				end
			end

			table.Empty( inv )
			table.Empty( eq )
		end

		self:lscsSyncInventory()
		self:lscsBuildPlayerInfo()
	end

	function meta:lscsDropItem( id )
		local item = self:lscsGetInventory()[ id ]

		if not item then return end

		local tr = util.TraceLine( {
			start = self:GetShootPos(),
			endpos = self:GetShootPos() + self:GetAimVector() * 50,
			filter = self,
		} )

		local ent = ents.Create( item )

		if not IsValid( ent ) then self:lscsRemoveItem( id ) return end

		ent:SetPos( tr.HitPos )
		ent:SetAngles( Angle(90,self:EyeAngles().y,0) )

		ent.PreventTouch = true
		ent.DieTime = CurTime() + 240

		ent:Spawn()
		ent:Activate()
		ent:PhysWake()

		net.Start( "lscs_inventory" )
			net.WriteBool( false )
			net.WriteInt( id, 8 )
		net.Send( self )

		if self:lscsGetEquipped()[ id ] then -- we dropped a equipped item
			local _item = LSCS:ClassToItem( item ) -- convert item from inventory which is a class to actual item data
			if _item.type =="hilt" or _item.type == "crystal" then -- the item is a crystal or hilt which means we have to craft a lightsaber so it actually takes these parts out

				-- this garbage has to be called before crafting because it pulls stuff out of the inventory
				self:lscsRemoveItem( id )
				self:lscsBuildPlayerInfo()

				-- craft the saber
				self:lscsCraftSaber()
			end

			if _item.type == "stance" then -- dropped a equipped stance
				self:lscsRemoveItem( id )
				self:lscsBuildPlayerInfo() -- sync stances
			end

			hook.Run( "LSCS:OnPlayerUnEquippedItem", self, _item )
		end

		self:lscsRemoveItem( id )

		hook.Run( "LSCS:OnPlayerDroppedItem", self, ent )
	end

	function meta:lscsRemoveItem( id )
		local item = self:lscsGetInventory()[ id ]

		if not item then return end

		net.Start( "lscs_inventory" )
			net.WriteBool( false )
			net.WriteInt( id, 8 )
		net.Send( self )

		self:lscsGetInventory()[ id ] = nil
		self:lscsGetEquipped()[ id ] = nil
	end

	net.Receive( "lscs_inventory", function( len, ply )
		local id = net.ReadInt( 8 )
		ply:lscsDropItem( id )
	end)

	net.Receive( "lscs_sync", function( len, ply )
		if ply._lscsNetworkingReady then return end -- only allow this to be called once. This will prevent them from doing malicious bullshit.

		-- in case someone was spamming ply:Give while the player wasnt ready for networking
		-- this will make sure the client's inventory is 100% in sync with the server
		ply._lscsNetworkingReady = true
		ply:lscsSyncInventory()
		ply:lscsBuildPlayerInfo()

		hook.Run( "LSCS:OnPlayerFullySpawned", ply )
	end )

	net.Receive( "lscs_inventory_refresh", function( len, ply )
		local Wipe = net.ReadBool()

		if Wipe then
			ply:lscsWipeInventory( net.ReadBool() )
		else
			ply._lscsInvRefNext = ply._lscsInvRefNext or 0

			local Time = CurTime()

			if ply._lscsInvRefNext > Time then
				ply._lscsInvRefNext = ply._lscsInvRefNext + 1 -- add 1 second penality
				ply:ChatPrint("[LSCS] - Please wait ".. math.Round(ply._lscsInvRefNext-Time,0) .." seconds before refreshing your Inventory again")
				return
			end

			ply._lscsInvRefNext = Time + 10

			ply:lscsSyncInventory()
			ply:lscsBuildPlayerInfo()

			ply:ChatPrint("[LSCS] - Inventory Refreshed")
		end
	end)
else
	hook.Add( "InitPostEntity", "!!!lscsPlayerReady", function()
		net.Start( "lscs_sync" )
		net.SendToServer()
	end )

	net.Receive( "lscs_inventory", function( len )
		local ply = LocalPlayer()

		local Add = net.ReadBool()
		local id = net.ReadInt( 8 )

		local inventory = ply:lscsGetInventory()
		local equipped = ply:lscsGetEquipped()
	
		if Add then
			local item = net.ReadString()
			inventory[ id ] = item
		else
			inventory[ id ] = nil
		end
		equipped[ id ] = nil

		LSCS:RefreshMenu()
	end)

	net.Receive( "lscs_sync", function( len )
		local ply = LocalPlayer()

		local inventory = ply:lscsGetInventory()
		local equipped = ply:lscsGetEquipped()

		table.Empty( inventory )
		table.Empty( equipped )

		local num = net.ReadInt( 8 )
		for i = 1, num do
			local index = net.ReadInt( 8 )
			local IsEquipped = net.ReadInt( 3 )
			local item = net.ReadString( item )

			inventory[ index ] = item

			if IsEquipped == 1 then
				equipped[ index ] = true
			elseif IsEquipped == 0 then
				equipped[ index ] = false
			else
				equipped[ index ] = nil
			end
		end

		LSCS:RefreshMenu()
	end)

	function meta:lscsDropItem( id )
		net.Start( "lscs_inventory" )
			net.WriteInt( id, 8 )
		net.SendToServer()

		self:lscsGetInventory()[ id ] = nil
		self:lscsGetEquipped()[ id ] = nil

		self:lscsBuildPlayerInfo()
	end

	function meta:lscsEquipItem( index, hand )
		if not self:lscsGetInventory()[ index ] then return end

		self:lscsGetEquipped()[ index ] = hand

		net.Start( "lscs_equip" )
			net.WriteInt( index, 8 )
			if hand == true then
				net.WriteInt( 1, 3 )
			elseif hand == false then
				net.WriteInt( 0, 3 )
			else
				net.WriteInt( -1, 3 )
			end
		net.SendToServer()

		self:lscsBuildPlayerInfo()
	end

	net.Receive( "lscs_equip", function( len )
		local ply = LocalPlayer()

		local inventory = ply:lscsGetInventory()
		local equipped = ply:lscsGetEquipped()

		local index = net.ReadInt( 8 )
		local equip = net.ReadInt( 3 )

		if inventory[ index ] then
			if equip == 1 then
				equipped[ index ] = true

			elseif equip == 0 then
				equipped[ index ] = false

			else
				equipped[ index ] = nil
			end
		else
			equipped[ index ] = nil
		end

		ply:lscsBuildPlayerInfo()
	end )
end
