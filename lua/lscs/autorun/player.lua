local meta = FindMetaTable( "Player" )

if SERVER then
	function meta:lscsSetStance( name )
		local stance = LSCS:GetStance( name )
		if stance then
			self:SetNWString( "lscsComboFile", name )
		else
			self:SetNWString( "lscsComboFile", "default" )
		end
	end
end

function meta:lscsKeyDown( IN_KEY )
	if not self.lscs_cmd then self.lscs_cmd = {} end

	return self.lscs_cmd[ IN_KEY ]
end

function meta:lscsGetCombo()
	return LSCS:GetStance( self:GetNWString( "lscsComboFile", "default" ) )
end

function meta:lscsGetInventory()
	if not self.m_inventory_lscs then self.m_inventory_lscs = {} end
	return self.m_inventory_lscs
end

function meta:lscsGetHilt()
	return self.m_lscs_hilt_right, self.m_lscs_hilt_left
end

function meta:lscsGetBlade()
	return self.m_lscs_blade_right, self.m_lscs_blade_left
end

hook.Add( "StartCommand", "!!!!lscs_syncedinputs", function( ply, cmd )
	if not ply.lscs_cmd then ply.lscs_cmd = {} end

	ply.lscs_cmd[ IN_ATTACK ] = cmd:KeyDown( IN_ATTACK )
	ply.lscs_cmd[ IN_FORWARD ] = cmd:KeyDown( IN_FORWARD )
	ply.lscs_cmd[ IN_MOVELEFT ] =  cmd:KeyDown( IN_MOVELEFT )
	ply.lscs_cmd[ IN_BACK ] =  cmd:KeyDown( IN_BACK )
	ply.lscs_cmd[ IN_MOVERIGHT ] = cmd:KeyDown( IN_MOVERIGHT )
	ply.lscs_cmd[ IN_SPEED ] =  cmd:KeyDown( IN_SPEED )
	ply.lscs_cmd[ IN_JUMP ] =  cmd:KeyDown( IN_JUMP )
end )
