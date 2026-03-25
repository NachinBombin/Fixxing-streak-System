include( "shared.lua" )		//  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES


function BOMBER_FRIENDLY()	//	CREATE A FUNCTION CALLED:	BOMBER_FRIENDLY()
	
	
	
	playBomberInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playBomberInboundSound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function BOMBER_ENEMY()	//	CREATE A FUNCTION CALLED:	BOMBER_ENEMY()


	
	playBomberDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playBomberDeploySound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playBomberInboundSound()	//	CREATE A FUNCTION CALLED:	playBomberInboundSound()


	surface.PlaySound("killstreak_rewards/precision_airstrike_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playBomberDeploySound()	//	CREATE A FUNCTION CALLED:	playBomberDeploySound()
	
	
	surface.PlaySound("killstreak_rewards/precision_airstrike_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


usermessage.Hook( "MW2_BOMBER_FRIENDLY", BOMBER_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_BOMBER_FRIENDLY"  -  RUN THE FUNCTION:	BOMBER_FRIENDLY()


usermessage.Hook( "MW2_BOMBER_ENEMY", BOMBER_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_BOMBER_ENEMY"  -  RUN THE FUNCTION:	BOMBER_ENEMY()