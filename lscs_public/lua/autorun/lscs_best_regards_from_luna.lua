--[[

heavily modified version of GVP's Lightsaber System for public use

please dont reupload, dont resell, dont modify

best regards luna

]]--

LSCS = istable( LSCS ) and LSCS or { Hilt = {}, Blade = {}, Stance = {},BulletTracerDeflectable = {} }

AddCSLuaFile("lscs/init.lua")
include("lscs/init.lua")

if SERVER then
	--resource.AddWorkshop( "2821066926" )
end
