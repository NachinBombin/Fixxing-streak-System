include( 'shared.lua' )  //  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES


function HARRIER_FRIENDLY()	//	CREATE A FUNCTION CALLED:	HARRIER_FRIENDLY()
	
	
	
	playHarrierInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playHarrierInboundSound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function HARRIER_ENEMY()	//	CREATE A FUNCTION CALLED:	HARRIER_ENEMY()


	
	playHarrierDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playHarrierDeploySound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playHarrierInboundSound()  //	CREATE A FUNCTION CALLED:	playHarrierInboundSound()
	

	surface.PlaySound("killstreak_rewards/harrier_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playHarrierDeploySound()  //	CREATE A FUNCTION CALLED:	playHarrierDeploySound()
	

	surface.PlaySound("killstreak_rewards/harrier_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


usermessage.Hook( "MW2_HARRIER_FRIENDLY", HARRIER_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_HARRIER_FRIENDLY"  -  RUN THE FUNCTION:	HARRIER_FRIENDLY()


usermessage.Hook( "MW2_HARRIER_ENEMY", HARRIER_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_HARRIER_ENEMY"  -  RUN THE FUNCTION:	HARRIER_ENEMY()