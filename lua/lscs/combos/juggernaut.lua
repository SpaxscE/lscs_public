COMBO.id = "juggernaut"
COMBO.PrintName = "Juggernaut"
COMBO.Author = "Luna"
COMBO.Description = "Hit's hard but easy to counter due to it's slow nature"

COMBO.DeflectBullets = true
COMBO.AutoBlock = true

COMBO.LeftSaberActive = false

COMBO.HoldType = "melee2"

COMBO.DamageMultiplier = 1.15
COMBO.BPDrainPerHit = 50

COMBO.Attacks = {
	["SLAM"] = {
		AttackAnim = "h_c3_t2",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound()
			ply:Freeze( true )
			ply:SetVelocity( Vector(0,0,200) )
			ply:lscsSuppressFalldamage( CurTime() + 5 )

			timer.Simple( 0.25, function()
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
		AttackAnim = "h_left_t3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)
			timer.Simple(0.6, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)

			if ply:OnGround() then
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 1600 )
			else
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 600 + Vector(0,0,40) )
			end
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 1.3,
	 },
	["BACKFLIP"] = {
		AttackAnim = "rollback",
		BeginAttack = function( weapon, ply )  
			weapon:SetDMGActive( false )

			ply:SetVelocity( Vector(0,0,250) - Angle(0,ply:EyeAngles().y,0):Forward() * 100 )
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
		AttackAnim = "h_left_t2",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 2, CurTime() + 0.3, 0.3, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.25,
		Duration = 0.5,
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
		AttackAnim = "h_right_t3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.7, Vector(250,0,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.7, 0.2, Vector(100,0,0) )
			ply:lscsSetTimedMove( 3, CurTime() + 0.9, 0.7, Vector(0,0,0) )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)
			timer.Simple(0.8, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound()
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 1.6,
	},
	["__S_"] = {
		AttackAnim = "vanguard_r_s3_t3",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-10,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.3,
	},
	["_A__"] = {
		AttackAnim = "h_left_t2",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(0,-100,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.3, 0.3, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.25,
		Duration = 0.5,
	},
	["___D"] = {
		AttackAnim = "h_right_t2",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(0,100,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.3, 0.3, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.25,
		Duration = 0.5,
	},
	["W__D"] = {
		AttackAnim = "vanguard_h_right_t1",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.4, Vector(1,1,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.3,
		Duration = 0.5,
	},
	["WA__"] = {
		AttackAnim = "vanguard_h_s1_t1",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(25,-25,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.3,
		Duration = 0.6,
	},
	["__SD"] = {
		AttackAnim = "judge_b_s2_t1",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,1,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.2,
		Duration = 0.5,
	},
	["_AS_"] = {
		AttackAnim = "vanguard_b_left_t3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound()
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-1,-1,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.3,
		Duration = 0.6,
	},
	["W___"] = {
		AttackAnim = "judge_b_s3_t1",
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