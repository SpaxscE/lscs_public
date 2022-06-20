include( "shared.lua" )
include("sh_combo.lua")
include("sh_animations.lua")
include("cl_worldmodel.lua")
include("cl_effects.lua")

SWEP.Slot = 0
SWEP.SlotPos = 0

language.Add( "lscsGlowstick", "Lightsaber" )

local mat_xhair = Material( "sprites/hud/v_crosshair1" )
local mat_glow = Material( "sprites/light_glow02_add" )
local VECTOR_NULL = Vector(0,0,0)

function SWEP:DrawHUD()
	local ply = LocalPlayer()
	local Pos = ply:GetPos()

	--draw.RoundedBox( 5, xpos, ypos, sizex, sizey, Color( 0, 0, 0, 200 ) )
	--draw.RoundedBox( 5, xpos + 2, ypos + 2, ((sizex - 4) / 100) * self:GetBlockPoints(), sizey - 4, Color( 255, 0, 0, 200 ) )

	for _,v in ipairs( player.GetAll() ) do
		if v == ply or (v:GetPos() - Pos):Length() > 400 then continue end

		local _pos = self:GetPlayerBlockPos( v )

		if _pos and _pos ~= VECTOR_NULL then
			local Pos2D = _pos:ToScreen()
			if not Pos2D.visible then continue end

			local BlockDistance = self:GetBlockDistanceTo( _pos )

			if BlockDistance < LSCS:GetBlockDistanceNormal() then
				if BlockDistance < LSCS:GetBlockDistancePerfect() then
					surface.SetDrawColor( 0, 255, 0, 255 )
				else
					surface.SetDrawColor( 255, 255, 0, 255 )
				end
			else
				surface.SetDrawColor( 255, 0, 0, 255 )
			end

			surface.SetMaterial( mat_glow )
			surface.DrawTexturedRectRotated( Pos2D.x, Pos2D.y, 100, 100, 0 )

			surface.SetMaterial( mat_xhair )
			surface.DrawTexturedRectRotated( Pos2D.x, Pos2D.y, 32, 32, 0 )
		end
	end
end

function SWEP:GetPlayerBlockPos( ply )
	if not IsValid( ply ) or not ply.GetActiveWeapon then return false end

	local wep = ply:GetActiveWeapon()

	if not IsValid( wep ) or not wep.LSCS or not wep.GetBlockPos then return false end

	return wep:GetBlockPos()
end

local circle = Material( "vgui/circle" )
local size = 5

function SWEP:DoDrawCrosshair( x, y )
	local ply = LocalPlayer()

	local pos = ply:lscsGetViewOrigin() + ply:EyeAngles():Forward() * 100

	local scr = pos:ToScreen()

	if scr.visible then
		surface.SetMaterial( circle )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawTexturedRect( scr.x - size * 0.5 + 1, scr.y - size * 0.5 + 1, size, size )

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( scr.x - size * 0.5, scr.y - size * 0.5, size, size )
	end

	return true
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( "n", "WeaponIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:CalcView( ply, pos, angles, fov )
	local view = {}

	view.origin = pos
	view.angles = angles
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
