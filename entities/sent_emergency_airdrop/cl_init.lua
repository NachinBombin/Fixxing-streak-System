include( "shared.lua" )


local function AIRDROP_FRIENDLY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/emergency_airdrop_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


-- FIX: usermessage.Hook x1 -> net.Receive
net.Receive( "MW2_AIRDROP_FRIENDLY", AIRDROP_FRIENDLY )
