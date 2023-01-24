--DO NOT EDIT OR REUPLOAD THIS FILE


EFFECT.mat = Material( "particle/warp1_warp" )
EFFECT.mat2 = Material( "effects/select_ring" )
EFFECT.mat3 = Material( "particle/smokesprites_0001" )

function EFFECT:Init( data )
	self.Ent = data:GetEntity()

	self.LifeTime = 0.4
	self.DieTime = CurTime() + self.LifeTime

	if not IsValid( self.Ent ) then self.Ready = true return end

	self.Pos = self.Ent:GetShootPos()
	self.Dir = data:GetNormal()
	self.mat3 = Material( "particle/smokesprites_000"..math.random(1,9) )

	self.Ready = true
end

function EFFECT:Think()
	if not self.Ready then return true end

	if self.DieTime < CurTime() or not IsValid( self.Ent ) then 
		return false
	end

	return true
end

function EFFECT:Render()
	if not self.Ready or not IsValid( self.Ent ) then return end

	local Scale = (self.DieTime - CurTime()) / self.LifeTime
	local InvScale =  (1 - Scale)

	render.SetMaterial( self.mat3 )
	render.DrawSprite( self.Pos + self.Dir * 200 * Scale, 100 * InvScale, 100 * InvScale, Color( 150,200,255,50 ) )

	for i = 1, 3 do
		local Scale = (self.DieTime - CurTime()) / self.LifeTime / 3 * i

		local Pos = self.Pos + self.Dir * 200 * Scale
		render.SetMaterial( self.mat )
		render.DrawSprite( Pos, 150 *  Scale, 150 *  Scale, Color( 255,255,255,255 ) )
	end
end
