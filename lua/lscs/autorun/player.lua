local meta = FindMetaTable( "Player" )

if SERVER then
	util.AddNetworkString( "lscs_sync_combo_data" )

	function meta:lscsSendComboDataTo( ply )
		if not IsValid( ply ) then return end

		local stances = self.m_lscs_combo or {}

		if table.IsEmpty( stances ) then return end

		net.Start( "lscs_sync_combo_data" )
			net.WriteEntity( self )
			net.WriteInt( #stances, 32 )
			for _, comboname in ipairs( stances ) do
				net.WriteString( comboname )
			end
		net.Send( ply )
	end

	hook.Add( "LSCS:OnPlayerFullySpawned", "sync_combo_data", function( ply )
		for _, other_ply in ipairs( player.GetAll() ) do
			other_ply:lscsSendComboDataTo( ply )
		end
	end )
else
	net.Receive( "lscs_sync_combo_data", function( len )
		local ply = net.ReadEntity()

		if not IsValid( ply ) then return end

		local num = net.ReadInt( 32 )

		local stances = {}
		for i = 1, num do
			table.insert( stances, net.ReadString() )
		end

		ply.m_lscs_combo = stances
	end )
end

function meta:lscsKeyDown( IN_KEY )
	if not self.lscs_cmd then self.lscs_cmd = {} end

	return self.lscs_cmd[ IN_KEY ]
end

function meta:lscsGetInventory()
	if not self.m_inventory_lscs then self.m_inventory_lscs = {} end
	return self.m_inventory_lscs
end

function meta:lscsGetInventoryItem( index )
	return LSCS:ClassToItem( self:lscsGetInventory()[ index ] )
end

function meta:lscsGetEquipped()
	if not self.m_equipped_lscs then self.m_equipped_lscs = {} end

	return self.m_equipped_lscs
end

function meta:lscsGetCombo( num )
	if not self.m_lscs_combo then self.m_lscs_combo = {} end

	if num then
		local combo = LSCS:GetStance( self.m_lscs_combo[ num ] )

		if combo then
			return combo
		else
			return LSCS:GetStance( "default" )
		end
	else
		return self.m_lscs_combo
	end
end

function meta:lscsGetHilt()
	return self.m_lscs_hilt_right, self.m_lscs_hilt_left
end

function meta:lscsGetBlade()
	return self.m_lscs_blade_right, self.m_lscs_blade_left
end

function meta:lscsBuildPlayerInfo()
	local inventory = self:lscsGetInventory()
	local equipped = self:lscsGetEquipped()

	local stances = {}
	local hilt_right
	local hilt_left
	local blade_right
	local blade_left

	for index, item in pairs( inventory ) do
		local eq = equipped[ index ]

		if not isbool( eq ) then continue end

		local object = LSCS:ClassToItem( item )

		if not object then continue end

		local type = object.type
		local ID = object.id

		if type == "stance" then
			table.insert( stances, ID )
			continue
		end
		if type == "hilt" then
			if eq == true then
				if not hilt_right then
					hilt_right = ID
				end
			else
				if not hilt_left then
					hilt_left = ID
				end
			end
			continue
		end
		if type == "crystal" then
			if eq == true then
				if not blade_right then
					blade_right = ID
				end
			else
				if not blade_left then
					blade_left = ID
				end
			end
			continue
		end
	end

	self.m_lscs_combo = stances
	LSCS:SetBlade( self, blade_right, blade_left )
	LSCS:SetHilt( self, hilt_right, hilt_left )

	if SERVER then
		self:SendLua( "LSCS:RefreshMenu()" )

		for _, ply in pairs( player.GetAll() ) do
			if ply == self then continue end

			self:lscsSendComboDataTo( ply )
		end

		local wep = self:GetWeapon( "weapon_lscs" )

		if IsValid( wep ) then
			wep:SetActive( false )
		end
	else
		LSCS:RefreshMenu()
	end
end

function meta:lscsClearEquipped( type, hand )
	local inventory = self:lscsGetInventory()
	local equipped = self:lscsGetEquipped()

	for index, item in pairs( inventory ) do
		local eq = equipped[ index ]

		local object = LSCS:ClassToItem( item )

		if not object then continue end

		local _type = object.type

		if isbool( hand ) then
			if _type == type and hand == eq then
				self:lscsEquipItem( index, nil )
			end
		else
			if _type == type then
				self:lscsEquipItem( index, nil )
			end
		end
	end
end

hook.Add( "StartCommand", "!!!!lscs_syncedinputs", function( ply, cmd )
	if not ply.lscs_cmd then ply.lscs_cmd = {} end

	ply.lscs_cmd[ IN_ATTACK ] = cmd:KeyDown( IN_ATTACK )
	ply.lscs_cmd[ IN_FORWARD ] = cmd:KeyDown( IN_FORWARD )
	ply.lscs_cmd[ IN_MOVELEFT ] =  cmd:KeyDown( IN_MOVELEFT )
	ply.lscs_cmd[ IN_BACK ] =  cmd:KeyDown( IN_BACK )
	ply.lscs_cmd[ IN_MOVERIGHT ] = cmd:KeyDown( IN_MOVERIGHT )
	ply.lscs_cmd[ IN_SPEED ] =  cmd:KeyDown( IN_SPEED )
	ply.lscs_cmd[ IN_JUMP ] =  cmd:KeyDown( IN_JUMP )
end )
