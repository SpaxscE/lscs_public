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
		blur:SetFloat( "$blur", 5 )
		blur:Recompute()
		if render then render.UpdateScreenEffectTexture() end
		surface.SetDrawColor( 255, 255, 255, fading_white.a )
		surface.DrawTexturedRect( -pX, -pY, ScrW(), ScrH() )
		surface.SetDrawColor( 0, 0, 0, 200 * smAlpha )
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

		local Thickness = (smOffset ~= 0) and (3 + math.floor( math.abs( math.cos( CurTime() * 100 ) * 6 )) ) or FrameThickness -- looks cool

		local fXstat = w * 0.5 - SelectedItemHalfHeight
		surface.DrawRect( fXstat, 0, SelectedItemHeight, Thickness )
		surface.DrawRect( fXstat, yh - Thickness, SelectedItemHeight, Thickness )
		surface.DrawRect( fXstat, Thickness, Thickness, yh - 2 * Thickness )
		surface.DrawRect( fXstat + SelectedItemHeight - Thickness, Thickness, Thickness, yh - 2 * Thickness )
	end

	LSCS.ForceSelector.Selector = ForceSelector
end

local ID_IN_USE

local function Use( ID )
	ID_IN_USE = ID

	net.Start("lscs_force_use")
		net.WriteInt( ID, 8 ) -- 127 equipped force powers are enough?
		net.WriteBool( true )
	net.SendToServer()
end

local function StopUse( ID )
	ID_IN_USE = nil

	net.Start("lscs_force_use")
		net.WriteInt( ID, 8 )
		net.WriteBool( false )
	net.SendToServer()
end

net.Receive( "lscs_force_use", function( len )
	for i = 1, net.ReadInt( 9 ) do
		StopUse( net.ReadInt( 8 ) )
	end
end )

local NextNav = 0

local function Prev( dont_set_time )
	if not IsValid( LSCS.ForceSelector.Selector ) then CreateSelector() end

	local Time = CurTime()
	if NextNav > Time then return end
	NextNav = Time + 0.01

	local ply = LocalPlayer()
	local ForcePowers = ply:lscsGetForceAbilities()

	if #ForcePowers == 0 then return end

	Selected = Selected + 1

	surface.PlaySound( "lscs/force_next.mp3" )

	if Selected > #ForcePowers then
		Selected = 1
	end

	smOffset = smOffset + SelectorItemHeight

	if dont_set_time then return end

	FadeTimer = CurTime() + 2
end

local function Next( dont_set_time )
	if not IsValid( LSCS.ForceSelector.Selector ) then CreateSelector() end

	local Time = CurTime()
	if NextNav > Time then return end
	NextNav = Time + 0.01

	local ply = LocalPlayer()
	local ForcePowers = ply:lscsGetForceAbilities()

	if #ForcePowers == 0 then return end

	Selected = Selected - 1

	surface.PlaySound( "lscs/force_next.mp3" )

	if Selected < 1 then
		Selected = #ForcePowers
	end

	smOffset = smOffset - SelectorItemHeight

	if dont_set_time then return end

	FadeTimer = CurTime() + 2
end

local function PlayerButtonDown( ply, button )
	local selector = LSCS.ForceSelector

	local InVehicle = ply:InVehicle()

	local AllowForce = not InVehicle or (InVehicle and ply:GetAllowWeaponsInVehicle())

	if AllowForce then
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
end

local function PlayerButtonUp( ply, button )
	local selector = LSCS.ForceSelector

	if button == selector.KeyActivate:GetInt() then
		MouseWheelScroller = false
		FadeTimer = 0
	end
	if ID_IN_USE and button == selector.KeyUse:GetInt() then
		StopUse( ID_IN_USE )
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
end

if game.SinglePlayer() then -- holy shit i hate gmod so much why dont these hooks run in SP holy fucking shit
	local IS_MOUSE_ENUM = {
		[MOUSE_LEFT] = true,
		[MOUSE_RIGHT] = true,
		[MOUSE_MIDDLE] = true,
		[MOUSE_4] = true,
		[MOUSE_5] = true,
		[MOUSE_WHEEL_UP] = true,
		[MOUSE_WHEEL_DOWN] = true,
	}

	local function InputPressed( key )
		if IS_MOUSE_ENUM[ key ] then
			return input.IsMouseDown( key ) 
		else
			return input.IsKeyDown( key ) 
		end
	end

	local OldPressed = {false, false,false,false}
	local OldPressedForce = {}

	hook.Add( "Think", "!!!lscs_gmods_prediction_system_is_cancer", function()
		local ply = LocalPlayer()

		local selector = LSCS.ForceSelector

		local SelectorButtons = {selector.KeyActivate:GetInt(),selector.KeyUse:GetInt(),selector.KeyNext:GetInt(),selector.KeyPrev:GetInt()}

		for id, key in pairs( SelectorButtons ) do
			local pressed = InputPressed( key )

			if OldPressed[ id ] ~= pressed then
				OldPressed[ id ] = pressed
				if pressed then
					PlayerButtonDown( ply, key )
				else
					PlayerButtonUp( ply, key )
				end
			end
		end

		for _, entry in pairs( LSCS.Force ) do
			local key = entry.cmd:GetInt()
			if not OldPressedForce[ key ] then OldPressedForce[ key ] = false end
	
			local pressed = InputPressed( key )

			if OldPressedForce[ key ] ~= pressed then
				OldPressedForce[ key ] = pressed
				if pressed then
					PlayerButtonDown( ply, key )
				else
					PlayerButtonUp( ply, key )
				end
			end
		end
	end )
else
	hook.Add( "PlayerButtonDown", "!!!!lscs_buttondownstuff", function( ply, button )
		if IsFirstTimePredicted() then
			PlayerButtonDown( ply, button )
		end
	end)

	hook.Add( "PlayerButtonUp", "!!!!lscs_buttonupstuff", function( ply, button )
		if IsFirstTimePredicted() then
			PlayerButtonUp( ply, button )
		end
	end)
end

local LAST_USED_LMB

hook.Add( "PlayerBindPress", "!!!!_lscs_playerbindpress", function( ply, bind, pressed )
	if not MouseWheelScroller then

		if not LAST_USED_LMB then return end

		if bind ~= "+attack" or pressed then return end

		StopUse( LAST_USED_LMB )

		return
	end

	if ply:InVehicle() and not ply:GetAllowWeaponsInVehicle() then return end

	local Time = CurTime()

	if bind == "invprev" then
		if pressed then
			Prev( true )
		end

		return true
	end
	if bind == "invnext" then
		if pressed then
			Next( true )
		end

		return true
	end
	if bind == "+attack" then
		if pressed then
			LAST_USED_LMB = Selected

			Use( Selected )
		else
			if LAST_USED_LMB then
				StopUse( LAST_USED_LMB )
			end

			LAST_USED_LMB = nil
		end

		return true
	end
end )
