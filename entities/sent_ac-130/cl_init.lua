include( "shared.lua" )

local friendlys = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }

local UseThermal
local isInVehicle    = false
local PlayVoice      = false
local playerInVehicle = NULL
local ThermalBlackMode = false
local AC130Idele

local AC130IdleInsideSound = Sound( "ac-130_kill_sounds/AC130_idle_inside.mp3" )

-- HUD data (updated each frame via NW vars)
local acHUDXPos = "0"
local acHUDYPos = "0"
local acHUDAGL  = "0"
local textFont  = "HUDNumber4"

local tblFonts = {
	HUDNumber  = { font = "Trebuchet MS", size = 40, weight = 900 },
	HUDNumber1 = { font = "Trebuchet MS", size = 41, weight = 900 },
	HUDNumber2 = { font = "Trebuchet MS", size = 42, weight = 900 },
	HUDNumber3 = { font = "Trebuchet MS", size = 43, weight = 900 },
	HUDNumber4 = { font = "Trebuchet MS", size = 44, weight = 900 },
	HUDNumber5 = { font = "Trebuchet MS", size = 45, weight = 900 },
}
for k, v in SortedPairs( tblFonts ) do
	surface.CreateFont( k, v )
end


local function drawAC130HUD()
	local lp = LocalPlayer()
	local textWhiteColor = Color( 255, 255, 255, 255 )
	local unusedGunColor = Color( 255, 255, 255, 127 )
	local blinkingColor  = Color( 255, 255, 255, math.sin( RealTime() * 16 ) * 127.5 + 127.5 )

	-- FIX: GetNetworkedInt/Bool -> GetNWInt/Bool
	local ac130weapon      = lp:GetNWInt( "Ac_130_weapon", 0 )
	local Is105mmReloading = lp:GetNWBool( "Ac_130_105mmReloading", false )
	local Is40mmReloading  = lp:GetNWBool( "Ac_130_40mmReloading",  false )
	local Is25mmReloading  = lp:GetNWBool( "Ac_130_25mmReloading",  false )

	if ac130weapon == 0 then
		Crosshair_105mm( Is105mmReloading, textWhiteColor )
	elseif ac130weapon == 1 then
		Crosshair_40mm( Is40mmReloading, textWhiteColor )
	elseif ac130weapon == 2 then
		Crosshair_25mm( Is25mmReloading, textWhiteColor )
	end

	local sen
	if ac130weapon == 0 then
		sen = lp:GetFOV() / 90
	elseif ac130weapon == 1 then
		sen = lp:GetFOV() / 105
	else
		sen = lp:GetFOV() / 53
	end
	local wep = lp:GetActiveWeapon()
	if IsValid( wep ) then wep.MouseSensitivity = sen end

	-- Target markers
	local allEnts = ents.GetAll()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0
	local dist    = 40

	for _, v in pairs( allEnts ) do
		local tarpos, pos
		if v:IsPlayer() and v != lp then
			tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )
			pos    = tarpos:ToScreen()
			if teamsOn then
				if v:Team() == lp:Team() then
					surface.SetDrawColor( 0, 255, 0 )
				else
					surface.SetDrawColor( 255, 0, 0 )
				end
			else
				surface.SetDrawColor( 255, 0, 0 )
			end
			surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )
		elseif v:IsNPC() then
			local cls = v:GetClass()
			if cls != "npc_bullseye" and cls != "npc_turret_floor" then
				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )
				pos    = tarpos:ToScreen()
				if table.HasValue( friendlys, cls ) then
					surface.SetDrawColor( 0, 255, 0 )
				else
					surface.SetDrawColor( 255, 0, 0 )
				end
				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )
			end
		end
	end

	-- FIX: GetNetworkedInt -> GetNWInt
	local acTime = string.ToMinutesSeconds( lp:GetNWInt( "Ac_130_Time", 0 ) )

	local sh = ScrH()
	local sw = ScrW()
	if sh >= 1000 then
		textFont = "HUDNumber5"
	elseif sh >= 900 then
		textFont = "HUDNumber4"
	elseif sh >= 700 then
		textFont = "HUDNumber3"
	elseif sh >= 600 then
		textFont = "HUDNumber2"
	else
		textFont = "HUDNumber"
	end

	draw.SimpleText( "0   A-G  MAN NARO", textFont, 25, 25,  textWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "RAY",               textFont, 25, 65,  textWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "FF 30",             textFont, 25, 105, textWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "LIR",               textFont, 25, 145, textWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "BORE",              textFont, 25, 225, textWhiteColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	draw.SimpleText( "L1514",             textFont, sw / 2,      sh - 50, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( "RDY",              textFont, sw / 2 + 20, sh - 50, textWhiteColor, TEXT_ALIGN_LEFT,  TEXT_ALIGN_TOP )
	draw.SimpleText( acTime,              textFont, sw / 4 * 3,  sh - 50, textWhiteColor, TEXT_ALIGN_LEFT,  TEXT_ALIGN_TOP )

	-- FIX: GetNetworkedInt -> GetNWInt for HUD position vars
	acHUDXPos = tostring( math.floor( lp:GetNWInt( "Ac_130_HUDXPos", 0 ) ) + 16384 )
	acHUDYPos = tostring( math.floor( lp:GetNWInt( "Ac_130_HUDYPos", 0 ) ) + 16384 )
	acHUDAGL  = tostring( math.floor( lp:GetNWInt( "Ac_130_HUDAGL",  0 ) ) + 16384 )

	draw.SimpleText( acHUDXPos,           textFont, sw - 25,  5,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( acHUDYPos,           textFont, sw - 150, 5,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	draw.SimpleText( acHUDAGL .. " AGL", textFont, sw - 25,  45, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )

	if UseThermal then
		if ThermalBlackMode then
			draw.SimpleText( "BHOT", textFont, sw - 100, 85, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		else
			draw.SimpleText( "WHOT", textFont, sw - 100, 85, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		end
	end

	if sh >= 750 then
		draw.SimpleText( "N", textFont, sw - 25, sh / 2 - 250, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "T", textFont, sw - 25, sh / 2 - 200, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "S", textFont, sw - 25, sh / 2 - 100, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "F", textFont, sw - 25, sh / 2 - 50,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "Q", textFont, sw - 25, sh / 2 + 50,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "Z", textFont, sw - 25, sh / 2 + 100, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "T", textFont, sw - 25, sh / 2 + 200, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "G", textFont, sw - 25, sh / 2 + 250, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "T", textFont, sw - 25, sh / 2 + 300, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	else
		draw.SimpleText( "N", textFont, sw - 25, sh / 2 - 200, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "T", textFont, sw - 25, sh / 2 - 160, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "S", textFont, sw - 25, sh / 2 - 80,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "F", textFont, sw - 25, sh / 2 - 40,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "Q", textFont, sw - 25, sh / 2 + 40,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "Z", textFont, sw - 25, sh / 2 + 80,  textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "T", textFont, sw - 25, sh / 2 + 160, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "G", textFont, sw - 25, sh / 2 + 200, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
		draw.SimpleText( "T", textFont, sw - 25, sh / 2 + 240, textWhiteColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	end

	if ac130weapon == 0 then
		draw.SimpleText( "105mm", textFont, 25, sh - 50,  blinkingColor,  TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( "40mm",  textFont, 25, sh - 90,  unusedGunColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( "25mm",  textFont, 25, sh - 130, unusedGunColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	elseif ac130weapon == 1 then
		draw.SimpleText( "105mm", textFont, 25, sh - 50,  unusedGunColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( "40mm",  textFont, 25, sh - 90,  blinkingColor,  TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( "25mm",  textFont, 25, sh - 130, unusedGunColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	elseif ac130weapon == 2 then
		draw.SimpleText( "105mm", textFont, 25, sh - 50,  unusedGunColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( "40mm",  textFont, 25, sh - 90,  unusedGunColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		draw.SimpleText( "25mm",  textFont, 25, sh - 130, blinkingColor,  TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	end
end


function Crosshair_105mm( isReloading, whiteColor )
	local width              = 120
	local height             = 60
	local lineLength         = 100
	local cornerLength       = 35
	local distanceFromCenter = 250
	local centerX = ScrW() / 2
	local centerY = ScrH() / 2

	if isReloading then
		surface.SetDrawColor( 255, 255, 255, math.sin( RealTime() * 8 ) * 127.5 + 127.5 )
	else
		surface.SetDrawColor( whiteColor )
	end

	surface.DrawOutlinedRect( centerX - width / 2, centerY - height / 2, width, height )
	surface.DrawLine( centerX - width / 2,  centerY, (centerX - width / 2)  - lineLength, centerY )
	surface.DrawLine( centerX + width / 2,  centerY, (centerX + width / 2)  + lineLength, centerY )
	surface.DrawLine( centerX, centerY - height / 2, centerX, (centerY - height / 2) - lineLength )
	surface.DrawLine( centerX, centerY + height / 2, centerX, (centerY + height / 2) + lineLength )

	surface.DrawLine( centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY - distanceFromCenter )
	surface.DrawLine( centerX - distanceFromCenter, centerY - distanceFromCenter, centerX - distanceFromCenter, (centerY - distanceFromCenter) + cornerLength )
	surface.DrawLine( centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY + distanceFromCenter )
	surface.DrawLine( centerX - distanceFromCenter, centerY + distanceFromCenter, centerX - distanceFromCenter, (centerY + distanceFromCenter) - cornerLength )
	surface.DrawLine( centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY - distanceFromCenter )
	surface.DrawLine( centerX + distanceFromCenter, centerY - distanceFromCenter, centerX + distanceFromCenter, (centerY - distanceFromCenter) + cornerLength )
	surface.DrawLine( centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY + distanceFromCenter )
	surface.DrawLine( centerX + distanceFromCenter, centerY + distanceFromCenter, centerX + distanceFromCenter, (centerY + distanceFromCenter) - cornerLength )
end


function Crosshair_40mm( isReloading, whiteColor )
	local width      = 60
	local height     = 60
	local hlineLength = 280
	local vlineLength = 225
	local centerX = ScrW() / 2
	local centerY = ScrH() / 2

	if isReloading then
		surface.SetDrawColor( 255, 255, 255, math.sin( RealTime() * 8 ) * 127.5 + 127.5 )
	else
		surface.SetDrawColor( whiteColor )
	end

	surface.DrawLine( centerX - width / 2, centerY, (centerX - width / 2) - hlineLength, centerY )
	surface.DrawLine( centerX + width / 2, centerY, (centerX + width / 2) + hlineLength, centerY )

	surface.DrawLine( centerX - width / 2 - 40,     centerY - 10, centerX - width / 2 - 40,     centerY + 10 )
	surface.DrawLine( centerX - width / 2 - 40 * 3, centerY - 10, centerX - width / 2 - 40 * 3, centerY + 10 )
	surface.DrawLine( centerX - width / 2 - 40 * 5, centerY - 10, centerX - width / 2 - 40 * 5, centerY + 10 )
	surface.DrawLine( centerX - width / 2 - 40 * 7, centerY - 20, centerX - width / 2 - 40 * 7, centerY + 20 )

	surface.DrawLine( centerX + width / 2 + 40,     centerY - 10, centerX + width / 2 + 40,     centerY + 10 )
	surface.DrawLine( centerX + width / 2 + 40 * 3, centerY - 10, centerX + width / 2 + 40 * 3, centerY + 10 )
	surface.DrawLine( centerX + width / 2 + 40 * 5, centerY - 10, centerX + width / 2 + 40 * 5, centerY + 10 )
	surface.DrawLine( centerX + width / 2 + 40 * 7, centerY - 20, centerX + width / 2 + 40 * 7, centerY + 20 )

	surface.DrawLine( centerX, centerY - height / 2, centerX, (centerY - height / 2) - vlineLength )
	surface.DrawLine( centerX - 10, centerY - height / 2 - 45,      centerX + 10, centerY - height / 2 - 45 )
	surface.DrawLine( centerX - 10, centerY - height / 2 - 45 * 3,  centerX + 10, centerY - height / 2 - 45 * 3 )
	surface.DrawLine( centerX - 20, centerY - height / 2 - 45 * 5,  centerX + 20, centerY - height / 2 - 45 * 5 )

	surface.DrawLine( centerX, centerY + height / 2, centerX, (centerY + height / 2) + vlineLength )
	surface.DrawLine( centerX - 10, centerY + height / 2 + 45,     centerX + 10, centerY + height / 2 + 45 )
	surface.DrawLine( centerX - 10, centerY + height / 2 + 45 * 3, centerX + 10, centerY + height / 2 + 45 * 3 )
	surface.DrawLine( centerX - 20, centerY + height / 2 + 45 * 5, centerX + 20, centerY + height / 2 + 45 * 5 )
end


function Crosshair_25mm( isReloading, whiteColor )
	local lineLength         = 100
	local cornerLength       = 35
	local distanceFromCenter = 150
	local lineDistance       = 6
	local centerX = ScrW() / 2
	local centerY = ScrH() / 2

	if isReloading then
		surface.SetDrawColor( 255, 255, 255, math.sin( RealTime() * 8 ) * 127.5 + 127.5 )
	else
		surface.SetDrawColor( whiteColor )
	end

	surface.DrawLine( centerX - lineDistance, centerY, (centerX - lineDistance) - lineLength, centerY )
	surface.DrawLine( centerX + lineDistance, centerY, (centerX + lineDistance) + lineLength, centerY )
	surface.DrawLine( centerX, centerY + lineDistance, centerX, (centerY + lineDistance) + lineLength )

	surface.DrawLine( centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY - distanceFromCenter )
	surface.DrawLine( centerX - distanceFromCenter, centerY - distanceFromCenter, centerX - distanceFromCenter, (centerY - distanceFromCenter) + cornerLength )
	surface.DrawLine( centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY + distanceFromCenter )
	surface.DrawLine( centerX - distanceFromCenter, centerY + distanceFromCenter, centerX - distanceFromCenter, (centerY + distanceFromCenter) - cornerLength )
	surface.DrawLine( centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY - distanceFromCenter )
	surface.DrawLine( centerX + distanceFromCenter, centerY - distanceFromCenter, centerX + distanceFromCenter, (centerY - distanceFromCenter) + cornerLength )
	surface.DrawLine( centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY + distanceFromCenter )
	surface.DrawLine( centerX + distanceFromCenter, centerY + distanceFromCenter, centerX + distanceFromCenter, (centerY + distanceFromCenter) - cornerLength )

	surface.DrawLine( centerX + 6,  centerY + 6,  centerX + 16, centerY + 6  )
	surface.DrawLine( centerX + 6,  centerY + 6,  centerX + 6,  centerY + 16 )
	surface.DrawLine( centerX + 16, centerY + 16, centerX + 26, centerY + 16 )
	surface.DrawLine( centerX + 16, centerY + 16, centerX + 16, centerY + 26 )
	surface.DrawLine( centerX + 26, centerY + 26, centerX + 36, centerY + 26 )
	surface.DrawLine( centerX + 26, centerY + 26, centerX + 26, centerY + 36 )
	surface.DrawLine( centerX + 36, centerY + 36, centerX + 46, centerY + 36 )
	surface.DrawLine( centerX + 36, centerY + 36, centerX + 36, centerY + 46 )
	surface.DrawLine( centerX + 46, centerY + 46, centerX + 56, centerY + 46 )
	surface.DrawLine( centerX + 46, centerY + 46, centerX + 46, centerY + 56 )
	surface.DrawLine( centerX + 56, centerY + 56, centerX + 66, centerY + 56 )
	surface.DrawLine( centerX + 56, centerY + 56, centerX + 56, centerY + 66 )
end


local tick = 0
function ENT:Think()
	if tick + 1 <= CurTime() then
		tick = CurTime()
		if not LocalPlayer():InVehicle() then
			self:StopSound( "ac-130_kill_sounds/AC130_idle_inside.mp3" )
			return
		end
		self:EmitSound( "ac-130_kill_sounds/AC130_idle_inside.mp3", 350, 100 )
	end
end


local sound105mm = Sound( "killstreak_rewards/ac-130_105mm_fire.wav" )
local sound40mm  = Sound( "killstreak_rewards/ac-130_40mm_fire.wav" )
local sound25mm  = Sound( "killstreak_rewards/ac-130_25mm_fire.wav" )
local sndTbl = { ["105mm"] = sound105mm, ["40mm"] = sound40mm, ["25mm"] = sound25mm }

net.Receive( "AC130_GunSound", function()
	local str = net.ReadString()
	if sndTbl[ str ] then
		LocalPlayer():EmitSound( sndTbl[ str ], 400, 100 )
		LocalPlayer():GetViewEntity():EmitSound( sndTbl[ str ], 400, 100 )
	end
end )


local function screenContrastWHOT()
	DrawColorModify({
		["$pp_colour_addr"]       = 0,
		["$pp_colour_addg"]       = 0,
		["$pp_colour_addb"]       = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"]   = 1,
		["$pp_colour_colour"]     = 0,
		["$pp_colour_mulr"]       = 0,
		["$pp_colour_mulg"]       = 0,
		["$pp_colour_mulb"]       = 0,
	})
end

local function screenContrastBHOT()
	DrawColorModify({
		["$pp_colour_addr"]       = 0,
		["$pp_colour_addg"]       = 0,
		["$pp_colour_addb"]       = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"]   = 2,
		["$pp_colour_colour"]     = 0,
		["$pp_colour_mulr"]       = 0,
		["$pp_colour_mulg"]       = 0,
		["$pp_colour_mulb"]       = 0,
	})
end


local DefMats = {}
local DefClrs = {}
local material = "thermal/thermal.vmt"

local function ThermalVision()
	if LocalPlayer():KeyPressed( IN_RELOAD ) then
		ThermalBlackMode = not ThermalBlackMode
	end
	local targets = {}
	table.Add( targets, player.GetAll() )
	table.Add( targets, ents.FindByClass( "npc_*" ) )
	for _, v in pairs( targets ) do
		local r, g, b, a = v:GetColor()
		local entmat     = v:GetMaterial()
		if v:IsNPC() or v:IsPlayer() then
			if ThermalBlackMode == false then
				if not ( r == 255 and g == 255 and b == 255 and a == 255 ) then
					DefClrs[ v ] = Color( tonumber( r ) or 255, tonumber( g ) or 255, tonumber( b ) or 255, tonumber( a ) or 255 )
					v:SetColor( Color( 255, 255, 255, 255 ) )
				end
			else
				if v:IsNPC() then
					if not ( r == 0 and g == 0 and b == 0 ) then
						DefClrs[ v ] = Color( tonumber( r ) or 255, tonumber( g ) or 255, tonumber( b ) or 255, tonumber( a ) or 255 )
						v:SetColor( Color( 0, 0, 0, 255 ) )
					end
				elseif v:IsPlayer() then
					if v:Alive() then
						if not ( r == 0 and g == 0 and b == 0 ) then
							DefClrs[ v ] = Color( tonumber( r ) or 255, tonumber( g ) or 255, tonumber( b ) or 255, tonumber( a ) or 255 )
							v:SetColor( Color( 0, 0, 0, 255 ) )
						end
					else
						v:SetColor( Color( 255, 255, 255, 255 ) )
					end
				end
			end
			if entmat ~= material then
				DefMats[ v ] = entmat
				v:SetMaterial( material )
			end
		end
	end
	if ThermalBlackMode then
		hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT", screenContrastBHOT )
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT" )
	else
		hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT", screenContrastWHOT )
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT" )
	end
end

local function removeThermalVision()
	hook.Remove( "RenderScene", "ThermalVision" )
	for ent, mat in pairs( DefMats ) do
		if ent:IsValid() then ent:SetMaterial( mat ) end
	end
	for ent, clr in pairs( DefClrs ) do
		if ent:IsValid() then ent:SetColor( Color( clr.r, clr.g, clr.b, clr.a ) ) end
	end
	DefMats = {}
	DefClrs = {}
end


local function hideDefaultHUD( name )
	for _, v in ipairs { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo" } do
		if name == v then return false end
	end
end


local function setUpHUD()
	ThermalBlackMode = false
	hook.Add( "HUDShouldDraw", "hideDefaultHUD", hideDefaultHUD )
	UseThermal = true
	if UseThermal then
		hook.Add( "RenderScene", "ThermalVision", ThermalVision )
	end
	hook.Add( "HUDPaint", "TargetEffect", drawAC130HUD )
	timer.Simple( 3, function() PlayVoice = true end )
	AC130Idele = CreateSound( LocalPlayer(), AC130IdleInsideSound )
	AC130Idele:Play()
end

local function removeHUD()
	if AC130Idele then AC130Idele:Stop() end
	hook.Remove( "HUDShouldDraw", "hideDefaultHUD" )
	if ThermalBlackMode then
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT" )
	else
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT" )
	end
	hook.Remove( "HUDPaint", "TargetEffect" )
	if UseThermal then removeThermalVision() end
	local wep = LocalPlayer():GetActiveWeapon()
	if IsValid( wep ) then wep.MouseSensitivity = 1 end
end

local function ErrorMessage()
	local ACE = vgui.Create( "DFrame" )
	ACE:SetSize( 357, 66 )
	ACE:Center()
	ACE:SetTitle( "AC-130 Error" )
	ACE:SetBackgroundBlur( true )
	ACE:MakePopup()
	local lbl = vgui.Create( "DLabel", ACE )
	lbl:SetPos( 18, 35 )
	lbl:SetText( "You can't use the AC-130 in this map. Reason: Not enough room" )
	lbl:SizeToContents()
end

local function PlayAC130KillSound()
	-- FIX: was usermessage callback reading um:ReadLong() -> now net.Receive reading net.ReadInt()
	local kills = net.ReadInt( 32 )
	local soundName
	if kills >= 3 and kills <= 5 then
		soundName = ( math.random( 0, 1 ) == 0 ) and "nice" or "you_got_him"
	elseif kills >= 6 and kills <= 9 then
		soundName = ( math.random( 0, 1 ) == 0 ) and "kaboom" or "thats_a_hit"
	elseif kills >= 10 then
		soundName = "little_pieces"
	end
	if soundName then
		surface.PlaySound( "ac-130_kill_sounds/" .. soundName .. ".wav" )
	end
end

local function LOCKHEED_FRIENDLY()
	surface.PlaySound(
		"killstreak_rewards/ac-130_friendly_inbound"
		.. LocalPlayer():GetNWString( "MW2TeamSound", "" )
		.. ".wav"
	)
end

local function LOCKHEED_ENEMY()
	surface.PlaySound(
		"killstreak_rewards/ac-130_enemy_inbound"
		.. LocalPlayer():GetNWString( "MW2TeamSound", "" )
		.. ".wav"
	)
end


function findGround()
	local minheight  = -16384
	local startPos   = LocalPlayer():GetPos()
	local filterList = { LocalPlayer() }
	local trace = { start = startPos, endpos = Vector( 0, 0, minheight ), filter = filterList }
	local bool = true
	local maxNumber      = 0
	local groundLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitWorld then
			groundLocation = td.HitPos.z
			bool = false
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then
			MsgN( "Reached max number here, no luck in finding the ground" )
			bool = false
		end
	end
	return groundLocation
end


-- FIX: ALL usermessage.Hook (removed API) -> net.Receive
net.Receive( "MW2_AC130_Kill_Sounds", PlayAC130KillSound )
net.Receive( "AC_130_SetUpHUD",      setUpHUD )
net.Receive( "AC_130_RemoveHUD",     removeHUD )
net.Receive( "AC_130_Error",         ErrorMessage )
net.Receive( "MW2_LOCKHEED_FRIENDLY", LOCKHEED_FRIENDLY )
net.Receive( "MW2_LOCKHEED_ENEMY",   LOCKHEED_ENEMY )
