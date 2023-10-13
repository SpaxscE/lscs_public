AddCSLuaFile()

ENT.Base = "lscs_holocron_base"
DEFINE_BASECLASS( "lscs_holocron_base" )

ENT.Spawnable		= false
ENT.AdminSpawnable		= false

ENT.BeamMat = Material( "trails/electric" )
ENT.GlowMat = Material( "sprites/light_glow02_add" )
ENT.GlowCol = Color(0,127,255,255)
ENT.GlowCol2 = Color(100,150,200,255)

if SERVER then
	function ENT:Initialize()
		BaseClass.Initialize( self )
		self:PhysicsInitBox( Vector(-11,-11,-11), Vector(11,11,11) )
		self:SetColor( Color(40,40,40,255) )
		self:PlayAnimation("open")
	end
else
	local HaloCount = 0
	local HaloEnts = {}

	function ENT:Think()
		for ID = 1, self:GetBoneCount() do
			self:ManipulateBoneAngles( ID, Angle(math.cos( CurTime() * 6 ),math.sin( CurTime() * 3 ), math.cos( CurTime() * 9 ) ) )
		end
	end

	function ENT:Initialize()
		self.smDist = CurTime() + 1
		table.insert( HaloEnts, self )

		HaloCount = table.Count( HaloEnts )
	end

	function ENT:DrawTranslucent()
		self:DrawModel()

		render.SetMaterial( self.GlowMat )
		render.DrawSprite( self:GetPos(), 64, 64, self.GlowCol )

		local D = math.Clamp(1 - (self.smDist - CurTime()),0,1)
		local Dist = 9 * D

		render.SetMaterial( self.BeamMat )
		
		for Z = -1, 1, 2 do
			for X = -1, 1, 2 do
				for Y = -1, 1, 2 do
					local Center =  self:LocalToWorld( Vector(X,Y,Z) )
					local Corner = self:LocalToWorld( Vector(X * Dist,Y * Dist,Z * Dist) )

					render.DrawBeam( Center, Corner, math.Rand(1,2), math.Rand(-1,0), math.Rand(1,1.5), Color( 255, 255, 255, 255 ) )
				end
			end
		end
	
		render.SetMaterial( self.GlowMat )
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:OnRemove()
		for id, e in pairs( HaloEnts ) do
			if e == self or not IsValid( e ) then HaloEnts[ id ] = nil end
		end

		HaloCount = table.Count( HaloEnts )
	end

	local haloColor = Color(0,127,255,255)
	hook.Add( "PreDrawHalos", "lscs_holocron_halo", function()
		if HaloCount == 0 then return end

		halo.Add( HaloEnts, haloColor, 1, 1, math.Rand(0.8,1.2) )
	end )
end