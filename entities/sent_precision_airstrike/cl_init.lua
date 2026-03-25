include( "shared.lua" )  //  REQUIRED TO PREVENT ERRORS


function AIRSTRIKE_FRIENDLY()	//	CREATE A FUNCTION CALLED:	AIRSTRIKE_FRIENDLY()
	
	
	
	playAirstrikeInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playAirstrikeInboundSound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function AIRSTRIKE_ENEMY()	//	CREATE A FUNCTION CALLED:	AIRSTRIKE_ENEMY()


	
	playAirstrikeDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playAirstrikeDeploySound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playAirstrikeInboundSound()	//	CREATE A FUNCTION CALLED:	playAirstrikeInboundSound()


	surface.PlaySound("killstreak_rewards/precision_airstrike_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")  //  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playAirstrikeDeploySound()  //	CREATE A FUNCTION CALLED:	playAirstrikeDeploySound()
	
	
	surface.PlaySound("killstreak_rewards/precision_airstrike_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


usermessage.Hook( "MW2_AIRSTRIKE_FRIENDLY", AIRSTRIKE_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_AIRSTRIKE_FRIENDLY"  -  RUN THE FUNCTION:	AIRSTRIKE_FRIENDLY()


usermessage.Hook( "MW2_AIRSTRIKE_ENEMY", AIRSTRIKE_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_AIRSTRIKE_ENEMY"  -  RUN THE FUNCTION:	AIRSTRIKE_ENEMY()