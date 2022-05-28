COMBO.Name = "default"
COMBO.PrintName = "Untrained"

COMBO.HoldType = "melee"

COMBO.Attacks = {}
COMBO.Attacks["____"] = {
	AttackAnim = "range_melee",
	BeginAttack = function( self, weapon ) 
		weapon:BeginAttack()
	end,
	FinishAttack = function( self, weapon )
		weapon:FinishAttack()
	end,
	Delay = 0,
	Duration = 0.5,
}