include( 'shared.lua' )

local Alpha      = 255
local alphaDelay = 0.01
local alphaTimer = 0

local EMP_TEAM  = -1
local EMP_OWNER = 0


local function DRAW_FLASH()
	surface.SetDrawColor( 255, 255, 255, Alpha )
	surface.DrawRect( 0, 0, ScrW(), ScrH() )
	if alphaTimer <= CurTime() then
		Alpha      = Alpha - 1
		alphaTimer = CurTime() + alphaDelay
	end
end


local function FireMW2EMPEffect()
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then
		if Alpha > 0 and EMP_TEAM != LocalPlayer():Team() then
			DRAW_FLASH()
		end
	else
		if EMP_OWNER != 1 then
			DRAW_FLASH()
		end
	end
end


-- FIX: MW2_EMP_FireEMP was usermessage.Hook with Team:ReadShort()
-- Now net.Receive reading net.ReadInt(16)
local function MW2_EMP_Effect()
	LocalPlayer():EmitSound( "killstreak_misc/em_pulse.wav" )
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then
		EMP_TEAM = net.ReadInt( 16 )
	end
	Alpha = 255
	hook.Add( "HUDPaint", "MW2_EMP_Effect", FireMW2EMPEffect )
end


-- FIX: MW2_EMP_OWNER was usermessage.Hook with Owner:ReadShort()
-- Now net.Receive reading net.ReadInt(16)
local function MW2_READ_OWNER()
	EMP_OWNER = net.ReadInt( 16 )
	hook.Add( "HUDPaint", "MW2_SEND_OWNER", FireMW2EMPEffect )
end


local function EMP_FRIENDLY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/mw2_emp_friendly_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


local function EMP_ENEMY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/mw2_emp_enemy_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


local function MW2_Clear_EMP()
	hook.Remove( "HUDPaint", "MW2_EMP_Effect" )
	hook.Remove( "HUDPaint", "MW2_SEND_OWNER" )
end


-- FIX: usermessage.Hook x5 -> net.Receive
net.Receive( "MW2_EMP_FireEMP",   MW2_EMP_Effect )
net.Receive( "MW2_EMP_RemoveEMP", MW2_Clear_EMP )
net.Receive( "MW2_EMP_OWNER",     MW2_READ_OWNER )
net.Receive( "MW2_EMP_FRIENDLY",  EMP_FRIENDLY )
net.Receive( "MW2_EMP_ENEMY",     EMP_ENEMY )
