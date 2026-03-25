AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "MW2_HARRIER_FRIENDLY" )
	util.AddNetworkString( "MW2_HARRIER_ENEMY" )
end

local bulletSound      = Sound( "killstreak_rewards/harrier_shoot.wav" )
local hoveringSound    = Sound( "killstreak_rewards/harrier_hover.wav" )
local hoverSoundDuration = SoundDuration( hoveringSound )

local backLeftWing  = Model( "models/military2/air/gibs/backleftwing.mdl" )
local backRightWing = Model( "models/military2/air/gibs/backrightwing.mdl" )
local cockPit       = Model( "models/military2/air/gibs/cockpit.mdl" )
local leftWing      = Model( "models/military2/air/gibs/leftwing.mdl" )
local middle        = Model( "models/military2/air/gibs/middle.mdl" )
local rightWing     = Model( "models/military2/air/gibs/rightwing.mdl" )

ENT.radius         = 2000
ENT.radi           = 20
ENT.shootPos       = Vector( 153, 3, -13 )
ENT.sky            = 0
ENT.distance       = 0
ENT.hoverPos       = NULL
ENT.hoverMode      = false
ENT.flyTo          = true
ENT.startTimer     = true
ENT.curTarget      = nil
-- FIX: all CurTime() fields at table-def scope (stale) -> 0
ENT.shootDelay     = 0
ENT.setPos         = true
ENT.curPos         = NULL
ENT.curAng         = NULL
ENT.turnDelay      = 0
ENT.keepPlaying    = false
ENT.alreadyBlownUp = false
ENT.retireDelay    = 0
ENT.retireOnce     = false
ENT.friendlys = {
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
ENT.targets        = NULL
ENT.SoundTime      = 0
ENT.movementDelay  = 0
ENT.startAngle     = 180
ENT.turnFactor     = 1
ENT.turnAmount     = 45
ENT.turned         = 0
ENT.newAngle       = 0
ENT.direction      = math.random( 0, 1 )
ENT.moveTime       = 0
ENT.StartMove      = false
ENT.AllowMove      = true


function ENT:PhysicsUpdate()
	-- FIX: self.Entity:GetPos/GetForward/SetPos/IsInWorld -> self:XXX
	self.distance = math.Dist( self:GetPos().x, self:GetPos().y, self.hoverPos.x, self.hoverPos.y )
	self:SetAngles( self.curAng )

	if not self:FindHoverZone() and self.flyTo then
		self.PhysObj:SetVelocity( self:GetForward() * self.distance )
		self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.sky ) )

	elseif self:FindHoverZone() and self.flyTo then
		self.hoverMode = true
		self.flyTo     = false

	elseif self.hoverMode then
		self.PhysObj:SetVelocity( Vector( 0, 0, 0 ) )
		if self.setPos then
			self.curPos = self:GetPos()
			self.setPos = false
		end

		if self.startTimer then
			self.retireDelay = CurTime() + 60
			self.retireOnce  = true
			self.startTimer  = false
		end

		if self.curTarget != nil and self.curTarget:IsValid() and self.shootDelay <= CurTime() then
			self.StartMove  = false
			self.shootDelay = CurTime() + 0.2
			self:EngageEnemy()

		elseif ( self.curTarget == nil or not self.curTarget:IsValid() ) and self.shootDelay <= CurTime() then
			self.curTarget = nil
			if not self.StartMove then
				self.StartMove    = true
				self.movementDelay = CurTime() + 8
			end
			self.shootDelay = CurTime() + 0.01
			self:FindEnemys()
		end

		if self.StartMove and self.AllowMove then
			self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.sky ) )
			self:SetAngles( Angle( 0, self.startAngle + self.newAngle, 0 ) )
			if self.movementDelay < CurTime() and math.abs( self.turned ) < self.turnAmount * self.turnFactor then
				-- FIX: direction (undefined global) -> self.direction
				if self.direction == 0 then
					self.turned   = self.turned + 1
					self.newAngle = self.newAngle + 1
				else
					self.turned   = self.turned - 1
					self.newAngle = self.newAngle - 1
				end
			elseif self.movementDelay < CurTime() and math.abs( self.turned ) >= self.turnAmount * self.turnFactor then
				self.turned        = 0
				self.movementDelay = CurTime() + 8
				self.moveTime      = CurTime() + 0.5
				self.direction     = math.random( 0, 1 )
				self.turnFactor    = math.random( 1, 6 )
			elseif self.moveTime > CurTime() then
				self.PhysObj:SetVelocity( self:GetForward() * 600 )
			end
		else
			self:SetPos( self.curPos )
		end

	elseif not self.flyTo and not self.hoverMode then
		self.PhysObj:SetVelocity( self:GetForward() * ( self.distance + 50 ) )
	end

	if not self:IsInWorld() then self:Remove() end

	if self.SoundTime <= CurTime() and self.keepPlaying then
		self:StartHoverSound()
		self.SoundTime = hoverSoundDuration + CurTime()
	end

	if self.retireOnce and self.retireDelay <= CurTime() and self.curTarget == nil then
		self.retireOnce = false
		self:HarrierLeave()
	end
end


function ENT:Initialize()
	self.hoverMode  = false
	self.flyTo      = true
	self.startTimer = true
	self.retireOnce = false
	self.curTarget  = nil
	self.setPos     = true
	-- FIX: self.Owner = self.Entity:GetVar('owner') - dead API -> removed
	-- FIX: self.hoverPos = self:GetVar('HarrierHoverZone') - dead API -> set by weapon
	-- FIX: self.spawnPos = self.Owner:GetNetworkedVector -> GetNWVector
	self.spawnPos = self.Owner:GetNWVector( "Harrier_Spawn_Pos" )
	self.sky      = self.spawnPos.z
	self.hoverPos = Vector( self.hoverPos.x, self.hoverPos.y, self.sky )

	-- FIX: assign stale timer fields at spawn time
	self.shootDelay    = CurTime()
	self.turnDelay     = CurTime()
	self.retireDelay   = CurTime()
	self.movementDelay = CurTime() + 8
	self.SoundTime     = CurTime()
	self.moveTime      = CurTime()

	-- FIX: self.Entity:SetModel/SetColor/SetPos/SetAngles/PhysicsInit/SetMoveType/SetSolid
	--      /GetPhysicsObject -> self:XXX
	self:SetModel( "models/harrier.mdl" )
	self:SetColor( Color( 255, 255, 255 ) )
	self:SetPos( self.spawnPos )
	self.curAng = Angle( 0, self.startAngle, 0 )
	self:SetAngles( self.curAng )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:EnableGravity( false )
		self.PhysObj:Wake()
	end

	self.PhysgunDisabled = true
	constraint.NoCollide( self, game.GetWorld(), 0, 0 )
	self.keepPlaying   = true
	self.alreadyBlownUp = false

	self:CALL_HARRIER()
end


function ENT:CALL_HARRIER()
	-- FIX: umsg.Start/End -> net library
	local Players = player.GetHumans()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	for _, Value in pairs( Players ) do
		local isFriendly
		if teamsOn then
			isFriendly = Value:Team() == self.Owner:Team()
		else
			isFriendly = Value == self.Owner
		end
		if isFriendly then
			net.Start( "MW2_HARRIER_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_HARRIER_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:FindHoverZone()
	-- FIX: self.Entity:GetPos -> self:GetPos
	local jetPos = self:GetPos()
	self.distanceToTarget = jetPos - self.hoverPos
	return math.abs( self.distanceToTarget.x ) <= self.radi
		and math.abs( self.distanceToTarget.y ) <= self.radi
end


function ENT:FindEnemys()
	-- FIX: minVec/maxVec/enemys were global -> local
	self.groundV2 = -16384
	local minVec = self:GetPos() - Vector( self.radius, self.radius, 0 )
	minVec = Vector( minVec.x, minVec.y, self.groundV2 )
	local maxVec = self:GetPos() + Vector( self.radius, self.radius, 0 )
	self.targets = ents.FindInBox( minVec, maxVec )
	local enemys = {}
	for _, v in pairs( self.targets ) do
		if self:FilterEnemy( v ) then table.insert( enemys, v ) end
	end
	self.curTarget = table.Count( enemys ) >= 1 and table.Random( enemys ) or nil
end


function ENT:FilterEnemy( Value )
	if not Value:IsValid() then return false end
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0
	local isEnemy = false
	if Value:IsNPC() and checkForStriders( Value ) then
		isEnemy = true
	elseif Value:IsPlayer() then
		isEnemy = teamsOn and ( Value:Team() != self.Owner:Team() ) or ( Value != self.Owner )
	end
	if not isEnemy then return false end
	if not table.HasValue( self.friendlys, Value:GetClass() )
		and Value:GetClass() != "npc_bullseye"
		and Value:GetClass() != "npc_turret_floor" then
		return self:traceHitEnemy( Value )
	end
	return false
end


function checkForStriders( v )
	if v:GetClass() == "npc_strider" then return false end
	local tab = string.Explode( "_", v:GetClass() )
	return not table.HasValue( tab, "strider" )
end


function ENT:EngageEnemy()
	if self.curTarget:IsValid() and self:traceHitEnemy( self.curTarget ) then
		local entityCenter = Vector( 0, 0, self.curTarget:OBBMaxs().z )
		local pos    = self.curTarget:GetPos() - ( self.curTarget:OBBCenter() - entityCenter )
		local dist   = ( self:GetPos() + self.shootPos ) - pos
		local target = dist:GetNormal() * -1
		-- FIX: bullet global -> local; self.Entity:FireBullets -> self:FireBullets
		local bullet = {}
		bullet.Src        = self:GetPos() + self.shootPos
		bullet.Attacker   = self.Owner
		bullet.Dir        = target
		bullet.Spread     = Vector( 0.01, 0.01, 0 )
		bullet.Num        = 1
		bullet.Damage     = 20
		bullet.Force      = 5
		bullet.Tracer     = 1
		bullet.TracerName = "HelicopterTracer"
		self:FireBullets( bullet )
		self:EmitSound( bulletSound, 140, 100 )
	end
end


function ENT:GetTeam()
	return self.Owner:Team()
end


function ENT:traceHitEnemy( enemy )
	local trace = {
		start  = self:GetPos(),
		endpos = enemy:GetPos(),
		filter = self
	}
	local traceData = util.TraceLine( trace )
	return not traceData.HitWorld
end


function ENT:HarrierLeave()
	self.hoverMode  = false
	self.keepPlaying = false
	self:StopSound( "Harrier_Hover" )
	self:EmitSound( "killstreak_rewards/harrier_leave.wav", 100 )
end


function ENT:StartHoverSound()
	self:EmitSound( "Harrier_Hover" )
end


function ENT:OnTakeDamage( dmg )
	if dmg:IsExplosionDamage() then self:Destroy() end
end


function ENT:Destroy()
	self:BlowUpJet()
end


function ENT:BlowUpJet()
	if self.alreadyBlownUp then return end
	self.alreadyBlownUp = true

	local expl = ents.Create( "env_explosion" )
	expl:SetKeyValue( "spawnflags", 128 )
	expl:SetPos( self:GetPos() )
	expl:Spawn()
	expl:Fire( "explode", "", 0 )

	local FireExp = ents.Create( "env_physexplosion" )
	FireExp:SetPos( self:GetPos() )
	FireExp:SetParent( self )
	FireExp:SetKeyValue( "magnitude", 500 )
	FireExp:SetKeyValue( "radius",    500 )
	FireExp:SetKeyValue( "spawnflags", "1" )
	FireExp:Spawn()
	FireExp:Fire( "Explode", "", 0 )
	FireExp:Fire( "kill",    "", 5 )
	util.BlastDamage( self, self, self:GetPos(), 500, 500 )

	local effectdata = EffectData()
	effectdata:SetStart(  self:GetPos() )
	effectdata:SetOrigin( self:GetPos() )
	effectdata:SetScale( 1 )

	local ParticleExplode = ents.Create( "info_particle_system" )
	ParticleExplode:SetPos( self:GetPos() )
	ParticleExplode:SetKeyValue( "effect_name",  "harrier_explode" )
	ParticleExplode:SetKeyValue( "start_active", "1" )
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire( "kill", "", 20 )

	util.Effect( "Explosion",            effectdata )
	util.Effect( "HelicopterMegaBomb",   effectdata )
	util.Effect( "cball_explode",        effectdata )

	self:SetColor( Color( 0, 0, 0, 255 ) )

	local gibModels = { backLeftWing, backRightWing, cockPit, leftWing, middle, rightWing }
	for _, mdl in ipairs( gibModels ) do
		local gib = ents.Create( "prop_physics" )
		gib:SetModel( mdl )
		gib:SetColor( Color( 150, 150, 150, 255 ) )
		gib:SetPos( self:GetPos() )
		gib:SetAngles( self:GetAngles() )
		gib:Spawn()
		gib:GetPhysicsObject():SetVelocity( self:GetVelocity() )
		gib:Fire( "kill", "", 15 )
	end

	local ed2 = EffectData()
	ed2:SetOrigin( self:GetPos() )
	ed2:SetStart(  Vector( 0, 0, 90 ) )
	util.Effect( "jetdestruction_explosion", ed2 )

	self:StopSound( "Harrier_Hover" )
	self:Remove()
end
