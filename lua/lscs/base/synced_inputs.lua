-- best method i know to get inputs that are correctly synced on server and client and third party clients. sadly ply:KeyDown is not synced

local meta = FindMetaTable( "Player" )

meta.lscs_cmd = {}

hook.Add( "StartCommand", "!!!!lscs_syncedinputs", function( ply, cmd )
	ply.lscs_cmd[ IN_ATTACK ] = cmd:KeyDown( IN_ATTACK )
	ply.lscs_cmd[ IN_FORWARD ] = cmd:KeyDown( IN_FORWARD )
	ply.lscs_cmd[ IN_MOVELEFT ] =  cmd:KeyDown( IN_MOVELEFT )
	ply.lscs_cmd[ IN_BACK ] =  cmd:KeyDown( IN_BACK )
	ply.lscs_cmd[ IN_MOVERIGHT ] = cmd:KeyDown( IN_MOVERIGHT )
	ply.lscs_cmd[ IN_SPEED ] =  cmd:KeyDown( IN_SPEED )
	ply.lscs_cmd[ IN_JUMP ] =  cmd:KeyDown( IN_JUMP )
end )

function meta:lscsKeyDown( IN_KEY )
	return self.lscs_cmd[ IN_KEY ]
end
