include( 'shared.lua' )


local function PACKAGE_FRIENDLY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/care_package_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


-- FIX: usermessage.Hook x1 -> net.Receive
net.Receive( "MW2_PACKAGE_FRIENDLY", PACKAGE_FRIENDLY )
