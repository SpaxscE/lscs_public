
for _, filename in pairs( file.Find("lscs/base/*.lua", "LUA") ) do
	if string.StartWith( filename, "sv_") then
		if SERVER then
			include("lscs/base/"..filename)
		end

		continue
	end

	if string.StartWith( filename, "cl_") then
		if SERVER then
			AddCSLuaFile("lscs/base/"..filename)
		else
			include("lscs/base/"..filename)
		end

		continue
	end

	if SERVER then
		AddCSLuaFile("lscs/base/"..filename)
	end
	include("lscs/base/"..filename)
end

-- combo files
COMBO = {}
for _, filename in pairs( file.Find("lscs/combofiles/*.lua", "LUA") ) do
	if SERVER then
		AddCSLuaFile("lscs/combofiles/"..filename)
	end

	table.Empty( COMBO )

	include("lscs/combofiles/"..filename)

	LSCS[ COMBO.Name ] = {
		Name = COMBO.PrintName,
		HoldType = COMBO.HoldType,
		Attacks = table.Copy( COMBO.Attacks ),
	}

	table.Empty( COMBO )
end