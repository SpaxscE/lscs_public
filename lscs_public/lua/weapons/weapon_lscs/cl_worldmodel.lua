SWEP.WorldModelCL = {}
SWEP.BladeModelCL = {}

function SWEP:DrawBladeModel( HandID, BladeID, PosData, bladeObject, Mul, HiltAngles )
	local HiltMDL = self:GetWorldModel( HandID )

	if not IsValid( HiltMDL ) then return end

	local BladeMDL = self:GetBladeModel( HandID, BladeID )

	if IsValid( BladeMDL ) then
		local Ang = HiltAngles
		local Forward = HiltAngles:Up()
		local Right = HiltAngles:Right()

		Ang:RotateAroundAxis( Right, math.deg( math.acos( math.Clamp( Forward:Dot( PosData.dir ) ,-1,1) ) ) )

		BladeMDL:SetPos( PosData.pos )
		BladeMDL:SetAngles( Ang )
		BladeMDL:SetupBones()
		BladeMDL:DrawModel()

		if bladeObject.mdl_poseparameter then
			BladeMDL:SetPoseParameter(bladeObject.mdl_poseparameter, Mul  )
			BladeMDL:InvalidateBoneCache()
		end
	else
		local Model = ClientsideModel( bladeObject.mdl )
		Model:SetNoDraw( true )
		self.BladeModelCL[ HandID ][BladeID ] = Model
	end
end

function SWEP:GetBladeModel( HandID, BladeID )
	if not self.BladeModelCL[ HandID ] then
		self.BladeModelCL[ HandID ] = {}
	end

	if HandID and BladeID then
		if not self.BladeModelCL[ HandID ][BladeID ] then
			return false
		else
			return self.BladeModelCL[ HandID ][BladeID ]
		end
	else
		return self.BladeModelCL
	end
end

function SWEP:GetWorldModel( handID )
	if handID then
		return self.WorldModelCL[ handID ]
	else
		return self.WorldModelCL
	end
end

function SWEP:UpdateWorldModel( hand , hiltobject )
	if hand == self.HAND_RIGHT then
		if IsValid( self.WorldModelCL[ self.HAND_RIGHT ] ) then
			self.WorldModelCL[ self.HAND_RIGHT ]:Remove()
		end

		if hiltobject then
			local WorldModel = ClientsideModel( hiltobject.mdl )
			WorldModel:SetNoDraw( true )
			self.WorldModelCL[ self.HAND_RIGHT ] = WorldModel
		end
	end

	if hand == self.HAND_LEFT then
		if IsValid( self.WorldModelCL[ self.HAND_LEFT ] ) then
			self.WorldModelCL[ self.HAND_LEFT ]:Remove()
		end

		if hiltobject then
			local WorldModel = ClientsideModel( hiltobject.mdl )
			WorldModel:SetNoDraw( true )
			self.WorldModelCL[ self.HAND_LEFT ] = WorldModel
		end
	end
end

function SWEP:ClearWorldModel()
	for _, mdl in pairs( self.WorldModelCL ) do
		if not IsValid( mdl ) then continue end

		mdl:Remove()
	end
end

function SWEP:ClearBladeModel()
	for _, tbl in pairs( self.BladeModelCL ) do
		if not tbl then continue end

		for _, mdl in pairs( tbl ) do
			if not IsValid( mdl ) then continue end
			mdl:Remove()
		end
	end
end

function SWEP:DrawWorldModel( flags )
end

function SWEP:DrawWorldModelUnequipped( ply )
	local Pos = self:GetPos() 
	local Ang = self:GetAngles()

	for handID, hiltObject in pairs( self:GetHiltData() ) do
		local WorldModel = self:GetWorldModel( handID )

		if not IsValid( WorldModel ) then continue end

		WorldModel:SetPos( Pos )
		WorldModel:SetAngles( Ang )
		WorldModel:SetupBones()
		WorldModel:DrawModel()
	end
end

function SWEP:DrawWorldModelTranslucent( flags, target )
	local ply = self:GetOwner()

	if not IsValid( ply ) then
		self:DrawWorldModelUnequipped( ply )

		return
	end

	if self:IsThrown() then
		if IsValid( target ) then
			ply = target
		else
			return
		end
	end

	local BladeID = 1
	local Mul = self:GetLength()

	for handID, hiltObject in pairs( self:GetHiltData() ) do
		local WorldModel = self:GetWorldModel( handID )

		if not IsValid( WorldModel ) then 
			self:RefreshWorldModel()

			continue
		end

		local data = hiltObject.info.ParentData[ self.HAND_STRING[ handID ] ]

		local offsetVec = data.pos
		local offsetAng = data.ang
		local boneid = ply:LookupBone( data.bone )

		if not boneid then continue end

		local matrix = ply:GetBoneMatrix( boneid )

		if not matrix then continue end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

		WorldModel:SetPos( newPos )
		WorldModel:SetAngles( newAng )
		WorldModel:SetupBones()
		WorldModel:DrawModel()

		if Mul <= 0 then continue end

		local Positions = hiltObject.info.GetBladePos( WorldModel )

		if not Positions then continue end

		local COMBO = self:GetCombo()

		for _, PosData in ipairs( Positions ) do
			local BladeData = self:GetBladeData( handID )

			if not IsValid( target ) then
				if (handID == 2 and not COMBO.LeftSaberActive) then continue end
			end

			if BladeData then
				self:DrawBlade( handID, BladeID, PosData, BladeData, Mul, newAng )
				if not BladeData.no_trail and not PosData.no_trail then
					self:CalcTrail( handID, BladeID, PosData, BladeData, Mul )
				end
			end

			BladeID = BladeID + 1
		end
	end
end

function SWEP:RefreshWorldModel()
	self._oldHiltR = nil
	self._oldHiltL = nil
	self._oldBladeR = nil
	self._oldBladeL = nil
end