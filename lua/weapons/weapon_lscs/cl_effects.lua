SWEP.BladeData = {
	[SWEP.HAND_RIGHT] = {
	},
	[SWEP.HAND_LEFT] = {
	},
}

function SWEP:CalcTrail( HandID, BladeID, PosData, bladeObject, Mul )
	local DMGActive = self:GetDMGActive()
	local LifeTime = self:GetBladeLifeTime()
	local CurTime = CurTime()

	local length = bladeObject.length * (PosData.length_multiplier or 1)

	local cur_pos = PosData.pos + PosData.dir * length
	local cur_dir = -PosData.dir

	if self:CanDoTrail( HandID, BladeID, 0.02 ) then
		for id, data in pairs( self.BladeData[HandID][BladeID].BladePositions ) do
			if CurTime - data.time > LifeTime then
				self.BladeData[HandID][BladeID].BladePositions[id] = nil
			end
		end

		if DMGActive then
			local data = {
				time = CurTime,
				pos = cur_pos,
				dir = cur_dir,
			}

			table.insert(self.BladeData[HandID][BladeID].BladePositions, data)
			table.sort(self.BladeData[HandID][BladeID].BladePositions, function( a, b ) return a.time > b.time end )
		end

		if Mul == 1 and bladeObject.dynamic_light and LSCS.DynamicLight then
			local dlight = DynamicLight( self:EntIndex() * 1000 + HandID * 10 + BladeID )
			if dlight then
				dlight.pos = cur_pos + cur_dir * length * 0.5
				dlight.r = bladeObject.color_blur.r
				dlight.g = bladeObject.color_blur.g
				dlight.b = bladeObject.color_blur.b
				dlight.brightness = 2
				dlight.Decay = 100
				dlight.Size = 125
				dlight.DieTime = CurTime + 0.2
			end
		end
	end

	render.SetMaterial( bladeObject.material_trail )

	self:DrawTrail( cur_pos, cur_dir, CurTime, LifeTime, length, self.BladeData[HandID][BladeID].BladePositions,  bladeObject.color_core, bladeObject.color_blur, DMGActive )
end

local function OverClocked() -- if someone has host_timescale lower than default 1, chances are he wants to make a screenshot. Lets increase detail to maximum in this case for best looks.
	return LSCS.TimeScale < 0.9
end

function SWEP:DrawTrail( MyPos, MyDir, CurTime, LifeTime, Length, Positions, ColorStart, ColorEnd, DMGActive )
	local prev

	if DMGActive then
		prev = {
			pos = MyPos,
			dir = MyDir,
			time = CurTime
		}
	end

	local LoopStep = OverClocked() and 1 or 2

	local idx = 0
	for _, cur in ipairs( Positions ) do
		if prev then
			local startpos = prev.pos
			local startdir = prev.dir

			local endpos = cur.pos
			local enddir = cur.dir

			local subtract = endpos - startpos

			local direction = subtract:GetNormalized()
			local distance = subtract:Length()

			for i = LoopStep, distance,LoopStep do
				idx = idx + 1

				if idx > self:GetMaxBeamElements() then
					break
				end

				local _pos = startpos + direction * i
				local _dir = startdir + (enddir - startdir) / distance * i
				local _time = prev.time + (cur.time - prev.time) / distance * i
				local _alpha = math.max( (_time + LifeTime - CurTime) / LifeTime, 0)

				local _alpha2 = (math.max(_alpha - 0.8,0) / 0.2) ^ 2
				local inv_alpha2 = math.max(1 - _alpha2,0)

				local R = ColorStart.r * _alpha2 + ColorEnd.r * inv_alpha2
				local G = ColorStart.g * _alpha2 + ColorEnd.g * inv_alpha2
				local B = ColorStart.b * _alpha2 + ColorEnd.b * inv_alpha2
				local A = (ColorStart.a * _alpha2 + ColorEnd.a * inv_alpha2) * _alpha

				render.DrawBeam( _pos, _pos + _dir * Length, 12, 1, 1, Color(R, G, B, A ) )
			end
		end

		prev = {
			pos = cur.pos,
			dir = cur.dir,
			time = cur.time
		}
	end
end

function SWEP:CanDoTrail( HandID, BladeID, Next )
	local Time = CurTime()
	if self.BladeData[HandID][BladeID].BladeNext < Time then
		self.BladeData[HandID][BladeID].BladeNext = Time + Next

		return true
	else
		return false
	end
end

function SWEP:CanDoEffect( HandID, BladeID, Next )
	local Time = CurTime()
	if self.BladeData[HandID][BladeID].NextImpactFX < Time then
		self.BladeData[HandID][BladeID].NextImpactFX = Time + Next

		return true
	else
		return false
	end
end

function SWEP:ObjectImpactEffects( pos, dir )
	local effectdata = EffectData()
		effectdata:SetOrigin( pos )
	util.Effect( "saber_hit_generic", effectdata, true, true )
end

function SWEP:IsMe()
	if not self._IsMe and IsValid( self:GetOwner() ) then
		self._IsMe = self:GetOwner() == LocalPlayer()
	end

	return self._IsMe
end

function SWEP:WallImpactEffects( pos, dir, playsound )
	if playsound then
		local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			effectdata:SetNormal( dir )
		util.Effect( "saber_hitwall_cheap", effectdata, true, true )

		sound.Play(Sound( "saber_hitwall_spark" ), pos, 75)
	else
		local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			effectdata:SetNormal( dir )
		util.Effect( "saber_hitwall", effectdata, true, true )
	end
end

function SWEP:GetMaxBeamElements()
	if OverClocked() then
		return 400
	end
	if self:IsMe() then
		return 200 * LSCS.SaberTrailDetail
	else
		return 25 * LSCS.SaberTrailDetail
	end
end

function SWEP:GetBladeLifeTime()
	if OverClocked() then
		return 0.15
	end
	if self:IsMe() then
		return 0.15 * LSCS.SaberTrailDetail
	else
		return 0.1 * LSCS.SaberTrailDetail
	end
end

function SWEP:DrawBlade( HandID, BladeID, PosData, bladeObject, Mul, HiltAngles )
	local length = bladeObject.length * (PosData.length_multiplier or 1)

	local width = bladeObject.width * (PosData.width_multiplier or 1)
	local actual_width = width + math.Rand(0,bladeObject.widthWiggle)

	local pos = PosData.pos
	local dir = PosData.dir

	local w12 = width * 12
	local w32 = width * 32

	local color_blur = bladeObject.color_blur
	local color_core = bladeObject.color_core

	local Frac = self:DoBladeTrace( HandID, BladeID, pos, dir, length * Mul, width ).Fraction

	local MulxFrac = Mul * Frac

	if bladeObject.mdl then
		self:DrawBladeModel( HandID, BladeID, PosData, bladeObject, MulxFrac, HiltAngles )

		return
	end

	render.SetMaterial( bladeObject.material_glow )
	render.DrawSprite( pos, w32, w32, color_blur )

	-- inefficient pls replace
	for i = 0, math.Round( (length - 1) * MulxFrac, 0 ) do
		render.DrawSprite( pos + dir * i, w12, w12, color_blur ) 
	end

	local EndPos = pos + dir * math.max(length - 0.9,0) * MulxFrac

	render.SetMaterial( bladeObject.material_core )
	render.DrawBeam( pos, EndPos, actual_width , 1, 1, color_core )

	render.SetMaterial( bladeObject.material_core_tip )
	render.DrawBeam( EndPos, EndPos + dir, actual_width , 0.9, 0.1, color_core )
end

function SWEP:DoImpactEffects( HandID, BladeID, bHit, vPos, vDir, hitEnt, ply, min, max )
	local start_pos = ply:GetShootPos()

	if self:IsThrown() then
		start_pos = self:GetProjectile():GetPos()
	end

	local aimDir = ply:GetAimVector()
	local dmgActive = self:GetDMGActive()

	local bHitWall = bHit and not IsValid( hitEnt )
	if self.BladeData[HandID][BladeID].HitWall ~= bHitWall then
		self.BladeData[HandID][BladeID].HitWall = bHitWall

		if bHitWall then
			if dmgActive then
				sound.Play( "saber_lighthit", vPos )
			end
		else
			sound.Play( "saber_hitwall", vPos )
		end
	end

	-- ?option performance setting?
	--[[
	if ply ~= LocalPlayer() then
		if not IsValid( hitEnt ) and bHitWall then
			if self:CanDoEffect( HandID, BladeID, 0.05 ) then
				self:WallImpactEffects(vPos, vDir, true )
			end
		end

		return
	end
	]]

	if self.BladeData[HandID][BladeID].prev_hitpos and self.BladeData[HandID][BladeID].prev_hitnormal then
		local _pos = self.BladeData[HandID][BladeID].prev_hitpos
		local _dir = self.BladeData[HandID][BladeID].prev_hitnormal
		local dir = (vPos - _pos):GetNormalized()

		local dist = math.Round( (vPos - _pos):Length() , 0 )

		if dist > 0 then
			local idx = 0
			for i = 2, dist,2 do
				local trace = util.TraceHull( {
					start = start_pos,
					endpos = _pos + dir * i + aimDir * 5,
					mins = min,
					maxs = max,
					mask = MASK_SHOT_HULL,
					filter = { self, ply }
				} )

				debugoverlay.SweptBox( start_pos, _pos + dir * i + aimDir * 5, min, max, (start_pos -  (_pos + dir * i + aimDir * 5)):Angle(), 10, Color( 0, 100, 255 ) )

				if trace.Hit and not IsValid( trace.Entity ) then
					self:WallImpactEffects( trace.HitPos, trace.HitNormal, false )
				end

				if dmgActive then
					self:RegisterHitCL( trace.Entity, trace.HitPos, trace.HitNormal )
				end
			end
		else
			if dmgActive then
				self:RegisterHitCL( hitEnt, vPos, vDir )
			else
				if not IsValid( hitEnt ) then
					self:WallImpactEffects(vPos, vDir, true )
				end
			end
		end
	else
		if not IsValid( hitEnt ) and bHitWall then
			if self:CanDoEffect( HandID, BladeID, self:IsMe() and 0.01 or 0.05 ) then
				self:WallImpactEffects(vPos, vDir, true )
			end
		end
	end

	self.BladeData[HandID][BladeID].prev_hitpos = vPos
	self.BladeData[HandID][BladeID].prev_hitnormal = vDir
end

function SWEP:DoBladeTrace( HandID, BladeID, pos, dir, length, width )
	if not self.BladeData[HandID][BladeID] then
		self.BladeData[HandID][BladeID] = {
			NextImpactFX = 0,
			BladePositions  = {},
			BladeNext = 0,
			HitWall = false,
		}
	end

	local ply = self:GetOwner()

	local max = Vector( width, width, width )
	local min = -max

	local trace = util.TraceHull( {
		start = pos,
		endpos = pos + dir * length,
		mins = min,
		maxs = max,
		mask = MASK_SHOT_HULL,
		filter =  {self, ply}
	} )

	if trace.Hit and trace.Fraction == 1 then
		trace.Fraction = 0
		trace.HitPos = pos
	end

	if IsValid( trace.Entity ) and not self:GetDMGActive() then
		if self:CanDoEffect( HandID, BladeID, 0.05 ) then
			self:ObjectImpactEffects( trace.HitPos, trace.HitNormal )
		end
	end

	if self:GetDMGActive() then
		debugoverlay.SweptBox( pos, pos + dir * length, min, max, dir:Angle(), 10, Color( 255, 0, 0 ) )
	else
		self.BladeData[HandID][BladeID].prev_hitpos = nil
		self.BladeData[HandID][BladeID].prev_hitnormal = nil
	end

	self:DoImpactEffects( HandID, BladeID, trace.Hit, trace.HitPos, trace.HitNormal, trace.Entity, ply, min, max )

	return trace
end

function SWEP:RegisterHitCL( target, Pos, Dir )
	if not IsValid( target ) then return end

	local ply = self:GetOwner()

	if not IsValid( ply ) then return end

	if ply ~= LocalPlayer() then return end

	local CurTime = CurTime()

	if (target.HitTime or 0) < CurTime then
		target.HitTime = CurTime + 0.15

		net.Start( "lscs_saberdamage" ) 
			net.WriteEntity( target )
			net.WriteVector( Pos )
			net.WriteVector( Dir )
		net.SendToServer()
	end
end