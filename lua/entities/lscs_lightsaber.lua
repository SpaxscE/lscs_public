AddCSLuaFile()

ENT.Base = "lscs_hilt"

ENT.PrintName = "Lightsaber"
ENT.Author = "Blu-x92 / Luna"
ENT.Category = "[LSCS]"

ENT.Spawnable       = true
ENT.AdminSpawnable  = false

ENT.MDL = "models/lscs/weapons/katarn.mdl"
ENT.MDL_INFO = {
	["RH"] = {
		bone = "ValveBiped.Bip01_R_Hand",
		pos = Vector(4.25, -1.5, -1),
		ang = Angle(172, 0, 10),
	},
	["LH"] = {
		bone = "ValveBiped.Bip01_L_Hand",
		pos = Vector(4.25, -1.5, 1),
		ang = Angle(8, 0, -10),
	},
}

ENT.BladeLength = 45

ENT.SwingSound = "saber_hup"
ENT.TurnOnSound = "saber_turnon"
ENT.TurnOffSound = "saber_turnoff"

sound.Add( {
	name = "saber_hup",
	channel = CHAN_STATIC,
	volume = 0.35,
	level = 110,
	pitch = { 100, 100 },
	sound = {
		"saber/saberhup1.mp3",
		"saber/saberhup2.mp3",
		"saber/saberhup3.mp3",
		"saber/saberhup5.mp3",
		"saber/saberhup6.mp3",
		"saber/saberhup7.mp3",
		"saber/saberhup8.mp3",
		"saber/saberhup9.mp3",
	}
} )

sound.Add( {
	name = "saber_block",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 100,
	pitch = { 100, 100 },
	sound = {
		"saber/saberblock1.mp3",
		"saber/saberblock2.mp3",
		"saber/saberblock3.mp3",
		"saber/saberblock4.mp3",
		"saber/saberblock5.mp3",
		"saber/saberblock6.mp3",
		"saber/saberblock7.mp3",
		"saber/saberblock8.mp3",
		"saber/saberblock9.mp3",
	}
} )

sound.Add( {
	name = "saber_pblock",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 100,
	pitch = { 100, 100 },
	sound = {
		"saber/saberbounce1.mp3",
		"saber/saberbounce2.mp3",
		"saber/saberbounce3.mp3",
	}
} )

sound.Add( {
	name = "saber_turnon",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 75,
	pitch = { 100, 100 },
	sound = "saber/saberon.mp3",
} )

sound.Add( {
	name = "saber_turnoff",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 75,
	pitch = { 100, 100 },
	sound = "saber/saberoff.mp3",
} )

sound.Add( {
	name = "saber_hum",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 100,
	pitch = { 100, 100 },
	sound = {
		"saber/saberhum1.wav",
		"saber/saberhum2.wav",
		"saber/saberhum3.wav",
		"saber/saberhum4.wav",
		"saber/saberhum5.wav",
	}
} )

sound.Add( {
	name = "saber_hit",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 100,
	pitch = { 100, 100 },
	sound = {
		"saber/saberhit1.mp3",
		"saber/saberhit2.mp3",
		"saber/saberhit3.mp3",
	}
} )

sound.Add( {
	name = "saber_hitwall",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 100,
	pitch = { 95, 105 },
	sound = {
		"saber/saberhitwall1.mp3",
		"saber/saberhitwall2.mp3",
		"saber/saberhitwall3.mp3",
	}
} )

sound.Add( {
	name = "saber_hitwall_spark",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 100,
	pitch = { 95, 105 },
	sound = {
		"saber/spark1.wav",
		"saber/spark2.wav",
		"saber/spark3.wav",
		"saber/spark4.wav",
		"saber/spark5.wav",
		"saber/spark6.wav",
	}
} )


if CLIENT then
	ENT.BladeElements = {}

	function ENT:DoIdleImpactEffects( trace )
		local effectdata = EffectData()
			effectdata:SetOrigin( trace.HitPos )
		util.Effect( "saber_hit_generic", effectdata, true, true )
	end

	function ENT:GetMaxBeamElements()
		if IsValid( self:GetWeapon() ) then
			return 200
		else
			return 50
		end
	end

	function ENT:GetBladeLifeTime()
		return 0.2
	end

	function ENT:BladeEffectsPrimary( att )
		local Length = self:GetLength()

		if Length <= 0 then return end

		local BladeCol = self:GetBladeColor()

		local Time = CurTime()

		-- start and dir inverted for better looks at the tip
		local Start = att.Pos + att.Ang:Up() * Length
		local Dir = -att.Ang:Up()

		self._bpNext = self._bpNext or 0
		if self._bpNext < Time then
			self._bpNext = Time + 0.015

			local oldest = nil
			local oldest_time = 0

			for k, v in pairs( self.BladeElements ) do
				if Time - v.time > self:GetBladeLifeTime() then
					self.BladeElements[k] = nil
				end
			end

			if self.BladeGlow and Length == self:GetMaxLength() then
				local dlight = DynamicLight( self:EntIndex() )
				if dlight then
					dlight.pos = att.Pos + att.Ang:Up() * Length * 0.5
					dlight.r = BladeCol.x
					dlight.g = BladeCol.y
					dlight.b = BladeCol.z
					dlight.brightness = 2
					dlight.Decay = 100
					dlight.Size = 250
					dlight.DieTime = Time + 0.2
				end
			end

			local data = {
				time = Time,
				pos = Start,
				dir = Dir,
			}

			if self:GetDMGActive() then
				table.insert(self.BladeElements, data)
				table.sort( self.BladeElements, function( a, b ) return a.time > b.time end )
			end
		end

		self:DrawBlade( att.Pos, -Dir, BladeCol, Length )
		self:DrawTrail( Start, Dir, BladeCol, Length, Time, self.BladeElements, wep )
	end

	
	local glow_mat = Material( "lscs/effects/lightsaber_glow" )
	local core_mat = Material( "lscs/effects/lightsaber_core" )
	local tip_mat = Material( "lscs/effects/lightsaber_tip" )
	local blade_mat = Material( "lscs/effects/lightsaber_blade" )

	function ENT:DrawBlade( pos, up, BladeCol, Length )
		local Col = Color( BladeCol.x, BladeCol.y, BladeCol.z, 255 )

		local Frac = self:DoBladeTrace( pos, up, 2 ).Fraction

		render.SetMaterial( glow_mat )
		render.DrawSprite( pos, 32, 32, Col )

		for i = 0, math.Round( (Length - 1) * Frac, 0 ) do
			render.DrawSprite( pos + up * i, 12, 12, Col ) 
		end

		local EndPos = pos + up * math.max(Length - 0.9,0) * Frac
		local RND = math.Rand(0,0.6)

		render.SetMaterial( blade_mat )
		render.DrawBeam( pos, EndPos, 0.9 + RND, 1, 1, Color( 255, 255, 255, 255 ) )

		render.SetMaterial( tip_mat )
		render.DrawBeam( EndPos, EndPos + up * 1, 0.9 + RND, 0.9, 0.1, Color( 255, 255, 255, 255 ) )
	end

	function ENT:DrawTrail( pos, up, BladeCol, Length, Time, tbl, wep )

		local prev = {}

		if self:GetDMGActive() then
			prev = {
				pos = pos,
				dir = up,
				time = Time
			}
		end

		local idx = 0
		for _, v in pairs( tbl ) do
			if prev.pos and prev.dir then
				local _pos = prev.pos
				local _dir = prev.dir
				local dir = (v.pos - _pos):GetNormalized()

				local dist = math.Round( (v.pos - _pos):Length() , 0 )

				for i = 1, dist,1 do
					idx = idx + 1

					if idx > self:GetMaxBeamElements() then
						break
					end

					local _cdir = _dir + (v.dir - _dir) / dist * i
					local _time = prev.time + (v.time - prev.time) / dist * i
					local Alpha = math.max( (_time + self:GetBladeLifeTime() - Time) / self:GetBladeLifeTime(), 0)
					local Alpha2 = math.max(Alpha - 0.4,0) ^ 2

					render.SetMaterial( core_mat )
					render.DrawBeam( _pos + dir * i, _pos + dir * i + _cdir * Length, 40, 1, 1, Color( BladeCol.x, BladeCol.y, BladeCol.z, 100 * Alpha ) )

					if Alpha2 > 0 then
						local _c = 150 * Alpha2
						render.SetMaterial( blade_mat )
						render.DrawBeam( _pos + dir * i, _pos + dir * i + _cdir * Length,3, 1, 1, Color( _c, _c, _c, _c ) )
					end
				end
			end
			
			prev = {
				pos = v.pos,
				dir = v.dir,
				time = v.time
			}
		end
	end
end