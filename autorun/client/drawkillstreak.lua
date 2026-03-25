if not ( CLIENT ) then return end
//if !MW2KillStreakAddon then return end
local centerX = ScrW()/2;
local centerY = ScrH()/2
local picturePossitonX = centerX - 256;
local picturePossitonY = 0
local curKillIconX = ScrW() - 100;
local curKillIconY = ScrH() - 150;
local streak = "";
local oldId = 0;
local showNewKillstreak = false;
local curStreak = nil;
local id = 0;

local function playAcquiredSound(soundName)
	
	
	if soundName == "stealth_bomber" then
	
	
		soundName = "precision_airstrike";
	
	
	end
	
	
	if soundName == "mw2_sentry_gun_package" then	//	IF THE KILLSTREAK ACQUIRED TURNS OUT TO BE A SENTRY GUN, THEN
	
	
		return	//	RETURN TO THE CALLING FUNCTION (DO NOT PLAY ANY SOUND)
	
	
	end  //  FINISH THE "IF" STATEMENT
	
	
	surface.PlaySound("killstreak_rewards/" .. soundName .. "_acquired" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");


end


local function DISPLAY_FRIEND( FRIEND )  //	CREATE LOCAL FUNCTION CALLED "DISPLAY_FRIEND"  -  ACCEPT THE RENDERED PLAYER AS THE PARAMETER ( FRIEND )


	if GetConVar( "MW2_DISPLAY_FRIEND" ):GetInt() != 0 and GetConVar( "MW2_KILLSTREAKS_ENABLED" ):GetInt() != 0 and GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 and FRIEND:Team() == LocalPlayer():Team() then	//	DO A CHECK:	IF THE "MW2_DISPLAY_FRIEND" CONSOLE VARIABLE IS SET TO ANYTHING OTHER THAN "0" (IS ENABLED), *AND* THE KILLSTREAKS ARE "ENABLED", *AND* TEAMS ARE "ENABLED", *AND* THE TEAM OF THE "PLAYER" IS **EQUAL** TO THE TEAM OF THE *LOCAL USER*, THEN...


		if ( !IsValid( FRIEND ) ) then return end	//	CHECK:	IF THE PLAYER RENDERED IS *NOT VALID*, DO NOTHING AND RETURN


		if ( FRIEND == LocalPlayer() ) then return end	//	CHECK:	IF THE PLAYER RENDERED *IS THE LOCAL PLAYER*, DO NOTHING AND RETURN ( MAY BE COMMENTED OUT IF DESIRED )


		if ( !FRIEND:Alive() ) then return end	//	CHECK:	IF THE PLAYER RENDERED IS *NOT ALIVE*, DO NOTHING AND RETURN


		local DISTANCE = LocalPlayer():GetPos():Distance( FRIEND:GetPos() )  //  CREATE LOCAL VARIABLE CALLED "DISTANCE"  -  STORE THE DISTANCE BETWEEN THE LOCAL PLAYER AND THE "FRIEND"


		if DISTANCE < 1000 then  //  CHECK:  IF THE DISTANCE BETWEEN THE LOCAL PLAYER AND THE "FRIEND" IS *LESS THAN* "1000" UNITS, THEN...


			cam.Start3D( EyePos(), EyeAngles() )	//	CREATE A CUSTOM "3D" RENDERING CONTEXT:  SET THE "POSITION" OF THE RENDERER TO THE POSITION OF THE LOCAL PLAYER'S "EYES"	-	SET THE "ANGLE" OF THE RENDERER TO THE "ANGLE" OF THE LOCAL PLAYER'S "EYES"


				local ANGLE = LocalPlayer():EyeAngles()  //  CREATE LOCAL VARIABLE CALLED "ANGLE"	-	STORE THE "EYE ANGLES" OF THE LOCAL PLAYER
				

					ANGLE:RotateAroundAxis( ANGLE:Forward(), 90 )	//	ROTATE AROUND THE *FORWARD* AXIS "90" DEGREES


					ANGLE:RotateAroundAxis( ANGLE:Right(), 90 )  //  ROTATE AROUND THE *RIGHT* AXIS "90" DEGREES


				local POSITION = FRIEND:GetPos() + Vector( 0, 0, FRIEND:OBBMaxs().z + 10 )	//  CREATE LOCAL VARIABLE CALLED "POSITION"	-	GET AND STORE THE "POSITION" OF THE "FRIEND"


					cam.Start3D2D( POSITION, Angle( 0, ANGLE.y, 90 ), 0.5 )  //	CREATE A CUSTOM "2D" RENDERING CONTEXT:  POPULATE THE "POSITION", "ANGLE", AND "SCALE" PARAMETERS WITH THE RESPECTIVE VALUES


						draw.DrawText( "FRIENDLY", "Default", 2, 2, Color( 0, 255, 0 ), TEXT_ALIGN_CENTER )  //  DRAW CUSTOM TEXT:	ALIGN TO "CENTER"


					cam.End3D2D()	//	FINISH THE "2D" RENDERING CONTEXT


			cam.End3D()  //  FINISH THE "3D" RENDERING CONTEXT


		end  //  FINISH THE "IF" STATEMENT


	end  //  FINISH THE "IF" STATEMENT


end  //  COMPLETE THE FUNCTION


hook.Add( "PostPlayerDraw", "Display_Friend", DISPLAY_FRIEND )	//	ADD CUSTOM HOOK:	AFTER THE PLAYER IS FULLY RENDERED, RUN FUNCTION CALLED "DISPLAY_FRIEND" DEFINED ABOVE


local function drawAddedKillStreak()
	
	if curStreak == nil || id <= oldId then
		local str = LocalPlayer():GetNetworkedString("MW2NewKillstreak");		
		local Sep = string.Explode("+", str)
		curStreak = Sep[1];
		
		if Sep[2] != nil then id = tonumber(Sep[2]); end	
		
	elseif curStreak != nil && id > oldId then		
		streak = curStreak;
		
		playAcquiredSound(streak)
		showNewKillstreak = true;
		timer.Create("AddedKillstreaks_Timer",2,1, function()
			showNewKillstreak = false;
		end)
		oldId = id;
	end
	if !showNewKillstreak then return; end
	
	if streak == "none" || streak == nil then return end;	
	
	surface.SetTexture(surface.GetTextureID("VGUI/killstreaks/" .. streak))	
	surface.SetDrawColor(255,255,255,255)  //  Make sure the image draws correctly
	surface.DrawTexturedRect(picturePossitonX, picturePossitonY, 512, 256)
end
hook.Add("HUDPaint", "DrawAddedMW2KillStreaks", drawAddedKillStreak)

local function drawAvaliabeKillStreak()	
	local availableStreak = LocalPlayer():GetNetworkedString("CurrentMW2KillStreak");
	
	str = availableStreak;
	if str == nil || str == "none" || str == "" then return end
	availableStreak = "VGUI/killstreaks/animated/" .. str;
	surface.SetTexture(surface.GetTextureID( availableStreak))
	surface.SetDrawColor(255,255,255,255) //Makes sure the image draws correctly
	surface.DrawTexturedRect(curKillIconX, curKillIconY, 44, 44)
end
hook.Add("HUDPaint", "DrawAvaliabeMW2KillStreaks", drawAvaliabeKillStreak)