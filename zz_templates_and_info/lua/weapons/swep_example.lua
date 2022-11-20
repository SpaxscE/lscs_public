-- this script will add a pre-assembled lightsaber to your q-menu

AddCSLuaFile()

SWEP.Base = "weapon_lscs"
DEFINE_BASECLASS( "weapon_lscs" )

SWEP.Category			= "[LSCS]"
SWEP.PrintName		= "Saber Example"
SWEP.Author			= "*you*"

SWEP.Slot				= 0
SWEP.SlotPos			= 3

SWEP.Spawnable		= true
SWEP.AdminOnly		= false

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )

	if SERVER then
		self:SetHiltR("vibrosword") -- which hilt to use
		--self:SetHiltL("vibrosword") -- left hand hilt

		self:SetBladeR("nanoparticles") -- which blade to use
		--self:SetBladeL("nanoparticles") --left hand blade

		--self:SetStance("butterfly") -- assigns a permanent stance to this saber only. Ignoring what the player has in his inventory
	end
end


-- example on how to equip and unequip forcepowers in combination with preset sweps:
--[[

if CLIENT then return end -- code below, SERVERSIDE ONLY

function SWEP:ForcePowersGive( ply ) -- give-forcepowers
	ply:lscsWipeInventory() -- just clean up the entire inventory to make sure its empty. You could cache the inventory here, or add checks if they already have these ect. 

	-- give forcepowers:
	ply:lscsAddInventory( "item_force_jump", true ) -- give them force jump and equip it.
	ply:lscsAddInventory( "item_force_heal", true ) -- force heal and equip it
	ply:lscsAddInventory( "item_force_immunity" ) -- this would give them force immunity but it wont equip it. Add ", true" to equip like the others

	-- you can also give stances, BUT MAKE SURE LINE 28 IS COMMENTED OUT OR THIS WONT WORK:
	ply:lscsAddInventory( "item_stance_yongli", true )
	ply:lscsAddInventory( "item_stance_butterfly", true )
	ply:lscsAddInventory( "item_stance_juggernaut", true )

	-- for more functions and info see:
	-- https://raw.githubusercontent.com/Blu-x92/LUNA_SWORD_COMBAT_SYSTEM/main/zz_templates_and_info/useful_lua_functions.txt
end

function SWEP:ForcePowersRemove( ply ) -- remove-forcepowers function
	ply:lscsWipeInventory() -- just wipe the entire inventory, you can do more complex things here like restoring the original equipped forcepowers ect
end

function SWEP:Equip( newOwner ) -- overwrite equip function
	BaseClass.Equip( self, newOwner ) -- call original Equip function

	if not IsValid( newOwner ) then return end

	self:ForcePowersGive( newOwner ) -- call our custom ForcePower Give function if newOwner is valid
end

function SWEP:OnDrop() -- overwrite OnDrop function
	BaseClass.OnDrop( self ) -- call original OnDrop function

	local ply = self:GetOwner()

	if not IsValid( ply ) then return end

	self:ForcePowersRemove( ply )  -- call our custom ForcePower Remove function if ply is valid
end

function SWEP:OnRemove() -- overwrite OnRemove function
	BaseClass.OnRemove( self ) -- call original Remove function

	local ply = self:GetOwner()

	if not IsValid( ply ) then return end

	self:ForcePowersRemove( ply )  -- call our custom ForcePower Remove function if ply is valid
end

]]