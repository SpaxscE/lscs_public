COMBO.id = "default"
COMBO.PrintName = "Untrained"
COMBO.Author = "Luna"
COMBO.Description = "Everyone can swing a Lightsaber, but having a Lightsaber does not make you Jedi."

COMBO.DeflectBullets = false
COMBO.AutoBlock = false

COMBO.LeftSaberActive = false

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
COMBO.Attacks["_A__"] = {
	AttackAnim = "phalanx_b_left_t1",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.2,
	Duration = 0.6,
}
COMBO.Attacks["___D"] = {
	AttackAnim = "phalanx_b_right_t1",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.2,
	Duration = 0.6,
}
COMBO.Attacks["WA__"] = {
	AttackAnim = "phalanx_b_left_t1",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.2,
	Duration = 0.6,
}
COMBO.Attacks["W__D"] = {
	AttackAnim = "phalanx_b_right_t1",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.2,
	Duration = 0.6,
}
COMBO.Attacks["_AS_"] = {
	AttackAnim = "phalanx_b_left_t1",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.2,
	Duration = 0.7,
}
COMBO.Attacks["__SD"] = {
	AttackAnim = "phalanx_b_right_t1",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.2,
	Duration = 0.7,
}
COMBO.Attacks["W_S_"] = {
	AttackAnim = "vanguard_r_s3_t1",

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()

		ply:lscsSetTimedMove( 1, CurTime(), 0.2, Vector(600,0,0) )
		ply:lscsSetTimedMove( 1, CurTime() + 0.2, 0.4, Vector(0,0,0) )
	end,
	FinishAttack = function( weapon, ply ) end,
	Delay = 0.1,
	Duration = 0.5,
}
