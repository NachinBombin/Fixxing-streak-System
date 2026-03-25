include( "shared.lua" )
AddCSLuaFile( "shared.lua" )

if SERVER then
	util.AddNetworkString( "MW2_AC130_Kill_Sounds" )
end

ENT.ExplosionSound = Sound( "killstreak_explosions/105_explosion.wav" )


function ENT:PhysicsUpdate()
	-- FIX: self.Entity:GetForward -> self:GetForward
	self.PhysObj:SetVelocity( self:GetForward() * 3500 )
end


function ENT:Initialize()
	-- FIX: self.Entity:SetModel/PhysicsInit/SetMoveType/SetSolid -> self:XXX
	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed; set by weapon base
	self:SetModel( "models/military2/bomb/bomb_gbu10.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- FIX: self.Entity:GetPhysicsObject -> self:GetPhysicsObject
	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	for _, v in pairs( player.GetAll() ) do
		sound.Play( "ac-130_kill_sounds/105mminair.wav", v:GetPos(), 180, 100, 1 )
	end
end


function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:Explosion()
	end
end


function ENT:OnTakeDamage( dmginfo )
	-- FIX: self.Entity:TakePhysicsDamage -> self:TakePhysicsDamage
	self:TakePhysicsDamage( dmginfo )
end


function ENT:Explosion()
	local blastRadius = 1000
	local targets = ents.FindInSphere( self:GetPos(), blastRadius )

	util.BlastDamage( self, self.Owner, self:GetPos(), blastRadius, blastRadius )
	self:EmitSound( self.ExplosionSound, 400, 100 )

	timer.Simple( 0.5, function()
		if IsValid( self ) then
			self:CountDeadBodys( targets )
			self:Remove()
		end
	end )

	-- FIX: ParticleExplode was global -> local
	local ParticleExplode = ents.Create( "info_particle_system" )
	ParticleExplode:SetPos( self:GetPos() )
	ParticleExplode:SetKeyValue( "effect_name",  "agm_explode" )
	ParticleExplode:SetKeyValue( "start_active", "1" )
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire( "kill", "", 20 )

	local en = ents.FindInSphere( self:GetPos(), 500 )
	for _, v in pairs( en ) do
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

	-- FIX: self.Entity:GetPos -> self:GetPos
	util.ScreenShake( self:GetPos(), 100, 100, 1, 2000 )
	self:SetColor( Color( 255, 255, 255, 0 ) )
	self:GetPhysicsObject():EnableCollisions( false )
end


function ENT:CountDeadBodys( bodys )
	local deadBodys = -1
	for _, v in pairs( bodys or {} ) do
		if not IsValid( v ) then
			deadBodys = deadBodys + 1
		end
	end
	-- FIX: umsg.Start/End -> net library
	if IsValid( self.Owner ) then
		net.Start( "MW2_AC130_Kill_Sounds" )
		net.WriteInt( deadBodys, 32 )
		net.Send( self.Owner )
	end
end
