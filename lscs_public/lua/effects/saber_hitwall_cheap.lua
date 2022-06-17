
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

local DecalMat = Material( util.DecalMaterial( "FadingScorch" ) )
function EFFECT:Init( data )
	self.Pos = data:GetOrigin()
	self.Col = data:GetStart() or Vector(255,100,0)
	
	self.mat = Material( "sprites/light_glow02_add" )
	
	self.LifeTime = 0.2
	self.DieTime = CurTime() + self.LifeTime

	local Col = self.Col
	local Pos = self.Pos
	local Dir = data:GetNormal()

	--[[
	local trace = util.TraceLine( {
		start = Pos + Dir * 5,
		endpos = Pos - Dir * 5,
	} )

	if trace.Hit and not trace.HitNonWorld then
		util.DecalEx( DecalMat, trace.Entity, trace.HitPos + trace.HitNormal, trace.HitNormal, Color(255,255,255,255), 0.3, 0.3 )
	end
	]]

	local emitter = ParticleEmitter( Pos, false )

	for i = 0,2 do
		local particle = emitter:Add( Materials[ math.random(1,table.Count( Materials )) ], Pos )
		
		local vel = VectorRand() * 100 + Dir * 40
		
		if particle then			
			particle:SetVelocity( vel )
			particle:SetDieTime( 0.5 )
			particle:SetAirResistance( 1000 ) 
			particle:SetStartAlpha( 50 )
			particle:SetStartSize( 2 )
			particle:SetEndSize( 6 )
			particle:SetRoll( math.Rand(-1,1) )
			particle:SetColor( 40,40,40 )
			particle:SetGravity( Dir * 10 )
			particle:SetCollide( false )
		end
	end

	for i = 0, 3 do
		local particle = emitter:Add( "sprites/rico1", Pos )
		
		local vel = VectorRand() * 100 + Dir * 40
		
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
	if self.DieTime < CurTime() then 
		return false
	end

	return true
end

local mat = Material( "sprites/light_glow02_add" )
function EFFECT:Render()
	local Scale = (self.DieTime - CurTime()) / self.LifeTime
	render.SetMaterial( mat )
	render.DrawSprite( self.Pos, 12, 12, Color( 255 * Scale, 100 * Scale, 0, 255) ) 
end

