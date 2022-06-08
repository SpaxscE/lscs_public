COMBO.id = "standard"
COMBO.PrintName = "GVP-Standard"
COMBO.Author = "Blu-x92 / Luna"
COMBO.Description = "Standard GVP-Style. Quick to learn, hard to master, but balanced and combat proven."

COMBO.DeflectBullets = true
COMBO.AutoBlock = true

COMBO.HoldType = "melee2"

COMBO.Attacks = {
	["SLAM"] = {
		AttackAnim = "slashdown",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():Freeze( true )
			weapon:GetOwner():SetVelocity( Vector(0,0,200) )
			weapon:GetOwner():lscsSuppressFalldamage( CurTime() + 5 )

			timer.Simple( 0.5, function()
				if IsValid( weapon ) and IsValid( weapon:GetOwner() ) then
					weapon:GetOwner():SetVelocity( Vector(0,0,-1500) )
				end
			end)
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.0,
		Duration = 1.5,
	},
	["FRONT_DASH"] = {
		AttackAnim = "combo4",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()

			if weapon:GetOwner():OnGround() then
				weapon:GetOwner():SetVelocity( Angle(0,weapon:GetOwner():EyeAngles().y,0):Forward() * 1600 )
			else
				weapon:GetOwner():SetVelocity( Angle(0,weapon:GetOwner():EyeAngles().y,0):Forward() * 600 + Vector(0,0,40) )
			end
		end,

		FinishAttack = function( self, weapon ) end,
		Delay = 0.2,
		Duration = 0.6,
	 },
	["BACKFLIP"] = {
		AttackAnim = "rollback",
		BeginAttack = function( self, weapon ) 
			weapon:SetDMGActive( false )

			weapon:GetOwner():SetVelocity( Vector(0,0,250) - Angle(0,weapon:GetOwner():EyeAngles().y,0):Forward() * 50 )
			weapon:GetOwner():lscsSuppressFalldamage( CurTime() + 5 )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.0,
		Duration = 0.5,
	},
	["ROLL_RIGHT"] = {
		AttackAnim = "rollright",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()

			weapon:GetOwner():SetVelocity( Vector(0,0,50) + Angle(0,weapon:GetOwner():EyeAngles().y,0):Right() * 600 )
			weapon:GetOwner():lscsSuppressFalldamage( CurTime() + 5 )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.0,
		Duration = 1,
	},
	["ROLL_LEFT"] = {
		AttackAnim = "rollleft",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()

			weapon:GetOwner():SetVelocity( Vector(0,0,50) - Angle(0,weapon:GetOwner():EyeAngles().y,0):Right() * 600 )
			weapon:GetOwner():lscsSuppressFalldamage( CurTime() + 5 )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.0,
		Duration = 1,
	},
	["____"] = {
		AttackAnim = "a_combo3",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["-45-"] = {
		AttackAnim = "vanguard_r_s3_t3",
		BeginAttack = function( self, weapon )
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.3, Vector(10,0,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.1,
		Duration = 0.4,
	},
	["+45+"] = {
		AttackAnim = "a_combo4",
		BeginAttack = function( self, weapon )
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.3, Vector(10,0,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.1,
		Duration = 0.3,
	},
	["W_S_"] = {
		AttackAnim = "h_left_t3",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.9, Vector(250,0,0) )
			weapon:GetOwner():lscsSetTimedMove( 2, CurTime() + 0.9, 0.3, Vector(0,0,0) )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)
			timer.Simple(0.6, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.2,
		Duration = 1.2,
	},
	["__S_"] = {
		AttackAnim = "a_combo4",
		BeginAttack = function( self, weapon )
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-10,0,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.1,
		Duration = 0.3,
	},
	["_A__"] = {
		AttackAnim = "a_combo3",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.2, Vector(0,-100,0) )
			weapon:GetOwner():lscsSetTimedMove( 2, CurTime() + 0.2, 0.1, Vector(0,0,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["___D"] = {
		AttackAnim = "combo2",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.2, Vector(0,100,0) )
			weapon:GetOwner():lscsSetTimedMove( 2, CurTime() + 0.2, 0.1, Vector(0,0,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["W__D"] = {
		AttackAnim = "combo4",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.6, Vector(1,1,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.4,
		Duration = 0.4,
	},
	["WA__"] = {
		AttackAnim = "combo3",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.3, Vector(25,-25,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["__SD"] = {
		AttackAnim = "a_combo2",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,1,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["_AS_"] = {
		AttackAnim = "combo1",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,-1,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["W___"] = {
		AttackAnim = "combo32",
		BeginAttack = function( self, weapon ) 
			weapon:DoAttackSound()
			if weapon:GetOwner():OnGround() then
				weapon:GetOwner():SetVelocity( Angle(0,weapon:GetOwner():EyeAngles().y,0):Forward() * 1000 )
			end
			weapon:GetOwner():lscsSetTimedMove( 1, CurTime(), 0.9, Vector(0,0,0) )
		end,
		FinishAttack = function( self, weapon ) end,
		Delay = 0.1,
		Duration = 0.8,
	},
}
LSCS:Reload()