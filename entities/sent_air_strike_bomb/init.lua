include( "shared.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
	-- FIX: self.Entity:SetModel/PhysicsInit/SetMoveType/SetSolid -> self:XXX
	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed (set by parent)
	self:SetModel( "models/military2/bomb/bomb_jdam.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- FIX: self.Entity:GetPhysicsObject -> self:GetPhysicsObject
	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end
end


function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:Explosion()
	end
end


function ENT:HitEffect()
	-- FIX: self.Entity:GetPos -> self:GetPos
	for _, v in pairs( ents.FindInSphere( self:GetPos(), 1250 ) ) do
		if IsValid( v ) and v:IsPlayer() then
			v:ConCommand( "pp_motionblur 1; pp_dof 1; sensitivity 1; play killstreak_rewards/shellshock.wav" )
			v:SetWalkSpeed( 50 )
			v:SetRunSpeed( 50 )
			timer.Simple( 5, function() v:ConCommand( "pp_motionblur 0; pp_dof 0; sensitivity 10" ) end )
			timer.Simple( 5, function() v:SetWalkSpeed( 250 ) end )
			timer.Simple( 5, function() v:SetRunSpeed( 500 ) end )
		end
	end
end


function ENT:Explosion()
	local ParticleExplode = ents.Create( "info_particle_system" )
	ParticleExplode:SetPos( self:GetPos() )
	ParticleExplode:SetKeyValue( "effect_name",  "stealth_explode" )
	ParticleExplode:SetKeyValue( "start_active", "1" )
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire( "kill", "", 20 )

	util.BlastDamage( self, self.Owner, self:GetPos(), 350, 350 )
	-- FIX: self.Entity:GetPos in ScreenShake -> self:GetPos
	util.ScreenShake( self:GetPos(), 100, 100, 2, 5000 )
	self:EmitSound( "ambient/explosions/explode_5.wav", 100 )

	timer.Simple( 1, function()
		if IsValid( self ) then
			self:Remove()
		end
	end )
end
