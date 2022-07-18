
local force = {}
force.PrintName = "Jump"
force.Author = "Blu-x92 / Luna"
force.Description = "Jump higher than anyone else"
force.id = "jump"
force.Equip = function( ply ) end
force.UnEquip = function( ply ) end
force.OnUse = function( ply ) end
LSCS:RegisterForce( force )

local force = {}
force.PrintName = "Push"
force.Author = "Blu-x92 / Luna"
force.Description = "Push things around"
force.id = "push"
LSCS:RegisterForce( force )

local force = {}
force.PrintName = "Pull"
force.Author = "Blu-x92 / Luna"
force.Description = "Pull things towards yourself"
force.id = "pull"
LSCS:RegisterForce( force )

local force = {}
force.PrintName = "Sense"
force.Author = "Blu-x92 / Luna"
force.Description = "Augmented Vision. See through the lies of the Jedi."
force.id = "sense"
LSCS:RegisterForce( force )

local force = {}
force.PrintName = "Heal"
force.Author = "Blu-x92 / Luna"
force.Description = "Regain Health"
force.id = "heal"
LSCS:RegisterForce( force )

local force = {}
force.PrintName = "Block"
force.Author = "Blu-x92 / Luna"
force.Description = "Incoming Force Power attacks are absorbed"
force.id = "immunity"
LSCS:RegisterForce( force )