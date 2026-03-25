include( 'shared.lua' )


AddCSLuaFile( 'shared.lua' )


AddCSLuaFile( 'cl_init.lua' )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS


ENT.findHoverZone = true;
ENT.Model = "models/dav0r/camera.mdl"
ENT.jet1Alive = false;
ENT.jet2Alive = false;
ENT.jet3Alive = false;
ENT.spawnJet2 = false;
ENT.spawnJet3 = false;
ENT.SpawnDelay = CurTime();
ENT.playOnce = true;
ENT.WallLoc = NULL;
ENT.restrictMovement = true;


local function Check_Status( Owner )	//  CREATE LOCAL FUNCTION CALLED:  "Check_Status"  -  ACCEPT ONE PARAMETER


	if Owner:Alive() == true then	//  CHECK:	IF THE OWNER OF THE PRECISION-AIRSTRIKE *IS ALIVE*, THEN...
	
	
		return 1	//  RETURN A VALUE OF "1"
	
	
	else	//  IF THE OWNER OF THE PRECISION-AIRSTRIKE IS *NOT ALIVE*, THEN...
	
	
		return 0	//  RETURN A VALUE OF "0"
	

	end  //  FINISH THE CHECK


end  //  COMPLETE THE FUNCTION


function ENT:Think()
	
	
	self:NextThink( CurTime() + 0.1 )
	
	
	local Status = Check_Status( self.Owner )	//  CREATE A LOCAL VARIABLE CALLED: 	"Status"	-	STORE THE VALUE RETURNED BY THE FUNCTION "Check_Status" ( PASS THE OWNER OF THE PRECISION-AIRSTRIKE TO THE FUNCTION )
	
	
	if Status == 1 then  //  CHECK:  IF THE FUNCTION "Check_Status" RETURNED A VALUE OF "1" ( THE OWNER OF THE PRECISION-AIRSTRIKE IS STILL ALIVE ), THEN...


	if self.DropLoc == nil || self.DropAng == nil then return true end
	
	
	if self.findHoverZone then
		
		
		self.DropLoc = self.DropLoc - Vector(0,0, 100);
		self.findHoverZone = false;
		self.WallLoc = self:FindWall();
		self.FlyAng = self.DropAng
		
		
		GAMEMODE:SetPlayerSpeed(self.Owner, self.playerSpeeds[1], self.playerSpeeds[2])


		if IsValid( self.Wep ) then
			
			
			self.Wep:CallIn();
			
			
			self:CALL_AIRSTRIKE()	//	IF THE DROP ZONE THAT THE USER SELECTS IS VALID, RUN CUSTOM FUNCTION EXPLAINED BELOW
			

		end


		self.jet1Alive = true;
		self.Jet1:SetVar("JetDropZone", self:FindDropZone1())
		self.Jet1:SetVar("WallLocation", self.WallLoc)
		self.Jet1:SetVar("FlyAngle", self.FlyAng)
		self.Jet1:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
		self.Jet1:Spawn()
		self.Jet1:Activate()
		self.SpawnDelay = CurTime() + 2;
	
	
	end
	
	if !self.findHoverZone && self.playOnce then
		self.Wep:PlaySound();
		self.playOnce = false;
	end
	if self.SpawnDelay <= CurTime() && self.jet1Alive then
		self.jet1Alive = false;
		self.jet2Alive = true;
		self.Jet2:SetVar("JetDropZone", self.DropLoc)
		self.Jet2:SetVar("WallLocation", self.WallLoc)
		self.Jet2:SetVar("FlyAngle", self.FlyAng)
		self.Jet2:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
		self.Jet2:Spawn();
		self.Jet2:Activate();
		self.SpawnDelay = CurTime() + 2;
	elseif self.SpawnDelay <= CurTime() && self.jet2Alive then
		self.jet2Alive = false;			
		self.Jet3:SetVar("JetDropZone", self:FindDropZone3())
		self.Jet3:SetVar("WallLocation", self.WallLoc)
		self.Jet3:SetVar("FlyAngle", self.FlyAng)
		self.Jet3:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
		self.Jet3:Spawn();
		self.Jet3:Activate();
		self:Remove()
	end	
	
	
	elseif Status != 1 then  //  IF THE FUNCTION "Check_Status" RETURNED A VALUE THAT IS *NOT EQUAL* TO "1" ( THE OWNER OF THE PRECISION-AIRSTRIKE IS NOT ALIVE ), THEN...


		self:Remove()	//  REMOVE THE PRECISION-AIRSTRIKE
	

	end  //  FINISH THE CHECK

	
    return true;	

	
end


function ENT:MW2_Init()
	self:SetColor(Color(255,255,255,0))
	self.PhysObj:EnableGravity(false)
	self:SetNotSolid(true)
	self:SetPos( Vector( 0,0,0 ) )
	self.Jet1 = ents.Create("sent_jet")
	self.Jet1:SetVar("owner",self.Owner) 
	
	self.Jet2 = ents.Create("sent_jet")
	self.Jet2:SetVar("owner",self.Owner) 
	
	self.Jet3 = ents.Create("sent_jet")
	self.Jet3:SetVar("owner",self.Owner) 
	
	
	self.Owner = self:GetVar("owner")
	
	
	self:OpenOverlayMap(true);
	
	
end


function ENT:CALL_AIRSTRIKE()	//	CREATE A GLOBAL FUNCTION CALLED:	"CALL_AIRSTRIKE"


	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER
	
	
	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE PRECISION-AIRSTRIKE, THEN...
			
			
				umsg.Start( "MW2_AIRSTRIKE_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_AIRSTRIKE_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED

		
			elseif Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE PRECISION-AIRSTRIKE, THEN...
		

				umsg.Start( "MW2_AIRSTRIKE_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_AIRSTRIKE_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
			
	    
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ AIRSTRIKE BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
		
		
			end  //  FINISH THE "IF" STATEMENT
	
	
		end  //  FINISH LOOPING
		
		
	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...
	
	
		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...
	
	
			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE PRECISION-AIRSTRIKE, THEN...
			
			
				umsg.Start( "MW2_AIRSTRIKE_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_AIRSTRIKE_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			elseif Value != self.Owner then		//	IF THE PLAYER CURRENTLY BEING LOOKED AT IS *NOT THE OWNER* OF THE PRECISION-AIRSTRIKE, THEN...
	
	
				umsg.Start( "MW2_AIRSTRIKE_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_AIRSTRIKE_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED
			
			
				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE
		
			
				print( "[ AIRSTRIKE BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE
		
		
			end  //  FINISH THE "IF" STATEMENT
			
			
		end  //  FINISH THE LOOP
		
		
	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )	
end

function ENT:FindWall()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * -100000, self).HitPos
end

function ENT:FindDropZone1()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * -350, self).HitPos
end

function ENT:FindDropZone3()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * 350, self).HitPos	
end