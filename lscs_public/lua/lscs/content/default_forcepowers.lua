
local force = {}
force.PrintName = "Jump"
force.Author = "Blu-x92 / Luna"
force.Description = "Force Assisted Jump"
force.id = "jump"
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



if SERVER then
	hook.Add( "LSCS:PlayerCanManipulate", "!!!lscs_forceblocking", function( ply, target_ent )
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