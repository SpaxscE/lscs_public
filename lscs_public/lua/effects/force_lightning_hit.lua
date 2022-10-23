--DO NOT EDIT OR REUPLOAD THIS FILE

local DecalMat = Material( util.DecalMaterial( "FadingScorch" ) )
function EFFECT:Init( data )
	self.Pos = data:GetOrigin()

	self.mat = Material( "sprites/light_glow02_add" )
	
	self.LifeTime = 0.5
	self.DieTime = CurTime() + self.LifeTime
	self.DieTimeGlow = CurTime() + 0.2

	local Col = self.Col
	local Pos = self.Pos
	local Dir = data:GetNormal()
	
	local emitter = ParticleEmitter( Pos, false )

	local trace = util.TraceLine( {
		start = Pos - Dir * 5,
		endpos = Pos + Dir * 5,
	} )

	if trace.Hit and not trace.HitNonWorld then
		util.DecalEx( DecalMat, trace.Entity, trace.HitPos + trace.HitNormal, trace.HitNormal, Color(255,255,255,255), math.Rand(0.4,0.8), math.Rand(0.4,0.8) )
	end

	for i = 0, 3 do
		local particle = emitter:Add( "sprites/rico1", Pos )
		
		local vel = VectorRand() * 100 + Dir * math.Rand(120,140)
		
		if particle then
			particle:SetVelocity( vel )
			particle:SetAngles( vel:Angle() + Angle(0,90,0) )
			particle:SetDieTime( math.Rand(1,2) )
			particle:SetStartAlpha( math.Rand( 200, 255 ) )
			particle:SetEndAlpha( 0 )
			particle:SetStartSize( 1 )
			particle:SetEndSize( 0.5 )
			particle:SetRoll( math.Rand(-100,100) )
			particle:SetRollDelta( math.Rand(-100,100) )
			particle:SetCollide( true )
			particle:SetBounce( 0.5 )
			particle:SetAirResistance( 0 )
			particle:SetColor( 255, 255, 255 )
			particle:SetGravity( Vector(0,0,-600) )
		end
	end

	self.Emitter = emitter
end

function EFFECT:Think()
	if self.DieTime < CurTime() then 
		if self.Emitter then
			self.Emitter:Finish()
		end

		if self.snd then
			self.snd:Stop()
		end

		return false
	end

	return true
end

local Mat = Material("particle/particle_glow_05_addnofog")
function EFFECT:Render()
	local Scale = (self.DieTimeGlow - CurTime()) / 0.2
	if Scale > 0 then
		render.SetMaterial( self.mat )
		render.DrawSprite( self.Pos, 24 * Scale, 24 * Scale, Color( 150, 150, 255, 255) )
	end
end
