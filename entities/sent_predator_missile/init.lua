AddCSLuaFile( "cl_init.lua" )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Model = "models/military2/bomb/bomb_cbu.mdl";
ENT.moveFactor = 0.5;
ENT.speedFactor = 1;
ENT.speedBoost = true;
ENT.keepPlaying = false;
ENT.playerAng = NULL;
ENT.playerWeapons = {};
ENT.Sky = 0;
ENT.ang = nil;
ENT.turnDelay = CurTime();
ENT.playerSpeeds = {};
ENT.MissileSpeed = 0;
ENT.restrictMovement = true;
local missileThrustSound = Sound("killstreak_rewards/predator_missile_thruster.wav")
local missileBoostSound = Sound("killstreak_rewards/predator_missile_boost.wav")
local missileExplosionSound = Sound("killstreak_rewards/predator_missile_explosion.wav")
local thrustSoundDuration = SoundDuration(missileThrustSound);


local PLAYER_ALIVE = NULL	//	CREATE A LOCAL VARIABLE CALLED "PLAYER_ALIVE"  -  SET IT TO "NULL" (NOTHING) INITIALLY. USED FOR ENSURING THE PLAYER IS ALIVE WHILE THE PREDATOR-MISSILE IS BEING CONTROLLED


function ENT:PhysicsUpdate()


	self.PhysObj:SetVelocity((self.Entity:GetForward()* self.MissileSpeed ) * self.speedFactor)

	self.ang = self:GetAngles()


	if self.Entity.Owner:KeyDown( IN_FORWARD ) and PLAYER_ALIVE == 1 then	//	IF THE OWNER OF THE PREDATOR-MISSILE PRESSES THE "FORWARD" KEY, **AND** THE PLAYER *IS ALIVE*, THEN...


		if self.ang.p > 30 then  //  RAISED THE LIMIT TO A MORE APPROPRIATE VALUE


			self.ang =  Angle( self.ang.p - self.moveFactor, self.ang.y, self.ang.r )


		end


	elseif self.Owner:KeyDown( IN_BACK ) and PLAYER_ALIVE == 1 then		//	IF THE OWNER OF THE PREDATOR-MISSILE PRESSES THE "BACK" KEY, **AND** THE PLAYER *IS ALIVE*, THEN...


		if self.ang.p < 89 then


			self.ang =  Angle( self.ang.p + self.moveFactor, self.ang.y, self.ang.r )


		end


	end


	if self.Entity.Owner:KeyDown( IN_MOVERIGHT ) and PLAYER_ALIVE == 1 then		//	IF THE OWNER OF THE PREDATOR-MISSILE PRESSES THE "MOVE-RIGHT" KEY, **AND** THE PLAYER *IS ALIVE*, THEN...
		self.ang =  Angle( self.ang.p, self.ang.y - self.moveFactor, self.ang.r )
	elseif 	self.Owner:KeyDown( IN_MOVELEFT ) and PLAYER_ALIVE == 1 then	//	IF THE OWNER OF THE PREDATOR-MISSILE PRESSES THE "MOVE-LEFT" KEY, **AND** THE PLAYER *IS ALIVE*, THEN...
		self.ang =  Angle( self.ang.p, self.ang.y + self.moveFactor, self.ang.r )
	end
	self:SetAngles(self.ang)

	if self.Owner:KeyDown( IN_ATTACK ) and PLAYER_ALIVE == 1 && self.speedBoost then	//	IF THE OWNER OF THE PREDATOR-MISSILE PRESSES THE "ATTACK" KEY, **AND** THE PLAYER *IS ALIVE*, **AND** THE PREDATOR-MISSILE IS *NOT* ALREADY BEING "BOOSTED", THEN...
		self.speedFactor = 2;
		self.speedBoost = false;
		self.Entity:EmitSound( missileBoostSound, 40 )
		self:SetNWBool("Boosted",true)
	end

		if self.Trail and self.Trail:IsValid() and PLAYER_ALIVE == 1 then
			self.Trail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
			self.Trail:SetLocalAngles(Angle(0,0,0))
		else
			self:SpawnTrail()
		end
	if (self.NextThrustSound or 0) <= CurTime() then
		self.NextThrustSound = CurTime() + 5
		self:EmitSound( missileThrustSound )
	end
	
	
	if self.Owner:Alive() == false then		//	CHECK:	IF AT ANY POINT THE OWNER OF THE PREDATOR-MISSILE IS *NOT* ALIVE (KILLED IN ACTION), THEN...


		self.Owner:SetViewEntity(self.Owner)	//	SET THE VIEW ENTITY BACK TO THE OWNER OF THE PREDATOR-MISSILE INSTEAD OF THE MISSILE ITSELF


		self.Owner:ExitVehicle()	//	EXIT THE CAMERA POSITION OF THE PREDATOR-MISSILE


		self.Owner:SetAngles(self.playerAng)	//	SET THE VIEW ANGLES BACK TO THE PLAYER'S EYES


		GAMEMODE:SetPlayerSpeed(self.Owner, self.playerSpeeds[1], self.playerSpeeds[2])		//	RESET THE PLAYER'S SPEED VALUES TO "NORMAL"


		umsg.Start("Predator_missile_RemoveHUD", self.Owner);	//	REMOVE THE PREDATOR-MISSILE HEAD-UP-DISPLAY


		umsg.End();		//	END THE USER-MESSAGE

		
		hook.Remove( "Move", "RESTRICT_MOVEMENT" )	//	REMOVE CUSTOM HOOK CREATED CALLED:	"RESTRICT_MOVEMENT"


		self.Owner:SetMoveType( MOVETYPE_WALK )  //  ALLOW THE OWNER OF THE PREDATOR-MISSILE TO MOVE AGAIN


		self.restrictMovement = false;			//	SAVE THE MOVEMENT STATE
		
		
		PLAYER_ALIVE = 0	//	SIGNAL THAT THE PLAYER WAS KILLED
		

	end		//	FINISH THE CHECK


end


function ENT:Think()

	if not IsValid(self.PhysObj) or not self.PhysObj:IsValid() then self:Remove() return end


	if self.PhysObj:IsAsleep() then


		self.PhysObj:Wake()


	end

end

function ENT:PhysicsCollide( data, physobj )


	if data.Speed > 50 and data.DeltaTime > 0.15 then


		self:PredatorExplosion()
		self.Owner:SetViewEntity(self.Owner)
		self.Owner:ExitVehicle()
		self.Owner:SetAngles(self.playerAng)
		GAMEMODE:SetPlayerSpeed(self.Owner, self.playerSpeeds[1], self.playerSpeeds[2])
		umsg.Start("Predator_missile_RemoveHUD", self.Owner);
		umsg.End();


		if IsValid(self.Wep) then
			self.Wep:CallIn();
		end


	end


end


function ENT:PredatorExplosion()

	util.BlastDamage(self, self.Owner, self:GetPos(), 700, 700)
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "agm_explode")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.


	local shake = ents.Create("env_shake")
		shake:SetOwner(self)
		shake:SetPos(self.Entity:GetPos())
		shake:SetKeyValue("amplitude", "2000")	// Power of the shake
		shake:SetKeyValue("radius", "1250")		// Radius of the shake
		shake:SetKeyValue("duration", "2.5")	// Time of shake
		shake:SetKeyValue("frequency", "255")	// How hard should the screenshake be
		shake:SetKeyValue("spawnflags", "4")	// Spawnflags(In Air)
		shake:Spawn()
		shake:Activate()
		shake:Fire("StartShake", "", 0)

	self:StopThrustSound();
	self.Entity:EmitSound( missileExplosionSound, 100 )
	--[[for k,v in pairs(player.GetAll()) do
		v:EmitSound(missileExplosionSound,400,100)
	end]]
	self:SetNWBool("Exploded",true)
	self:SetColor(Color(255,255,255,0))
	self:SetRenderMode(1)
	self:GetPhysicsObject():EnableMotion(false)
	self:GetPhysicsObject():EnableCollisions(false)


	local en = ents.FindInSphere(self:GetPos(), 500)
	local phys
	for k, v in pairs(en) do
		phys = v:GetPhysicsObject()
		if (phys:IsValid()) then
			v:Fire("enablemotion", "", 0)
			constraint.RemoveAll(v)
			phys:ApplyForceCenter( ( v:GetPos() - self:GetPos() ):GetNormal() * phys:GetMass() * 1500 )
		end
		if v:GetClass() == "npc_strider" then
			v:Fire("Break","",0);
		end
	end


	timer.Simple( 1, function()  //  CREATE A "SIMPLE" TIMER THAT LASTS FOR "1" SECOND TO ALLOW *SAFE REMOVAL* OF THE ENTITY


		if self:IsValid() == true then  //  CHECK:	IF ( AFTER "1" SECOND ), THE ENTITY IS STILL VALID ( ALIVE ), THEN...


			self:Remove()  //  REMOVE THE ENTITY


			hook.Remove( "Move", "RESTRICT_MOVEMENT" )	//	REMOVE CUSTOM HOOK CREATED CALLED:	"RESTRICT_MOVEMENT"


			self.Owner:SetMoveType( MOVETYPE_WALK )  //  ALLOW THE OWNER OF THE PREDATOR-MISSILE TO MOVE AGAIN


			self.restrictMovement = false;			//	SAVE THE MOVEMENT STATE


		end  //  FINISH THE CHECK


	end )  //  FINISH THE TIMER


end


function ENT:LAUNCH_MISSILE()	//	CREATE A GLOBAL FUNCTION CALLED:	"LAUNCH_MISSILE"


	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then  //	CHECK:	IF TEAMS *ARE ENABLED*, THEN...


		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...


			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE PREDATOR-MISSILE, THEN...


				umsg.Start( "MW2_PREDATOR_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_PREDATOR_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			elseif Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE PREDATOR-MISSILE, THEN...


				umsg.Start( "MW2_PREDATOR_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_PREDATOR_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE


				print( "[ PREDATOR BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE


			end  //  FINISH THE "IF" STATEMENT


		end  //  FINISH LOOPING


	else	//	IF TEAMS ARE *NOT ENABLED*, THEN...


		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...


			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE PREDATOR-MISSILE, THEN...


				umsg.Start( "MW2_PREDATOR_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_PREDATOR_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			elseif Value != self.Owner then		//	IF THE PLAYER CURRENTLY BEING LOOKED AT IS *NOT THE OWNER* OF THE PREDATOR-MISSILE, THEN...


				umsg.Start( "MW2_PREDATOR_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_PREDATOR_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE


				print( "[ PREDATOR BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE


			end  //  FINISH THE "IF" STATEMENT


		end  //  FINISH THE LOOP


	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function RESTRICT_OWNER_MOVEMENT( PLAYER, MOVEMENT )	//	CREATE GLOBAL FUNCTION CALLED:	"RESTRICT_OWNER_MOVEMENT"	-	ACCEPT TWO PARAMETERS


	PLAYER:SetMoveType( MOVETYPE_NONE )  //  DO NOT ALLOW ANY PLAYER MOVEMENT


	PLAYER.restrictMovement = true;		//	SAVE THE MOVEMENT STATE


end  //  COMPLETE THE FUNCTION


function ENT:MW2_Init()


	self.Sky = self.Sky - 100;

	local lplPos = self.Owner:GetPos()
	local skyVector = Vector(lplPos.x,lplPos.y, self.Sky);
	
	
	if self.Owner:Alive() then	//	CHECK:	IF THE OWNER OF THE PREDATOR-MISSILE *IS ALIVE*, THEN...
	
	
		PLAYER_ALIVE = 1	//	SET THE VARIABLE TO "1" (THE PLAYER IS ALIVE)
		
	
	end		//	FINISH THE CHECK

	
	--self.speedFactor = 1;
	--self.speedBoost = true;

	self.Entity:SetPos(skyVector)
	self.Entity:SetAngles(Angle(75, self.Owner:EyeAngles().y, 0))

	--self.playerSpeeds = { self.Owner:GetWalkSpeed(), self.Owner:GetRunSpeed() }
	--GAMEMODE:SetPlayerSpeed(self.Owner, -1, -1)

	self.playerAng = self.Owner:GetAngles();

	self.Owner:SetViewEntity(self);
	umsg.Start("Predator_missile_SetUpHUD", self.Owner);
	umsg.End()
	self.keepPlaying = true;
	self.MissileSpeed = math.Clamp(Vector(0,0, self.Sky):Distance( Vector( 0,0, self:findGround()) ), 0, 2000)


	self.Owner = self:GetVar( "owner" )


	hook.Add( "Move", "RESTRICT_MOVEMENT", function( PLY, DATA )	//	ADD A HOOK CALLED:	"RESTRICT_MOVEMENT"  -  EACH TIME A PLAYER TRIES TO "MOVE", DO THE FOLLOWING...


		if PLY == self.Owner then	//	CHECK:	IF THE PLAYER TRYING TO MOVE *IS THE OWNER* OF THE PREDATOR-MISSILE, THEN...


			RESTRICT_OWNER_MOVEMENT( PLY, DATA )	//	RUN CUSTOM FUNCTION DEFINED ABOVE ( PASS THE OWNER AND MOVEMENT DATA AS INDIVIDUAL ARGUMENTS )


		end  //  FINISH THE CHECK


	end )  //  COMPLETE THE FUNCTION ( AND THE HOOK )


	self:LAUNCH_MISSILE()	//	AFTER THE PREDATOR-MISSILE HAS BEEN SUCCESSFULLY INITIALIZED, RUN CUSTOM FUNCTION EXPLAINED ABOVE


end


function ENT:OnTakeDamage( dmginfo )
	self.Entity:TakePhysicsDamage( dmginfo )
end

function ENT:SpawnTrail()

	self.Trail = ents.Create("env_rockettrail")
	self.Trail:SetPos(self.Entity:GetPos() - 16*self.Entity:GetForward())
	self.Trail:SetParent(self.Entity)
	self.Trail:SetLocalAngles(Angle(0,0,0))
	self.Trail:Spawn()

end

function ENT:StartThrustSound()
	self.Entity:EmitSound( missileThrustSound )
end

function ENT:StopThrustSound()
	self.keepPlaying = false;
end