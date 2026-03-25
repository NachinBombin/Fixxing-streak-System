AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )


function ENT:Think()
	if self:WaterLevel() > 0 then
		self:Explode()
	end
end


function ENT:Freeze()
	-- FIX: self.Entity:SetMoveType -> self:SetMoveType
	self:SetMoveType( MOVETYPE_NONE )
end


function ENT:Explode()
	util.BlastDamage( self, self.Owner, self:GetPos(), 500, 100 )

	local p = ents.Create( "info_particle_system" )
	p:SetPos( self:GetPos() )
	p:SetKeyValue( "effect_name",  "cluster_explode" )
	p:SetKeyValue( "start_active", "1" )
	p:Spawn()
	p:Activate()
	p:Fire( "kill", "", 20 )

	self:EmitSound( "weapons/explode3.wav", 200 )

	timer.Simple( 1, function()
		if IsValid( self ) then
			self:Remove()
		end
	end )
end


function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 1 and data.DeltaTime > 0.1 and data.HitEntity:GetClass() != self:GetClass() then
		self:Explode()
	end
end


function ENT:Initialize()
	-- FIX: self.Entity:SetModel/SetColor/PhysicsInit/SetMoveType/SetSolid/GetPhysicsObject -> self:XXX
	-- FIX: self.Owner = self:GetVar('owner') dead API -> removed (set by parent/spawner)
	self:SetModel( "models/items/ar2_grenade.mdl" )
	self:SetColor( Color( 50, 50, 50, 255 ) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local Phys = self:GetPhysicsObject()
	if Phys:IsValid() then
		Phys:Wake()
	end

	self.PhysgunDisabled = true
end
