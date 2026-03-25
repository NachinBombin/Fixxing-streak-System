include( 'shared.lua' )

local lpl
local fullWidth = 175
local width     = 0
local height    = 10
local offset    = 4
local DisFromCrate = CreateConVar( "Supply_CrateDistance", "50" )
local setHook   = false


local function getEntityWidthLengthHeight( ent )
	local min, max = ent:WorldSpaceAABB()
	return max - min
end


local function drawProgressBar()
	if width > fullWidth then width = fullWidth end

	-- FIX: ScrW/ScrH must be called at draw time, not file scope
	local sw = ScrW()
	local sh = ScrH()
	local x  = sw / 2 - fullWidth / 2
	local y  = sh / 2 - height / 2

	draw.SimpleText( "Capturing...", "MW2Font", sw / 2, sh / 2 - ( height + offset ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	surface.SetDrawColor( 50, 50, 50, 150 )
	surface.DrawRect( x - offset / 2, y - offset / 2, fullWidth + offset, height + offset )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( x, y, width, height )

	-- FIX: GetNetworkedBool -> GetNWBool; nil guard -> IsValid
	if not IsValid( lpl ) or not lpl:GetNWBool( "SupplyCrate_DrawBarBool", false ) then
		timer.Stop( "SupplyCrate_ProgressBarTimer" )
		hook.Remove( "HUDPaint", "SupplyCrate_ProgressBar" )
		hook.Remove( "Tick",     "Check_Player" )
		return
	end

	if width >= fullWidth then
		net.Start( "SupplyCrate_GiveReward" )
		net.SendToServer()
		timer.Stop( "SupplyCrate_ProgressBarTimer" )
		hook.Remove( "HUDPaint", "SupplyCrate_ProgressBar" )
		hook.Remove( "HUDPaint", "SupplyCrate_PopUpText" )
		hook.Remove( "Tick",     "Check_Player" )
	end
end


local function increment()
	if not IsValid( lpl ) then return end
	-- FIX: GetNetworkedFloat -> GetNWFloat
	width = width + lpl:GetNWFloat( "SupplyCrate_Inc", 0 )
end


local function startProgressBar()
	lpl   = LocalPlayer()
	width = 0
	hook.Add( "HUDPaint", "SupplyCrate_ProgressBar", drawProgressBar )
	timer.Create( "SupplyCrate_ProgressBarTimer", 0.01, fullWidth, increment )
end


local function setUp()
	timer.Simple( 0.05, startProgressBar )
end


local function checkPlayerInput()
	hook.Add( "Tick", "Check_Player", function()
		if LocalPlayer():KeyDown( IN_USE ) then
			net.Start( "START_CAPTURING" )
			net.SendToServer()
		else
			net.Start( "STOP_CAPTURING" )
			net.SendToServer()
		end
	end )
end


-- FIX: usermessage.Hook x2 -> net.Receive
net.Receive( "SupplyCrate_DrawBar",  setUp )
net.Receive( "CHECK_PLAYER_INPUT",   checkPlayerInput )


function ENT:Draw()
	self:DrawModel()

	-- FIX: self:GetNetworkedString -> self:GetNWString
	local reward = self:GetNWString( "SupplyCrate_Reward", "" )
	if reward == "" then return end

	local tex
	if reward == "ammo" then
		tex = Material( "vgui/killstreaks/ammo" )
	else
		tex = Material( "vgui/killstreaks/animated/" .. reward )
	end

	local wlh    = getEntityWidthLengthHeight( self )
	local entPos = self:GetPos() + Vector( 0, 0, wlh.z + 8 )

	cam.Start3D2D( entPos, Angle( 0, LocalPlayer():GetAngles().y - 90, 90 ), 1 )
		surface.SetMaterial( tex )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawTexturedRect( -8, -8, 16, 16 )
	cam.End3D2D()

	local tab = ents.FindInSphere( self:GetPos(), DisFromCrate:GetInt() )
	if table.HasValue( tab, LocalPlayer() ) and not setHook then
		local function drawPopUpText()
			local str
			if string.find( reward, "_" ) then
				local sep = string.Explode( "_", reward )
				str = "a " .. sep[1] .. " " .. sep[2]
			elseif reward == "ammo" then
				str = reward
			else
				str = "a " .. reward
			end
			draw.SimpleText( "Press and hold \"USE\" for " .. str, "MW2Font", ScrW() / 2, ScrH() / 2 + ( height + offset ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		hook.Add( "HUDPaint", "SupplyCrate_PopUpText", drawPopUpText )
		setHook = true
	elseif not table.HasValue( tab, LocalPlayer() ) then
		hook.Remove( "HUDPaint", "SupplyCrate_PopUpText" )
		setHook = false
	end
end
