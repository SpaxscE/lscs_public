-- this is where the public saber system differentiates the most from the GVP version.
-- in GVP, since i have full control over what weapon systems to expect, the bullet or damage data is never actually messed with as blood effects, damage, tracer information ect all happen through internal communication with the weapon systems.
-- on a public version however, it can not be done like this as we do not know what kind of weapons there are and if they rely on their callbacks ect. Generally the public version is written in alot more cancerous way, as it has to support a wide range of unknown weapon systems.
-- so instead of preventing it all before it happens, this system just lets it happen and then tries to clean up the mess afterwards. BIG GAY

local meta = FindMetaTable( "Player" )

LSCS_BLOCK_NONSABER = 4
LSCS_BLOCK_PERFECT = 3
LSCS_BLOCK_NORMAL = 2
LSCS_BLOCK = 1
LSCS_UNBLOCKED = 0

function meta:lscsSuppressFalldamage( time )
	self._lscsPreventFallDamageTill = time
end

function meta:lscsIsFalldamageSuppressed()
	if self._lscsPreventFallDamageTill == true then
		return true
	else
		return (self._lscsPreventFallDamageTill or 0) > CurTime()
	end
end

function meta:lscsShouldBleed()
	return self:GetNWBool( "lscsShouldBleed", true ) -- gay
end

if SERVER then
	hook.Add("GetFallDamage", "!!lscs_RemoveFallDamage", function(ply, speed)
		if ply:lscsIsFalldamageSuppressed() then
			return 0
		end
	end)

	hook.Add( "EntityFireBullets", "!!!lscs_deflecting", function( entity, bullet )
		local oldCallback = bullet.Callback
		bullet.Callback = function(att, tr, dmginfo)
			local ply = tr.Entity

			if IsValid( ply ) and ply:IsPlayer() then
				local wep = ply:GetActiveWeapon()

				if not IsValid( wep ) or not wep.LSCS then return end

				wep:DeflectBullet( att, tr, dmginfo, bullet )

				oldCallback( att, tr, dmginfo )
			end
		end

		return true
	end)

	hook.Add( "EntityTakeDamage", "!!!lscs_block_damage", function( ply, dmginfo )
		if dmginfo:GetDamage() <= 0 then return end

		if not ply:IsPlayer() then return end

		if not ply:lscsShouldBleed() then
			ply:lscsClearBlood()
		end

		local wep = ply:GetActiveWeapon()

		if not IsValid( wep ) or not wep.LSCS then return end

		return wep:Block( dmginfo )
	end )

	util.AddNetworkString( "lscs_saberdamage" )
	util.AddNetworkString( "lscs_clearblood" )

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
		local dmg = DamageInfo()
		dmg:SetDamage( LSCS.SaberDamage )
		dmg:SetAttacker( ply )
		dmg:SetDamageForce( (victim:GetPos() - ply:GetPos()):GetNormalized() * 10000 )
		dmg:SetDamagePosition( pos ) 
		dmg:SetDamageType( DMG_ENERGYBEAM )

		if slice[ victim:GetClass() ] then -- gay, because it plays metal slicing sound
			victim:SetPos( victim:GetPos() + Vector(0,0,5) ) -- gay, because their ragdoll spawns 5 units lower than the npc is at causing ragdoll spazz...
			dmg:SetDamageType( bit.bor( DMG_CRUSH, DMG_SLASH ) )
		end

		local startpos = ply:GetShootPos()

		local trace = util.TraceLine( {
			start = startpos,
			endpos = pos + dir,
			filter = function( ent ) 
				return ent == victim
			end
		} )

		-- HOW FAR do we trust our client's? ;), ideally this would check for actual blade location during time of detected hit or call lag compensation. TODO maybe?
		-- Oh well, Since we have a defined time in which damage can happen and a defined range in which damage can be done this shouldn't be a huge problem. It is a small problem with PING as i have noticed but prediction and melee combat is always gay, like this entire lscs_damage.lua file
		if (trace.HitPos - startpos):Length() > 100 then return end

		local wep = ply:GetActiveWeapon()

		if not IsValid( wep ) or not wep.LSCS then return end
		if not wep:GetDMGActive() then return end

		dmg:SetInflictor( wep )

		if victim:IsPlayer() then
			local victim_wep = victim:GetActiveWeapon()
			if IsValid( victim_wep ) and victim_wep.LSCS then
				local Blocked = victim_wep:Block( dmg ) -- this will modify dmginfo internally

				if Blocked ~= LSCS_UNBLOCKED then
					wep:OnBlocked( Blocked ) -- callback function

					return
				end
			end
		end

		if victim:IsPlayer() or victim:IsNPC() or victim:IsNextBot() then -- or victim:IsGay() or lscs_damage.lua:IsGay() then
			victim:EmitSound( "saber_hit" )
		else
			victim:EmitSound( "saber_lighthit" )
		end

		victim:TakeDamageInfo( dmg )

		-- net. vs internal EmitSound networking. Ready,Set, GO! Wohever reaches the client first wins
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

	function meta:lscsSetShouldBleed( bleed )
		if bleed then
			if self.lscsBloodColor then
				self:SetBloodColor( self.lscsBloodColor )
			end
		else
			if not self.lscsBloodColor then
				self.lscsBloodColor = self:GetBloodColor()
			end

			self:SetBloodColor( DONT_BLEED )
		end
		self:SetNWBool( "lscsShouldBleed", bleed )
	end

	function meta:lscsClearBlood()
		net.Start( "lscs_clearblood" )
			net.WriteEntity( self )
		net.Broadcast()
	end
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

	-- for some reason ply:RemoveAllDecals() doesnt work on players when called serverside... bug? It's gay because every line lscs_damage.lua is gay
	net.Receive( "lscs_clearblood", function( len )
		local ply = net.ReadEntity()
		if not IsValid( ply ) then return end
		ply:RemoveAllDecals()
	end)
end