local meta = FindMetaTable( "Player" )

meta.m_inventory_lscs = {}

local LSCS_HILT = 1
local LSCS_BLADE = 2
local LSCS_MULTI = 3
local LSCS_INVENTORY = 4

local function SetHilt( ply, hilt_right, hilt_left )
	if hilt_right == "" or not LSCS:GetHilt( hilt_right ) then
		ply.m_lscs_hilt_right = nil
	else
		ply.m_lscs_hilt_right = hilt_right
	end

	if hilt_left == ""  or not LSCS:GetHilt( hilt_left ) then
		ply.m_lscs_hilt_left = nil
	else
		ply.m_lscs_hilt_left = hilt_left
	end
end

local function SetBlade( ply, blade_right, blade_left )
	if blade_right == "" or not LSCS:GetBlade( blade_right ) then
		ply.m_lscs_blade_right = nil
	else
		ply.m_lscs_blade_right = blade_right
	end

	if blade_left == ""  or not LSCS:GetBlade( blade_left ) then
		ply.m_lscs_blade_left = nil
	else
		ply.m_lscs_blade_left = blade_left
	end
end

if SERVER then
	util.AddNetworkString( "lscs_inventory" )
	util.AddNetworkString( "lscs_sync" )

	function meta:lscsSetHilt( hilt_right, hilt_left )
		SetHilt( self, hilt_right, hilt_left )

		net.Start( "lscs_sync" )
			net.WriteInt( LSCS_HILT, 4 )
			net.WriteString( hilt_right or "" )
			net.WriteString( hilt_left or "" )
			net.WriteEntity( self )
		net.Broadcast()
	end

	function meta:lscsSetBlade( blade_right, blade_left )
		SetBlade( self, blade_right, blade_left )

		net.Start( "lscs_sync" )
			net.WriteInt( LSCS_BLADE, 4 )
			net.WriteString( blade_right or "" )
			net.WriteString( blade_left or "" )
			net.WriteEntity( self )
		net.Broadcast()
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

		self.m_inventory_lscs[ index ] = item

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
		local item = self.m_inventory_lscs[ id ]

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

		self.m_inventory_lscs[ id ] = nil

		return ent
	end

	net.Receive( "lscs_inventory", function( len, ply )
		local id = net.ReadInt( 8 )
		ply:lscsDropItem( id )
	end)

	net.Receive( "lscs_sync", function( len, ply )
		for _, player in ipairs( player.GetAll() ) do
			if player == ply then continue end

			local hilt_right, hilt_left = player:lscsGetHilt()
			local blade_right, blade_left = player:lscsGetBlade()

			net.Start( "lscs_sync" )
				net.WriteInt( LSCS_MULTI, 4 )
				net.WriteString( hilt_right or "" )
				net.WriteString( hilt_left or "" )
				net.WriteString( blade_right or "" )
				net.WriteString( blade_left or "" )
				net.WriteEntity( player )
			net.Send( ply )
		end

		-- in case someone was spamming ply:Give items on spawn
		timer.Simple( 5, function()
			if not IsValid( ply ) then return end
			ply:lscsSyncInventory()
		end)
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
				ply:lscsSetHilt( hilt_right, hilt_left )
			end
		end

		if TYPE == LSCS_BLADE then
			local blade_right = net.ReadString()
			local blade_left = net.ReadString()
			local ply = net.ReadEntity()
	
			if IsValid( ply ) then
				ply:lscsSetBlade( blade_right, blade_left )
			end
		end

		if TYPE == LSCS_MULTI then
			local hilt_right = net.ReadString()
			local hilt_left = net.ReadString()
			local blade_right = net.ReadString()
			local blade_left = net.ReadString()
			local ply = net.ReadEntity()
	
			if IsValid( ply ) then
				ply:lscsSetHilt( hilt_right, hilt_left )
				ply:lscsSetBlade( blade_right, blade_left )
			end
		end

		if TYPE == LSCS_INVENTORY then
			table.Empty( ply.m_inventory_lscs )
			local num = net.ReadInt( 8 )
			for i = 1, num do
				local index = net.ReadInt( 8 )
				local item = net.ReadString( item )
				ply.m_inventory_lscs[ index ] = item
			end
		end
	end)

	function meta:lscsDropItem( id )
		net.Start( "lscs_inventory" )
			net.WriteInt( id, 8 )
		net.SendToServer()

		self.m_inventory_lscs[ id ] = nil
	end

	function meta:lscsSetHilt( hilt_right, hilt_left )
		SetHilt( self, hilt_right, hilt_left )
	end

	function meta:lscsSetBlade( blade_right, blade_left )
		SetBlade( self, blade_right, blade_left )
	end
end

function meta:lscsGetInventory()
	return self.m_inventory_lscs
end

function meta:lscsGetHilt()
	return self.m_lscs_hilt_right, self.m_lscs_hilt_left
end

function meta:lscsGetBlade()
	return self.m_lscs_blade_right, self.m_lscs_blade_left
end