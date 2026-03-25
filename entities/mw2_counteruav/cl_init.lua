include( 'shared.lua' )  //  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES


function COUNTER_UAV_FRIENDLY()	//	CREATE A FUNCTION CALLED:	COUNTER_UAV_FRIENDLY()
	
	
	
	playCounterUAVInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playCounterUAVInboundSound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function COUNTER_UAV_ENEMY()	//	CREATE A FUNCTION CALLED:	COUNTER_UAV_ENEMY()


	
	playCounterUAVDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playCounterUAVDeploySound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED

	
function playCounterUAVInboundSound()	//	CREATE A FUNCTION CALLED:	playCounterUAVInboundSound()

	/*	THIS CODE BLOCK HAS BEEN DISABLED	-	INOPERABLE AND UNOPTIMIZED
	
	local teamType = "";
	
	if GetGlobalString("MW2_CounterUAV_Player") == LocalPlayer():GetName() then
		teamType = "friendly";
	else 
		teamType = "enemy";
	end
	
	*/
	
	surface.PlaySound("killstreak_rewards/mw2_counter_uav_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")  //  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playCounterUAVDeploySound()	//	CREATE A FUNCTION CALLED:	playCounterUAVDeploySound()

	
	surface.PlaySound("killstreak_rewards/mw2_counter_uav_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")  //  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


usermessage.Hook( "MW2_COUNTER_UAV_FRIENDLY", COUNTER_UAV_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_COUNTER_UAV_FRIENDLY"  -  CALL THE FUNCTION:	COUNTER_UAV_FRIENDLY()


usermessage.Hook( "MW2_COUNTER_UAV_ENEMY", COUNTER_UAV_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_COUNTER_UAV_ENEMY"  -  CALL THE FUNCTION:	COUNTER_UAV_ENEMY()