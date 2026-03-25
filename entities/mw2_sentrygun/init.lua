AddCSLuaFile( "shared.lua" )


AddCSLuaFile( "cl_init.lua" )


include( 'shared.lua' )


local disToTurret = 50
local Friends = { "npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt", "npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner", "npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield", "npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr", "npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s", "npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg", "npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf", "npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof", "npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3", "npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell", "npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p", "npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull", "npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel", "npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y", "npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa", "npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper", "npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset", "npc_elizabeth_lady_corset", "npc_elizabeth_noire", "npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage", "npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach", "npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush", "npc_elizabeth_torture_corset", "npc_elizabeth_young", "npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams", "npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg", "npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine", "npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret", "npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka", "npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s", "npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret", "npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret", "npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv", "npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert", "npc_su_t80u_turret", "npc_su_t80u_turret_desert", "npc_su_t80u_turret_winter", "npc_su_t80u_winter", "npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber", "npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured", "npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat", "npc_vaas_montenegro", "npc_green_goblin" }
local Sentrys = {};


ENT.Placed = false;
ENT.Target = nil;


ENT.SmokeAttachment = "smoke_particle"
ENT.EngageDelay = CurTime();
ENT.AimDelay = CurTime();
ENT.LifeTimer = CurTime();
ENT.FadeTimer = CurTime();
ENT.yaw = 0;
ENT.pitch = 0;
ENT.OurHealth = 500;
ENT.AutomaticFrameAdvance = true;
ENT.Dead = false;


ENT.TurnDelay = CurTime();
ENT.MaxYaw = 60;
ENT.MinYaw = -60;
ENT.CurYaw = 0;
ENT.Direction = 1;
ENT.InitialTurnDelay = CurTime();


ENT.SnapToDelay = CurTime();
ENT.TurnAmount = 1;
ENT.TurnFactor = 1;
ENT.ShouldSearch = false;


PrecacheParticleSystem( "muzzle_shotgun" )	//	REQUIRED:	ASKS THE SYSTEM TO "SET UP" THE PARTICLE SYSTEM FOR THE "muzzle_shotgun"


PrecacheParticleSystem( "shotgun_muzzle_flash" )	//	REQUIRED:	ASKS THE SYSTEM TO "SET UP" THE PARTICLE SYSTEM FOR THE "shotgun_muzzle_flash"


function ENT:Think()
	self:NextThink(CurTime());
	if self.Dead then
		if self.FadeTimer <= CurTime() then
			self:Remove();
		end
		return true;
	end
	if IsValid(self.Owner) && !self.Placed then
		self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
		self:SetAngles( Angle(0, self.Owner:GetAimVector():Angle().y, 0) )
	end

	if self.Owner:KeyDown( IN_ATTACK ) && !self.Placed then -- Called for when the sentry should be placed
		self.Placed = true;
		self:ResetSequence( self:LookupSequence( "Deploy" ) )
		constraint.Weld(game.GetWorld(), self, 0,0,0, true)
		self.Owner:DrawViewModel(true)
		self.InitialTurnDelay = CurTime() + 3;
		self:SetDisposition( true );	-- Makes the npcs hate the sentry
		self:SetColor( Color( 255, 255, 255 ) )
	end

	if self.Owner:KeyDown( IN_USE ) && self.Placed && self:GetPos():Distance(self.Owner:GetPos()) <= disToTurret then
		self.Placed = false;
		constraint.RemoveConstraints(self,"Weld")
		self.Owner:DrawViewModel( false )
		self:PreDeploy()
		self:SetDisposition( false ); -- makes the npc feel neutral about the sentry
		self:SetColor( Color( 255, 255, 255 ) )
	end

	if self.Placed then
		self:Search();
		--[[
		if !IsValid(self.Target) then
			self:NoTarget()
		end
]]


		--local ConeEnts = ents.FindInCone(self:LocalToWorld(self:OBBCenter()) + (self:GetForward() * -50), self:GetAngles():Forward(), self.Dis, 90)


		--local ConeEnts = ents.FindInCone(self:GetAttachment(self:LookupAttachment(self.BarrelAttachment)).Pos - (self:GetForward() * -50), self:GetAngles():Forward(), self.Dis, 90)


		local ConeEnts = ents.GetAll()  //  GET ALL ENTITIES IN THE SERVER AND STORE THEM IN A TABLE CALLED "ConeEnts"


		if GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0 then	//	CHECK:	IF TEAMS *ARE ENABLED*, THEN...


			if self.Target == nil then	//	CHECK:	IF THERE IS NO TARGET, THEN...


				for i, pEnt in ipairs( ConeEnts ) do	//	FOR EACH ENTITY FOUND, DO THE FOLLOWING...


					if ( pEnt:IsNPC() && !table.HasValue( Friends, pEnt:GetClass() ) && pEnt:GetClass() != "npc_bullseye" && pEnt:GetClass() != "npc_turret_floor" ) or ( pEnt:IsPlayer() and pEnt:Team() != self.Owner:Team() ) then	//	CHECK:	IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, **AND** THAT ENTITY IS *NOT* A FRIENDLY ( DOES NOT HAVE AN ENTRY IN THE "Friends" TABLE ), **AND** THE ENTITY IS *NOT* A SENTRY-GUN, **AND** THE ENTITY IS *NOT* A TURRET;    ** OR **    THE ENTITY BEING PROCESSED IS A *PLAYER*, **AND** THAT PLAYER IS *NOT* ON THE SAME TEAM AS THE OWNER OF THE SENTRY-GUN, THEN...


						local ang = ( pEnt:GetPos() - self:GetPos() ):Angle()	//	CALCULATE THE ANGLE


						local yaw = math.NormalizeAngle( ang.y - self:GetAngles().y );	//	CALCULATE THE YAW ( TWIST )


						local pitch = math.NormalizeAngle(ang.p)	//	CALCULATE THE PITCH


						if ( pitch <= 45 && pitch >= -45 ) && ( yaw <= 60 && yaw >= -60 ) && self:HasLOS( pEnt ) then	//	CHECK:	IF THE PITCH IS *LESS THAN OR EQUAL TO* "45" DEGREES, **AND** THE PITCH IS *GREATER THAN OR EQUAL TO* "-45" DEGREES;  ** AND **  THE YAW IS *LESS THAN OR EQUAL TO* "60" DEGREES, *AND* THE YAW IS *GREATER THAN OR EQUAL TO* "-60" DEGREES;  ** AND **  THE SENTRY-GUN HAS A "LINE OF SIGHT" TO THE ENTITY, THEN...


							self.Target = pEnt;  //  SET THE TARGET TO BE THE ENTITY CURRENTLY BEING PROCESSED


							--self.Owner:SetNetworkedBool("SentryGunTargetLocated", true)


							self.yaw = self.CurYaw	//	SET THE YAW TO EQUAL ITS CURRENT VALUE


							break	//	TERMINATE THE LOOP


						end  //  FINISH THE NESTED CHECK


					end  //  FINISH THE ENTITY CHECK


				end  //  FINISH THE LOOP


			end  //  FINISH THE CHECK


		else	//	IF TEAMS ARE *NOT ENABLED*, THEN...


			if self.Target == nil then	//	CHECK:	IF THERE IS NO TARGET, THEN...


				for i, pEnt in ipairs( ConeEnts ) do	//	FOR EACH ENTITY FOUND, DO THE FOLLOWING...


					if ( pEnt:IsNPC() && !table.HasValue( Friends, pEnt:GetClass() ) && pEnt:GetClass() != "npc_bullseye" && pEnt:GetClass() != "npc_turret_floor" ) or ( pEnt:IsPlayer() and pEnt != self.Owner ) then	//	CHECK:	IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, **AND** THAT ENTITY IS *NOT* A FRIENDLY ( DOES NOT HAVE AN ENTRY IN THE "Friends" TABLE ), **AND** THE ENTITY IS *NOT* A SENTRY-GUN, **AND** THE ENTITY IS *NOT* A TURRET;    ** OR **    THE ENTITY BEING PROCESSED IS A *PLAYER*, **AND** THAT PLAYER IS *NOT THE OWNER* OF THE SENTRY-GUN, THEN...


						local ang = ( pEnt:GetPos() - self:GetPos() ):Angle()	//	CALCULATE THE ANGLE


						local yaw = math.NormalizeAngle( ang.y - self:GetAngles().y );	//	CALCULATE THE YAW ( TWIST )


						local pitch = math.NormalizeAngle(ang.p)	//	CALCULATE THE PITCH


						if ( pitch <= 45 && pitch >= -45 ) && ( yaw <= 60 && yaw >= -60 ) && self:HasLOS( pEnt ) then	//	CHECK:	IF THE PITCH IS *LESS THAN OR EQUAL TO* "45" DEGREES, **AND** THE PITCH IS *GREATER THAN OR EQUAL TO* "-45" DEGREES;  ** AND **  THE YAW IS *LESS THAN OR EQUAL TO* "60" DEGREES, *AND* THE YAW IS *GREATER THAN OR EQUAL TO* "-60" DEGREES;  ** AND **  THE SENTRY-GUN HAS A "LINE OF SIGHT" TO THE ENTITY, THEN...


							self.Target = pEnt;  //  SET THE TARGET TO BE THE ENTITY CURRENTLY BEING PROCESSED


							--self.Owner:SetNetworkedBool("SentryGunTargetLocated", true)


							self.yaw = self.CurYaw	//	SET THE YAW TO EQUAL ITS CURRENT VALUE


							break	//	TERMINATE THE LOOP


						end  //  FINISH THE NESTED CHECK


					end  //  FINISH THE ENTITY CHECK


				end  //  FINISH THE LOOP


			end  //  FINISH THE CHECK


		end  //  FINISH CHECKING THE AVAILABILITY OF TEAMS


		if IsValid(self.Target) && !table.HasValue(ConeEnts,self.Target) then -- This is to check to see if the target does exist, but is out side of our line of site
			self:NoTarget()
		end

		if IsValid(self.Target) && self:HasLOS(self.Target) then
			--Engage Target Here
			self.ShouldSearch = true;
			local ang = ( self.Target:GetPos() - self:GetPos() ):Angle()
			local vec1 = self.Target:GetPos() - self:GetPos();
			local ang1 = math.NormalizeAngle( vec1:Angle().y - self:GetAngles().y )
			ang1 = math.Clamp( ang1 , -60, 60 )

			local diff = ang1 - self.yaw;
			--[[
			self.Owner:SetNetworkedString("SentryGunYawDebug", tostring(ang1));
			self.Owner:SetNetworkedVector("SentryGunSPosDebug", self:GetPos());
			self.Owner:SetNetworkedAngle("SentryGunSAngDebug", self:GetAngles());
			self.Owner:SetNetworkedVector("SentryGunTPosDebug", self.Target:GetPos());
			]]
			if diff > -1 && diff < 1 then
				self.TurnFactor = .05;
			else
				self.TurnFactor = 1;
			end

			if ang1 > self.yaw && ang1 < 60 then
				self.yaw = self.yaw + (self.TurnAmount * self.TurnFactor);
			elseif ang1 < self.yaw && ang1 > -60 then
				self.yaw = self.yaw - (self.TurnAmount * self.TurnFactor);
			end

			self:SetPoseParameter("aim_yaw", self.yaw )

			self.pitch = math.NormalizeAngle( vec1:Angle().p - self:GetAngles().p )
			self.pitch = math.Clamp( self.pitch , -45, 45 )

			if (self.pitch < 45 && self.pitch > -45) && ( self.yaw < 60 && self.yaw > -60 ) then
				self:SetPoseParameter("aim_pitch", self.pitch )


				if self.EngageDelay <= CurTime() then


					self:EngageTarget(self.pitch, self.yaw);


					self.EngageDelay = CurTime() + 0.1 /* 0.07 */  --  FIRE DELAY


				end


			else


				self:NoTarget()


			end
		elseif self.ShouldSearch then


			self.ShouldSearch = false;


			self:NoTarget()


		end


	end


	if self.LifeTimer <= CurTime() then


		self:Destroy();


	end


	return true;


end

function ENT:NoTarget()


	self.Target = nil;
	--self.Owner:SetNetworkedBool("SentryGunTargetLocated", false)
	self:SetPoseParameter("aim_pitch", 0 )
	self.CurYaw = self:GetPoseParameter("aim_yaw")
	self.InitialTurnDelay = CurTime() + 1;


end

function ENT:HasLOS(tar)

	local ang = (tar:GetPos() - self:GetPos() ):GetNormal()
	local barrel = self:GetAttachment(self:LookupAttachment(self.BarrelAttachment))

	--local traceRes = util.QuickTrace( self:LocalToWorld(self:OBBCenter()), ang * self.Dis, {self, self.bullseye })
	local traceRes = util.QuickTrace( barrel.Pos, ang * self.Dis, {self, self.bullseye })
		--self.Owner:SetNetworkedVector("SentryGunLOSHit", traceRes.HitPos);
	local ent = traceRes.Entity;
		--self.Owner:SetNetworkedEntity("SentryGunTracedEnt", ent);
	if ent:IsNPC() || ent:IsPlayer() then
		return true;
	end
	return false;
end

hook.Add("EntityTakeDamage","MW2KS.TurretDamage",function(ent,dmginfo)
	if ent.Turret and ent.Turret.OurHealth then
		local tur = ent.Turret
		tur.HP = tur.HP or tur.OurHealth
		tur.HP = tur.HP - dmginfo:GetDamage()
		if tur.HP < 0 then
			tur:Destroy()
		end
	end
end)


function ENT:Initialize()

	self.Owner = self.Entity:GetVar("owner")
	self:SetModel( "models/mw2_sentry/sentry_gun.mdl" );

	self.ShootMe = ents.Create("prop_physics")
	self.ShootMe.Turret = self
	self.ShootMe:SetModel("models/props_borealis/bluebarrel001.mdl")
	self.ShootMe:SetPos(self:GetPos() + self:OBBCenter());
	self.ShootMe:SetParent(self)
	self.ShootMe:Spawn()
	self.ShootMe:SetColor( Color( 255, 255, 255, 0) )
	self.ShootMe:SetRenderMode(1)
	self.ShootMe:DeleteOnRemove(self)
	self.ShootMe:SetName( "SENTRY_GUN" )	//	SET A UNIQUE NAME FOR THE "PHYSICS" ENTITY ( REQUIRED FOR THE ANTI-CHEAT )


	self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
	self:SetAngles( Angle(0, self.Owner:GetAimVector():Angle().y, 0) )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.bullseye = ents.Create("npc_bullseye");
	self.bullseye:SetPos(self:GetPos() + self:OBBCenter());

	self.bullseye:SetKeyValue("health", tostring(self.OurHealth))
	self.bullseye:SetKeyValue("spawnflags", "262144")
	self.bullseye:CallOnRemove("RemoveSentry", self.KillBullseye, self);
	self.bullseye:SetParent(self);
	self.bullseye.m_tblToolsAllowed = string.Explode( " ", "none" )
	self.bullseye:Spawn();

	self.PhysObj = self.Entity:GetPhysicsObject()
	if (self.PhysObj:IsValid()) then
		self.PhysObj:Wake()
	end
	self.Owner:DrawViewModel(false)

	constraint.NoCollide( self, self.Owner, 0, 0 );
	self:PreDeploy()

	self.FireAnim, self.FireTime = self:LookupSequence( "Fire" );
	self.LifeTimer = CurTime() + 60;

	umsg.Start("setMW2SentryGunOwner", self.Owner);
		umsg.Entity(self.Owner);
	umsg.End()
	table.insert(Sentrys,self.bullseye);
	self:SetColor( Color( 255, 255, 255 ) )



//	PREVENT USER FROM CHEATING: DO NOT ALLOW ANY PHYSICS GUN INTERACTION ( EXCEPT FOR ADMINISTRATORS )



	hook.Add( "PhysgunPickup", "Disable_Physics_Gun_Interaction", function( PLY, ENT )	//	CALL HOOK:	WHEN A USER USES THE PHYSICS GUN, RUN A PERMISSION CHECK



		if PLY:IsAdmin() == true and ENT:IsValid() == true and ENT:GetClass() == "prop_physics" and ENT:GetName() == "SENTRY_GUN" then	//	IF THE USER WHO IS USING THE PHYSICS GUN *IS* AN "ADMIN", *AND* THE SENTRY-GUN IS VALID (ALIVE), *AND* THE ENTITY BEING GRABBED *IS INDEED* A SENTRY-GUN, THEN...



			ENT:SetPersistent( false )	//	ALLOW THE ADMINISTRATOR TO PICK UP THE SENTRY-GUN



		elseif PLY:IsAdmin() == false and ENT:IsValid() == true and ENT:GetClass() == "prop_physics" and ENT:GetName() == "SENTRY_GUN" then	//	IF THE USER WHO IS USING THE PHYSICS GUN IS *NOT* AN "ADMIN", *AND* THE SENTRY-GUN IS VALID (ALIVE), *AND* THE ENTITY BEING GRABBED *IS INDEED* A SENTRY-GUN, THEN...



			ENT:SetPersistent( true )	//	DO *NOT* ALLOW THE USER TO PICK UP THE SENTRY-GUN



		end	//	CLOSE THE "IF" STATEMENT



	end ) //	CLOSE THE FUNCTION



//	PREVENT USER FROM CHEATING: DO NOT ALLOW ANY GRAVITY GUN INTERACTION ( EXCEPT FOR ADMINISTRATORS )



	hook.Add( "GravGunPickupAllowed", "Disable_Gravity_Gun_Interaction", function( PLY, ENT )	//	CALL HOOK:	WHEN A USER USES THE GRAVITY GUN, RUN A PERMISSION CHECK



		if PLY:IsAdmin() == true and ENT:IsValid() == true and ENT:GetClass() == "prop_physics" and ENT:GetName() == "SENTRY_GUN" then	//	IF THE USER WHO IS USING THE GRAVITY GUN *IS* AN "ADMIN", *AND* THE SENTRY-GUN IS VALID (ALIVE), *AND* THE ENTITY BEING GRABBED *IS INDEED* A SENTRY-GUN, THEN...



			return true		//	ALLOW THE ADMINISTRATOR TO PICK UP THE SENTRY-GUN



		elseif PLY:IsAdmin() == false and ENT:IsValid() == true and ENT:GetClass() == "prop_physics" and ENT:GetName() == "SENTRY_GUN" then	//	IF THE USER WHO IS USING THE GRAVITY GUN IS *NOT* AN "ADMIN", *AND* THE SENTRY-GUN IS VALID (ALIVE), *AND* THE ENTITY BEING GRABBED *IS INDEED* A SENTRY-GUN, THEN...



			return false	//	DO *NOT* ALLOW THE USER TO PICK UP THE SENTRY-GUN



		end	//	CLOSE THE "IF" STATEMENT



	end )	//	CLOSE THE FUNCTION


end


function ENT:KillBullseye(ent)
	ent:Destroy()
end


function ENT:EngageTarget( pitch, yaw )


	bullet				= {}
	bullet.Src			= self:GetAttachment(self:LookupAttachment(self.BarrelAttachment)).Pos;
	bullet.Attacker 	= self.Owner;
	bullet.Dir			= ( self:GetAngles() + Angle(pitch, yaw, 0) ):Forward();

	bullet.Spread		= Vector(0.01,0.01,0)
	bullet.Num			= 1
	bullet.Damage		= 10
	bullet.Force		= 5
	bullet.Tracer		= 4
	bullet.TracerName	= "AirboatGunTracer"


	self.Entity:FireBullets(bullet);


	self:StartFiring()


	self:EmitSound( "killstreak_misc/sentry_gun_firing.wav" )


end

function ENT:StartFiring()
	self:ResetSequence( self.FireAnim )
end

function ENT:Search()
	if IsValid(self.Target) then
		self.CurYaw = 0;
		--self.Owner:SetNetworkedBool("SentryGunSearching", false);
		return;
	end
	if self.InitialTurnDelay > CurTime() then return; end
	--self.Owner:SetNetworkedBool("SentryGunSearching", true);
	if self.TurnDelay <= CurTime() then
		self:SetPoseParameter("aim_yaw", self.CurYaw )
		self.CurYaw = self.CurYaw + ( 1 * self.Direction );
		self.TurnDelay = CurTime() + 0.01;
	end

	if self.CurYaw >= self.MaxYaw then
		self.Direction = -1;
	elseif self.CurYaw <= self.MinYaw then
		self.Direction = 1;
	end
end


function ENT:Destroy()
	if self.Dead then return end
	self.Dead = true;
	for k, v in pairs(Sentrys) do
		if v == self.bullseye then
			table.remove(Sentrys, k);
			break;
		end
	end
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos( self:GetPos() + ( self:GetUp() * 50 ) )
	ParticleExplode:SetKeyValue("effect_name", "smoke_burning_engine_01")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire( "kill", "", 8 )
	self:ResetSequence( self:LookupSequence( "Die" ) )
	self.FadeTimer = CurTime() + 10


	hook.Remove( "PhysgunPickup", "Disable_Physics_Gun_Interaction" )	//	REMOVE PHYSICS GUN ANTI-CHEAT


	hook.Remove( "GravGunPickupAllowed", "Disable_Gravity_Gun_Interaction" )	//	REMOVE GRAVITY GUN ANTI-CHEAT


end


function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:OnTakeDamage(dmg)
	self:TakePhysicsDamage(dmg); -- React physically when getting shot/blown

	if(self.OurHealth <= 0) then return end -- If the health-variable is already zero or below it - do nothing

	self.OurHealth = self.OurHealth - dmg:GetDamage(); -- Reduce the amount of damage took from our health-variable

	if(self.OurHealth <= 0) then -- If our health-variable is zero or below it
		//self:Destroy(); -- Remove our entity
	end
 end

function ENT:PreDeploy()
	self:ResetSequence( self:LookupSequence( "PreDeploy" ) )
end


function ENT:SetDisposition( Relationship )  //  CREATE GLOBAL FUNCTION CALLED:  "SetDisposition"	-	ACCEPT ONE PARAMETER


	local ENTITY = ents.GetAll();  //	CREATE LOCAL TABLE CALLED:	"ENTITY"  -  STORE A LIST OF EACH ENTITY FOUND IN THE SERVER


		for Key, Value in ipairs( ENTITY ) do	//	FOR EACH ENTITY FOUND IN THE SERVER, DO THE FOLLOWING...


			if Value:IsNPC() and Value:GetClass() != "npc_bullseye" and Relationship == true and !table.HasValue( Friends, Value:GetClass() ) then	//	CHECK:	IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, **AND** THAT NPC IS *NOT A SENTRY-GUN*, **AND** THE ARGUMENT PASSED TO THE FUNCTION IS "true", **AND** THE NPC IS *NOT* A FRIENDLY ( DOES NOT HAVE AN ENTRY IN THE "Friends" TABLE ), THEN...


				Value:AddEntityRelationship( self.bullseye, D_HT, 100 )  //  MAKE THE SENTRY-GUN AN *ENEMY* TO THE NPC BEING PROCESSED


			elseif Value:IsNPC() and Value:GetClass() != "npc_bullseye" and Relationship == false and !table.HasValue( Friends, Value:GetClass() ) then  //  IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, **AND** THAT NPC IS *NOT A SENTRY-GUN*, **AND** THE ARGUMENT PASSED TO THE FUNCTION IS "false", **AND** THE NPC IS *NOT* A FRIENDLY ( DOES NOT HAVE AN ENTRY IN THE "Friends" TABLE ), THEN...


				Value:AddEntityRelationship( self.bullseye, D_NU, 100 )  //  MAKE THE SENTRY-GUN A *NEUTRAL* ENTITY TO THE NPC BEING PROCESSED


			elseif Value:IsNPC() and Value:GetClass() != "npc_bullseye" and table.HasValue( Friends, Value:GetClass() ) then	//  IF THE ENTITY CURRENTLY BEING PROCESSED *IS AN NPC*, **AND** THAT NPC IS *NOT A SENTRY-GUN*, **AND** THE NPC *IS A FRIENDLY* ( DOES HAVE AN ENTRY IN THE "Friends" TABLE ), THEN...


				Value:AddEntityRelationship( self.bullseye, D_LI, 100 )  //  MAKE THE SENTRY-GUN A *FRIENDLY* ENTITY TO THE NPC BEING PROCESSED


			end  //  FINISH THE CHECK


		end  //  FINISH THE LOOP


end  //  COMPLETE THE FUNCTION
