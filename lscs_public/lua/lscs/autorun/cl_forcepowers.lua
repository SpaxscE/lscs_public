local blur = Material("pp/blurscreen")

local SelectorWidth = 410
local SelectorItemHeight = 64
local SelectedItemHeight = 72
local SelectedItemHalfHeight = SelectedItemHeight * 0.5
local StartOffsetToSelectable = 5
local FrameThickness = 3
local SelectorHeight = SelectedItemHeight + 2 * FrameThickness

local X = ScrW() * 0.5 - SelectorWidth * 0.5
local Y = ScrH() - SelectorHeight - 25

local MouseWheelScroller = false
local Selected = 1
local smOffset = 0
local smAlpha = 0
local FadeTimer = 0

LSCS.ForceSelector = LSCS.ForceSelector or {
	KeyActivate = CreateClientConVar( "lscs_key_selector_activate", KEY_LALT, true, true ),
	KeyNext = CreateClientConVar( "lscs_key_selector_next", KEY_H, true, true ),
	KeyPrev = CreateClientConVar( "lscs_key_selector_prev", KEY_G, true, true ),
	KeyUse = CreateClientConVar( "lscs_key_selector_use", KEY_F, true, true ),
}

if IsValid( LSCS.ForceSelector.Selector ) then
	LSCS.ForceSelector.Selector:Remove()
	LSCS.ForceSelector.Selector = nil
end

local function CreateSelector()
	local ForceSelector = vgui.Create("DPanel")
	ForceSelector:SetPos( X, Y )
	ForceSelector:SetSize( SelectorWidth, SelectorHeight + 25 )
	ForceSelector.Paint = function( self, w, h )
		local Time = CurTime()

		local smRate = RealFrameTime()
		local tAlpha = (FadeTimer > Time) and 1 or 0

		smAlpha = smAlpha + math.Clamp(tAlpha - smAlpha,-smRate * 3,smRate * 50)

		if smAlpha == 0 then return end

		local fading_white = Color(255,255,255,smAlpha * 255)
		local fading_blue = Color(0, 127, 255, smAlpha * 255)

		local pX, pY = self:GetPos()
		surface.SetMaterial( blur )
		blur:SetFloat( "$blur", 3 )
		blur:Recompute()
		if render then render.UpdateScreenEffectTexture() end
		surface.SetDrawColor( 255, 255, 255, fading_white.a )
		surface.DrawTexturedRect( -pX, -pY, ScrW(), ScrH() )
		surface.SetDrawColor( 0, 0, 0, 100 * smAlpha )
		surface.DrawRect( 0, 0, w, h )

		local StartX = w * 0.5 + smOffset

		local xh = SelectorItemHeight
		local yh = SelectorHeight

		local ply = LocalPlayer()

		local Rate = RealFrameTime() * 450

		smOffset = math.Clamp(smOffset - math.Clamp(smOffset,-Rate,Rate),-xh * 0.6,xh * 0.6)
		local ForcePowers = ply:lscsGetForceAbilities()

		local Selection = ForcePowers[ Selected ]

		if not Selection then return end

		local SelectionPlus = {}
		local SelectionMinus = {}

		local StartIDp = Selected
		local StartIDm = StartIDp

		for ID = 1, 3 do
			StartIDp = StartIDp + 1
			StartIDm = StartIDm - 1

			if StartIDp > #ForcePowers then
				StartIDp = 1
			end
			if StartIDm < 1 then
				StartIDm = #ForcePowers
			end

			SelectionPlus[ ID ] = ForcePowers[ StartIDp ]
			SelectionMinus[ ID ] = ForcePowers[ StartIDm ]
		end

		surface.SetDrawColor( fading_white )

		surface.SetMaterial( Selection.icon )

		if smOffset ~= 0 then
			surface.DrawTexturedRect( StartX - xh * 0.5, (yh - xh) * 0.5, xh, xh )
		else
			surface.DrawTexturedRect( StartX - SelectedItemHalfHeight + 3, FrameThickness + 3, SelectedItemHeight - 6, SelectedItemHeight - 6 )
			draw.SimpleText( Selection.item.name, "LSCS_FONT", w * 0.5, h - 13, fading_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		local addX = SelectedItemHalfHeight + StartOffsetToSelectable
		for _, obj in pairs( SelectionPlus ) do
			surface.SetMaterial( obj.icon )
			surface.DrawTexturedRect( StartX + addX, yh - xh, xh, xh )
			addX = addX + xh
		end

		local subX = -xh - SelectedItemHalfHeight - StartOffsetToSelectable
		for _, obj in pairs( SelectionMinus ) do
			surface.SetMaterial( obj.icon )
			surface.DrawTexturedRect( StartX + subX, yh - xh, xh, xh )
			subX = subX - xh
		end

		surface.DrawRect( 0, 0, FrameThickness, h )
		surface.DrawRect( w - FrameThickness, 0, FrameThickness, h )

		surface.SetDrawColor( fading_blue )
		local fXstat = w * 0.5 - SelectedItemHalfHeight
		surface.DrawRect( fXstat, 0, SelectedItemHeight, FrameThickness )
		surface.DrawRect( fXstat, yh - FrameThickness, SelectedItemHeight, FrameThickness )
		surface.DrawRect( fXstat, FrameThickness, FrameThickness, yh - 2 * FrameThickness )
		surface.DrawRect( fXstat + SelectedItemHeight - FrameThickness, FrameThickness, FrameThickness, yh - 2 * FrameThickness )
	end

	LSCS.ForceSelector.Selector = ForceSelector
end

local function Use( ID )
	net.Start("lscs_force_use")
		net.WriteInt( ID, 8 ) -- 127 equipped force powers are enough?
		net.WriteBool( true )
	net.SendToServer()
end

local function StopUse( ID )
	net.Start("lscs_force_use")
		net.WriteInt( ID, 8 )
		net.WriteBool( false )
	net.SendToServer()
end

local function Prev()
	if not IsValid( LSCS.ForceSelector.Selector ) then CreateSelector() end

	local ply = LocalPlayer()
	local ForcePowers = ply:lscsGetForceAbilities()

	if #ForcePowers == 0 then return end

	Selected = Selected + 1

	surface.PlaySound( "lscs/force_next.mp3" )

	if Selected > #ForcePowers then
		Selected = 1
	end

	smOffset = smOffset + SelectorItemHeight

	FadeTimer = CurTime() + 2
end

local function Next()
	if not IsValid( LSCS.ForceSelector.Selector ) then CreateSelector() end

	local ply = LocalPlayer()
	local ForcePowers = ply:lscsGetForceAbilities()

	if #ForcePowers == 0 then return end

	Selected = Selected - 1

	surface.PlaySound( "lscs/force_next.mp3" )

	if Selected < 1 then
		Selected = #ForcePowers
	end

	smOffset = smOffset - SelectorItemHeight

	FadeTimer = CurTime() + 2
end

hook.Add( "PlayerButtonDown", "!!!!lscs_buttondownstuff", function( ply, button )
	local selector = LSCS.ForceSelector

	-- this needs to be reworked at some point to the same method used as direct inputs
	if button == selector.KeyActivate:GetInt() then
		if #ply:lscsGetForceAbilities() == 0 then return end

		MouseWheelScroller = true
		FadeTimer = CurTime() + 9999
	end
	if button == selector.KeyUse:GetInt() then
		Use( Selected )
	end
	if button == selector.KeyNext:GetInt() then
		Prev() -- inverted lmao
	end
	if button == selector.KeyPrev:GetInt() then
		Next()
	end

	local Input = LSCS.KeyToForce[ button ]

	if not Input then return end

	local ForcePowers = ply:lscsGetForceAbilities()

	for _, name in pairs( Input ) do
		for ID, power in pairs( ForcePowers ) do
			if power.item.id == name then
				Use( ID )
			end
		end
	end
end)

hook.Add( "PlayerButtonUp", "!!!!lscs_buttonupstuff", function( ply, button )
	if button == LSCS.ForceSelector.KeyActivate:GetInt() then
		MouseWheelScroller = false
		FadeTimer = 0
	end

	local Input = LSCS.KeyToForce[ button ]

	if not Input then return end

	local ForcePowers = ply:lscsGetForceAbilities()

	for _, name in pairs( Input ) do
		for ID, power in pairs( ForcePowers ) do
			if power.item.id == name then
				StopUse( ID )
			end
		end
	end
end)

hook.Add( "PlayerBindPress", "PlayerBindPressExample", function( ply, bind, pressed )
	if not MouseWheelScroller then return end

	local Time = CurTime()

	if bind == "invprev" then
		if pressed then
			Prev()
		end

		return true
	end
	if bind == "invnext" then
		if pressed then
			Next()
		end

		return true
	end
	if bind == "+attack" then
		if pressed then
			Use( Selected )
		end

		return true
	end
end )
