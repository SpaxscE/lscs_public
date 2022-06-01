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
local icon_close = Material("lscs/ui/cross.png")
local icon_inventory = Material("lscs/ui/inventory.png")
local icon_hilt = Material("lscs/ui/hilt.png")
local icon_stance = Material("lscs/ui/stance.png")
local icon_settings = Material("lscs/ui/settings.png")

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

	local DermaButton = vgui.Create( "DButton", Panel )
	DermaButton:SetText( "Say hi" )
	DermaButton:SetPos( 25, 50 )
	DermaButton:SetSize( 250, 30 )
	DermaButton.DoClick = function()
		local menu = DermaMenu()
		menu:AddOption( "Copy to clipboard", function() SetClipboardText( "weapon_pistol" ) end )
		menu:AddOption( "Spawn 5", function() for i=1,5 do RunConsoleCommand( "gm_spawnswep", "weapon_pistol" ) end end )
		menu:AddOption( "Spawn 10", function() for i=1,10 do RunConsoleCommand( "gm_spawnswep", "weapon_pistol" ) end end )
		menu:Open()
	end
end

function LSCS:BuildInventory( Frame )
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

	Frame.ID = 2
end

function LSCS:BuildSaberMenu( Frame )
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

	Frame.ID = 3
end

function LSCS:BuildStanceMenu( Frame )
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
			draw.SimpleText( "[LSCS] - Control Panel ", "LSCS_FONT", 5, 11, menu_light, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
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
