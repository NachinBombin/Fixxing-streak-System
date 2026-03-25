include( "shared.lua" )

local Friendly = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }


local function drawHUD()
	render_Crosshair()

	local allEnts = ents.GetAll()
	local lp      = LocalPlayer()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	for _, v in pairs( allEnts ) do
		local tarpos, pos
		local dist = 25

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
			tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )
			pos    = tarpos:ToScreen()
			local cls = v:GetClass()
			if cls == "npc_bullseye" or cls == "npc_turret_floor" then
				-- skip sentry/turret markers
			elseif table.HasValue( Friendly, cls ) then
				surface.SetDrawColor( 0, 255, 0 )
				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )
			else
				surface.SetDrawColor( 255, 0, 0 )
				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )
			end
		end
	end
	return true
end


local width              = 120
local height             = 60
local lineLength         = 100
local cornorLength       = 35
local distanceFromCenter = 350

function render_Crosshair()
	-- FIX: ScrW/ScrH called live each frame (not at file-scope before first frame)
	local centerX = ScrW() / 2
	local centerY = ScrH() / 2

	surface.SetDrawColor( 150, 150, 150 )
	surface.DrawOutlinedRect( centerX - width / 2, centerY - height / 2, width, height )

	surface.DrawLine( centerX - width / 2,              centerY,                       (centerX - width / 2) - lineLength,  centerY )
	surface.DrawLine( centerX + width / 2,              centerY,                       (centerX + width / 2) + lineLength,  centerY )
	surface.DrawLine( centerX,                          centerY - height / 2,          centerX,                             (centerY - height / 2) - lineLength )
	surface.DrawLine( centerX,                          centerY + height / 2,          centerX,                             (centerY + height / 2) + lineLength )

	surface.DrawLine( centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornorLength, centerY - distanceFromCenter )
	surface.DrawLine( centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter),               (centerY - distanceFromCenter) + cornorLength )

	surface.DrawLine( centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornorLength, centerY + distanceFromCenter )
	surface.DrawLine( centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter),               (centerY + distanceFromCenter) - cornorLength )

	surface.DrawLine( centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornorLength, centerY - distanceFromCenter )
	surface.DrawLine( centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter),               (centerY - distanceFromCenter) + cornorLength )

	surface.DrawLine( centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornorLength, centerY + distanceFromCenter )
	surface.DrawLine( centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter),               (centerY + distanceFromCenter) - cornorLength )
end


local missileThrustSound    = Sound( "killstreak_rewards/predator_missile_thruster.wav" )
local missileExplosionSound = Sound( "killstreak_rewards/predator_missile_explosion.wav" )
local missileBoostSound     = Sound( "killstreak_rewards/predator_missile_boost.wav" )


function ENT:Think()
	if ( self.NextThrustSound or 0 ) <= CurTime() then
		self.NextThrustSound = CurTime() + 1
		self:EmitSound( missileThrustSound )
	end
	if self:GetNWBool( "Boosted" ) then
		self:SetNWBool( "Boosted", false )
		self.KeepBoosting = true
	end
end


local function screenContrast()
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

local function setUpHUD()
	hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOO", screenContrast )
	hook.Add( "HUDPaint", "TargetEffect", drawHUD )
end

local function removeHUD()
	hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOO" )
	hook.Remove( "HUDPaint", "TargetEffect" )
end

local function PREDATOR_FRIENDLY()
	surface.PlaySound(
		"killstreak_rewards/predator_missile_friendly_inbound"
		.. LocalPlayer():GetNWString( "MW2TeamSound", "" )
		.. ".wav"
	)
end

local function PREDATOR_ENEMY()
	surface.PlaySound(
		"killstreak_rewards/predator_missile_enemy_inbound"
		.. LocalPlayer():GetNWString( "MW2TeamSound", "" )
		.. ".wav"
	)
end

-- FIX: usermessage.Hook (removed GMod API) -> net.Receive
net.Receive( "Predator_missile_SetUpHUD",  setUpHUD )
net.Receive( "Predator_missile_RemoveHUD", removeHUD )
net.Receive( "MW2_PREDATOR_FRIENDLY",      PREDATOR_FRIENDLY )
net.Receive( "MW2_PREDATOR_ENEMY",         PREDATOR_ENEMY )
