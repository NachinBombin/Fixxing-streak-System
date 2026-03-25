AddCSLuaFile( 'cl_init.lua' )	//	REQUIRED TO PREVENT ERRORS


AddCSLuaFile( "shared.lua" )


include( 'shared.lua' )


ENT.Model = "models/dav0r/camera.mdl"
ENT.findHoverZone = true;
ENT.jet1Alive = false;
ENT.jet2Alive = false;
ENT.jet3Alive = false;
ENT.spawnJet2 = false;
ENT.spawnJet3 = false;
ENT.SpawnDelay = CurTime();
ENT.playOnce = true;
ENT.restrictMovement = true;


local function Check_Status( Owner )  //  CREATE LOCAL FUNCTION CALLED:  "Check_Status"  -  ACCEPT ONE PARAMETER


	if Owner:Alive() == true then  //  CHECK:	IF THE OWNER OF THE KILLSTREAK *IS ALIVE*, THEN...
	
	
		return 1  //  RETURN A VALUE OF "1"
	
	
	else  //  IF THE OWNER OF THE KILLSTREAK IS *NOT ALIVE*, THEN...
	
	
		return 0  //  RETURN A VALUE OF "0"
	

	end  //  FINISH THE CHECK


end  //  COMPLETE THE FUNCTION


function ENT:Think()
	
	
	self:NextThink( CurTime() + 0.1 )
	
	
	local Status = Check_Status( self.Owner )  //  CREATE A LOCAL VARIABLE CALLED:	"Status"	-	STORE THE VALUE RETURNED BY THE FUNCTION "Check_Status" ( PASS THE OWNER OF THE KILLSTREAK TO THE FUNCTION )
	
	
	if Status == 1 then  //  CHECK:  IF THE FUNCTION "Check_Status" RETURNED A VALUE OF "1" ( THE OWNER OF THE KILLSTREAK IS STILL ALIVE ), THEN...
	
	
	if self.DropLoc == nil then return true end

	
	if self.findHoverZone then
		self.findHoverZone = false;
		GAMEMODE:SetPlayerSpeed(self.Owner, self.playerSpeeds[1], self.playerSpeeds[2])
		if IsValid(self.Wep) then
			self.Wep:CallIn();
		end

		self.jet1Alive = true;
		self.Jet1:SetVar("JetDropZone", self.DropLoc)
		self.Jet1:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
		self.Jet1:Spawn()
		self.Jet1:Activate()
		self.SpawnDelay = CurTime() + 2;		
	end
	if !self.findHoverZone && self.playOnce then
		self.Wep:PlaySound();
		self.playOnce = false;
	end
		if self.SpawnDelay <= CurTime() && self.jet1Alive then//
			self.jet1Alive = false;
			self.jet2Alive = true;
			self.Jet2:SetVar("JetDropZone", self.DropLoc)
			self.Jet2:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
			self.Jet2:Spawn();
			self.Jet2:Activate();
			self.SpawnDelay = CurTime() + 2;
		elseif self.SpawnDelay <= CurTime() && self.jet2Alive then
			self.jet2Alive = false;			
			self.Harrier:SetVar("HarrierHoverZone", self.DropLoc)
			self.Harrier:SetVar("FromCarePackage", self:GetVar("FromCarePackage",false))
			self.Harrier:Spawn();
			self.Harrier:Activate();
			self:Remove()
		end
		
		
	elseif Status != 1 then  //  IF THE FUNCTION "Check_Status" RETURNED A VALUE THAT IS *NOT EQUAL* TO "1" ( THE OWNER OF THE KILLSTREAK IS NOT ALIVE ), THEN...
	
	
		self:Remove()  //  REMOVE THE KILLSTREAK
		
		
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
	
	self.Harrier = ents.Create("sent_harrier")
	self.Harrier:SetVar("owner",self.Owner) 

	self:OpenOverlayMap(false);
	
end