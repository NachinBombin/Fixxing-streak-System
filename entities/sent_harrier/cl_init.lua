include( 'shared.lua' )


local function HARRIER_FRIENDLY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/harrier_friendly_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


local function HARRIER_ENEMY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/harrier_enemy_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


-- FIX: usermessage.Hook x2 -> net.Receive
net.Receive( "MW2_HARRIER_FRIENDLY", HARRIER_FRIENDLY )
net.Receive( "MW2_HARRIER_ENEMY",   HARRIER_ENEMY )
