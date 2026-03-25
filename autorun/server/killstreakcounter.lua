if not SERVER then return end


AddCSLuaFile( "autorun/client/map_overlay.lua" )	//	MARK THE "map_overlay.lua" FILE AS IMPORTANT AND SEND IT TO CLIENTS


util.AddNetworkString( "ChosenKillstreaks" )

util.AddNetworkString( "SetMW2Voices" )

util.AddNetworkString( "MW2_DropLocation_Overlay_Stream" )

util.AddNetworkString( "SupplyCrate_GiveReward" )

util.AddNetworkString( "MW2_DropLoc_Overlay_UM" )	 //  DUE TO THE IMPLEMENTATION OF THE (OFFICIAL) NETWORK LIBRARY, THIS SPECIFIC EVENT MUST BE PRECACHED

util.AddNetworkString( "MW2NukeEffectOwner" )

util.AddNetworkString( "setMW2PlayerVars" )  //  REQUIRED FOR EFFICIENT OPERATION OF THE KILLSTREAK MENU  -  WHICH WAS ORIGINALLY DAMAGED BUT HAS SINCE BEEN PATCHED, WITH THE ADDITION OF THIS SINGLE LINE. THIS LINE FIXES THE "UNPOOLED MESSAGE NAME" ERROR

util.AddNetworkString( "START_CAPTURING" )	//	REQUIRED TO KEEP THE SUPPLY CRATE SYSTEM STABLE

util.AddNetworkString( "STOP_CAPTURING" )	//	REQUIRED TO KEEP THE SUPPLY CRATE SYSTEM STABLE

util.AddNetworkString( "UAV_STATUS" )	//	REQUIRED FOR UAV STABILITY

util.AddNetworkString( "COUNTER_UAV_STATUS" )	//	REQUIRED FOR STABLE ANTI-CHEAT WHILE COUNTER UAV IS ACTIVE

util.AddNetworkString( "EMP_STATUS" )	//	REQUIRED FOR STABLE ANTI-CHEAT WHILE EMP IS ACTIVE

util.AddNetworkString( "STATUS" )	//	ALLOWS THE SERVER TO SEND MESSAGES REGARDING MAP COMPATIBILITY TO THE SERVER OPERATOR


MW2KillStreakAddon = 1


MW2_KillStreaks_EMP_Team = -1


EMP_TEAM_CHECK = NULL	//	CREATE GLOBAL VARIABLE CALLED:	"EMP_TEAM_CHECK"  -  THIS IS USED TO STORE THE TEAM OF AN EMP ALREADY IN USE


local enableKillStreaks = CreateConVar ( "MW2_KILLSTREAKS_ENABLED", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )


local maxNpcKills = CreateConVar ( "MW2_NPC_REQUIREMENT", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } );


local MW2AllowUseOfNuke = CreateConVar ( "MW2_ALLOW_CLIENT_USE_NUKE", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } );


local MW2AllowTeams = CreateConVar ( "MW2_TEAMS_ENABLED", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } );


local friendlysNpcs = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }


local easyKillNpcs = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }


function Run_Overlay( ply )		//	CREATE CUSTOM FUNCTION CALLED "Run_Overlay"  -  ACCEPT NEWLY-CONNECTED PLAYER AS THE PARAMETER


	if ply:IsValid() == true and ply:Alive() == true then	//	CHECK:	IF THE PLAYER WHO JOINED IS VALID *AND* ALIVE, THEN...


		timer.Simple( 10, function()	//	CREATE A SIMPLE TIMER FOR TEN (10) SECONDS. AFTER TEN SECONDS, DO THE FOLLOWING...


			ply:SendLua( "include( 'autorun/client/map_overlay.lua' )" )	//	EXECUTE THE "map_overlay.lua" SCRIPT ON THE CONNECTED CLIENT  -  THIS IS ESSENTIALLY EXECUTED ON THE CLIENT'S SYSTEM BY THE SERVER DIRECTLY


		end )	//	CLOSE FUNCTION ( TELL THE SYSTEM THE TIMER IS FULLY DEFINED )


	end  //  FINISH THE "IF" STATEMENT


end  //  TELL THE SYSTEM THAT THE FUNCTION IS FULLY DEFINED


local function giveAmmo(pl)
	local ammoAmount = 100;
	local healthAmount = 25;
	local armorAmount = 50;
	for k,v in pairs(pl:GetWeapons()) do
		pl:GiveAmmo(ammoAmount, v:GetPrimaryAmmoType());
	end
	pl:SetHealth( pl:Health() + healthAmount )
	pl:SetArmor( pl:Armor() + armorAmount )
end

local function addKillStreak(ply, str, isCare)
	if str == "ammo" then giveAmmo(ply); return; end

	if isCare == nil then isCare = false; end
	ply:SetNetworkedString("CurrentMW2KillStreak", str)
	ply:SetNetworkedString("MW2NewKillstreak", str .. "+".. ply.MW2KV.StreakID)
	ply.MW2KV.StreakID = ply.MW2KV.StreakID + 1;
	table.insert(ply.MW2KV.killStreaks, {str, isCare})
end


function CHECK_MOD()	//	CREATE GLOBAL FUNCTION CALLED:	"CHECK_MOD"


	cvars.AddChangeCallback( "MW2_KILLSTREAKS_ENABLED", function()	//	ADD A CALLBACK FUNCTION TO THE "MW2_KILLSTREAKS_ENABLED" CONSOLE VARIABLE ( WHEN THE CONSOLE VARIABLE IS CHANGED, DO THE FOLLOWING... )


		if GetConVar( "MW2_KILLSTREAKS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF THE KILLSTREAKS ARE *ENABLED* BY AN ADMINISTRATOR, THEN...


			BroadcastLua( [[ chat.AddText( Color( 0, 255, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THE KILLSTREAKS ARE NOW ENABLED!" ) ]] )	//	BROADCAST MESSAGE TO ALL PLAYERS CONNECTED TO THE SERVER


		elseif GetConVar( "MW2_KILLSTREAKS_ENABLED" ):GetInt() == 0 then	//	IF THE KILLSTREAKS ARE *DISABLED* BY AN ADMINISTRATOR, THEN...


			BroadcastLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THE KILLSTREAKS ARE NOW DISABLED!" ) ]] )	//	BROADCAST MESSAGE TO ALL PLAYERS CONNECTED TO THE SERVER


		end  //  FINISH THE CHECK


	end, "MOD_CHECK" )	//	COMPLETE THE FUNCTION AND NAME THE CALLBACK "MOD_CHECK"


end  //  COMPLETE FUNCTION


function CHECK_NUKE()	//	CREATE GLOBAL FUNCTION CALLED:	"CHECK_NUKE"


	cvars.AddChangeCallback( "MW2_ALLOW_CLIENT_USE_NUKE", function()	//	ADD A CALLBACK FUNCTION TO THE "MW2_ALLOW_CLIENT_USE_NUKE" CONSOLE VARIABLE ( WHEN THE CONSOLE VARIABLE IS CHANGED, DO THE FOLLOWING... )


		if GetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" ):GetInt() != 0 then	//	CHECK:	IF THE NUKE IS *ENABLED* FOR CLIENTS, THEN...


			BroadcastLua( [[ chat.AddText( Color( 0, 255, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  CLIENTS MAY NOW USE A NUKE!" ) ]] )	//	BROADCAST MESSAGE TO ALL PLAYERS CONNECTED TO THE SERVER


		elseif GetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" ):GetInt() == 0 then	//	IF THE NUKE IS *DISABLED* FOR CLIENTS, THEN...


			BroadcastLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  CLIENTS MAY NOT USE A NUKE!" ) ]] )	//	BROADCAST MESSAGE TO ALL PLAYERS CONNECTED TO THE SERVER


		end  //  FINISH THE CHECK


	end, "NUKE_CHECK" )	//	COMPLETE THE FUNCTION AND NAME THE CALLBACK "NUKE_CHECK"


end  //  COMPLETE THE FUNCTION


function CHECK_TEAM()	//	CREATE GLOBAL FUNCTION CALLED:	"CHECK_TEAM"


	cvars.AddChangeCallback( "MW2_TEAMS_ENABLED", function()	//	ADD A CALLBACK FUNCTION TO THE "MW2_TEAMS_ENABLED" CONSOLE VARIABLE ( WHEN THE CONSOLE VARIABLE IS CHANGED, DO THE FOLLOWING... )


		if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS ARE *ENABLED*, THEN...


			BroadcastLua( [[ chat.AddText( Color( 0, 255, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  TEAMS ARE NOW ENABLED!" ) ]] )	//	BROADCAST MESSAGE TO ALL PLAYERS CONNECTED TO THE SERVER


		elseif GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() == 0 then	//	IF TEAMS ARE *DISABLED*, THEN...


			BroadcastLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  TEAMS ARE NOW DISABLED!" ) ]] )  //  BROADCAST MESSAGE TO ALL PLAYERS CONNECTED TO THE SERVER


		end  //  FINISH THE CHECK


	end, "TEAM_CHECK" )  //  COMPLETE THE FUNCTION AND NAME THE CALLBACK "TEAM_CHECK"


end  //  COMPLETE FUNCTION


function CHECK_NPC_REQUIREMENT()	//	CREATE GLOBAL FUNCTION CALLED:	"CHECK_NPC_REQUIREMENT"


	cvars.AddChangeCallback( "MW2_NPC_REQUIREMENT", function()	//	ADD A CALLBACK FUNCTION TO THE "MW2_NPC_REQUIREMENT" CONSOLE VARIABLE ( WHEN THE CONSOLE VARIABLE IS CHANGED, DO THE FOLLOWING... )


		if GetConVar( "MW2_KILLSTREAKS_ENABLED" ) != 0 then		//	CHECK:	IF THE KILLSTREAKS ARE *ENABLED*, THEN...


			local PLAYER = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "PLAYER"	-	STORE ALL HUMAN PLAYERS FOUND IN THE SERVER


			for Key, Value in pairs( PLAYER ) do	//	FOR EACH PLAYER FOUND, DO THE FOLLOWING...


				Value.MW2KV.npcKills = 0	//	RESET THE PLAYER'S NPC KILLS TO "0".


			end  //  FINISH THE LOOP


		end  //  FINISH THE CHECK


	end, "NPC_CHECK" )  //  COMPLETE THE FUNCTION AND NAME THE CALLBACK "NPC_CHECK"


end  //  COMPLETE FUNCTION


function ADD_HARRIER_SOUND()	//	CREATE GLOBAL FUNCTION CALLED:	"ADD_HARRIER_SOUND"


	sound.Add( {	//	ADD SOUND


		name = "Harrier_Hover",  //  NAME


		level = 100,	//	VOLUME


		sound = "killstreak_rewards/harrier_hover.wav"	//	USE THIS SOUND FILE


	} )  //  FINISH ADDING SOUND


end  //  CLOSE THE FUNCTION


local function playerJoin( ply ) --when a player joins the server initailizes the nessacary variables


	ply.MW2KV = {}; -- MW2 Killstreak Variables
	ply.MW2KV.npcKills = 0;
	ply.MW2KV.plKills = 0;
	ply.MW2KV.killStreaks = {}
	ply.MW2KV.curKillstreaks = {}
	ply.MW2KV.newKillstreaks = {}
	ply.MW2KV.StreakID = 1;

	ply.MW2KV.addKillStreak = addKillStreak;

	ply:SetNetworkedString("CurrentMW2KillStreak","none")
	ply.MW2KV.FirstSpawn = true;
	local teamNum = math.random(1,5)
	ply:SetTeam(teamNum);
	ply:SetNetworkedString("MW2TeamSound", tostring( teamNum ))
	ply:SetNetworkedString("MW2NewKillstreak", "none")
	ply:SetNetworkedBool("MW2AC130ThermalView", true)


	Run_Overlay( ply )	//	WHEN A NEW PLAYER FULLY CONNECTS TO THE SERVER, RUN CUSTOM FUNCTION DEFINED ABOVE ( PASS THE SPECIFIC PLAYER WHO CONNECTED AS ARGUMENT )


end


hook.Add( "PlayerInitialSpawn" ,"MW2SetUpKillStreakVars", playerJoin )	//	WHEN A PLAYER SPAWNS IN THE SERVER FOR THE FIRST TIME, RUN FUNCTION ABOVE CALLED:	"playerJoin"


net.Receive( "STATUS", function( LENGTH, PLY )	//	"LISTEN" FOR THE MESSAGE CALLED "STATUS" FROM A CLIENT ( USER )


	if ( IsValid( PLY ) and PLY:IsPlayer() ) then	//	CHECK:	IF A MESSAGE IS DETECTED AND THE PLAYER WHO SENT THE MESSAGE IS VALID, *AND* THE PLAYER IS INDEED A PLAYER, THEN...


		if net.ReadInt( 2 ) == 0 then	//	CHECK THE MESSAGE RECEIVED:	IF THE MESSAGE RECEIVED EQUALS "0", THEN...


			CHECK_MOD()  //  MONITOR THE KILLSTREAKS


			CHECK_NUKE()  //  MONITOR THE NUKE


			CHECK_TEAM()  //  MONITOR THE TEAMS


			CHECK_NPC_REQUIREMENT()  //  MONITOR THE NPC REQUIREMENT


			ADD_HARRIER_SOUND()  //  CALL FUNCTION DEFINED ABOVE

			
			if PLY:EntIndex() == 1 then		//	IF THE PLAYER SENDING THE MESSAGE IS THE *FIRST* PLAYER TO JOIN THE SERVER (HAVING AN INDEX OF "1"), THEN...
			
			
				print( "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THIS MAP IS COMPATIBLE WITH THE KILLSTREAKS!" )	//	NOTIFY THE SERVER OPERATOR THAT THE KILLSTREAKS *ARE COMPATIBLE* WITH THE CURRENT MAP
		
		
			end		//	FINISH CHECKING FOR THE "FIRST" PLAYER
		
		
		else	//	IF THE MESSAGE RECEIVED IS ANYTHING OTHER THAN "0", THEN...


			cvars.RemoveChangeCallback( "MW2_KILLSTREAKS_ENABLED", "MOD_CHECK" )	//	REMOVE THE CALLBACK PLACED ON THE "MW2_KILLSTREAKS_ENABLED" CONSOLE VARIABLE ( IF THE CALLBACK EXISTS )


			cvars.RemoveChangeCallback( "MW2_ALLOW_CLIENT_USE_NUKE", "NUKE_CHECK" )  //	REMOVE THE CALLBACK PLACED ON THE "MW2_ALLOW_CLIENT_USE_NUKE" CONSOLE VARIABLE ( IF THE CALLBACK EXISTS )


			cvars.RemoveChangeCallback( "MW2_TEAMS_ENABLED", "TEAM_CHECK" )  //	REMOVE THE CALLBACK PLACED ON THE "MW2_TEAMS_ENABLED" CONSOLE VARIABLE ( IF THE CALLBACK EXISTS )


			cvars.RemoveChangeCallback( "MW2_NPC_REQUIREMENT", "NPC_CHECK" )  //	REMOVE THE CALLBACK PLACED ON THE "MW2_NPC_REQUIREMENT" CONSOLE VARIABLE ( IF THE CALLBACK EXISTS )


			MW2KillStreakAddon = 0;			//	AUTOMATICALLY DISABLE THE KILLSTREAKS ADDON


			if PLY:EntIndex() == 1 then		//	IF THE PLAYER SENDING THE MESSAGE IS THE *FIRST* PLAYER TO JOIN THE SERVER (HAVING AN INDEX OF "1"), THEN...	
			
			
				print( "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THIS MAP IS NOT COMPATIBLE WITH THE KILLSTREAKS!" )	//	NOTIFY THE SERVER OPERATOR THAT THE KILLSTREAKS ARE *NOT COMPATIBLE* WITH THE CURRENT MAP
		
		
			end		//	FINISH CHECKING FOR THE "FIRST" PLAYER
		
		
		end  //  FINISH CHECKING THE MESSAGE


	end  //  FINISH CHECKING THE PLAYER WHO SENT THE MESSAGE


end )	//	NOTIFY THE SYSTEM THAT THE MESSAGE HAS BEEN DEALT WITH APPROPRIATELY


local function checkNPC(victim)	--Disallow people from killing freindly NPCs and easy to kill NPCs like breen
	if table.HasValue(friendlysNpcs, victim:GetClass()) || table.HasValue(easyKillNpcs, victim:GetClass()) then return false;
	else return true;
	end
end

local function canUseStreak(ply, streak)
	if table.HasValue(ply.MW2KV.curKillstreaks, streak) then return true; end
	return false;
end

local function checkKills(ply)
	local kills = ply.MW2KV.plKills;

	if kills == 3 && canUseStreak(ply, "UAV") then
		addKillStreak(ply,"uav");
	elseif kills == 4 && canUseStreak(ply, "Care Package") then
		addKillStreak(ply,"care_package");
	elseif kills == 4 && canUseStreak(ply, "COUNTER UAV") then
		addKillStreak(ply,"mw2_Counter_UAV");
	elseif kills == 5 && canUseStreak(ply, "Predator Missile") then
		addKillStreak(ply,"predator_missile");
	elseif kills == 5 && canUseStreak(ply, "Sentry Gun") then
		addKillStreak(ply,"mw2_sentry_gun_package");
	elseif kills == 6 && canUseStreak(ply, "Precision Airstrike")	then
		addKillStreak(ply,"precision_airstrike");
	elseif kills == 7 && canUseStreak(ply, "Harrier") then
		addKillStreak(ply,"harrier");
	elseif kills == 7 && canUseStreak(ply, "Attack Helicopter") then
		addKillStreak(ply,"mw2_attack_helicopter");
	elseif kills == 8  && canUseStreak(ply, "Emergency Airdrop") then
		addKillStreak(ply,"emergency_airdrop");
	elseif kills == 9  && canUseStreak(ply, "Stealth Bomber") then
		addKillStreak(ply,"stealth_bomber");
	elseif kills == 11 && canUseStreak(ply, "AC-130") then
		addKillStreak(ply,"ac-130");
	elseif kills == 15 && canUseStreak(ply, "EMP") then
		addKillStreak(ply,"mw2_EMP");
	elseif kills == 25 && canUseStreak(ply, "NUKE") then


		if GetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" ):GetInt() != 0 /* and ply:IsAdmin() == false */ then	//	CHECK:	IF THE NUKE IS *ENABLED* FOR CLIENTS, THEN...


			addKillStreak( ply, "Tactical_Nuke" );	//	GIVE THE PLAYER THE NUKE


/*		elseif ply:IsAdmin() == true then	//	IF THE PLAYER THAT ACHIEVED "25" KILLS *IS AN ADMINISTRATOR*, THEN... (CODE CURRENTLY DISABLED)


			addKillStreak( ply, "Tactical_Nuke" );	//	GIVE THE PLAYER THE NUKE

*/

		else	//	IF THE NUKE IS *DISABLED* FOR CLIENTS, THEN...


			ply:SendLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THE NUKE IS CURRENTLY DISABLED FOR CLIENTS!" ) ]] )  //  PRINT A MESSAGE TO THE USER IN HIS OR HER CHAT FEED


		end  //  FINISH THE CHECK


	end


end


local function npcDeath( victim, killer, weapon )   //	CREATE A LOCAL FUNCTION CALLED:  "npcDeath"  -  ACCEPT THREE PARAMETERS


	if enableKillStreaks:GetInt() != 0 and maxNpcKills:GetInt() != 0 and MW2KillStreakAddon != 0 then		//	CHECK:	IF THE KILLSTREAKS ARE *NOT DISABLED*, **AND** THE NPC REQUIREMENT IS *NOT EQUAL* TO "0", **AND** THE KILLSTREAKS ADDON ITSELF IS *NOT* DISABLED ( THE MAP *IS* COMPATIBLE WITH THE KILLSTREAKS ADDON ), THEN...


		if killer:IsPlayer() and killer:Alive() && checkNPC(victim) then


			--	if weapon:GetVar( "FromCarePackage", false ) then return end


			if victim:GetClass() == "npc_antlionguard" || victim:GetClass() == "npc_strider" then


				killer.MW2KV.npcKills = killer.MW2KV.npcKills + 1;


				checkKills(killer);


			else


				killer.MW2KV.npcKills = killer.MW2KV.npcKills + 1;


			end


			if killer.MW2KV.npcKills == maxNpcKills:GetInt() then


				killer.MW2KV.npcKills = 0;


				killer.MW2KV.plKills = killer.MW2KV.plKills + 1;


				checkKills(killer);


			end


		end


	end  //  FINISH THE CHECK


end  //  COMPLETE THE FUNCTION


hook.Add( "OnNPCKilled", "MW2KillstreakCounterForNPC", npcDeath )	//	ADD A HOOK:  EACH TIME AN NPC IS KILLED, RUN THE FUNCTION "npcDeath" DEFINED ABOVE


local function playerDies( victim, weapon, killer )  //  CREATE LOCAL FUNCTION CALLED "playerDies"	-	USE THREE PARAMETERS


	if enableKillStreaks:GetInt() != 0 and MW2KillStreakAddon != 0 then  //  CHECK THE MOD STATUS:	IF THE KILLSTREAKS ARE *NOT DISABLED*, **AND** THE KILLSTREAKS ADDON ITSELF IS *NOT* DISABLED ( THE MAP *IS* COMPATIBLE WITH THE KILLSTREAKS ADDON ), THEN...


		if victim:IsPlayer() and killer:IsWorld() == false and killer:GetClass() != "sent_supplycrate" then  //  IF THE PLAYER WHO DIED *IS INDEED* A PLAYER, **AND** THAT PLAYER IS *NOT* KILLED BY "THE WORLD", **AND** THE PLAYER IS *NOT* KILLED BY A SUPPLY CRATE, THEN...


//			*****	"BLUE ON BLUE" ( FRIENDLY FIRE INCIDENT )	*****


			if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 and killer:IsPlayer() and killer:Team() == victim:Team() and killer != victim then	//  CHECK:	IF TEAMS *ARE ENABLED*, **AND** THE KILLER *IS A PLAYER*, **AND** THE KILLER IS ON THE *SAME* TEAM AS THE VICTIM, **AND** IT WAS *NOT* A SUICIDE ( THE PLAYER DID NOT KILL THEMSELVES ), THEN...


				victim:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  A FRIENDLY player killed you! Don't worry... you still have your Killstreaks!" ) ]] );	//	PRINT A MESSAGE TO THE VICTIM'S CHAT THAT A FRIENDLY FIRE INCIDENT OCCURRED


			elseif GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 and killer:Team() != victim:Team() then		//	IF TEAMS ARE *ENABLED*, **AND** THERE WAS *NOT* A FRIENDLY FIRE INCIDENT, THEN...


				victim.MW2KV.npcKills = 0;	//	RESET NPC KILLS TO "0" ON THE VICTIM


				victim.MW2KV.plKills = 0;	//	RESET PLAYER KILLS TO "0" ON THE VICTIM


				victim.MW2KV.curKillstreaks = victim.MW2KV.newKillstreaks	//	REGISTER SELECTED KILLSTREAKS


				for k,v in pairs(victim.MW2KV.killStreaks) do -- If the player has any killstreaks and they were killed will make it so that their killstreaks will not get them kills next life


					v[2] = true;


				end


//				umsg.Start("ResetKillStreakIcon", victim);


//				umsg.End();


			elseif GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() == 0 or killer == victim then		//	IF TEAMS ARE *NOT ENABLED*, **OR** THE PLAYER KILLED THEMSELVES, THEN...


				victim.MW2KV.npcKills = 0;	//	RESET NPC KILLS TO "0" ON THE VICTIM


				victim.MW2KV.plKills = 0;	//	RESET PLAYER KILLS TO "0" ON THE VICTIM


				victim.MW2KV.curKillstreaks = victim.MW2KV.newKillstreaks	//	REGISTER SELECTED KILLSTREAKS


				for k,v in pairs(victim.MW2KV.killStreaks) do -- If the player has any killstreaks and they were killed will make it so that their killstreaks will not get them kills next life


					v[2] = true;


				end


//				umsg.Start("ResetKillStreakIcon", victim);


//				umsg.End();


			end  //  FINISH THE CHECK


		elseif victim:IsPlayer() and killer:IsWorld() == true or killer:GetClass() == "sent_supplycrate" then  //  IF THE PLAYER WHO DIED *IS INDEED* A PLAYER, **AND** THAT PLAYER WAS KILLED BY "THE WORLD", **OR** THE PLAYER WAS KILLED BY A SUPPLY CRATE, THEN...
			
			
				victim.MW2KV.npcKills = 0;	//	RESET NPC KILLS TO "0" ON THE VICTIM


				victim.MW2KV.plKills = 0;	//	RESET PLAYER KILLS TO "0" ON THE VICTIM


				victim.MW2KV.curKillstreaks = victim.MW2KV.newKillstreaks	//	REGISTER SELECTED KILLSTREAKS


				for k,v in pairs(victim.MW2KV.killStreaks) do -- If the player has any killstreaks and they were killed will make it so that their killstreaks will not get them kills next life


					v[2] = true;


				end


//				umsg.Start("ResetKillStreakIcon", victim);


//				umsg.End();


		else	//	IF THE PLAYER WAS KILLED BY ANYTHING ELSE, THEN...

		
				victim.MW2KV.npcKills = 0;	//	RESET NPC KILLS TO "0" ON THE VICTIM


				victim.MW2KV.plKills = 0;	//	RESET PLAYER KILLS TO "0" ON THE VICTIM


				victim.MW2KV.curKillstreaks = victim.MW2KV.newKillstreaks	//	REGISTER SELECTED KILLSTREAKS


				for k,v in pairs(victim.MW2KV.killStreaks) do -- If the player has any killstreaks and they were killed will make it so that their killstreaks will not get them kills next life


					v[2] = true;


				end


//				umsg.Start("ResetKillStreakIcon", victim);


//				umsg.End();			
			
			
		end  //  FINISH THE "IF" STATEMENT


		if killer:IsPlayer() && killer != victim then	//	IF THE KILLER *IS* A PLAYER, **AND** THERE WAS *NO* SUICIDE ( THE PLAYER DID NOT KILL THEMSELVES )


			if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 and killer:Team() == victim:Team() then	//  CHECK:  IF TEAMS *ARE ENABLED*, **AND** THE KILLER IS ON THE *SAME* TEAM AS THE VICTIM, THEN...


				killer:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  You killed a FRIENDLY!" ) ]] );	//	PRINT A MESSAGE TO THE KILLER'S CHAT THAT A FRIENDLY FIRE INCIDENT OCCURRED


			elseif ( GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() == 0 or killer:Team() != victim:Team() ) and killer:Alive() then		//	IF TEAMS ARE *NOT ENABLED*, **OR** THERE WAS *NOT* A FRIENDLY FIRE INCIDENT, ****AND**** THE KILLER *IS ALIVE*, THEN...


				killer.MW2KV.plKills = killer.MW2KV.plKills + 1;	//	INCREMENT THE PLAYER'S KILLS BY "1"


				checkKills(killer);  //  CHECK FOR KILLSTREAKS


			end  //  FINISH THE CHECK


		end  //  FINISH THE "IF" STATEMENT


	end  //  FINISH CHECKING THE MOD STATUS


end  //  COMPLETE THE FUNCTION


hook.Add( "PlayerDeath", "MW2KillstreakCounterForPlayer", playerDies )  //  ADD A HOOK:  EACH TIME A PLAYER DIES, RUN FUNCTION "playerDies" DEFINED ABOVE


local function FindSky(player)
	local pos = player:GetPos();
	local maxheight = 16384
	local startPos = pos;
	local endPos = Vector(pos.x, pos.y, maxheight);
	local filterList = {player}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local num = 0;
	local foundSky = false;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			foundSky = true;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
		else
			table.insert(filterList, traceData.Entity)
		end

		if num >= 300 then
			bool = false;
		end
		num = num + 1
	end

	return foundSky;
end

function useKillStreak( player, command, arguments )


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then 	  //	CHECK:	IF TEAMS *ARE ENABLED*, THEN...


		if MW2_KillStreaks_EMP_Team != -1 and MW2_KillStreaks_EMP_Team != NULL and player:Team() != MW2_KillStreaks_EMP_Team then  //  IF A TEAM USES AN EMP ( VALUE WOULD *NOT* BE "-1" ), **AND** THE EMP TEAM IS *NOT EQUAL* TO "-1", **AND** THE EMP TEAM IS *NOT EQUAL* TO "NULL", **AND** THE PLAYER USING A KILLSTREAK IS *NOT* ON THE SAME TEAM AS THE ONE WHO USED THE EMP, THEN...


			player:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  ENEMY EMP IN EFFECT  -  KILLSTREAKS TEMPORARILY DISABLED FOR YOUR TEAM!" ) ]] );  //  PRINT MESSAGE IN THE PLAYER'S CHAT


			return;  //  DENY PLAYER FROM USING THE KILLSTREAK


		elseif MW2_KillStreaks_EMP_Team != -1 and MW2_KillStreaks_EMP_Team != NULL and player:Team() == MW2_KillStreaks_EMP_Team then  //  IF A TEAM USES AN EMP ( VALUE WOULD *NOT* BE "-1" ), **AND** THE EMP TEAM IS *NOT EQUAL* TO "-1", **AND** THE EMP TEAM IS *NOT EQUAL* TO "NULL", **AND** THE PLAYER USING A KILLSTREAK *IS* ON THE SAME TEAM AS THE ONE WHO USED THE EMP, THEN...


			local remaingKillStreaks = table.Count(player.MW2KV.killStreaks)


			if remaingKillStreaks > 0 then


				local val = player.MW2KV.killStreaks[remaingKillStreaks][1];


				if val == "ac-130" || val == "predator_missile" then


					if !FindSky(player) then


						umsg.Start("ShowKillstreakSpawnError", player);


						umsg.End()


						return;


					end


				end


				local tab = table.remove(player.MW2KV.killStreaks)


				local streak = tab[1];


				local isCare = tab[2];


				player:SetNetworkedString("UsedKillStreak",streak)


				player:SetNetworkedBool("IsKillStreakFromCarePackage",isCare)


				player:Give(streak);


			end


			local killStr = player.MW2KV.killStreaks[remaingKillStreaks-1]


			if killStr != nil then


				player:SetNetworkedString("CurrentMW2KillStreak", tostring(killStr[1]))


			else


				player:SetNetworkedString("CurrentMW2KillStreak", "none")


			end


			return;


		elseif EMP_TEAM_CHECK != NULL and EMP_TEAM_CHECK != MW2_KillStreaks_EMP_Team then	//	IF THE TEAM THAT WAS STORED IN "EMP_TEAM_CHECK" IS *NOT EQUAL* TO "NULL", **AND** THE VALUE OF "EMP_TEAM_CHECK" IS *NOT EQUAL* TO THE VALUE OF THE "MW2_KillStreaks_EMP_Team" VARIABLE, THEN...


			player:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  EMP IN EFFECT  -  KILLSTREAKS TEMPORARILY DISABLED FOR ALL PLAYERS!" ) ]] );  //  PRINT MESSAGE IN THE PLAYER'S CHAT


			return;		//  DENY PLAYER FROM USING THE KILLSTREAK		


		end  //  FINISH THE "IF" STATEMENT


	elseif GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() == 0 and MW2_KillStreaks_EMP_Team != NULL and EMP_TEAM_CHECK != NULL then	//	IF TEAMS ARE *NOT ENABLED*, **AND** THE CURRENT EMP TEAM IS *NOT EQUAL* TO "NULL", **AND** THE VALUE OF "EMP_TEAM_CHECK" IS *NOT EQUAL* TO "NULL", THEN...


		player:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  EMP IN EFFECT  -  KILLSTREAKS TEMPORARILY DISABLED FOR ALL PLAYERS!" ) ]] );  //  PRINT MESSAGE IN THE PLAYER'S CHAT


		return;  //  DENY PLAYER FROM USING THE KILLSTREAK


	end  //  FINISH THE CHECK


//	*****  IF ALL OF THE ABOVE CHECKS FAIL, DO THE FOLLOWING  *****


	local remaingKillStreaks = table.Count(player.MW2KV.killStreaks)

	if remaingKillStreaks > 0 then

		local val = player.MW2KV.killStreaks[remaingKillStreaks][1];

		if val == "ac-130" || val == "predator_missile" then
			if !FindSky(player) then
				umsg.Start("ShowKillstreakSpawnError", player);
				umsg.End()
				return;
			end
		end

		local tab = table.remove(player.MW2KV.killStreaks)
		local streak = tab[1];
		local isCare = tab[2];
		player:SetNetworkedString("UsedKillStreak",streak)
		player:SetNetworkedBool("IsKillStreakFromCarePackage",isCare)
		player:Give(streak);
	end
	local killStr = player.MW2KV.killStreaks[remaingKillStreaks-1]
	if killStr != nil then
		player:SetNetworkedString("CurrentMW2KillStreak", tostring(killStr[1]))
	else
		player:SetNetworkedString("CurrentMW2KillStreak", "none")
	end


end


concommand.Add( "USE_KILLSTREAK", useKillStreak )


function setKillstreaks( ln,pl )
	local tab = net.ReadTable()
	if pl.MW2KV.FirstSpawn then
		pl.MW2KV.curKillstreaks = tab
		pl.MW2KV.newKillstreaks = tab
		pl.MW2KV.FirstSpawn = false;
	else
		pl.MW2KV.newKillstreaks = tab
	end
end
net.Receive( "ChosenKillstreaks", setKillstreaks )


function setMW2Voices( ln,pl )
	local tm = net.ReadFloat()
	pl:SetNetworkedString("MW2TeamSound", tm)
	if MW2AllowTeams:GetInt() == 1 then

		pl:SetTeam(tm);

	end
end


net.Receive( "SetMW2Voices", setMW2Voices )


function setMW2PlayerVars( ln, pl )


	pl:SetNetworkedBool( "MW2NukeEffectOwner", 1 )


	pl:SetNetworkedBool( "MW2AC130ThermalView", 1 )


end


net.Receive( "setMW2PlayerVars", setMW2PlayerVars )