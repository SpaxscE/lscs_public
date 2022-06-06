 
 hook.Add( "ScalePlayerDamage", "!!!lscs_block_damage", function( ply, hitgroup, dmginfo )
	timer.Simple( 0, function()
		ply:RemoveAllDecals()
	end )
	--return true
 end)

if SERVER then
	hook.Add( "EntityTakeDamage", "!!!lscs_block_damage", function( target, dmginfo )
		--return true
	end )

	util.AddNetworkString( "lscs_saberdamage" )

	local cVar_SaberDamage = CreateConVar( "lscs_sv_saberdamage", "200", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"amount of damage per saber hit" )

	LSCS.SaberDamage = cVar_SaberDamage and cVar_SaberDamage:GetInt() or 200

	cvars.AddChangeCallback( "lscs_sv_saberdamage", function( convar, oldValue, newValue ) 
		LSCS.SaberDamage = tonumber( newValue )
	end)

	local slice = {
		["npc_zombie"] = true,
		["npc_zombine"] = true,
		["npc_fastzombie"] = true,
	}

	function LSCS:ApplyDamage( ply, victim, pos, dir )
		local damage = LSCS.SaberDamage

		local dmg = DamageInfo()
		dmg:SetDamage( damage )
		dmg:SetAttacker( ply )
		dmg:SetDamageForce( (victim:GetPos() - ply:GetPos()):GetNormalized() * 10000 )
		dmg:SetDamagePosition( pos ) 
		dmg:SetDamageType( DMG_ENERGYBEAM )

		if slice[ victim:GetClass() ] then
			victim:SetPos( victim:GetPos() + Vector(0,0,5) )
			dmg:SetDamageType( bit.bor( DMG_CRUSH, DMG_SLASH ) )
		end

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

		if not IsValid( wep ) or not wep.LSCS then return end
		if not wep:GetDMGActive() then return end

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

		local wep = ply:GetActiveWeapon()

		if not IsValid( wep ) or not wep.LSCS then return end

		local victim = net.ReadEntity()
		local pos = net.ReadVector()
		local dir = net.ReadVector()

		if not IsValid( victim ) then return end

		LSCS:ApplyDamage( ply, victim, pos, dir )
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