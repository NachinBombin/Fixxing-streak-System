include('shared.lua')	//  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES

local Alpha = 255;
local alphaDelay = 0.01
local alphaTimer = CurTime();


local EMP_TEAM = -1;  //  SET THE "TEAM" TO BE "-1" BY DEFAULT ( NO TEAM )


local EMP_OWNER = 0  //  SET THE OWNER OF THE EMP TO BE "0" BY DEFAULT ( NO OWNER )


function FireMW2EMPEffect()  //  CREATE A GLOBAL FUNCTION CALLED:	"FireMW2EMPEffect"
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		if Alpha > 0 and EMP_TEAM != LocalPlayer():Team() then	//	CHECK:	IF THE "ALPHA" OF THE HUD IS *GREATER THAN* "0", **AND** THE EMP WAS *NOT* USED BY THE LOCAL USER'S TEAM, THEN...
			

			DRAW_FLASH()	//	DRAW FLASH ON PLAYER'S SCREEN
	

		end  //  FINISH CHECK
		
		
	else  //  IF TEAMS ARE *NOT ENABLED*, THEN...


		local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER


		for Key, Value in pairs( Players ) do	//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
		

			if Value == LocalPlayer() and EMP_OWNER != 1 then	//  CHECK:	IF THE CURRENT PLAYER BEING LOOKED AT *IS THE LOCAL PLAYER*, **AND** THE FLAG ( EMP_OWNER ) IS *NOT EQUAL* TO THE VALUE OF "1", THEN...
			

				DRAW_FLASH()	//	DRAW FLASH ON PLAYER'S SCREEN
				
				
			end  //  FINISH THE CHECK

		
		end  //  FINISH THE LOOP

	
	end  //  FINISH THE CHECK
	
	
end  //  COMPLETE THE FUNCTION


function DRAW_FLASH()
	
	
	surface.SetDrawColor(255, 255, 255, Alpha)
	
	
	surface.DrawRect(0, 0, surface.ScreenWidth(), surface.ScreenHeight())
	
	
	if alphaTimer <= CurTime() then
		
		
		Alpha = Alpha - 1;
		
		
		alphaTimer = CurTime() + alphaDelay;
	
	
	end


end


function MW2_EMP_Effect( Team )  //  CREATE A GLOBAL FUNCTION CALLED:	"MW2_EMP_Effect"	-	ACCEPT ONE PARAMETER


	LocalPlayer():EmitSound( "killstreak_misc/em_pulse.wav" )	//	PLAY SOUND LOCALLY ON THE CLIENT

	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...

		
		EMP_TEAM = Team:ReadShort();	//	READ THE "SHORT" PIECE OF DATA RECEIVED AS ARGUMENT
		
		
	end  //  FINISH THE CHECK


	hook.Add( "HUDPaint", "MW2_EMP_Effect", FireMW2EMPEffect )  //  ADD A HOOK:  AS THE HEAD UP DISPLAY ( HUD ) IS RENDERING, RUN FUNCTION "FireMW2EMPEffect" DEFINED ABOVE


end  //  COMPLETE THE FUNCTION


function MW2_READ_OWNER( Owner )	//  CREATE A GLOBAL FUNCTION CALLED:	"MW2_READ_OWNER"	-	ACCEPT ONE PARAMETER


	EMP_OWNER = Owner:ReadShort();	//  READ THE "SHORT" FLAG SIGNALING THE OWNER OF THE EMP
	
	
	hook.Add( "HUDPaint", "MW2_SEND_OWNER", FireMW2EMPEffect )  //  ADD A HOOK:  AS THE HEAD UP DISPLAY ( HUD ) IS RENDERING, RUN FUNCTION "FireMW2EMPEffect" DEFINED ABOVE


end  //  COMPLETE THE FUNCTION


function EMP_FRIENDLY()	//	CREATE A FUNCTION CALLED:	EMP_FRIENDLY()
	
	
	
	playEMPInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playEMPInboundSound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function EMP_ENEMY()	//	CREATE A FUNCTION CALLED:	EMP_ENEMY()


	
	playEMPDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playEMPDeploySound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playEMPInboundSound()	//	CREATE A FUNCTION CALLED:	playEMPInboundSound()
	
	
	surface.PlaySound("killstreak_rewards/mw2_emp_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")  //  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playEMPDeploySound()	//	CREATE A FUNCTION CALLED:	playEMPDeploySound()
	
	
	surface.PlaySound("killstreak_rewards/mw2_emp_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")  //  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function MW2_Clear_EMP()


	hook.Remove( "HUDPaint", "MW2_EMP_Effect" )	


end


usermessage.Hook( "MW2_EMP_FireEMP", MW2_EMP_Effect )


usermessage.Hook( "MW2_EMP_RemoveEMP", MW2_Clear_EMP )


usermessage.Hook( "MW2_EMP_OWNER", MW2_READ_OWNER )  //  //	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_EMP_OWNER"  -  CALL THE FUNCTION:	MW2_READ_OWNER()


usermessage.Hook( "MW2_EMP_FRIENDLY", EMP_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_EMP_FRIENDLY"  -  CALL THE FUNCTION:	EMP_FRIENDLY()


usermessage.Hook( "MW2_EMP_ENEMY", EMP_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_EMP_ENEMY"  -  CALL THE FUNCTION:	EMP_ENEMY()