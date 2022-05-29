
function LSCS:GetHilt( name )
	return LSCS.Hilt[ name ]
end

function LSCS:GetBlade( name )
	return LSCS.Blade[ name ]
end

function LSCS:RegisterHilt( data )
	if not data.id or not data.mdl or not data.info then return end

	LSCS.Hilt[ data.id ] = {
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

	scripted_ents.Register( ENT, "item_saberhilt_"..data.id )
end

function LSCS:RegisterBlade( data )
	if not data.id then return end

	LSCS.Blade[ data.id ] = {
		color_blur = data.color_blur or Color(0,65,255),
		color_core = data.color_core or color_white,
		length = data.length or 45,
		glow = (data.glow == true),
		sounds = {
			BladeSound = (data.sounds.BladeSound or "saber_hup"),
			BladeActivateSound = (data.sounds.BladeActivateSound or "saber_turnon"),
			BladeDisableSound = (data.sounds.BladeDisableSound or "saber_turnoff"),
			BladeIdleSound =  (data.sounds.BladeIdleSound or "saber/saberhum4.wav"),
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

	scripted_ents.Register( ENT, "item_crystal_"..data.id )
end

LSCS.Timeout = LSCS.Timeout or 0

LSCS.Reload = function()

	local Time = CurTime()
	if LSCS.Timeout > Time then 
		print("[LSCS] - refusing refresh")
		return
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