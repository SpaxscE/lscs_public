COMBO.id = "yongli"
COMBO.PrintName = "YongLi"
COMBO.Author = "Luna"
COMBO.Description = "Standard Sword Art. Quick to learn, hard to master, but balanced and combat proven."

COMBO.DeflectBullets = true
COMBO.AutoBlock = true

COMBO.LeftSaberActive = false

COMBO.HoldType = "slam"

COMBO.Attacks = {
	["SLAM"] = {
		AttackAnim = "slashdown",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound()
			ply:Freeze( true )
			ply:SetVelocity( Vector(0,0,200) )
			ply:lscsSuppressFalldamage( CurTime() + 5 )

			timer.Simple( 0.5, function()
				if IsValid( weapon ) and IsValid( ply ) then
					ply:SetVelocity( Vector(0,0,-1500) )
				end
			end)
		end,
		FinishAttack = function( weapon, ply )
			ply:Freeze( false )
		end,
		Delay = 0.0,
		Duration = 1.5,
	},
	["FRONT_DASH"] = {
		AttackAnim = "combo4",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()

			if ply:OnGround() then
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 1600 )
			else
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 600 + Vector(0,0,40) )
			end
		end,

		FinishAttack = function( weapon, ply ) end,
		Delay = 0.2,
		Duration = 0.6,
	 },
	["BACKFLIP"] = {
		AttackAnim = "rollback",
		BeginAttack = function( weapon, ply )  
			weapon:SetDMGActive( false )

			ply:SetVelocity( Vector(0,0,250) - Angle(0,ply:EyeAngles().y,0):Forward() * 50 )
			ply:lscsSuppressFalldamage( CurTime() + 5 )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.0,
		Duration = 0.5,
	},
	["ROLL_RIGHT"] = {
		AttackAnim = "rollright",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()

			ply:SetVelocity( Vector(0,0,50) + Angle(0,ply:EyeAngles().y,0):Right() * 600 )
			ply:lscsSuppressFalldamage( CurTime() + 5 )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.0,
		Duration = 1,
	},
	["ROLL_LEFT"] = {
		AttackAnim = "rollleft",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()

			ply:SetVelocity( Vector(0,0,50) - Angle(0,ply:EyeAngles().y,0):Right() * 600 )
			ply:lscsSuppressFalldamage( CurTime() + 5 )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.0,
		Duration = 1,
	},
	["____"] = {
		AttackAnim = "a_combo3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["-45-"] = {
		AttackAnim = "vanguard_r_s3_t3",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(10,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.4,
	},
	["+45+"] = {
		AttackAnim = "a_combo4",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(10,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.3,
	},
	["W_S_"] = {
		AttackAnim = "h_left_t3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.7, Vector(250,0,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.7, 0.2, Vector(100,0,0) )
			ply:lscsSetTimedMove( 3, CurTime() + 0.9, 0.4, Vector(0,0,0) )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)
			timer.Simple(0.6, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 1.3,
	},
	["__S_"] = {
		AttackAnim = "a_combo4",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-10,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.3,
	},
	["_A__"] = {
		AttackAnim = "a_combo3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.2, Vector(0,-100,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.2, 0.1, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["___D"] = {
		AttackAnim = "combo2",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.2, Vector(0,100,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.2, 0.1, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["W__D"] = {
		AttackAnim = "combo4",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.4, Vector(1,1,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.2,
		Duration = 0.6,
	},
	["WA__"] = {
		AttackAnim = "combo3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(25,-25,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["__SD"] = {
		AttackAnim = "a_combo2",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,1,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["_AS_"] = {
		AttackAnim = "combo1",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,-1,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.3,
	},
	["W___"] = {
		AttackAnim = "combo32",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			if ply:OnGround() then
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 1000 )
			end
			ply:lscsSetTimedMove( 1, CurTime(), 0.9, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.8,
	},
}
