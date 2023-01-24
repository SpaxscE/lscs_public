
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
	self.LifeTime = 0.2
	self.DieTime = CurTime() + self.LifeTime

	self:Spark( self.Pos )
	self:Smoke( self.Pos )
end


function EFFECT:Smoke( pos )
	local emitter = ParticleEmitter( pos, false )
	
	for i = 0,1 do
		local particle = emitter:Add( Materials[ math.random(1,table.Count( Materials )) ], pos )
		
		local vel = VectorRand() * math.Rand(10,30)
		
		if particle then			
			particle:SetVelocity( vel )
			particle:SetDieTime( math.Rand(0.5,1.5) )
			particle:SetAirResistance( 10 ) 
			particle:SetStartAlpha( 50 )
			particle:SetStartSize( 10 )
			particle:SetEndSize( 25 )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 40,40,40 )
			particle:SetGravity( Vector(0,0,200) )
			particle:SetCollide( false )
		end
	end
	
	emitter:Finish()
end

function EFFECT:Spark( pos )
	local emitter = ParticleEmitter( pos, false )
	
	for i = 0, 10 do
		local particle = emitter:Add( "sprites/rico1", pos )
		
		local vel = VectorRand() * 100
		
		if particle then
			particle:SetVelocity( vel )
			particle:SetAngles( vel:Angle() + Angle(0,90,0) )
			particle:SetDieTime( 0.5 )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 1 )
			particle:SetEndSize( 0.25 )
			particle:SetRoll( math.Rand(-100,100) )
			particle:SetRollDelta( math.Rand(-100,100) )
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )
			particle:SetAirResistance( 0 )
			particle:SetColor( 255, 150, 0 )
			particle:SetGravity( Vector(0,0,-600) )
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
	render.DrawSprite( self.Pos, 25 * Scale, 25 * Scale, Color( 255, 100, 0, 255) ) 
end
