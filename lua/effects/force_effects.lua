--DO NOT EDIT OR REUPLOAD THIS FILE

EFFECT.mat2 = Material( "sprites/heatwave" )

function EFFECT:Init( data )
	self.Ent = data:GetEntity()
	self.Pos = data:GetOrigin()

	self.LifeTime = 1
	self.DieTime = CurTime() + self.LifeTime
	self.mat = Material( "particle/smokesprites_000"..math.random(1,9) )
end

function EFFECT:Think()
	if self.DieTime < CurTime() or not IsValid( self.Ent ) then 
		return false
	end

	return true
end

function EFFECT:Render()
	if not IsValid( self.Ent ) then return end

	local Scale = (self.DieTime - CurTime()) / self.LifeTime

	render.SetMaterial( self.mat )
	render.DrawSprite( self.Ent:LocalToWorld( self.Ent:OBBCenter() ), 150 * Scale, 150 * Scale, Color( 150,200,255,50 * Scale ) )
	render.SetMaterial( self.mat2 )
	render.DrawSprite( self.Ent:LocalToWorld( self.Ent:OBBCenter() ), 100 * Scale, 100 * Scale, Color( 255,255,255,255 ) )
end
	
