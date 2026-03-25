include( 'shared.lua' )

local Countdown = Sound( "killstreak_rewards/tactical_nuke_countdown.wav" )

-- FIX: surface.CreateFont signature was wrong (positional args) -> table form
surface.CreateFont( "MW2Font", {
	font   = "BankGothic Md BT",
	size   = 20,
	weight = 400,
	antialias = true,
} )

local function drawNukeCountDownHUD()
	-- GetGlobalString is still valid (read-only convar replication)
	local nukeTime = GetGlobalString( "MW2_Nuke_CountDown_Timer" )
	local nukeString
	if string.len( nukeTime ) > 3 then
		nukeString = "0:0" .. string.sub( nukeTime, 1, 3 )
	else
		nukeString = "0:0" .. nukeTime
	end

	surface.SetTexture( surface.GetTextureID( "VGUI/killstreaks/animated/tactical_nuke" ) )
	surface.SetDrawColor( 255, 255, 255 )
	surface.DrawTexturedRect( 200 - 32, 20, 64, 64 )
	surface.SetFont( "MW2Font" )
	surface.SetTextColor( 255, 255, 255 )
	surface.SetTextPos( 200 - 20, 15 + 32 )
	surface.DrawText( nukeString )
end


local function NukeSetUpHUD()
	hook.Add( "HUDPaint", "NukeCountDownEffect", drawNukeCountDownHUD )
	surface.PlaySound( Countdown )
end


local function NukeRemoveHUD()
	hook.Remove( "HUDPaint", "NukeCountDownEffect" )
end


local function NUKE_FRIENDLY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/tactical_nuke_friendly_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


local function NUKE_ENEMY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/tactical_nuke_enemy_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


-- FIX: usermessage.Hook x4 -> net.Receive
net.Receive( "MW2_Nukes_SetUpHUD", NukeSetUpHUD )
net.Receive( "MW2_Nuke_RemoveHUD", NukeRemoveHUD )
net.Receive( "MW2_NUKE_FRIENDLY",  NUKE_FRIENDLY )
net.Receive( "MW2_NUKE_ENEMY",     NUKE_ENEMY )
