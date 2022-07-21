-- 2022 and i still havent bothered creating a system that does this automatically

local cVar_SaberDamage = CreateConVar( "lscs_sv_saberdamage", "200", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"Amount of Damage per Saber Hit" )
LSCS.SaberDamage = cVar_SaberDamage and cVar_SaberDamage:GetInt() or 200
cvars.AddChangeCallback( "lscs_sv_saberdamage", function( convar, oldValue, newValue ) 
	LSCS.SaberDamage = tonumber( newValue )
end)


local cVar_BulletForceDrainMul = CreateConVar( "lscs_sv_forcedrain_per_bullet_mul", "0.1", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"BulletDamage is multiplied by this value and then removed from ForcePoints on deflect." )
LSCS.BulletForceDrainMul = cVar_BulletForceDrainMul and cVar_BulletForceDrainMul:GetFloat() or 0.1
cvars.AddChangeCallback( "lscs_sv_forcedrain_per_bullet_mul", function( convar, oldValue, newValue ) 
	LSCS.BulletForceDrainMul = math.max( tonumber( newValue ), 0 )
end)


local cVar_BulletForceDrainMin = CreateConVar( "lscs_sv_forcedrain_per_bullet_min", "1", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"Minimum amount of force a bullet will drain on deflect." )
LSCS.BulletForceDrainMin = cVar_BulletForceDrainMin and cVar_BulletForceDrainMin:GetFloat() or 1
cvars.AddChangeCallback( "lscs_sv_forcedrain_per_bullet_min", function( convar, oldValue, newValue ) 
	LSCS.BulletForceDrainMin = math.max( tonumber( newValue ), 0 )
end)


local cVar_BulletForceDrainMax = CreateConVar( "lscs_sv_forcedrain_per_bullet_max", "5", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"Maxmimum amount of force a bullet will drain on deflect." )
LSCS.BulletForceDrainMax = cVar_BulletForceDrainMax and cVar_BulletForceDrainMax:GetFloat() or 5
cvars.AddChangeCallback( "lscs_sv_forcedrain_per_bullet_max", function( convar, oldValue, newValue ) 
	LSCS.BulletForceDrainMax = math.max( tonumber( newValue ), LSCS.BulletForceDrainMin )
end)


local cVar_AttackInterruptable = CreateConVar( "lscs_sv_bullet_can_interrupt_attack", "1", {FCVAR_REPLICATED , FCVAR_ARCHIVE},"Maxmimum amount of force a bullet will drain on deflect." )
LSCS.AttackInterruptable = cVar_AttackInterruptable and cVar_AttackInterruptable:GetBool() or true
cvars.AddChangeCallback( "lscs_sv_bullet_can_interrupt_attack", function( convar, oldValue, newValue ) 
	LSCS.AttackInterruptable = tonumber( newValue ) ~=0
end)

if SERVER then
	util.AddNetworkString( "lscs_admin_setconvar" )

	net.Receive( "lscs_admin_setconvar", function( length, ply )
		if not IsValid( ply ) or not ply:IsSuperAdmin() then return end

		local ConVar = net.ReadString()
		local Value = tonumber( net.ReadString() )

		RunConsoleCommand( ConVar, Value ) 
	end)
end