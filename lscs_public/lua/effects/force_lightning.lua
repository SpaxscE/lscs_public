--DO NOT EDIT OR REUPLOAD THIS FILE

function EFFECT:Init( data )
	self.Ent = data:GetEntity()

	self.LifeTime = 0.2
	self.DieTime = CurTime() + self.LifeTime

	if IsValid( self.Ent ) then
		local Dir = self.Ent:GetAimVector()
		local StartPos = self.Ent:GetShootPos() - Dir * 25
		local EndPos = StartPos + Dir * 625
		self:SetRenderBoundsWS( StartPos, EndPos )
	end
end

function EFFECT:Think()
	if self.DieTime < CurTime() or not IsValid( self.Ent ) then 
		return false
	end

	return true
end

local BeamMat = Material( "trails/electric" )
local mat = Material( "sprites/light_glow02_add" )

function EFFECT:Render()
	if IsValid( self.Ent ) then

		local boneID = self.Ent:LookupBone( "ValveBiped.Bip01_L_Hand" )

		if boneID then
			local T = CurTime() * 10

			local X = math.cos( T ) * math.cos( T * 10 ) * 4
			local Y = math.sin( T ) * math.cos( T * 10 ) * 4
			local pos, ang = self.Ent:GetBonePosition( boneID )
			local StartPos = pos + ang:Up() * 2 + ang:Forward() * 5 + ang:Right() * 2

			if not self.TargetPos then
				self.TargetPos = self.Ent:GetEyeTrace().HitPos
	
				local dlight = DynamicLight( self.Ent:EntIndex() + math.random(0,99) )
				if dlight then
					dlight.pos = StartPos
					dlight.r = 255
					dlight.g = 255
					dlight.b = 255
					dlight.brightness = 3
					dlight.Decay = 2000
					dlight.Size = 150
					dlight.DieTime = CurTime() + 0.1
				end
			end


			local Dir = ((self.TargetPos - StartPos):Angle() + Angle(X,Y,0)):Forward()
			local EndPos = StartPos + Dir * math.random(200,600)

			local trace = util.TraceLine( { start = StartPos, endpos = EndPos, filter = self.Ent} )

			if (self.HitFX or 0) < CurTime() then
				self.HitFX = CurTime() + 0.01

				if trace.Hit then
					local effectdata = EffectData()
						effectdata:SetOrigin( trace.HitPos + trace.HitNormal )
						effectdata:SetNormal( -trace.HitNormal )
					util.Effect( "force_lightning_hit", effectdata )

					if math.random(1,3) == 3 then

						local dlight = DynamicLight( self.Ent:EntIndex() + math.random(100,9999) )
						if dlight then
							dlight.pos = trace.HitPos + trace.HitNormal
							dlight.r = 255
							dlight.g = 150
							dlight.b = 255
							dlight.brightness = 3
							dlight.Decay = 2000
							dlight.Size = 100
							dlight.DieTime = CurTime() + 0.01
						end

						self:EmitSound("lscs/force/lightninghit"..math.random(1,3)..".mp3")
					end
				end
			end

			render.SetMaterial( mat )
			render.DrawSprite( StartPos, 64, 64, Color( 0, 50, 255, 255) )
			render.DrawSprite( StartPos, 16, 16, Color( 255, 255, 255, 255) )

			local BeamStart = StartPos
			local BeamPrevious = BeamStart
			local BeamEnd = trace.HitPos
			local BeamSub = BeamEnd - BeamStart
			local BeamDir = BeamSub:GetNormalized()
			local BeamDistance = (BeamSub):Length()
			local SegmentLength = 50

			render.SetMaterial( BeamMat )

			render.DrawBeam( BeamStart, BeamEnd, 18, 0, 1, Color( 255, 255, 255, 255 ) )

			for SegmentStart = 0, BeamDistance, SegmentLength do
				local SegmentEnd = BeamPrevious + (BeamDir:Angle() + Angle(math.Rand(-8,8),math.Rand(-8,8),0)):Forward() * SegmentLength

				local Width = (SegmentStart / BeamDistance)
				if SegmentStart + SegmentLength >= BeamDistance then
					SegmentEnd = BeamEnd
				end

				render.DrawBeam( BeamPrevious, SegmentEnd, 16 * (1 - Width), Width, Width + 0.15, Color( 255, 150 + 155 * Width, 255, 255 ) )

				local BranchEnd1 = SegmentEnd + (BeamDir:Angle() + Angle(math.Rand(-20,20),math.Rand(-20,20),0)):Forward() * SegmentLength * 0.5

				render.DrawBeam( SegmentEnd, BranchEnd1, math.Rand(8,16) * (1 - Width), 0, 0.2, Color( 255, 255, 255, 255 ) )
				render.DrawBeam( BranchEnd1, BranchEnd1 + (BeamDir:Angle() + Angle(math.Rand(-6,6),math.Rand(-6,6),0)):Forward() * SegmentLength * 1.5, math.Rand(4,8) * (1 - Width), 0, 1.5, Color( 255, 255, 255, 255 ) )

				BeamPrevious = SegmentEnd
			end
		end
	end
end
