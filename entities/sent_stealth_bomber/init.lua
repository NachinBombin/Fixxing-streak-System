include( 'shared.lua' )


AddCSLuaFile( "shared.lua" )


AddCSLuaFile( "cl_init.lua" )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS


ENT.Model = Model( "models/dav0r/camera.mdl" )
ENT.DropDelay = CurTime();
ENT.playOnce = true;
ENT.findHoverZone = true
ENT.WallLoc = NULL;
ENT.Bomber = nil
ENT.InitialDelay = CurTime();
ENT.restrictMovement = true;


local function Check_Status( Owner )	//  CREATE LOCAL FUNCTION CALLED:  "Check_Status"  -  ACCEPT ONE PARAMETER


	if Owner:Alive() == true then	//  CHECK:	IF THE OWNER OF THE STEALTH-BOMBER *IS ALIVE*, THEN...
	
	
		return 1	//  RETURN A VALUE OF "1"
	
	
	else	//  IF THE OWNER OF THE STEALTH-BOMBER IS *NOT ALIVE*, THEN...
	
	
		return 0	//  RETURN A VALUE OF "0"
	

	end  //  FINISH THE CHECK


end  //  COMPLETE THE FUNCTION


function ENT:Think()
	self:NextThink( CurTime() + 0.1 )
	if IsValid(self.Bomber) && !self.Bomber:IsInWorld() then
		self.Bomber:Remove()
		self:Remove()
		return true;
	end


	local Status = Check_Status( self.Owner )	//  CREATE A LOCAL VARIABLE CALLED: 	"Status"	-	STORE THE VALUE RETURNED BY THE FUNCTION "Check_Status" ( PASS THE OWNER OF THE STEALTH-BOMBER TO THE FUNCTION )


	if Status == 1 then  //  CHECK:  IF THE FUNCTION "Check_Status" RETURNED A VALUE OF "1" ( THE OWNER OF THE STEALTH-BOMBER IS STILL ALIVE ), THEN...


	if self.DropLoc == nil || self.DropAng == nil then return end

	if self.findHoverZone then
		self.findHoverZone = false;
		
		self.WallLoc = self:FindWall();
		self.FlyAng = self.DropAng
		
		GAMEMODE:SetPlayerSpeed(self.Owner, self.playerSpeeds[1], self.playerSpeeds[2])
		if IsValid(self.Wep) then
			
			self.Wep:CallIn();
			
			self:REQUEST_BOMBER()	//	IF THE DROP ZONE THAT THE USER SELECTS IS VALID, RUN CUSTOM FUNCTION EXPLAINED BELOW
			
		end
		self:SpawnBomber();		
	else
		if not self.Bomber then self:Remove() return end
		self.Bomber.PhysObj:SetVelocity(self.Bomber:GetForward()*5000)
		if self.DropDelay < CurTime() && self.InitialDelay < CurTime() then
			self.DropDelay = CurTime() + .08;
			self:SpawnBomb();
		end
	end
	
	if !self.findHoverZone && self.playOnce then
		self.Wep:PlaySound();
		self.playOnce = false;
	end
	
	
	elseif Status != 1 then  //  IF THE FUNCTION "Check_Status" RETURNED A VALUE THAT IS *NOT EQUAL* TO "1" ( THE OWNER OF THE STEALTH-BOMBER IS NOT ALIVE ), THEN...
	
	
		self:Remove()  //  REMOVE THE STEALTH-BOMBER
		
		
	end  //  FINISH THE CHECK
	
	
	return true;
	
	
end

function ENT:MW2_Init()
	self.Entity:SetModel( "models/dav0r/camera.mdl" )
	self.Entity:SetColor(Color(255,255,255,0))
	self:SetPos(Vector(0,0, 0));
	
	self.PhysObj:EnableGravity(false)
	self.Entity:SetNotSolid(true);
	
	
	self.Owner = self:GetVar("owner")
	
	
	self:OpenOverlayMap(true);
	
	
end


function ENT:REQUEST_BOMBER()	//	CREATE A GLOBAL FUNCTION CALLED:	"REQUEST_BOMBER"
	

	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE STEALTH-BOMBER, THEN...
			
			
				umsg.Start( "MW2_BOMBER_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_BOMBER_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED

		
			elseif Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE STEALTH-BOMBER, THEN...
		

				umsg.Start( "MW2_BOMBER_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_BOMBER_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
			
	    
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ BOMBER BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH LOOPING
		
		
	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE STEALTH-BOMBER, THEN...
			
			
				umsg.Start( "MW2_BOMBER_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_BOMBER_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			elseif Value != self.Owner then		//	IF THE PLAYER CURRENTLY BEING LOOKED AT IS *NOT THE OWNER* OF THE STEALTH-BOMBER, THEN...
	
	
				umsg.Start( "MW2_BOMBER_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_BOMBER_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ BOMBER BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
		
		
			end  //  FINISH THE "IF" STATEMENT
			
			
		end  //  FINISH THE LOOP
		
		
	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ENT:SpawnBomber()
	self.ground = self:findGround() + 4000;
	self.Bomber = ents.Create("prop_physics")
	self.Bomber:SetModel("models/military2/air/air_f117_l.mdl")
	self.Bomber:SetColor(Color(255,255,255,255))
	self.Bomber:SetPos( Vector( self.WallLoc.x, self.WallLoc.y, self.ground) )
	self.Bomber:SetAngles( self.FlyAng )
	
	self.Bomber:PhysicsInit( SOLID_VPHYSICS )
	self.Bomber:SetMoveType( MOVETYPE_VPHYSICS )		
	self.Bomber:SetSolid( SOLID_VPHYSICS )

	self.Bomber.PhysObj = self.Bomber:GetPhysicsObject()
	if (self.Bomber.PhysObj:IsValid()) then
		self.Bomber.PhysObj:Wake()
	end
	self.InitialDelay = CurTime() + .6;
	
	constraint.NoCollide( self.Bomber, game.GetWorld(), 0, 0 );	
	self.Bomber.PhysgunDisabled = true
end

function ENT:SpawnBomb()
	local bomb = ents.Create( "sent_air_strike_bomb" );
	bomb:SetPos(self.Bomber:GetPos() + (self.Bomber:GetRight() * -50) )
	bomb:SetAngles(self.Bomber:GetAngles());
	bomb:SetVar("owner",self.Owner)
	bomb:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	bomb:Spawn();
	constraint.NoCollide( self.Bomber, bomb, 0, 0 );	
	bomb:SetVar("HasBeenDropped",true);
	
	local bomb2 = ents.Create( "sent_air_strike_bomb" );
	bomb2:SetPos(self.Bomber:GetPos() + (self.Bomber:GetRight() * 50) )
	bomb2:SetAngles(self.Bomber:GetAngles());
	bomb2:SetVar("owner",self.Owner)
	bomb2:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
	bomb2:Spawn();
	constraint.NoCollide( self.Bomber, bomb2, 0, 0 );
	bomb2:SetVar("HasBeenDropped",true);		
end

function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function ENT:FindWall()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * -100000, self).HitPos
end