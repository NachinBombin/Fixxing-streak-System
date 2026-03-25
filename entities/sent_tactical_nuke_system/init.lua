AddCSLuaFile( 'shared.lua' )


AddCSLuaFile( 'cl_init.lua' )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS


include('shared.lua')


ENT.TimeToDetonate = CurTime() + 10;
ENT.DetonatePos = NULL;
ENT.CountDown = 10;
ENT.TimerDelay = CurTime();
ENT.NukeSpawned = false;


ENT.Killable_Killstreaks = { "mw2_counterUAV", "mw2_SentryGun", "mw2_UAV", "sent_ac-130", "sent_harrier", "npc_bullseye" }	//	CREATE A TABLE CALLED "Killable_Killstreaks" TO STORE THE VARIOUS "KILLABLE" KILLSTREAKS


function ENT:Initialize()
	SetGlobalString("MW2_Nuke_CountDown_Timer", "")
	self.TimeToDetonate = CurTime() + 10;
	self.Owner = self.Entity:GetVar( "owner", Entity( 1 ) )
	SetGlobalString( "MW2_Nuke_Player", self.Owner )
	self:SetModel( "models/dav0r/camera.mdl" ) -- Just need a model, doesnt matter what it is
	self:SetPos( Vector(0,0, self:findGround()) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:GetPhysicsObject():EnableGravity(false)
	self:SetNotSolid(true)


	for Key, Value in pairs( player.GetHumans() ) do


		umsg.Start( "MW2_Nukes_SetUpHUD", Value );


		umsg.End()


	end


	self:SEND_NUKE()	//	AFTER THE NUKE HAS BEEN SUCCESSFULLY INITIALIZED, RUN CUSTOM FUNCTION EXPLAINED BELOW


end


function ENT:SEND_NUKE()  //	CREATE A GLOBAL FUNCTION CALLED:	"SEND_NUKE"


	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...


		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...


			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE NUKE, THEN...


				umsg.Start( "MW2_NUKE_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_NUKE_FRIENDLY"  -  SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			elseif Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE NUKE, THEN...


				umsg.Start( "MW2_NUKE_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_NUKE_ENEMY"  -  SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE


				print( "[ NUKE BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE


			end  //  FINISH THE "IF" STATEMENT


		end  //  FINISH LOOPING


	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...


		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...


			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE NUKE, THEN...


				umsg.Start( "MW2_NUKE_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_NUKE_FRIENDLY"  -  SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			elseif Value != self.Owner then		//	IF THE PLAYER CURRENTLY BEING LOOKED AT IS *NOT THE OWNER* OF THE NUKE, THEN...


				umsg.Start( "MW2_NUKE_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_NUKE_ENEMY"  -  SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE


				print( "[ NUKE BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE


			end  //  FINISH THE "IF" STATEMENT


		end  //  FINISH THE LOOP


	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ENT:Think()
	if CurTime() < self.TimeToDetonate && self.TimerDelay < CurTime() then
		self.TimerDelay = CurTime() + 0.1;
		self.CountDown = self.CountDown - 0.1;

		local timerString = self.CountDown .. "";
		SetGlobalString("MW2_Nuke_CountDown_Timer", timerString)
	elseif CurTime() > self.TimeToDetonate && !self.NukeSpawned then


		self:SpawnNuke();


		timer.Simple( 5, function()


			self:Remove()


		end )


	end


	self.Entity:NextThink( CurTime() + 0.01 )


	return true


end



function ENT:SpawnNuke()


	self.NukeSpawned = true;


	umsg.Start("MW2_Nuke_RemoveHUD", self.Owner);


	umsg.End()


	local nuke = ents.Create("sent_tactical_nuke")


		nuke:SetPos( self:GetPos())
		nuke:SetVar( "owner", self.Owner )
		nuke:Spawn()
		nuke:Activate()


	self:killEveryOneWithNuke()


end


function ENT:killEveryOneWithNuke()


	local Entities = ents.GetAll()	//	CREATE LOCAL VARIABLE CALLED:	"Entities"	-	STORE ALL ENTITIES FOUND IN THE SERVER


	local FRAGS = 0;


	for k, v in pairs( Entities ) do  //  FOR EACH ENTITY FOUND, DO THE FOLLOWING...


//		*****  CREATE NESTED LOOP IN ORDER TO GET ALL ACTIVE KILLSTREAKS INDIVIDUALLY  *****


		for K, V in pairs( self.Killable_Killstreaks ) do	//	FOR EACH "KILLSTREAK" LISTED IN THE "Killable_Killstreaks" TABLE, DO THE FOLLOWING...
		
		
			local Active_Killstreaks = ents.FindByClass( V );	//	CREATE A LOCAL VARIABLE CALLED:  "Active_Killstreaks"	-	STORE ALL KILLSTREAKS FOUND *BY CLASS NAME*
			
			
			for Key, Value in pairs( Active_Killstreaks ) do	//	FOR EACH *ACTIVE KILLSTREAK*, DO THE FOLLOWING...				
				
				
				if Value:IsNPC() and Value:GetClass() == "npc_bullseye" then  //  CHECK:	IF THE ENTITY BEING PROCESSED *IS AN NPC*, **AND** THAT NPC *IS A SENTRY GUN*, THEN...
				
				
					Value:Fire( "kill", "", 0 )  //  DESTROY THE SENTRY GUN
				
				
				else	//	IF THE ENTITY BEING PROCESSED IS *NOT* A SENTRY GUN, THEN...
				
				
					Value:Destroy();	//	DESTROY THE ACTIVE KILLSTREAK
		
		
				end		//	FINISH THE CHECK
		
		
			end  //  FINISH THE NESTED LOOP
	
	
		end  //  FINISH THE LOOP


		if ( v:IsPlayer() && v != self.Owner ) then


			SlowDownPlayers(v)


			FRAGS = FRAGS + 1;


		elseif ( v:IsPlayer() && v == self.Owner && v:GetNetworkedBool("MW2NukeEffectOwner") ) then


			SlowDownPlayers(v)


			FRAGS = FRAGS + 1;


		elseif v:IsNPC() and v:GetClass() != "npc_bullseye" then  //  IF THE ENTITY BEING PROCESSED *IS AN NPC*, **AND** THAT NPC IS *NOT A SENTRY GUN*, THEN...


			if v:GetClass() != "npc_strider" && v:GetClass() != "bullseye_strider_focus" && v:GetClass() != "npc_rollermine" && v:GetClass() != "npc_turret_floor" then	//	CHECK:	IF THE NPC BEING PROCESSED IS *NOT A STRIDER*, **AND** THE NPC IS *NOT A ROLLERMINE*, **AND** THE NPC IS *NOT A TURRET*, THEN...


				timer.Simple( 5, function()  //  CREATE A "SIMPLE" TIMER:	AFTER "5" SECONDS, DO THE FOLLOWING...


					if v != NULL and v != nil then	//	CHECK:	IF THE NPC *IS VALID*, THEN...


						TurnIntoRagdoll( v )  //  TURN THE NPC INTO A "RAGDOLL"


					else  //  IF THE NPC IS *NOT VALID*, THEN...


						return  //  DO NOTHING AND RETURN


					end  //  FINISH THE CHECK


				end )  //  FINISH THE TIMER


			else  //  IF THE NPC *IS* A STRIDER, ROLLERMINE, OR TURRET, THEN...


				v:Fire( "Break", "", 0 );  //  "BREAK" THE NPC


			end  //  FINISH CHECKING THE NPC


		end


		FRAGS = FRAGS + 1;


	end  //  FINISH THE LOOP


	self.Owner:AddFrags( FRAGS )


end


function SLOW_PLAYER_MOVEMENT( PLAYER, MOVEMENT )	//	CREATE GLOBAL FUNCTION CALLED:	"SLOW_PLAYER_MOVEMENT"	-	ACCEPT TWO PARAMETERS


	MOVEMENT:SetVelocity( PLAYER:GetVelocity() / 2 )  //  CUT THE PLAYER'S MOVEMENT IN HALF ( MAKE THE SPEED OF THE PLAYER TO BE ONLY HALF AS FAST AS THEIR NORMAL SPEED )


end  //  COMPLETE THE FUNCTION


function SlowDownPlayers( pl )


	hook.Add( "Move", "SLOW_PLAYER_MOVEMENT", function( PLY, DATA )  //	ADD A HOOK CALLED:	"RESTRICT_MOVEMENT"  -  EACH TIME A PLAYER TRIES TO "MOVE", DO THE FOLLOWING...


		SLOW_PLAYER_MOVEMENT( PLY, DATA )  //	RUN CUSTOM FUNCTION DEFINED ABOVE ( PASS THE PLAYER AND MOVEMENT DATA AS INDIVIDUAL ARGUMENTS )


	end )  //  COMPLETE THE FUNCTION ( AND THE HOOK )


	//Controls the bloom. Redundant, but will work for now.


	//	INOPERABLE AND BUGGY / HAD TO FIX MANUALLY


	timer.Simple(0.3, /*pl.ConCommand, pl,*/  function() pp_bloom_darken = 0; pp_bloom_multiply = 0.1; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1; sensitivity = 1 end )

	timer.Simple(0.5, /*pl.ConCommand, pl,*/  function() pp_bloom_darken = 0; pp_bloom_multiply = 0.2; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple(0.7, /*pl.ConCommand, pl,*/  function() pp_bloom_darken = 0; pp_bloom_multiply = 0.3; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple(0.9, /*pl.ConCommand, pl,*/  function() pp_bloom_darken = 0; pp_bloom_multiply = 0.4; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple(0.11, /*pl.ConCommand, pl,*/ function() pp_bloom_darken = 0; pp_bloom_multiply = 0.5; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple(0.13, /*pl.ConCommand, pl,*/ function() pp_bloom_darken = 0; pp_bloom_multiply = 0.6; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple(0.15, /*pl.ConCommand, pl,*/ function() pp_bloom_darken = 0; pp_bloom_multiply = 0.7; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple(0.17, /*pl.ConCommand, pl,*/ function() pp_bloom_darken = 0; pp_bloom_multiply = 0.8; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple(0.19, /*pl.ConCommand, pl,*/ function() pp_bloom_darken = 0; pp_bloom_multiply = 1.0; pp_bloom_sizex = 9; pp_bloom_sizey = 9; pp_bloom_passes = 3; pp_bloom_color = 10; pp_bloom_color_r = 255; pp_bloom_color_b = 0; pp_bloom_color_g = 153; pp_bloom = 1 end )

	timer.Simple( 5, /*pl.Kill, pl*/ function() hook.Remove( "Move", "SLOW_PLAYER_MOVEMENT" ) pl:Kill() end )	//	AFTER "5" SECONDS, REMOVE THE CUSTOM HOOK ( ALLOWING THE PLAYER TO MOVE AT NORMAL SPEED ), THEN KILL THEM ONCE

	timer.Simple( 10, /*pl.ConCommand, pl,*/ function() pp_bloom = 0; sensitivity = 10 end )


end


function TurnIntoRagdoll( NPC )  //  CREATE GLOBAL FUNCTION CALLED:  "TurnIntoRagdoll"  -  ACCEPT ONE PARAMETER


	if NPC != NULL and NPC != nil then	//	CHECK:	IF THE NPC *IS VALID*, THEN...


		timer.Simple( 5, function()  //  CREATE A "SIMPLE" TIMER:	AFTER "5" SECONDS, DO THE FOLLOWING...


			local tempRag = ents.Create( "prop_ragdoll" )  //  CREATE A "RAGDOLL" ENTITY


			tempRag:SetModel( NPC:GetModel() )  //  SET THE *MODEL* OF THE "RAGDOLL" ENTITY TO BE THE MODEL OF THE *NPC*


			tempRag:SetPos( NPC:GetPos() )	//  SET THE *POSITION* OF THE "RAGDOLL" ENTITY TO BE THE POSITION OF THE *NPC*


			NPC:Remove();  //  REMOVE THE NPC


			tempRag:Spawn();  //  SPAWN THE NEW "RAGDOLL" ENTITY


		end )  //  FINISH THE TIMER


	else  //  IF THE ENTITY BEING PROCESSED IS *NOT VALID*, THEN...


		return  //  DO NOTHING AND RETURN


	end  //  FINISH THE CHECK


end  //  COMPLETE THE FUNCTION


function ENT:findGround()


	local minheight = -16384
	local startPos = Vector(0,0,0);
	local endPos = Vector(0, 0,minheight);
	local filterList = {}

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
			MsgN("Reached max number here, no luck in finding the ground.");
			bool = false;
		end
	end

	return groundLocation;


end
