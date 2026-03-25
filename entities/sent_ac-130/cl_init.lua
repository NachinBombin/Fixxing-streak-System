include('shared.lua')	//  REQUIRED TO PREVENT ERRORS AND INVISIBLE ENTITIES

local tarpos;
local pos;
local dist;
local color;
local friendlys = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }
local UseThermal;
local isInVehicle = false;
local PlayVoice = false;
local playerInVehicle = NULL;
local AC130IdleInsideSound = Sound("ac-130_kill_sounds/AC130_idle_inside.mp3")
AC130Idele = nil; //= CreateSound(LocalPlayer(), AC130IdleInsideSound )

local tblFonts = {}
tblFonts["HUDNumber"] = {
	font = "Trebuchet MS",
	size = 40,
	weight = 900,
}

tblFonts["HUDNumber1"] = {
	font = "Trebuchet MS",
	size = 41,
	weight = 900,
}

tblFonts["HUDNumber2"] = {
	font = "Trebuchet MS",
	size = 42,
	weight = 900,
}

tblFonts["HUDNumber3"] = {
	font = "Trebuchet MS",
	size = 43,
	weight = 900,
}

tblFonts["HUDNumber4"] = {
	font = "Trebuchet MS",
	size = 44,
	weight = 900,
}

tblFonts["HUDNumber5"] = {
	font = "Trebuchet MS",
	size = 45,
	weight = 900,
}

for k,v in SortedPairs( tblFonts ) do
	surface.CreateFont( k, tblFonts[k] );

	--print( "Added font '"..k.."'" );
end

local function drawAC130HUD()
	textWhiteColor = Color(255,255,255,255)
	unusedGunColor = Color(255,255,255,127)
	blinkingColor = Color(255,255,255,math.sin(RealTime() * 16) * 127.5 + 127.5)
	ac130weapon = LocalPlayer():GetNetworkedInt("Ac_130_weapon")
	Is105mmReloading = LocalPlayer():GetNetworkedBool("Ac_130_105mmReloading")
	Is40mmReloading = LocalPlayer():GetNetworkedBool("Ac_130_40mmReloading")
	Is25mmReloading = LocalPlayer():GetNetworkedBool("Ac_130_25mmReloading")
	local ac130weapon = LocalPlayer():GetNetworkedInt("Ac_130_weapon")
	if ac130weapon == 0 then
		Crosshair_105mm()
	elseif ac130weapon == 1 then
		Crosshair_40mm()
	elseif ac130weapon == 2 then
		Crosshair_25mm()
	end

	local sen = 0;
	if ac130weapon == 0 then
		sen = LocalPlayer():GetFOV() / 90;
	elseif ac130weapon == 1 then
		sen = LocalPlayer():GetFOV() / 105;
	else
		sen = LocalPlayer():GetFOV() / 53;
	end


	LocalPlayer():GetActiveWeapon().MouseSensitivity = sen


	allEnts = ents.GetAll();	//	GET ALL ENTITIES IN THE SERVER


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...


		for k, v in pairs( allEnts ) do  //  FOR EACH ENTITY FOUND, DO THE FOLLOWING...


			if v:IsPlayer() && v != LocalPlayer() then  //  CHECK:  IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER IS *NOT THE LOCAL PLAYER*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )	//	GET THE "TARPOS" OF THE PLAYER


				pos = tarpos:ToScreen()  //  GET THE "POSITION"	OF THE PLAYER


				dist = 40;	//	SET THE "DISTANCE"


				if v:Team() == LocalPlayer():Team() then  //  CHECK:  IF THE PLAYER'S TEAM IS *EQUAL* TO THE TEAM OF THE *LOCAL PLAYER*, THEN...


					surface.SetDrawColor( 0, 255, 0 )	//	SET THE COLOR TO "GREEN"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )	//	DRAW A RECTANGLE


				else	//	IF THE PLAYER'S TEAM IS *NOT EQUAL* TO THE TEAM OF THE *LOCAL PLAYER*, THEN...


					surface.SetDrawColor( 255, 0, 0 )	//	SET THE COLOR TO "RED"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )	//	DRAW A RECTANGLE


				end  //  FINISH THE CHECK


			elseif v:IsNPC() then	//	IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )	//	GET THE "TARPOS" OF THE NPC


				pos = tarpos:ToScreen()  //	GET THE "POSITION" OF THE NPC


				dist = 40;	//	SET THE "DISTANCE"


				if table.HasValue( friendlys, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then	//	CHECK:	IF THE NPC *IS A FRIENDLY* ( DOES HAVE AN ENTRY IN THE "friendlys" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 0, 255, 0 )	//	SET THE COLOR TO "GREEN"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				elseif !table.HasValue( friendlys, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then	//	IF THE NPC IS *NOT A FRIENDLY* ( DOES NOT HAVE AN ENTRY IN THE "friendlys" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 255, 0, 0 )	//	SET THE COLOR TO "RED"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )	//	DRAW A RECTANGLE


				end  //  FINISH THE CHECK


			elseif v:IsPlayer() && v == LocalPlayer() then	//	IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER *IS ALSO THE LOCAL PLAYER*, THEN...


				lplpos = LocalPlayer():GetPos()  //  GET THE "POSITION" OF THE LOCAL PLAYER


				lpltarpos = lplpos:ToScreen()	//  GET THE "TARPOS" OF THE LOCAL PLAYER


				surface.SetDrawColor( 0, 0, 255 )	//  SET THE COLOR TO "BLUE"


				surface.DrawLine( lpltarpos.x - 25, lpltarpos.y, lpltarpos.x + 25, lpltarpos.y )  //  DRAW A LINE


				surface.DrawLine( lpltarpos.x, lpltarpos.y - 25, lpltarpos.x, lpltarpos.y + 25 )  //  DRAW ANOTHER LINE


			end  //  FINISH CHECKING THE ENTITY


		end  //  FINISH THE LOOP


	else  //  IF TEAMS ARE *NOT ENABLED*, THEN...


		for k, v in pairs( allEnts ) do  //  FOR EACH ENTITY FOUND, DO THE FOLLOWING...


			if v:IsPlayer() && v != LocalPlayer() then  //  CHECK:  IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER IS *NOT THE LOCAL PLAYER*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )	//	GET THE "TARPOS" OF THE PLAYER


				pos = tarpos:ToScreen()  //  GET THE "POSITION" OF THE PLAYER


				dist = 40;  //	SET THE "DISTANCE"


				surface.SetDrawColor( 255, 0, 0 )	//	SET THE COLOR TO "RED"


				surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )	//	DRAW A RECTANGLE


			elseif v:IsNPC() then	//	IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, THEN...


				tarpos = v:GetPos() + Vector( 0, 0, v:OBBMaxs().z * 0.5 )	//	GET THE "TARPOS" OF THE NPC


				pos = tarpos:ToScreen()  //	GET THE "POSITION" OF THE NPC


				dist = 40;  //	SET THE "DISTANCE"


				if table.HasValue( friendlys, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then	//	CHECK:	IF THE NPC *IS A FRIENDLY* ( DOES HAVE AN ENTRY IN THE "friendlys" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 0, 255, 0 )  //  SET THE COLOR TO "GREEN"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				elseif !table.HasValue( friendlys, v:GetClass() ) and v:GetClass() != "npc_bullseye" and v:GetClass() != "npc_turret_floor" then	//	IF THE NPC IS *NOT A FRIENDLY* ( DOES NOT HAVE AN ENTRY IN THE "friendlys" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					surface.SetDrawColor( 255, 0, 0 )  //  SET THE COLOR TO "RED"


					surface.DrawOutlinedRect( pos.x - dist / 2, pos.y - dist / 2, dist, dist )  //  DRAW A RECTANGLE


				end  //  FINISH THE CHECK


			elseif v:IsPlayer() && v == LocalPlayer() then	//	IF THE ENTITY CURRENTLY BEING PROCESSED *IS A PLAYER*, **AND** THAT PLAYER *IS ALSO THE LOCAL PLAYER*, THEN...


				lplpos = LocalPlayer():GetPos()  //  GET THE "POSITION" OF THE LOCAL PLAYER


				lpltarpos = lplpos:ToScreen()  //  GET THE "TARPOS" OF THE LOCAL PLAYER


				surface.SetDrawColor( 0, 0, 255 )  //  SET THE COLOR TO "BLUE"


				surface.DrawLine( lpltarpos.x - 25, lpltarpos.y, lpltarpos.x + 25, lpltarpos.y )  //  DRAW A LINE


				surface.DrawLine( lpltarpos.x, lpltarpos.y - 25, lpltarpos.x, lpltarpos.y + 25 )  //  DRAW ANOTHER LINE


			end  //  FINISH CHECKING THE ENTITY


		end  //  FINISH THE LOOP


	end  //  FINISH CHECKING IF TEAMS ARE ENABLED


	acTime = string.ToMinutesSeconds(LocalPlayer():GetNetworkedInt("Ac_130_Time"))

	if ScrH() >= 1000 then
		textFont = "HUDNumber5"
	elseif ScrH() <=1000 then
		textFont = "HUDNumber4"
	elseif ScrH() <=900 then
		textFont = "HUDNumber3"
	elseif ScrH() <=700 then
		textFont = "HUDNumber2"
	elseif ScrH() <=600 then
		textFont = "HUDNumber"
	end

	draw.SimpleText("0   A-G  MAN NARO",textFont,25,25,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("RAY",textFont,25,65,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("FF 30",textFont,25,105,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("LIR",textFont,25,145,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("BORE",textFont,25,225,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText("L1514",textFont,ScrW()/2,ScrH()-50,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText("RDY",textFont,ScrW()/2+20,ScrH()-50,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText(acTime,textFont,ScrW()/4*3,ScrH()-50,textWhiteColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	draw.SimpleText(acHUDXPos,textFont,ScrW()-25,5,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText(acHUDYPos,textFont,ScrW()-150,5,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	draw.SimpleText(acHUDAGL.." AGL",textFont,ScrW()-25,45,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	if UseThermal then
		if ThermalBlackMode then
			draw.SimpleText("BHOT",textFont,ScrW()-100,85,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		else
			draw.SimpleText("WHOT",textFont,ScrW()-100,85,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		end
	end
	if ScrH() >= 750 then
		draw.SimpleText("N",textFont,ScrW()-25,ScrH()/2-250,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2-200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("S",textFont,ScrW()-25,ScrH()/2-100,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("F",textFont,ScrW()-25,ScrH()/2-50,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Q",textFont,ScrW()-25,ScrH()/2+50,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Z",textFont,ScrW()-25,ScrH()/2+100,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("G",textFont,ScrW()-25,ScrH()/2+250,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+300,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	else
		draw.SimpleText("N",textFont,ScrW()-25,ScrH()/2-200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2-160,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("S",textFont,ScrW()-25,ScrH()/2-80,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("F",textFont,ScrW()-25,ScrH()/2-40,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Q",textFont,ScrW()-25,ScrH()/2+40,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("Z",textFont,ScrW()-25,ScrH()/2+80,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+160,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("G",textFont,ScrW()-25,ScrH()/2+200,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
		draw.SimpleText("T",textFont,ScrW()-25,ScrH()/2+240,textWhiteColor,TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP)
	end
	if ac130weapon == 0 then
		draw.SimpleText("105mm",textFont,25,ScrH()-50,blinkingColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("40mm",textFont,25,ScrH()-90,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("25mm",textFont,25,ScrH()-130,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	elseif ac130weapon == 1 then
		draw.SimpleText("105mm",textFont,25,ScrH()-50,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("40mm",textFont,25,ScrH()-90,blinkingColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("25mm",textFont,25,ScrH()-130,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	elseif ac130weapon == 2 then
		draw.SimpleText("105mm",textFont,25,ScrH()-50,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("40mm",textFont,25,ScrH()-90,unusedGunColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		draw.SimpleText("25mm",textFont,25,ScrH()-130,blinkingColor,TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
	end

	//return true;
end

function CheckForVehicle(ply)

	if ( ( !ply:InVehicle() && ply == playerInVehicle ) || !playerInVehicle:IsValid() ) && isInVehicle then
		playerInVehicle = NULL;
		isInVehicle = false;
	end

	if ply:InVehicle() && !isInVehicle then
		playerInVehicle = ply;
		isInVehicle = true;
		surface.PlaySound("ac-130_kill_sounds/clear_to_engage.wav")
	end
end

function Crosshair_105mm()
	local width = 120;
	local height = 60;
	local lineLength = 100;
	local cornerLength = 35;
	local centerX = ScrW()/2;
	local centerY = ScrH()/2;
	distanceFromCenter = 250

	if Is105mmReloading then
		surface.SetDrawColor(255,255,255,math.sin(RealTime() * 8) * 127.5 + 127.5) 			//--surface.SetDrawColor(blinkingColor)
	else
		surface.SetDrawColor(textWhiteColor)
	end

    surface.DrawOutlinedRect( centerX - width/2, centerY - height/2, width, height ) -- Draws the middle square

	surface.DrawLine(centerX - width/2, centerY, (centerX - width/2) - lineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + width/2, centerY, (centerX + width/2) + lineLength, centerY); -- Draws the horizontal line on the right
	surface.DrawLine(centerX, centerY - height/2, centerX , (centerY - height/2) - lineLength); -- Draws the vertical line on the top
	surface.DrawLine(centerX, centerY + height/2, centerX , (centerY + height/2) + lineLength); -- Draws the vertical line on the bottom

	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY - distanceFromCenter) -- upper left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY + distanceFromCenter) -- bottom left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY - distanceFromCenter) -- upper right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY + distanceFromCenter) -- bottom right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
end

function Crosshair_40mm()
	local width = 60;
	local height = 60;
	local hlineLength = 280;
	local vlineLength = 225;
	local centerX = ScrW()/2;
	local centerY = ScrH()/2

	if Is40mmReloading then
		surface.SetDrawColor(255,255,255,math.sin(RealTime() * 8) * 127.5 + 127.5) 			//--surface.SetDrawColor(blinkingColor)
	else
		surface.SetDrawColor(textWhiteColor)
	end

	surface.DrawLine(centerX - width/2, centerY, (centerX - width/2) - hlineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + width/2, centerY, (centerX + width/2) + hlineLength, centerY); -- Draws the horizontal line on the right

	surface.DrawLine(centerX - width/2 - 40, centerY - 10, centerX - width/2 - 40, centerY + 10);
	surface.DrawLine(centerX - width/2 - 40*3, centerY - 10, centerX - width/2 - 40*3, centerY + 10);
	surface.DrawLine(centerX - width/2 - 40*5, centerY - 10, centerX - width/2 - 40*5, centerY + 10);
	surface.DrawLine(centerX - width/2 - 40*7, centerY - 20, centerX - width/2 - 40*7, centerY + 20);

	surface.DrawLine(centerX + width/2 + 40, centerY - 10, centerX + width/2 + 40, centerY + 10);
	surface.DrawLine(centerX + width/2 + 40*3, centerY - 10, centerX + width/2 + 40*3, centerY + 10);
	surface.DrawLine(centerX + width/2 + 40*5, centerY - 10, centerX + width/2 + 40*5, centerY + 10);
	surface.DrawLine(centerX + width/2 + 40*7, centerY - 20, centerX + width/2 + 40*7, centerY + 20);

	surface.DrawLine(centerX, centerY - height/2, centerX , (centerY - height/2) - vlineLength); -- Draws the vertical line on the top

	surface.DrawLine(centerX - 10, centerY - height/2 - 45, centerX + 10 , (centerY - height/2) - 45);
	surface.DrawLine(centerX - 10, centerY - height/2 - 45*3, centerX + 10, (centerY - height/2) - 45*3);
	surface.DrawLine(centerX - 20, centerY - height/2 - 45*5, centerX + 20 , (centerY - height/2) - 45*5);

	surface.DrawLine(centerX, centerY + height/2, centerX , (centerY + height/2) + vlineLength); -- Draws the vertical line on the bottom

	surface.DrawLine(centerX - 10, centerY + height/2 + 45, centerX + 10 , (centerY + height/2) + 45);
	surface.DrawLine(centerX - 10, centerY + height/2 + 45*3, centerX + 10, (centerY + height/2) + 45*3);
	surface.DrawLine(centerX - 20, centerY + height/2 + 45*5, centerX + 20 , (centerY + height/2) + 45*5);
end

function Crosshair_25mm()
	local width = 120;
	local height = 60;
	local lineLength = 100;
	local cornerLength = 35;
	local centerX = ScrW()/2;
	local centerY = ScrH()/2
	local distanceFromCenter = 150;
	local lineDistance = 6
	if Is25mmReloading then
		surface.SetDrawColor(255,255,255,math.sin(RealTime() * 8) * 127.5 + 127.5) 			//--surface.SetDrawColor(blinkingColor)
	else
		surface.SetDrawColor(textWhiteColor)
	end

	surface.DrawLine(centerX - lineDistance, centerY, (centerX - lineDistance) - lineLength, centerY); -- Draws the horizontal line on the left
	surface.DrawLine(centerX + lineDistance, centerY, (centerX + lineDistance) + lineLength, centerY); -- Draws the horizontal line on the right

	surface.DrawLine(centerX, centerY + lineDistance, centerX , (centerY + lineDistance) + lineLength); -- Draws the vertical line on the bottom

	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY - distanceFromCenter) -- upper left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY - distanceFromCenter, (centerX - distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter) + cornerLength, centerY + distanceFromCenter) -- bottom left corner
	surface.DrawLine(centerX - distanceFromCenter, centerY + distanceFromCenter, (centerX - distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY - distanceFromCenter) -- upper right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY - distanceFromCenter, (centerX + distanceFromCenter), (centerY - distanceFromCenter) + cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter) - cornerLength, centerY + distanceFromCenter) -- bottom right corner
	surface.DrawLine(centerX + distanceFromCenter, centerY + distanceFromCenter, (centerX + distanceFromCenter), (centerY + distanceFromCenter) - cornerLength) --
	----------------------------------------------------
	surface.DrawLine(centerX + 6, centerY + 6, centerX + 16, centerY + 6)
	surface.DrawLine(centerX + 6, centerY + 6, centerX + 6, centerY + 16)
	----
	surface.DrawLine(centerX + 16, centerY + 16, centerX + 26, centerY + 16)
	surface.DrawLine(centerX + 16, centerY + 16, centerX + 16, centerY + 26)
	----
	surface.DrawLine(centerX + 26, centerY + 26, centerX + 36, centerY + 26)
	surface.DrawLine(centerX + 26, centerY + 26, centerX + 26, centerY + 36)
	----
	surface.DrawLine(centerX + 36, centerY + 36, centerX + 46, centerY + 36)
	surface.DrawLine(centerX + 36, centerY + 36, centerX + 36, centerY + 46)
	----
	surface.DrawLine(centerX + 46, centerY + 46, centerX + 56, centerY + 46)
	surface.DrawLine(centerX + 46, centerY + 46, centerX + 46, centerY + 56)
	----
	surface.DrawLine(centerX + 56, centerY + 56, centerX + 66, centerY + 56)
	surface.DrawLine(centerX + 56, centerY + 56, centerX + 56, centerY + 66)
	----
end

local tick = 0
function ENT:Think()
	if tick + 1 <= CurTime() then
		tick = CurTime()
		if not LocalPlayer():InVehicle() then
			self:StopSound("ac-130_kill_sounds/AC130_idle_inside.mp3")
			return
		end
		self:EmitSound("ac-130_kill_sounds/AC130_idle_inside.mp3",350,100)
	end
end

local sound105mm = Sound("killstreak_rewards/ac-130_105mm_fire.wav");
local sound40mm = Sound("killstreak_rewards/ac-130_40mm_fire.wav");
local sound25mm = Sound("killstreak_rewards/ac-130_25mm_fire.wav");


local sndTbl = {}
sndTbl["105mm"] = sound105mm
sndTbl["40mm"] = sound40mm
sndTbl["25mm"] = sound25mm

net.Receive("AC130_GunSound",function()
	local str = net.ReadString()
	if sndTbl[str] then
		LocalPlayer():EmitSound(sndTbl[str],400,100)
		LocalPlayer():GetViewEntity():EmitSound(sndTbl[str],400,100)
	end
end)

function screenContrastWHOT()
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

function screenContrastBHOT()

	local tab = {}
	tab[ "$pp_colour_addr" ] = 0
	tab[ "$pp_colour_addg" ] = 0
	tab[ "$pp_colour_addb" ] = 0
	tab[ "$pp_colour_brightness" ] = 0
	tab[ "$pp_colour_contrast" ] = 2
	tab[ "$pp_colour_colour" ] = 0
	tab[ "$pp_colour_mulr" ] = 0
	tab[ "$pp_colour_mulg" ] = 0
	tab[ "$pp_colour_mulb" ] = 0

	DrawColorModify( tab )
end

function UpdatePosAgl()
	local sky = findGround() + 6000
	local spawnPos = LocalPlayer():GetPos() + (LocalPlayer():GetForward() * 2000)
	acHUDXPos = tostring(math.floor(spawnPos.x)+16384)
	acHUDYPos = tostring(math.floor(spawnPos.y)+16384)
	acHUDAGL = tostring(math.floor(sky)+16384)
	timer.Create("refreshTimer",2,0, UpdatePosAglNumbers)
end

function UpdatePosAglNumbers()
	acHUDXPos = tostring(math.floor(LocalPlayer():GetNetworkedInt("Ac_130_HUDXPos"))+16384)
	acHUDYPos = tostring(math.floor(LocalPlayer():GetNetworkedInt("Ac_130_HUDYPos"))+16384)
	acHUDAGL = tostring(math.floor(LocalPlayer():GetNetworkedInt("Ac_130_HUDAGL"))+16384)
end

local DefMats = {}	-- The heat vision is curtisy of Teta_Bonita's x-ray vison script
local DefClrs = {}
local material = "thermal/thermal.vmt"

function ThermalVision()
	if LocalPlayer():KeyPressed(IN_RELOAD) then
		if ThermalBlackMode == true then
			ThermalBlackMode = false
		else
			ThermalBlackMode = true
		end
	end
	local playerTable = player.GetAll();
	local npcTable = ents.FindByClass("npc_*");
	local targets = {};
	table.Add(targets, playerTable)
	table.Add(targets, npcTable)
	for k,v in pairs( targets ) do

		-- Inefficient, but not TOO laggy I hope
		local r,g,b,a = v:GetColor()
		local entmat = v:GetMaterial()

		if v:IsNPC() or v:IsPlayer() then -- It's alive!
			if ThermalBlackMode == false then
				if not (r == 255 and g == 255 and b == 255 and a == 255) then -- Has our color been changed?
					DefClrs[ v ] = Color( tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255, tonumber(a) or 255 )  -- Store it so we can change it back later
					v:SetColor( Color( 255, 255, 255, 255 ) ) -- Set it back to what it should be now
				end
			else
				if v:IsNPC() then
					if not (r == 0 and g == 0 and b == 0 and a == 0) then -- Has our color been changed?
						DefClrs[ v ] = Color( tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255, tonumber(a) or 255 )  -- Store it so we can change it back later
						v:SetColor( Color( 0, 0, 0, 255 ) ) -- Set it back to what it should be now
					end
				elseif v:IsPlayer() and v:Alive() then
					if not (r == 0 and g == 0 and b == 0 and a == 0) then -- Has our color been changed?
						DefClrs[ v ] = Color( tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255, tonumber(a) or 255 )  -- Store it so we can change it back later
						v:SetColor( Color( 0, 0, 0, 255 ) ) -- Set it back to what it should be now
					end
				elseif v:IsPlayer() and v:Alive() == false then
					v:SetColor( Color( 255, 255, 255, 255 ) )
				end
			end

			if entmat ~= material then -- Has our material been changed?
				DefMats[ v ] = entmat -- Store it so we can change it back later
				v:SetMaterial( material ) -- The xray matierals are designed to show through walls
			end

		end
	end
	if ThermalBlackMode == true then
		hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT", screenContrastBHOT )
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT")
	else
		hook.Add( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT", screenContrastWHOT )
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT")
	end
end

function removeThermalVision()
	hook.Remove( "RenderScene", "ThermalVision" )

	for ent,mat in pairs( DefMats ) do
		if ent:IsValid() then
			ent:SetMaterial( mat )
		end
	end

	for ent,clr in pairs( DefClrs ) do
		if ent:IsValid() then
			ent:SetColor( Color( clr.r, clr.g, clr.b, clr.a ) )
		end
	end

	-- Clean up our tables- we don't need them anymore.
	DefMats = {}
	DefClrs = {}
end

function hideDefaultHUD(name)
	for k, v in pairs{"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo"} do
		if name == v then return false end
	end
end

function setUpHUD()
	ThermalBlackMode = false;
	hook.Add("HUDShouldDraw", "hideDefaultHUD", hideDefaultHUD)	;
	UseThermal = true //LocalPlayer():GetNetworkedBool("MW2AC130ThermalView");  USE THERMAL VIEW BY DEFAULT
	UpdatePosAgl()
	if UseThermal then
		hook.Add( "RenderScene", "ThermalVision", ThermalVision )
	end
	hook.Add("HUDPaint", "TargetEffect", drawAC130HUD)
	timer.Simple(3, function()
		PlayVoice = true;
	end )
	AC130Idele = CreateSound(LocalPlayer(), AC130IdleInsideSound )
	AC130Idele:Play()
end

function removeHUD()
	if AC130Idele then
		AC130Idele:Stop()
	end
	hook.Remove("HUDShouldDraw", "hideDefaultHUD");
	if ThermalBlackMode == true then
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOBHOT")
	else
		hook.Remove( "RenderScreenspaceEffects", "RenderColorModifyPOOWHOT")
	end
	hook.Remove("HUDPaint", "TargetEffect")
	if UseThermal then
		removeThermalVision();
	end
	LocalPlayer():GetActiveWeapon().MouseSensitivity = 1

end

function PlayAC130KillSound(um)
	kills = um:ReadLong()
	//MsgN(kills)
	local soundName = NULL;

	if kills >=3 && kills <=5 then
		if math.random(0,1) == 0 then
			soundName = "nice";
		else
			soundName = "you_got_him";
		end
	elseif kills >= 6 && kills <=9 then
		if math.random(0,1) == 0 then
			soundName = "kaboom";
		else
			soundName = "thats_a_hit";
		end

	elseif kills >=10 then
		soundName = "little_pieces";
	end
	if soundName != NULL then
		surface.PlaySound("ac-130_kill_sounds/" .. soundName .. ".wav")
	end
end

function findGround()

	local minheight = -16384
	local startPos = LocalPlayer():GetPos()
	local endPos = Vector(0, 0,minheight);
	local filterList = {LocalPlayer()}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local groundLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitWorld then
			groundLocation = traceData.HitPos.z;
			bool = false;
		else
			table.insert(filterList, traceData.Entity)
		end

		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the ground");
			bool = false;
		end
	end

	return groundLocation;
end


function LOCKHEED_FRIENDLY()	//	CREATE A FUNCTION CALLED:	LOCKHEED_FRIENDLY()



	playAC130InboundSound()	//	CALL (RUN) FUNCTION CALLED:  playAC130InboundSound



end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function LOCKHEED_ENEMY()	//	CREATE A FUNCTION CALLED:	LOCKHEED_ENEMY()



	playAC130DeploySound()	//	CALL (RUN) FUNCTION CALLED:  playAC130DeploySound



end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playAC130InboundSound()	//	CREATE A FUNCTION CALLED:	playAC130InboundSound()


	surface.PlaySound("killstreak_rewards/ac-130_" .. /*teamType*/"friendly" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")	//  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function playAC130IncomingSound()	//	CREATE A FUNCTION CALLED:	playAC130IncomingSound()


	surface.PlaySound("killstreak_rewards/ac-130_" .. /*teamType*/"enemy" .. "_inbound" .. LocalPlayer():GetNetworkedString("MW2TeamSound") ..  ".wav")  //  PLAY THE APPROPRIATE SOUND IN RELATION TO THE USER'S CHOSEN TEAM


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ErrorMessage()
	-- Lua generated by DermaDesigner

	local DLabel1
	local ACE

	ACE = vgui.Create('DFrame')
	ACE:SetSize(357, 66)
	ACE:Center()
	ACE:SetTitle('AC-130 Error')
	ACE:SetBackgroundBlur(true)
	ACE:MakePopup()

	DLabel1 = vgui.Create('DLabel')
	DLabel1:SetParent(ACE)
	DLabel1:SetPos(18, 35)
	DLabel1:SetText("You can't use the AC-130 in this map. Reason: Not enough room")
	DLabel1:SizeToContents()
end

usermessage.Hook("MW2_AC130_Kill_Sounds", PlayAC130KillSound)
usermessage.Hook("AC_130_SetUpHUD", setUpHUD)
usermessage.Hook("AC_130_RemoveHUD", removeHUD)
usermessage.Hook("AC_130_Error", ErrorMessage)


usermessage.Hook( "MW2_LOCKHEED_FRIENDLY", LOCKHEED_FRIENDLY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_LOCKHEED_FRIENDLY"  -  RUN THE FUNCTION:	LOCKHEED_FRIENDLY()


usermessage.Hook( "MW2_LOCKHEED_ENEMY", LOCKHEED_ENEMY )	//	IF THE SYSTEM DETECTS THAT A MESSAGE HAS BEEN SENT TO THE USER *AND* THAT MESSAGE IS SPECIFICALLY:	"MW2_LOCKHEED_ENEMY"  -  RUN THE FUNCTION:	LOCKHEED_ENEMY()
