-- prevent falldamage over set amount of time

if SERVER then
	hook.Add("GetFallDamage", "!!lscs_RemoveFallDamage", function(ply, speed)
		if ply:lscsIsFalldamageSuppressed() then
			return 0
		end
	end)
end

local meta = FindMetaTable( "Player" )

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