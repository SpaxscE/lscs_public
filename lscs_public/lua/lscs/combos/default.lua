COMBO.id = "default"
COMBO.PrintName = "No-Stance"
COMBO.Author = "Luna"
COMBO.Description = "Everyone can swing a Lightsaber, but having a Lightsaber does not make you Jedi."

COMBO.DeflectBullets = false
COMBO.AutoBlock = false

COMBO.LeftSaberActive = false

COMBO.HoldType = "melee"

COMBO.Spawnable = false 

COMBO.Attacks = {}
COMBO.Attacks["____"] = {
	AttackAnim = "range_melee",
	AttackAnimMenu = "seq_baton_swing",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0,
	Duration = 0.25,
}