
function LSCS:SetHilt( ply, hilt_right, hilt_left )
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

function LSCS:SetBlade( ply, blade_right, blade_left )
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

function LSCS:GetHilt( name )
	return LSCS.Hilt[ name ]
end

function LSCS:GetBlade( name )
	return LSCS.Blade[ name ]
end

function LSCS:ClassToItem( class )
	local words = string.Explode( "_", class )
	local type = words[ 2 ]
	local id = words[ 3 ]

	if type == "saberhilt" then
		return LSCS.Hilt[ id ]
	end
	if type == "crystal" then
		return LSCS.Blade[ id ]
	end

	return false
end

function LSCS:RegisterHilt( data )
	if not data.id or not data.mdl or not data.info then return end

	local class = "item_saberhilt_"..data.id

	LSCS.Hilt[ data.id ] = {
		id = data.id,
		name = data.PrintName,
		type = "hilt",
		Type = "Hilt",
		class = class,
		mdl = data.mdl,
		info = data.info,
	}

	local ENT = {}

	ENT.Base = "lscs_hilt_base"

	ENT.PrintName = data.PrintName
	ENT.Author = data.Author
	ENT.Category = "[LSCS] - Hilts"

	ENT.Spawnable       = true
	ENT.AdminSpawnable  = false

	ENT.ID = data.id
	ENT.MDL = data.mdl

	scripted_ents.Register( ENT, class )
end

function LSCS:RegisterBlade( data )
	if not data.id then return end

	local class = "item_crystal_"..data.id

	LSCS.Blade[ data.id ] = {
		id = data.id,
		name = data.PrintName,
		type = "crystal",
		Type = "Crystal",
		class = class,
		color_blur = data.color_blur or Color(0,65,255),
		color_core = data.color_core or color_white,
		length = data.length or 45,
		width = data.width or 0.9,
		widthWiggle = data.widthWiggle or 0.6,
		material_core_tip = data.material_core_tip or Material( "lscs/effects/lightsaber_tip" ),
		material_core = data.material_core or Material( "lscs/effects/lightsaber_core" ),
		material_glow_start = data.material_glow_start or Material( "lscs/effects/lightsaber_glow" ),
		material_glow = data.material_glow or Material( "lscs/effects/lightsaber_blade" ),
		material_trail = data.material_trail or Material( "lscs/effects/lightsaber_trail" ),
		dynamic_light = (data.dynamic_light == true),
		sounds = {
			Attack = (data.sounds.Attack or "saber_hup"),
			Activate = (data.sounds.Activate or "saber_turnon"),
			Disable = (data.sounds.Disable or "saber_turnoff"),
			Idle =  (data.sounds.Idle or "saber/saberhum4.wav"),
		}
	}

	local ENT = {}

	ENT.Base = "lscs_crystal_base"

	ENT.PrintName = data.PrintName
	ENT.Author = data.Author
	ENT.Category = "[LSCS] - Crystals"

	ENT.Spawnable       = true
	ENT.AdminSpawnable  = false

	ENT.ID = data.id

	scripted_ents.Register( ENT, class )
end

LSCS.Timeout = LSCS.Timeout or 0

LSCS.Reload = function()

	local Time = CurTime()
	if LSCS.Timeout > Time then 
		print("[LSCS] - refusing refresh ["..Time.."]")
		return
	else
		print("[LSCS] - initialized ["..Time.."]")
	end
	LSCS.Timeout = CurTime() + 1

	for _, filename in pairs( file.Find("lscs/autorun/*.lua", "LUA") ) do
		if string.StartWith( filename, "sv_") then -- sv_ prefix only load serverside
			if SERVER then
				include("lscs/autorun/"..filename)
			end

			continue
		end

		if string.StartWith( filename, "cl_") then -- cl_ prefix only load clientside
			if SERVER then
				AddCSLuaFile("lscs/autorun/"..filename)
			else
				include("lscs/autorun/"..filename)
			end

			continue
		end

		-- everything else is shared
		if SERVER then
			AddCSLuaFile("lscs/autorun/"..filename)
		end
		include("lscs/autorun/"..filename)
	end

	-- combo files
	COMBO = {} -- yeah this can cause conflicts if someone happens to have a global table with the same name somewhere in his gamemode. 
	for _, filename in pairs( file.Find("lscs/combos/*.lua", "LUA") ) do
		if SERVER then
			AddCSLuaFile("lscs/combos/"..filename)
		end

		table.Empty( COMBO )

		include("lscs/combos/"..filename)

		LSCS[ COMBO.Name ] = {
			Name = COMBO.PrintName,
			Description = COMBO.Description,
			HoldType = COMBO.HoldType,
			Attacks = table.Copy( COMBO.Attacks ),
		}

		table.Empty( COMBO )
	end
end

LSCS:Reload()