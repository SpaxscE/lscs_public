local meta = FindMetaTable( "Player" )

meta.m_inventory_lscs = {}

if SERVER then
	util.AddNetworkString( "lscs_inventory" )

	function meta:lscsAddInventory( entity )

		local item = entity:GetClass()

		local index = 1 -- start at 1
		for i,_ in ipairs( self:lscsGetInventory() ) do
			index = index + 1 -- lets find an empty slot. Thanks to ipairs nature it will automatically stop at an empty slot
		end

		net.Start( "lscs_inventory" )
			net.WriteBool( true )
			net.WriteInt( index, 32 )
			net.WriteString( item )
		net.Send( self )

		self.m_inventory_lscs[ index ] = item

		entity:Remove()
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
			net.WriteInt( id, 32 )
		net.Send( self )

		self.m_inventory_lscs[ id ] = nil

		return ent
	end

	net.Receive( "lscs_inventory", function( len, ply )
		local id = net.ReadInt( 32 )
		ply:lscsDropItem( id )
	end)
else
	local ply = LocalPlayer()
	net.Receive( "lscs_inventory", function( len )
		local Add = net.ReadBool()
		local id = net.ReadInt( 32 )

		if Add then
			local item = net.ReadString()
			ply.m_inventory_lscs[ id ] = item
		else
			ply.m_inventory_lscs[ id ] = nil
		end
	end)

	function meta:lscsDropItem( id )
		net.Start( "lscs_inventory" )
			net.WriteInt( id, 32 )
		net.SendToServer()

		self.m_inventory_lscs[ id ] = nil
	end
end

function meta:lscsGetInventory()
	return self.m_inventory_lscs
end