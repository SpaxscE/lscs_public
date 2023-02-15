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
	util.AddNetworkString( "lscs_hitmarker" )

	hook.Add("GetFallDamage", "!!lscs_RemoveFallDamage", function(ply, speed)
		if ply:lscsIsFalldamageSuppressed() then
			return 0
		end
	end)

	-- engine stuff doesnt come with the correct callbacks, tracer name and whatnot
	-- so this must be done manually
	local ClassDeflectable = {
		["npc_turret_floor"] = true,
		["npc_strider"] = true,
		["npc_helicopter"] = true,
		["npc_combinegunship"] = true,
	}
	local AmmoTypeDeflectable = {
		["CombineCannon"] = true, -- dropship container gun, the container gives a NULL entity as attacker and inflictor... amazing stuff
		["AR2"] = true, -- AR2
	}


	-- fix conflict with CAP:Code  https://steamcommunity.com/sharedfiles/filedetails/?id=175394472
	local HookSG = false
	hook.Add( "LSCS:EntityFireBullets", "StarGate.CAP.Code.Fix", function( entity, bullet )
		if HookSG == false then
			local FireBulletsSG = hook.GetTable()["EntityFireBullets"]["StarGate.EntityFireBullets"]

			if isfunction( FireBulletsSG ) then
				HookSG = FireBulletsSG

				return HookSG( entity, bullet )
			else
				HookSG = true
			end
		else
			if HookSG ~= true then
				return HookSG( entity, bullet )
			end
		end
	end)


	hook.Add( "EntityFireBullets", "!!!lscs_deflecting", function( entity, bullet )
		if IsValid( entity ) and entity.IsVJBaseSNPC then return end -- for some reason VJBase npc's act different and already break by doing nothing in this hook. So let's let EntityTakeDamage handle this instead. Don't return anything.

		local oldCallback = bullet.Callback
		bullet.Callback = function(att, tr, dmginfo)
			local ply = tr.Entity

			if IsValid( ply ) and ply:IsPlayer() then
				local wep = ply:GetActiveWeapon()

				if not IsValid( wep ) or not wep.LSCS or dmginfo:GetDamage() == 0 then -- damage = 0... ArcCW... detected...
					if oldCallback then
						oldCallback( att, tr, dmginfo )
					end

					return
				end

				local DeflectHack = not bullet.TracerName and AmmoTypeDeflectable[ bullet.AmmoType ] -- if this is true its most likely the AR2 or the dropship container

				if IsValid( bullet.Attacker ) and ClassDeflectable[ bullet.Attacker:GetClass() ] then -- this is for everything else that uses that similar to AR2 plasma bullet type
					DeflectHack = true
				end

				if DeflectHack  then
					bullet.TracerName = "ar2tracer_custom" -- inject a tracer, since i couldnt get vanilla ar2tracer to work i just made my own
				end

				wep:DeflectBullet( att, tr, dmginfo, bullet )

				if DeflectHack then
					bullet.TracerName = nil -- remove the tracer when we are done to avoid conflicts
				end

				if dmginfo:GetDamage() ~= 0 and dmginfo:GetDamageType() ~= DMG_REMOVENORAGDOLL then -- dirty but works
					if oldCallback then -- engine weapons <sometimes> dont have a callback so this check is needed
						oldCallback( att, tr, dmginfo )
					end
				end
			else
				-- just allow normal callback to run if not player
				if oldCallback then -- engine weapons <sometimes> dont have a callback so this check is needed
					oldCallback( att, tr, dmginfo )
				end
			end
		end

		local ShouldFireBullet = hook.Run( "LSCS:EntityFireBullets", entity, bullet ) -- this will allow other addons to still be able to hook into FireBullets while keeping LSCS deflecting intact

		if ShouldFireBullet == false then
			return false
		end

		return true
	end)


	hook.Add( "EntityTakeDamage", "!!!lscs_block_damage", function( ply, dmginfo )

		if not ply:IsPlayer() then return end

		if dmginfo:IsDamageType( DMG_PREVENT_PHYSICS_FORCE ) and dmginfo:IsDamageType( DMG_REMOVENORAGDOLL ) then return end -- failed bullet deflect detected. Don't run block code, but allow damage.

		if dmginfo:GetDamage() == 0 and dmginfo:GetDamageType() == DMG_REMOVENORAGDOLL then return true end -- deflected bullet detected. Don't run block code, prevent damage.

		if not ply:lscsShouldBleed() then
			ply:lscsClearBlood()
		end

		local wep = ply:GetActiveWeapon()

		if not IsValid( wep ) or not wep.LSCS then return end

		if dmginfo:IsDamageType( DMG_BULLET + DMG_AIRBOAT ) then -- some npcs shoot "fake" bullets that just do entitytakedamage with a visual bullet effect
			return wep:BlockDMGinfoBullet( dmginfo ) -- and these can not be deflected properly as they aint calling FireBullets. However we still treat them as bullets internally.
		else
			return wep:Block( dmginfo ) > LSCS_UNBLOCKED
		end
	end )

	util.AddNetworkString( "lscs_saberdamage" )
	util.AddNetworkString( "lscs_clearblood" )

	local slice = {
		["npc_zombie"] = true,
		["npc_zombine"] = true,
		["npc_fastzombie"] = true,
	}

	function LSCS:ApplyDamage( ply, victim, pos, dir )
		local plyID = ply:EntIndex()
		local Time = CurTime()

		if victim._lscsHitTimes then
			local HitTime = victim._lscsHitTimes[ plyID ]

			if HitTime then
				if HitTime > Time then return end
			end
		end

		local dmg = DamageInfo()
		dmg:SetAttacker( ply )
		dmg:SetDamageForce( (victim:GetPos() - ply:GetPos()):GetNormalized() * 10000 )
		dmg:SetDamagePosition( pos ) 
		dmg:SetDamageType( DMG_ENERGYBEAM )

		if slice[ victim:GetClass() ] then -- gay, because it plays metal slicing sound
			victim:SetPos( victim:GetPos() + Vector(0,0,5) ) -- ragdoll spawns 5 units lower than the npc is at causing ragdoll spazz...
			dmg:SetDamageType( bit.bor( DMG_CRUSH, DMG_SLASH ) )
		end

		local wep = ply:GetActiveWeapon()

		if not IsValid( wep ) or not wep.LSCS then return end
		if not wep:GetDMGActive() then return end

		local startpos = ply:GetShootPos()
		local projectile = wep:GetProjectile()

		if IsValid( projectile ) then
			startpos = projectile:GetPos()
		else
			ply:LagCompensation( true )
		end

		local trace = util.TraceLine( {
			start = startpos,
			endpos = pos + dir,
			filter = function( ent ) 
				return ent == victim
			end
		} )

		ply:LagCompensation( false )

		if (trace.HitPos - startpos):Length() > 100 then return end -- protection against net abusers or 1000 ping players

		if not victim._lscsHitTimes then victim._lscsHitTimes = {} end

		victim._lscsHitTimes[ plyID ] = Time + 0.15

		dmg:SetDamage( LSCS.SaberDamage * wep:GetCombo().DamageMul )

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

		if victim:IsPlayer() or victim:IsNPC() or victim:IsNextBot() then
			victim:EmitSound( "saber_hit" )
		else
			victim:EmitSound( "saber_lighthit" )
		end

		victim:TakeDamageInfo( dmg )

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

		if not IsValid( victim ) or ply == victim then return end

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
	net.Receive( "lscs_hitmarker", function( length )
		local num = net.ReadInt( 4 )

		LocalPlayer():EmitSound("lscs/saber/reflect"..num..".mp3", 140, 100, 1, CHAN_ITEM2 )
	end)

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