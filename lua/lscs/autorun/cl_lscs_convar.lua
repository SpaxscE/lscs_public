-- dynamic light
local cvarDynamicLight = CreateClientConVar( "lscs_dynamiclight", 1, true, false)

LSCS.DynamicLight = cvarDynamicLight and cvarDynamicLight:GetBool() or false

cvars.AddChangeCallback( "lscs_dynamiclight", function( convar, oldValue, newValue ) 
	LSCS.DynamicLight = tonumber( newValue ) ~=0
end)


-- impact effects
local cvarImpactEffects = CreateClientConVar( "lscs_impacteffects", 1, true, false)

LSCS.ImpactEffects = cvarImpactEffects and cvarImpactEffects:GetBool() or false

cvars.AddChangeCallback( "lscs_impacteffects", function( convar, oldValue, newValue ) 
	LSCS.ImpactEffects = tonumber( newValue ) ~=0
end)


-- trail detail
local cvarSaberTrailDetail = CreateClientConVar( "lscs_traildetail", 100, true, false)

LSCS.SaberTrailDetail  = cvarSaberTrailDetail and (cvarSaberTrailDetail:GetInt() / 100) or 1

cvars.AddChangeCallback( "lscs_traildetail", function( convar, oldValue, newValue ) 
	LSCS.SaberTrailDetail = math.Clamp( tonumber( newValue ), 0, 100 ) / 100
end)


-- host timescale
local cVarTimeScale = GetConVar( "host_timescale" )

LSCS.TimeScale = cVarTimeScale and cVarTimeScale:GetFloat() or 1

cvars.AddChangeCallback( "host_timescale", function( convar, oldValue, newValue ) 
	LSCS.TimeScale = tonumber( newValue )
end)


-- hud should draw
local cvarDrawHud = CreateClientConVar( "lscs_drawhud", 1, true, false)

LSCS.DrawHud = cvarDrawHud and cvarDrawHud:GetBool() or false

cvars.AddChangeCallback( "lscs_drawhud", function( convar, oldValue, newValue ) 
	LSCS.DrawHud = tonumber( newValue ) ~=0
end)