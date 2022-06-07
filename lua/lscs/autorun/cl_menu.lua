surface.CreateFont( "LSCS_FONT", {
	font = "Verdana",
	extended = false,
	size = 20,
	weight = 2000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

surface.CreateFont( "LSCS_FONT_SMALL", {
	font = "Verdana",
	extended = false,
	size = 12,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = false,
	outline = false,
} )

local function bezier(p0, p1, p2, p3, t)
	local e = p0 + t * (p1 - p0)
	local f = p1 + t * (p2 - p1)
	local g = p2 + t * (p3 - p2)

	local h = e + t * (f - e)
	local i = f + t * (g - f)

	local p = h + t * (i - h)

	return p
end

local function DrawFrame( w, h, offset, thickness )
	surface.DrawRect( offset, offset, thickness, h - offset * 2 )
	surface.DrawRect( w - offset - thickness, offset, thickness, h - offset * 2 )

	surface.DrawRect( offset, offset, w - offset * 2 - thickness, thickness )
	surface.DrawRect( offset, h - offset - thickness, w - offset * 2 - thickness, thickness )
end

local function DrawBezier( startPos, endPos )
	local detail = 15
	local p2 = Vector(endPos.x,startPos.y,0)
	local p3 = Vector(startPos.x,endPos.y,0)

	for i = 1,detail do
		local sp = bezier(startPos, p2, p3, endPos, (i - 1) / detail)
		local ep = bezier(startPos, p2, p3, endPos, i / detail)
		surface.DrawLine( sp.x, sp.y, ep.x, ep.y )
	end
end
local test1 = Material("entities/item_saberhilt_katarn.png")
local test2 = Material("entities/item_crystal_sapphire.png")

local Gradient = Material("vgui/gradient-l")
local ClickMat = Material("sun/overlay")

local menu_white_dim = Color(100,100,100,255)
local menu_white = Color(255,255,255,255)
local menu_dark = Color(24,30,54,255)
local menu_dim = Color(37,42,64,255)
local menu_light = Color(46,51,73,255)
local menu_black = Color(31,31,31,255)
local menu_text = Color(0,127,255,255)

local icon_lscs = Material("lscs/ui/icon256.png")
local icon_inventory = Material("lscs/ui/inventory.png")
local icon_hilt = Material("lscs/ui/hilt.png")
local icon_stance = Material("lscs/ui/stance.png")
local icon_settings = Material("lscs/ui/settings.png")

local icon_check = Material("lscs/ui/check.png")
local icon_cross = Material("lscs/ui/cross.png")

local icon_lhand = Material("lscs/ui/hand_l.png")
local icon_rhand = Material("lscs/ui/hand_r.png")

local zoom_mat = Material( "vgui/zoom" )

local function BaseButtonClick( self, sound )
	sound = sound or "ui/buttonclick.wav"

	surface.PlaySound( sound )
	self.smScale = 1
end

local function DrawButtonClick( self, w, h ) 
	local Col = menu_white_dim
	if self:IsHovered() then
		Col = menu_white
	end

	self.smScale = self.smScale or 0
	self.smScale = self.smScale - math.min(self.smScale,RealFrameTime() * 3)

	local Size = self.smScale

	if Size > 0.05 then
		surface.DrawCircle( w * 0.5, h * 0.5, (1 - Size) * (w - 25), 150, 200, 255, 255 * Size )
		surface.DrawCircle( w * 0.5, h * 0.5, (1 - Size) * (w - 15), 150, 200, 255, 255 * 0.5 * Size )
		surface.DrawCircle( w * 0.5, h * 0.5, (1 - Size) * (w - 10), 150, 200, 255, 255 * 0.2 * Size )

		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 150 * Size, 200 * Size, 255 * Size, 255 * Size )
		surface.DrawTexturedRect( w * 0.5 - w * 0.5 * Size * 2, h * 0.5 - h * 0.5 * Size * 2, w * Size * 2, h * Size * 2 )
	end

	return Col
end

local Frame

local FrameBarHeight = 24

local FrameSizeX = 750
local FrameSizeY = 400 + FrameBarHeight

local SelectorHeight = 80 * 5
local SelectorWidth = 80
local SelectorWidthActive = 196

local PanelPosX = SelectorWidth
local PanelPosY = FrameBarHeight
local PanelSizeX = FrameSizeX - SelectorWidth
local PanelSizeY = FrameSizeY - FrameBarHeight * 2

function LSCS:SetActivePanel( newpanel )
	if not IsValid( Frame ) then
		LSCS:OpenMenu()
	end

	if IsValid( Frame.PANEL ) then
		Frame.PANEL:Remove()
	end

	Frame.PANEL = newpanel
end

local function BaseButtonClickSB( self, sound )
	sound = sound or "ui/buttonclick.wav"

	surface.PlaySound( sound )

	Frame.buttons = Frame.buttons or {}
	Frame.buttons[ self.ID ] = 1
end

local function DrawButtonClickSB( self, w, h ) 
	local Col = menu_white_dim
	if self:IsHovered() then
		Col = menu_white
	end

	Frame.buttons = Frame.buttons or {}
	Frame.buttons[ self.ID ] = Frame.buttons[ self.ID ] or 0

	Frame.buttons[ self.ID ] = Frame.buttons[ self.ID ] - math.min(Frame.buttons[ self.ID ],RealFrameTime() * 3)

	local Size = Frame.buttons[ self.ID ]

	if Size > 0.05 then
		surface.DrawCircle( w * 0.5, h * 0.5, (1 - Size) * (w - 25), 150, 200, 255, 255 * Size )
		surface.DrawCircle( w * 0.5, h * 0.5, (1 - Size) * (w - 15), 150, 200, 255, 255 * 0.5 * Size )
		surface.DrawCircle( w * 0.5, h * 0.5, (1 - Size) * (w - 10), 150, 200, 255, 255 * 0.2 * Size )

		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 150 * Size, 200 * Size, 255 * Size, 255 * Size )
		surface.DrawTexturedRect( w * 0.5 - w * 0.5 * Size * 2, h * 0.5 - h * 0.5 * Size * 2, w * Size * 2, h * Size * 2 )
	end

	return Col
end

local function CreateSideBarButton( icon, ID, text )
	local button = vgui.Create( "Button", Frame.SideBar )
	button.text = text or ""
	button:SetText( "" )	
	button:SetSize( SelectorWidthActive,  80 )
	button:SetPos( 0,  (ID - 1) * 80 )
	button.DoClick = function( self )
	end
	button.Paint = function(self, w, h )
		Frame._smSB = Frame._smSB or SelectorWidth

		local xPos = Frame._smSB - 8 - 64

		local Col = DrawButtonClickSB( self, w, h ) 
		if Frame.ID == self.ID then
			Col = menu_text

			draw.DrawText( self.text, "LSCS_FONT", -110 + xPos, h * 0.5 - 10, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			surface.SetMaterial( Gradient )
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			surface.DrawTexturedRect( 0, 0, 6, h )
		else
			draw.DrawText( self.text, "LSCS_FONT", -110 + xPos, h * 0.5 - 10, Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		surface.SetMaterial( icon )
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawTexturedRect( xPos, 8, 64, 64 )
	end
	button.ID = ID

	return button
end

function LSCS:SideBar( Frame )
	if IsValid( Frame.SideBar ) then
		Frame.SideBar:Remove()
	end
	Frame.SideBar = vgui.Create( "DPanel", Frame )
	Frame.SideBar:SetPos( 0, FrameBarHeight )
	Frame.SideBar:SetSize( (Frame:SideBarIsActive() and SelectorWidthActive or SelectorWidth), SelectorHeight )
	Frame.SideBar.Paint = function(self, w, h )
		draw.RoundedBoxEx( 8, 0, 0, w, h, menu_dark, false, false, true, false )
	end

	local button = CreateSideBarButton( icon_lscs, 1, "Home" )
	button.DoClick = function( self )
		BaseButtonClickSB( self )
		LSCS:BuildMainMenu( Frame )
	end

	local button = CreateSideBarButton( icon_inventory, 2, "Inventory" )
	button.DoClick = function( self )
		BaseButtonClickSB( self )
		LSCS:BuildInventory( Frame )
	end

	local button = CreateSideBarButton( icon_hilt, 3, "Lightsaber" )
	button.DoClick = function( self )
		BaseButtonClickSB( self )
		LSCS:BuildSaberMenu( Frame )
	end

	local button = CreateSideBarButton( icon_stance, 4, "Stance" )
	button.DoClick = function( self )
		BaseButtonClickSB( self )
		LSCS:BuildStanceMenu( Frame )
	end

	local button = CreateSideBarButton( icon_settings, 5, "Settings" )
		button.DoClick = function( self )
		BaseButtonClickSB( self )
		LSCS:BuildSettings( Frame )
	end
end

function LSCS:BuildMainMenu( Frame )
	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY )
	Panel.Paint = function(self, w, h )
		local Col = menu_light
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 1
end

function LSCS:BuildInventory( Frame )
	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY )
	Panel.Paint = function(self, w, h )
		local Col = menu_light
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 255, 255, 255, 255 )
		local X, Y = self:CursorPos()
		surface.DrawTexturedRectRotated( X, Y, 512, 512, 0 )

		local Col = menu_light
		surface.SetDrawColor( Col.r, Col.g, Col.b, 240 )
		surface.DrawRect( 0, 0, w, h  )
	end

	local DScrollPanel = vgui.Create( "DScrollPanel", Panel )
	DScrollPanel:Dock( FILL )

	local Inventory = LocalPlayer():lscsGetInventory()

	local X = 8
	local Y = 8
	for index, class in pairs( Inventory ) do
		local DButton = vgui.Create( "DButton", DScrollPanel )
		DButton:SetText( "" )
		DButton:SetPos( X, Y )
		DButton:SetSize( 128, 128 )

		DButton.SetMaterial = function( self, mat ) 
			if file.Exists( "materials/"..mat, "GAME" ) then
				self.Mat = Material( mat )
			else
				self.Mat = Material( "debug/debugwireframe" )
			end
		end
		DButton.GetMaterial = function( self ) return self.Mat end

		DButton.SetID = function( self, id ) self.ID = id end
		DButton.GetID = function( self ) return self.ID end

		DButton.SetItem = function( self, item ) self.Item = LSCS:ClassToItem( item ) self.ClassName = class end
		DButton.GetItem = function( self ) return self.Item end

		DButton:SetItem( class )
		DButton:SetID( index )
		DButton:SetMaterial( "entities/"..class..".png" )

		DButton.Paint = function(self, w, h )
			if not self:IsEnabled() then
				local Col = menu_dim
				surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
				surface.DrawRect( 2, 2, w - 4, h - 4 )
				return
			end

			surface.SetMaterial( self:GetMaterial() )
			surface.SetDrawColor( 255,255,255,255 )
			surface.DrawTexturedRect( 2, 2, w - 4, h - 4 )

			DrawButtonClick( self, w, h ) 

			if not self:IsHovered() and not IsValid( self.menu ) then
				local Col = menu_dark

				surface.SetDrawColor( 0,0,0,100 )
				surface.DrawRect( 2, 2, w - 4, h - 4 )

				surface.SetDrawColor( Color(255,255,255,255) )
				surface.SetMaterial(zoom_mat ) 

				local BoxSize = w - 4
				local xPos = 2
				local yPos = 2

				surface.DrawTexturedRectRotated( xPos + BoxSize * 0.25, yPos + BoxSize * 0.25, BoxSize * 0.5, BoxSize * 0.5, 90 )
				surface.DrawTexturedRectRotated( xPos + BoxSize * 0.75, yPos + BoxSize * 0.25, BoxSize * 0.5, BoxSize * 0.5, 0 )
				surface.DrawTexturedRectRotated( xPos + BoxSize * 0.25, yPos + BoxSize * 0.75, BoxSize * 0.5, BoxSize * 0.5, 180 )
				surface.DrawTexturedRectRotated( xPos + BoxSize * 0.75, yPos + BoxSize * 0.75, BoxSize * 0.5, BoxSize * 0.5, 270 )

				surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
				surface.DrawRect( 4, h - 24, w-8, 20  )
		
				local Item = self:GetItem()
				if Item then
					draw.SimpleText( Item.name.." ["..Item.Type.."]", "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				else
					draw.SimpleText( self.ClassName, "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				end
			else
				local Col = menu_text

				if IsValid( self.menu ) then
					surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
					DrawFrame( w, h, 2, 2 )
				end

				Col = menu_light

				surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
				surface.DrawRect( 4, h - 24, w-8, 20  )

				local Item = self:GetItem()
				if Item then
					draw.SimpleText( Item.name.." ["..Item.Type.."]", "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				else
					draw.SimpleText( self.ClassName, "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				end
			end
		end
		DButton.DoClick = function( self )
			BaseButtonClick( self )
			self.menu = DermaMenu()
			self.menu:AddOption( "Equip", function()
				LocalPlayer():lscsEquipFromInventory( self:GetID() )
				self:SetEnabled( false )
			end )
			self.menu:AddOption( "Drop", function() LocalPlayer():lscsDropItem( self:GetID() ) self:SetEnabled( false ) end )
			self.menu:Open()
		end
		DButton.DoRightClick = function( self )
		end

		X = X + 128
		if X > (PanelSizeX - 128) then
			X = 8
			Y = Y + 128
		end
	end

	while Y < (PanelSizeY - 128) or X < (PanelSizeX - 128) do
		local Panel = vgui.Create( "DPanel", DScrollPanel )
		Panel:SetPos( X, Y )
		Panel:SetSize( 128, 128 )
		Panel.Paint = function(self, w, h )
			local Col = menu_dim
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			surface.DrawRect( 2, 2, w - 4, h - 4 )
		end

		X = X + 128
		if X > (PanelSizeX - 128) then
			if Y < (PanelSizeY - 128) then
				X = 8
			end
			Y = Y + 128
		end
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 2
end

local CrafterButtonPaint = function(self, w, h )
	if self.Item then
		if not self.Mat then
			if file.Exists( "materials/entities/"..self.Item.class..".png", "GAME" ) then
				self.Mat = Material( "entities/"..self.Item.class..".png" )
			else
				self.Mat = Material( "debug/debugwireframe" )
			end
		end

		surface.SetMaterial( self.Mat )
		surface.SetDrawColor( 255, 255, 255 ,255 )
		surface.DrawTexturedRect( 2, 2, w - 4, h - 4 )

		local IsMainHovered = IsValid(self.Main) and self.Main:IsHovered()
		if self:IsHovered() or IsValid( self.menu ) or IsMainHovered then
			Col = menu_light

			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			surface.DrawRect( 4, h - 24, w-8, 20  )

			draw.SimpleText( self.Item.name, "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		else
			surface.SetDrawColor( Color(255,255,255,255) )
			surface.SetMaterial(zoom_mat ) 
			local BoxSize = w - 4
			local xPos = 2
			local yPos = 2

			surface.DrawTexturedRectRotated( xPos + BoxSize * 0.25, yPos + BoxSize * 0.25, BoxSize * 0.5, BoxSize * 0.5, 90 )
			surface.DrawTexturedRectRotated( xPos + BoxSize * 0.75, yPos + BoxSize * 0.25, BoxSize * 0.5, BoxSize * 0.5, 0 )
			surface.DrawTexturedRectRotated( xPos + BoxSize * 0.25, yPos + BoxSize * 0.75, BoxSize * 0.5, BoxSize * 0.5, 180 )
			surface.DrawTexturedRectRotated( xPos + BoxSize * 0.75, yPos + BoxSize * 0.75, BoxSize * 0.5, BoxSize * 0.5, 270 )

			Col = menu_dark
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			surface.DrawRect( 4, h - 24, w-8, 20  )
	
			draw.SimpleText( self.Item.name, "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white_dim, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		end

		local Col = DrawButtonClick( self, w, h )
		
		if IsMainHovered then
			Col = menu_white
		end

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		DrawFrame( w, h, 0, 2 )


		local Col = menu_text
		if IsValid( self.menu ) then
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawFrame( w, h, 0, 2 )
		end
	else
		local Col = menu_dark
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )

		Col = DrawButtonClick( self, w, h )

		surface.SetMaterial( icon_cross )

		if self:IsHovered() then
			Col = Color(255,0,0,255)
		end
		if IsValid( self.menu ) then
			Col = menu_white
		end

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )

		surface.DrawTexturedRect( 32, 32, 64, 64 )

		DrawFrame( w, h, 0, 2 )

		draw.SimpleText( self.InfoText, "LSCS_FONT", w * 0.5, h - 8, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

		if IsValid( self.menu ) then
			Col = menu_text
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawFrame( w, h, 0, 2 )
		end
	end
end

function LSCS:BuildSaberMenu( Frame )
	local ply = LocalPlayer()
	local HiltR, HiltL = ply:lscsGetHilt()
	local BladeR, BladeL = ply:lscsGetBlade()

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY )
	Panel.Paint = function(self, w, h )
		local Col = menu_light
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 5, 15, PanelSizeX - 10, PanelSizeY - 15 )


		if IsValid( self.Main ) and self.Main:IsHovered() then
			local Col = menu_white_dim
			if HiltR and BladeR then
				Col = menu_white
			end
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY * 0.5,0), Vector(PanelSizeX * 0.5 + 64,35+64,0) )
			surface.DrawLine( 163, 99, PanelSizeX * 0.5 - 64,35+64 )
			Col = menu_white_dim
			if HiltL and BladeR then
				Col = menu_white
			end
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY * 0.5,0), Vector(PanelSizeX * 0.5 + 64,PanelSizeY - 64 - 35,0) )
			surface.DrawLine( 163, PanelSizeY - 64 - 35, PanelSizeX * 0.5 - 64,PanelSizeY - 64 - 35 )
		else
			local Col = menu_white_dim
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY * 0.5,0), Vector(PanelSizeX * 0.5 + 64,35+64,0) )
			surface.DrawLine( 163, 99, PanelSizeX * 0.5 - 64,35+64 )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY * 0.5,0), Vector(PanelSizeX * 0.5 + 64,PanelSizeY - 64 - 35,0) )
			surface.DrawLine( 163, PanelSizeY - 64 - 35, PanelSizeX * 0.5 - 64,PanelSizeY - 64 - 35 )
		end
	end

	local Main = vgui.Create( "DButton", Panel )
	Main:SetText( "" )
	Main:SetPos( PanelSizeX - 125,  PanelSizeY * 0.5 - 50 )
	Main:SetSize( 100, 100 )
	Main.Paint = function(self, w, h )
		local Col = menu_dark
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )

		Col = DrawButtonClick( self, w, h )

		surface.SetMaterial( icon_check )
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawTexturedRect( 18, 18, w - 36, h - 36 )

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		DrawFrame( w, h, 0, 2 )
	end
	Main.DoClick = function( self )
		BaseButtonClick( self )
		ply:lscsCraftSaber()
		Frame:Remove()
	end
	Panel.Main = Main

	-- RIGHT
	local Clear = vgui.Create( "Button", Panel )
	Clear:SetText( "" )	
	Clear:SetSize( 46,  46 )
	Clear:SetPos( PanelSizeX - 185, 79 )
	Clear.DoClick = function( self )
		BaseButtonClick( self )
		ply:lscsUnEquip( true, false, true, false )
	end
	Clear.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )
		surface.SetMaterial( icon_rhand )
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	local ButtonHilt = vgui.Create( "DButton", Panel )
	ButtonHilt.InfoText = "Hilt"
	ButtonHilt:SetText( "" )
	ButtonHilt:SetPos( PanelSizeX * 0.5 - 64, 35 )
	ButtonHilt:SetSize( 128, 128 )
	ButtonHilt.Item = LSCS:GetHilt( HiltR )
	ButtonHilt.Paint = CrafterButtonPaint
	ButtonHilt.DoClick = function( self )
		BaseButtonClick( self )
		if self.Item then
			self.menu = DermaMenu()
			self.menu:AddOption( "Unequip", function()
				ply:lscsUnEquip( true )
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				local item = LSCS:ClassToItem( v )
				if item.type == "hilt" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						LocalPlayer():lscsEquipFromInventory( k, 1 )
					end )
				end
			end
			if Num >= 1 then
				self.menu:Open()
			else
				surface.PlaySound("buttons/button10.wav")
				self.menu:Remove()
			end
		end
	end
	ButtonHilt.Main = Main

	local ButtonBlade = vgui.Create( "DButton", Panel )
	ButtonBlade.InfoText = "Crystal"
	ButtonBlade:SetText( "" )
	ButtonBlade:SetPos( 35, 35 )
	ButtonBlade:SetSize( 128, 128 )
	ButtonBlade.Item = LSCS:GetBlade( BladeR )
	ButtonBlade.Paint = CrafterButtonPaint
	ButtonBlade.DoClick = function( self )
		BaseButtonClick( self )
		if self.Item then
			self.menu = DermaMenu()
			self.menu:AddOption( "Unequip", function()
				ply:lscsUnEquip( false, false, true )
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				local item = LSCS:ClassToItem( v )
				if item.type == "crystal" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						LocalPlayer():lscsEquipFromInventory( k, 1 )
					end )
				end
			end
			if Num >= 1 then
				self.menu:Open()
			else
				surface.PlaySound("buttons/button10.wav")
				self.menu:Remove()
			end
		end
	end
	ButtonBlade.Main = Main

	-- LEFT
	local Clear = vgui.Create( "Button", Panel )
	Clear:SetText( "" )	
	Clear:SetSize( 46,  46 )
	Clear:SetPos( PanelSizeX - 185, PanelSizeY - 119 )
	Clear.DoClick = function( self )
		BaseButtonClick( self )
		ply:lscsUnEquip( false, true, false, true )
	end
	Clear.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )
		surface.SetMaterial( icon_lhand )
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	local ButtonHilt = vgui.Create( "DButton", Panel )
	ButtonHilt.InfoText = "Hilt"
	ButtonHilt:SetText( "" )
	ButtonHilt:SetPos( PanelSizeX * 0.5 - 64, PanelSizeY - 128 - 35 )
	ButtonHilt:SetSize( 128, 128 )
	ButtonHilt.Item = LSCS:GetHilt( HiltL )
	ButtonHilt.Paint = CrafterButtonPaint
	ButtonHilt.DoClick = function( self )
		BaseButtonClick( self )
		if self.Item then
			self.menu = DermaMenu()
			self.menu:AddOption( "Unequip", function()
				ply:lscsUnEquip( false, true )
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				local item = LSCS:ClassToItem( v )
				if item.type == "hilt" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						LocalPlayer():lscsEquipFromInventory( k, 2 )
					end )
				end
			end
			if Num >= 1 then
				self.menu:Open()
			else
				surface.PlaySound("buttons/button10.wav")
				self.menu:Remove()
			end
		end
	end
	ButtonHilt.Main = Main

	local ButtonBlade = vgui.Create( "DButton", Panel )
	ButtonBlade.InfoText = "Crystal"
	ButtonBlade:SetText( "" )
	ButtonBlade:SetPos( 35, PanelSizeY - 128 - 35 )
	ButtonBlade:SetSize( 128, 128 )
	ButtonBlade.Item = LSCS:GetBlade( BladeL )
	ButtonBlade.Paint = CrafterButtonPaint
	ButtonBlade.DoClick = function( self )
		BaseButtonClick( self )
		if self.Item then
			self.menu = DermaMenu()
			self.menu:AddOption( "Unequip", function()
				ply:lscsUnEquip( false, false, false, true)
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				local item = LSCS:ClassToItem( v )
				if item.type == "crystal" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						LocalPlayer():lscsEquipFromInventory( k, 2 )
					end )
				end
			end
			if Num >= 1 then
				self.menu:Open()
			else
				surface.PlaySound("buttons/button10.wav")
				self.menu:Remove()
			end
		end
	end
	ButtonBlade.Main = Main

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 3
end

function LSCS:BuildStanceMenu( Frame )
	local ply = LocalPlayer()
	local combo = ply:lscsGetCombo()

	local mdlStart = 4
	local mdlSize = PanelSizeY - 8 + FrameBarHeight

	local HeaderY = 24

	local hX = mdlStart * 2 + mdlSize
	local hY = mdlStart * 2 + HeaderY
	local hSizeX = PanelSizeX - hX - mdlStart
	local hSizeY =  100

	local sX = hX
	local sY = hY + hSizeY + mdlStart

	local sSizeX = hSizeX
	local sSizeY = (PanelSizeY + FrameBarHeight) - (hY + hSizeY + mdlStart * 2)

	local ColHead = menu_text
	local ColText = menu_white

	local LastID

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY + FrameBarHeight )
	Panel.Paint = function(self, w, h )
		draw.RoundedBoxEx( 8, 0, 0, w, h, menu_light, false, false, false, true )

		local Col = menu_dim

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( hX, mdlStart, hSizeX, HeaderY  )
		draw.SimpleText( "Information", "LSCS_FONT", hX + hSizeX * 0.5, mdlStart + HeaderY * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		surface.DrawRect( hX, sY, hSizeX, HeaderY  )
		draw.SimpleText( "Attacks", "LSCS_FONT", hX + hSizeX * 0.5, sY + HeaderY * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local description = vgui.Create( "DPanel", Panel )
	description:SetPos( hX, hY )
	description:SetSize( hSizeX, hSizeY )
	description.Paint = function(self, w, h ) 
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	end

	local richtext = vgui.Create( "RichText", description )
	richtext:Dock( FILL )
	richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
	richtext:AppendText("Name:\n")
	richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
	richtext:AppendText((combo.name or combo.id).."\n\n")
	richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
	richtext:AppendText("Description:\n")
	richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
	richtext:AppendText((combo.description or "").."\n\n")
	richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
	richtext:AppendText("Author:\n")
	richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
	richtext:AppendText((combo.author or "").."\n\n")
	richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
	richtext:AppendText("Internal-ID:\n")
	richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
	richtext:AppendText(combo.id)

	local SPB = vgui.Create( "DPanel", Panel )
	SPB:SetPos( sX, sY + HeaderY + mdlStart )
	SPB:SetSize( sSizeX, sSizeY - HeaderY - mdlStart )
	SPB.Paint = function(self, w, h )
		draw.RoundedBoxEx( 8, 0, 0, w, h, menu_dim, false, false, false, true )
	end

	local mdl = vgui.Create( "DModelPanel", Panel )
	mdl:SetPos( mdlStart, mdlStart )
	mdl:SetSize( mdlSize, mdlSize )
	mdl:SetFOV( 50 )
	mdl:SetCamPos( vector_origin )
	mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
	mdl:SetAnimated( true )
	mdl.Angles = angle_zero
	mdl:SetLookAt( Vector( -100, 0, -22 ) )
	mdl:SetModel( LocalPlayer():GetModel() )
	function mdl.Entity:GetPlayerColor() return LocalPlayer():GetPlayerColor() end
	mdl.Entity:SetPos( Vector( -100, 0, -61 ) )

	function mdl:DragMousePress()
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end

	function mdl:DragMouseRelease() self.Pressed = false end

	function mdl:LayoutEntity( ent )
		if ( self.bAnimated ) then self:RunAnimation() end

		if ( self.Pressed ) then
			local mx = gui.MousePos()
			self.Angles = self.Angles - Angle( 0, ( ( self.PressX or mx ) - mx ) / 2, 0 )

			self.PressX, self.PressY = gui.MousePos()
		end

		ent:SetAngles( self.Angles )
	end

	mdl.Paint = function(self, w, h )
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	
		if not IsValid( self.Entity ) then return end

		local x, y = self:LocalToScreen( 0, 0 )

		self:LayoutEntity( self.Entity )

		local ang = self.aLookAngle
		if not ang then
			ang = ( self.vLookatPos - self.vCamPos ):Angle()
		end

		cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( self.Entity:GetPos() )
		render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
		render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
		render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()

		for i = 0, 6 do
			local col = self.DirectionalLight[ i ]
			if ( col ) then
				render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
			end
		end

		self:DrawModel()

		render.SuppressEngineLighting( false )
		cam.End3D()

		self.LastPaint = RealTime()
	end

	local DScrollPanel = vgui.Create( "DScrollPanel", SPB )
	DScrollPanel:Dock( FILL )

	for index, attack in pairs( combo.Attacks ) do
		local DButton = DScrollPanel:Add( "DButton" )
		DButton:SetText( index )
		DButton:Dock( TOP )
		DButton:DockMargin( 5, 5, 5, 2.5 )
		DButton.Paint = function(self, w, h )
			DrawButtonClick( self, w, h ) 
			if LastID == index then
				local Col = menu_text
				surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
				DrawFrame( w, h, 0, 2 )
			end
		end
		DButton.DoClick = function( self )
			BaseButtonClick( self )

			LastID = index

			local model = mdl.Entity
			if IsValid( model ) then
				if (model.Next or 0) < CurTime() then
					local seqID = model:LookupSequence( attack.AttackAnim )
					model:SetSequence( seqID )
					model:ResetSequence( seqID )
					model:SetCycle( 0 )
				end
			end
		end
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 4
end

function LSCS:BuildSettings( Frame )
	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY )
	Panel.Paint = function(self, w, h )
		local Col = menu_light
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 5
end

function LSCS:RefreshMenu()
	if not IsValid( Frame ) then return end

	if Frame.ID == 2 then
		LSCS:BuildInventory( Frame )
	end
	if Frame.ID == 3 then
		LSCS:BuildSaberMenu( Frame )
	end
end

function LSCS:OpenMenu()
	if not IsValid( Frame ) then
		Frame = vgui.Create( "DFrame" )
		Frame:SetSize( FrameSizeX, FrameSizeY )
		Frame:SetTitle( "" )
		Frame:SetDraggable( true )
		Frame:SetScreenLock( true )
		Frame:MakePopup()
		Frame:Center()
		Frame.Paint = function(self, w, h )
			draw.RoundedBox( 8, 0, 0, w, h, menu_light )
			draw.RoundedBoxEx( 8, 0, 0, w, FrameBarHeight, menu_dark, true, true, false, false)
			draw.SimpleText( "[LSCS] - Control Panel ", "LSCS_FONT", 5, 11, menu_white_dim , TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		Frame.GetSideBar = function(self)
			return self.SideBar 
		end
		Frame.SideBarIsActivated = function( self )
			return self._smSB == SelectorWidthActive
		end
		Frame.SideBarIsActive = function( self )
			return self._isActive == true
		end
		Frame.SideBarSetActive = function( self, active )
			self._isActive = active
		end
		Frame.oldThink = Frame.Think
		Frame.Think = function( self )
			self:oldThink()

			local Rate = RealFrameTime() * 1000
			local Active = self:SideBarIsActive()
			local TargetWidth = Active and SelectorWidthActive or SelectorWidth

			local X, Y = self:CursorPos()

			if Active then
				if X < 0 or X > SelectorWidthActive or Y < 0 or Y > FrameSizeY then
					self:SideBarSetActive( false )
				end
			else
				if X > 0 and X < SelectorWidth and Y > 0 and Y < FrameSizeY then
					self:SideBarSetActive( true )
				end
			end

			self._smSB = self._smSB and (self._smSB + math.Clamp(TargetWidth - self._smSB,-Rate,Rate)) or SelectorWidth

			if self._smSB ~= self.old_smSB then
				self.old_smSB = self._smSB

				local SB = self:GetSideBar()
				if IsValid( SB ) then
					SB:SetSize( self._smSB, SelectorHeight )
				end
			end
		end

		LSCS:BuildMainMenu( Frame )
	end
end

list.Set( "DesktopWindows", "LSCSMenu", {
	title = "[LSCS] Menu",
	icon = "lscs/ui/icon64.png",
	init = function( icon, window )
		LSCS:OpenMenu()
	end
} )

concommand.Add( "lscs_openmenu", function( ply, cmd, args ) LSCS:OpenMenu() end )
