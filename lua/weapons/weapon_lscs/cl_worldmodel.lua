SWEP.WorldModelCL = {}

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
			self.WorldModelCL[ self.HAND_LEFT ] :Remove()
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

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelUnequipped( ply )
	local Pos = self:GetPos() 
	local Ang = self:GetAngles()
	local BladeID = 1
	local Mul = self:GetLength()

	for handID, hiltObject in pairs( self:GetHiltData() ) do
		local WorldModel = self:GetWorldModel( handID )

		if not IsValid( WorldModel ) then continue end

		WorldModel:SetPos( Pos )
		WorldModel:SetAngles( Ang )
		WorldModel:SetupBones()
		WorldModel:DrawModel()

		if Mul <= 0 then continue end

		local Positions = hiltObject.info.GetBladePos( WorldModel )

		if not Positions then continue end

		for _, PosData in ipairs( Positions ) do

			self:DrawBlade( handID, BladeID, PosData, self:GetBladeData( handID ), Mul )

			BladeID = BladeID + 1
		end
	end
end

function SWEP:DrawWorldModelTranslucent()
	local ply = self:GetOwner()

	if not IsValid( ply ) then
		self:DrawWorldModelUnequipped( ply )

		return
	end

	local BladeID = 1
	local Mul = self:GetLength()

	for handID, hiltObject in pairs( self:GetHiltData() ) do
		local WorldModel = self:GetWorldModel( handID )

		if not IsValid( WorldModel ) then continue end

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

		for _, PosData in ipairs( Positions ) do
			local BladeData = self:GetBladeData( handID )

			self:DrawBlade( handID, BladeID, PosData, BladeData, Mul )
			self:CalcTrail( handID, BladeID, PosData, BladeData, Mul )

			BladeID = BladeID + 1
		end
	end
end