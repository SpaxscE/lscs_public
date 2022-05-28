hook.Add("GetFallDamage", "!!lscs_RemoveFallDamage", function(ply, speed)
	if (ply.PreventFallDamageTill or 0) > CurTime() then
		return 0
	end
end)