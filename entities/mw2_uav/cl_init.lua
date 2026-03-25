include( 'shared.lua' )

local sweepTexture = surface.GetTextureID( "VGUI/killStreak_misc/uavsweep" )

local isActive    = false
local totalActive = 0

local uavBoxSize  = 250
local x           = 20
local y           = 20
local width       = uavBoxSize
local height      = uavBoxSize
local edge        = 270
local sweepPos    = 0
local cameraPos   = 1000
local centerX     = x + width  / 2
local centerY     = y + height / 2
local scaleFactor = ( ( cameraPos * 2 ) / 1.5 ) / uavBoxSize
local lineLength  = 10

local Friendly_Entity_Position = {}
local Enemy_Entity_Position    = {}

local Friends = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }

local UavSweepBase = 3
local UavBarBase   = 0.005
local UavSweepNew  = 0
local UavBarNew    = 0

local Scale            = Vector( 10, 10 )
local Segment_Distance = 360 / ( 2 * math.pi * math.max( Scale.x, Scale.y ) / 2 )


local function DRAW_FRIENDLIES( Local_Player )
	for Key, Value in pairs( Friendly_Entity_Position ) do
		local pos = Local_Player:GetPos() - Value
		local newX    = pos.x / scaleFactor
		local newY    = pos.y / scaleFactor
		local targetX = math.Clamp( centerY + newY, 20, 270 )
		local targetY = math.Clamp( centerX + newX, 20, 270 )
		draw.RoundedBox( 4, targetX, targetY, 20, 20, Color( 0, 255, 0 ) )
	end
end


local function DRAW_ENEMIES( Local_Player )
	for Key, Value in pairs( Enemy_Entity_Position ) do
		local pos = Local_Player:GetPos() - Value
		local newX    = pos.x / scaleFactor
		local newY    = pos.y / scaleFactor
		local targetX = math.Clamp( centerY + newY, 20, 270 )
		local targetY = math.Clamp( centerX + newX, 20, 270 )
		draw.RoundedBox( 4, targetX, targetY, 20, 20, Color( 255, 0, 0 ) )
	end
end


local function DRAW_MAP()
	local Local_Player = LocalPlayer()
	local CamData = {
		angles        = Angle( 90, 0, 0 ),
		origin        = Local_Player:GetPos() + Vector( 0, 0, cameraPos ),
		x             = x,
		y             = y,
		w             = width,
		h             = height,
		drawviewmodel = false,
	}
	render.RenderView( CamData )

	local aimVector = Local_Player:GetAimVector()
	draw.RoundedBox( 4, centerX - 4, centerY - 4, 8, 8, Color( 0, 0, 255 ) )
	surface.DrawLine( centerX, centerY, centerX + ( lineLength * ( aimVector.y * -1 ) ), centerY + ( lineLength * ( aimVector.x * -1 ) ) )

	DRAW_FRIENDLIES( Local_Player )
	DRAW_ENEMIES( Local_Player )

	if sweepPos > 20 then
		surface.SetTexture( sweepTexture )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawTexturedRect( sweepPos, 20, 16, uavBoxSize )
	end
end


local function startHUDHook()
	hook.Add( "HUDPaint", "UAV", DRAW_MAP )
end


function UavSweep()
	sweepPos = edge - 8
	local Local_Player = LocalPlayer()
	Friendly_Entity_Position = {}
	Enemy_Entity_Position    = {}

	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	for Key, Value in pairs( ents.GetAll() ) do
		if Value:IsNPC() and table.HasValue( Friends, Value:GetClass() ) and Value:GetClass() != "npc_bullseye" and Value:GetClass() != "npc_turret_floor"
			or ( Value:IsPlayer() and Value:Team() == Local_Player:Team() and Value != Local_Player and teamsOn ) then
			Friendly_Entity_Position[ Key ] = Value:GetPos()
		elseif Value:IsNPC() and not table.HasValue( Friends, Value:GetClass() ) and Value:GetClass() != "npc_bullseye" and Value:GetClass() != "npc_turret_floor"
			or ( Value:IsPlayer() and Value:Team() != Local_Player:Team() and Value != Local_Player and teamsOn ) then
			Enemy_Entity_Position[ Key ] = Value:GetPos()
		elseif Value:IsPlayer() and Value != Local_Player and not teamsOn then
			Enemy_Entity_Position[ Key ] = Value:GetPos()
		end
	end

	startHUDHook()
end


function moveSweep()
	sweepPos = sweepPos - 4
end


local function REMOVE_UAV()
	timer.Stop( "UAV_redrawTimer" )
	timer.Stop( "UavSweeper" )
	timer.Stop( "UAV_stopTimer" )
	hook.Remove( "HUDPaint", "UAV" )
	hook.Remove( "HUDPaint", "Crosshair" )
	totalActive = 0
	isActive    = false
end


local function UAV_FRIENDLY()
	totalActive = totalActive + 1
	if isActive then
		if totalActive <= 3 then
			UavSweepNew = UavSweepBase - ( totalActive / 1.25 )
			UavBarNew   = UavBarBase * ( totalActive + 2 )
			timer.Adjust( "UAV_redrawTimer", UavSweepNew, 0, UavSweep )
			timer.Adjust( "UavSweeper",      UavBarNew,   0, moveSweep )
		end
		return
	end

	UavSweep()

	-- FIX: ScrW/ScrH must be called at runtime, not at file scope
	hook.Add( "HUDPaint", "Crosshair", function()
		local Center = Vector( ScrW() / 2, ScrH() / 2, 0 )
		if ConVarExists( "vj_hud_disablegmodcross" ) then
			if GetConVarNumber( "crosshair" ) == 1 and GetConVarNumber( "vj_hud_disablegmodcross" ) == 0 then
				surface.SetDrawColor( 255, 255, 255 )
				for A = 0, 360 - Segment_Distance, Segment_Distance do
					surface.DrawLine( Center.x + math.cos( math.rad( A ) ) * Scale.x, Center.y - math.sin( math.rad( A ) ) * Scale.y, Center.x + math.cos( math.rad( A + Segment_Distance ) ) * Scale.x, Center.y - math.sin( math.rad( A + Segment_Distance ) ) * Scale.y )
				end
			end
		else
			if GetConVarNumber( "crosshair" ) == 1 then
				surface.SetDrawColor( 255, 255, 255 )
				for A = 0, 360 - Segment_Distance, Segment_Distance do
					surface.DrawLine( Center.x + math.cos( math.rad( A ) ) * Scale.x, Center.y - math.sin( math.rad( A ) ) * Scale.y, Center.x + math.cos( math.rad( A + Segment_Distance ) ) * Scale.x, Center.y - math.sin( math.rad( A + Segment_Distance ) ) * Scale.y )
				end
			end
		end
	end )

	timer.Create( "UAV_redrawTimer", UavSweepBase, 0, UavSweep )
	timer.Create( "UavSweeper",      UavBarBase,   0, moveSweep )
	isActive = true

	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/uav_friendly_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


local function UAV_ENEMY()
	-- FIX: GetNetworkedString -> GetNWString
	surface.PlaySound( "killstreak_rewards/uav_enemy_inbound" .. LocalPlayer():GetNWString( "MW2TeamSound", "" ) .. ".wav" )
end


-- FIX: usermessage.Hook x3 -> net.Receive
net.Receive( "MW2_UAV_FRIENDLY", UAV_FRIENDLY )
net.Receive( "MW2_UAV_ENEMY",   UAV_ENEMY )
net.Receive( "MW2_UAV_END",     REMOVE_UAV )
