AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')  //	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS
include('shared.lua')

ENT.Duration = 60;
ENT.Timer = CurTime();


ENT.Killstreaks = { "mw2_counterUAV", "mw2_SentryGun", "mw2_UAV", "sent_ac-130", "sent_harrier", "npc_bullseye" }	//	CREATE A TABLE CALLED "Killstreaks" TO STORE THE VARIOUS "KILLABLE" KILLSTREAKS


local empSound = Sound( "killstreak_misc/em_pulse.wav" );


local EMP_ACTIVE = false  //  CREATE LOCAL VARIABLE CALLED:  "EMP_ACTIVE"  -  STORE THE STATE OF THE EMP


function ENT:Initialize()
	
	
	self.Owner = self:GetVar("owner")		
	self:SetModel("models/dav0r/camera.mdl") -- Just need a model, doesnt matter what it is
	self:SetColor( Color( 255, 255, 255 ) )
	self:SetPos( Vector(0,0, self:FindSky() - 200) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:GetPhysicsObject():EnableGravity(false)
	self:SetNotSolid(true)


//	sound.Play("killstreak_misc/em_pulse.wav",self:GetPos(),0,100,1)
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		MW2_KillStreaks_EMP_Team = self.Owner:Team()	//	SET THE TEAM OF THE EMP BEING USED TO THE TEAM OF ITS OWNER
		
		
		EMP_TEAM_CHECK = self.Owner:Team()	//	STORE THE CURRENT TEAM OF THE EMP'S OWNER
		
		
	else  //  IF TEAMS ARE *NOT ENABLED*, THEN...


		MW2_KillStreaks_EMP_Team = -1	//	SET THE TEAM OF THE EMP TO "-1" ( SINCE THERE IS NO TEAM )
		
		
		EMP_TEAM_CHECK = self.Owner:Team()	//	STORE THE CURRENT TEAM OF THE EMP'S OWNER
		
	
	end  //  FINISH THE CHECK
	
	
	self:Create_EMP_Effect()
	self:Kill_Killstreaks()
	self.Timer = CurTime() + self.Duration;
	
	self.EMPSoundEmmiter = CreateSound(self, empSound )
	self.EMPSoundEmmiter:Play() -- starts the sound	
	
	
	EMP_ACTIVE = true	//	THE EMP IS NOW ACTIVE
	
	
	net.Start( "EMP_STATUS" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "EMP_STATUS"
	
	
		net.WriteBool( EMP_ACTIVE )  //  SEND THE CURRENT STATE OF THE EMP ( NOW "ACTIVE" ) AS DATA INCLUDED WITH THE MESSAGE
	
	
	net.Send( player.GetHumans() )	//	SEND THIS MESSAGE TO *ALL PLAYERS*
	
	
	self:FIRE_EMP()  //  AFTER THE EMP HAS BEEN SUCCESSFULLY INITIALIZED, RUN CUSTOM FUNCTION EXPLAINED BELOW
	
	
end


function ENT:FIRE_EMP()  //	CREATE A GLOBAL FUNCTION CALLED:	FIRE_EMP()
	

	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	

			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE EMP, THEN...
			
			
				umsg.Start( "MW2_EMP_FireEMP", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_FireEMP"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
		
			
					umsg.Short( self.Owner:Team() )  //  SEND A "SHORT" PIECE OF DATA REGARDING THE EMP OWNER'S TEAM	-	SEND TO CLIENT
		
		
				umsg.End()	//  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
			
			
				Value:SetNoTarget( true )	//	MAKE THE PLAYER "NEUTRAL" TO ANY ENEMY NPC
			
			
				umsg.Start( "MW2_EMP_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED

		
			elseif Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE EMP, THEN...
		
		
				umsg.Start( "MW2_EMP_FireEMP", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_FireEMP"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
		
		
				umsg.End()	//  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
		

				umsg.Start( "MW2_EMP_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
			
	    
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ EMP BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH LOOPING
		
		
	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE EMP, THEN...
			
			
				umsg.Start( "MW2_EMP_FireEMP", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_FireEMP"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
		
		
				umsg.End()	//  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
				umsg.Start( "MW2_EMP_OWNER", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_OWNER"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
		
		
					umsg.Short( 1 )  //  SEND A "SHORT" FLAG SIGNALING THE OWNER OF THE EMP  -  SEND TO CLIENT
		
		
				umsg.End()	//  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
			
			
				Value:SetNoTarget( true )	//	MAKE THE PLAYER "NEUTRAL" TO ANY ENEMY NPC
			
			
				umsg.Start( "MW2_EMP_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			elseif Value != self.Owner then		//	IF THE PLAYER CURRENTLY BEING LOOKED AT IS *NOT THE OWNER* OF THE EMP, THEN...
	
	
				umsg.Start( "MW2_EMP_FireEMP", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_FireEMP"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
		
		
				umsg.End()	//  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
	
	
				umsg.Start( "MW2_EMP_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ EMP BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
			
			
			end  //  FINISH THE "IF" STATEMENT
			
			
		end  //  FINISH THE LOOP
		
		
	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ENT:Think()

	
	if self.Timer <= CurTime() then
	

		self:Remove_EMP();
	
	
	end


    self.Entity:NextThink( CurTime()+ 0.01 )
    
	
	return true;
	
	
end

function ENT:Create_EMP_Effect()
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos( self:GetPos() )
	ParticleExplode:SetKeyValue("effect_name", "EMP")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 40)
end

function ENT:Kill_Killstreaks()  //  DEFINE A FUNCTION ALLOWING THE EMP TO "KILL" ACTIVE KILLSTREAKS


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	IF TEAMS *ARE ENABLED*, THEN...

		
		local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
		
		
		local Enemy_Team = {}  //  CREATE A LOCAL TABLE CALLED:	"Enemy_Team"	-	STORE EACH PLAYER THAT IS ON THE *ENEMY TEAM* (NOT ON THE SAME TEAM AS THE OWNER OF THE EMP)
		
		
		for Key, Value in pairs( Players ) do	//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
		
		
			if Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE EMP, THEN...
			
			
				Enemy_Team[ Key ] = Value  //  ADD THE PLAYER TO THE CUSTOM TABLE CREATED ABOVE
			
				
			end  //  FINISH THE "IF" STATEMENT
			
		
		end  //  FINISH THE LOOP
		
	
		for K, V in pairs( self.Killstreaks ) do	//	FOR EACH "KILLSTREAK" LISTED IN THE "Killstreaks" TABLE, DO THE FOLLOWING...
		
		
			local Active_Killstreaks = ents.FindByClass( V );	//	CREATE A LOCAL VARIABLE CALLED:  "Active_Killstreaks"	-	STORE ALL KILLSTREAKS FOUND *BY CLASS NAME*
			
			
			for Key, Value in pairs( Active_Killstreaks ) do	//	FOR EACH *ACTIVE KILLSTREAK*, DO THE FOLLOWING...

			
				for Index, User in pairs( Enemy_Team ) do  //  ITERATE THROUGH ALL USERS IN THE CUSTOM "Enemy_Team" TABLE CREATED ABOVE  -  FOR EACH USER FOUND IN THE TABLE, DO THE FOLLOWING...
			

					if Value:GetVar( "owner" ) == User then  //  IF THE OWNER OF THE ACTIVE KILLSTREAK IS ON THE ENEMY TEAM, THEN...
				
				
						if Value:IsNPC() and Value:GetClass() == "npc_bullseye" then  //  CHECK:	IF THE ENTITY BEING PROCESSED *IS AN NPC*, **AND** THAT NPC *IS A SENTRY GUN*, THEN...
				
				
							Value:Fire( "kill", "", 0 )  //  DESTROY THE SENTRY GUN
				
				
						else	//	IF THE ENTITY BEING PROCESSED IS *NOT* A SENTRY GUN, THEN...
				
				
							Value:Destroy();	//	DESTROY THE ACTIVE KILLSTREAK
		
		
						end		//	FINISH THE CHECK
						
			
					end  //  FINISH THE "IF" STATEMENT
			
		
				end  //  FINISH THE NESTED LOOP
		
		
			end  //  FINISH THE NESTED LOOP
	
	
		end  //  FINISH THE LOOP


	else  //  IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for K, V in pairs( self.Killstreaks ) do	//	FOR EACH "KILLSTREAK" LISTED IN THE "Killstreaks" TABLE, DO THE FOLLOWING...
		
		
			local Active_Killstreaks = ents.FindByClass( V );	//	CREATE A LOCAL VARIABLE CALLED:  "Active_Killstreaks"	-	STORE ALL KILLSTREAKS FOUND *BY CLASS NAME*
		
		
			for Key, Value in pairs( Active_Killstreaks ) do	//	FOR EACH *ACTIVE KILLSTREAK*, DO THE FOLLOWING...

			
				if Value:GetVar( "owner" ) == self.Owner then	//  IF THE OWNER OF THE ACTIVE KILLSTREAK *IS THE OWNER* OF THE EMP, THEN...
				
				
					if Value:IsNPC() and Value:GetClass() == "npc_bullseye" then  //  CHECK:	IF THE ENTITY BEING PROCESSED *IS AN NPC*, **AND** THAT NPC *IS A SENTRY GUN*, THEN...
				
				
						Value:Fire( "kill", "", 0 )  //  DESTROY THE SENTRY GUN
				
				
					else	//	IF THE ENTITY BEING PROCESSED IS *NOT* A SENTRY GUN, THEN...
				
				
						Value:Destroy();	//	DESTROY THE ACTIVE KILLSTREAK
		
		
					end		//	FINISH THE CHECK
			
			
				end  //  FINISH THE "IF" STATEMENT
		
		
			end  //  FINISH THE NESTED LOOP
	
	
		end  //  FINISH THE LOOP


	end  //  FINISH THE CHECK


end  //  COMPLETE THE FUNCTION


function ENT:Remove_EMP()  //  BEFORE THE EMP IS OFFICIALLY REMOVED, DO THE FOLLOWING CHECKS...
	
	
	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do	//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
		
		
			umsg.Start( "MW2_EMP_RemoveEMP", Value );	//  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_RemoveEMP"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
		
		
			umsg.End()	//  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
		
		
			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE EMP, THEN...
				
				
				Value:SetNoTarget( false )	//	RESET THE PLAYER'S DISPOSITION
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH THE LOOP
	
	
	else  //  IF TEAMS ARE *NOT ENABLED*, THEN...
	

		for Key, Value in pairs( Players ) do	//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
		
		
			umsg.Start( "MW2_EMP_RemoveEMP", Value );	//  CREATE A MESSAGE (EVENT) CALLED:	"MW2_EMP_RemoveEMP"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
		
		
			umsg.End()	//  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
		
		
			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE EMP, THEN...
				
				
				Value:SetNoTarget( false )	//	RESET THE PLAYER'S DISPOSITION
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH THE LOOP
	
	
	end  //  FINISH THE CHECK
	
	
	EMP_TEAM_CHECK = NULL	//	STORE THE TEAM OF THE EMP AS "NULL"
	
	
	MW2_KillStreaks_EMP_Team = NULL  //	SET THE TEAM OF THE EMP TO "NULL" ( CAN BE ANYTHING EXCEPT "-1" )


	EMP_ACTIVE = false	//  THE EMP IS *NO LONGER* ACTIVE
	
	
	net.Start( "EMP_STATUS" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "EMP_STATUS"
	
	
		net.WriteBool( EMP_ACTIVE )  //  SEND THE CURRENT STATE OF THE EMP ( NO LONGER ACTIVE ) AS DATA INCLUDED WITH THE MESSAGE
	
	
	net.Send( player.GetHumans() )  //  SEND THIS MESSAGE TO *ALL PLAYERS*

	
	self:Remove();  //  REMOVE THE EMP
	
	
end  //  COMPLETE THE FUNCTION


function ENT:FindSky()

	local maxheight = 16384
	local startPos = Vector(0,0,0);
	local endPos = Vector(0, 0,maxheight);
	local filterList = {}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local num = 0;
	local skyLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			skyLocation = traceData.HitPos.z;
			bool = false;
		elseif hitWorld then
			trace.start = traceData.HitPos + Vector(0,0,50);
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if num >= 300 then
			MsgN("Reached max number here, no luck in finding a Skybox.");
			bool = false;
		end
		num = num + 1
	end
	
	return skyLocation;
end