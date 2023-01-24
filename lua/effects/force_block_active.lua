--DO NOT EDIT OR REUPLOAD THIS FILE

function EFFECT:Init( data )
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()
	
	self.mat = Material( "effects/select_ring" )
	
	self.LifeTime = 0.2
	self.DieTime = CurTime() + self.LifeTime

	if not IsValid( self.Ent ) then return end

	self.Model = ClientsideModel( self.Ent:GetModel(), RENDERGROUP_TRANSLUCENT )
	self.Model:SetMaterial("models/alyx/emptool_glow")
	self.Model:SetColor( Color(0,70,150,255) )
	self.Model:SetParent( self.Ent, 0 )
	self.Model:SetMoveType( MOVETYPE_NONE )
	self.Model:SetLocalPos( Vector( 0, 0, 0 ) )
	self.Model:SetLocalAngles( Angle( 0, 0, 0 ) )
	self.Model:AddEffects( EF_BONEMERGE )

	for i = 0,self.Ent:GetBoneCount() do
		self.Model:ManipulateBoneScale( i, Vector(1,1,1) * (1 + math.abs( math.cos( CurTime() * 5 ) ) * 0.2 ) )
	end

	for i = 0, self.Ent:GetNumBodyGroups() do
		self.Model:SetBodygroup(i, self.Ent:GetBodygroup(i))
	end
end

function EFFECT:Think()
	if self.DieTime < CurTime() or not IsValid( self.Ent ) or not self.Ent:Alive() then 
		if IsValid( self.Model ) then
			self.Model:Remove()
		end

		return false
	end
	
	return true
end

function EFFECT:Render()
	if IsValid( self.Ent ) then
		local Pos = self.Ent:GetPos() + Vector(0,0,40)

		local Scale = (self.DieTime - CurTime()) / self.LifeTime

		if IsValid( self.Model ) then
			local A = math.abs( math.cos( CurTime() * 5 ) )
			local InvA = 1 - A

			local r = 0
			local g = 127 * A + 50 * InvA
			local b = 255 * A + 255 * InvA
			local a = 255 * A + 255 * InvA

			self.Model:SetColor( Color(r,g,b,a) )
		end
	end
end
