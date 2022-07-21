--DO NOT EDIT OR REUPLOAD THIS FILE


EFFECT.mat = Material( "sprites/light_glow02_add" )


function EFFECT:Init( data )
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()

	self.LifeTime = 1
	self.DieTime = CurTime() + self.LifeTime

	if not IsValid( self.Ent ) then return end

	self.Model = ClientsideModel( self.Ent:GetModel(), RENDERGROUP_TRANSLUCENT )

	self.Model:SetMaterial("models/alyx/emptool_glow")
	self.Model:SetColor( Color(255,0,0,255) )
	self.Model:SetParent( self.Ent, 0 )
	self.Model:SetMoveType( MOVETYPE_NONE )
	self.Model:SetLocalPos( Vector( 0, 0, 0 ) )
	self.Model:SetLocalAngles( Angle( 0, 0, 0 ) )
	self.Model:AddEffects( EF_BONEMERGE )

	for i = 0,self.Ent:GetBoneCount() do
		self.Model:ManipulateBoneScale( i, Vector(1,1,1) * 1.1 )
	end

	for i = 0, self.Ent:GetNumBodyGroups() do
		self.Model:SetBodygroup(i, self.Ent:GetBodygroup(i))
	end
end

function EFFECT:Think()
	if self.DieTime < CurTime() or not IsValid( self.Ent ) or (self.Ent.Alive and not self.Ent:Alive()) then 
		if IsValid( self.Model ) then
			self.Model:Remove()
		end

		return false
	end

	if IsValid( self.Model ) then
		self.Model:SetColor( Color(255 * (self.DieTime - CurTime()) / self.LifeTime,0,0,255) )
	end

	return true
end

function EFFECT:Render()
	if not IsValid( self.Ent ) then return end

	local Scale = (self.DieTime - CurTime()) / self.LifeTime
	render.SetMaterial( self.mat )
	render.DrawSprite( self.Ent:LocalToWorld( Vector(0,0,40) ), 250 * Scale, 250 * Scale, Color( 150 * Scale, 0, 0, 150 * Scale ) )
end
	
