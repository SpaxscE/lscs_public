AddCSLuaFile()

ENT.Type            = "anim"

ENT.PrintName = "LSCS Basescript"
ENT.Author = "Blu-x92 / Luna"
ENT.Category = "[LSCS]"

ENT.MDL = "models/blu/jedi/saberhilt/katarn.mdl"
ENT.MDL_INFO = {
	["RH"] = {
		bone = "ValveBiped.Bip01_R_Hand",
		pos = Vector(4.25, -1.5, -2.5),
		ang = Angle(-85, 90, 0),
	},
	["LH"] = {
		bone = "ValveBiped.Bip01_L_Hand",
		pos = Vector(4.25, -1.5, 2.5),
		ang = Angle(85, 90, 0),
	},
}

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar( "Entity",0, "BelongTo" )
	self:NetworkVar( "Bool",0, "LeftHand" )
end

function ENT:IsOwned()
	return IsValid( self:GetBelongTo() )
end

if SERVER then
	function ENT:Initialize()
		self:SetModel( self.MDL )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

		self:SetTrigger( true )
	end

	function ENT:UpdateTransmitState() 
		return TRANSMIT_ALWAYS
	end

	function ENT:DoPickup( ply, LH )
		self:SetBelongTo( ply )
		self:SetLeftHand( LH )

		self:SetParent( ply )
		self:SetLocalPos( Vector(0,0,70) )
		self:SetLocalAngles( angle_zero )

		self:SetTransmitWithParent( true )

		self:DrawShadow( false )

		self:EmitSound( "items/ammo_pickup.wav" )
	end

	function ENT:GiveTo( ply )
		if self:IsOwned() then return end
		if not IsValid( ply ) or not ply:IsPlayer() or not ply:Alive() then return end

		if not ply:HasWeapon( "lscs_combohandler" ) then
			ply:Give( "lscs_combohandler" )
		end

		ply:SelectWeapon( "lscs_combohandler" )

		local wep = ply:GetWeapon( "lscs_combohandler" )

		if IsValid( wep ) then
			local LH = wep:GethiltLH()
			local RH = wep:GethiltRH()

			if not IsValid( RH ) then
				wep:SethiltRH( self, false )
				self:DoPickup( ply )

				return
			end
	
			if not IsValid( LH ) then
				wep:SethiltLH( self )
				self:DoPickup( ply, true )
			end
		end
	end

	function ENT:OnRemove()
		local ply = self:GetBelongTo()

		if not IsValid( ply ) then return end

		local wep = ply:GetWeapon( "lscs_combohandler" )

		if IsValid( wep ) then
			local LH = wep:GethiltLH()
			local RH = wep:GethiltRH()

			if not IsValid( RH ) or not IsValid( LH ) then
				ply:StripWeapon( "lscs_combohandler" )
			end
		end
	end

	function ENT:Use( ply )
		self:GiveTo( ply )
	end

	function ENT:Think()
		return false
	end

	function ENT:OnTakeDamage( dmginfo )
	end

	function ENT:StartTouch( touch_ent )
		self:GiveTo( touch_ent )
	end

	function ENT:EndTouch( touch_ent )
	end

	function ENT:Touch( touch_ent )
	end

	function ENT:PhysicsCollide( data, physobj )
	end
else
	function ENT:Initialize()
		self.WorldModel = ClientsideModel( self.MDL )
		self.WorldModel:SetNoDraw(true)
	end

	function ENT:OnRemove()
		if IsValid( self.WorldModel ) then
			self.WorldModel:Remove()
		end
	end

	function ENT:Think()
	end

	function ENT:DrawEquippedTranslucent( flags )
		local _Owner = self:GetBelongTo()
		local WorldModel = self.WorldModel

		if IsValid( _Owner ) then
			local active = _Owner:GetActiveWeapon():GetClass() == "lscs_combohandler"

			local data = self.MDL_INFO[ (self:GetLeftHand() and "LH" or "RH") ]

			local offsetVec = data.pos
			local offsetAng = data.ang

			local boneid = _Owner:LookupBone( data.bone )

			if not boneid then return end

			local matrix = _Owner:GetBoneMatrix( boneid )
			if not matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			WorldModel:SetPos( newPos )
			WorldModel:SetAngles( newAng )
			WorldModel:SetupBones()
		else
			WorldModel:SetPos( self:GetPos() )
			WorldModel:SetAngles( self:GetAngles() )
		end

		WorldModel:DrawModel()
	end

	function ENT:DrawEquipped( flags )
	end

	function ENT:DrawTranslucent()
	end

	function ENT:Draw()
		if self:IsOwned() then return end

		self:DrawModel()
	end
end