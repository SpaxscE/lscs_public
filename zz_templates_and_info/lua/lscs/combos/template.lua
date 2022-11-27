COMBO.id = "template" -- internal ID, lower case only
COMBO.PrintName = "Template Stance" -- what should be displayed in your hud
COMBO.Author = "ME"
COMBO.Description = "best stance that beats all other stances" -- write an essay explaining what makes your saber style the best

COMBO.DeflectBullets = false -- false, because this style can not deflect bullets. Set to true to enable
COMBO.AutoBlock = false -- false, because this style can only block when a perfect block is performed. Doesn't use stamina system. For any style that should not suck set to true

COMBO.LeftSaberActive = false -- if this combo is selected, left saber is deactivated

--COMBO.DamageMultiplier = 1 -- multiplies global server damage setting for this stance. Avoid using this. Only uncomment if you really need it.

--COMBO.MaxBlockPoints = 100 -- use this to make op boss saber stances. Avoid using this. Only uncomment if you really need it.
--COMBO.BPDrainPerHit = 25 -- how much bp damage this saber stance should be doing. Avoid using this. Only uncomment if you really need it.

--COMBO.BlockDistanceNormal = 60 -- distance of crosshair to block pos until  a normal block is detected with this stance. Avoid using this. Only uncomment if you really need it.
--COMBO.BlockDistancePerfect = 20 -- distance of crosshair to block pos until  a perfect block is detected with this stance. Avoid using this. Only uncomment if you really need it.

--COMBO.Spawnable = false -- uncomment to hide in q-menu

COMBO.HoldType = "melee"  -- just like any other weapon. If you have wos installed you can just use their holdtype editor to add custom holdtypes.

COMBO.Attacks = {}
COMBO.Attacks["____"] = {
	AttackAnim = "range_melee", -- which animation to play
	--AttackAnimStart = 0.3, -- start from this cycle
	--AttackAnimMenu = "seq_baton_swing", -- OPTIONAL, only used for the menu. I added this because of dModelPanel limitations with displaying gesture animations. Its just so it looks nice in the menu

	BeginAttack = function( weapon, ply )  
		weapon:DoAttackSound() -- this will play the "Attack" sound from your equipped blade on BOTH sabers, assuming the left hand saber is equipped and active
		--weapon:DoAttackSound(1) -- this would play the "Attack1" sound on both sabers
		--weapon:DoAttackSound(2, weapon.LEFT_HAND) -- this would play the "Attack2" sound on your LEFT light saber, assuming its equipped and active.  weapon.RIGHT_HAND would be for right hand
		--weapon:DoAttackSound(3 ....    "Attack3", same logic as everything above

		--ply:lscsSetTimedMove( ID, START_TIME, DURATION, MOVEMENT_VECTOR ) -- overwrite playermovement using LSCS' TimedMove system. Smooth af player experience compared to setvelocity. Please use reasonable values.

		--ply:lscsSetTimedMove( 1, CurTime(), 0.7, Vector(250,0,0) ) -- move 250 u/s forward for 0.7 seconds, NOTE: if this duration is longer than the COMBO's attack duration it will just be reset and take no effect. This is just an example copied from another combo file so you will have to edit it yourself
		--ply:lscsSetTimedMove( 2, CurTime() + 0.7, 0.2, Vector(100,0,0) ) -- after 0.7 seconds slow down to 100 u/s for 0.2 seconds.  NOTE: Source's player movement system takes a bit time to accelerate/deaccelerate so extremely short durations will have NO effect.
		--ply:lscsSetTimedMove( 3, CurTime() + 0.9, 0.4, Vector(0,0,0) ) -- after 0.9 seconds lock movement to a full stand for 0.4 seconds.
	
		-- do whatever extra things you want to do when the attack is triggered. Such as force power combinations, effects, sounds, you name it. Please note this is run on both server and client
	end,
	FinishAttack = function( weapon, ply )  
		-- do whatever extra things you want to do when the attack is finished. Please note this is run on both server and client. It does also get called when,  during a attack,  the saber is switched away from or when the player dies
	end,
	Delay = 0, -- how long to wait until dmg is active and BeginAttack is called. This can be used to exclude the windup animation from causing damage
	Duration = 0.25,	-- Actual duration after keypress is Delay + Duration. After this time the gesture will be faded out, Damage will be disabled and all ply:lscsSetTimedMove's will be removed
}


--[[ -- list of valid COMBO.Attacks

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
	"W___"			// order always has to be W A S D

]]--

--LSCS:Reload() -- calling LSCS:Reload() is actually not needed but it helps alot while working on a combo file. 
-- Its so you dont have to reload the map all the time. Once you are finished you should comment it out to avoid hundreds of files spamming refresh on the basescript. If this function is called twice or on gamestartup the basescript will actually refuse to reload. So PLEASE remove it when you release your stuff.
