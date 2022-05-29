
local meta = FindMetaTable( "Player" )

function meta:lscsGetCombo()
	return LSCS[ self:GetNWString( "lscsComboFile", "default" ) ]
end

if CLIENT then return end

function meta:lscsSetCombo( name )
	if LSCS[ name ] then
		self:SetNWString( "lscsComboFile", name )
	else
		self:SetNWString( "lscsComboFile", "default" )
	end
end