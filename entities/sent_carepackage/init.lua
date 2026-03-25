AddCSLuaFile( "cl_init.lua" )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
ENT.dropPos = NULL;
local radius = 200;
ENT.ground = 0;
ENT.RemoveDelay = CurTime();
ENT.crate = NULL;
ENT.DropDaCrate = false;
ENT.DropOnce = false;
ENT.StartAngle = NULL;
ENT.WasInWorld = false;
ENT.IsInZone = false;
ENT.Top = NULL;
ENT.Back = NULL;
ENT.Model = Model("models/military2/air/air_h500.mdl")

local roaterSound = Sound("killstreak_misc/ah6_loop.wav")

function ENT:PhysicsUpdate()
	if !self.IsInZone then
		self.PhysObj:SetVelocity(self.Entity:GetForward()*1500)
	else
		if !self.DropOnce then
			timer.Simple(2, function() self:DropCrate() end)
			self.DropOnce = true;
		end
	end
	
	self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.dropPos.y, self.ground));
	self.Entity:SetAngles(self.StartAngle)

	if( !self.Entity:IsInWorld() && self.WasInWorld && self.RemoveDelay < CurTime()) then
		//self:StopSound(roaterSound)
		self.EMPSoundEmmiter:Stop()
		--self.Owner:ConCommand("stopsound");
		self.Entity:Remove();
		self.Top:Remove();
		self.Back:Remove();		
		return;
	end
	
	if !self.WasInWorld && self.Entity:IsInWorld() then
		self.RemoveDelay = CurTime() + 2;
		self.WasInWorld = true;
	end
	
	if self:FindDropZone(self.dropPos) && !self.DropDaCrate  then
		self.IsInZone = true;
	end	
	if self.Top:IsValid() && self.Back:IsValid() then
		self.Top:GetPhysicsObject():AddAngleVelocity( Vector(0,0, 300) )
		self.Back:GetPhysicsObject():AddAngleVelocity( Vector(0,25, 0) )
	end
	
end

function ENT:Initialize()	
	self.Owner = self:GetVar("owner")
	self.dropPos = self:GetVar("PackageDropZone", NULL) -- Needs to be set from the weapon
	//self.ground = findGround() + 1200;
	self.ground = self.dropPos.z + 1200;
	
	x = findWall("x", self.ground)
	self.spawnZone = Vector(x,self.dropPos.y,self.ground);
	//self.spawnZone = Vector(x,self.dropPos.y,self.dropPos.z + 1200);
	self.StartAngle = Angle(0, 180, 0);	
		
	self:SetModel( self.Model)
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
	
	self.Top = ents.Create( "prop_physics" )
	self.Top:SetModel("models/military2/air/air_h500_r.mdl")		
	self.Top:SetPos(self:GetPos() + (self:GetUp() * 50))
	self.Top:Spawn()
	if IsValid(self.Top:GetPhysicsObject()) then
		self.Top:GetPhysicsObject():EnableGravity(false)
	end

	self.Back = ents.Create( "prop_physics" )
	self.Back:SetModel("models/military2/air/air_h500_sr.mdl")		
	self.Back:SetPos(self:GetPos() + (self:GetForward() * -185) + (self:GetUp() * 13) + (self:GetRight() * -3) )
	self.Back:SetAngles( Angle( 0, 0, 180 ) )
	self.Back:Spawn()
	if IsValid(self.Back:GetPhysicsObject()) then
		self.Back:GetPhysicsObject():EnableGravity(false)
	end
	
	self.crate = ents.Create( "sent_supplyCrate" );
	self.crate:SetPos( self:GetPos() + (self:GetRight() * 1) + (self:GetUp() * -64) + (self:GetForward() * 8.5) )
	self.crate:SetAngles(self.Entity:GetAngles() + Angle(0,90,0));	
	self.crate:SetVar("owner",self.Owner)
	self.crate:SetVar("IsSentry",self:GetVar("IsSentry", false))
	self.crate:Spawn();
	if IsValid(self.crate:GetPhysicsObject()) then
		self.crate:GetPhysicsObject():EnableGravity(false)
	end
	self.crate:SetNotSolid(true);

	constraint.NoCollide( self, self.crate, 0, 0 );
	constraint.Weld(self.Entity, self.crate, 0,0,0, false)	
	constraint.NoCollide( self.Entity, game.GetWorld(), 0, 0 );	
	constraint.NoCollide( self.Top, game.GetWorld(), 0, 0 );	
	constraint.NoCollide( self.Back, game.GetWorld(), 0, 0 );	
	
	constraint.Axis( self, self.Top, 0, 0, (Vector(0,0,0)), Vector(0,0,0) , 0, 0, 0, 1 )	
	constraint.Axis( self, self.Back, 0, 0, Vector(-185,-3,13) , Vector(0,0,0), 0, 0, 0, 1 ) 
	constraint.Keepupright( self.Top, Angle(0,0,0), 0, 15 )	
	--self:EmitSound(roaterSound, 500, 100);
	self.EMPSoundEmmiter = CreateSound(self, roaterSound )
	--self.EMPSoundEmmiter:SetSoundLevel(0)
	self.EMPSoundEmmiter:Play() -- starts the sound	
	
	
	self:REQUEST_PACKAGE()  //	AFTER THE PACKAGE HAS BEEN SUCCESSFULLY INITIALIZED, RUN CUSTOM FUNCTION EXPLAINED BELOW
	
	
end


function ENT:REQUEST_PACKAGE()  //	CREATE A GLOBAL FUNCTION CALLED:	"REQUEST_PACKAGE"
	

	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE CARE-PACKAGE, THEN...
			
			
				umsg.Start( "MW2_PACKAGE_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_PACKAGE_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH LOOPING
		
		
	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE CARE-PACKAGE, THEN...
			
			
				umsg.Start( "MW2_PACKAGE_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_PACKAGE_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
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
	if IsValid(self.crate:GetPhysicsObject()) then
		self.crate:GetPhysicsObject():EnableGravity(true)
	end
	constraint.RemoveConstraints(self.crate, "Weld")
	self.crate:SetNotSolid(false);
	self.IsInZone = false
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