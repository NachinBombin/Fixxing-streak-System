include( 'shared.lua' )


local function COUNTER_UAV_FRIENDLY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/mw2_counter_uav_friendly_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


local function COUNTER_UAV_ENEMY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/mw2_counter_uav_enemy_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


-- FIX: usermessage.Hook x2 -> net.Receive
net.Receive( "MW2_COUNTER_UAV_FRIENDLY", COUNTER_UAV_FRIENDLY )
net.Receive( "MW2_COUNTER_UAV_ENEMY",   COUNTER_UAV_ENEMY )
