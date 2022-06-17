COMBO.id = "default"
COMBO.PrintName = "Untrained"
COMBO.Author = "Luna"
COMBO.Description = "Everyone can swing a Lightsaber, but having a Lightsaber does not make you Jedi." -- write an essay explaining what makes your saber style the best

COMBO.DeflectBullets = false
COMBO.AutoBlock = false

COMBO.HoldType = "melee"

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
