//if !MW2KillStreakAddon then return end

/*	THIS CODE HAS BEEN DISABLED  -  EXTREMELY BUGGY AND COULD VERY WELL CONFLICT WITH THE CURRENT IMPLEMENTATION OF THE KILLSTREAKS

predMissileDeploy = Sound("killstreak_rewards/predator_missile_deploy.wav");
predMissileInbound = Sound("killstreak_rewards/predator_missile_inbound.wav");
harrierLaptopDeploy = Sound("killstreak_rewards/harrier_laptop.wav");

ac130Deploy = Sound("killstreak_rewards/ac-130_deploy.wav");

function playPredatorMissileDeploy()
	surface.PlaySound(predMissileDeploy)
end

function playPredatorMissileInbound()
	//surface.PlaySound(predMissileInbound);
	surface.PlaySound("killstreak_rewards/predator_missile_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end



function playHarrierLaptopDeploy()
	
	
	surface.PlaySound("killstreak_rewards/harrier_laptop.wav")

	
end



function playHarrierInbound()
	//surface.PlaySound(harrierInbound);
	surface.PlaySound("killstreak_rewards/harrier_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

function playPrecisionAirstrikeInbound()
	surface.PlaySound("killstreak_rewards/precision_airstrike_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav");
end

function playAC130Deploy()
	//surface.PlaySound(ac130Deploy);
	surface.PlaySound("killstreak_rewards/ac-130_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav")
end

usermessage.Hook("playPredatorMissileDeploySound", playPredatorMissileDeploy)
usermessage.Hook("playPredatorMissileInboundSound", playPredatorMissileInbound)
usermessage.Hook("playHarrierInboundSound", playHarrierInbound)
usermessage.Hook("playPrecisionAirstrikeInboundSound", playPrecisionAirstrikeInbound)
usermessage.Hook("playAC130DeploySound", playAC130Deploy)



usermessage.Hook("playHarrierLaptopDeploySound", playHarrierLaptopDeploy)

*/

killicon.Add("sent_predator_missile","vgui/killicons/predator_missile",Color ( 255, 255, 255 ) )
killicon.Add("sent_air_strike_bomb","vgui/killicons/precision_air_strike",Color ( 255, 255, 255 ) ) 
killicon.Add("sent_harrier","vgui/killicons/harrier",Color ( 255, 255, 255 ) ) -- this was added
killicon.Add("sent_ac-130","vgui/killicons/ac-130",Color ( 255, 255, 255 ) )
killicon.Add( "mw2_sentrygun", "vgui/killicons/sentry_gun", Color( 255, 255, 255 ) )	//	REQUIRED FOR THE SENTRY GUN KILL-ICON
killicon.Add( "sent_supplycrate", "vgui/killicons/supply_crate", Color( 255, 255, 255 ) )	//	REQUIRED FOR THE SUPPLY CRATE KILL-ICON
killicon.Add( "worldspawn", "vgui/killicons/world", Color( 255, 255, 255 ) )	//	REQUIRED FOR THE WORLD KILL-ICON
killicon.AddAlias( "sent_105mm", "sent_ac-130" )
killicon.AddAlias( "sent_40mm", "sent_ac-130" )
killicon.AddAlias( "sent_bomblet", "sent_air_strike_bomb" )