AddCSLuaFile( "cl_init.lua" )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS


AddCSLuaFile( "shared.lua" )


include( 'shared.lua' )


ENT.FlightLength = CurTime();
ENT.flightHeight = nil;
ENT.ang = NULL;
ENT.speed = 1500;
ENT.OurHealth = 100;
local IsUAVActive = false;


local UAV_ACTIVE = false	//  CREATE LOCAL VARIABLE CALLED:  "UAV_ACTIVE"  -  STORE THE STATE OF THE UAV


function ENT:Think()
	
	
	if self.PhysObj:IsAsleep() then
		self.PhysObj:Wake()
	end
	if( !self:IsInWorld()) then
		MsgN("[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  The UAV has returned to base!")	//	REWROTE SENTENCE FOR REALISM
		self:Remove()
	end
	
	
end

function ENT:PhysicsUpdate()
	
	self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self.flightHeight));
	self.PhysObj:SetVelocity(self:GetForward() * 750)	
	self:SetAngles(self.ang)
	
	local Trace = util.QuickTrace( self:GetPos(), self:GetForward() * 4500,  self )	
	if Trace.HitSky then
		self.ang = self.ang + Angle(0, -0.3, 0)
	end
	
	if self.FlightLength < CurTime() then
		self:Remove()		
	end
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:Initialize()
	
	
	self.Owner = self:GetVar("owner")
	if IsUAVActive then
		self:Remove();
		return;
	end
	
	self:SetModel( "models/COD4/UAV/UAV.mdl" );
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	self.flightHeight = self:findGround() + 5000

	self:SetPos( Vector( self:FindEdge() - 500, 0, self.flightHeight) )
	self.FlightLength = CurTime() + 30;
	self.ang = Angle(0,-90,0);
	
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )
	
	IsUAVActive = true;
	self:GetVar("Weapon"):PlaySound();
	
	
	UAV_ACTIVE = true	//	THE UAV IS NOW ACTIVE
	
	
	net.Start( "UAV_STATUS" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "UAV_STATUS"
	
	
		net.WriteBool( UAV_ACTIVE )  //  SEND THE CURRENT STATE OF THE UAV ( NOW "ACTIVE" ) AS DATA INCLUDED WITH THE MESSAGE
	
	
	net.Send( player.GetHumans() )	//	SEND THIS MESSAGE TO *ALL PLAYERS*
	
	
	self:BROADCAST_UAV();	//	AFTER THE UAV HAS BEEN SUCCESSFULLY INITIALIZED, RUN CUSTOM FUNCTION EXPLAINED BELOW
	
	
end


function ENT:BROADCAST_UAV()	//	CREATE A GLOBAL FUNCTION CALLED:	"BROADCAST_UAV"

	
	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE UAV, THEN...
			
			
				umsg.Start( "MW2_UAV_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_UAV_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED

		
			elseif Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE UAV, THEN...
		

				umsg.Start( "MW2_UAV_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_UAV_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
			
	    
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ UAV BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH LOOPING
		
		
	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE UAV, THEN...
			
			
				umsg.Start( "MW2_UAV_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_UAV_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			elseif Value != self.Owner then		//	IF THE PLAYER CURRENTLY BEING LOOKED AT IS *NOT THE OWNER* OF THE UAV, THEN...
	
	
				umsg.Start( "MW2_UAV_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_UAV_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ UAV BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
		
		
			end  //  FINISH THE "IF" STATEMENT
			
			
		end  //  FINISH THE LOOP
		
		
	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg); -- React physically when getting shot/blown
 
	if(self.OurHealth <= 0) then return; end -- If the health-variable is already zero or below it - do nothing
 
	self.OurHealth = self.OurHealth - dmg:GetDamage(); -- Reduce the amount of damage took from our health-variable
 
	if(self.OurHealth <= 0) then -- If our health-variable is zero or below it
		self:Destroy();
	end
 end

function ENT:Destroy()
	local ParticleExplode = ents.Create("info_particle_system")
		ParticleExplode:SetPos( self:GetPos() )
		ParticleExplode:SetKeyValue("effect_name", "cluster_explode")
		ParticleExplode:SetKeyValue("start_active", "1")
		ParticleExplode:Spawn()
		ParticleExplode:Activate()
		ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.		
	self:Remove(); -- Remove our entity		
end

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
	local maxNumber = 0;
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
			
		if maxNumber >= 300 then
			MsgN("Reached max number here, no luck in finding a Skybox.");
			bool = false;
		end
	end
	
	return skyLocation;
end

function ENT:findGround()

	local minheight = -16384
	//local startPos = self.Owner:GetPos()
	local startPos = Vector(0, 0, self:FindSky())
	local endPos = Vector(0, 0,minheight);
	local filterList = {self.Owner, self}

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

function ENT:FindEdge()

	local dis = 16384
	local height = self:FindSky()
	local startPos = Vector(0,0, height)
	local endPos = Vector(dis, 0, height);
	local filterList = {self.Owner, self}

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = filterList;

	local traceData;
	local hitSky;
	local hitWorld;
	local bool = true;
	local maxNumber = 0;
	local WallLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitWorld then
			WallLocation = traceData.HitPos.x;
			bool = false;
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the wall.");
			bool = false;
		end		
	end
	
	return WallLocation;
end


function ENT:OnRemove()  //  OVERRIDE GLOBAL FUNCTION:	PERFORM SPECIAL ACTIONS UPON REMOVAL OF THE UAV
	
	
	local Players = player.GetHumans()	//	CREATE LOCAL VARIABLE CALLED:	"Players"	-	STORE ALL HUMAN PLAYERS IN THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do	//	FOR EACH PLAYER FOUND, DO THE FOLLOWING...	
	    
		
			if Value:Team() == self.Owner:Team() then  //  CHECK:  IF THE PLAYER CURRENTLY BEING PROCESSED IS ON THE *SAME TEAM* AS THE OWNER OF THE UAV, THEN...
			
			
				umsg.Start( "MW2_UAV_END", Value );  //  SEND A MESSAGE TO THE PLAYER NOTIFYING THEIR SYSTEM THAT THE UAV IS BEING REMOVED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
	    
		
			end  //  FINISH THE CHECK
	
	
		end  //  FINISH THE LOOP
	
	
	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do	//	FOR EACH PLAYER FOUND, DO THE FOLLOWING...	
	    
		
			if Value == self.Owner then  //  CHECK:  IF THE PLAYER CURRENTLY BEING PROCESSED *IS THE OWNER* OF THE UAV, THEN...
			
			
				umsg.Start( "MW2_UAV_END", Value );  //  SEND A MESSAGE TO THE PLAYER NOTIFYING THEIR SYSTEM THAT THE UAV IS BEING REMOVED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
	    
		
			end  //  FINISH THE CHECK
	
	
		end  //  FINISH THE LOOP
		
		
	end  //  FINISH THE CHECK
	
	
	UAV_ACTIVE = false	//  THE UAV IS *NO LONGER* ACTIVE
	
	
	net.Start( "UAV_STATUS" )	//	BEGIN A (NETWORK) MESSAGE BLOCK:	NAME THE MESSAGE "UAV_STATUS"
	
	
		net.WriteBool( UAV_ACTIVE )  //  SEND THE CURRENT STATE OF THE UAV ( NO LONGER ACTIVE ) AS DATA INCLUDED WITH THE MESSAGE
	
	
	net.Send( player.GetHumans() )  //  SEND THIS MESSAGE TO *ALL PLAYERS*
	
	
	IsUAVActive = false;  //  NOTIFY THE SYSTEM THAT THE UAV IS NO LONGER ACTIVE


end  //  COMPLETE THE FUNCTION