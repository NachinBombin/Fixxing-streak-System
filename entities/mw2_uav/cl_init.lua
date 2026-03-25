include('shared.lua')	//  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES

local sweepTexture = surface.GetTextureID("VGUI/killStreak_misc/uavsweep")

local isActive = false;
local totalActive = 0;

local uavBoxSize = 250;
local x = 20;
local y = 20;
local width = uavBoxSize;
local height = uavBoxSize;
local edge = 270;
local sweepPos = 0;
local cameraPos = 1000
local centerX = x + width/2;
local centerY = y + height/2;
local scaleFactor = ((cameraPos *2)/1.5)/uavBoxSize
local lineLength = 10
local Friendly_Entity_Position = {}  //  CREATE CUSTOM TABLE TO RECEIVE THE CURRENT POSITION OF A FRIENDLY NPC ( HAS AN ENTRY IN THE TABLE BELOW )
local Enemy_Entity_Position = {}	//	CREATE CUSTOM TABLE TO RECEIVE THE CURRENT POSITION OF AN ENEMY NPC ( DOES *NOT* HAVE AN ENTRY IN THE TABLE BELOW )
local Friends = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }


local UavSweepBase = 3;
local UavBarBase = 0.005;
local UavSweepNew = 0;
local UavBarNew = 0;


//	*****  LOCAL VARIABLE DEFINITIONS FOR THE TEMPORARY CROSSHAIR  *****


local Center = Vector( ScrW() / 2, ScrH() / 2, 0 )


local Scale = Vector( 10, 10 )


local Segment_Distance = 360 / ( 2 * math.pi * math.max( Scale.x, Scale.y ) / 2 )


//	*****  END OF VARIABLE DEFINITIONS FOR THE TEMPORARY CROSSHAIR  *****


local function DRAW_FRIENDLIES( FRIENDLY, Local_Player )	//	CREATE LOCAL FUNCTION CALLED "DRAW_FRIENDLIES" AND ACCEPT THE "FRIENDLY" ENTITY TABLE *AND* THE LOCAL PLAYER AS PARAMETERS


	for Key, Value in pairs( Friendly_Entity_Position ) do


		local pos = Local_Player:GetPos() - Value

		local newX = pos.x/scaleFactor;

		local newY = pos.y/scaleFactor;

		local targetX = centerY + newY;

		local targetY = centerX + newX;

		local targetX = math.Clamp(targetX, 20, 270)

		local targetY = math.Clamp(targetY, 20, 270)


		draw.RoundedBox( 4, targetX , targetY , 20, 20, Color( 0, 255, 0 ) )	//	DRAW A "ROUNDED" GREEN BOX AT THE POSITION OF THE FRIENDLY NPC OR PLAYER


	end


end


local function DRAW_ENEMIES( ENEMY, Local_Player )	//	CREATE LOCAL FUNCTION CALLED "DRAW_ENEMIES" AND ACCEPT THE "ENEMY" ENTITY TABLE *AND* THE LOCAL PLAYER AS PARAMETERS


	for Key, Value in pairs( Enemy_Entity_Position ) do


		local pos = Local_Player:GetPos() - Value

		local newX = pos.x/scaleFactor;

		local newY = pos.y/scaleFactor;

		local targetX = centerY + newY;

		local targetY = centerX + newX;

		local targetX = math.Clamp(targetX, 20, 270)

		local targetY = math.Clamp(targetY, 20, 270)


		draw.RoundedBox( 4, targetX , targetY , 20, 20, Color( 255, 0, 0 ) )	//	DRAW A "ROUNDED" RED BOX AT THE POSITION OF THE ENEMY NPC OR PLAYER


	end


end


local function DRAW_MAP( FRIENDLY_ENTITY, ENEMY_ENTITY, LOCAL_PLAYER )	//	CREATE LOCAL FUNCTION CALLED "DRAW_MAP" AND ACCEPT THE FRIENDLY AND ENEMY ENTITY TABLES AS PARAMETERS


	local Local_Player = LocalPlayer()


	local CamData = {}


		CamData.angles = Angle(90,0,0)
		CamData.origin = Local_Player:GetPos() + Vector(0,0,cameraPos)
		CamData.x = x
		CamData.y = y
		CamData.w = width
		CamData.h = height
		CamData.drawviewmodel = false;


	render.RenderView( CamData )


	local aimVector = Local_Player:GetAimVector()


	draw.RoundedBox( 4, centerX - 4,  centerY - 4, 8, 8, Color( 0, 0, 255 ) )


	surface.DrawLine(centerX, centerY, centerX + (lineLength * (aimVector.y * -1) ), centerY + (lineLength * (aimVector.x * -1)))


	DRAW_FRIENDLIES( FRIENDLY_ENTITY, LocalPlayer() )	//	CALL FUNCTION "DRAW_FRIENDLIES" DEFINED ABOVE, PASSING THE "FRIENDLY_ENTITY" TABLE PREVIOUSLY RECEIVED *AND* THE LOCAL PLAYER AS ARGUMENTS


	DRAW_ENEMIES( ENEMY_ENTITY, LocalPlayer() )  //	CALL FUNCTION "DRAW_ENEMIES" DEFINED ABOVE, PASSING THE "ENEMY_ENTITY" TABLE PREVIOUSLY RECEIVED *AND* THE LOCAL PLAYER AS ARGUMENTS


	if sweepPos > 20 then


		surface.SetTexture(sweepTexture)


		surface.SetDrawColor( 255, 255, 255 ) // Makes sure the image draws correctly


		surface.DrawTexturedRect(sweepPos, 20, 16, uavBoxSize)


	end


end


function BRIDGE( Local_Player )	//	CREATE A FUNCTION CALLED "BRIDGE"


	hook.Add( "HUDPaint", "UAV", function()  //  ASK THE SYSTEM TO UPDATE THE HEAD UP DISPLAY (HUD) BY...


		DRAW_MAP( FRIENDLY, ENEMY, Local_Player )  //  DRAWING THE UAV MAP ( PASS THE NEWLY POPULATED FRIENDLY AND ENEMY TABLES AS ARGUMENTS )


	end )	//	NOTIFY THE SYSTEM THAT THE FUNCTION IS FULLY DEFINED


end  //  NOTIFY THE SYSTEM THAT THE "BRIDGE" FUNCTION IS FULLY DEFINED


function UavSweep()


	sweepPos = edge - 8;


	local Local_Player = LocalPlayer()	//	STORE THE LOCAL PLAYER


	Friendly_Entity_Position = {}	//	ERASE ANY CURRENT ENTRIES WITHIN THE CUSTOM TABLE


	Enemy_Entity_Position = {}	//	ERASE ANY CURRENT ENTRIES WITHIN THE CUSTOM TABLE


	local FRIENDLY = {}		//	CREATE A TEMPORARY TABLE CALLED "FRIENDLY" TO HOLD THE CURRENT FRIENDLY NPC BEING PROCESSED


	local ENEMY = {}	//	CREATE A TEMPORARY TABLE CALLED "ENEMY" TO HOLD THE CURRENT ENEMY NPC BEING PROCESSED


	local Temporary_Entities = ents.GetAll();  //  CREATE LOCAL VARIABLE TO STORE A LIST OF ALL ENTITIES IN THE SERVER


	for Key, Value in pairs( Temporary_Entities ) do	//	FOR EACH ENTITY IN THE LIST, DO THE FOLLOWING...


		if Value:IsNPC() and table.HasValue( Friends, Value:GetClass() ) and Value:GetClass() != "npc_bullseye" and Value:GetClass() != "npc_turret_floor" or ( Value:IsPlayer() and Value:Team() == Local_Player:Team() and Value != Local_Player and GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 ) then	//	CHECK:	IF THE ENTITY CURRENTLY BEING PROCESSED *IS* AN NPC, *AND* THE NPC HAS AN ENTRY IN THE "Friends" TABLE, *AND* THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*,  **OR**  THE ENTITY BEING PROCESSED IS A PLAYER, *AND* THEIR "TEAM" IS *EQUAL* TO THE LOCAL PLAYER'S "TEAM", *AND* THE PLAYER IS *NOT* THE LOCAL PLAYER, **AND** TEAMS *ARE ENABLED*, THEN...


			Friendly_Entity_Position[ Key ] = Value:GetPos();	//	STORE THE POSITION OF THE FRIENDLY NPC OR PLAYER AS AN ENTRY IN THE "Friendly_Entity_Position" TABLE


			FRIENDLY[ Key ] = Value  //  STORE THE NAME OF THE FRIENDLY NPC OR PLAYER AS AN ENTRY IN THE "FRIENDLY" TABLE


			BRIDGE()	//	CALL FUNCTION "BRIDGE" DEFINED ABOVE


		elseif Value:IsNPC() and !table.HasValue( Friends, Value:GetClass() ) and Value:GetClass() != "npc_bullseye" and Value:GetClass() != "npc_turret_floor" or ( Value:IsPlayer() and Value:Team() != Local_Player:Team() and Value != Local_Player and GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 ) then		//	CHECK:	IF THE ENTITY CURRENTLY BEING PROCESSED *IS* AN NPC, *AND* THE NPC *DOES NOT* HAVE AN ENTRY IN THE "Friends" TABLE, *AND* THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*,  **OR**  THE ENTITY BEING PROCESSED IS A PLAYER, *AND* THEIR "TEAM" IS *NOT EQUAL* TO THE LOCAL PLAYER'S "TEAM", *AND* THE PLAYER IS *NOT* THE LOCAL PLAYER, **AND** TEAMS *ARE ENABLED*, THEN...


			Enemy_Entity_Position[ Key ] = Value:GetPos();	//	STORE THE POSITION OF THE ENEMY NPC OR PLAYER AS AN ENTRY IN THE "Enemy_Entity_Position" TABLE


			ENEMY[ Key ] = Value	//  STORE THE NAME OF THE ENEMY NPC OR PLAYER AS AN ENTRY IN THE "ENEMY" TABLE


			BRIDGE()  //	CALL FUNCTION "BRIDGE" DEFINED ABOVE


		elseif Value:IsPlayer() and Value == Local_Player then	//	CHECK:	IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER *IS ALSO THE LOCAL PLAYER*, THEN...


			local Local_Player = {}  //  CREATE A LOCAL TABLE CALLED:  "Local_Player"


			Local_Player = Value	//	STORE THE CURRENT PLAYER BEING PROCESSED AS AN ENTRY IN THE TABLE


			BRIDGE( Local_Player )  //	CALL FUNCTION "BRIDGE" DEFINED ABOVE


		elseif Value:IsPlayer() and Value != Local_Player and GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() == 0 then	//	CHECK:	IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER IS *NOT THE LOCAL PLAYER*, **AND** TEAMS ARE *NOT ENABLED*, THEN...


			Enemy_Entity_Position[ Key ] = Value:GetPos();	//	STORE THE POSITION OF THE ENEMY NPC OR PLAYER AS AN ENTRY IN THE "Enemy_Entity_Position" TABLE


			ENEMY[ Key ] = Value	//  STORE THE NAME OF THE ENEMY NPC OR PLAYER AS AN ENTRY IN THE "ENEMY" TABLE


			BRIDGE()  //	CALL FUNCTION "BRIDGE" DEFINED ABOVE


		end  //  FINISH PROCESSING THE NPC OR PLAYER


	end  //  FINISH LOOPING THROUGH THE LIST OF ENTITIES


end  //  NOTIFY THE SYSTEM THAT THE FUNCTION IS FULLY DEFINED


function moveSweep()
	sweepPos = sweepPos - 4
end

function REMOVE_UAV()


	timer.Stop("UAV_redrawTimer");


	timer.Stop("UavSweeper");


	timer.Stop("UAV_stopTimer");


	hook.Remove( "HUDPaint", "UAV" );	//	REMOVE THE UAV MAP ONCE THE KILLSTREAK ENDS


	hook.Remove( "HUDPaint", "Crosshair" )	//	REMOVE THE TEMPORARY CROSSHAIR ONCE THE KILLSTREAK ENDS


	totalActive = 0;


	isActive = false;


end

function UAV_FRIENDLY()	//	CREATE A FUNCTION CALLED:	UAV_FRIENDLY()


	totalActive = totalActive + 1;

	if isActive then
		if totalActive <= 3 then
			UavSweepNew = UavSweepBase - ( totalActive / 1.25 );
			UavBarNew = UavBarBase * (totalActive + 2 );
			timer.Adjust("UAV_redrawTimer", UavSweepNew, 0, UavSweep)
			timer.Adjust("UavSweeper", UavBarNew, 0, moveSweep)
		end
		return;
	end


	UavSweep();


	hook.Add( "HUDPaint", "Crosshair", function()	//	HOOK INTO THE "HUDPaint" EVENT:  RUN CUSTOM FUNCTION


		if ConVarExists( "vj_hud_disablegmodcross" ) then	//	CHECK:	IF VJ-HUD IS FOUND, THEN...


			if GetConVarNumber( "crosshair" ) == 1 and GetConVarNumber( "vj_hud_disablegmodcross" ) == 0 then	//	MAKE SURE THAT *BOTH* THE GMOD INTERNAL CROSSHAIR IS ENABLED AND THAT VJ-HUD *DOES NOT* DISABLE THE CROSSHAIR


				surface.SetDrawColor( 255, 255, 255 )	//	SET THE COLOR AND OPACITY OF THE NEW CROSSHAIR


				for A = 0, 360 - Segment_Distance, Segment_Distance do	//	CALCULATE DIMENSIONS


					surface.DrawLine( Center.x + math.cos( math.rad( A ) ) * Scale.x, Center.y - math.sin( math.rad( A ) ) * Scale.y, Center.x + math.cos( math.rad( A + Segment_Distance ) ) * Scale.x, Center.y - math.sin( math.rad( A + Segment_Distance ) ) * Scale.y )	//	DRAW CROSSHAIR


				end  //  FINISH CALCULATING


			end  //  CLOSE "IF" STATEMENT


		else	//	IF VJ-HUD IS *NOT* FOUND, THEN...


			if GetConVarNumber( "crosshair" ) == 1 then  //  ONLY CHECK IF THE GMOD INTERNAL CROSSHAIR IS ENABLED. IF IT IS, THEN...


				surface.SetDrawColor( 255, 255, 255 )  //	SET THE COLOR AND OPACITY OF THE NEW CROSSHAIR


				for A = 0, 360 - Segment_Distance, Segment_Distance do	//	CALCULATE DIMENSIONS


					surface.DrawLine( Center.x + math.cos( math.rad( A ) ) * Scale.x, Center.y - math.sin( math.rad( A ) ) * Scale.y, Center.x + math.cos( math.rad( A + Segment_Distance ) ) * Scale.x, Center.y - math.sin( math.rad( A + Segment_Distance ) ) * Scale.y )	//	DRAW CROSSHAIR


				end  //  FINISH CALCULATING


			end  //  CLOSE "IF" STATEMENT


		end  //  FINISH CHECK


	end )	//	TELL THE SYSTEM THAT THE FUNCTION IS FULLY DEFINED


	//timer.Create("UAV_stopTimer",30,1, killUav)

	timer.Create("UAV_redrawTimer", UavSweepBase, 0, UavSweep)

	timer.Create("UavSweeper", UavBarBase, 0, moveSweep)

	if !isActive then

		isActive = true;

	end


	playUAVInboundSound()	//	CALL (RUN) FUNCTION CALLED:  playUAVInboundSound


end


function UAV_ENEMY()	//	CREATE A FUNCTION CALLED:	UAV_ENEMY()



	playUAVDeploySound()	//	CALL (RUN) FUNCTION CALLED:  playUAVDeploySound



end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playUAVInboundSound()	//	CREATE A FUNCTION CALLED:	playUAVInboundSound()


	/*	THIS CODE BLOCK HAS BEEN DISABLED	-	INOPERABLE AND UNOPTIMIZED

	local teamType = "";

	if GetGlobalString("MW2_UAV_Player") == LocalPlayer():GetName() then
		teamType = "friendly";
	else
		teamType = "enemy";
	end

	*/


	surface.PlaySound( "killstreak_rewards/uav_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav" )	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playUAVDeploySound()	//	CREATE A FUNCTION CALLED:	playUAVDeploySound()


	surface.PlaySound("killstreak_rewards/uav_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") .. ".wav")  //  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


usermessage.Hook( "MW2_UAV_FRIENDLY", UAV_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_UAV_FRIENDLY"  -  RUN THE FUNCTION:	UAV_FRIENDLY()


usermessage.Hook( "MW2_UAV_ENEMY", UAV_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_UAV_ENEMY"  -  RUN THE FUNCTION:	UAV_ENEMY()


usermessage.Hook( "MW2_UAV_END", REMOVE_UAV )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_UAV_END"  -  RUN THE FUNCTION:  REMOVE_UAV()
