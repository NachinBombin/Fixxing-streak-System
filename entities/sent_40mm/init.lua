include( "shared.lua" )
AddCSLuaFile( "shared.lua" )

ENT.ExplosionSound = Sound( "killstreak_explosions/40_explosion.wav" )


function ENT:PhysicsUpdate()
	-- FIX: self.Entity:GetForward -> self:GetForward
	self.PhysObj:SetVelocity( self:GetForward() * 5500 )
end


function ENT:Initialize()
	-- FIX: self.Entity:SetModel/PhysicsInit/SetMoveType/SetSolid -> self:XXX
	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed
	self:SetModel( "models/military2/missile/missile_s300.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- FIX: self.Entity:GetPhysicsObject -> self:GetPhysicsObject
	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	timer.Simple( 0.5, function()
		for _, v in pairs( player.GetAll() ) do
			sound.Play( "ac-130_kill_sounds/40mminair.wav", v:GetPos(), 180, 100, 1 )
		end
	end )
end


function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:Explosion()
		self:Remove()
	end
end


function ENT:OnTakeDamage( dmginfo )
	-- FIX: self.Entity:TakePhysicsDamage -> self:TakePhysicsDamage
	self:TakePhysicsDamage( dmginfo )
end


function ENT:Explosion()
	util.BlastDamage( self, self.Owner, self:GetPos(), 250, 250 )
	self:EmitSound( self.ExplosionSound, 200, 100 )

	-- FIX: ParticleExplode was global -> local
	local ParticleExplode = ents.Create( "info_particle_system" )
	ParticleExplode:SetPos( self:GetPos() )
	ParticleExplode:SetKeyValue( "effect_name",  "40mm_explode" )
	ParticleExplode:SetKeyValue( "start_active", "1" )
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire( "kill", "", 20 )

	-- FIX: self.Entity:GetPos in ScreenShake -> self:GetPos
	util.ScreenShake( self:GetPos(), 15, 15, 0.5, 2000 )
end
