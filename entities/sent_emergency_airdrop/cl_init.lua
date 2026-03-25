include( "shared.lua" )		//  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES


function AIRDROP_FRIENDLY()	//	CREATE A FUNCTION CALLED:	AIRDROP_FRIENDLY()
	
	
	
	playAirdropInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playAirdropInboundSound
	
	

end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playAirdropInboundSound()	//	CREATE A FUNCTION CALLED:	playAirdropInboundSound()


	surface.PlaySound("killstreak_rewards/emergency_airdrop" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


usermessage.Hook( "MW2_AIRDROP_FRIENDLY", AIRDROP_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_AIRDROP_FRIENDLY"  -  RUN THE FUNCTION:	AIRDROP_FRIENDLY()