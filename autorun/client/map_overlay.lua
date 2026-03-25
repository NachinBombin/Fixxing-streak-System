if CLIENT == true then

local tex      = surface.GetTextureID( "VGUI/killStreak_misc/callin" )
local arrow    = surface.GetTextureID( "VGUI/killStreak_misc/arrow" )
local texSize  = 64
local arrowSize = 32
local edge     = arrowSize + arrowSize / 2

local Runtime_Error = false

local sky, x1, x2, y1, y2
local xDis, yDis
local xyOffset = .05
local x, y, w, h


local function FindSky()
	local maxheight  = 16384
	local startPos   = Vector( 0, 0, 0 )
	local endPos     = Vector( 0, 0, maxheight )
	local filterList = {}

	local trace = { start = startPos, endpos = endPos, filter = filterList }

	local bool        = true
	local maxNumber   = 0
	local skyLocation = -1

	while bool do
		local traceData = util.TraceLine( trace )

		if traceData.HitSky then
			skyLocation = traceData.HitPos.z
			bool = false
		elseif traceData.HitWorld then
			trace.start = traceData.HitPos + Vector( 0, 0, 50 )
		else
			table.insert( filterList, traceData.Entity )
		end

		-- FIX: maxNumber now increments every iteration (was missing); prevents infinite loop
		maxNumber = maxNumber + 1
		if maxNumber >= 300 then
			MsgN( "[MW2 Killstreaks] FindSky: reached max iterations, no skybox found" )
			bool = false
		end
	end

	if skyLocation == -1 then
		Runtime_Error = true
	end

	return skyLocation
end


local function findBounds( axis, height )
	local length     = 16384
	local startPos   = Vector( 0, 0, height )
	local endPos

	if axis == "x" then
		endPos = Vector( length, 0, height )
	elseif axis == "y" then
		endPos = Vector( 0, length, height )
	end

	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }

	local bool          = true
	local maxNumber     = 0
	local wallLocation1 = -1
	local wallLocation2 = -1

	while bool do
		local traceData = util.TraceLine( trace )

		if traceData.HitSky then
			if wallLocation1 == -1 then
				wallLocation1 = ( axis == "x" ) and traceData.HitPos.x or traceData.HitPos.y
				if axis == "x" then
					endPos = Vector( -length, 0, height )
				else
					endPos = Vector( 0, -length, height )
				end
				trace = { start = startPos, endpos = endPos, filter = filterList }
			else
				wallLocation2 = ( axis == "x" ) and traceData.HitPos.x or traceData.HitPos.y
				bool = false
			end
		elseif traceData.HitWorld then
			if wallLocation1 == -1 then
				trace.start = ( axis == "x" ) and ( traceData.HitPos + Vector( 50, 0, 0 ) ) or ( traceData.HitPos + Vector( 0, 50, 0 ) )
			else
				trace.start = ( axis == "x" ) and ( traceData.HitPos - Vector( 50, 0, 0 ) ) or ( traceData.HitPos - Vector( 0, 50, 0 ) )
			end
		else
			table.insert( filterList, traceData.Entity )
		end

		maxNumber = maxNumber + 1
		if maxNumber >= 100 then
			MsgN( "[MW2 Killstreaks] findBounds: reached max iterations, wall not found" )
			bool = false
		end
	end

	return wallLocation1, wallLocation2
end


local function isInWorld( pos )
	local posX, posY = pos.x, pos.y
	if ( posX > x2 and posX < x1 ) and ( posY > y2 and posY < y1 ) then
		return true
	end
	return false
end

local function advRound( val, d )
	d = d or 0
	return math.Round( val * ( 10 ^ d ) ) / ( 10 ^ d )
end

local function drawDirArrow( angle, xPos, yPos )
	surface.SetTexture( arrow )
	surface.SetDrawColor( 255, 255, 255, 255 )
	if angle == 0   then surface.DrawTexturedRectRotated( xPos,              yPos - edge,          arrowSize, arrowSize, 0   )
	elseif angle == 45  then surface.DrawTexturedRectRotated( xPos - edge/1.5,  yPos - edge/1.5,      arrowSize, arrowSize, 45  )
	elseif angle == 90  then surface.DrawTexturedRectRotated( xPos - edge,       yPos,                 arrowSize, arrowSize, 90  )
	elseif angle == 135 then surface.DrawTexturedRectRotated( xPos - edge/1.5,  yPos + edge/1.5,      arrowSize, arrowSize, 135 )
	elseif angle == 180 then surface.DrawTexturedRectRotated( xPos,              yPos + edge,          arrowSize, arrowSize, 180 )
	elseif angle == 225 then surface.DrawTexturedRectRotated( xPos + edge/1.5,  yPos + edge/1.5,      arrowSize, arrowSize, 225 )
	elseif angle == 270 then surface.DrawTexturedRectRotated( xPos + edge,       yPos,                 arrowSize, arrowSize, 270 )
	elseif angle == 315 then surface.DrawTexturedRectRotated( xPos + edge/1.5,  yPos - edge/1.5,      arrowSize, arrowSize, 315 )
	end
end


local function Check_Status()
	return LocalPlayer():Alive() and 1 or 0
end


local function showOverlay( ent, select )
	local Timer = NULL

	timer.Create( "Status_Check", 1, 0, function()
		Timer = Check_Status()
	end )

	local viewPos = Vector( 0, 0, sky )
	local ang     = 0
	local CamData = {}

	local Overlay = vgui.Create( "DFrame" )
	Overlay:SetSize( w, h )
	Overlay:SetPos( x, y )
	Overlay:SetDraggable( false )
	Overlay:ShowCloseButton( false )
	Overlay:SetTitle( "Overlay" )
	Overlay:SetBackgroundBlur( false )
	Overlay:MakePopup()

	local button = vgui.Create( "DButton", Overlay )
	button:SetSize( Overlay:GetWide(), Overlay:GetTall() )
	button:SetPos( 0, 0 )
	button:SetText( "" )

	button.DoClick = function()
		if select and Timer == 1 then
			net.Start( "MW2_DropLocation_Overlay_Stream" )
				net.WriteFloat( ent )
				net.WriteVector( viewPos )
				net.WriteFloat( ang )
			net.SendToServer()
		elseif not select and Timer == 1 then
			net.Start( "MW2_DropLocation_Overlay_Stream" )
				net.WriteFloat( ent )
				net.WriteVector( viewPos )
			net.SendToServer()
		else
			timer.Remove( "Status_Check" )
			Overlay:Close()
			return
		end
		timer.Remove( "Status_Check" )
		Overlay:Close()
	end

	button.DoRightClick = function()
		if select then
			ang = ang + 45
			if ang >= 360 then ang = 0 end
		end
	end

	button.curX, button.curY = 0, 0
	button.fov      = 75
	button.fovScale = 1

	local moveFactor   = .005
	local texPositionX = button:GetWide() / 2 - texSize / 2
	local texPositionY = button:GetTall() / 2 - texSize / 2

	button.Paint = function()
		local CamX, CamY = Overlay:GetPos()
		CamData.angles        = Angle( 90, 0, 0 )
		CamData.origin        = viewPos
		CamData.x             = CamX
		CamData.y             = CamY
		CamData.w             = w
		CamData.h             = h
		CamData.drawviewmodel = false
		CamData.fov           = button.fov
		render.RenderView( CamData )
		surface.SetTexture( tex )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( texPositionX, texPositionY, texSize, texSize )
		if select then
			drawDirArrow( ang, button:GetWide() / 2, button:GetTall() / 2 )
		end
	end

	button.Think = function()
		if not button.Move then return end
		button.curX, button.curY = button:CursorPos()
		button.curX = button.curX - button:GetWide() / 2
		button.curY = button.curY - button:GetTall() / 2
		button.curX = advRound( ( button.curX / ( button:GetWide()  * moveFactor ) ) * button.fovScale, 2 )
		button.curY = advRound( ( button.curY / ( button:GetTall()  * moveFactor ) ) * button.fovScale, 2 )
		if button.curX != 0 and isInWorld( viewPos - Vector( 0, button.curX, 0 ) ) then viewPos = viewPos - Vector( 0, button.curX, 0 ) end
		if button.curY != 0 and isInWorld( viewPos - Vector( button.curY, 0, 0 ) ) then viewPos = viewPos - Vector( button.curY, 0, 0 ) end
	end

	function button:OnMouseWheeled( mc )
		if mc > 0 then
			button.fov = button.fov - ( button.fov < 10 and 1 or 4 )
			if button.fov < 1 then button.fov = 1 end
		elseif mc < 0 then
			button.fov = button.fov + ( button.fov < 10 and 1 or 4 )
			if button.fov > 75 then button.fov = 75 end
		end
		button.fovScale = button.fov / 75
	end

	button.OnCursorEntered = function() button.Move = true  end
	button.OnCursorExited  = function() button.Move = false end

	input.SetCursorPos( ScrW() / 2, ScrH() / 2 )
end


net.Receive( "MW2_DropLoc_Overlay_UM", function()
	local Number  = net.ReadFloat()
	local Boolean = net.ReadBool()
	showOverlay( Number, Boolean )
end )


-- FIX: net.Start and LocalPlayer() calls moved here from file scope.
-- At autorun time LocalPlayer() is not valid and net messages may not be registered yet.
hook.Add( "InitPostEntity", "MW2_MapOverlay_Init", function()

	-- Run world traces now that the map is fully loaded
	sky  = FindSky()
	x1, x2 = findBounds( "x", sky )
	y1, y2 = findBounds( "y", sky )
	xDis = math.abs( x1 ) + math.abs( x2 )
	yDis = math.abs( y1 ) + math.abs( y2 )
	x = ScrW() * xyOffset
	y = ScrH() * xyOffset
	w = math.Round( ScrW() - ( x * 2 ) )
	h = math.Round( ScrH() - ( y * 2 ) )

	if Runtime_Error == false then
		net.Start( "STATUS" )
			net.WriteInt( 0, 2 )
		net.SendToServer()

		LocalPlayer():ConCommand( "OPEN_KILLSTREAK_MENU" )
		chat.AddText( Color( 0, 255, 0 ), "[ MW2 KILLSTREAKS ]:  This map is compatible with the Killstreaks!" )
	else
		net.Start( "STATUS" )
			net.WriteInt( 1, 2 )
		net.SendToServer()

		chat.AddText( Color( 255, 0, 0 ), "[ MW2 KILLSTREAKS ]:  This map is NOT compatible with the Killstreaks!" )
	end
end )


end  -- CLIENT
