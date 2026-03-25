include('shared.lua')	//  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES

local tarpos;
local pos;
local dist;
local color;
local Friendly = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }


function drawHUD()


	render_Crosshair();


	allEnts = ents.GetAll();	//	GET ALL ENTITIES IN THE SERVER


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...


		for k, v in pairs( allEnts ) do  //  FOR EACH ENTITY FOUND, DO THE FOLLOWING...


			if v:IsPlayer() && v != LocalPlayer() then  //  CHECK:  IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER IS *NOT THE LOCAL PLAYER*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )	//	GET THE "TARPOS" OF THE PLAYER


				pos = tarpos:ToScreen()  //	GET THE "POSITION" OF THE PLAYER


				dist = 25;  //	SET THE "DISTANCE"


				if v:Team() == LocalPlayer():Team() then	//  CHECK:  IF THE PLAYER'S TEAM IS *EQUAL* TO THE TEAM OF THE *LOCAL PLAYER*, THEN...


					surface.SetDrawColor( 0, 255, 0 )  //  SET THE COLOR TO "GREEN"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				else	//	IF THE PLAYER'S TEAM IS *NOT EQUAL* TO THE TEAM OF THE *LOCAL PLAYER*, THEN...


					surface.SetDrawColor( 255, 0, 0 )  //  SET THE COLOR TO "RED"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				end  //  FINISH THE CHECK


			elseif v:IsNPC() then  //	IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )  //	GET THE "TARPOS" OF THE NPC


				pos = tarpos:ToScreen()  //	GET THE "POSITION" OF THE NPC


				dist = 25;  //	SET THE "DISTANCE"


				if table.HasValue( Friendly, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then  //	CHECK:	IF THE NPC *IS A FRIENDLY* ( DOES HAVE AN ENTRY IN THE "Friendly" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 0, 255, 0 )  //  SET THE COLOR TO "GREEN"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				elseif !table.HasValue( Friendly, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then	//	IF THE NPC IS *NOT A FRIENDLY* ( DOES NOT HAVE AN ENTRY IN THE "Friendly" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 255, 0, 0 )  //  SET THE COLOR TO "RED"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				end  //  FINISH THE CHECK


			elseif v:IsPlayer() && v == LocalPlayer() then  //	IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER *IS ALSO THE LOCAL PLAYER*, THEN...


				lplpos = LocalPlayer():GetPos()  //  GET THE "POSITION" OF THE LOCAL PLAYER


				lpltarpos = lplpos:ToScreen()  //  GET THE "TARPOS" OF THE LOCAL PLAYER


				surface.SetDrawColor( 0, 0, 255 )  //  SET THE COLOR TO "BLUE"


				surface.DrawLine( lpltarpos.x - 25, lpltarpos.y, lpltarpos.x + 25, lpltarpos.y )  //  DRAW A LINE


				surface.DrawLine( lpltarpos.x, lpltarpos.y - 25, lpltarpos.x, lpltarpos.y + 25 )  //  DRAW ANOTHER LINE


			end  //  FINISH CHECKING THE ENTITY


		end  //  FINISH THE LOOP


	else  //  IF TEAMS ARE *NOT ENABLED*, THEN...


		for k, v in pairs( allEnts ) do  //  FOR EACH ENTITY FOUND, DO THE FOLLOWING...


			if v:IsPlayer() && v != LocalPlayer() then	//  CHECK:  IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER IS *NOT THE LOCAL PLAYER*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )  //	GET THE "TARPOS" OF THE PLAYER


				pos = tarpos:ToScreen()  //	GET THE "POSITION" OF THE PLAYER


				dist = 25;  //	SET THE "DISTANCE"


				surface.SetDrawColor( 255, 0, 0 )  //  SET THE COLOR TO "RED"


				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


			elseif v:IsNPC() then	//	IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )	//	GET THE "TARPOS" OF THE NPC


				pos = tarpos:ToScreen()  //	GET THE "POSITION" OF THE NPC


				dist = 25;  //  SET THE "DISTANCE"


				if table.HasValue( Friendly, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then  //	CHECK:	IF THE NPC *IS A FRIENDLY* ( DOES HAVE AN ENTRY IN THE "Friendly" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 0, 255, 0 )  //  SET THE COLOR TO "GREEN"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				elseif !table.HasValue( Friendly, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then  //	IF THE NPC IS *NOT A FRIENDLY* ( DOES NOT HAVE AN ENTRY IN THE "Friendly" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 255, 0, 0 )  //  SET THE COLOR TO "RED"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				end  //  FINISH THE CHECK


			elseif v:IsPlayer() && v == LocalPlayer() then  //	IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER *IS ALSO THE LOCAL PLAYER*, THEN...


				lplpos = LocalPlayer():GetPos()  //  GET THE "POSITION" OF THE LOCAL PLAYER


				lpltarpos = lplpos:ToScreen()  //  GET THE "TARPOS" OF THE LOCAL PLAYER


				surface.SetDrawColor( 0, 0, 255 )  //  SET THE COLOR TO "BLUE"


				surface.DrawLine( lpltarpos.x - 25, lpltarpos.y, lpltarpos.x + 25, lpltarpos.y )  //  DRAW A LINE


				surface.DrawLine( lpltarpos.x, lpltarpos.y - 25, lpltarpos.x, lpltarpos.y + 25 )  //  DRAW ANOTHER LINE


			end  //  FINISH CHECKING THE ENTITY


		end  //  FINISH THE LOOP


	end  //  FINISH CHECKING IF TEAMS ARE ENABLED


	return true;


end


local width = 120;
local height = 60;
local lineLength = 100;
local cornorLength = 35;
local centerX = ScrW()/2;
local centerY = ScrH()/2
local distanceFromCenter = 350;
function render_Crosshair()


	surface.SetDrawColor( 150, 150, 150 )

    surface.DrawOutlinedRect( centerX - width/2, centerY - height/2, width, height ) -- Draws the middle square

	surface.DrawLine(centerX - width/2, centerY, (centerX - width/2) - lineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + width/2, centerY, (centerX + width/2) + lineLength, centerY); -- Draws the horizontal line on the right
	surface.DrawLine(centerX, centerY - height/2, centerX , (centerY - height/2) - lineLength); -- Draws the vertical line on the top
	surface.DrawLine(centerX, centerY + height/2, centerX , (centerY + height/2) + lineLength); -- Draws the vertical line on the bottom

	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornorLength, centerY - distanceFromCenter) -- upper left cornor
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter), (centerY - distanceFromCenter) + cornorLength) --
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornorLength, centerY + distanceFromCenter) -- bottom left cornor
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter), (centerY + distanceFromCenter) - cornorLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornorLength, centerY - distanceFromCenter) -- upper right cornor
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter), (centerY - distanceFromCenter) + cornorLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornorLength, centerY + distanceFromCenter) -- bottom right cornor
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter), (centerY + distanceFromCenter) - cornorLength) --
	----------------------------------------------------


end

local missileThrustSound = Sound("killstreak_rewards/predator_missile_thruster.wav")
local missileExplosionSound = Sound("killstreak_rewards/predator_missile_explosion.wav")
local missileBoostSound = Sound("killstreak_rewards/predator_missile_boost.wav")


function ENT:Think()


	if (self.NextThrustSound or 0) <= CurTime() then


		self.NextThrustSound = CurTime() + 1


		if self.KeepBoosting then


			self:EmitSound( missileThrustSound )


		else


			self:EmitSound( missileThrustSound )


		end


	end


	if self:GetNWBool("Boosted") then


		self:SetNWBool("Boosted",false)


		self.KeepBoosting = true


	end


end


function PREDATOR_FRIENDLY()	//	CREATE A FUNCTION CALLED:	PREDATOR_FRIENDLY()



	playMissileInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playMissileInboundSound



end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function PREDATOR_ENEMY()	//	CREATE A FUNCTION CALLED:	PREDATOR_ENEMY()



	playMissileDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playMissileDeploySound



end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playMissileInboundSound()  //	CREATE A FUNCTION CALLED:	playMissileInboundSound()


	surface.PlaySound("killstreak_rewards/predator_missile_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playMissileDeploySound()	//	CREATE A FUNCTION CALLED:	playMissileDeploySound()


	surface.PlaySound("killstreak_rewards/predator_missile_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function screenContrast()

	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0
	tab[ "$pp_colour_brightness" ] = 0
	tab[ "$pp_colour_contrast" ] = 1
	tab[ "$pp_colour_colour" ] = 0
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0

	DrawColorModify( tab )
end

function setUpHUD()
	hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOO", screenContrast )
	hook.Add("HUDPaint", "TargetEffect", drawHUD)
end
function removeHUD()
	hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOO")
	hook.Remove("HUDPaint", "TargetEffect")
end

usermessage.Hook("Predator_missile_SetUpHUD", setUpHUD)
usermessage.Hook("Predator_missile_RemoveHUD", removeHUD)


usermessage.Hook( "MW2_PREDATOR_FRIENDLY", PREDATOR_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_PREDATOR_FRIENDLY"  -  RUN THE FUNCTION:	PREDATOR_FRIENDLY()


usermessage.Hook( "MW2_PREDATOR_ENEMY", PREDATOR_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_PREDATOR_ENEMY"  -  RUN THE FUNCTION:	PREDATOR_ENEMY()
