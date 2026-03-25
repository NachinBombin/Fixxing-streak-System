if CLIENT == true then	  //	PERFORM A CHECK TO MAKE SURE THAT THE SCRIPT IS RUNNING ON THE CLIENT ONLY


local tex = surface.GetTextureID("VGUI/killStreak_misc/callin")
local arrow = surface.GetTextureID("VGUI/killStreak_misc/arrow")
local texSize = 64;
local arrowSize = 32;
local edge = arrowSize + arrowSize/2
local Runtime_Error = false  //  CREATE A LOCAL VARIABLE CALLED:	Runtime_Error	-	MAKE "FALSE" INITIALLY BECAUSE THERE SHOULD BE NO ERRORS AT THIS TIME


local function FindSky()

	local maxheight = 16384
	local startPos = Vector(0,0,0);
	local endPos = Vector(0, 0,maxheight);
	local filterList = {}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local skyLocation = -1;
	while bool do
	
		traceData = util.TraceLine(trace);
		
		hitSky = traceData.HitSky;
			
		hitWorld = traceData.HitWorld;
			
			
		if hitSky == true then
			//MsgN("Hit the sky")
			skyLocation = traceData.HitPos.z;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
			//MsgN("hit the world, not the sky")
		else 
			//Msg("Hit ")
			//MsgN(traceData.Entity:GetClass());
			table.insert(filterList, traceData.Entity)
		end
			
		if skyLocation == -1 then	//	PERFORM A CHECK:	MAKE SURE THAT A SKY DOES INDEED EXIST. HOWEVER, IF A SKY IS *NOT* FOUND, THEN

			
			Runtime_Error = true	//	NOTE THE ERROR
			
			
			bool = false	//	SET "bool" TO "false" SO THAT THE LOOP WON'T RUN ANYMORE
			
			
			break	//	STOP EXECUTION
			
		
		end  //  FINISH THE "IF" STATEMENT
		
					
		if maxNumber >= 300 then
			
			
			MsgN("Reached max number here, no luck in finding a skyBox");
			
			
			bool = false;
		
		
		end
			

	end

		
		return skyLocation
		
	
end
	

local function findBounds(axis, height)

	local length = 16384
	local startPos = Vector(0,0,height);
	local endPos;
	if axis == "x" then 
		endPos = Vector(length, 0,height);
	elseif axis == "y" then 
		endPos = Vector(0, length,height);
	end
	
	local filterList = {}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local wallLocation1 = -1;
	local wallLocation2 = -1;
	while bool do
		
		
		traceData = util.TraceLine(trace);
		
		hitSky = traceData.HitSky;
			
		hitWorld = traceData.HitWorld;

		
		if hitSky == true then
			if wallLocation1 == -1 then
				if axis == "x" then
					wallLocation1 = traceData.HitPos.x;
				elseif axis == "y" then
					wallLocation1 = traceData.HitPos.y;
				end
				
				if axis == "x" then 
					endPos = Vector(length * -1, 0,height);
				elseif axis == "y" then
					endPos = Vector(0, length * -1,height);
				end
				
				trace = {}
				trace.start = startPos;
				trace.endpos = endPos;
				trace.filter = filterList;
			else
				if axis == "x" then
					wallLocation2 = traceData.HitPos.x;
				elseif axis == "y" then
					wallLocation2 = traceData.HitPos.y;
				end
				
				bool = false;
			end
		elseif hitWorld then
			if wallLocation1 == -1 then
				if axis == "x" then
					trace.start = traceData.HitPos + Vector(50,0,0);
				elseif axis == "y" then
					trace.start = traceData.HitPos + Vector(0,50,0);
				end
			else
				if axis == "x" then
					trace.start = traceData.HitPos - Vector(50,0,0);
				elseif axis == "y" then
					trace.start = traceData.HitPos - Vector(0,50,0);
				end
			end
		else 
			table.insert(filterList, traceData.Entity)
		end
	
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the wall");
			bool = false;
		end		
		maxNumber = maxNumber + 1;
	end
	
	
	return wallLocation1, wallLocation2;

	
end


local sky = FindSky()


local x1,x2 = findBounds("x", sky) -- x1 is positive, x2 is negative


local y1,y2 = findBounds("y", sky) -- y1 > 0; y2 < 0


local xDis, yDis = math.abs(x1) + math.abs(x2), math.abs(y1) + math.abs(y2);


local xyOffset = .05
local x,y = ScrW() * xyOffset, ScrH() * xyOffset
local w,h = math.Round( ScrW() - (x * 2 ) ), math.Round( ScrH() - ( y * 2 ) )


local function isInWorld( pos )
	local posX, posY = pos.x, pos.y
	if ( posX > x2 && posX < x1 ) && ( posY > y2 && posY < y1 ) then
		return true;
	end

	return false;

end

local function advRound( val, d )
	d = d or 0;
 
	return math.Round( val * (10 ^ d) ) / (10 ^ d);
end

local function drawDirArrow(angle, xPos, yPos)	
	surface.SetTexture(arrow)
	surface.SetDrawColor(255,255,255,255)
	if angle == 0 then
		surface.DrawTexturedRectRotated(xPos, yPos - edge, arrowSize, arrowSize, 0)	-- 					X = 640, 	Y = 464	
	elseif angle == 45 then
		surface.DrawTexturedRectRotated(xPos - edge/1.5, yPos - edge/1.5, arrowSize, arrowSize, 45)	--	X = 608,	Y = 480	
	elseif angle == 90 then
		surface.DrawTexturedRectRotated(xPos - edge, yPos, arrowSize, arrowSize, 90)	-- 				X = 592,	Y = 512
	elseif angle == 135 then
		surface.DrawTexturedRectRotated(xPos - edge/1.5, yPos + edge/1.5, arrowSize, arrowSize, 135)--	X = 608,	Y = 544
	elseif angle == 180 then
		surface.DrawTexturedRectRotated(xPos, yPos + edge, arrowSize, arrowSize, 180)	--				X = 640,	Y = 560
	elseif angle == 225 then
		surface.DrawTexturedRectRotated(xPos + edge/1.5, yPos + edge/1.5, arrowSize, arrowSize, 225)--	X = 672,	Y = 544
	elseif angle == 270 then
		surface.DrawTexturedRectRotated(xPos + edge, yPos, arrowSize, arrowSize, 270)	--				X = 688,	Y = 512
	elseif angle == 315 then
		surface.DrawTexturedRectRotated(xPos + edge/1.5, yPos - edge/1.5, arrowSize, arrowSize, 315)--	X = 672,	Y = 480	
	end
end


local function Check_Status()	//	CREATE LOCAL FUNCTION CALLED:	"Check_Status"


	if LocalPlayer():Alive() == true then	//	CHECK:	IF THE LOCAL PLAYER *IS ALIVE*, THEN...
	
	
		return 1  //  RETURN A VALUE OF "1"
	
	
	else  //  IF THE PLAYER IS *NOT ALIVE*, THEN...
	
	
		return 0  //  RETURN A VALUE OF "0"
	

	end  //  FINISH THE CHECK


end  //  COMPLETE THE FUNCTION


local function showOverlay( ent, select )	//	CREATE LOCAL FUNCTION CALLED "showOverlay"	-	ACCEPT AN ENTITY (ent) AND BOOLEAN (select) BOTH AS AN INDIVIDUAL PARAMETER


local Timer = NULL	//	CREATE A LOCAL VARIABLE CALLED "Timer" AND SET IT TO AN INITIAL VALUE OF "NULL" ( CAN BE ANYTHING )


timer.Create( "Status_Check", 1, 0, function()	//	CREATE A CUSTOM TIMER NAMED "Status_Check"	-	AFTER "1" SECOND, RUN CUSTOM FUNCTION ( REPEAT UNTIL REMOVED )
	
	
	Timer = Check_Status()	//	SET THE "Timer" VARIABLE TO RECEIVE THE DATA PASSED BACK AFTER RUNNING THE "Check_Status" FUNCTION DEFINED ABOVE


end )	//	COMPLETE THE TIMER ( AND FUNCTION )


	local viewPos = Vector(0,0,sky) 
	local ang = 0;
	local CamData = {}
	local Overlay = vgui.Create('DFrame')
		Overlay:SetSize(w, h)
		Overlay:SetPos(x, y)
		Overlay:SetDraggable(false)
		Overlay:ShowCloseButton(false)
		Overlay:SetTitle("Overlay")
		Overlay:SetBackgroundBlur( false )
		Overlay:MakePopup()
				
	local button = vgui.Create( "DButton", Overlay ) -- Need to use a button to register right clicks.
		button:SetSize( Overlay:GetWide(), Overlay:GetTall() )
		button:SetPos( 0,0 );
		button:SetText( "" );
		button.DoClick = function()	//	WHEN THE USER LEFT-CLICKS ON THE MAP, DO THE FOLLOWING...
	
			
			if select and Timer == 1 then	//	CHECK:	IF THE BOOLEAN IS RECEIVED "TRUE" *AND* THE "Timer" EQUALS "1" ( THE PLAYER IS STILL ALIVE ), THEN...

				
				net.Start( "MW2_DropLocation_Overlay_Stream" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "MW2_DropLocation_Overlay_Stream"
					
					
					net.WriteFloat( ent )  //  USED TO BE:  "ent:EntIndex()"  -  CAUSED A MAJOR BUG THAT RENDERED THE OVERLAY INOPERABLE
					
			
					net.WriteVector( viewPos )
					
				
					net.WriteFloat( ang )
				
				
				net.SendToServer()	//	SEND THIS MESSAGE TO THE SERVER
				
				
				-- datastream.StreamToServer("MW2_DropLocation_Overlay_Stream", { ent, viewPos, ang } )
				
				
			elseif !select and Timer == 1 then	//	IF THE BOOLEAN IS RECEIVED "FALSE" *AND* THE "Timer" EQUALS "1" ( THE PLAYER IS STILL ALIVE ), THEN...
				
				
				net.Start( "MW2_DropLocation_Overlay_Stream" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "MW2_DropLocation_Overlay_Stream"
					
					
					net.WriteFloat( ent )  //  USED TO BE:  "ent:EntIndex()"  -  CAUSED A MAJOR BUG THAT RENDERED THE OVERLAY INOPERABLE
					
					
					net.WriteVector( viewPos )
				
				
				net.SendToServer()	//	SEND THIS MESSAGE TO THE SERVER
			
			
			else	//	IF THE ABOVE CONDITIONS FAIL, THEN...
			
			
				timer.Remove( "Status_Check" )	//	REMOVE THE CUSTOM TIMER "Status_Check"
			
				
				Overlay:Close()  //  CLOSE THE OVERLAY MAP
			
			
			end  //  FINISH THE "IF" STATEMENT
			
			
			timer.Remove( "Status_Check" )	//	REMOVE THE CUSTOM TIMER "Status_Check" ( IF SUCCESSFUL )
			
			
			Overlay:Close()  //  CLOSE THE OVERLAY MAP
		
		
		end  //  COMPLETE THE FUNCTION ( FOR THE BUTTON )
		
		
		button.DoRightClick = function()
			if select then
				ang = ang + 45;
				if ang >= 360 then ang = 0 end
			end
		end	
		button.curX, button.curY = 0,0
		button.fov = 75;
		button.fovScale = 1;
	local moveFactor = .005	
	local texPossitonX = button:GetWide()/2 - texSize/2
	local texPossitonY = button:GetTall()/2 - texSize/2

	button.Paint = function()
		local CamX, CamY = Overlay:GetPos()
		
		CamData.angles = Angle(90,0,0)
		CamData.origin = viewPos
		CamData.x = CamX
		CamData.y = CamY
		CamData.w = w
		CamData.h = h
		CamData.drawviewmodel = false;
		CamData.fov = button.fov
		render.RenderView( CamData )			
		surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
		surface.DrawTexturedRect(texPossitonX, texPossitonY, texSize, texSize)	
		if select then			
			drawDirArrow(ang, button:GetWide()/2, button:GetTall()/2)
		end
	end


	button.Think = function()
		if !button.Move then return end
		button.curX, button.curY = button:CursorPos();
		button.curX = button.curX - button:GetWide()/2;
		button.curY = button.curY - button:GetTall()/2;
		button.curX = advRound( ( button.curX / (button:GetWide() * moveFactor) ) * button.fovScale, 2 );
		button.curY = advRound( ( button.curY / (button:GetTall() * moveFactor) ) * button.fovScale, 2 );
		if button.curX != 0 && isInWorld( viewPos - Vector(0, button.curX, 0) ) then viewPos = viewPos - Vector(0, button.curX, 0) end
		if button.curY != 0 && isInWorld( viewPos - Vector(button.curY, 0, 0) ) then viewPos = viewPos - Vector(button.curY, 0, 0) end
	end
	
	function button:OnMouseWheeled(mc)
		if mc > 0 then			
			if button.fov < 10 then 
				button.fov = button.fov - 1;
			else
				button.fov = button.fov - 4
			end
			if button.fov < 1 then button.fov = 1; end			
		elseif mc < 0 then
			if button.fov < 10 then 
				button.fov = button.fov + 1;
			else
				button.fov = button.fov + 4;
			end
			if button.fov > 75 then button.fov = 75; end
		end
		button.fovScale = button.fov/75
	end

	button.OnCursorEntered = function()
		button.Move = true;
	end
	button.OnCursorExited = function()
		button.Move = false;
	end
	
	input.SetCursorPos(ScrW()/2,ScrH()/2)


end


/*	CODE BLOCK DISABLED  -  NON-FUNCTIONAL


local function OpenOverlay( um )

	
	showOverlay( um:ReadFloat(), um:ReadBool() )

	
end


usermessage.Hook("MW2_DropLoc_Overlay_UM", OpenOverlay)


*/


net.Receive( "MW2_DropLoc_Overlay_UM", function()	//	IF THE SYSTEM RECEIVES A MESSAGE THAT IS SPECIFICALLY:	"MW2_DropLoc_Overlay_UM" FROM THE SERVER, CREATE A CUSTOM FUNCTION (function()) THAT PERFORMS THE FOLLOWING

		
		local Number = net.ReadFloat()	//	CREATE A LOCAL VARIABLE AND READ THE FIRST PIECE OF DATA RECEIVED AS A FLOAT
		
		
		local Boolean = net.ReadBool()	//	CREATE A LOCAL VARIABLE AND READ THE SECOND PIECE OF DATA RECEIVED AS A BOOLEAN

		
		showOverlay( Number, Boolean )		//	CALL THE "showOverlay" FUNCTION AND PASS BOTH VARIABLES IN "PROTECTED" MODE (pcall)		
		
		
end )	//  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


if Runtime_Error == false then	//	IF (DURING THE LIFETIME OF THE SCRIPT) NO ERRORS OCCURRED, THEN... 


	net.Start( "STATUS" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "STATUS"
	

		net.WriteInt( 0, 2 )	//	MESSAGE CONTENT:	SIMPLY SEND AN INTEGER OF "0" (MAY BE UP TO "32") TO DENOTE THE COMMON "SUCCESS" MESSAGE. SET THE MAXIMUM BITS SENT TO "2"
	
	
	net.SendToServer()	//	SEND THIS MESSAGE TO THE SERVER


	LocalPlayer():ConCommand( "OPEN_KILLSTREAK_MENU" )	//	OPEN THE KILLSTREAK MENU


	chat.AddText( Color( 0, 255, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THIS MAP IS COMPATIBLE WITH THE KILLSTREAKS!" )	//	PRINT A SUCCESS MESSAGE TO THE USER'S CHAT
	

else	//	OTHERWISE (IF AN ERROR *DID* OCCUR), THEN...


	net.Start( "STATUS" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "STATUS"
	

		net.WriteInt( 1, 2 )	//	MESSAGE CONTENT:	SIMPLY SEND AN INTEGER OF "1" (MAY BE UP TO "32") TO DENOTE THE COMMON "FAILURE" MESSAGE. SET THE MAXIMUM BITS SENT TO "2"
	
	
	net.SendToServer()	//	SEND THIS MESSAGE TO THE SERVER

	
	chat.AddText( Color( 255, 0, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THIS MAP IS NOT COMPATIBLE WITH THE KILLSTREAKS!" )	//	PRINT A FAILURE MESSAGE TO THE USER'S CHAT
	
	
end  //  FINISH THE "IF" STATEMENT


end  //  SINCE THE CODE HAS SUCCESSFULLY RUN AS THE "CLIENT"  -  TELL THE SYSTEM THERE IS NO MORE CODE TO RUN