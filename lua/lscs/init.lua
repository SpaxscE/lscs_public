
if CLIENT then
	LSCS.KeyToForce = LSCS.KeyToForce or {}

	function LSCS:RefreshKeys() -- we don't know how many forcepowers we gonna expect, so a lookup table might be a good idea.
		table.Empty( LSCS.KeyToForce )
		for name, entry in pairs( LSCS.Force ) do
			local ID = entry.cmd:GetInt()

			if not LSCS.KeyToForce[ ID ] then
				LSCS.KeyToForce[ ID ] = {}
			end

			table.insert( LSCS.KeyToForce[ ID ], name ) -- it must be done like this so we can bind multiple forcepowers to the same key
		end
	end
else
	AddCSLuaFile("includes/circles/circles.lua")
end

function LSCS:RegisterDeflectableTracer( tracername )
	if not table.HasValue( LSCS.BulletTracerDeflectable, tracername ) then
		table.insert( LSCS.BulletTracerDeflectable, tracername )
	end
end

LSCS:RegisterDeflectableTracer( "laser_*" ) -- this should pretty much include all laser types, but you can add your own
LSCS:RegisterDeflectableTracer( "ar2tracer_custom" )

function LSCS:AngleBetweenVectors( Vec1, Vec2 )
	local clampDot = math.Clamp( Vec1:Dot( Vec2 ) ,-1,1) -- this clamp took me 1 whole day to figure out in 2014... If the dotproduct of both vectors that are supposedly 1 unit long goes above 1 this can be NAN and cause instant ctd when applied as force...
	local rads = math.acos( clampDot ) -- rad is for nerds

	return math.deg( rads ) -- degrees is what normal humans use
end

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

function LSCS:GetStance( name )
	return LSCS.Stance[ name ]
end

function LSCS:GetForce( name )
	return LSCS.Force[ name ]
end

function LSCS:ClassToItem( class )
	if not isstring( class ) then return end

	local words = string.Explode( "_", class )
	local type = words[ 2 ]
	local id = words[ 3 ]

	if type == "saberhilt" then
		return LSCS.Hilt[ id ]
	end
	if type == "crystal" then
		return LSCS.Blade[ id ]
	end
	if type == "stance" then
		return LSCS.Stance[ id ]
	end
	if type == "force" then
		return LSCS.Force[ id ]
	end

	return false
end

function LSCS:RegisterForce( data )
	if not data.id then return end

	local id = string.lower( data.id )
	local class = "item_force_"..id
	local fallback = function( ply ) end

	LSCS.Force[ id ] = {
		id = id,
		name = data.PrintName,
		description = data.Description,
		author = data.Author,
		type = "force",
		Type = "Force",
		class = class,
		Equip = (data.Equip or fallback),
		UnEquip = (data.UnEquip or fallback),
		StartUse = (data.StartUse or fallback),
		StopUse = (data.StopUse or fallback),
	}

	if data.OnClk then
		hook.Add( "LSCS:PlayerForcePowerThink", id, data.OnClk )
	end

	if CLIENT then
		LSCS.Force[ id ].cmd = CreateClientConVar( "lscs_key_force_"..id, KEY_NONE, true, true )
		LSCS:RefreshKeys()
	end

	local ENT = {}

	ENT.Base = "lscs_force_base"

	ENT.PrintName = data.PrintName
	ENT.Author = data.Author
	ENT.Category = "[LSCS] - Force"

	ENT.Spawnable       = data.Spawnable ~= false
	ENT.AdminSpawnable  = false

	scripted_ents.Register( ENT, class )
end

function LSCS:RegisterHilt( data )
	if not data.id or not data.mdl or not data.info then return end

	local id = string.lower( data.id )
	local class = "item_saberhilt_"..id

	LSCS.Hilt[ id ] = {
		id = id,
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

	ENT.Spawnable = data.Spawnable ~= false
	ENT.AdminSpawnable = false

	ENT.MDL = data.mdl

	scripted_ents.Register( ENT, class )
end

function LSCS:RegisterBlade( data )
	if not data.id then return end

	local id = string.lower( data.id )
	local class = "item_crystal_"..id

	LSCS.Blade[ id ] = {
		id = id,
		name = data.PrintName,
		type = "crystal",
		Type = "Crystal",
		class = class,
		color_blur = data.color_blur or Color(0,65,255),
		color_core = data.color_core or color_white,
		length = data.length or 45,
		width = data.width or 0.9,
		widthWiggle = data.widthWiggle or 0.6,
		mdl = data.mdl,
		mdl_poseparameter = data.mdl_poseparameter,
		material_core_tip = data.material_core_tip or Material( "lscs/effects/lightsaber_tip" ),
		material_core = data.material_core or Material( "lscs/effects/lightsaber_core" ),
		material_glow = data.material_glow or Material( "lscs/effects/lightsaber_glow" ),
		material_trail = data.material_trail or Material( "lscs/effects/lightsaber_trail" ),
		dynamic_light = (data.dynamic_light == true),
		no_trail = (data.no_trail == true),
		sounds = {
			Attack = (data.sounds.Attack or "saber_hup"),
			Attack1 = (data.sounds.Attack1 or "saber_spin1"),
			Attack2 = (data.sounds.Attack2 or "saber_spin2"),
			Attack3 = (data.sounds.Attack3 or "saber_spin3"),
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

	ENT.Spawnable       = data.Spawnable ~= false
	ENT.AdminSpawnable  = false

	ENT.ID = id

	scripted_ents.Register( ENT, class )
end

local function FileIsEmpty( filename )
	if file.Size( filename, "LUA" ) <= 1 then -- this is suspicous
		local data = file.Read( filename, "LUA" )

		if data and string.len( data ) <= 1 then -- confirm its empty
			print("[LSCS] - refusing to load '"..filename.."'! File is Empty!" )

			return true
		end
	end

	return false
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
		if FileIsEmpty( "lscs/combos/"..filename ) then continue end -- sometimes i feel like people just want to troll me. Maximum incompetence honestly.

		if SERVER then
			AddCSLuaFile("lscs/combos/"..filename)
		end

		table.Empty( COMBO )

		include("lscs/combos/"..filename)

		local id = string.lower( COMBO.id )
		local class = "item_stance_"..id

		LSCS.Stance[ id ] = {
			id = id,
			name = COMBO.PrintName,
			description = COMBO.Description,
			author = COMBO.Author,
			type = "stance",
			Type = "Stance",
			class = class,
			HoldType = COMBO.HoldType,
			DeflectBullets = COMBO.DeflectBullets,
			AutoBlock = COMBO.AutoBlock,
			Attacks = table.Copy( COMBO.Attacks ),
			LeftSaberActive = (COMBO.LeftSaberActive == true),
			MaxBlockPoints = COMBO.MaxBlockPoints,
			BPDrainPerHit = COMBO.BPDrainPerHit,
			DamageMul = (COMBO.DamageMultiplier or 1),
			BlockDistanceNormal = COMBO.BlockDistanceNormal,
			BlockDistancePerfect = COMBO.BlockDistancePerfect,
		}

		local ENT = {}

		ENT.Base = "lscs_stance_base"

		ENT.PrintName = COMBO.PrintName
		ENT.Author = COMBO.Author
		ENT.Category = "[LSCS] - Stances"

		ENT.Spawnable       = COMBO.Spawnable ~= false
		ENT.AdminSpawnable  = false

		scripted_ents.Register( ENT, class )

		table.Empty( COMBO )
	end

	-- content, such as hilts, blades, force powers
	for _, filename in pairs( file.Find("lscs/content/*.lua", "LUA") ) do
		if FileIsEmpty( "lscs/content/"..filename ) then continue end -- sometimes i feel like people just want to troll me. Maximum incompetence honestly.

		if SERVER then
			AddCSLuaFile("lscs/content/"..filename)
		end
		include("lscs/content/"..filename)
	end
end

LSCS:Reload()

-- TODO: allow this to be changed in combo file
LSCS.ComboInterupt = {
	["____"] = "b_block_forward_riposte",
	["-45-"] = "b_block_forward_riposte",
	["+45+"] = "b_block_forward_riposte",
	["__S_"] = "b_block_forward_riposte",
	["_A__"] = "b_block_left_riposte",
	["___D"] = "b_block_right_riposte",
	["W__D"] = "b_right_riposte",
	["WA__"] = "b_block_forward_riposte",
	["__SD"] = "b_right_riposte",
	["_AS_"] = "b_block_left_riposte",
	["W___"] = "b_forward_riposte",
}

LSCS.ComboInfo = {
	["____"] = {
		name = "Base Attack",
		order = 1,
		description = "[Mouse 1]",
	},
	["W___"] = {
		name = "Forward Attack",
		order = 2,
		description = "[W]+[Mouse 1]+([Shift] to prioritize)",
	},
	["__S_"] = {
		name = "Reverse Attack",
		order = 3,
		description = "[S]+[Mouse 1]",
	},
	["_A__"] = {
		name = "Left Attack",
		order = 4,
		description = "[A]+[Mouse 1]",
	},
	["___D"] = {
		name = "Right Attack",
		order = 5,
		description = "[D]+[Mouse 1]",
	},
	["W__D"] = {
		name = "Front-Right Attack",
		order = 6,
		description = "[W]+[D]+[Mouse 1]",
	},
	["WA__"] = {
		name = "Front-Left Attack",
		order = 7,
		description = "[W]+[A]+[Mouse 1]",
	},
	["__SD"] = {
		name = "Back-Right Attack",
		order = 8,
		description = "[S]+[D]+[Mouse 1]",
	},
	["_AS_"] = {
		name = "Back-Left Attack",
		order = 9,
		description = "[A]+[S]+[Mouse 1]",
	},
	["W_S_"] = {
		name = "Special Attack",
		order = 10,
		description = "[W]+[S]+[Mouse 1]",
	},
	["-45-"] = {
		name = "Up Attack",
		order = 11,
		description = "while looking UP\nPress [Mouse 1] or [W]+[Mouse 1]",
	},
	["+45+"] = {
		name = "Down Attack",
		order = 12,
		description = "while looking DOWN\nPress [Mouse 1] or [W]+[Mouse 1]",
	},
	["FRONT_DASH"] = {
		name = "Dash Forward",
		order = 13,
		description = "HOLD [SPACE]+[W] then\nPress [Mouse 1] while still in air",
	},
	["BACKFLIP"] = {
		name = "Backflip",
		order = 14,
		description = "HOLD [SPACE]+[S] then\nPress [Mouse 1] while still in air",
	},
	["SLAM"] = {
		name = "Slam",
		order = 15,
		description = "Perform a [Backflip] then\nHOLD [Mouse 1] while still in air",
	},
	["ROLL_RIGHT"] = {
		name = "Dodge Right",
		order = 16,
		description = "HOLD [SPACE]+[D] then\nPress [Mouse 1] while still in air",
	},
	["ROLL_LEFT"] = {
		name = "Dodge Left",
		order = 17,
		description = "HOLD [SPACE]+[A] then\nPress [Mouse 1] while still in air",
	},
}