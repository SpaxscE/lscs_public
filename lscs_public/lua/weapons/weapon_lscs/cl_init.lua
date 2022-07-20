include( "shared.lua" )
include("sh_combo.lua")
include("sh_animations.lua")
include("sh_blockpoints.lua")
include("cl_worldmodel.lua")
include("cl_effects.lua")

SWEP.Slot = 0
SWEP.SlotPos = 0

language.Add( "lscsGlowstick", "Lightsaber" )

local circles = include("lscs/autorun/cl_circles.lua")

local X = ScrW() - 110
local Y = ScrH() - 100

local BP_BG = circles.New(CIRCLE_OUTLINED, 126, 0, 0, 12)
BP_BG:SetColor( Color(0, 0, 0, 200) )
BP_BG:SetX( X )
BP_BG:SetY( Y )

local BP = circles.New(CIRCLE_OUTLINED, 125, 0, 0, 10)
BP:SetColor( Color(255, 0, 0, 255) )
BP:SetX( X )
BP:SetY( Y )

local CH_BG = circles.New(CIRCLE_OUTLINED, 106, 0, 0, 12)
CH_BG:SetColor( Color(0, 0, 0, 200) )
CH_BG:SetX( X )
CH_BG:SetY( Y )

local CH = circles.New(CIRCLE_OUTLINED, 105, 0, 0, 10)
CH:SetColor( Color(255, 200, 0, 255) )
CH:SetX( X )
CH:SetY( Y )

local mat_xhair = Material( "sprites/hud/v_crosshair1" )
local mat_glow = Material( "sprites/light_glow02_add" )
local mat_glow_combo = Material( "lscs/effects/lightsaber_core" )
local mat_glow_combo_tip = Material( "lscs/effects/lightsaber_tip" )

local COLOR_WHITE = Color( 255, 255, 255, 255 )
local VECTOR_NULL = Vector(0,0,0)

local segmentLength = 5
local segmentSpace = 10

local OldCombo
local ComboIcon = Material("entities/item_stance_yongli.png")

function SWEP:DrawHUD()
	local ply = LocalPlayer()

	local combo = self:GetCombo()

	local segmentDist = segmentLength + segmentSpace
	local ActiveValueCH = 160 * self:GetComboHits()
	local ActiveValueBP = (160 /  self:GetMaxBlockPoints()) * self:GetBlockPoints()

	if combo ~= OldCombo then
		OldCombo = combo

		local mat = "entities/"..combo.class..".png"
		if file.Exists( "materials/"..mat, "GAME" ) then
			ComboIcon = Material( mat )
		else
			ComboIcon = nil
		end
	end

	if ComboIcon then
		surface.SetMaterial( ComboIcon )
		surface.SetDrawColor( COLOR_WHITE )
		surface.DrawTexturedRectRotated( X - 170, Y + 5, 128,128, 0 )
	end
	draw.SimpleText( combo.name, "LSCS_FONT", X - 170, Y + 80, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	draw.NoTexture()

	-- the way im using circles is probably not ideal...  but fuck it, it looks so awesome.  This is probably the thing that will pop up in your profiler
	local Offset = 150
	for A = 0, 170 - segmentDist, segmentDist do
		local Start = Offset + A

		CH_BG:SetStartAngle( Start - 1 )
		CH_BG:SetEndAngle( Start  + segmentLength + 1 )
		CH_BG()

		if A < ActiveValueCH then
			CH:SetStartAngle( Start  )
			CH:SetEndAngle( Start  + segmentLength )
			CH()
		end

		if not combo.AutoBlock then continue end

		BP_BG:SetStartAngle( Start - 1 )
		BP_BG:SetEndAngle( Start  + segmentLength + 1 )
		BP_BG()

		if A < ActiveValueBP then
			BP:SetStartAngle( Start  )
			BP:SetEndAngle( Start  + segmentLength )
			BP()
		end
	end

	local Pos = ply:GetPos()

	if self:IsComboActive() then return end	

	for _,v in ipairs( player.GetAll() ) do -- oh no he did it again... How else would you do it tho?
		if v == ply or (v:GetPos() - Pos):Length() > 400 then continue end

		local _pos = self:GetPlayerBlockPos( v )

		if _pos and _pos ~= VECTOR_NULL then
			local Pos2D = _pos:ToScreen()
			if not Pos2D.visible then continue end

			local BlockDistance = self:GetBlockDistanceTo( _pos )

			local Col

			if BlockDistance < self:GetBlockDistanceNormal() then
				if BlockDistance < self:GetBlockDistancePerfect() then
					Col = Color( 0, 255, 0, 255 ) -- why
				else
					Col = Color( 255, 255, 0, 255 ) -- am i not
				end
			else
				Col = Color( 255, 0, 0, 255 ) -- caching these?
			end

			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )

			if self:GetPlayerCurComboUnblockable( v ) then
				draw.SimpleText( "!", "LSCS_BLOCK_FONT", Pos2D.x, Pos2D.y, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				surface.SetMaterial( mat_xhair )
				surface.DrawTexturedRectRotated( Pos2D.x, Pos2D.y, 40, 40, 0 )
			end

			surface.SetDrawColor( Col.r * 0.5, Col.g * 0.5, Col.b * 0.5, Col.a )
			local SZ = 1000 * self:GetAttackMultiplier( v )
			surface.SetMaterial( mat_glow )
			surface.DrawTexturedRectRotated( Pos2D.x, Pos2D.y, SZ, SZ, 0 )
		end
	end
end

function SWEP:GetPlayerBlockPos( ply )
	if not IsValid( ply ) or not ply.GetActiveWeapon then return false end

	local wep = ply:GetActiveWeapon()

	if not IsValid( wep ) or not wep.LSCS or not wep.GetBlockPos then return false end

	return wep:GetBlockPos()
end

function SWEP:GetPlayerCurComboUnblockable( ply )
	if not IsValid( ply ) or not ply.GetActiveWeapon then return false end

	local wep = ply:GetActiveWeapon()

	if not IsValid( wep ) or not wep.LSCS or not wep.CurComboUnblockable then return false end

	return wep:CurComboUnblockable()
end

function SWEP:GetAttackMultiplier( ply )
	if not IsValid( ply ) or not ply.GetActiveWeapon then return false end

	local wep = ply:GetActiveWeapon()

	if not IsValid( wep ) or not wep.LSCS or not wep.GetComboHits then return false end

	return wep:GetComboHits()
end

local circle = Material( "vgui/circle" )
local size = 5

function SWEP:DoDrawCrosshair( X, Y )
	local ply = LocalPlayer()

	surface.SetMaterial( circle )
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawTexturedRect( X - size * 0.5 + 1, Y - size * 0.5 + 1, size, size )

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( X - size * 0.5, Y - size * 0.5, size, size )

	draw.NoTexture()

	return true
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( "n", "WeaponIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:CalcView( ply, pos, angles, fov )

	local view = {}
	view.origin = ply:lscsGetViewOrigin()
	view.angles = ply:EyeAngles()
	view.fov = fov
	view.drawviewer = true

	return view
end

function SWEP:Reload()
end

function SWEP:OnActiveChanged( oldActive, active )
end

function SWEP:OnTick()
end

function SWEP:OnRemove()
	self:ClearWorldModel()
	self:ClearBladeModel()
end

function SWEP:EmitSoundUnpredicted( sound )
	-- dont do anything on client
end

surface.CreateFont( "LSCS_BP_FONT", {
	font = "Verdana",
	extended = false,
	size = 16,
	weight = 2000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "LSCS_BLOCK_FONT", {
	font = "Verdana",
	extended = false,
	size = 60,
	weight = 2000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )