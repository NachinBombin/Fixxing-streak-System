include( "shared.lua" )

ENT.Target   = nil
ENT.Vel      = nil
ENT.Exploded = false


function ENT:Initialize()
	-- FIX: self:GetVar() is old datastream API (removed from GMod) -> GetNW*
	local m = self:GetNWString( "DecoyModel", "" )
	self.Owner  = self:GetNWEntity( "DecoyOwner",  NULL )
	self.Target = self:GetNWEntity( "DecoyTarget", NULL )
	self.Vel    = self:GetNWFloat(  "DecoyVelocity", 0 )

	if m == "" then
		self:Remove()
		return
	end

	self:SetModel( m )
	self:SetOwner( self.Owner )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.phys = self:GetPhysicsObject()
	if self.phys:IsValid() then
		self.phys:Wake()
	else
		self:SetModel( "models/Weapons/W_missile_closed.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self.phys = self:GetPhysicsObject()
		if self.phys:IsValid() then self.phys:Wake() end
	end

	util.SpriteTrail( self, 0, Color( 255, 255, 255, 150 ), false, 10, 0, 0.4, 1 / 3 * 0.5, "trails/smoke.vmt" )
	self.turnDelay = CurTime()
end


function ENT:PhysicsCollide( data, phys )
	if not self.Exploded then
		self:Explode()
		self.Exploded = true
	end
end


function ENT:Think()
	self:NextThink( CurTime() + 0.001 )
	self.phys:SetVelocity( self:GetForward() * self.Vel )

	if IsValid( self.Target ) then
		local ourAng = self:GetAngles()
		local ang    = ( self.Target:GetPos() - self:GetPos() ):Angle()
		if ourAng.y < 0 then ourAng.y = 360 + ourAng.y end
		if ourAng.p < 0 then ourAng.p = 360 + ourAng.p end
		if self.turnDelay < CurTime() then
			local turnF = 10
			self.yaw   = math.ApproachAngle( math.Round( ourAng.y ), math.Round( ang.y ), turnF )
			self.pitch = math.ApproachAngle( math.Round( ourAng.p ), math.Round( ang.p ), turnF )
			self:SetAngles( Angle( self.pitch, self.yaw, ourAng.r ) )
			self.turnDelay = CurTime() + 0.005
		end
	end
	return true
end


function ENT:Explode()
	local p = ents.Create( "info_particle_system" )
	p:SetPos( self:GetPos() )
	p:SetKeyValue( "effect_name",  "stealth_explode" )
	p:SetKeyValue( "start_active", "1" )
	p:Spawn()
	p:Activate()
	p:Fire( "kill", "", 20 )
	util.ScreenShake( self:GetPos(), 100, 100, 2, 5000 )
	self:Remove()
end
