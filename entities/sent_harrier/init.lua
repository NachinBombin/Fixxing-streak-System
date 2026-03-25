AddCSLuaFile( "shared.lua" )


AddCSLuaFile( 'cl_init.lua' )	//	MARK CUSTOM CLIENT FILE AS IMPORTANT AND SEND IT TO OTHER PLAYERS


include( 'shared.lua' )


local bulletSound = Sound("killstreak_rewards/harrier_shoot.wav");
local hoveringSound = Sound("killstreak_rewards/harrier_hover.wav");
local hoverSoundDuration = SoundDuration( hoveringSound );

local backLeftWing = Model("models/military2/air/gibs/backleftwing.mdl");
local backRightWing = Model("models/military2/air/gibs/backrightwing.mdl");
local cockPit = Model("models/military2/air/gibs/cockpit.mdl");
local leftWing = Model("models/military2/air/gibs/leftwing.mdl");
local middle = Model("models/military2/air/gibs/middle.mdl");
local rightWing = Model("models/military2/air/gibs/rightwing.mdl");


ENT.radius = 2000;
ENT.radi = 20
ENT.shootPos = Vector(153, 3, -13)
ENT.sky = 0;
ENT.distance = 0;
ENT.hoverPos = NULL;
ENT.hoverMode = false;
ENT.flyTo = true
ENT.startTimer = true;
ENT.curTarget = nil;
ENT.shootDelay = CurTime();
ENT.setPos = true;
ENT.curPos = NULL;
ENT.curAng = NULL;
ENT.turnDelay = CurTime()
ENT.keepPlaying = false;
ENT.alreadyBlownUp = false;
ENT.retireDelay = CurTime();
ENT.retireOnce = false;
ENT.friendlys = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }
ENT.targets = NULL;
ENT.SoundTime = CurTime();

ENT.movementDelay = CurTime() + 8;
ENT.startAngle = 180;
ENT.turnFactor = 1;
ENT.turnAmount = 45;
ENT.turned = 0;
ENT.newAngle = 0;
ENT.direction = math.random(0,1)
ENT.moveTime = CurTime();
ENT.StartMove = false;
ENT.AllowMove = true; -- True means the harrier will move, false = wont move.

function ENT:PhysicsUpdate() -- Think
	self.distance = math.Dist(self.Entity:GetPos().x, self.Entity:GetPos().y, self.hoverPos.x, self.hoverPos.y)
	self:SetAngles(self.curAng);
	if !self:FindHoverZone() && self.flyTo then
		self.PhysObj:SetVelocity(self.Entity:GetForward()* self.distance)
		self.Entity:SetPos(Vector(self.Entity:GetPos().x, self.Entity:GetPos().y, self.sky));

	elseif self:FindHoverZone() && self.flyTo then
		self.hoverMode = true;
		self.flyTo = false;

	elseif self.hoverMode then
		self.PhysObj:SetVelocity(Vector(0,0,0))
		if self.setPos then
			self.curPos = self.Entity:GetPos()
			self.setPos = false;
		end

		if self.startTimer then --// Sets a timer so that the harrier will leave after 60 seconds
			self.retireDelay = CurTime() + 60;
			self.retireOnce = true;
			self.startTimer = false;
		end

		if self.curTarget != nil && self.curTarget:IsValid() && self.shootDelay <= CurTime() then	--// This is what tells the harrier to attack the target
			self.StartMove = false;
			self.shootDelay = CurTime() + 0.2;
			self:EngageEnemy();

		elseif ( self.curTarget == nil || !self.curTarget:IsValid() ) && self.shootDelay <= CurTime() then	--// if there is no target then find one
			self.curTarget = nil;
			if !self.StartMove then
				self.StartMove = true;
				self.movementDelay = CurTime() + 8;
			end
			self.shootDelay = CurTime() + 0.01
			self:FindEnemys();
		end

		if self.StartMove && self.AllowMove then
			self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self.sky))
			self:SetAngles(Angle(0, self.startAngle + self.newAngle,0))
			if self.movementDelay < CurTime() && math.abs(self.turned) < self.turnAmount * self.turnFactor then
				if direction == 0 then
					self.turned = self.turned + 1;
					self.newAngle = self.newAngle + 1;
				else
					self.turned = self.turned - 1;
					self.newAngle = self.newAngle - 1;
				end
			elseif self.movementDelay < CurTime() && math.abs(self.turned) >= self.turnAmount * self.turnFactor then
				self.turned = 0;
				self.movementDelay = CurTime() + 8;
				self.moveTime = CurTime() + .5;
				self.direction = math.random(0,1)
				self.turnFactor =  math.random(1,6)
			elseif self.moveTime > CurTime() then
				self.PhysObj:SetVelocity(self:GetForward() * 600)
			end
		else
			self.Entity:SetPos(self.curPos);
		end

	elseif !self.flyTo && !self.hoverMode then
		self.PhysObj:SetVelocity(self.Entity:GetForward()*(self.distance + 50))
	end

	if( !self.Entity:IsInWorld()) then
		self:Remove();
	end

	if self.SoundTime <= CurTime() && self.keepPlaying then
		self:StartHoverSound()
		self.SoundTime = hoverSoundDuration + CurTime()
	end

	if self.retireOnce && self.retireDelay <= CurTime() && self.curTarget == nil then
		self.retireOnce = false;
		self:HarrierLeave()
	end

end

function ENT:Initialize()
	self.hoverMode = false;
	self.flyTo = true
	self.startTimer = true;
	self.retireOnce = false;
	self.curTarget = nil;
	self.setPos = true;

	self.Owner = self.Entity:GetVar( "owner" )

--	self.hoverPos = self.Owner:GetNetworkedVector("Hover_zone_vector");
	self.hoverPos = self:GetVar("HarrierHoverZone", NULL)
	self.spawnPos = self.Owner:GetNetworkedVector("Harrier_Spawn_Pos");
	self.sky = self.spawnPos.z
	self.hoverPos = Vector(self.hoverPos.x, self.hoverPos.y, self.sky)

	self.Entity:SetModel( "models/harrier.mdl" )
	self.Entity:SetColor( Color( 255, 255, 255 ) )
	self.Entity:SetPos( self.spawnPos)
	self.curAng = Angle(0, self.startAngle, 0);
	self.Entity:SetAngles(self.curAng)

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity(false);
		self.PhysObj:Wake()
	end
	self.PhysgunDisabled = true
	constraint.NoCollide( self.Entity, game.GetWorld(), 0, 0 );
	self.keepPlaying = true
	self.alreadyBlownUp = false;


	self:CALL_HARRIER()  //	AFTER THE HARRIER HAS BEEN SUCCESSFULLY INITIALIZED, RUN CUSTOM FUNCTION EXPLAINED BELOW


end


function ENT:CALL_HARRIER()  //	CREATE A GLOBAL FUNCTION CALLED:	"CALL_HARRIER"


	local Players = player.GetHumans()	//	CREATE A LOCAL VARIABLE CALLED:  "Players"	-	STORE ALL PLAYERS FOUND ACROSS THE SERVER


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then  //	CHECK:	IF TEAMS *ARE ENABLED*, THEN...


		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...


			if Value:Team() == self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS ON THE *SAME TEAM* AS THE OWNER OF THE HARRIER, THEN...


				umsg.Start( "MW2_HARRIER_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_HARRIER_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			elseif Value:Team() != self.Owner:Team() then	//	IF THE CURRENT PLAYER BEING LOOKED AT IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE HARRIER, THEN...


				umsg.Start( "MW2_HARRIER_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_HARRIER_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE


				print( "[ HARRIER BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE


			end  //  FINISH THE "IF" STATEMENT


		end  //  FINISH LOOPING


	else  //	IF TEAMS ARE *NOT ENABLED*, THEN...


		for Key, Value in pairs( Players ) do		//	CREATE A LOOP IN ORDER TO ITERATE THROUGH EACH PLAYER FOUND  -  FOR EACH PLAYER FOUND, DO THE FOLLOWING...


			if Value == self.Owner then  //  IF THE PLAYER CURRENTLY BEING LOOKED AT *IS THE OWNER* OF THE HARRIER, THEN...


				umsg.Start( "MW2_HARRIER_FRIENDLY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_HARRIER_FRIENDLY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED


			elseif Value != self.Owner then		//	IF THE PLAYER CURRENTLY BEING LOOKED AT IS *NOT THE OWNER* OF THE HARRIER, THEN...


				umsg.Start( "MW2_HARRIER_ENEMY", Value );  //  CREATE A MESSAGE (EVENT) CALLED:	"MW2_HARRIER_ENEMY"	-	SEND TO THE PLAYER CURRENTLY BEING PROCESSED


				umsg.End();  //  TELL THE SYSTEM THAT ALL MESSAGES HAVE BEEN DEFINED
				
				
			else	//	IF BOTH CONDITIONS FAIL, PRINT AN ERROR MESSAGE


				print( "[ HARRIER BROADCAST FAILED ] - TRIED TO SEND MESSAGE TO: ", Value )		//	PRINT ERROR MESSAGE TO SERVER CONSOLE


			end  //  FINISH THE "IF" STATEMENT


		end  //  FINISH THE LOOP


	end  //  FINISH THE CHECK


end  //  TELL THE SYSTEM THAT THE FUNCTION HAS BEEN FULLY DEFINED


function ENT:FindHoverZone()
	local jetPos = self.Entity:GetPos();
	self.distanceToTarget = jetPos - self.hoverPos;
	if math.abs(self.distanceToTarget.x) <= self.radi && math.abs(self.distanceToTarget.y) <= self.radi then
		return true;
	end
	return false;
end

function ENT:FindEnemys()
	self.groundV2 = -16384;

	minVec = self.Entity:GetPos() - Vector(self.radius, self.radius, 0);
	minVec = Vector(minVec.x, minVec.y, self.groundV2);
	maxVec = self.Entity:GetPos() + Vector(self.radius, self.radius, 0);

--[[
	minVec = (self.Entity:GetPos() + (self.Entity:GetRight() * radius)) * -1;
	minVec = Vector(minVec.x, minVec.y, 0);
	maxVec = self.Entity:GetPos() + (self.Entity:GetForward() * radius)
	maxVec = Vector(maxVec.x, maxVec.y, -16384);
	]]
	self.targets = ents.FindInBox(minVec, maxVec)
	enemys = {}
	for k, v in pairs(self.targets) do
		if self:FilterEnemy(v) then
			table.insert(enemys, v);
		end
	end
	if table.Count(enemys) >= 1 then
		self.curTarget = table.Random(enemys);
	else
		self.curTarget = nil;
	end
end


function ENT:FilterEnemy( Value )


	if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then  //  CHECK:  IF TEAMS *ARE ENABLED*, THEN...


		if Value:IsValid() then  //  IF THE ENTITY PASSED AS AN ARGUMENT *IS VALID*, THEN...


			if ( ( Value:IsNPC() && checkForStriders( Value ) ) or ( Value:IsPlayer() && Value:Team() != self.Owner:Team() ) ) then  //  CHECK:  IF THE ENTITY *IS AN NPC*, **AND** "checkForStriders" EXECUTES SUCCESSFULLY,  ** OR **  THE ENTITY *IS A PLAYER*, **AND** THAT PLAYER IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE HARRIER, THEN...


				if !table.HasValue( self.friendlys, Value:GetClass() ) and Value:GetClass() != "npc_bullseye" and Value:GetClass() != "npc_turret_floor" then  //	CHECK:  IF AN NPC IS *NOT A FRIENDLY* ( DOES NOT HAVE AN ENTRY IN THE "friendlys" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					if self:traceHitEnemy( Value ) then  //  CHECK:  IF THE HARRIER CAN HIT THE ENEMY, THEN...


						return true;  //  RETURN "true" TO THE CALLING FUNCTION


					end  //  FINISH THE CHECK


				end  //  FINISH THE CHECK


			end  //  FINISH CHECKING THE ENTITY


		end  //  FINISH CHECKING VALIDITY


	else  //  IF TEAMS ARE *NOT ENABLED*, THEN...


		if Value:IsValid() then  //  IF THE ENTITY PASSED AS AN ARGUMENT *IS VALID*, THEN...


			if ( ( Value:IsNPC() && checkForStriders( Value ) ) or ( Value:IsPlayer() && Value != self.Owner ) ) then  //  CHECK:  IF THE ENTITY *IS AN NPC*, **AND** "checkForStriders" EXECUTES SUCCESSFULLY,  ** OR **  THE ENTITY *IS A PLAYER*, **AND** THAT PLAYER IS *NOT THE OWNER* OF THE HARRIER, THEN...


				if !table.HasValue( self.friendlys, Value:GetClass() ) and Value:GetClass() != "npc_bullseye" and Value:GetClass() != "npc_turret_floor" then  //	CHECK:  IF AN NPC IS *NOT A FRIENDLY* ( DOES NOT HAVE AN ENTRY IN THE "friendlys" TABLE ), **AND** THE NPC IS *NOT A SENTRY GUN*, **AND** THE NPC IS *NOT A TURRET*, THEN...


					if self:traceHitEnemy( Value ) then  //  CHECK:  IF THE HARRIER CAN HIT THE ENEMY, THEN...


						return true;  //  RETURN "true" TO THE CALLING FUNCTION


					end  //  FINISH THE CHECK


				end  //  FINISH THE CHECK


			end  //  FINISH CHECKING THE ENTITY


		end  //  FINISH CHECKING VALIDITY


	end  //  FINISH CHECKING IF TEAMS ARE ENABLED


	return false;


end

function checkForStriders(v)
	if v:GetClass() == "npc_strider" then return false end
	local tab = string.Explode("_", v:GetClass())
	if table.HasValue( tab, "strider" ) then
		return false
	end
	return true;
end

function ENT:EngageEnemy()
	if self.curTarget:IsValid() && self:traceHitEnemy(self.curTarget) then
		local entityCenter = Vector(0, 0, self.curTarget:OBBMaxs().z)
		local pos = self.curTarget:GetPos() - (self.curTarget:OBBCenter( ) - entityCenter)
		local dist = (self.Entity:GetPos() + self.shootPos) - pos;
		local target = dist:GetNormal();
		target = target * -1;

		bullet = {}

		bullet.Src		= self.Entity:GetPos() + self.shootPos;
		bullet.Attacker = self.Owner;
		bullet.Dir		= target;

		bullet.Spread		= Vector(0.01,0.01,0)
		bullet.Num		= 1
		bullet.Damage		= 20
		bullet.Force		= 5
		bullet.Tracer		= 1
		bullet.TracerName	= "HelicopterTracer"

		self.Entity:FireBullets(bullet);
		self:EmitSound(bulletSound,140,100)
	end
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:traceHitEnemy(enemy)

	local startPos = self:GetPos();
	local endPos = enemy:GetPos();

	local trace = {}
	trace.start = startPos;
	trace.endpos = endPos;
	trace.filter = self;

	local clearSight = false;
	local traceData = util.TraceLine(trace);
	local hitWorld = traceData.HitWorld;

	if hitWorld then
		clearSight = false;
	else
		clearSight = true;
	end
	return clearSight;
end

function ENT:HarrierLeave()


	self.hoverMode = false;


	self.keepPlaying = false;


	self:StopSound( "Harrier_Hover" );	//	STOP THE "HOVERING" SOUND


	self.Entity:EmitSound( "killstreak_rewards/harrier_leave.wav", 100 )	//	PLAY CUSTOM SOUND ONCE HARRIER BEGINS TO LEAVE THE AREA


end

function ENT:StartHoverSound()
	self.Entity:EmitSound( "Harrier_Hover" )
end

function ENT:OnTakeDamage(dmg)
	if( dmg:IsExplosionDamage() ) then
		self:Destroy();
	end
end

function ENT:Destroy()


	self:BlowUpJet();


end

function ENT:BlowUpJet()
	if self.alreadyBlownUp then return end;
	self.alreadyBlownUp = true;
	--Boom!
		local expl = ents.Create("env_explosion")
		expl:SetKeyValue("spawnflags",128)
		expl:SetPos(self.Entity:GetPos())
		expl:Spawn()
		expl:Fire("explode","",0)

		local FireExp = ents.Create("env_physexplosion")
		FireExp:SetPos(self.Entity:GetPos())
		FireExp:SetParent(self.Entity)
		FireExp:SetKeyValue("magnitude", 500)
		FireExp:SetKeyValue("radius", 500)
		FireExp:SetKeyValue("spawnflags", "1")
		FireExp:Spawn()
		FireExp:Fire("Explode", "", 0)
		FireExp:Fire("kill", "", 5)
		util.BlastDamage( self.Entity, self.Entity, self.Entity:GetPos(), 500, 500)

		local effectdata = EffectData()
		effectdata:SetStart( self.Entity:GetPos() )
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetScale( 1 )

		--Explosions!

		local ParticleExplode = ents.Create("info_particle_system")
		ParticleExplode:SetPos(self:GetPos())
		ParticleExplode:SetKeyValue("effect_name", "harrier_explode") -- The names are cluster_explode, 40mm_explode, and agm_explode.
		ParticleExplode:SetKeyValue("start_active", "1")
		ParticleExplode:Spawn()
		ParticleExplode:Activate()
		ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.


		util.Effect( "Explosion", effectdata )
		util.Effect( "HelicopterMegaBomb", effectdata )
		util.Effect( "cball_explode", effectdata )

		self.Entity:SetColor(Color(0,0,0,255))

		--Spawning gibs
		local gib = NULL;
		gib = ents.Create( "prop_physics" )
		gib:SetModel(backLeftWing)
		gib:SetColor(Color(150,150,150,255)	)
		gib:SetPos(self.Entity:GetPos())
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)

		gib = ents.Create( "prop_physics" )
		gib:SetModel(backRightWing)
		gib:SetColor(Color(150,150,150,255))
		gib:SetPos(self.Entity:GetPos())
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)

		gib = ents.Create( "prop_physics" )
		gib:SetModel(cockPit)
		gib:SetColor(Color(150,150,150,255))
		gib:SetPos(self.Entity:GetPos())
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)

		gib = ents.Create( "prop_physics" )
		gib:SetModel(leftWing)
		gib:SetColor(Color(150,150,150,255))
		gib:SetPos(self.Entity:GetPos())
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)

		gib = ents.Create( "prop_physics" )
		gib:SetModel(middle)
		gib:SetColor(Color(150,150,150,255))
		gib:SetPos(self.Entity:GetPos())
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)

		gib = ents.Create( "prop_physics" )
		gib:SetModel(rightWing)
		gib:SetColor(Color(150,150,150,255))
		gib:SetPos(self.Entity:GetPos())
		gib:SetAngles(self.Entity:GetAngles())
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self.Entity:GetVelocity() )
		gib:Fire("kill", "", 15)

		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetStart( Vector(0,0,90) )
		util.Effect( "jetdestruction_explosion", effectdata )


		self:StopSound( "Harrier_Hover" )


		self.Entity:Remove()
end
