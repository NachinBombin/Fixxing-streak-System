if not CLIENT then return end

local centerX          = ScrW() / 2
local centerY          = ScrH() / 2
local picturePossitonX = centerX - 256
local picturePossitonY = 0
local curKillIconX     = ScrW() - 100
local curKillIconY     = ScrH() - 150
local streak           = ""
local oldId            = 0
local showNewKillstreak = false
local curStreak        = nil
local id               = 0


local function playAcquiredSound( soundName )
	if soundName == "stealth_bomber" then
		soundName = "precision_airstrike"
	end
	if soundName == "mw2_sentry_gun_package" then
		return
	end
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/" .. soundName .. "_acquired" .. LocalPlayer():GetNWString( "MW2TeamSound" ) .. ".wav" )
end


local function DISPLAY_FRIEND( FRIEND )
	if GetConVar( "MW2_DISPLAY_FRIEND" ):GetInt() == 0 then return end
	if GetConVar( "MW2_KILLSTREAKS_ENABLED" ):GetInt() == 0 then return end
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() == 0 then return end
	if FRIEND:Team() != LocalPlayer():Team() then return end
	if not IsValid( FRIEND ) then return end
	if FRIEND == LocalPlayer() then return end
	if not FRIEND:Alive() then return end

	local DISTANCE = LocalPlayer():GetPos():Distance( FRIEND:GetPos() )
	if DISTANCE >= 1000 then return end

	cam.Start3D( EyePos(), EyeAngles() )
		local ANGLE = LocalPlayer():EyeAngles()
		ANGLE:RotateAroundAxis( ANGLE:Forward(), 90 )
		ANGLE:RotateAroundAxis( ANGLE:Right(), 90 )
		local POSITION = FRIEND:GetPos() + Vector( 0, 0, FRIEND:OBBMaxs().z + 10 )
		cam.Start3D2D( POSITION, Angle( 0, ANGLE.y, 90 ), 0.5 )
			draw.DrawText( "FRIENDLY", "Default", 2, 2, Color( 0, 255, 0 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
	cam.End3D()
end

hook.Add( "PostPlayerDraw", "Display_Friend", DISPLAY_FRIEND )


local function drawAddedKillStreak()
	if curStreak == nil or id <= oldId then
		-- FIX: GetNetworkedString -> GetNWString
		local str = LocalPlayer():GetNWString( "MW2NewKillstreak" )
		local Sep = string.Explode( "+", str )
		curStreak = Sep[1]
		if Sep[2] != nil then id = tonumber( Sep[2] ) end
	elseif curStreak != nil and id > oldId then
		streak = curStreak
		playAcquiredSound( streak )
		showNewKillstreak = true
		timer.Create( "AddedKillstreaks_Timer", 2, 1, function()
			showNewKillstreak = false
		end )
		oldId = id
	end

	if not showNewKillstreak then return end
	if streak == "none" or streak == nil then return end

	surface.SetTexture( surface.GetTextureID( "VGUI/killstreaks/" .. streak ) )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( picturePossitonX, picturePossitonY, 512, 256 )
end
hook.Add( "HUDPaint", "DrawAddedMW2KillStreaks", drawAddedKillStreak )


local function drawAvailableKillStreak()
	-- FIX: GetNetworkedString -> GetNWString
	local availableStreak = LocalPlayer():GetNWString( "CurrentMW2KillStreak" )
	if availableStreak == nil or availableStreak == "none" or availableStreak == "" then return end
	local texPath = "VGUI/killstreaks/animated/" .. availableStreak
	surface.SetTexture( surface.GetTextureID( texPath ) )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( curKillIconX, curKillIconY, 44, 44 )
end
hook.Add( "HUDPaint", "DrawAvaliabeMW2KillStreaks", drawAvailableKillStreak )


-- FIX: net handler for ShowKillstreakSpawnError (replaces removed umsg system)
net.Receive( "ShowKillstreakSpawnError", function()
	chat.AddText( Color( 255, 80, 0 ), "[ MW2 KILLSTREAKS ]:  Cannot deploy - no sky access at your location!" )
end )
