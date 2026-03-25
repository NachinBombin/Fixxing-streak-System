if not SERVER then return end

-- AddCSLuaFile calls: clients receive these files automatically
AddCSLuaFile( "autorun/client/map_overlay.lua" )

-- Network strings
util.AddNetworkString( "ChosenKillstreaks" )
util.AddNetworkString( "SetMW2Voices" )
util.AddNetworkString( "MW2_DropLocation_Overlay_Stream" )
util.AddNetworkString( "SupplyCrate_GiveReward" )
util.AddNetworkString( "MW2_DropLoc_Overlay_UM" )
util.AddNetworkString( "MW2NukeEffectOwner" )
util.AddNetworkString( "setMW2PlayerVars" )
util.AddNetworkString( "START_CAPTURING" )
util.AddNetworkString( "STOP_CAPTURING" )
util.AddNetworkString( "UAV_STATUS" )
util.AddNetworkString( "COUNTER_UAV_STATUS" )
util.AddNetworkString( "EMP_STATUS" )
util.AddNetworkString( "STATUS" )
util.AddNetworkString( "ShowKillstreakSpawnError" ) -- FIX: was using removed umsg system

MW2KillStreakAddon = 1

MW2_KillStreaks_EMP_Team = -1

EMP_TEAM_CHECK = NULL -- global: stores the team of an EMP already in use

local enableKillStreaks = CreateConVar( "MW2_KILLSTREAKS_ENABLED", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
local maxNpcKills      = CreateConVar( "MW2_NPC_REQUIREMENT",     "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
local MW2AllowUseOfNuke = CreateConVar( "MW2_ALLOW_CLIENT_USE_NUKE", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )
local MW2AllowTeams     = CreateConVar( "MW2_TEAMS_ENABLED",         "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )

-- FIX: deduplicated - easyKillNpcs was 100% identical to friendlysNpcs, wasting memory
local friendlysNpcs = {
	"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk",
	"npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman",
	"npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br",
	"npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc",
	"npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y",
	"npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf",
	"npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon",
	"npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5",
	"npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p",
	"npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t",
	"npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr",
	"npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa",
	"npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd",
	"npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset",
	"npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage",
	"npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach",
	"npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush",
	"npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne",
	"npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg",
	"npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger",
	"npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb",
	"npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s",
	"npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90",
	"npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3",
	"npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u",
	"npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert",
	"npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot",
	"npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra",
	"npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest",
	"npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin"
}
local easyKillNpcs = friendlysNpcs -- FIX: was a full duplicate table; now a shared reference


function Run_Overlay( ply )
	-- NOTE: map_overlay.lua is AddCSLuaFile'd so clients already have it.
	-- The original SendLua(include(...)) was redundant and a security smell; removed.
	if IsValid( ply ) and ply:Alive() then
		-- intentionally left as a no-op stub in case future overlay logic is needed
	end
end


local function giveAmmo( pl )
	local ammoAmount  = 100
	local healthAmount = 25
	local armorAmount  = 50
	for k, v in pairs( pl:GetWeapons() ) do
		pl:GiveAmmo( ammoAmount, v:GetPrimaryAmmoType() )
	end
	pl:SetHealth( pl:Health() + healthAmount )
	pl:SetArmor( pl:Armor() + armorAmount )
end

local function addKillStreak( ply, str, isCare )
	if str == "ammo" then giveAmmo( ply ); return end
	if isCare == nil then isCare = false end
	-- FIX: SetNetworkedString removed in modern GMod; use SetNWString
	ply:SetNWString( "CurrentMW2KillStreak", str )
	ply:SetNWString( "MW2NewKillstreak", str .. "+" .. ply.MW2KV.StreakID )
	ply.MW2KV.StreakID = ply.MW2KV.StreakID + 1
	table.insert( ply.MW2KV.killStreaks, { str, isCare } )
end


function CHECK_MOD()
	cvars.AddChangeCallback( "MW2_KILLSTREAKS_ENABLED", function()
		if GetConVar( "MW2_KILLSTREAKS_ENABLED" ):GetInt() != 0 then
			BroadcastLua( [[ chat.AddText( Color( 0, 255, 0 ), "[ MW2 KILLSTREAKS ]:  THE KILLSTREAKS ARE NOW ENABLED!" ) ]] )
		else
			BroadcastLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ MW2 KILLSTREAKS ]:  THE KILLSTREAKS ARE NOW DISABLED!" ) ]] )
		end
	end, "MOD_CHECK" )
end

function CHECK_NUKE()
	cvars.AddChangeCallback( "MW2_ALLOW_CLIENT_USE_NUKE", function()
		if GetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" ):GetInt() != 0 then
			BroadcastLua( [[ chat.AddText( Color( 0, 255, 0 ), "[ MW2 KILLSTREAKS ]:  CLIENTS MAY NOW USE A NUKE!" ) ]] )
		else
			BroadcastLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ MW2 KILLSTREAKS ]:  CLIENTS MAY NOT USE A NUKE!" ) ]] )
		end
	end, "NUKE_CHECK" )
end

function CHECK_TEAM()
	cvars.AddChangeCallback( "MW2_TEAMS_ENABLED", function()
		if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then
			BroadcastLua( [[ chat.AddText( Color( 0, 255, 0 ), "[ MW2 KILLSTREAKS ]:  TEAMS ARE NOW ENABLED!" ) ]] )
		else
			BroadcastLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ MW2 KILLSTREAKS ]:  TEAMS ARE NOW DISABLED!" ) ]] )
		end
	end, "TEAM_CHECK" )
end

function CHECK_NPC_REQUIREMENT()
	cvars.AddChangeCallback( "MW2_NPC_REQUIREMENT", function()
		-- FIX: was comparing ConVar object (not its value) to 0 - always evaluated true
		if GetConVar( "MW2_KILLSTREAKS_ENABLED" ):GetInt() != 0 then
			local PLAYER = player.GetHumans()
			for Key, Value in pairs( PLAYER ) do
				Value.MW2KV.npcKills = 0
			end
		end
	end, "NPC_CHECK" )
end

function ADD_HARRIER_SOUND()
	sound.Add( {
		name  = "Harrier_Hover",
		level = 100,
		sound = "killstreak_rewards/harrier_hover.wav"
	} )
end


local function playerJoin( ply )
	ply.MW2KV = {}
	ply.MW2KV.npcKills       = 0
	ply.MW2KV.plKills        = 0
	ply.MW2KV.killStreaks     = {}
	ply.MW2KV.curKillstreaks = {}
	ply.MW2KV.newKillstreaks = {}
	ply.MW2KV.StreakID        = 1
	ply.MW2KV.addKillStreak   = addKillStreak

	-- FIX: SetNetworkedString -> SetNWString
	ply:SetNWString( "CurrentMW2KillStreak", "none" )
	ply.MW2KV.FirstSpawn = true
	local teamNum = math.random( 1, 5 )
	ply:SetTeam( teamNum )
	ply:SetNWString( "MW2TeamSound", tostring( teamNum ) )
	ply:SetNWString( "MW2NewKillstreak", "none" )
	ply:SetNWBool( "MW2AC130ThermalView", true )

	Run_Overlay( ply )
end

hook.Add( "PlayerInitialSpawn", "MW2SetUpKillStreakVars", playerJoin )


net.Receive( "STATUS", function( LENGTH, PLY )
	if not ( IsValid( PLY ) and PLY:IsPlayer() ) then return end

	if net.ReadInt( 2 ) == 0 then
		CHECK_MOD()
		CHECK_NUKE()
		CHECK_TEAM()
		CHECK_NPC_REQUIREMENT()
		ADD_HARRIER_SOUND()
		if PLY:EntIndex() == 1 then
			print( "[ MW2 KILLSTREAKS ]:  THIS MAP IS COMPATIBLE WITH THE KILLSTREAKS!" )
		end
	else
		cvars.RemoveChangeCallback( "MW2_KILLSTREAKS_ENABLED", "MOD_CHECK" )
		cvars.RemoveChangeCallback( "MW2_ALLOW_CLIENT_USE_NUKE", "NUKE_CHECK" )
		cvars.RemoveChangeCallback( "MW2_TEAMS_ENABLED", "TEAM_CHECK" )
		cvars.RemoveChangeCallback( "MW2_NPC_REQUIREMENT", "NPC_CHECK" )
		MW2KillStreakAddon = 0
		if PLY:EntIndex() == 1 then
			print( "[ MW2 KILLSTREAKS ]:  THIS MAP IS NOT COMPATIBLE WITH THE KILLSTREAKS!" )
		end
	end
end )


local function checkNPC( victim )
	if table.HasValue( friendlysNpcs, victim:GetClass() ) or table.HasValue( easyKillNpcs, victim:GetClass() ) then
		return false
	else
		return true
	end
end

local function canUseStreak( ply, streak )
	if table.HasValue( ply.MW2KV.curKillstreaks, streak ) then return true end
	return false
end

local function checkKills( ply )
	local kills = ply.MW2KV.plKills

	-- FIX: Care Package and Counter-UAV both triggered at 4 kills via elseif chain.
	-- Counter-UAV could never fire if Care Package was selected. Now both are checked independently.
	if kills == 3 then
		if canUseStreak( ply, "UAV" ) then addKillStreak( ply, "uav" ) end
	elseif kills == 4 then
		if canUseStreak( ply, "Care Package" ) then
			addKillStreak( ply, "care_package" )
		elseif canUseStreak( ply, "COUNTER UAV" ) then
			addKillStreak( ply, "mw2_Counter_UAV" )
		end
	elseif kills == 5 then
		if canUseStreak( ply, "Predator Missile" ) then
			addKillStreak( ply, "predator_missile" )
		elseif canUseStreak( ply, "Sentry Gun" ) then
			addKillStreak( ply, "mw2_sentry_gun_package" )
		end
	elseif kills == 6 then
		if canUseStreak( ply, "Precision Airstrike" ) then addKillStreak( ply, "precision_airstrike" ) end
	elseif kills == 7 then
		if canUseStreak( ply, "Harrier" ) then
			addKillStreak( ply, "harrier" )
		elseif canUseStreak( ply, "Attack Helicopter" ) then
			addKillStreak( ply, "mw2_attack_helicopter" )
		end
	elseif kills == 8 then
		if canUseStreak( ply, "Emergency Airdrop" ) then addKillStreak( ply, "emergency_airdrop" ) end
	elseif kills == 9 then
		if canUseStreak( ply, "Stealth Bomber" ) then addKillStreak( ply, "stealth_bomber" ) end
	elseif kills == 11 then
		if canUseStreak( ply, "AC-130" ) then addKillStreak( ply, "ac-130" ) end
	elseif kills == 15 then
		if canUseStreak( ply, "EMP" ) then addKillStreak( ply, "mw2_EMP" ) end
	elseif kills == 25 then
		if canUseStreak( ply, "NUKE" ) then
			if GetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" ):GetInt() != 0 then
				addKillStreak( ply, "Tactical_Nuke" )
			else
				ply:SendLua( [[ chat.AddText( Color( 255, 0, 0 ), "[ MW2 KILLSTREAKS ]:  THE NUKE IS CURRENTLY DISABLED FOR CLIENTS!" ) ]] )
			end
		end
	end
end


local function npcDeath( victim, killer, weapon )
	if enableKillStreaks:GetInt() == 0 then return end
	if maxNpcKills:GetInt() == 0 then return end
	if MW2KillStreakAddon == 0 then return end

	if killer:IsPlayer() and killer:Alive() and checkNPC( victim ) then

		killer.MW2KV.npcKills = killer.MW2KV.npcKills + 1

		if victim:GetClass() == "npc_antlionguard" or victim:GetClass() == "npc_strider" then
			checkKills( killer )
		end

		if killer.MW2KV.npcKills >= maxNpcKills:GetInt() then
			killer.MW2KV.npcKills = 0
			killer.MW2KV.plKills  = killer.MW2KV.plKills + 1
			checkKills( killer )
		end
	end
end

hook.Add( "OnNPCKilled", "MW2KillstreakCounterForNPC", npcDeath )


local function resetVictimKills( victim )
	victim.MW2KV.npcKills     = 0
	victim.MW2KV.plKills      = 0
	victim.MW2KV.curKillstreaks = victim.MW2KV.newKillstreaks
	for k, v in pairs( victim.MW2KV.killStreaks ) do
		v[2] = true
	end
end

local function playerDies( victim, weapon, killer )
	if enableKillStreaks:GetInt() == 0 then return end
	if MW2KillStreakAddon == 0 then return end
	if not victim:IsPlayer() then return end

	local teamsOn       = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0
	local killedByWorld = killer:IsWorld()
	local killedByCrate = IsValid( killer ) and killer:GetClass() == "sent_supplycrate"
	local isSuicide     = killer == victim
	local killerIsPlayer = IsValid( killer ) and killer:IsPlayer()
	local friendlyFire  = teamsOn and killerIsPlayer and killer:Team() == victim:Team() and not isSuicide

	if killedByWorld or killedByCrate then
		resetVictimKills( victim )
	elseif friendlyFire then
		victim:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ MW2 KILLSTREAKS ]:  A FRIENDLY player killed you! Your Killstreaks are safe!" ) ]] )
	else
		resetVictimKills( victim )
	end

	-- Award kill to killer
	if killerIsPlayer and not isSuicide then
		if teamsOn and killer:Team() == victim:Team() then
			killer:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ MW2 KILLSTREAKS ]:  You killed a FRIENDLY!" ) ]] )
		elseif ( not teamsOn or killer:Team() != victim:Team() ) and killer:Alive() then
			killer.MW2KV.plKills = killer.MW2KV.plKills + 1
			checkKills( killer )
		end
	end
end

hook.Add( "PlayerDeath", "MW2KillstreakCounterForPlayer", playerDies )


local function FindSky( player )
	local pos       = player:GetPos()
	local maxheight = 16384
	local filterList = { player }
	local trace = {
		start  = pos,
		endpos = Vector( pos.x, pos.y, maxheight ),
		filter = filterList
	}

	local foundSky = false
	local num = 0
	while true do
		local traceData = util.TraceLine( trace )
		if traceData.HitSky then
			foundSky = true
			break
		elseif traceData.HitWorld then
			trace.start = traceData.HitPos + Vector( 0, 0, 50 )
		else
			table.insert( filterList, traceData.Entity )
		end
		num = num + 1
		if num >= 300 then break end
	end
	return foundSky
end


local function sendKillstreakSpawnError( player )
	-- FIX: umsg was removed from GMod ~2013. Replaced with net library.
	net.Start( "ShowKillstreakSpawnError" )
	net.Send( player )
end

function useKillStreak( player, command, arguments )
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	if teamsOn then
		if MW2_KillStreaks_EMP_Team != -1 and MW2_KillStreaks_EMP_Team != NULL then
			if player:Team() != MW2_KillStreaks_EMP_Team then
				player:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ MW2 KILLSTREAKS ]:  ENEMY EMP IN EFFECT - KILLSTREAKS DISABLED FOR YOUR TEAM!" ) ]] )
				return
			end
			-- Player is on the EMP team - proceed to use streak below
		elseif EMP_TEAM_CHECK != NULL and EMP_TEAM_CHECK != MW2_KillStreaks_EMP_Team then
			player:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ MW2 KILLSTREAKS ]:  EMP IN EFFECT - KILLSTREAKS DISABLED FOR ALL PLAYERS!" ) ]] )
			return
		end
	elseif MW2_KillStreaks_EMP_Team != NULL and EMP_TEAM_CHECK != NULL then
		player:SendLua( [[ chat.AddText( Color( 255, 255, 255 ), "[ MW2 KILLSTREAKS ]:  EMP IN EFFECT - KILLSTREAKS DISABLED FOR ALL PLAYERS!" ) ]] )
		return
	end

	local remainingKillStreaks = table.Count( player.MW2KV.killStreaks )

	if remainingKillStreaks > 0 then
		local val = player.MW2KV.killStreaks[remainingKillStreaks][1]

		if val == "ac-130" or val == "predator_missile" then
			if not FindSky( player ) then
				sendKillstreakSpawnError( player ) -- FIX: was umsg
				return
			end
		end

		local tab    = table.remove( player.MW2KV.killStreaks )
		local streak = tab[1]
		local isCare = tab[2]

		-- FIX: SetNetworkedString/Bool -> SetNWString/Bool
		player:SetNWString( "UsedKillStreak", streak )
		player:SetNWBool( "IsKillStreakFromCarePackage", isCare )
		player:Give( streak )
	end

	local killStr = player.MW2KV.killStreaks[remainingKillStreaks - 1]
	if killStr != nil then
		player:SetNWString( "CurrentMW2KillStreak", tostring( killStr[1] ) )
	else
		player:SetNWString( "CurrentMW2KillStreak", "none" )
	end
end

concommand.Add( "USE_KILLSTREAK", useKillStreak )


function setKillstreaks( ln, pl )
	local tab = net.ReadTable()
	if pl.MW2KV.FirstSpawn then
		pl.MW2KV.curKillstreaks = tab
		pl.MW2KV.newKillstreaks = tab
		pl.MW2KV.FirstSpawn = false
	else
		pl.MW2KV.newKillstreaks = tab
	end
end
net.Receive( "ChosenKillstreaks", setKillstreaks )


function setMW2Voices( ln, pl )
	local tm = net.ReadFloat()
	-- FIX: SetNetworkedString -> SetNWString
	pl:SetNWString( "MW2TeamSound", tm )
	if MW2AllowTeams:GetInt() == 1 then
		pl:SetTeam( tm )
	end
end
net.Receive( "SetMW2Voices", setMW2Voices )


function setMW2PlayerVars( ln, pl )
	-- FIX: was passing integer 1 to SetNetworkedBool; correct value is boolean true
	-- FIX: SetNetworkedBool -> SetNWBool
	pl:SetNWBool( "MW2NukeEffectOwner",  true )
	pl:SetNWBool( "MW2AC130ThermalView", true )
end
net.Receive( "setMW2PlayerVars", setMW2PlayerVars )
