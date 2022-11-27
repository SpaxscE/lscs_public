COMBO.id = "butterfly"
COMBO.PrintName = "Butterfly"
COMBO.Author = "Luna"
COMBO.Description = "Butterfly Stance. Not easy to control but hit's hard when used correctly. Works best with a Saber in both Hands."

COMBO.DeflectBullets = true
COMBO.AutoBlock = true

COMBO.LeftSaberActive = true

COMBO.HoldType = "lscs_butterfly"

COMBO.BPDrainPerHit = 35

COMBO.Attacks = {
	["SLAM"] = {
		AttackAnim = "slashdown",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound(nil, 1)
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
		AttackAnim = "pure_b_right_t1",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound(1, 1)
			timer.Simple(0.1, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 1, 2 )
			end)
			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 2 )
			end)
			timer.Simple(0.5, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 1, 1 )
			end)
			timer.Simple(0.6, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 1, 2 )
			end)

			if ply:OnGround() then
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 1600 )
			else
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 600 + Vector(0,0,40) )
			end
		end,

		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.9,
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
	["ROLL_LEFT"] = {
		AttackAnim = "ryoku_b_s2_t1",
		BeginAttack = function( weapon, ply )  
			ply:SetVelocity( Vector(0,0,50) - Angle(0,ply:EyeAngles().y,0):Right() * 600 )
			ply:lscsSuppressFalldamage( CurTime() + 5 )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 2 )
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 1,
	},
	["ROLL_RIGHT"] = {
		AttackAnim = "ryoku_b_s2_t2",
		BeginAttack = function( weapon, ply )  
			ply:SetVelocity( Vector(0,0,50) + Angle(0,ply:EyeAngles().y,0):Right() * 600 )
			ply:lscsSuppressFalldamage( CurTime() + 5 )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 2 )
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.7,
	},
	["____"] = {
		AttackAnim = "pure_b_s2_t3",
		BeginAttack = function( weapon, ply )  
			ply:lscsSetTimedMove( 1, CurTime(), 0.5, Vector(4500,0,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.5, 0.4, Vector(0,0,0) )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 1 )
			end)
			timer.Simple(0.5, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 2 )
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 1,
	},
	["-45-"] = {
		AttackAnim = "vanguard_r_s3_t3",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound(nil, 1)
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(10,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.4,
	},
	["+45+"] = {
		AttackAnim = "a_combo4",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound(nil, 1)
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(10,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.3,
	},
	["W_S_"] = {
		AttackAnim = "pure_h_left_t3",
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound(1, 1)
			ply:lscsSetTimedMove( 1, CurTime(), 0.4, Vector(400,0,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.4, 0.3, Vector(225,0,0) )
			ply:lscsSetTimedMove( 3, CurTime() + 0.7, 0.6, Vector(0,0,0) )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 1 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 2 )
			end)
			timer.Simple(0.5, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 1 )
			end)
			timer.Simple(0.6, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 2 )
			end)
			timer.Simple(0.8, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 2, 1 )
			end)
			timer.Simple(1, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound(nil, 1)
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 1.3,
	},
	["__S_"] = {
		AttackAnim = "a_combo4",
		BeginAttack = function( weapon, ply ) 
			weapon:DoAttackSound(nil, 1)
			ply:lscsSetTimedMove( 1, CurTime(), 0.3, Vector(-10,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0.1,
		Duration = 0.3,
	},
	["_A__"] = {
		AttackAnim = "pure_b_right_t1",
		BeginAttack = function( weapon, ply )  
			ply:lscsSetTimedMove( 1, CurTime(), 0.4, Vector(0,-150,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.4, 0.2, Vector(0,-80,0) )
			ply:lscsSetTimedMove( 3, CurTime() + 0.6, 0.4, Vector(0,0,0) )

			weapon:DoAttackSound(1, 1)
			timer.Simple(0.1, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 1, 2 )
			end)
			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.65,
	},
	["___D"] = {
		AttackAnim = "pure_b_s2_t3",
		AttackAnimStart = 0.3,
		BeginAttack = function( weapon, ply )  
			ply:lscsSetTimedMove( 1, CurTime(), 0.4, Vector(0,150,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.4, 0.2, Vector(0,80,0) )
			ply:lscsSetTimedMove( 3, CurTime() + 0.6, 0.4, Vector(0,0,0) )

			weapon:DoAttackSound( math.random(1,2), 1 )

			timer.Simple(0.1, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( math.random(1,2), 2 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound(nil, 1)
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.7,
	},
	["W__D"] = {
		AttackAnim = "pure_b_s2_t3",
		BeginAttack = function( weapon, ply )  
			ply:lscsSetTimedMove( 1, CurTime(), 0.7, Vector(150,150,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.7, 0.3, Vector(80,80,0) )
			ply:lscsSetTimedMove( 3, CurTime() + 1, 0.4, Vector(0,0,0) )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( math.random(1,2), 1 )
			end)
			timer.Simple(0.5, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( math.random(1,2), 2 )
			end)
			timer.Simple(0.9, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 1.25,
	},
	["WA__"] = {
		AttackAnim = "pure_b_right_t3",
		AttackAnimStart = 0.1,
		BeginAttack = function( weapon, ply )  
			ply:lscsSetTimedMove( 1, CurTime(), 0.7, Vector(150,-150,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.7, 0.3, Vector(80,-80,0) )
			ply:lscsSetTimedMove( 3, CurTime() + 1, 0.4, Vector(0,0,0) )

			timer.Simple(0.2, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
			timer.Simple(0.4, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( math.random(1,2), 1 )
			end)
			timer.Simple(0.5, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( math.random(1,2), 2 )
			end)
			timer.Simple(0.9, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound( 3, 1 )
			end)
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 1.25,
	},
	["__SD"] = {
		AttackAnim = "pure_b_s3_t2",
		AttackAnimStart = 0.2,
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound(2, 1)
			timer.Simple(0.35, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound(math.random(1,2), 1)
			end)

			ply:lscsSetTimedMove( 1, CurTime(), 0.5, Vector(150,80,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.5, 0.5, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 1,
	},
	["_AS_"] = {
		AttackAnim = "pure_b_s2_t2",
		AttackAnimStart = 0.05,
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound(1, 1)
			timer.Simple(0.35, function()
				if not IsValid( weapon ) then return end
				weapon:DoAttackSound(math.random(1,2), 1)
			end)
			ply:lscsSetTimedMove( 1, CurTime(), 0.5, Vector(150,-80,0) )
			ply:lscsSetTimedMove( 2, CurTime() + 0.5, 0.5, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 1,
	},
	["W___"] = {
		AttackAnim = "phalanx_b_s4_t1",
		AttackAnimStart = 0,
		BeginAttack = function( weapon, ply )  
			weapon:DoAttackSound(nil,1)
			if ply:OnGround() then
				ply:SetVelocity( Angle(0,ply:EyeAngles().y,0):Forward() * 1000 )
			end
			ply:lscsSetTimedMove( 1, CurTime(), 0.9, Vector(0,0,0) )
		end,
		FinishAttack = function( weapon, ply ) end,
		Delay = 0,
		Duration = 0.7,
	},
}