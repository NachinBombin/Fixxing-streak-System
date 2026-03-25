-- Server-only SENT: no shared.lua or cl_init.lua exists for this entity.
-- FIX: removed include('shared.lua') that caused the startup crash.

AddCSLuaFile()

ENT.Target = NULL

function ENT:Initialize()
	self:SetModel( "models/Weapons/W_missile_closed.mdl" )
	-- FIX: GetVar() is removed datastream API. Owner/Target are set directly
	-- on the entity table by weapon_stingermissile:FireMissile().
	self.Owner  = self.Owner  or Entity( 1 )
	self.Target = self.Target or NULL

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end
end


function ENT:PhysicsUpdate()
	if self.Trail and self.Trail:IsValid() then
		self.Trail:SetPos( self:GetPos() - 16 * self:GetForward() )
		-- FIX: SetLocalAngles takes Angle not Vector
		self.Trail:SetLocalAngles( Angle( 0, 0, 0 ) )
	else
		self:SpawnTrail()
	end

	if IsValid( self.Target ) then
		local ang    = ( self.Target:GetPos() - self:GetPos() ):Angle()
		local ourAng = self:GetAngles()
		local turnF  = 10
		local newYaw   = math.ApproachAngle( math.Round( ourAng.y ), math.Round( ang.y ), turnF )
		local newPitch = math.ApproachAngle( math.Round( ourAng.p ), math.Round( ang.p ), turnF )
		-- FIX: original code called SetAngles(blended) then immediately SetAngles(ang),
		-- overwriting the smooth turn with a hard snap every tick. Removed hard-snap.
		self:SetAngles( Angle( newPitch, newYaw, ourAng.r ) )
		self:GetPhysicsObject():SetVelocity( self:GetForward() * 2500 )
	end
end


function ENT:Think()
end


function ENT:PhysicsCollide( data, physobj )
	if data.Speed > 50 and data.DeltaTime > 0.15 then
		self:Explosion()
		self:Remove()
	end
end


function ENT:Explosion()
	local expl = ents.Create( "env_explosion" )
	expl:SetOwner( self )
	expl:SetKeyValue( "spawnflags", 128 )
	expl:SetKeyValue( "iMagnitude", "200" )
	expl:SetPos( self:GetPos() )
	expl:Spawn()
	expl:Fire( "explode", "", 0 )

	local ar2Explo = ents.Create( "env_ar2explosion" )
	ar2Explo:SetOwner( self )
	ar2Explo:SetPos( self:GetPos() )
	ar2Explo:Spawn()
	ar2Explo:Activate()
	ar2Explo:Fire( "Explode", "", 0 )
end


function ENT:SpawnTrail()
	self.Trail = ents.Create( "env_rockettrail" )
	self.Trail:SetPos( self:GetPos() - 16 * self:GetForward() )
	self.Trail:SetParent( self )
	-- FIX: SetLocalAngles takes Angle not Vector
	self.Trail:SetLocalAngles( Angle( 0, 0, 0 ) )
	self.Trail:Spawn()
end
