include( "shared.lua" )
include("sh_combo.lua")
include("sh_animations.lua")

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.WorldModel = {}

language.Add( "lscsGlowstick", "Lightsaber" )

function SWEP:GetWorldModel( handID )
	if handID then
		return self.WorldModel[ handID ]
	else
		return self.WorldModel
	end
end

function SWEP:UpdateWorldModel( hand , hiltobject )
	if hand == self.HAND_RIGHT then
		if IsValid( self.WorldModel[ self.HAND_RIGHT ] ) then
			self.WorldModel[ self.HAND_RIGHT ]:Remove()
		end

		if hiltobject then
			local WorldModel = ClientsideModel( hiltobject.mdl )
			WorldModel:SetNoDraw( true )
			self.WorldModel[ self.HAND_RIGHT ] = WorldModel
		end
	end

	if hand == self.HAND_LEFT then
		if IsValid( self.WorldModel[ self.HAND_LEFT ] ) then
			self.WorldModel[ self.HAND_LEFT ] :Remove()
		end

		if hiltobject then
			local WorldModel = ClientsideModel( hiltobject.mdl )
			WorldModel:SetNoDraw( true )
			self.WorldModel[ self.HAND_LEFT ] = WorldModel
		end
	end
end

function SWEP:ClearWorldModel()
	for _, mdl in pairs( self.WorldModel ) do
		if not IsValid( mdl ) then continue end

		mdl:Remove()
	end
end

function SWEP:DoDrawCrosshair( x, y )
	--surface.SetDrawColor( 0, 250, 255, 255 )
	--surface.DrawOutlinedRect( x - 32, y - 32, 64, 64 )
	return true
end

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( "n", "WeaponIcons", x + wide/2, y + tall*0.2, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:DrawWorldModelTranslucent( flags )
	local ply = self:GetOwner()

	if not IsValid( ply ) then return end

	local BladeID = 1

	for handID, hiltObject in pairs( self:GetHiltData() ) do
		local WorldModel = self:GetWorldModel( handID )

		if not IsValid( WorldModel ) then continue end

		local data = hiltObject.info.ParentData[ self.HAND_STRING[ handID ] ]

		local offsetVec = data.pos
		local offsetAng = data.ang
		local boneid = ply:LookupBone( data.bone )

		if not boneid then continue end

		local matrix = ply:GetBoneMatrix( boneid )

		if not matrix then continue end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		WorldModel:SetPos( newPos )
		WorldModel:SetAngles( newAng )
		WorldModel:SetupBones()
		WorldModel:DrawModel()

		local Positions = hiltObject.info.GetBladePos( WorldModel )
		for _, PosData in ipairs( Positions ) do

			self:DrawBlade( BladeID, PosData, self:GetBladeData( handID ) )

			BladeID = BladeID + 1
		end
	end
end

function SWEP:DrawBlade( BladeID, PosData, bladeObject )
	local Mul = self:GetLength()

	if Mul <= 0 then return end

	local length = bladeObject.length

	local width = bladeObject.width
	local actual_width = width + math.Rand(0,bladeObject.widthWiggle)

	local pos = PosData.pos
	local dir = PosData.dir

	local w12 = width * 12
	local w32 = width * 32

	local color_blur = bladeObject.color_blur
	local color_core = bladeObject.color_core

	local Frac = 1 * Mul --self:DoBladeTrace( pos, up, 2 ).Fraction

	render.SetMaterial( bladeObject.material_glow )
	render.DrawSprite( pos, w32, w32, color_blur )

	-- inefficient pls replace
	for i = 0, math.Round( (length - 1) * Frac, 0 ) do
		render.DrawSprite( pos + dir * i, w12, w12, color_blur ) 
	end

	local EndPos = pos + dir * math.max(length - 0.9,0) * Frac

	render.SetMaterial( bladeObject.material_core )
	render.DrawBeam( pos, EndPos, actual_width , 1, 1, color_core )

	render.SetMaterial( bladeObject.material_core_tip )
	render.DrawBeam( EndPos, EndPos + dir, actual_width , width, 0.1, color_core )	
end

function SWEP:DrawWorldModel( flags )
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

function SWEP:OnRemove()
	self:ClearWorldModel()
end
