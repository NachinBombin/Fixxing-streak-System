AddCSLuaFile( "shared.lua" )


AddCSLuaFile( "cl_init.lua" )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS


include( 'shared.lua' )


ENT.dropPos = NULL;
local radius = 100;
ENT.ground = 0;
ENT.RemoveDelay = CurTime();
ENT.crate = NULL;
ENT.DropDaCrate = false;
ENT.StartAngle = NULL;
ENT.WasInWorld = false;
ENT.Model = Model( "models/military2/air/air_130_l.mdl" )


function ENT:Initialize()	
	
	hook.Add( "PhysgunPickup", "DisallowJetPickUp", physgunJetPickup );	
	self.Owner = self:GetVar("owner")		
	self.dropPos = self:GetVar("PackageDropZone", NULL) -- Needs to be set from the weapon
	self.ground = findGround() + 2000;
	
	x = findWall("x", self.ground)
	self.spawnZone = Vector(x,self.dropPos.y,self.ground);
	self.StartAngle = Angle(0, 180, 0);
	
	
	self:SetModel( self.Model )
	self:SetColor(Color(255,255,255,255))
	self:SetPos(self.spawnZone )
	self:SetAngles( self.StartAngle )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity(false);
		self.PhysObj:Wake()
	end
	

	constraint.NoCollide( self.Entity, game.GetWorld(), 0, 0 );
	
	
	self:REQUEST_AIRDROP()  //	AFTER THE AIRDROP HAS BEEN SUCCESSFULLY INITIALIZED, RUN CUSTOM FUNCTION EXPLAINED BELOW
	
	
end


function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity(self.Entity:GetForward()*3500)		
	
	self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.ground));
	self.Entity:SetAngles(self.StartAngle)

	if( !self.Entity:IsInWorld() && self.WasInWorld && self.RemoveDelay < CurTime()) then
		self.Entity:Remove();
		hook.Remove( "PhysgunPickup", "DisallowJetPickUp");
		return;
	end
	
	if !self.WasInWorld && self.Entity:IsInWorld() then
		self.RemoveDelay = CurTime() + 2;
		self.WasInWorld = true;
	end
	
	if self:FindDropZone(self.dropPos) && !self.DropDaCrate  then
		self.DropDaCrate = true;
		timer.Create("EmAd_crateTimer", .1, 4,function() self:DropCrate() end);
	end	
	
end


function ENT:REQUEST_AIRDROP()	//	CREATE A GLOBAL FUNCTION CALLED:	"REQUEST_AIRDROP"
	

	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE EMERGENCY-AIRDROP, THEN...
			
			
				umsg.Start( "MW2_AIRDROP_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_AIRDROP_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH LOOPING
		
		
	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE EMERGENCY-AIRDROP, THEN...
			

				umsg.Start( "MW2_AIRDROP_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_AIRDROP_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
			
			
			end  //  FINISH THE "IF" STATEMENT
			
			
		end  //  FINISH THE LOOP
		
		
	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ENT:OnTakeDamage( dmginfo )
end

function ENT:FindDropZone(vec)
	local jetPos = self.Entity:GetPos();
	local distance = jetPos - self.dropPos;
	if math.abs(distance.x) <= radius && math.abs(distance.y) <= radius then
		return true;
	end
	return false;
end

function ENT:DropCrate()
	self.DropDaCrate = true;
	
	local crate = ents.Create( "sent_supplyCrate" );
	crate:SetPos( self:GetPos() + (self:GetRight() * -3.5) + (self:GetUp() * 16.6) + (self:GetForward() * -393) )			
	crate:SetVar("CrateType", self:GetClass())	
	crate:SetVar("owner",self.Owner)
	crate:Spawn();	
	constraint.NoCollide( self, crate, 0, 0 );
end

function findGround()

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
			MsgN("Reached max number here, no luck in finding the ground");
			bool = false;
		end		
	end
	
	return groundLocation;
end

function findWall(axis, height)

	local length = 16384
	local startPos = Vector(0,0,height);
	local endPos;
	if axis == "x" then 
		endPos = Vector(length, 0,height);
	elseif axis == "y" then 
		endPos = Vector(0, length,height);
	end
	
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
	local wallLocation = -1;
	while bool do
		traceData = util.TraceLine(trace);
		hitSky = traceData.HitSky;
		hitWorld = traceData.HitWorld;
		if hitSky then
			if axis == "x" then
				wallLocation = traceData.HitPos.x;
			elseif axis == "y" then
				wallLocation = traceData.HitPos.y;
			end
			bool = false;
		elseif hitWorld then
			if axis == "x" then
				trace.start = traceData.HitPos + Vector(50,0,0);
			elseif axis == "y" then
				trace.start = traceData.HitPos + Vector(0,50,0);
			end
		else 
			table.insert(filterList, traceData.Entity)
		end
			
		if maxNumber >= 100 then
			MsgN("Reached max number here, no luck in finding the wall");
			bool = false;
		end		
		maxNumber = maxNumber + 1;
	end
	
	return wallLocation;
end


function physgunJetPickup( ply, ent )
	if ent:GetClass() == "sent_jet" || ent:GetClass() == "sent_air_strike_cluster"  then
		return false // Don't allow them to pick up the jet or the bombs.
	else
		return true 
	end
end