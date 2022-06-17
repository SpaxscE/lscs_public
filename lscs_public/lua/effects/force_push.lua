--DO NOT EDIT OR REUPLOAD THIS FILE


EFFECT.mat = Material( "sprites/heatwave" )
EFFECT.mat2 = Material( "effects/select_ring" )


function EFFECT:Init( data )
	self.Ent = data:GetEntity()

	self.LifeTime = 0.4
	self.DieTime = CurTime() + self.LifeTime

	if not IsValid( self.Ent ) then return end

	self.Pos = self.Ent:GetAttachment( self.Ent:LookupAttachment("anim_attachment_lh") ).Pos
	self.Dir = data:GetNormal()
	self.mat3 = Material( "particle/smokesprites_000"..math.random(1,9) )
end

function EFFECT:Think()
	if self.DieTime < CurTime() then 
		return false
	end

	return true
end

function EFFECT:Render()
	local Scale = (self.DieTime - CurTime()) / self.LifeTime
	local InvScale =  (1 - Scale)

	render.SetMaterial( self.mat3 )
	render.DrawSprite( self.Pos + self.Dir * 200 * InvScale, 100 * Scale, 100 * Scale, Color( 150,200,255,50 ) )

	for i = 1, 3 do
		local Scale = (self.DieTime - CurTime()) / self.LifeTime / 3 * i

		local Pos = self.Pos + self.Dir * 200 * InvScale

		render.SetMaterial( self.mat )
		render.DrawSprite( Pos, 150 *  InvScale, 150 *  InvScale, Color( 255,255,255,255 ) )
	end
end
	
