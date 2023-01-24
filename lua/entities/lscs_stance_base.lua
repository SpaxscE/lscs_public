AddCSLuaFile()

ENT.Base = "lscs_holocron_base"
DEFINE_BASECLASS( "lscs_holocron_base" )

ENT.Spawnable		= false
ENT.AdminSpawnable		= false

ENT.GlowMat = Material( "sprites/light_glow02_add" )
ENT.GlowCol = Color(255,200,0,255)

if CLIENT then
	function ENT:DrawTranslucent()
		self:DrawModel()
	end

	function ENT:Draw()
		-- ironic, in order to look nice the translucent sprite has to be rendered normal while the solid model has to be rendered translucent
		render.SetMaterial( self.GlowMat )
		render.DrawSprite( self:GetPos(), 64, 64, self.GlowCol )
	end
end