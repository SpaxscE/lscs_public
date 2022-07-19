local SelectorWidth = 410
local SelectorItemHeight = 64
local SelectedItemHeight = 72
local SelectedItemHalfHeight = SelectedItemHeight * 0.5
local StartOffsetToSelectable = 5
local FrameThickness = 3
local SelectorHeight = SelectedItemHeight + 2 * FrameThickness

local X = ScrW() * 0.5 - SelectorWidth * 0.5
local Y = ScrH() - SelectorHeight - 25

if IsValid( ForceSelector ) then
	ForceSelector:Remove()
end

local Selected = 1
local smOffset = 0

hook.Add( "PlayerBindPress", "PlayerBindPressExample", function( ply, bind, pressed )
	--[[
	if bind == "invprev" then

			local ForcePowers = ply:lscsGetForceAbilities()
			Selected = Selected + 1
			surface.PlaySound( "lscs/force_next.mp3" )
			if Selected > #ForcePowers then
				Selected = 1
			end
			smOffset = smOffset + SelectorItemHeight


		return true
	end
	if bind == "invnext" then

			local ForcePowers = ply:lscsGetForceAbilities()
			Selected = Selected - 1
			surface.PlaySound( "lscs/force_next.mp3" )
			if Selected < 1 then
				Selected = #ForcePowers
			end
			smOffset = smOffset - SelectorItemHeight


		return true
	end
	]]
end )

ForceSelector = vgui.Create("DPanel")
ForceSelector:SetPos( X, Y )
ForceSelector:SetSize( SelectorWidth, SelectorHeight + 25 )
ForceSelector.Paint = function( self, w, h )
	local StartX = w * 0.5 + smOffset

	local xh = SelectorItemHeight
	local yh = SelectorHeight

	local ply = LocalPlayer()

	local LMB =  input.IsMouseDown( MOUSE_LEFT )
	local RMB =  input.IsMouseDown( MOUSE_RIGHT )

	local Rate = RealFrameTime() * 450

	smOffset = math.Clamp(smOffset - math.Clamp(smOffset,-Rate,Rate),-xh,xh)
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

	surface.SetDrawColor( color_white )

	surface.SetMaterial( Selection.icon )

	if smOffset ~= 0 then
		surface.DrawTexturedRect( StartX - xh * 0.5, (yh - xh) * 0.5, xh, xh )
	else
		surface.DrawTexturedRect( StartX - SelectedItemHalfHeight + 3, FrameThickness + 3, SelectedItemHeight - 6, SelectedItemHeight - 6 )
		draw.SimpleText( Selection.item.name, "LSCS_FONT", w * 0.5, h - 13, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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

	local fXstat = w * 0.5 - SelectedItemHalfHeight
	surface.DrawRect( fXstat, 0, SelectedItemHeight, FrameThickness )
	surface.DrawRect( fXstat, yh - FrameThickness, SelectedItemHeight, FrameThickness )

	surface.DrawRect( fXstat, FrameThickness, FrameThickness, yh - 2 * FrameThickness )
	surface.DrawRect( fXstat + SelectedItemHeight - FrameThickness, FrameThickness, FrameThickness, yh - 2 * FrameThickness )

	surface.DrawRect( 0, yh - xh, FrameThickness, xh )
	surface.DrawRect( w - FrameThickness, yh - xh, FrameThickness, xh )
end
