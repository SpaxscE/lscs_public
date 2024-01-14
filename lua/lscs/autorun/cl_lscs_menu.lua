local THE_FONT = {
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
}
surface.CreateFont( "LSCS_FONT", THE_FONT )

THE_FONT.size = 12
THE_FONT.weight = 500
surface.CreateFont( "LSCS_FONT_SMALL", THE_FONT )

THE_FONT.font = "Ink Free"
THE_FONT.size = 16
THE_FONT.weight = 1000
surface.CreateFont( "LSCS_VERSION", THE_FONT )

THE_FONT.size = 40
THE_FONT.weight = 1000
surface.CreateFont( "LSCS_FONT_MAXIMUM", THE_FONT )

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
local icon_force = Material("lscs/ui/force.png")
local icon_settings = Material("lscs/ui/settings.png")

local icon_check = Material("lscs/ui/check.png")
local icon_cross = Material("lscs/ui/cross.png")

local icon_hand = Material("lscs/ui/hand.png")
local icon_lhand = Material("lscs/ui/hand_l.png")
local icon_rhand = Material("lscs/ui/hand_r.png")

local icon_load_version = Material("gui/html/refresh")

local icon_invert = Material( "lscs/ui/logo_invert.png")
local icon_steam = Material("lscs/ui/steam.png")
local icon_youtube = Material("lscs/ui/youtube.png")
local icon_discord = Material("lscs/ui/discord.png")
local icon_github = Material("lscs/ui/github.png")

local zoom_mat = Material( "vgui/zoom" )
local gradient_mat = Material( "gui/gradient" )
local adminMat = Material( "icon16/shield.png" )

local function BaseButtonClick( self, sound )
	if not self:IsEnabled() then return end

	sound = sound or "ui/buttonclick.wav"

	surface.PlaySound( sound )
	self.smScale = 1
end

local function DrawButtonClick( self, w, h ) 
	local Col = menu_white_dim
	if self:IsHovered() then
		Col = menu_white
	end
	if not self:IsEnabled() then
		Col = menu_text
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

local ForceNum = 1
local StanceNum = 1
local Frame

local FrameBarHeight = 24

local FrameSizeX = 750
local FrameSizeY = 480 + FrameBarHeight

local SelectorHeight = 80 * 6
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

	local button = CreateSideBarButton( icon_force, 5, "Force" )
		button.DoClick = function( self )
		BaseButtonClickSB( self )
		LSCS:BuildForceMenu( Frame )
	end

	local button = CreateSideBarButton( icon_settings, 6, "Settings" )
		button.DoClick = function( self )
		BaseButtonClickSB( self )
		LSCS:BuildSettings( Frame )
	end
end

function LSCS:BuildMainMenu( Frame )
	local smMove = 0

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY + FrameBarHeight )
	Panel.Paint = function(self, w, h )
		local Col = Color( 255, 191, 0, 255 ) 

		surface.SetDrawColor( menu_dim )
		surface.DrawRect( 4, h - 64, w - 8, 60 )

		if LSCS.VERSION_GITHUB == 0 then
			surface.SetMaterial( icon_load_version )
			surface.SetDrawColor( Col )
			surface.DrawTexturedRectRotated( w - 14, h - 14, 16, 16, -CurTime() * 200 )

			draw.SimpleText( "v"..LSCS:GetVersion()..LSCS.VERSION_TYPE, "LSCS_VERSION", w - 23, h - 14, Col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		else
			local Current = LSCS:GetVersion()
			local Latest = LSCS.VERSION_GITHUB

			local Pref = "v"

			if Current >= Latest then
				Col = Color(0,255,0,255)
			else
				Col = Color(255,0,0,255)
				Pref = "OUTDATED v"
			end

			draw.SimpleText( Pref..LSCS:GetVersion()..LSCS.VERSION_TYPE, "LSCS_VERSION", w - 7, h - 14, Col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		end
	end

	local Header = vgui.Create( "DPanel", Panel )
	Header:SetSize( 0, 136 )
	Header:Dock( TOP )
	Header.Paint = function(self, w, h )
		-- showoff lmao
		local Col = menu_light

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )

		local A = math.rad( CurTime() * 150 )
		local X = math.cos( A ) * w * 0.5
		local Y = math.sin( A ) * h * 0.5

		surface.SetDrawColor( menu_dim )
		surface.DrawRect( w - 132, 4, 128, 128 )

		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( menu_text )

		surface.DrawTexturedRectRotated( w * 0.5 + X - 5, h * 0.5 + Y, 150, 150, 0 )

		surface.SetDrawColor( menu_dim )
		surface.SetMaterial( icon_invert )
		surface.DrawTexturedRect( w - 132, 4, 128, 128 )
		surface.DrawRect( 4, 4, w - 136, 128 )

		draw.SimpleText( "THANK YOU FOR USING", "LSCS_FONT_MAXIMUM", w * 0.5 - 18, h * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "LSCS", "LSCS_FONT_MAXIMUM", w * 0.5 - 18, h * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	local Bar = vgui.Create( "DPanel", Panel )
	Bar:SetSize( 0, 136 )
	Bar:Dock( TOP )
	Bar:DockMargin( 4, 0, 4, 4 )
	Bar.Paint = function(self, w, h )
		local Col = menu_dim

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )
	end

	local B = vgui.Create( "DButton", Bar )
	B:SetText("")
	B:SetSize( PanelSizeX * 0.45 , 128 )
	B:Dock( LEFT )
	B:DockMargin( 4, 4, 4, 4 )
	B.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		draw.SimpleText( "PROBLEMS?", "LSCS_FONT_MAXIMUM", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "REPORT HERE", "LSCS_FONT_MAXIMUM", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	B.DoClick = function( self )
		BaseButtonClick( self )
		timer.Simple( 0.5, function()
			gui.OpenURL( "https://github.com/Blu-x92/lscs_public" )
		end )
	end

	local B = vgui.Create( "DButton", Bar )
	B:SetText("")
	B:SetSize( PanelSizeX * 0.5 , 128 )
	B:Dock( LEFT )
	B:DockMargin( 4, 4, 4, 4 )
	B.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		draw.SimpleText( "THIS PROJECT", "LSCS_FONT_MAXIMUM", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "ON STEAM", "LSCS_FONT_MAXIMUM", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end
	B.DoClick = function( self )
		BaseButtonClick( self )
		timer.Simple( 0.5, function()
			gui.OpenURL( "https://steamcommunity.com/sharedfiles/filedetails/?id=2837856621" )
		end )
	end

	local ToolBar = vgui.Create( "DPanel", Panel )
	ToolBar:SetSize( 0, 136 )
	ToolBar:Dock( TOP )
	ToolBar:DockMargin( 4, 0, 4, 4 )
	ToolBar.Paint = function(self, w, h )
		local Col = menu_dim

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )
	end

	local B = vgui.Create( "DButton", ToolBar )
	B:SetText("")
	B:SetSize( 128, 128 )
	B:Dock( LEFT )
	B:DockMargin( 60, 4, 4, 4 )
	B.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		surface.SetMaterial( icon_steam )
		surface.SetDrawColor( Col )
		surface.DrawTexturedRectRotated( w * 0.5, h * 0.5, w, h, 0 )

		draw.SimpleText( "STEAM", "LSCS_FONT", w * 0.5, h - 4, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	end
	B.DoClick = function( self )
		BaseButtonClick( self )
		timer.Simple( 0.5, function()
			gui.OpenURL( "https://steamcommunity.com/id/Blu-x92/myworkshopfiles/" )
		end )
	end

	local B = vgui.Create( "DButton", ToolBar )
	B:SetText("")
	B:SetSize( 128, 128 )
	B:Dock( LEFT )
	B:DockMargin( 4, 4, 4, 4 )
	B.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		surface.SetMaterial( icon_discord )
		surface.SetDrawColor( Col )
		surface.DrawTexturedRectRotated( w * 0.5, h * 0.5, w, h, 0 )

		draw.SimpleText( "DISCORD", "LSCS_FONT", w * 0.5, h - 4, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	end
	B.DoClick = function( self )
		BaseButtonClick( self )
		timer.Simple( 0.5, function()
			gui.OpenURL( "https://discord.gg/BeVtn7uwNH" )
		end )
	end

	local B = vgui.Create( "DButton", ToolBar )
	B:SetText("")
	B:SetSize( 128, 128 )
	B:Dock( LEFT )
	B:DockMargin( 4, 4, 4, 4 )
	B.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		surface.SetMaterial( icon_youtube )
		surface.SetDrawColor( Col )
		surface.DrawTexturedRectRotated( w * 0.5, h * 0.5, w, h, 0 )

		draw.SimpleText( "YOUTUBE", "LSCS_FONT", w * 0.5, h - 4, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	end
	B.DoClick = function( self )
		BaseButtonClick( self )
		timer.Simple( 0.5, function()
			gui.OpenURL( "https://www.youtube.com/channel/UCoXuTyv69fGOUv7hZcAPHoQ" )
		end )
	end

	local B = vgui.Create( "DButton", ToolBar )
	B:SetText("")
	B:SetSize( 128, 128 )
	B:Dock( LEFT )
	B:DockMargin( 4, 4, 4, 4 )
	B.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		surface.SetMaterial( icon_github )
		surface.SetDrawColor( Col )
		surface.DrawTexturedRectRotated( w * 0.5, h * 0.5, w, h, 0 )

		draw.SimpleText( "GITHUB", "LSCS_FONT", w * 0.5, h - 4, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	end
	B.DoClick = function( self )
		BaseButtonClick( self )
		timer.Simple( 0.5, function()
			gui.OpenURL( "https://github.com/Blu-x92" )
		end )
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 1
end

function LSCS:BuildInventory( Frame )
	local ply = LocalPlayer()

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY + FrameBarHeight )
	Panel.Paint = function(self, w, h )
		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 255, 255, 255, 255 )
		local X, Y = self:CursorPos()
		surface.DrawTexturedRectRotated( X, Y, 512, 512, 0 )

		local Col = menu_light
		surface.SetDrawColor( Col.r, Col.g, Col.b, 240 )
		surface.DrawRect( 0, 0, w, h  )
	end

	local ToolBar = vgui.Create( "DPanel", Panel )
	ToolBar:SetSize( PanelSizeX, 50 )
	ToolBar:Dock( BOTTOM )
	ToolBar:DockMargin( 10, 4, 24, 10 )
	ToolBar.Paint = function(self, w, h )
		local Col = menu_dim

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )
	end

	local Refresh = vgui.Create( "DButton", ToolBar )
	Refresh:SetText("")
	Refresh:SetSize( 130, 100 )
	Refresh:Dock( RIGHT )
	Refresh:DockMargin( 4, 4, 4, 4 )
	Refresh.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		draw.SimpleText( "REFRESH", "LSCS_FONT", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )

		DrawFrame( w, h, 0, 2 )
	end
	Refresh.DoClick = function( self )
		BaseButtonClick( self )

		self:SetEnabled( false )

		timer.Simple( 0.2, function()
			if not IsValid( self ) then return end
			self:SetEnabled( true )
			net.Start("lscs_inventory_refresh")
				net.WriteBool( false )
			net.SendToServer()
		end )
	end

	local DropAll = vgui.Create( "DButton", ToolBar )
	DropAll:SetText("")
	DropAll:SetSize( 180, 100 )
	DropAll:Dock( LEFT )
	DropAll:DockMargin( 4, 4, 4, 4 )
	DropAll.SafetyEnabled = 1
	DropAll.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		if self.SafetyEnabled == 1 then
			draw.SimpleText( "DROP ALL", "LSCS_FONT", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		elseif self.SafetyEnabled == 2 then
			draw.SimpleText( "ARE YOU SURE??", "LSCS_FONT", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			Col = Color(255, 0, 0, 255)
			surface.SetMaterial( ClickMat )
			surface.SetDrawColor( 150, 0, 0, 255 )
			surface.DrawTexturedRect( 0, 0, w, h )

			draw.SimpleText( "!!DROP ALL!!", "LSCS_FONT", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )

		DrawFrame( w, h, 0, 2 )
	end
	DropAll.DoClick = function( self )
		BaseButtonClick( self )

		if self.SafetyEnabled < 3 then
			self:SetEnabled( false )

			timer.Simple( 1, function()
				if not IsValid( self ) then return end
				self:SetEnabled( true )
				self.SafetyEnabled = self.SafetyEnabled + 1
			end )
		else
			self:SetEnabled( false )

			net.Start("lscs_inventory_refresh")
				net.WriteBool( true )
				net.WriteBool( false )
			net.SendToServer()
		end
	end

	local DropUnEq = vgui.Create( "DButton", ToolBar )
	DropUnEq:SetText("")
	DropUnEq:SetSize( 180, 100 )
	DropUnEq:Dock( LEFT )
	DropUnEq:DockMargin( 4, 4, 4, 4 )
	DropUnEq.SafetyEnabled = 1
	DropUnEq.Paint = function(self, w, h )
		local Col = DrawButtonClick( self, w, h )

		if self.SafetyEnabled == 1 then
			draw.SimpleText( "DROP", "LSCS_FONT", w * 0.5, h * 0.5 + 2, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( "UNEQUIPPED", "LSCS_FONT", w * 0.5, h * 0.5 - 2, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		elseif self.SafetyEnabled == 2 then
			draw.SimpleText( "ARE YOU SURE??", "LSCS_FONT", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			Col = Color(255, 0, 0, 255)
			surface.SetMaterial( ClickMat )
			surface.SetDrawColor( 150, 0, 0, 255 )
			surface.DrawTexturedRect( 0, 0, w, h )

			draw.SimpleText( "!!DROP!!", "LSCS_FONT", w * 0.5, h * 0.5 + 2, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( "!!UNEQUIPPED!!", "LSCS_FONT", w * 0.5, h * 0.5 - 2, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
		end

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )

		DrawFrame( w, h, 0, 2 )
	end
	DropUnEq.DoClick = function( self )
		BaseButtonClick( self )

		if self.SafetyEnabled < 3 then
			self:SetEnabled( false )

			timer.Simple( 1, function()
				if not IsValid( self ) then return end
				self:SetEnabled( true )
				self.SafetyEnabled = self.SafetyEnabled + 1
			end )
		else
			self:SetEnabled( false )

			net.Start("lscs_inventory_refresh")
				net.WriteBool( true )
				net.WriteBool( true )
			net.SendToServer()
		end
	end

	local DScrollPanel = vgui.Create( "DScrollPanel", Panel )
	DScrollPanel:SetSize( PanelSizeX, PanelSizeY - 40 )
	DScrollPanel:Dock( BOTTOM )

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

				local eq = ply:lscsGetEquipped()[ self:GetID() ] 
				if isbool( eq ) then
					surface.SetDrawColor( 255, 191, 0, 255 )
					DrawFrame( w, h, 2, 2 )

					if Item and (Item.type == "hilt" or Item.type == "crystal") then
						if eq == true then
							surface.SetMaterial( icon_rhand )
						else
							surface.SetMaterial( icon_lhand )
						end
					else
						surface.SetMaterial( icon_hand )
					end
					surface.DrawTexturedRect( 4, 4, 64, 64 )

				end
			else
				local Col = menu_light

				surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
				surface.DrawRect( 4, h - 24, w-8, 20  )

				local Item = self:GetItem()
				if Item then
					draw.SimpleText( Item.name.." ["..Item.Type.."]", "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				else
					draw.SimpleText( self.ClassName, "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				end

				Col = menu_text

				if IsValid( self.menu ) then
					surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
					DrawFrame( w, h, 2, 2 )
					if isbool( ply:lscsGetEquipped()[ self:GetID() ] ) then
						surface.SetDrawColor( 255, 191, 0, 255 )
						DrawFrame( w, h, 4, 2 )
					end
				else
					if isbool( ply:lscsGetEquipped()[ self:GetID() ] ) then
						surface.SetDrawColor( 255, 191, 0, 255 )
						DrawFrame( w, h, 2, 2 )
					else
						if self:IsHovered() then
							surface.SetDrawColor( Color(255,255,255,255) )
							DrawFrame( w, h, 2, 2 )
						end
					end
				end
			end
		end
		DButton.DoClick = function( self )
			BaseButtonClick( self )

			self.menu = DermaMenu()

			if isbool( ply:lscsGetEquipped()[ self:GetID() ] ) then
				self.menu:AddOption( "Unequip", function()
					if not self.GetItem then return end -- what happened ?

					local Item = self:GetItem()

					if not Item then return end

					if Item.type == "hilt" or Item.type == "crystal" then
						ply:lscsEquipItem( self:GetID(), nil )
						ply:lscsCraftSaber()
					else
						ply:lscsEquipItem( self:GetID(), nil )
					end
				end )
			else
				self.menu:AddOption( "Equip", function()
					if not self.GetItem then return end -- what happened ?

					local Item = self:GetItem()

					if not Item then return end

					if Item.type == "hilt" then
						ply:lscsClearEquipped( "hilt" )
					end

					if Item.type == "crystal" then
						ply:lscsClearEquipped( "crystal" )
					end

					ply:lscsEquipItem( self:GetID(), true )

					if Item.type =="hilt" or Item.type == "crystal" then
						local A, _ = ply:lscsGetHilt()
						local B, _ = ply:lscsGetBlade()
						if A and A ~= "" and B and B ~= "" then
							ply:lscsCraftSaber()
						end
					end
				end )
			end
			self.menu:AddOption( "Drop", function() ply:lscsDropItem( self:GetID() ) self:SetEnabled( false ) end )
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
		surface.DrawTexturedRect( 2, h * 0.5 - w * 0.5 - 2, w - 4, w - 4 )

		local IsMainHovered = IsValid(self.Main) and self.Main:IsHovered()
		if self:IsHovered() or IsValid( self.menu ) or IsMainHovered then
			Col = menu_light

			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			surface.DrawRect( 4, h - 24, w-8, 20  )

			draw.SimpleText( self.Item.name, "LSCS_FONT_SMALL", w * 0.5, h - 8, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		else
			surface.SetDrawColor( Color(255,255,255,255) )
			surface.SetMaterial(zoom_mat ) 
			local BoxSizeX = w - 4
			local BoxSizeY = h - 4
			local xPos = 2
			local yPos = 2

			surface.DrawTexturedRectRotated( xPos + BoxSizeX * 0.25, yPos + BoxSizeY * 0.25, BoxSizeY * 0.5, BoxSizeX * 0.5, 90 )
			surface.DrawTexturedRectRotated( xPos + BoxSizeX * 0.75, yPos + BoxSizeY * 0.25, BoxSizeX * 0.5, BoxSizeY * 0.5, 0 )
			surface.DrawTexturedRectRotated( xPos + BoxSizeX * 0.25, yPos + BoxSizeY * 0.75, BoxSizeX * 0.5, BoxSizeY * 0.5, 180 )
			surface.DrawTexturedRectRotated( xPos + BoxSizeX * 0.75, yPos + BoxSizeY * 0.75, BoxSizeY * 0.5, BoxSizeX * 0.5, 270 )

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

	local AAA = 80

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY + FrameBarHeight )
	Panel.Paint = function(self, w, h )
		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 150,150,150,150 )
		local X, Y = self:CursorPos()
		surface.DrawTexturedRectRotated( X, Y, 512, 512, 0 )

		draw.RoundedBoxEx( 8, 4, 4, w - 8, h - 8, menu_dim, false, false, false, true )

		draw.SimpleText( "Information", "LSCS_FONT", 8, 14, menu_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "NOTE: For this to work you need a Hilt and a Blade-Crystal in your Inventory and you must have permission to spawn SWEP's", "LSCS_FONT_SMALL", 8, 30, menu_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		if IsValid( self.Main ) and self.Main:IsHovered() then
			local Col = menu_white_dim
			if HiltR and BladeR then
				Col = menu_white
			end
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY - 54,0), Vector(PanelSizeX * 0.5 + 64,35+64+AAA,0) )
			surface.DrawLine( 163, 99+AAA, PanelSizeX * 0.5 - 64,35+64+AAA )
			Col = menu_white_dim
			if HiltL and BladeL then
				Col = menu_white
			end
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY - 54,0), Vector(PanelSizeX * 0.5 + 64,PanelSizeY - 64 - 35,0) )
			surface.DrawLine( 163, PanelSizeY - 64 - 35, PanelSizeX * 0.5 - 64,PanelSizeY - 64 - 35 )
		else
			local Col = menu_white_dim
			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY - 54,0), Vector(PanelSizeX * 0.5 + 64,35+64+AAA,0) )
			surface.DrawLine( 163, 99+AAA, PanelSizeX * 0.5 - 64,35+64+AAA )
			DrawBezier( Vector(PanelSizeX - 125,PanelSizeY - 54,0), Vector(PanelSizeX * 0.5 + 64,PanelSizeY - 64 - 35,0) )
			surface.DrawLine( 163, PanelSizeY - 64 - 35, PanelSizeX * 0.5 - 64,PanelSizeY - 64 - 35 )
		end
	end

	local Main = vgui.Create( "DButton", Panel )
	Main:SetText( "" )
	Main:SetPos( PanelSizeX - 125, PanelSizeY - 104 )
	Main:SetSize( 100, 100 )
	Main.Paint = function(self, w, h )
		local Col = menu_dark
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )

		Col = DrawButtonClick( self, w, h )
		local Col2 = Col

		surface.SetMaterial( icon_check )
		if self:IsHovered() then
			Col2 = Color(0,255,0)
		end
		surface.SetDrawColor( Col2.r, Col2.g, Col2.b, Col2.a )
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
	local ButtonHilt = vgui.Create( "DButton", Panel )
	ButtonHilt.InfoText = "Hilt [RH]"
	ButtonHilt:SetText( "" )
	ButtonHilt:SetPos( PanelSizeX * 0.5 - 64, 35 + AAA )
	ButtonHilt:SetSize( 128, 128 )
	ButtonHilt.Item = LSCS:GetHilt( HiltR )
	ButtonHilt.Paint = CrafterButtonPaint
	ButtonHilt.DoClick = function( self )
		BaseButtonClick( self )
		if self.Item then
			self.menu = DermaMenu()
			self.menu:AddOption( "Unequip", function()
				ply:lscsClearEquipped( "hilt", true )
				ply:lscsCraftSaber()
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				if isbool( ply:lscsGetEquipped()[ k ] ) then continue end

				local item = LSCS:ClassToItem( v )
				if item.type == "hilt" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						ply:lscsEquipItem( k, true )
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
	ButtonBlade.InfoText = "Crystal [RH]"
	ButtonBlade:SetText( "" )
	ButtonBlade:SetPos( 35, 35+AAA )
	ButtonBlade:SetSize( 128, 128 )
	ButtonBlade.Item = LSCS:GetBlade( BladeR )
	ButtonBlade.Paint = CrafterButtonPaint
	ButtonBlade.DoClick = function( self )
		BaseButtonClick( self )

		if self.Item then
			self.menu = DermaMenu()
			self.menu:AddOption( "Unequip", function()
				ply:lscsClearEquipped( "crystal", true )
				ply:lscsCraftSaber()
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				if isbool( ply:lscsGetEquipped()[ k ] ) then continue end

				local item = LSCS:ClassToItem( v )
				if item.type == "crystal" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						ply:lscsEquipItem( k, true )
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
	local ButtonHilt = vgui.Create( "DButton", Panel )
	ButtonHilt.InfoText = "Hilt [LH]"
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
				ply:lscsClearEquipped( "hilt", false )
				ply:lscsCraftSaber()
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				if isbool( ply:lscsGetEquipped()[ k ] ) then continue end

				local item = LSCS:ClassToItem( v )

				if not item then continue end

				if item.type == "hilt" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						ply:lscsEquipItem( k, false )
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
	ButtonBlade.InfoText = "Crystal [LH]"
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
				ply:lscsClearEquipped( "crystal", false )
				ply:lscsCraftSaber()
			end )
			self.menu:Open()
		else
			self.menu = DermaMenu()
			local Num = 0
			for k, v in pairs( ply:lscsGetInventory() ) do
				if isbool( ply:lscsGetEquipped()[ k ] ) then continue end

				local item = LSCS:ClassToItem( v )

				if not item then continue end

				if item.type == "crystal" then
					Num = Num + 1
					self.menu:AddOption( item.name, function()
						ply:lscsEquipItem( k, false )
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

	if StanceNum > #ply:lscsGetCombo() then
		StanceNum = 1
	end

	local combo = ply:lscsGetCombo( StanceNum )

	local ColHead = menu_text
	local ColText = menu_white

	local LastID

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY + FrameBarHeight )
	Panel.Paint = function(self, w, h )
		draw.RoundedBoxEx( 8, 0, 0, w, h, menu_light, false, false, false, true )

		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 150,150,150,150 )
		local X, Y = self:CursorPos()
		surface.DrawTexturedRectRotated( X, Y, 512, 512, 0 )
	end

	local mdl = vgui.Create( "DModelPanel", Panel )
	mdl:SetSize( 250, 0)
	mdl:Dock( RIGHT )
	mdl:DockMargin( 4, 4, 4, 4 )
	mdl:SetFOV( 30 )
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

	local descriptionHeader = vgui.Create( "DPanel", Panel )
	descriptionHeader:Dock( TOP )
	descriptionHeader:DockMargin( 4, 4, 0, 0 )
	descriptionHeader.Paint = function(self, w, h )
		local Col = menu_dim

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )
		draw.SimpleText( "Information", "LSCS_FONT", w * 0.5, h * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	end

	local SPB = vgui.Create( "DPanel", Panel )
	SPB:SetSize( 0, 280 )
	SPB:Dock( BOTTOM )
	SPB:DockMargin( 4, 4, 0, 4 )
	SPB.Paint = function(self, w, h )
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	end

	local DScrollPanel = vgui.Create( "DScrollPanel", SPB )
	DScrollPanel:Dock( FILL )

	local nice_combo = {}

	for index, obj in pairs( combo.Attacks ) do
		local info = LSCS.ComboInfo[ index ]

		local data = {
			text = info.description,
			name = info.name,
			AttackAnim = (obj.AttackAnimMenu or obj.AttackAnim),
			id = info.order,
		}
		table.insert( nice_combo, data )
	end
	table.sort( nice_combo, function( a, b ) return a.id < b.id end )

	for index, data in ipairs( nice_combo ) do
		local DButton = DScrollPanel:Add( "DButton" )
		DButton.InfoText = data.text
		DButton.InfoName = data.name
		DButton:SetSize(100,50)
		DButton:SetText("")
		DButton:Dock( TOP )
		DButton:DockMargin( 5, 5, 5, 2.5 )
		DButton.Paint = function(self, w, h )
			DrawButtonClick( self, w, h ) 
			local Col = menu_white_dim

			if LastID == index then
				Col = menu_text
				draw.SimpleText( "["..self.InfoName.."]", "LSCS_FONT", w * 0.5, 2, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

				surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
				DrawFrame( w, h, 0, 2 )
				Col = menu_white
			else
				if self:IsHovered() then
					Col = menu_white
					surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
					DrawFrame( w, h, 0, 2 )
				end

				draw.SimpleText( self.InfoName, "LSCS_FONT", w * 0.5, h * 0.5, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

				return
			end

			local words = string.Explode( "\n", self.InfoText )
			if #words > 1 then
				draw.SimpleText( words[1], "LSCS_FONT_SMALL", w * 0.5, h - 2 - 12, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				draw.SimpleText( words[2], "LSCS_FONT_SMALL", w * 0.5, h - 2, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			else
				draw.SimpleText( words[1], "LSCS_FONT_SMALL", w * 0.5, h - 8, Col, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			end
		end
		DButton.DoClick = function( self )
			BaseButtonClick( self )

			LastID = index

			local model = mdl.Entity
			if IsValid( model ) then
				local seqID = model:LookupSequence( data.AttackAnim )
				model:SetSequence( seqID )
				model:ResetSequence( seqID )
				model:SetCycle( 0 )
			end
		end
	end

	local description = vgui.Create( "DPanel", Panel )
	description:SetSize( 275, 0 )
	description:Dock( LEFT )
	description:DockMargin( 4, 4, 0, 0 )
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

	if combo.LeftSaberActive then
		richtext:InsertColorChange( 0,255,0,255 )
		richtext:AppendText("This Stance supports Left Hand Sabers\n\n")
	else
		richtext:InsertColorChange( 255,200,0,255 )
		richtext:AppendText("This Stance does not support Left Hand Sabers\n\n")
	end

	richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )

	richtext:AppendText("Author:\n")
	richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
	richtext:AppendText((combo.author or "").."\n\n")
	richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )

	local Button = vgui.Create( "DButton", Panel )
	Button.Item = combo
	Button:SetText( "" )
	Button:SetSize( 130, 0 )
	Button:Dock( LEFT )
	Button:DockMargin( 4, 4, 4, 0 )
	Button.Paint = function( self, w, h )
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		CrafterButtonPaint( self, w, h )
	end
	Button.DoClick = function( self )
		BaseButtonClick( self )

		local NumCombo = #ply:lscsGetCombo()

		self.menu = DermaMenu()

		self.menu:AddOption( "view next", function()
			StanceNum = StanceNum + 1
			if StanceNum > NumCombo then
				StanceNum = 1
			end
			combo = ply:lscsGetCombo( StanceNum )
			self.menu:Remove()
			LSCS:RefreshMenu()
		end )
		self.menu:AddOption( "view previous", function()
			StanceNum = StanceNum - 1
			if StanceNum <= 0 then
				StanceNum = NumCombo
			end
			combo = ply:lscsGetCombo( StanceNum )
			self.menu:Remove()
			LSCS:RefreshMenu()
		end )

		local subMenu = self.menu:AddSubMenu("equip")

		local Num = 0
		for k, v in pairs( ply:lscsGetInventory() ) do
			if isbool( ply:lscsGetEquipped()[ k ] ) then continue end

			local item = LSCS:ClassToItem( v )

			if not item then continue end

			if item.type == "stance" then
				Num = Num + 1
				subMenu:AddOption( item.name, function()
					ply:lscsEquipItem( k, true )
				end )
			end
		end

		self.menu:Open()
	end
	Button.DoRightClick = function( self )
		BaseButtonClick( self )

		local NumCombo = #ply:lscsGetCombo()

		StanceNum = StanceNum + 1
		if StanceNum > NumCombo then
			StanceNum = 1
		end
		combo = ply:lscsGetCombo( StanceNum )
		LSCS:RefreshMenu()
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 4
end

function LSCS:BuildForceMenu( Frame )
	local ply = LocalPlayer()
	local ForceAbilities = ply:lscsGetForceAbilities()

	if ForceNum > #ForceAbilities then
		ForceNum = 1
	end

	local Force = ForceAbilities[ ForceNum ] and ForceAbilities[ ForceNum ].item or false

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY + FrameBarHeight )
	Panel.Paint = function(self, w, h )
		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 150,150,150,150 )
		local X, Y = self:CursorPos()
		surface.DrawTexturedRectRotated( X, Y, 512, 512, 0 )
	end

	local L = vgui.Create( "DPanel", Panel )
	L:SetSize( PanelSizeX - 208, 800 )
	L:Dock( LEFT )
	L:DockMargin( 0, 0, 0, 0 )
	L.Paint = function(self, w, h )
	end

	local descriptionHeader = vgui.Create( "DPanel", L )
	descriptionHeader:Dock( TOP )
	descriptionHeader:DockMargin( 4, 4, 0, 0 )
	descriptionHeader.Paint = function(self, w, h )
		local Col = menu_dim

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )
		draw.SimpleText( "Information", "LSCS_FONT", w * 0.5, h * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local SelectBind = vgui.Create( "DPanel", L )
	SelectBind:SetSize( 0, 280 )
	SelectBind:Dock( BOTTOM )
	SelectBind:DockMargin( 4, 4, 0, 4 )
	SelectBind.Paint = function(self, w, h )
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	end

	local description = vgui.Create( "DPanel", L )
	description:SetSize( 324, 0 )
	description:Dock( LEFT )
	description:DockMargin( 4, 4, 0, 0 )
	description.Paint = function(self, w, h ) 
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	end

	local ColHead = menu_text
	local ColText = menu_white

	local richtext = vgui.Create( "RichText", description )
	richtext:Dock( FILL )
	if Force then
		richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
		richtext:AppendText("Name:\n")

		richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
		richtext:AppendText("Force "..(Force.name or Force.id).."\n\n")

		richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
		richtext:AppendText("Description:\n")
		richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
		richtext:AppendText((Force.description or "").."\n\n")
		richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
		richtext:AppendText("Author:\n")
		richtext:InsertColorChange( ColText.r, ColText.g, ColText.b, ColText.a )
		richtext:AppendText((Force.author or "").."\n\n")
		richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
	else
		richtext:InsertColorChange( ColHead.r, ColHead.g, ColHead.b, ColHead.a )
		richtext:AppendText("You don't have any Force Powers")
	end

	local Button = vgui.Create( "DButton", L )
	Button.Item = Force
	Button.InfoText = "N/A"
	Button:SetText( "" )
	Button:SetSize( 130, 0 )
	Button:Dock( LEFT )
	Button:DockMargin( 4, 4, 4, 0 )
	Button.Paint = function( self, w, h )
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		CrafterButtonPaint( self, w, h )
	end
	Button.DoClick = function( self )
		BaseButtonClick( self )

		local NumForce = #ForceAbilities

		self.menu = DermaMenu()

		self.menu:AddOption( "view next", function()
			ForceNum = ForceNum + 1
			if ForceNum > NumForce then
				ForceNum = 1
			end
			self.menu:Remove()
			LSCS:RefreshMenu()
		end )
		self.menu:AddOption( "view previous", function()
			ForceNum = ForceNum - 1
			if ForceNum <= 0 then
				ForceNum = NumForce
			end
			self.menu:Remove()
			LSCS:RefreshMenu()
		end )

		local subMenu = self.menu:AddSubMenu("equip")

		local Num = 0
		for k, v in pairs( ply:lscsGetInventory() ) do
			if isbool( ply:lscsGetEquipped()[ k ] ) then continue end

			local item = LSCS:ClassToItem( v )

			if not item then continue end

			if item.type == "force" then
				Num = Num + 1
				subMenu:AddOption( item.name, function()
					ply:lscsEquipItem( k, true )
				end )
			end
		end

		self.menu:Open()
	end
	Button.DoRightClick = function( self )
		BaseButtonClick( self )

		local NumForce = #ForceAbilities

		ForceNum = ForceNum + 1
		if ForceNum > NumForce then
			ForceNum = 1
		end
		LSCS:RefreshMenu()
	end


	local descriptionHeader = vgui.Create( "DPanel", SelectBind )
	descriptionHeader:Dock( TOP )
	descriptionHeader:DockMargin( 4, 4, 0, 0 )
	descriptionHeader.Paint = function(self, w, h )
		local Col = menu_dim

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h )
		draw.SimpleText( "Force Selector Keybinding", "LSCS_FONT", w * 0.5, h * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local ActivatorBG = vgui.Create( "DPanel", SelectBind )
	ActivatorBG:SetSize( 250, 30 )
	ActivatorBG:Dock( TOP )
	ActivatorBG:DockMargin( 4, 4, 4, 0 )
	ActivatorBG.Paint = function(self, w, h )
		local Col = menu_light

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		draw.SimpleText( "Mouse Override (LMB to use Force, Scroll Wheel to select)", "LSCS_FONT_SMALL", (w - 100) * 0.5, h * 0.5 - 1, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	local ActivatorBinder = vgui.Create( "DBinder", ActivatorBG )
	ActivatorBinder:SetSize( 100, 30 )
	ActivatorBinder:Dock( RIGHT )
	ActivatorBinder:DockMargin( 2, 2, 2, 2 )
	ActivatorBinder:SetValue( LSCS.ForceSelector.KeyActivate:GetInt() )
	ActivatorBinder.OnChange = function( self, num )
		LSCS.ForceSelector.KeyActivate:SetInt( num )
	end

	local Next = vgui.Create( "DPanel", SelectBind )
	Next:SetSize( 250, 30 )
	Next:Dock( TOP )
	Next:DockMargin( 4, 4, 4, 0 )
	Next.Paint = function(self, w, h )
		local Col = menu_light

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		draw.SimpleText( "Next", "LSCS_FONT_SMALL", (w - 100) * 0.5, h * 0.5 - 1, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	local Binder = vgui.Create( "DBinder", Next )
	Binder:SetSize( 100, 30 )
	Binder:Dock( RIGHT )
	Binder:DockMargin( 2, 2, 2, 2 )
	Binder:SetValue( LSCS.ForceSelector.KeyNext:GetInt() )
	Binder.OnChange = function( self, num )
		LSCS.ForceSelector.KeyNext:SetInt( num )
	end

	local Prev = vgui.Create( "DPanel", SelectBind )
	Prev:SetSize( 250, 30 )
	Prev:Dock( TOP )
	Prev:DockMargin( 4, 4, 4, 0 )
	Prev.Paint = function(self, w, h )
		local Col = menu_light

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		draw.SimpleText( "Previous", "LSCS_FONT_SMALL", (w - 100) * 0.5, h * 0.5 - 1, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	local Binder = vgui.Create( "DBinder", Prev )
	Binder:SetSize( 100, 30 )
	Binder:Dock( RIGHT )
	Binder:DockMargin( 2, 2, 2, 2 )
	Binder:SetValue( LSCS.ForceSelector.KeyPrev:GetInt() )
	Binder.OnChange = function( self, num )
		LSCS.ForceSelector.KeyPrev:SetInt( num )
	end


	local Use = vgui.Create( "DPanel", SelectBind )
	Use:SetSize( 250, 30 )
	Use:Dock( TOP )
	Use:DockMargin( 4, 4, 4, 0 )
	Use.Paint = function(self, w, h )
		local Col = menu_light

		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		draw.SimpleText( "Use", "LSCS_FONT_SMALL", (w - 100) * 0.5, h * 0.5 - 1, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	local Binder = vgui.Create( "DBinder", Use )
	Binder:SetSize( 100, 30 )
	Binder:Dock( RIGHT )
	Binder:DockMargin( 2, 2, 2, 2 )
	Binder:SetValue( LSCS.ForceSelector.KeyUse:GetInt() )
	Binder.OnChange = function( self, num )
		LSCS.ForceSelector.KeyUse:SetInt( num )
	end


	local SPH = vgui.Create( "DPanel", Panel )
	SPH:SetSize( 0, 50 )
	SPH:Dock( TOP )
	SPH:DockMargin( 4, 4, 4, 0 )
	SPH.Paint = function(self, w, h )
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )

		draw.SimpleText( "Force Power", "LSCS_FONT", w * 0.5, h * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "Direct Key Binding", "LSCS_FONT", w * 0.5, h * 0.5, menu_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
	end

	local SPB = vgui.Create( "DPanel", Panel )
	SPB:SetSize( 200, 0 )
	SPB:Dock( RIGHT )
	SPB:DockMargin( 0, 4, 4, 4 )
	SPB.Paint = function(self, w, h )
		local Col = menu_dim
		surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
		surface.DrawRect( 0, 0, w, h  )
	end

	local DScrollPanel = vgui.Create( "DScrollPanel", SPB )
	DScrollPanel:Dock( FILL )

	for ID, item in pairs( LSCS.Force ) do
		local P = DScrollPanel:Add( "DPanel" )
		P:SetSize( 250, 30 )
		P:Dock( TOP )
		P:DockMargin( 4, 4, 4, 0 )
		P.Paint = function(self, w, h )
			local Col = menu_light

			if Force and Force.id == ID then
				Col = menu_text
			end

			surface.SetDrawColor( Col.r, Col.g, Col.b, Col.a )
			surface.DrawRect( 0, 0, w, h  )

			draw.SimpleText( item.name, "LSCS_FONT_SMALL", (w - 100) * 0.5, h * 0.5 - 1, menu_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		local B = vgui.Create( "DBinder", P )
		
		B:SetSize( 100, 30 )
		B:Dock( RIGHT )
		B:DockMargin( 2, 2, 2, 2 )
		B:SetValue( item.cmd:GetInt() )
		B.OnChange = function( self, num )
			item.cmd:SetInt( num )
			LSCS:RefreshKeys()
		end
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 5
end

function LSCS:BuildSettings( Frame )
	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetPos( PanelPosX, PanelPosY )
	Panel:SetSize( PanelSizeX, PanelSizeY + FrameBarHeight )
	Panel.Paint = function(self, w, h )
		surface.SetMaterial( ClickMat )
		surface.SetDrawColor( 150,150,150,150 )
		local X, Y = self:CursorPos()
		surface.DrawTexturedRectRotated( X, Y, 512, 512, 0 )
	end

	local PerfSettings = vgui.Create( "DPanel", Panel )
	PerfSettings:SetSize( 0, 166 )
	PerfSettings:DockMargin( 4, 4, 4, 4 )
	PerfSettings:Dock( TOP )
	PerfSettings.Paint = function(self, w, h )
		surface.SetDrawColor( menu_dim )
		surface.DrawRect( 0, 0, w, h )
	end

	local Header = vgui.Create( "DPanel", PerfSettings )
	Header:SetSize( 0, 40 )
	Header:DockMargin( 4, 4, 4, 4 )
	Header:Dock( TOP )
	Header.Paint = function(self, w, h )
		draw.SimpleText( "Client Settings", "LSCS_FONT", 4, h * 0.5, menu_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	local Line = vgui.Create( "DPanel", PerfSettings )
	Line:SetSize( PanelSizeX, 1)
	Line:Dock( TOP )
	Line:DockMargin( 0, 4, 4, 4 )
	Line.Paint = function(self, w, h )
		surface.SetDrawColor( menu_text )
		surface.SetMaterial( gradient_mat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	local pLeft = vgui.Create( "DPanel", PerfSettings )
	pLeft:SetSize( PanelSizeX * 0.5, 0 )
	pLeft:DockMargin( 0, 0, 0, 0 )
	pLeft:Dock( LEFT )
	pLeft.Paint = function(self, w, h ) end

	local pRight = vgui.Create( "DPanel", PerfSettings )
	pRight:SetSize( PanelSizeX * 0.5, 0 )
	pRight:DockMargin( 0, 0, 0, 0 )
	pRight:Dock( LEFT )
	pRight.Paint = function(self, w, h ) end

	local T = vgui.Create( "DPanel", pLeft )
	T:Dock( TOP )
	T:DockMargin( 4, 4, 0, 0 )
	T.Paint = function(self, w, h )
		draw.SimpleText( "Performance", "LSCS_FONT_SMALL", 0, h * 0.5, menu_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	local DCheckbox = vgui.Create( "DCheckBoxLabel", pLeft )
	DCheckbox:Dock( TOP )
	DCheckbox:DockMargin( 4, 4, 0, 0 )
	DCheckbox:SetText("Dynamic Light")	
	DCheckbox:SetConVar("lscs_dynamiclight")
	DCheckbox:SizeToContents()

	local DCheckbox = vgui.Create( "DCheckBoxLabel", pLeft )
	DCheckbox:Dock( TOP )
	DCheckbox:DockMargin( 4, 4, 0, 0 )
	DCheckbox:SetText("High Quality Impact Effects")	
	DCheckbox:SetConVar("lscs_impacteffects")
	DCheckbox:SizeToContents()

	local DSlider = vgui.Create( "DNumSlider", pLeft )
	DSlider:Dock( TOP )
	DSlider:DockMargin( 4, 4, 0, 0 )
	DSlider:SetText( "Trail Effect Detail" )
	DSlider:SetMin( 0 )
	DSlider:SetMax( 100 )
	DSlider:SetDecimals( 0 )
	DSlider:SetConVar( "lscs_traildetail" )	

	local T = vgui.Create( "DPanel", pRight )
	T:Dock( TOP )
	T:DockMargin( 4, 4, 0, 0 )
	T.Paint = function(self, w, h )
		draw.SimpleText( "Hud", "LSCS_FONT_SMALL", 0, h * 0.5, menu_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	local DCheckbox = vgui.Create( "DCheckBoxLabel", pRight )
	DCheckbox:Dock( TOP )
	DCheckbox:DockMargin( 4, 4, 0, 0 )
	DCheckbox:SetText("Show HUD")	
	DCheckbox:SetConVar("lscs_drawhud")
	DCheckbox:SizeToContents()


	local SVSettings = vgui.Create( "DPanel", Panel )
	SVSettings:SetSize( 0, 302 )
	SVSettings:DockMargin( 4, 0, 4, 4 )
	SVSettings:Dock( TOP )
	SVSettings.Paint = function(self, w, h )
		surface.SetDrawColor( menu_dim )
		surface.DrawRect( 0, 0, w, h )
	end

	local Header = vgui.Create( "DPanel", SVSettings )
	Header:SetSize( 0, 40 )
	Header:DockMargin( 4, 4, 4, 4 )
	Header:Dock( TOP )
	Header.Paint = function(self, w, h )
		draw.SimpleText( "Server Settings", "LSCS_FONT", 4, h * 0.5, menu_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( adminMat )
		surface.DrawTexturedRect( w - 20,  4, 16, 16 )
	end

	local Line = vgui.Create( "DPanel", SVSettings )
	Line:SetSize( PanelSizeX, 1)
	Line:Dock( TOP )
	Line:DockMargin( 0, 4, 4, 4 )
	Line.Paint = function(self, w, h )
		surface.SetDrawColor( menu_text )
		surface.SetMaterial( gradient_mat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	local T = vgui.Create( "DPanel", SVSettings )
	T:Dock( TOP )
	T:DockMargin( 4, 4, 0, 0 )
	T.Paint = function(self, w, h )
		draw.SimpleText( "Saber Attacking", "LSCS_FONT_SMALL", 0, h * 0.5, menu_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	local slider = vgui.Create( "DNumSlider", SVSettings )
	slider:Dock( TOP )
	slider:DockMargin( 4, 4, 0, 0 )
	slider:SetText( "Damage" )
	slider:SetMin( 0 )
	slider:SetMax( 2000 )
	slider:SetDecimals( 0 )
	slider:SetConVar( "lscs_sv_saberdamage" )
	function slider:OnValueChanged( val )
		net.Start("lscs_admin_setconvar")
			net.WriteString("lscs_sv_saberdamage")
			net.WriteString( tostring( val ) )
		net.SendToServer()
	end

	local Line = vgui.Create( "DPanel", SVSettings )
	Line:SetSize( PanelSizeX, 1)
	Line:Dock( TOP )
	Line:DockMargin( 0, 4, 4, 4 )
	Line.Paint = function(self, w, h )
		surface.SetDrawColor( menu_text )
		surface.SetMaterial( gradient_mat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	local T = vgui.Create( "DPanel", SVSettings )
	T:Dock( TOP )
	T:DockMargin( 4, 4, 0, 0 )
	T.Paint = function(self, w, h )
		draw.SimpleText( "Saber Bullet Deflecting", "LSCS_FONT_SMALL", 0, h * 0.5, menu_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end

	local slider = vgui.Create( "DNumSlider", SVSettings )
	slider:Dock( TOP )
	slider:DockMargin( 4, 4, 0, 0 )
	slider:SetText( "Deflect Force Drain Multiplier" )
	slider:SetMin( 0 )
	slider:SetMax( 1 )
	slider:SetDecimals( 2 )
	slider:SetConVar( "lscs_sv_forcedrain_per_bullet_mul" )
	function slider:OnValueChanged( val )
		net.Start("lscs_admin_setconvar")
			net.WriteString("lscs_sv_forcedrain_per_bullet_mul")
			net.WriteString( tostring( val ) )
		net.SendToServer()
	end

	local slider = vgui.Create( "DNumSlider", SVSettings )
	slider:Dock( TOP )
	slider:DockMargin( 4, 4, 0, 0 )
	slider:SetText( "Minimum ForceDrain per Deflect" )
	slider:SetMin( 0 )
	slider:SetMax( 10 )
	slider:SetDecimals( 0 )
	slider:SetConVar( "lscs_sv_forcedrain_per_bullet_min" )
	function slider:OnValueChanged( val )
		net.Start("lscs_admin_setconvar")
			net.WriteString("lscs_sv_forcedrain_per_bullet_min")
			net.WriteString( tostring( val ) )
		net.SendToServer()
	end

	local slider = vgui.Create( "DNumSlider", SVSettings )
	slider:Dock( TOP )
	slider:DockMargin( 4, 4, 0, 0 )
	slider:SetText( "Maximum ForceDrain per Deflect" )
	slider:SetMin( 0 )
	slider:SetMax( 100 )
	slider:SetDecimals( 0 )
	slider:SetConVar( "lscs_sv_forcedrain_per_bullet_max" )
	function slider:OnValueChanged( val )
		net.Start("lscs_admin_setconvar")
			net.WriteString("lscs_sv_forcedrain_per_bullet_max")
			net.WriteString( tostring( val ) )
		net.SendToServer()
	end

	local DCheckbox = vgui.Create( "DCheckBoxLabel", SVSettings )
	DCheckbox:Dock( TOP )
	DCheckbox:DockMargin( 4, 4, 0, 0 )
	DCheckbox:SetText("Player Bullets Interrupt Saber Attack")	
	DCheckbox:SetConVar("lscs_sv_bullet_can_interrupt_attack")
	DCheckbox:SizeToContents()
	function DCheckbox:OnChange( val )
		net.Start("lscs_admin_setconvar")
			net.WriteString("lscs_sv_bullet_can_interrupt_attack")
			net.WriteString( val and "1" or "0" )
		net.SendToServer()
	end

	LSCS:SetActivePanel( Panel )
	LSCS:SideBar( Frame )

	Frame.ID = 6
end

function LSCS:RefreshMenu()
	if not IsValid( Frame ) then return end

	if Frame.ID == 2 then
		LSCS:BuildInventory( Frame )
	end
	if Frame.ID == 3 then
		LSCS:BuildSaberMenu( Frame )
	end
	if Frame.ID == 4 then
		LSCS:BuildStanceMenu( Frame )
	end
	if Frame.ID == 5 then
		LSCS:BuildForceMenu( Frame )
	end
	if Frame.ID == 6 then
		LSCS:BuildSettings( Frame )
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
