local meta = FindMetaTable( "Player" )

local LSCS_FIRSTJOIN = 0
local LSCS_HILT = 1
local LSCS_BLADE = 2
local LSCS_MULTI = 3
local LSCS_INVENTORY = 4

if SERVER then
	util.AddNetworkString( "lscs_inventory" )
	util.AddNetworkString( "lscs_sync" )
	util.AddNetworkString( "lscs_equip" )
	util.AddNetworkString( "lscs_craft_saber" )

	function meta:lscsCraftSaber()
		local HiltR, HiltL = self:lscsGetHilt()
		local BladeR, BladeL = self:lscsGetBlade()

		self:StripWeapon( "weapon_lscs" )

		self:Give("weapon_lscs")
		self:SelectWeapon( "weapon_lscs" )

		self:EmitSound("lscs/equip.mp3")

		--?option consumables?
		self:lscsSetHilt()
		self:lscsSetBlade()

		local weapon = self:GetWeapon( "weapon_lscs" )

		if IsValid( weapon ) then
			weapon:SetHiltR( HiltR or "" )
			weapon:SetHiltL( HiltL or "" )
			weapon:SetBladeR( BladeR or "" )
			weapon:SetBladeL( BladeL or "" )
		end
	end

	function meta:lscsSetHilt( hilt_right, hilt_left )
		LSCS:SetHilt( self, hilt_right, hilt_left )

		net.Start( "lscs_sync" )
			net.WriteInt( LSCS_HILT, 4 )
			net.WriteString( hilt_right or "" )
			net.WriteString( hilt_left or "" )
			net.WriteEntity( self )
		net.Send( self )
	end

	function meta:lscsSetBlade( blade_right, blade_left )
		LSCS:SetBlade( self, blade_right, blade_left )

		net.Start( "lscs_sync" )
			net.WriteInt( LSCS_BLADE, 4 )
			net.WriteString( blade_right or "" )
			net.WriteString( blade_left or "" )
			net.WriteEntity( self )
		net.Send( self )
	end

	function meta:lscsSetStance( name )
		local stance = LSCS:GetStance( name )
		if stance then
			self:SetNWString( "lscsComboFile", name )
		else
			self:SetNWString( "lscsComboFile", "default" )
		end
	end

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

		entity:Remove()
	end

	function meta:lscsSyncInventory()
		local inv = self:lscsGetInventory()
		local num = table.Count( inv )

		net.Start( "lscs_sync" )
			net.WriteInt( LSCS_INVENTORY, 4 )
			net.WriteInt( num, 8 )
			for index, item in pairs( inv ) do
				net.WriteInt( index, 8 )
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
		ent:Spawn()
		ent:Activate()
		ent:PhysWake()

		net.Start( "lscs_inventory" )
			net.WriteBool( false )
			net.WriteInt( id, 8 )
		net.Send( self )

		self:lscsGetInventory()[ id ] = nil

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
	end

	function meta:lscsEquipFromInventory( id, slot )
		local inventory = self:lscsGetInventory()
		local item = LSCS:ClassToItem( inventory[ id ] )

		if not item then
			self:ChatPrint("This Item can not be equipped!")
			self:EmitSound("buttons/button10.wav")
			self:SendLua( "LSCS:RefreshMenu()" )
			return
		end

		if item.type == "hilt" then
			local A, B = self:lscsGetHilt()

			if slot == 0 then
				if A and B then
					self:EmitSound("buttons/button10.wav")
					self:SendLua( "LSCS:RefreshMenu()" )
				else
					if not A then
						self:lscsSetHilt( item.id, B )
					else
						self:lscsSetHilt( A , item.id )
					end
					self:lscsRemoveItem( id )
					self:EmitSound( "lscs/equip.mp3" )
					self:SendLua( "LSCS:RefreshMenu()" )
				end
			else
				if slot == 1 or slot == 2 then
					if slot == 1 then
						self:lscsSetHilt( item.id, B )
					else
						self:lscsSetHilt( A , item.id )
					end
					self:lscsRemoveItem( id )
					self:EmitSound( "lscs/equip.mp3" )
					self:SendLua( "LSCS:RefreshMenu()" )
				end
			end
		end
		if item.type == "crystal" then
			local A, B = self:lscsGetBlade()

			if slot == 0 then
				if A and B then
					self:EmitSound("buttons/button10.wav")
					self:SendLua( "LSCS:RefreshMenu()" )
				else
					if not A then
						self:lscsSetBlade( item.id, B )
					else
						self:lscsSetBlade( A , item.id )
					end
					self:lscsRemoveItem( id )
					self:EmitSound( "lscs/equip.mp3" )
					self:SendLua( "LSCS:RefreshMenu()" )
				end
			else
				if slot == 1 or slot == 2 then
					if slot == 1 then
						self:lscsSetBlade( item.id, B )
					else
						self:lscsSetBlade( A , item.id )
					end
					self:lscsRemoveItem( id )
					self:EmitSound( "lscs/equip.mp3" )
					self:SendLua( "LSCS:RefreshMenu()" )
				end
			end
		end
		if item.type == "stance" then
			self:lscsRemoveItem( id )
			self:lscsSetStance( item.id )
			self:EmitSound( "lscs/equip.mp3" )
			self:SendLua( "LSCS:RefreshMenu()" )

			local wep = self:GetActiveWeapon()

			if IsValid( wep ) and wep.LSCS then
				wep:SetActive( false )
			end
		end
	end

	net.Receive( "lscs_equip", function( len, ply )
		local unequip = net.ReadBool()

		if unequip then
			local unequip_hiltR = net.ReadBool()
			local unequip_hiltL = net.ReadBool()
			local unequip_bladeR = net.ReadBool()
			local unequip_bladeL = net.ReadBool()

			local HiltR, HiltL = ply:lscsGetHilt()
			if unequip_hiltR then
				local item = LSCS:GetHilt( HiltR )
				if item and item.class then
					ply:Give( item.class )
					HiltR = nil
				end
			end
			if unequip_hiltL then
				local item = LSCS:GetHilt( HiltL )
				if item and item.class then
					ply:Give( item.class )
					HiltL = nil
				end
			end
			ply:lscsSetHilt( HiltR, HiltL )

			local BladeR, BladeL = ply:lscsGetBlade()
			if unequip_bladeR then
				local item = LSCS:GetBlade( BladeR )
				if item and item.class then
					ply:Give( item.class )
					BladeR = nil
				end
			end
			if unequip_bladeL then
				local item = LSCS:GetBlade( BladeL )
				if item and item.class then
					ply:Give( item.class )
					BladeL = nil
				end
			end
			ply:lscsSetBlade( BladeR, BladeL )

			ply:SendLua( "LSCS:RefreshMenu()" )
		else
			local item = net.ReadInt( 8 )
			local slot = net.ReadInt( 8 )

			ply:lscsEquipFromInventory( item, slot )
		end
	end)

	net.Receive( "lscs_inventory", function( len, ply )
		local id = net.ReadInt( 8 )
		ply:lscsDropItem( id )
	end)

	net.Receive( "lscs_sync", function( len, ply )
		local TYPE = net.ReadInt( 4 )

		if TYPE == LSCS_FIRSTJOIN then
			-- in case someone was spamming ply:Give while the player wasnt ready for networking
			-- this will make sure the client's inventory is 100% in sync with the server
			ply:lscsSyncInventory()
		end
	end )

	net.Receive( "lscs_craft_saber", function( len, ply )
		ply:lscsCraftSaber()
	end )
else
	hook.Add( "InitPostEntity", "!!!lscsPlayerReady", function()
		net.Start( "lscs_sync" )
			net.WriteInt( LSCS_FIRSTJOIN, 4 )
		net.SendToServer()
	end )

	net.Receive( "lscs_inventory", function( len )
		local ply = LocalPlayer()

		local Add = net.ReadBool()
		local id = net.ReadInt( 8 )

		if Add then
			local item = net.ReadString()
			ply.m_inventory_lscs[ id ] = item
		else
			ply.m_inventory_lscs[ id ] = nil
		end
	end)

	net.Receive( "lscs_sync", function( len )
		local ply = LocalPlayer()

		local TYPE = net.ReadInt( 4 )

		if TYPE == LSCS_HILT then
			local hilt_right = net.ReadString()
			local hilt_left = net.ReadString()
			local ply = net.ReadEntity()
	
			if IsValid( ply ) then
				LSCS:SetHilt( ply, hilt_right, hilt_left )
			end
		end

		if TYPE == LSCS_BLADE then
			local blade_right = net.ReadString()
			local blade_left = net.ReadString()
			local ply = net.ReadEntity()
	
			if IsValid( ply ) then
				LSCS:SetBlade( ply, blade_right, blade_left )
			end
		end

		if TYPE == LSCS_MULTI then
			local hilt_right = net.ReadString()
			local hilt_left = net.ReadString()
			local blade_right = net.ReadString()
			local blade_left = net.ReadString()
			local ply = net.ReadEntity()
	
			if IsValid( ply ) then
				LSCS:SetHilt( ply, hilt_right, hilt_left )
				LSCS:SetBlade( ply, blade_right, blade_left )
			end
		end

		if TYPE == LSCS_INVENTORY then
			table.Empty( ply:lscsGetInventory() )
			local num = net.ReadInt( 8 )
			for i = 1, num do
				local index = net.ReadInt( 8 )
				local item = net.ReadString( item )
				ply.m_inventory_lscs[ index ] = item
			end
			LSCS:RefreshMenu()
		end
	end)

	function meta:lscsCraftSaber()
		net.Start( "lscs_craft_saber" )
		net.SendToServer()
	end

	function meta:lscsDropItem( id )
		net.Start( "lscs_inventory" )
			net.WriteInt( id, 8 )
		net.SendToServer()

		self:lscsGetInventory()[ id ] = nil
	end

	function meta:lscsEquipFromInventory( id, slot )
		local slot = slot or 0
		net.Start( "lscs_equip" )
			net.WriteBool( false )
			net.WriteInt( id, 8 )
			net.WriteInt( slot, 8 )
		net.SendToServer()
	end

	function meta:lscsUnEquip( HiltR, HiltL, BladeR, BladeL )
		net.Start( "lscs_equip" )
			net.WriteBool( true )
			net.WriteBool( HiltR == true )
			net.WriteBool( HiltL == true )
			net.WriteBool( BladeR == true )
			net.WriteBool( BladeL == true )
		net.SendToServer()
	end
end

function meta:lscsGetCombo()
	return LSCS:GetStance( self:GetNWString( "lscsComboFile", "default" ) )
end

function meta:lscsGetInventory()
	if not self.m_inventory_lscs then self.m_inventory_lscs = {} end
	return self.m_inventory_lscs
end

function meta:lscsGetHilt()
	return self.m_lscs_hilt_right, self.m_lscs_hilt_left
end

function meta:lscsGetBlade()
	return self.m_lscs_blade_right, self.m_lscs_blade_left
end
