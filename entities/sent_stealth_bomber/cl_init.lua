include( "shared.lua" )


local function BOMBER_FRIENDLY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/precision_airstrike_friendly_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


local function BOMBER_ENEMY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/precision_airstrike_enemy_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


-- FIX: usermessage.Hook x2 -> net.Receive
net.Receive( "MW2_BOMBER_FRIENDLY", BOMBER_FRIENDLY )
net.Receive( "MW2_BOMBER_ENEMY",   BOMBER_ENEMY )
