include( 'shared.lua' )  //  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES

local Countdown = Sound("killstreak_rewards/tactical_nuke_countdown.wav")
local function drawNukeCountDownHUD()
	
	local nukeTime = GetGlobalString("MW2_Nuke_CountDown_Timer")
	
	local nukeString = "";
	if string.len(nukeTime) > 3 then	
		nukeString = "0:0" .. string.sub(nukeTime, 1, 3);
	else
		nukeString = "0:0" .. nukeTime;
	end
	
	
	surface.SetTexture(surface.GetTextureID("VGUI/killstreaks/animated/tactical_nuke"))
	surface.SetDrawColor( 255, 255, 255 )  //  Makes sure the image draws correctly
	surface.DrawTexturedRect(200 - 32, 20 , 64, 64)
	surface.CreateFont ( "MW2Font", { "BankGothic Md BT", 20, 400, true, false } )
	surface.SetFont("MW2Font")
	surface.SetTextColor( 255, 255, 255 )
    surface.SetTextPos( 200 - 20 , 15 + 32  )
    surface.DrawText( nukeString )
	
	
end


function NukeSetUpHUD()
	hook.Add("HUDPaint", "NukeCountDownEffect", drawNukeCountDownHUD)
	surface.PlaySound(Countdown)
end


function NUKE_FRIENDLY()	//	CREATE A FUNCTION CALLED:	NUKE_FRIENDLY()
	
	
	
	playNukeInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playNukeInboundSound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function NUKE_ENEMY()	//	CREATE A FUNCTION CALLED:	NUKE_ENEMY()


	
	playNukeDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playNukeDeploySound
	
	
	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playNukeInboundSound()  //	CREATE A FUNCTION CALLED:	playNukeInboundSound()
	
	
	surface.PlaySound("killstreak_rewards/tactical_nuke_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playNukeIncomingSound()	//	CREATE A FUNCTION CALLED:	playNukeIncomingSound()
	
	
	surface.PlaySound("killstreak_rewards/tactical_nuke_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM

	
end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function NukeRemoveHUD()
	hook.Remove("HUDPaint", "NukeCountDownEffect")	
end


usermessage.Hook( "MW2_Nukes_SetUpHUD", NukeSetUpHUD )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_Nukes_SetUpHUD"  -  RUN THE FUNCTION:	NukeSetUpHUD()


usermessage.Hook( "MW2_Nuke_RemoveHUD", NukeRemoveHUD )


usermessage.Hook( "MW2_NUKE_FRIENDLY", NUKE_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_NUKE_FRIENDLY"  -  RUN THE FUNCTION:	NUKE_FRIENDLY()


usermessage.Hook( "MW2_NUKE_ENEMY", NUKE_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_NUKE_ENEMY"  -  RUN THE FUNCTION:	NUKE_ENEMY()