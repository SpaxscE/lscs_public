local meta = FindMetaTable( "Player" )

if SERVER then
	util.AddNetworkString( "lscs_inventory" )
	util.AddNetworkString( "lscs_sync" )
	util.AddNetworkString( "lscs_equip" )

	function meta:lscsAddInventory( entity )

		local item = entity:GetClass()

		local index = 1 -- start at 1
		for i,_ in ipairs( self:lscsGetInventory() ) do
			index = index + 1 -- lets find an empty slot. Thanks to ipairs nature it will automatically stop at an empty slot
		end

		net.Start( "lscs_inventory" )
			net.WriteBool( true )
			net.WriteInt( index, 8 )
			net.WriteString( item )
		net.Send( self )

		self:lscsGetInventory()[ index ] = item
		self:lscsGetEquipped()[ index ] = nil

		entity:Remove()
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
		net.Send( self )

		self:lscsBuildPlayerInfo()
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
	end )

	function meta:lscsSyncInventory()
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

	function meta:lscsDropItem( id )
		local item = self:lscsGetInventory()[ id ]

		if not item then return end

		local tr = util.TraceLine( {
			start = self:GetShootPos(),
			endpos = self:GetShootPos() + self:GetAimVector() * 50,
			filter = self,
		} )

		local ent = ents.Create( item )
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

		self:lscsGetInventory()[ id ] = nil
		self:lscsGetEquipped()[ id ] = nil

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
		-- in case someone was spamming ply:Give while the player wasnt ready for networking
		-- this will make sure the client's inventory is 100% in sync with the server
		ply:lscsSyncInventory()

		hook.Run( "LSCS:OnPlayerFullySpawned", ply )
	end )
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
