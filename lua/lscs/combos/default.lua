COMBO.id = "default" -- internal ID
COMBO.PrintName = "Untrained" -- what should be displayed in your hud
COMBO.Author = "Blu-x92 / Luna"
COMBO.Description = "Everyone can swing a Lightsaber, but having a Lightsaber does not make you Jedi." -- write an essay explaining what makes your saber style the best

COMBO.DeflectBullets = false -- false, because this style can not deflect bullets
COMBO.AutoBlock = false -- false, because this style can only block when a perfect block is performed. Dont use stamina system.

COMBO.HoldType = "melee"  -- just like any other weapon

COMBO.Attacks = {}
COMBO.Attacks["____"] = {
	AttackAnim = "range_melee", -- which animation to play
	BeginAttack = function( self, weapon )
		weapon:DoAttackSound()

		-- do whatever extra things you want to do when the attack is triggered. Please note this is run on both server and client
	end,
	FinishAttack = function( self, weapon )
		-- do whatever extra things you want to do when the attack is finished. Please note this is run on both server and client
	end,
	Delay = 0, -- how long to wait until dmg is active and BeginAttack is called. This can be used to exclude the windup animation from causing damage
	Duration = 0.25,	-- Actual duration after keypress is Delay + Duration. After this time the gesture will be faded out, Damage will be disabled and player movement will be restored
}

--[[
	"____"			// standing still or fallback. Every saber style MUST HAVE THIS or the combo file will error.
	"SLAM"			// pressing attack after doing BACKFLIP
	"FRONT_DASH"		// when holding w + jump while in air and then pressing mouse1 (while still holding w + jump)
	"BACKFLIP"		// when holding s + jump while in air and then pressing mouse1 (while still holding s + jump)
	"ROLL_RIGHT"		// when holding d + jump while in air and then pressing mouse1 (while still holding d + jump)
	"ROLL_LEFT"		// when holding a + jump while in air and then pressing mouse1 (while still holding a + jump)
	"-45-"			// standing, looking up
	"+45+"			// standing, looking down
	"W_S_"			// while holding W + S
	"__S_"			// ect ect
	"_A__"			// ok ?
	"___D"
	"W__D"
	"WA__"
	"__SD"
	"_AS_"
	"W___"			// order has to be always W A S D
]]--

--LSCS:Reload() -- calling LSCS:Reload() is actually not needed but it helps alot while working on a combo file. Its so you dont have to reload the map all the time. Once you are finished you should comment it out to avoid hundreds of files spamming refresh on the basescript