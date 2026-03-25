AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "setMW2SentryGunOwner" )
end

local disToTurret = 50
local Friends = {
	"npc_gman", "npc_alyx", "npc_barney", "npc_citizen", "npc_vortigaunt",
	"npc_monk", "npc_dog", "npc_eli", "npc_fisherman", "npc_kleiner",
	"npc_magnusson", "npc_mossman", "npc_max_caulfield", "npc_maxine_caulfield",
	"npc_maxine_caulfield_a", "npc_maxine_caulfield_br", "npc_maxine_caulfield_dr",
	"npc_maxine_caulfield_j", "npc_maxine_caulfield_rc", "npc_maxine_caulfield_s",
	"npc_maxine_caulfield_uw", "npc_maxine_caulfield_y", "npc_maxine_caulfield_zg",
	"npc_chloe_price", "npc_chloe_price_a", "npc_chloe_price_bf",
	"npc_chloe_price_br", "npc_chloe_price_bs", "npc_chloe_price_cof",
	"npc_chloe_price_dragon", "npc_chloe_price_ep2", "npc_chloe_price_ep3",
	"npc_chloe_price_ep4", "npc_chloe_price_ep5", "npc_chloe_price_farewell",
	"npc_chloe_price_fw", "npc_chloe_price_i", "npc_chloe_price_p",
	"npc_chloe_price_rh", "npc_chloe_price_rs", "npc_chloe_price_skull",
	"npc_chloe_price_t", "npc_chloe_price_tempest", "npc_chloe_price_towel",
	"npc_chloe_price_uw", "npc_chloe_price_wr", "npc_chloe_price_y",
	"npc_princess_anna", "npc_princess_anna_2", "npc_queen_elsa",
	"npc_queen_elsa_2", "npc_gothic_elsa", "npc_companion_viper",
	"npc_german_shepherd", "npc_super_companion", "npc_elizabeth_beta_corset",
	"npc_elizabeth_lady_corset", "npc_elizabeth_noire",
	"npc_elizabeth_noire_minor_damage", "npc_elizabeth_noire_major_damage",
	"npc_elizabeth_old", "npc_elizabeth_student", "npc_elizabeth_student_beach",
	"npc_elizabeth_student_bruised", "npc_elizabeth_student_post_ambush",
	"npc_elizabeth_torture_corset", "npc_elizabeth_young",
	"npc_vj_milifri_airborne", "npc_vj_milifri_m1a1abrams",
	"npc_vj_milifri_m1a1abramsdes", "npc_vj_milifri_m1a1abramsdesg",
	"npc_vj_milifri_m1a1abramsg", "npc_vj_milifri_marine",
	"npc_vj_milifri_ranger", "npc_rf_2s25", "npc_rf_2s25_turret",
	"npc_rf_fsb", "npc_rf_russian_airb", "npc_rf_russian_gorka",
	"npc_rf_russian_marine", "npc_rf_russian_omon", "npc_rf_russian_s",
	"npc_rf_russian_spetsnaz", "npc_rf_t14", "npc_rf_t14_turret",
	"npc_rf_t90", "npc_rf_t90_turret", "npc_su_bmp2", "npc_su_bmp2_turret",
	"npc_su_bmp3", "npc_su_bmp3_turret", "npc_su_t80bv",
	"npc_su_t80bv_turret", "npc_su_t80u", "npc_su_t80u_desert",
	"npc_su_t80u_turret", "npc_su_t80u_turret_desert",
	"npc_su_t80u_turret_winter", "npc_su_t80u_winter",
	"npc_noob_saibot", "npc_rachel_amber_punk", "npc_rachel_amber",
	"npc_rachel_amber_bra", "npc_rachel_amber_ep2b", "npc_rachel_amber_injured",
	"npc_rachel_amber_tempest", "npc_jeffrey", "npc_swat",
	"npc_vaas_montenegro", "npc_green_goblin"
}
local Sentrys = {}

ENT.Placed   = false
ENT.Target   = nil
ENT.SmokeAttachment = "smoke_particle"
-- FIX: all CurTime() timer fields moved out of table-def scope (stale) -> 0
ENT.EngageDelay       = 0
ENT.AimDelay          = 0
ENT.LifeTimer         = 0
ENT.FadeTimer         = 0
ENT.TurnDelay         = 0
ENT.InitialTurnDelay  = 0
ENT.SnapToDelay       = 0
ENT.yaw               = 0
ENT.pitch             = 0
ENT.OurHealth         = 500
ENT.AutomaticFrameAdvance = true
ENT.Dead              = false
ENT.MaxYaw            = 60
ENT.MinYaw            = -60
ENT.CurYaw            = 0
ENT.Direction         = 1
ENT.TurnAmount        = 1
ENT.TurnFactor        = 1
ENT.ShouldSearch      = false

PrecacheParticleSystem( "muzzle_shotgun" )
PrecacheParticleSystem( "shotgun_muzzle_flash" )


function ENT:Think()
	self:NextThink( CurTime() )
	if self.Dead then
		if self.FadeTimer <= CurTime() then
			self:Remove()
		end
		return true
	end

	if IsValid( self.Owner ) and not self.Placed then
		self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
		self:SetAngles( Angle( 0, self.Owner:GetAimVector():Angle().y, 0 ) )
	end

	if IsValid( self.Owner ) and self.Owner:KeyDown( IN_ATTACK ) and not self.Placed then
		self.Placed = true
		self:ResetSequence( self:LookupSequence( "Deploy" ) )
		constraint.Weld( game.GetWorld(), self, 0, 0, 0, true )
		self.Owner:DrawViewModel( true )
		self.InitialTurnDelay = CurTime() + 3
		self:SetDisposition( true )
		self:SetColor( Color( 255, 255, 255 ) )
	end

	if IsValid( self.Owner ) and self.Owner:KeyDown( IN_USE ) and self.Placed
		and self:GetPos():Distance( self.Owner:GetPos() ) <= disToTurret then
		self.Placed = false
		constraint.RemoveConstraints( self, "Weld" )
		self.Owner:DrawViewModel( false )
		self:PreDeploy()
		self:SetDisposition( false )
		self:SetColor( Color( 255, 255, 255 ) )
	end

	if self.Placed then
		self:Search()

		local ConeEnts = ents.GetAll()
		local teamsOn  = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

		if self.Target == nil then
			for _, pEnt in ipairs( ConeEnts ) do
				local isEnemy = false
				if pEnt:IsNPC() and not table.HasValue( Friends, pEnt:GetClass() )
					and pEnt:GetClass() != "npc_bullseye"
					and pEnt:GetClass() != "npc_turret_floor" then
					isEnemy = true
				elseif pEnt:IsPlayer() then
					if teamsOn then
						isEnemy = pEnt:Team() != self.Owner:Team()
					else
						isEnemy = pEnt != self.Owner
					end
				end

				if isEnemy then
					local ang   = ( pEnt:GetPos() - self:GetPos() ):Angle()
					local yaw   = math.NormalizeAngle( ang.y - self:GetAngles().y )
					local pitch = math.NormalizeAngle( ang.p )
					if pitch <= 45 and pitch >= -45 and yaw <= 60 and yaw >= -60
						and self:HasLOS( pEnt ) then
						self.Target = pEnt
						self.yaw    = self.CurYaw
						break
					end
				end
			end
		end

		if IsValid( self.Target ) and not table.HasValue( ConeEnts, self.Target ) then
			self:NoTarget()
		end

		if IsValid( self.Target ) and self:HasLOS( self.Target ) then
			self.ShouldSearch = true
			local vec1 = self.Target:GetPos() - self:GetPos()
			local ang1 = math.NormalizeAngle( vec1:Angle().y - self:GetAngles().y )
			ang1 = math.Clamp( ang1, -60, 60 )
			local diff = ang1 - self.yaw
			self.TurnFactor = ( diff > -1 and diff < 1 ) and 0.05 or 1

			if ang1 > self.yaw and ang1 < 60 then
				self.yaw = self.yaw + ( self.TurnAmount * self.TurnFactor )
			elseif ang1 < self.yaw and ang1 > -60 then
				self.yaw = self.yaw - ( self.TurnAmount * self.TurnFactor )
			end
			self:SetPoseParameter( "aim_yaw", self.yaw )

			self.pitch = math.NormalizeAngle( vec1:Angle().p - self:GetAngles().p )
			self.pitch = math.Clamp( self.pitch, -45, 45 )

			if self.pitch < 45 and self.pitch > -45 and self.yaw < 60 and self.yaw > -60 then
				self:SetPoseParameter( "aim_pitch", self.pitch )
				if self.EngageDelay <= CurTime() then
					self:EngageTarget( self.pitch, self.yaw )
					self.EngageDelay = CurTime() + 0.1
				end
			else
				self:NoTarget()
			end
		elseif self.ShouldSearch then
			self.ShouldSearch = false
			self:NoTarget()
		end
	end

	if self.LifeTimer <= CurTime() then
		self:Destroy()
	end
	return true
end


function ENT:NoTarget()
	self.Target = nil
	self:SetPoseParameter( "aim_pitch", 0 )
	self.CurYaw = self:GetPoseParameter( "aim_yaw" )
	self.InitialTurnDelay = CurTime() + 1
end


function ENT:HasLOS( tar )
	local ang    = ( tar:GetPos() - self:GetPos() ):GetNormal()
	local barrel = self:GetAttachment( self:LookupAttachment( self.BarrelAttachment ) )
	local traceRes = util.QuickTrace( barrel.Pos, ang * self.Dis, { self, self.bullseye } )
	local ent = traceRes.Entity
	return ent:IsNPC() or ent:IsPlayer()
end


hook.Add( "EntityTakeDamage", "MW2KS.TurretDamage", function( ent, dmginfo )
	if ent.Turret and ent.Turret.OurHealth then
		local tur = ent.Turret
		tur.HP = tur.HP or tur.OurHealth
		tur.HP = tur.HP - dmginfo:GetDamage()
		if tur.HP < 0 then
			tur:Destroy()
		end
	end
end )


function ENT:Initialize()
	-- FIX: self.Owner = self.Entity:GetVar('owner') - dead API -> removed
	self:SetModel( "models/mw2_sentry/sentry_gun.mdl" )

	self.ShootMe = ents.Create( "prop_physics" )
	self.ShootMe.Turret = self
	self.ShootMe:SetModel( "models/props_borealis/bluebarrel001.mdl" )
	self.ShootMe:SetPos( self:GetPos() + self:OBBCenter() )
	self.ShootMe:SetParent( self )
	self.ShootMe:Spawn()
	self.ShootMe:SetColor( Color( 255, 255, 255, 0 ) )
	self.ShootMe:SetRenderMode( 1 )
	self.ShootMe:DeleteOnRemove( self )
	self.ShootMe:SetName( "SENTRY_GUN" )

	self:SetPos( self.Owner:GetPos() + ( self.Owner:GetForward() * 50 ) )
	self:SetAngles( Angle( 0, self.Owner:GetAimVector():Angle().y, 0 ) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.bullseye = ents.Create( "npc_bullseye" )
	self.bullseye:SetPos( self:GetPos() + self:OBBCenter() )
	self.bullseye:SetKeyValue( "health", tostring( self.OurHealth ) )
	self.bullseye:SetKeyValue( "spawnflags", "262144" )
	self.bullseye:CallOnRemove( "RemoveSentry", self.KillBullseye, self )
	self.bullseye:SetParent( self )
	self.bullseye.m_tblToolsAllowed = string.Explode( " ", "none" )
	self.bullseye:Spawn()

	-- FIX: self.Entity:GetPhysicsObject() -> self:GetPhysicsObject()
	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	self.Owner:DrawViewModel( false )
	constraint.NoCollide( self, self.Owner, 0, 0 )
	self:PreDeploy()

	self.FireAnim, self.FireTime = self:LookupSequence( "Fire" )
	-- FIX: LifeTimer/FadeTimer/etc assigned at actual spawn time
	self.LifeTimer = CurTime() + 60

	-- FIX: umsg.Start/End removed from GMod -> net library
	net.Start( "setMW2SentryGunOwner" )
	net.WriteEntity( self.Owner )
	net.Send( self.Owner )

	table.insert( Sentrys, self.bullseye )
	self:SetColor( Color( 255, 255, 255 ) )

	hook.Add( "PhysgunPickup", "Disable_Physics_Gun_Interaction", function( PLY, ENT )
		if ENT:IsValid() and ENT:GetClass() == "prop_physics" and ENT:GetName() == "SENTRY_GUN" then
			if PLY:IsAdmin() then
				ENT:SetPersistent( false )
			else
				ENT:SetPersistent( true )
			end
		end
	end )

	hook.Add( "GravGunPickupAllowed", "Disable_Gravity_Gun_Interaction", function( PLY, ENT )
		if ENT:IsValid() and ENT:GetClass() == "prop_physics" and ENT:GetName() == "SENTRY_GUN" then
			return PLY:IsAdmin()
		end
	end )
end


function ENT:KillBullseye( ent )
	ent:Destroy()
end


function ENT:EngageTarget( pitch, yaw )
	-- FIX: bullet was global (missing local keyword)
	local bullet = {}
	bullet.Src       = self:GetAttachment( self:LookupAttachment( self.BarrelAttachment ) ).Pos
	bullet.Attacker  = self.Owner
	bullet.Dir       = ( self:GetAngles() + Angle( pitch, yaw, 0 ) ):Forward()
	bullet.Spread    = Vector( 0.01, 0.01, 0 )
	bullet.Num       = 1
	bullet.Damage    = 10
	bullet.Force     = 5
	bullet.Tracer    = 4
	bullet.TracerName = "AirboatGunTracer"
	-- FIX: self.Entity:FireBullets -> self:FireBullets
	self:FireBullets( bullet )
	self:StartFiring()
	self:EmitSound( "killstreak_misc/sentry_gun_firing.wav" )
end


function ENT:StartFiring()
	self:ResetSequence( self.FireAnim )
end


function ENT:Search()
	if IsValid( self.Target ) then
		self.CurYaw = 0
		return
	end
	if self.InitialTurnDelay > CurTime() then return end
	if self.TurnDelay <= CurTime() then
		self:SetPoseParameter( "aim_yaw", self.CurYaw )
		self.CurYaw = self.CurYaw + ( 1 * self.Direction )
		self.TurnDelay = CurTime() + 0.01
	end
	if self.CurYaw >= self.MaxYaw then
		self.Direction = -1
	elseif self.CurYaw <= self.MinYaw then
		self.Direction = 1
	end
end


function ENT:Destroy()
	if self.Dead then return end
	self.Dead = true
	for k, v in pairs( Sentrys ) do
		if v == self.bullseye then
			table.remove( Sentrys, k )
			break
		end
	end
	local p = ents.Create( "info_particle_system" )
	p:SetPos( self:GetPos() + ( self:GetUp() * 50 ) )
	p:SetKeyValue( "effect_name", "smoke_burning_engine_01" )
	p:SetKeyValue( "start_active", "1" )
	p:Spawn()
	p:Activate()
	p:Fire( "kill", "", 8 )
	self:ResetSequence( self:LookupSequence( "Die" ) )
	self.FadeTimer = CurTime() + 10
	hook.Remove( "PhysgunPickup", "Disable_Physics_Gun_Interaction" )
	hook.Remove( "GravGunPickupAllowed", "Disable_Gravity_Gun_Interaction" )
end


function ENT:GetTeam()
	return self.Owner:Team()
end


function ENT:OnTakeDamage( dmg )
	self:TakePhysicsDamage( dmg )
	if self.OurHealth <= 0 then return end
	self.OurHealth = self.OurHealth - dmg:GetDamage()
	if self.OurHealth <= 0 then
		self:Destroy()
	end
end


function ENT:PreDeploy()
	self:ResetSequence( self:LookupSequence( "PreDeploy" ) )
end


function ENT:SetDisposition( Relationship )
	for _, Value in ipairs( ents.GetAll() ) do
		if Value:IsNPC() and Value:GetClass() != "npc_bullseye"
			and not table.HasValue( Friends, Value:GetClass() ) then
			if Relationship then
				Value:AddEntityRelationship( self.bullseye, D_HT, 100 )
			else
				Value:AddEntityRelationship( self.bullseye, D_NU, 100 )
			end
		elseif Value:IsNPC() and Value:GetClass() != "npc_bullseye"
			and table.HasValue( Friends, Value:GetClass() ) then
			Value:AddEntityRelationship( self.bullseye, D_LI, 100 )
		end
	end
end
