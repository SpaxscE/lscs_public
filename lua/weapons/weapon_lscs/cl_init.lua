include( "shared.lua" )
include("sh_combo.lua")
include("sh_animations.lua")
include("cl_worldmodel.lua")
include("cl_effects.lua")

SWEP.Slot = 0
SWEP.SlotPos = 0

language.Add( "lscsGlowstick", "Lightsaber" )

function SWEP:DoDrawCrosshair( x, y )
	--surface.SetDrawColor( 0, 250, 255, 255 )
	--surface.DrawOutlinedRect( x - 32, y - 32, 64, 64 )
	return true
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( "n", "WeaponIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:CalcView( ply, pos, angles, fov )
	local attachment = ply:GetAttachment( ply:LookupAttachment( "eyes" ) )

	local pos = ply:GetShootPos()

	if attachment then
		pos = attachment.Pos
	end

	local view = {}

	local clamped_angles = Angle( math.max( angles.p, -60 ), angles.y, angles.r )

	local endpos = pos - clamped_angles:Forward() * 70 + clamped_angles:Up() * 12

	local trace = util.TraceHull({
		start = pos,
		endpos = endpos,
		mask = MASK_SOLID_BRUSHONLY,
		mins = Vector(-5,-5,-5),
		maxs = Vector(5,5,5),
		filter = { ply },
	})
	
	if (trace.HitPos - pos):Length() < 1 then
		view.origin = endpos
	else
		view.origin = trace.HitPos
	end

	view.angles = angles
	view.fov = 90
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
