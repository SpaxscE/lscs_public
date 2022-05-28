
local meta = FindMetaTable( "Player" )

function meta:lscsGetCombo()
	local combo = "standard"

	if LSCS[ combo ] then
		return LSCS[ combo ]
	else
		return LSCS[ "default" ]
	end
end
