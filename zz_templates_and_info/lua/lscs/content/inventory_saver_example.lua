-- for all the people who cant figure this out by themself...
-- just a quick script that will save and restore your inventory
-- i strongly urge you to code your own system, as this is a very inefficient way of doing it.

-- this file goes to: lua/lscs/content

if CLIENT then return end -- all this is serverside only.

local meta = FindMetaTable( "Player" )

local NumberToEquippedEntry = {
	[0] = true,
	[1] = false,
	[-1] = nil, -- just for looks, doesnt actually do anything
}

function meta:lscsWriteInventory()
	local ID = self:AccountID()

	if not ID then return end

	local inv = self:lscsGetInventory()
	local eq = self:lscsGetEquipped()

	local data = ""

	for index, item in pairs( inv ) do
		data = data..tostring( index ).."="..tostring( item )..","
	end

	data = data .."#"

	for index, equipped in pairs( eq ) do

		local eq_string

		if equipped == true then
			eq_string = "0" -- equipped right hand

		elseif equipped == false then
			eq_string = "1" -- equipped left hand

		else
			eq_string = "-1" -- unequipped
		end

		data = data..tostring( index ).."="..eq_string..","
	end

	if not file.Exists( "lscs", "DATA" ) then
		file.CreateDir( "lscs" )
	end

	if not file.Exists( "lscs/"..ID, "DATA" ) then
		file.CreateDir( "lscs/"..ID )
	end

	file.Write( "lscs/"..ID.."/inventory.txt", data )
end

function meta:lscsReadInventory()
	local ID = self:AccountID()

	if not ID then return end

	if not file.Exists( "lscs/"..ID, "DATA" ) then return end

	local file_data = file.Read( "lscs/"..ID.."/inventory.txt", "DATA" )

	if not file_data then return end -- can this fail? i dont know...  probably yes.

	local data = string.Explode( "#", file_data )

	local inventory_string = data[1]
	local equipped_string = data[2]

	local inventory = {}
	local equipped = {}

	if inventory_string and inventory_string ~= "" then
		for _, entry in pairs( string.Explode( ",", inventory_string ) ) do
			local item_piece = string.Explode( "=", entry ) 
			local index = tonumber( item_piece[1] )
	
			if not index then continue end

			inventory[ index ] = item_piece[ 2 ]
		end
	end

	if equipped_string and equipped_string ~= "" then
		for _, entry in pairs( string.Explode( ",", equipped_string ) ) do
			local item_piece = string.Explode( "=", entry ) 
			local index = tonumber( item_piece[1] )

			if not index then continue end

			equipped[ index ] = NumberToEquippedEntry[ tonumber( item_piece[ 2 ] ) ]
		end
	end

	self:lscsWipeInventory() -- clear original inventory

	for index, item in pairs( inventory ) do
		self:lscsAddInventory( item, equipped[ index ] )
	end
end

hook.Add( "LSCS:PlayerInventory", "!!!lscs_inventory_saver", function( ply, item, index )

	-- no code is perfect without atleast one timer.Simple
	-- its actually needed because this hook is called before the item is actually picked-up
	-- ( its so this hook could be used to prevent item-picking up )

	timer.Simple(0, function()
		if not IsValid( ply ) then return end

		ply:lscsWriteInventory() -- ideally you would only add a single item in your saved .txt instead of rewriting it entirely
	end )
end )

hook.Add( "LSCS:OnPlayerDroppedItem", "!!!lscs_inventory_saver", function( ply, item_entity )
	ply:lscsWriteInventory() -- ideally you would only remove the dropped item from your saved .txt instead of rewriting said .txt entirely
end )

hook.Add( "LSCS:OnPlayerEquippedItem", "!!!lscs_inventory_saver", function( ply, item )
	ply:lscsWriteInventory() -- ideally you would only change the equipped state in your saved .txt of this single item instead of rewriting said .txt entirely
end)

hook.Add( "LSCS:OnPlayerUnEquippedItem", "!!!lscs_inventory_saver", function( ply, item )
	ply:lscsWriteInventory() -- ideally you would only change the equipped state in your saved .txt of this single item instead of rewriting said .txt entirely
end)

hook.Add( "PlayerInitialSpawn", "!!!lscs_inventory_saver", function( ply )
	-- ply:Give("weapon_lscs") -- shouldn't be needed
	ply:lscsReadInventory()
end )

--[[
-- alternative to playerinitialspawn hook above:
hook.Add( "LSCS:OnPlayerFullySpawned", "!!!lscs_inventory_saver", function( ply )
	-- ply:Give("weapon_lscs") -- shouldn't be needed
	ply:lscsReadInventory()
	ply:lscsCraftSaber()
end )
]]

-- more info about inventory saving:
-- https://github.com/Blu-x92/lscs_public/blob/main/zz_templates_and_info/how_to_save_and_restore_inventory.lua

 -- for more functions and info see:
 -- https://raw.githubusercontent.com/Blu-x92/lscs_public/main/zz_templates_and_info/useful_lua_functions.txt
