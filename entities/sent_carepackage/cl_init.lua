include( 'shared.lua' )  //  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES


function PACKAGE_FRIENDLY()	//	CREATE A FUNCTION CALLED:	PACKAGE_FRIENDLY()
	
	
	
	playCarePackageInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playCarePackageInboundSound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playCarePackageInboundSound()	//	CREATE A FUNCTION CALLED:	playCarePackageInboundSound()
	

	surface.PlaySound("killstreak_rewards/care_package" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


usermessage.Hook( "MW2_PACKAGE_FRIENDLY", PACKAGE_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_PACKAGE_FRIENDLY"  -  RUN THE FUNCTION:	PACKAGE_FRIENDLY()