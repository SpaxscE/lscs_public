AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName = "test"
ENT.Author = "me"
ENT.Category = "test"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

if SERVER then
	function ENT:Initialize()
		self:SetModel( "models/Items/combine_rifle_ammo01.mdl" )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		self:SetCollisionGroup( COLLISION_GROUP_NONE )
	end
else
	ENT.Positions = {}
	ENT.BeamMaterial = Material( "trails/laser" )

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTranslucent()
		self:CalcTrail()
	end

	function ENT:CalcTrail()
		local Length = 45
		local LifeTime = 2
		local CurTime = CurTime()

		local MyDir = self:GetUp()
		local MyPos = self:GetPos()

		for id, data in pairs( self.Positions ) do
			if CurTime - data.time > LifeTime then
				self.Positions[id] = nil
			end
		end

		local data = {
			time = CurTime,
			pos = MyPos,
			dir = MyDir,
		}
		table.insert(self.Positions, data)
		table.sort(self.Positions, function( a, b ) return a.time > b.time end )

		self:DrawTrail( MyPos, MyDir, CurTime, LifeTime, Length )
	end

	function ENT:DrawTrail( MyPos, MyDir, CurTime, LifeTime, Length )
		render.SetMaterial( self.BeamMaterial )

		local prev = {
			pos = MyPos,
			dir = MyDir,
			time = CurTime
		}

		local idx = 0
		for _, cur in ipairs( self.Positions ) do
			local startpos = prev.pos
			local startdir = prev.dir

			local endpos = cur.pos
			local enddir = cur.dir

			local subtract = endpos - startpos

			local direction = subtract:GetNormalized()
			local distance = subtract:Length()

			for i = 1, distance,1 do
				idx = idx + 1

				if idx > 50 then
					break
				end

				local _pos = startpos + direction * i
				local _dir = startdir + (enddir - startdir) / distance * i
				local _time = prev.time + (cur.time - prev.time) / distance * i
				local _alpha = math.max( (_time + LifeTime - CurTime) / LifeTime, 0)

				local _alpha2 = math.max(_alpha - 0.4,0) ^ 2
				local inv_alpha2 = math.max(1 - _alpha2,0)

				local _c = 255 * _alpha2
				local FadeColor = Color(_c,60 * inv_alpha2 + _c,255 * inv_alpha2 + _c, 255 * _alpha2 + 255 * _alpha * inv_alpha2 )

				render.DrawBeam( _pos, _pos + _dir * Length, 40, 1, 1, FadeColor )
			end
			
			prev = {
				pos = cur.pos,
				dir = cur.dir,
				time = cur.time
			}
		end
	end
end