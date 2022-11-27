COMBO.id = "untrained"
COMBO.PrintName = "Untrained"
COMBO.Author = "Luna"
COMBO.Description = "Self-Taught Swordsman. The Person using this Stance probably knows how to wield a Saber without hurting himself. However, he still not quite a Jedi yet."

COMBO.DeflectBullets = false
COMBO.AutoBlock = true

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
	AttackAnimStart = 0.2,

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.1,
	Duration = 0.5,
}
COMBO.Attacks["___D"] = {
	AttackAnim = "phalanx_b_right_t1",
	AttackAnimStart = 0.2,

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
	end,
	FinishAttack = function( weapon, ply )  
	end,
	Delay = 0.1,
	Duration = 0.5,
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
COMBO.Attacks["__SD"] = {
	AttackAnim = "ryoku_b_s3_t1",
	AttackAnimStart = 0.4,
	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
		ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,1,0) )
	end,
	FinishAttack = function( weapon, ply ) end,
	Delay = 0,
	Duration = 0.5,
}
COMBO.Attacks["_AS_"] = {
	AttackAnim = "ryoku_b_s3_t1",
	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound()
		ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,-1,0) )
	end,
	FinishAttack = function( weapon, ply ) end,
	Delay = 0,
	Duration = 0.4,
}