AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
include( "nuke_vars_init.lua" )


function ENT:Initialize()
	self.Yield        = ( GetConVar( "nuke_yield" ):GetInt() or 100 ) / 100
	self.YieldSlow    = self.Yield ^ 0.75
	self.YieldSlowest = self.Yield ^ 0.5
	-- FIX: self.Entity:GetPos -> self:GetPos
	self.Pos = self:GetPos() + Vector( 0, 0, 4 )

	self.Damage   = ( GetConVar( "nuke_radiation_damage" ):GetInt() or 100 ) * 3e5 * self.YieldSlow
	self.Duration = ( GetConVar( "nuke_radiation_duration" ):GetInt() or 100 ) * 0.40 * self.YieldSlowest
	self.Radius   = 12000 * self.YieldSlow

	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed (set by sent_nuke spawner)
	-- FIX: self.Weapon = self.Entity deprecated alias -> removed; use self directly
	self.lastThink = CurTime() + 3
	self.RadTime   = CurTime() + self.Duration

	-- FIX: self.Entity:SetMoveType/DrawShadow/SetCollisionBounds/PhysicsInitBox/GetPhysicsObject/SetNotSolid/Fire -> self:XXX
	self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow( false )
	self:SetCollisionBounds( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
	self:PhysicsInitBox( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions( false )
	end

	self:SetNotSolid( true )
	self:Fire( "kill", "", self.Duration )
end


function ENT:LOS( ent, entpos )
	local trace = {
		start  = self.Pos,
		-- FIX: filter = {self.Entity} -> {self}
		filter = { self },
		endpos = entpos
	}
	local traceRes = util.TraceLine( trace )
	if traceRes.Entity ~= ent and math.abs( self.Pos.z - entpos.z ) < 800 * self.Yield then
		trace.start = Vector( self.Pos.x, self.Pos.y, entpos.z )
		traceRes    = util.TraceLine( trace )
	end
	return ( traceRes.Entity == ent )
end


function ENT:Think()
	local CurrentTime = CurTime()
	local FTime = CurrentTime - self.lastThink
	if FTime < 0.3 then return end

	self.lastThink   = CurrentTime
	local RadIntensity = ( self.RadTime - CurrentTime ) / self.Duration

	for _, found in pairs( ents.FindInSphere( self.Pos, self.Radius ) ) do
		if IsValid( found ) then
			local entpos = found:LocalToWorld( found:OBBCenter() )
			if found:IsNPC() then
				if self:LOS( found, entpos ) then
					local entdist = ( ( entpos - self.Pos ):Length() ) ^ -2
					-- FIX: util.BlastDamage(self.Weapon,...) -> self
					util.BlastDamage( self, self.Owner, entpos, 8, self.Damage * RadIntensity * entdist )
				end
			elseif found:IsPlayer() then
				if self:LOS( found, entpos ) then
					local entdist = ( ( entpos - self.Pos ):Length() ) ^ -2
					found:TakeDamage( self.Damage * RadIntensity * entdist, self.Owner )
				end
			end
		end
	end
end
