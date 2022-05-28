
local Materials = {
	"particle/smokesprites_0001",
	"particle/smokesprites_0002",
	"particle/smokesprites_0003",
	"particle/smokesprites_0004",
	"particle/smokesprites_0005",
	"particle/smokesprites_0006",
	"particle/smokesprites_0007",
	"particle/smokesprites_0008",
	"particle/smokesprites_0009",
	"particle/smokesprites_0010",
	"particle/smokesprites_0011",
	"particle/smokesprites_0012",
	"particle/smokesprites_0013",
	"particle/smokesprites_0014",
	"particle/smokesprites_0015",
	"particle/smokesprites_0016"
}

function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Dir = data:GetNormal()
	self.LifeTime = 0.2
	self.DieTime = CurTime() + self.LifeTime
	
	self:Spark( self.Pos, self.Dir )
end

function EFFECT:Spark( pos, dir )
	local emitter = ParticleEmitter( pos, false )
	
	for i = 0, 20 do
		local particle = emitter:Add( "sprites/rico1", pos )
		
		local vel = VectorRand() * 200 + dir * 80
		
		if particle then
			particle:SetVelocity( vel )
			particle:SetAngles( vel:Angle() + Angle(0,90,0) )
			particle:SetDieTime( math.Rand(0.1,0.2) )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( math.Rand(2,4) )
			particle:SetEndSize( 0 )
			particle:SetRoll( math.Rand(-100,100) )
			particle:SetRollDelta( math.Rand(-100,100) )

			particle:SetAirResistance( 0 )
		end
	end
	
	emitter:Finish()
end

function EFFECT:Think()
	if self.DieTime < CurTime() then return false end
	
	return true
end

local mat = Material( "sprites/light_glow02_add" )

function EFFECT:Render()
	local Scale = (self.DieTime - CurTime()) / self.LifeTime
	render.SetMaterial( mat )
	render.DrawSprite( self.Pos + self.Dir, 150 * Scale, 150 * Scale, Color( 255, 255, 200, 255) ) 
end
