if SERVER then
	util.AddNetworkString( "lscs_saberdamage" )

	local function ApplyDamage( ply, victim, pos, dir )
		local damage = 200

		local dmg = DamageInfo()
		dmg:SetDamage( damage )
		dmg:SetAttacker( ply )
		dmg:SetDamageForce( (victim:GetPos() - ply:GetPos()):GetNormalized() * 10000 )
		dmg:SetDamagePosition( pos ) 
		dmg:SetDamageType( DMG_ENERGYBEAM )

		local startpos = ply:GetShootPos()
		local endpos = pos + (victim:GetPos() - ply:GetPos()):GetNormalized() * 50

		local trace = util.TraceLine( {
			start = startpos,
			endpos = pos + dir,
			filter = function( ent ) 
				return ent == victim
			end
		} )

		if (trace.HitPos - startpos):Length() > 100 then return end

		local wep = ply:GetActiveWeapon()
		if not IsValid( wep ) then return end
		if not wep.GetDMGActive and not wep:GetDMGActive() then return end

		if victim.GetActiveWeapon then
			local wep = victim:GetActiveWeapon()
			if IsValid( wep ) and wep.Block then

				if wep:Block( dmg ) then
					victim:EmitSound( "saber_block" )
					net.Start( "saberdamage" )
						net.WriteVector( pos )
						net.WriteVector( dir )
						net.WriteBool( true )
					net.Broadcast()
				else
					victim:TakeDamageInfo( dmg )
					victim:EmitSound( "saber_hit" )
					net.Start( "saberdamage" )
						net.WriteVector( pos )
						net.WriteVector( dir )
						net.WriteBool( false )
					net.Broadcast()
				end

				return
			end
		end

		victim:TakeDamageInfo( dmg )

		if victim:IsPlayer() or victim:IsNPC() then
			victim:EmitSound( "saber_hit" )
		else
			victim:EmitSound( "saber_lighthit" )
		end

		net.Start( "lscs_saberdamage" )
			net.WriteVector( pos )
			net.WriteVector( dir )
			net.WriteBool( false )
		net.Broadcast()
	end

	net.Receive( "lscs_saberdamage", function( len, ply )

		if not IsValid( ply ) then return end

		local a_weapon = ply:GetActiveWeapon()

		if not IsValid( a_weapon ) or not a_weapon.LSCS then return end

		local victim = net.ReadEntity()
		local pos = net.ReadVector()
		local dir = net.ReadVector()

		if not IsValid( victim ) then return end

		ApplyDamage( ply, victim, pos, dir )
	end)
else
	net.Receive( "lscs_saberdamage", function( len )
		local pos = net.ReadVector()
		local dir = net.ReadVector()
		
		local effectdata = EffectData()
			effectdata:SetOrigin( pos )
			effectdata:SetNormal( dir )
			
		if net.ReadBool( ) then
			util.Effect( "saber_block", effectdata, true, true )
		else
			util.Effect( "saber_hit", effectdata, true, true )
		end
	end)
end