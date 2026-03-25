AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "MW2_PREDATOR_FRIENDLY" )
	util.AddNetworkString( "MW2_PREDATOR_ENEMY" )
	util.AddNetworkString( "Predator_missile_SetUpHUD" )
	util.AddNetworkString( "Predator_missile_RemoveHUD" )
end

ENT.Model           = "models/military2/bomb/bomb_cbu.mdl"
ENT.moveFactor      = 0.5
ENT.speedFactor     = 1
ENT.speedBoost      = true
ENT.keepPlaying     = false
ENT.playerAng       = NULL
ENT.playerWeapons   = {}
ENT.Sky             = 0
ENT.ang             = nil
-- FIX: was set to CurTime() at table-def (file-load) time, stale by spawn. Moved to MW2_Init.
ENT.turnDelay       = 0
ENT.playerSpeeds    = {}
ENT.MissileSpeed    = 0
ENT.restrictMovement = true
-- FIX: was a file-scope local shared across all instances. Now instance variable.
ENT.PlayerAlive     = 0

local missileThrustSound    = Sound( "killstreak_rewards/predator_missile_thruster.wav" )
local missileBoostSound     = Sound( "killstreak_rewards/predator_missile_boost.wav" )
local missileExplosionSound = Sound( "killstreak_rewards/predator_missile_explosion.wav" )


local function ResetOwner( self )
	if not IsValid( self.Owner ) then return end
	self.Owner:SetViewEntity( self.Owner )
	self.Owner:ExitVehicle()
	self.Owner:SetAngles( self.playerAng )
	-- FIX: GAMEMODE:SetPlayerSpeed is DarkRP-only
	self.Owner:SetWalkSpeed( self.playerSpeeds[1] or 200 )
	self.Owner:SetRunSpeed( self.playerSpeeds[2] or 400 )
	self.Owner:SetMoveType( MOVETYPE_WALK )
	-- FIX: umsg -> net
	net.Start( "Predator_missile_RemoveHUD" )
	net.Send( self.Owner )
	hook.Remove( "Move", "RESTRICT_MOVEMENT" )
	self.restrictMovement = false
end


function ENT:PhysicsUpdate()
	-- FIX: self.Entity.Owner:KeyDown crash - guard owner validity first
	if not IsValid( self.Owner ) then return end

	self.PhysObj:SetVelocity( ( self:GetForward() * self.MissileSpeed ) * self.speedFactor )
	self.ang = self:GetAngles()

	if self.Owner:KeyDown( IN_FORWARD ) and self.PlayerAlive == 1 then
		if self.ang.p > 30 then
			self.ang = Angle( self.ang.p - self.moveFactor, self.ang.y, self.ang.r )
		end
	elseif self.Owner:KeyDown( IN_BACK ) and self.PlayerAlive == 1 then
		if self.ang.p < 89 then
			self.ang = Angle( self.ang.p + self.moveFactor, self.ang.y, self.ang.r )
		end
	end

	if self.Owner:KeyDown( IN_MOVERIGHT ) and self.PlayerAlive == 1 then
		self.ang = Angle( self.ang.p, self.ang.y - self.moveFactor, self.ang.r )
	elseif self.Owner:KeyDown( IN_MOVELEFT ) and self.PlayerAlive == 1 then
		self.ang = Angle( self.ang.p, self.ang.y + self.moveFactor, self.ang.r )
	end
	self:SetAngles( self.ang )

	if self.Owner:KeyDown( IN_ATTACK ) and self.PlayerAlive == 1 and self.speedBoost then
		self.speedFactor = 2
		self.speedBoost  = false
		self:EmitSound( missileBoostSound, 40 )
		self:SetNWBool( "Boosted", true )
	end

	if self.Trail and self.Trail:IsValid() and self.PlayerAlive == 1 then
		self.Trail:SetPos( self:GetPos() - 16 * self:GetForward() )
		self.Trail:SetLocalAngles( Angle( 0, 0, 0 ) )
	else
		self:SpawnTrail()
	end

	if ( self.NextThrustSound or 0 ) <= CurTime() then
		self.NextThrustSound = CurTime() + 5
		self:EmitSound( missileThrustSound )
	end

	if self.Owner:Alive() == false then
		ResetOwner( self )
		self.PlayerAlive = 0
	end
end


function ENT:Think()
	if not IsValid( self.PhysObj ) or not self.PhysObj:IsValid() then
		self:Remove()
		return
	end
	if self.PhysObj:IsAsleep() then
		self.PhysObj:Wake()
	end
end


function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:PredatorExplosion()
		ResetOwner( self )
		if IsValid( self.Wep ) then
			self.Wep:CallIn()
		end
	end
end


function ENT:PredatorExplosion()
	util.BlastDamage( self, self.Owner, self:GetPos(), 700, 700 )

	local ParticleExplode = ents.Create( "info_particle_system" )
	ParticleExplode:SetPos( self:GetPos() )
	ParticleExplode:SetKeyValue( "effect_name", "agm_explode" )
	ParticleExplode:SetKeyValue( "start_active", "1" )
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire( "kill", "", 20 )

	local shake = ents.Create( "env_shake" )
	shake:SetOwner( self )
	shake:SetPos( self:GetPos() )
	shake:SetKeyValue( "amplitude",  "2000" )
	shake:SetKeyValue( "radius",     "1250" )
	shake:SetKeyValue( "duration",   "2.5" )
	shake:SetKeyValue( "frequency",  "255" )
	shake:SetKeyValue( "spawnflags", "4" )
	shake:Spawn()
	shake:Activate()
	shake:Fire( "StartShake", "", 0 )

	self:StopThrustSound()
	self:EmitSound( missileExplosionSound, 100 )
	self:SetNWBool( "Exploded", true )
	self:SetColor( Color( 255, 255, 255, 0 ) )
	self:SetRenderMode( 1 )
	self:GetPhysicsObject():EnableMotion( false )
	self:GetPhysicsObject():EnableCollisions( false )

	local en = ents.FindInSphere( self:GetPos(), 500 )
	for k, v in pairs( en ) do
		local phys = v:GetPhysicsObject()
		if phys:IsValid() then
			v:Fire( "enablemotion", "", 0 )
			constraint.RemoveAll( v )
			phys:ApplyForceCenter( ( v:GetPos() - self:GetPos() ):GetNormal() * phys:GetMass() * 1500 )
		end
		if v:GetClass() == "npc_strider" then
			v:Fire( "Break", "", 0 )
		end
	end

	timer.Simple( 1, function()
		if IsValid( self ) then
			hook.Remove( "Move", "RESTRICT_MOVEMENT" )
			if IsValid( self.Owner ) then
				self.Owner:SetMoveType( MOVETYPE_WALK )
			end
			self.restrictMovement = false
			self:Remove()
		end
	end )
end


function ENT:LAUNCH_MISSILE()
	-- FIX: umsg.Start/End removed from GMod. Replaced with net library.
	-- FIX: self.Owner is now valid here (no longer re-assigned after this call)
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
			net.Start( "MW2_PREDATOR_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_PREDATOR_ENEMY" )
			net.Send( Value )
		end
	end
end


local function RESTRICT_OWNER_MOVEMENT( PLY, DATA )
	PLY:SetMoveType( MOVETYPE_NONE )
	PLY.restrictMovement = true
end


function ENT:MW2_Init()
	self.turnDelay = CurTime()  -- FIX: set at actual spawn time
	self.Sky = self.Sky - 100

	local lplPos    = self.Owner:GetPos()
	local skyVector = Vector( lplPos.x, lplPos.y, self.Sky )

	if self.Owner:Alive() then
		self.PlayerAlive = 1
	end

	-- FIX: self.Entity:SetPos/SetAngles -> self:SetPos/SetAngles
	self:SetPos( skyVector )
	self:SetAngles( Angle( 75, self.Owner:EyeAngles().y, 0 ) )

	self.playerAng   = self.Owner:GetAngles()
	self.playerSpeeds = { self.Owner:GetWalkSpeed(), self.Owner:GetRunSpeed() }

	self.Owner:SetViewEntity( self )
	-- FIX: umsg -> net
	net.Start( "Predator_missile_SetUpHUD" )
	net.Send( self.Owner )

	self.keepPlaying = true
	self.MissileSpeed = math.Clamp(
		Vector( 0, 0, self.Sky ):Distance( Vector( 0, 0, self:findGround() ) ),
		0, 2000
	)

	-- FIX: removed self.Owner = self:GetVar('owner') which was re-assigning
	-- AFTER LAUNCH_MISSILE() was called, meaning LAUNCH_MISSILE saw a stale
	-- owner and crashed on :Team(). Owner is already set by weapon base.

	hook.Add( "Move", "RESTRICT_MOVEMENT", function( PLY, DATA )
		if PLY == self.Owner then
			RESTRICT_OWNER_MOVEMENT( PLY, DATA )
		end
	end )

	self:LAUNCH_MISSILE()
end


function ENT:OnTakeDamage( dmginfo )
	-- FIX: self.Entity:TakePhysicsDamage -> self:TakePhysicsDamage
	self:TakePhysicsDamage( dmginfo )
end


function ENT:SpawnTrail()
	-- FIX: self.Entity:XXX -> self:XXX
	self.Trail = ents.Create( "env_rockettrail" )
	self.Trail:SetPos( self:GetPos() - 16 * self:GetForward() )
	self.Trail:SetParent( self )
	self.Trail:SetLocalAngles( Angle( 0, 0, 0 ) )
	self.Trail:Spawn()
end


function ENT:StartThrustSound()
	self:EmitSound( missileThrustSound )
end

function ENT:StopThrustSound()
	self.keepPlaying = false
end
