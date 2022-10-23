

local force = {}
force.PrintName = "Throw"
force.Author = "Blu-x92 / Luna"
force.Description = "Throw your Lightsaber"
force.id = "throw"
force.StartUse = function( ply )
	local SWEP = ply:GetWeapon( "weapon_lscs" )

	if not IsValid( SWEP ) then return end
	if SWEP:IsBrokenSaber() then return end

	if (ply._lscsNextThrow or 0) > CurTime() then return end

	ply._lscsNextThrow = CurTime() + 1

	if IsValid( ply._lscsThrownSaber ) then
		if not ply._lscsThrownSaber.Returning then
			ply._lscsThrownSaber:ResetProgress()
			ply._lscsThrownSaber.Returning = true
		end
	else
		if ply:lscsGetForce() < 10 then return end

		if ply:GetActiveWeapon() ~= SWEP then
			ply:SelectWeapon( "weapon_lscs" )
		end

		LSCS:PlayVCDSequence( ply, "zombie_attack_02", 0.3 )

		local proj = ents.Create("lscs_projectile")
		proj:SetPos( ply:GetShootPos() - Vector(0,0,20) )
		proj:SetSWEP( SWEP )
		proj:Spawn()
		proj:Activate()

		ply:EmitSound("npc/zombie/claw_miss1.wav")

		SWEP:SetHoldType( "magic" )

		ply._lscsThrownSaber = proj
	end
end
force.StopUse = function( ply )
	if IsValid( ply._lscsThrownSaber ) then
		ply._lscsThrownSaber:ResetProgress()
		ply._lscsThrownSaber.Returning = true
	end
end

LSCS:RegisterForce( force )


local force = {}
force.PrintName = "Jump"
force.Author = "Blu-x92 / Luna"
force.Description = "Force Assisted Jump"
force.id = "jump"
force.OnClk =  function( ply, TIME )
	if not ply._lscsAssistedJump then return end

	if ply:OnGround() then
		ply._lscsCanForceJump = true
		ply._lscsPlayedJumpSound = false
		ply._lscsJumpForceTaken = nil
	end

	local JUMP = ply:KeyDown( IN_JUMP )

	if JUMP then
		local wep = ply:GetActiveWeapon()
		if IsValid( wep ) and wep.LSCS then
			if wep:IsComboActive() then JUMP = false end
		end
	end

	if JUMP ~= ply._lscsOldJump then
		ply._lscsOldJump = JUMP
		if JUMP then
			ply._lscsJumpTime = TIME + 0.1
		else
			if not ply:OnGround() then
				ply._lscsCanForceJump = false
			end
		end
	end

	if JUMP and ply:lscsGetForce() > 0 and (ply._lscsJumpForceTaken or 0) < 35 and ply._lscsCanForceJump and (ply._lscsJumpTime or 0) < TIME and not ply:OnGround() then
		ply:lscsSuppressFalldamage( TIME + 5 )
		ply:SetVelocity( Vector(0,0,100) + Angle(0,ply:EyeAngles().y,0):Forward() * 5 )
		ply:lscsTakeForce( 2.5 )
		ply._lscsJumpForceTaken = ply._lscsJumpForceTaken and ply._lscsJumpForceTaken + 2.5 or 0

		if not ply._lscsPlayedJumpSound then
			ply._lscsPlayedJumpSound = true

			net.Start( "lscs_start_jump" )
			net.Send( ply )

			ply:EmitSound("lscs/force/jump.mp3")
		end
	end
end
force.Equip = function( ply ) ply._lscsAssistedJump = true end
force.UnEquip = function( ply ) ply._lscsAssistedJump = false end
force.StartUse = function( ply )
	if ply._lscsForceJumpTime then
		ply._lscsForceJumpTime = nil
	else
		ply._lscsForceJumpTime = CurTime() + 2
	end
end
force.StopUse = function( ply )
	ply._lscsForceJumpTime = nil
end
LSCS:RegisterForce( force )



local force = {}
force.PrintName = "Push"
force.Author = "Blu-x92 / Luna"
force.Description = "Push things around"
force.id = "push"
force.StartUse = function( ply )
	if ply:lscsGetForce() < 20 then return end

	local Time = CurTime()

	local CanPush = (ply._lscsNextForce or 0) < Time

	if not CanPush then return end

	ply._lscsNextForce = Time + 1

	ply:EmitSound("lscs/force/push.mp3")
	ply:lscsTakeForce( 20 )

	local AimVector = ply:GetAimVector()
	local MyPos = ply:GetShootPos()

	LSCS:PlayVCDSequence( ply, "gesture_item_throw", 0.5 )

	local effectdata = EffectData()
		effectdata:SetOrigin( MyPos )
		effectdata:SetNormal( AimVector )
		effectdata:SetEntity( ply )
	util.Effect( "force_push", effectdata, true, true )

	for _, Ent in pairs( ents.FindInSphere( MyPos, 800 ) ) do
		local Sub = (Ent.GetShootPos and Ent:GetShootPos() or Ent:GetPos()) - MyPos
		local ToTarget = Sub:GetNormalized()

		if math.deg( math.acos( math.Clamp( AimVector:Dot( ToTarget ) ,-1,1) ) ) < 30 then
			local Dist = Sub:Length()

			if IsValid( Ent ) and Dist < 800 then
				local Vel = Sub:GetNormalized() * 1250 + Vector(0,0,50)

				LSCS:ForceApply( Ent, Vel, ply )
			end
		end
	end
end
LSCS:RegisterForce( force )



local force = {}
force.PrintName = "Pull"
force.Author = "Blu-x92 / Luna"
force.Description = "Pull things towards yourself"
force.id = "pull"
force.StartUse = function( ply )
	if ply:lscsGetForce() < 20 then return end

	local Time = CurTime()

	local CanPush = (ply._lscsNextForce or 0) < Time

	if not CanPush then return end

	ply._lscsNextForce = Time + 1

	ply:EmitSound("lscs/force/pull.mp3")
	ply:lscsTakeForce( 20 )

	local AimVector = ply:GetAimVector()
	local MyPos = ply:GetShootPos()

	LSCS:PlayVCDSequence( ply, "gesture_becon", 0.8 )

	local effectdata = EffectData()
		effectdata:SetOrigin( MyPos )
		effectdata:SetNormal( AimVector )
		effectdata:SetEntity( ply )
	util.Effect( "force_pull", effectdata, true, true )

	for _, Ent in pairs( ents.FindInSphere( MyPos, 800 ) ) do
		local Sub = (Ent.GetShootPos and Ent:GetShootPos() or Ent:GetPos()) - MyPos
		local ToTarget = Sub:GetNormalized()

		if math.deg( math.acos( math.Clamp( AimVector:Dot( ToTarget ) ,-1,1) ) ) < 20 then
			local Dist = Sub:Length()

			if IsValid( Ent ) and Dist < 800 then
				local Vel = -Sub:GetNormalized() * 1250 + Vector(0,0,50)

				LSCS:ForceApply( Ent, Vel, ply )
			end
		end
	end
end
LSCS:RegisterForce( force )




local force = {}
force.PrintName = "Sense"
force.Author = "Blu-x92 / Luna"
force.Description = "Augmented Vision. See through the lies of the Jedi and through walls"
force.id = "sense"
force.OnClk =  function( ply, TIME )
	if not ply:GetNWBool( "_lscsForceSense", false ) then return end

	if not ply:Alive() or ply:GetObserverMode() ~= OBS_MODE_NONE then
		ply:SetNWBool( "_lscsForceSense", false )
		return
	end

	ply:lscsTakeForce()

	if (ply._lscsSenseTime or 0) < TIME then
		ply:SetNWBool( "_lscsForceSense", false )
	end
end
force.UnEquip = function( ply ) ply:SetNWBool( "_lscsForceSense", false ) end
force.StartUse = function( ply )
	local Time = CurTime()

	local CanDo = (ply._lscsNextForce or 0) < Time

	if not CanDo then return end

	ply._lscsNextForce = Time + 1

	if ply:GetNWBool( "_lscsForceSense", false ) then
		ply:SetNWBool( "_lscsForceSense", false )
	else
		if ply:lscsGetForce() >= 30 then
			ply:SetNWBool( "_lscsForceSense", true )
			ply._lscsSenseTime = CurTime() + 20

			ply:lscsTakeForce( 30 )
			ply:EmitSound("lscs/force/sense.mp3")
		end
	end

end
LSCS:RegisterForce( force )




local force = {}
force.PrintName = "Heal"
force.Author = "Blu-x92 / Luna"
force.Description = "Heal yourself using the Force"
force.id = "heal"
force.StartUse = function( ply )
	local Time = CurTime()

	local CanDo = (ply._lscsNextForce or 0) < Time

	if not CanDo then return end

	ply._lscsNextForce = Time + 2

	local available = ply:lscsGetForce()
	local need = ply:GetMaxHealth() - ply:Health()

	if need > 0 and available >= 5 then
		local take = math.min( need, available, 25 )

		ply:lscsTakeForce( take )
		ply:SetHealth( math.min(ply:Health() + take ) )

		ply:EmitSound("lscs/force/heal.mp3")

		local effectdata = EffectData()
			effectdata:SetOrigin( ply:GetPos() )
			effectdata:SetEntity( ply )
		util.Effect( "force_heal", effectdata, true, true )
	end
end
LSCS:RegisterForce( force )



local force = {}
force.PrintName = "Replenish"
force.Author = "Blu-x92 / Luna"
force.Description = "A Dark Side ability that regains Force from Health"
force.id = "replenish"
force.StartUse = function( ply )
	local Time = CurTime()

	local CanDo = (ply._lscsNextForce or 0) < Time

	if not CanDo then return end

	ply._lscsNextForce = Time + 2

	local available = math.max( ply:Health() - 1, 0 )

	local need = ply:lscsGetMaxForce() - ply:lscsGetForce()

	if available > 1 then
		if need > 0 then
			local take = math.min( need, available, 50 )

			ply:SetHealth( ply:Health() - take )
			ply:lscsSetForce( math.min(ply:lscsGetForce() + take, ply:lscsGetMaxForce()) )

			ply:EmitSound("lscs/force/replenish.mp3")

			local effectdata = EffectData()
				effectdata:SetOrigin( ply:GetPos() )
				effectdata:SetEntity( ply )
			util.Effect( "force_replenish", effectdata, true, true )
		end
	else
		if need > 0 then
			ply:EmitSound("lscs/force/replenish.mp3")

			local d = DamageInfo()
			d:SetDamage( 1 )
			d:SetAttacker( ply )
			d:SetDamageType( DMG_DROWN ) 
			d:SetDamagePosition( ply:GetShootPos() )
			ply:TakeDamageInfo( d )
		end
	end
end
LSCS:RegisterForce( force )



local force = {}
force.PrintName = "Immunity"
force.Author = "Blu-x92 / Luna"
force.Description = "Incoming Force Power attacks are absorbed and regain Force Points. Also gives a permanent immunity against incoming Force Powers as long your own Force Points are above 50% even when this Power is not activated. Only the weak minded don't learn this ability."
force.id = "immunity"
force.OnClk =  function( ply, TIME )
	if not ply:GetNWBool( "_lscsForceProtect", false ) then return end

	if not ply:Alive() or ply:GetObserverMode() ~= OBS_MODE_NONE then
		ply:SetNWBool( "_lscsForceProtect", false )
		return
	end

	local effectdata = EffectData()
		effectdata:SetOrigin( ply:GetPos() )
		effectdata:SetEntity( ply )
	util.Effect( "force_block_active", effectdata, true, true )

	ply:lscsTakeForce()

	if (ply._lscsBlockTime or 0) < TIME then
		ply:SetNWBool( "_lscsForceProtect", false )
	end
end
force.Equip = function( ply ) ply._lscsForceResistant = true end
force.UnEquip = function( ply ) ply._lscsForceResistant = nil ply:GetNWBool( "_lscsForceProtect", false ) end
force.StartUse = function( ply )
	local Time = CurTime()

	local CanDo = (ply._lscsNextForce or 0) < Time

	if not CanDo then return end

	ply._lscsNextForce = Time + 1

	if ply:GetNWBool( "_lscsForceProtect", false ) then
		ply:SetNWBool( "_lscsForceProtect", false )
	else
		if ply:lscsGetForce() < 20 then return end

		ply:SetNWBool( "_lscsForceProtect", true )
		ply._lscsBlockTime = CurTime() + 20

		ply:EmitSound("lscs/force/protect.mp3")

		ply:lscsTakeForce( 20 )
	end

end
LSCS:RegisterForce( force )


local force = {}
force.PrintName = "Lightning"
force.Author = "Blu-x92 / Luna"
force.Description = "Force Lightning"
force.id = "lightning"
force.OnClk =  function( ply, TIME )
	if not ply._lscsLightningTime then return end

	ply:lscsTakeForce( 2 )

	local effectdata = EffectData()
		effectdata:SetOrigin( ply:GetPos() )
		effectdata:SetEntity( ply )
	util.Effect( "force_lightning", effectdata, true, true )

	local MyPos = ply:GetShootPos()
	local AimVector = ply:GetAimVector()
	local Force = AimVector * 100

	for _, victim in pairs( ents.FindInSphere( MyPos, 700 ) ) do
		local TargetPos = victim.GetShootPos and victim:GetShootPos() or victim:GetPos()
		local Sub = TargetPos - MyPos
		local ToTarget = Sub:GetNormalized()

		if math.deg( math.acos( math.Clamp( AimVector:Dot( ToTarget ) ,-1,1) ) ) < 14 then
			if util.TraceLine( {start = MyPos,endpos = victim:LocalToWorld( victim:OBBCenter() ),mask = MASK_SHOT,filter = ply,} ).Entity ~= victim then continue end

			local Dist = Sub:Length()

			if IsValid( victim ) and Dist < 700 then
				if victim:IsPlayer() then
					if hook.Run( "LSCS:PlayerCanManipulate", ply, victim, true ) then continue end
				end

				if victim:GetClass() == "prop_ragdoll" then
					victim:Fire("StartRagdollBoogie")

					if (victim._lscsBoogieTime or 0) < TIME then
						victim._lscsBoogieTime = TIME + 6

						for i = 1, 70 do
							if math.random(1,5) == 1 then continue end

							timer.Simple( i * 0.1, function()
								if not IsValid( victim ) then return end

								local effect = EffectData()
								effect:SetEntity( victim )
								effect:SetMagnitude(30)
								effect:SetScale(30)
								effect:SetRadius(30)
								util.Effect("TeslaHitBoxes", effect)
								victim:EmitSound("Weapon_StunStick.Activate")
							end )
						end
					end
				end

				local DMGtrace = util.TraceHull( {
					start = MyPos,
					endpos = MyPos + AimVector * 800,
					filter = ply,
					mins = Vector( -20, -20, -20 ),
					maxs = Vector( 20, 20, 20 ),
					mask = MASK_SHOT_HULL,
					filter = function( ent ) return ent == victim end
				} )

				local DmgSub = TargetPos - DMGtrace.HitPos
				local DmgPos = DMGtrace.HitPos + DmgSub:GetNormalized() * math.min(DmgSub:Length(),20) + VectorRand(-5,5)

				local dmginfo = DamageInfo()
				dmginfo:SetDamage( 5 )
				dmginfo:SetAttacker( ply )
				dmginfo:SetInflictor( ply ) 
				dmginfo:SetDamageType( bit.bor( DMG_SHOCK, DMG_BULLET ) )
				dmginfo:SetDamagePosition( DmgPos )
				dmginfo:SetDamageForce( Force ) 
				victim:TakeDamageInfo( dmginfo )
			end
		end
	end

	if ply._lscsLightningStartTime < TIME then
		LSCS:PlayVCDSequence( ply, "gesture_item_give", 0.7 )
	end

	if ply._lscsLightningTime < TIME or ply:lscsGetForce() <= 0 or not ply:Alive() or ply:GetObserverMode() ~= OBS_MODE_NONE then
		ply._lscsLightningTime = nil
		ply._lscsLightningStartTime = nil
	end
end
force.Equip = function( ply ) end
force.UnEquip = function( ply ) end
force.StartUse = function( ply )
	local Time = CurTime()

	if (ply._lscsLightningTime or 0) > Time then
		ply._lscsLightningTime = nil
		ply._lscsLightningStartTime = nil

		return
	end

	if ply:lscsGetForce() < 10 then return end

	local CanDo = (ply._lscsNextForce or 0) < Time and (ply._lscsLightningTime or 0) < Time

	if not CanDo then return end

	ply._lscsNextForce = Time + 2

	ply:EmitSound("lscs/force/lightning.mp3")

	ply:lscsTakeForce( 5 )

	if not ply._lscsLightningTime then
		ply._lscsLightningTime = CurTime() + 3.5
		ply._lscsLightningStartTime = CurTime() + 0.15

		LSCS:PlayVCDSequence( ply, "gesture_signal_forward", 0.1 )
	end
end
force.StopUse = function( ply )
	ply._lscsLightningTime = nil
end
LSCS:RegisterForce( force )


if SERVER then
	hook.Add( "LSCS:PlayerCanManipulate", "!!!lscs_forceblocking", function( ply, target_ent, ignore_passive )
		if not target_ent.IsPlayer or not target_ent:IsPlayer() then return end

		if target_ent:GetNWBool( "_lscsForceProtect", false ) then
			target_ent:lscsSetForce( math.min(target_ent:lscsGetForce() + 15, target_ent:lscsGetMaxForce()) )

			local effectdata = EffectData()
				effectdata:SetOrigin( target_ent:GetPos() )
				effectdata:SetEntity( target_ent )
			util.Effect( "force_block", effectdata, true, true )

			target_ent:EmitSound("lscs/force/block.mp3")
			LSCS:PlayVCDSequence( target_ent, "walk_magic" )

			return true
		end

		if ignore_passive then return end

		if target_ent._lscsForceResistant and target_ent:lscsGetForce() > 50 then
			LSCS:PlayVCDSequence( target_ent, "walk_magic" )

			return true
		end
	end )
else
	local zoom_mat = Material( "vgui/zoom" )
	local warp = Material("effects/tp_eyefx/tpeye3")

	hook.Add( "HUDPaint", "!lscs_senseoverlay", function()
		local ply = LocalPlayer()

		if not ply:GetNWBool( "_lscsForceSense", false ) then return end

		local X = ScrW()
		local Y = ScrH()

		surface.SetDrawColor( Color(255,255,255,255) )
		surface.SetMaterial( zoom_mat ) 
		surface.DrawTexturedRectRotated( X + X * 0.5, Y * 0.5, X, Y, 0 )
		surface.DrawTexturedRectRotated( X + X * 0.5, Y + Y * 0.5, Y, X, 270 )
		surface.DrawTexturedRectRotated( X * 0.5, Y * 0.5, Y, X, 90 )
		surface.DrawTexturedRectRotated( X * 0.5, Y + Y * 0.5, X, Y, 180 )
	
		surface.SetMaterial( warp ) 
		surface.DrawTexturedRect( 0, 0, X, Y )
	end )

	hook.Add( "HUDPaint", "!lscs_protectoverlay", function()
		local ply = LocalPlayer()

		if not ply:GetNWBool( "_lscsForceProtect", false ) then return end

		local X = ScrW()
		local Y = ScrH()
	
		surface.SetDrawColor(0, 127, 255, 25)
		surface.DrawRect( 0, 0, X, Y )
	end )

	
	local function StencilMagic( renderfunction, Col )
		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )
		render.ClearStencil()

		render.SetStencilEnable( true )
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
		render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )

		renderfunction()

		render.SetStencilCompareFunction( STENCIL_EQUAL )
		render.ClearBuffersObeyStencil(Col.r, Col.g, Col.b, Col.a , false)

		render.SetStencilEnable( false )
	end

	hook.Add("PostDrawOpaqueRenderables", "!!!!lscs_playertrackerwallhack", function( bDrawingDepth, bDrawingSkybox, isDraw3DSkybox )
		if isDraw3DSkybox then return end

		local ply = LocalPlayer()

		if not ply:GetNWBool( "_lscsForceSense", false ) then return end

		local ply = LocalPlayer()

		StencilMagic( 
			function()
				for _, ent in pairs( ents.GetAll() ) do
					if ent == ply then continue end

					if not ent.IsNPC or not ent.IsNextBot or not ent.IsPlayer then continue end

					if not ent:IsNPC() and not ent:IsNextBot() and not ent:IsPlayer() then continue end

					if ent.Alive and not ent:Alive() then continue end -- doesnt do shit on npc's ...
					if ent.Health and ent:Health() <= 0 then continue end -- doesnt do shit on npc's ...
					if ent.GetMoveType and ent:GetMoveType() == MOVETYPE_NONE then continue end -- this works for npc's

					ent:DrawModel()
				end
			end,
			Color(255,200,0,255)
		)
	end)
end