AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

local MW2Killstreaks = { "ammo", "uav", "mw2_counter_uav", "predator_missile", "mw2_sentry_gun", "precision_airstrike", "harrier", "stealth_bomber", "ac-130", "mw2_EMP" };

local ammoSlot = 1;
local uavSlot = 2;
local counterSlot = 3;
local predatorSlot = 4;
local sentrySlot = 5;
local precisionSlot = 6;
local harrierSlot = 7;
local attackSlot = harrierSlot;
local stealthSlot = 8;
local paveSlot = stealthSlot;
local acSlot = 9;
local chopperSlot = acSlot;
local empSlot = 10;


ENT.Players = {}
ENT.GiveReward = false;
ENT.Reward = nil;
ENT.Winner = nil;
ENT.Model = Model("models/deathdealer142/supply_crate/supply_crate.mdl");

function ENT:Initialize()	
	self.Owner = self:GetVar("owner")	
	
	self:SetModel( self.Model );
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )	
	self:SetSolid( SOLID_VPHYSICS )	
	
	self.PhysObj = self:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	
	self.PhysgunDisabled = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )
	
	self.Reward = self:PickReward()
	self:SetNetworkedString("SupplyCrate_Reward", self.Reward) -- Have to use a network variable because the reward needs to be accessed from client side.
	self:SetSkin( self.Owner:GetNetworkedString("MW2TeamSound") - 1 )
	
	
end

function ENT:PickReward()
	if self:GetVar("IsSentry",false) then
		return MW2Killstreaks[sentrySlot]; -- Will return the sentry gun when its implemented
	end
	local num = math.random(1, 100)
	local str = "";
	local crateType = self:GetVar("CrateType", "sent_CarePackage")
	if crateType == "sent_CarePackage" then
		if num <= 15 then --15 - Ammo
			str = MW2Killstreaks[ammoSlot]
		elseif num > 15 && num <= 30 then --15 - UAV
			str = MW2Killstreaks[uavSlot]
		elseif num > 30 && num <= 43 then --13 - Counter-UAV
			str = MW2Killstreaks[counterSlot]
		elseif num > 43 && num <= 53 then --10 - Sentry Gun
			str = MW2Killstreaks[sentrySlot]
		elseif num > 53 && num <= 63 then --10 - Predator Missile
			str = MW2Killstreaks[predatorSlot]
		elseif num > 63 && num <= 73 then --10 - Precision Airstrike
			str = MW2Killstreaks[precisionSlot]
		elseif num > 73 && num <= 79 then --6 - Harrier Strike
			str = MW2Killstreaks[harrierSlot]
		elseif num > 79 && num <= 85 then --6 - Attack Helicopter
			str = MW2Killstreaks[attackSlot]
		elseif num > 85 && num <= 89 then --4 - Pave Low
			str = MW2Killstreaks[paveSlot]
		elseif num > 89 && num <= 93 then --4 - Stealth Bomber
			str = MW2Killstreaks[stealthSlot]
		elseif num > 93 && num <= 96 then --3 - Chopper Gunner
			str = MW2Killstreaks[chopperSlot]
		elseif num > 96 && num <= 99 then --3 - AC-130
			str = MW2Killstreaks[acSlot]
		elseif num > 99 then --1 - EMP 
			str = MW2Killstreaks[empSlot]
		end
	else
		if num <= 12 then --12 - Ammo
			str = MW2Killstreaks[ammoSlot]
		elseif num > 12 && num <= 24 then --12 - UAV
			str = MW2Killstreaks[uavSlot]
		elseif num > 24 && num <= 40 then --16 - Counter-UAV
			str = MW2Killstreaks[counterSlot]
		elseif num > 40 && num <= 56 then --16 - Sentry Gun
			str = MW2Killstreaks[sentrySlot]
		elseif num > 56 && num <= 70 then --14 - Predator Missile
			str = MW2Killstreaks[predatorSlot]
		elseif num > 70 && num <= 80 then --10 - Precision Airstrike
			str = MW2Killstreaks[precisionSlot]
		elseif num > 80 && num <= 85 then --5 - Harrier Strike
			str = MW2Killstreaks[harrierSlot]
		elseif num > 85 && num <= 90 then --5 - Attack Helicopter
			str = MW2Killstreaks[attackSlot]
		elseif num > 90 && num <= 93 then --3 - Pave Low
			str = MW2Killstreaks[paveSlot]
		elseif num > 93 && num <= 96 then --3 - Stealth Bomber
			str = MW2Killstreaks[stealthSlot]
		elseif num > 96 && num <= 98 then --2 - Chopper Gunner
			str = MW2Killstreaks[chopperSlot]
		elseif num > 98 && num <= 100 then --2 - AC-130
			str = MW2Killstreaks[acSlot]
		end
	end
	return str;	
end

function ENT:Think()
	
	
	if self.GiveReward then
	

		self.Winner.MW2KV.addKillStreak( self.Winner, self.Reward, true )
	

		for Key, Value in pairs( self.Players ) do 
	

			Value:SetNetworkedBool("SupplyCrate_DrawBarBool", false)
	

			Value.UseBool = false;
	

			table.remove( self.Players, Key );
			
			
			Value:Freeze( false )	//	UNFREEZE THE PLAYER
	

		end
	

		self:Remove()
	

		return;
	
	
	end


	for Key, Value in pairs( self.Players ) do
	
	
		if Value:KeyReleased( IN_USE ) == true and Value.UseBool == true then
		
		
			Value:SetNetworkedBool( "SupplyCrate_DrawBarBool", false )
	

			Value.UseBool = false;
		
		
			table.remove( self.Players, Key )
			
			
			Value:Freeze( false )	//	UNFREEZE THE PLAYER
			
			
		end


	end


end


function ENT:Use( PLY )


	if !PLY.UseBool || PLY.UseBool == nil then
		
		
		table.insert( self.Players, PLY );
		
		
		PLY:SetNetworkedBool("SupplyCrate_DrawBarBool", true)	
		
		
		PLY.SupplyCrate = self;
		
		
		PLY.UseBool = true


		if PLY == self.Owner then

			
			PLY:SetNetworkedFloat( "SupplyCrate_Inc", 4 )
			
			
			PLY:Freeze( true )  //  FREEZE THE PLAYER
			
			
		elseif PLY:Team() == self.Owner:Team() and PLY != self.Owner then
		
		
			PLY:SetNetworkedFloat( "SupplyCrate_Inc", 2 )
		
			
			PLY:Freeze( true )  //  FREEZE THE PLAYER
			
		
		else
		
		
			PLY:SetNetworkedFloat( "SupplyCrate_Inc", 1 )
			
		
			PLY:Freeze( true )  //  FREEZE THE PLAYER
		
		
		end

		
		umsg.Start( "SupplyCrate_DrawBar", PLY );


		umsg.End()
		
		
		umsg.Start( "CHECK_PLAYER_INPUT", PLY )  //  SEND A MESSAGE TO THE CLIENT USING THE SUPPLY CRATE SIGNALING THEIR SYSTEM TO MONITOR THEIR INPUT


		umsg.End()  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


	end


end


function Give_Reward( SIZE, PL )
	
	
	if not IsValid( PL.SupplyCrate ) or PL:Alive() == false then return end
	
	
	PL.SupplyCrate.GiveReward = true -- The Supply Crate
	
	
	PL.SupplyCrate.Winner = PL;
	
	
	timer.Remove( "CAPTURE_TIMER" )  //  REMOVE THE CUSTOM TIMER NAMED:  "CAPTURE_TIMER"
	
	
	PL:Freeze( false )  //  UNFREEZE THE PLAYER
	
	
end


net.Receive( "SupplyCrate_GiveReward", Give_Reward )


function START_CAPTURE( SIZE, PLY )  //  CREATE A GLOBAL FUNCTION CALLED:	"START_CAPTURE"  -  ACCEPT TWO PARAMETERS
	
	
	timer.Create( "CAPTURE_TIMER", 0.5, 0, function()  //  CREATE A SPECIAL TIMER NAMED:	"CAPTURE_TIMER"  -  AFTER EVERY "1/2" SECOND ( REPEATING FOREVER / UNTIL STOPPED ), DO THE FOLLOWING...


		if PLY:KeyDown( IN_USE ) == false then  //  CHECK:	IF THE PLAYER *RELEASES* THEIR "USE" KEY, THEN...
		

			STOP_CAPTURE( SIZE, PLY )	//	STOP CAPTURING THE SUPPLY CRATE ( CALL FUNCTION "STOP_CAPTURE" DEFINED BELOW	-	PASS THE TWO PARAMETERS INITIALLY RECEIVED )

		
		end  //  FINISH THE CHECK


	end )  //  FINISH THE TIMER
	
	
	PLY:SetNetworkedBool( "SupplyCrate_DrawBarBool", true )
	

	PLY.UseBool = true;
	
	
	PLY:Freeze( true )  //  FREEZE THE PLAYER
	

end  //  COMPLETE THE FUNCTION


net.Receive( "START_CAPTURING", START_CAPTURE )  //	IF THE SYSTEM DETECTS THAT A USER SENT A NETWORK MESSAGE NAMED "START_CAPTURING", RUN THE FUNCTION "START_CAPTURE" DEFINED ABOVE


function STOP_CAPTURE( SIZE, PLY )  //  CREATE A GLOBAL FUNCTION CALLED:	"STOP_CAPTURE"  -  ACCEPT TWO PARAMETERS


	timer.Remove( "CAPTURE_TIMER" )  //  REMOVE THE CUSTOM TIMER NAMED:  "CAPTURE_TIMER"


	PLY:SetNetworkedBool( "SupplyCrate_DrawBarBool", false )
	

	PLY.UseBool = false;
	
	
	PLY:Freeze( false )  //  UNFREEZE THE PLAYER


end  //  COMPLETE THE FUNCTION


net.Receive( "STOP_CAPTURING", STOP_CAPTURE )	//	IF THE SYSTEM DETECTS THAT A USER SENT A NETWORK MESSAGE NAMED "STOP_CAPTURING", RUN THE FUNCTION "STOP_CAPTURE" DEFINED ABOVE