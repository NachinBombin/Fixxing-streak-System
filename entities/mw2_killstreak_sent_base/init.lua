AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.MapBounds        = {}
ENT.Model            = ""
ENT.Sky              = 0
ENT.playerSpeeds     = {}
ENT.restrictMovement = false
ENT.DropLoc          = nil
ENT.DropAng          = nil
ENT.Flares           = 0
ENT.FlareSpawnPos    = nil


function ENT:FindSky()
	local maxheight  = 16384
	local startPos   = Vector( 0, 0, 0 )
	local endPos     = Vector( 0, 0, maxheight )
	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }

	local bool        = true
	local maxNumber   = 0
	local skyLocation = -1

	while bool do
		local traceData = util.TraceLine( trace )
		if traceData.HitSky then
			skyLocation = traceData.HitPos.z
			bool = false
		elseif traceData.HitWorld then
			trace.start = traceData.HitPos + Vector( 0, 0, 50 )
		else
			table.insert( filterList, traceData.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 300 then
			MsgN( "[MW2 Killstreaks] FindSky: reached max iterations, no skybox found" )
			bool = false
		end
	end

	return skyLocation
end


function ENT:findGround()
	local minheight  = -16384
	local startPos   = Vector( 0, 0, self.Sky )
	local endPos     = Vector( startPos.x, startPos.y, minheight )
	local filterList = { self.Owner, self }
	local trace = { start = startPos, endpos = endPos, filter = filterList }

	local bool           = true
	local maxNumber      = 0
	local groundLocation = -1

	while bool do
		local traceData = util.TraceLine( trace )
		if traceData.HitWorld then
			groundLocation = traceData.HitPos.z
			bool = false
		else
			table.insert( filterList, traceData.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then
			MsgN( "[MW2 Killstreaks] findGround: reached max iterations, ground not found" )
			bool = false
		end
	end

	return groundLocation
end


function ENT:FindBounds( xAxis )
	local height  = self.Sky
	local length  = 16384
	local startPos = Vector( 0, 0, height )
	local endPos

	if xAxis then
		endPos = Vector( length, 0, height )
	else
		endPos = Vector( 0, length, height )
	end

	local filterList    = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }

	local bool          = true
	local maxNumber     = 0
	local wallLocation1 = -1
	local wallLocation2 = -1

	while bool do
		local traceData = util.TraceLine( trace )
		if traceData.HitSky then
			if wallLocation1 == -1 then
				wallLocation1 = xAxis and traceData.HitPos.x or traceData.HitPos.y
				if xAxis then
					endPos = Vector( -length, 0, height )
				else
					endPos = Vector( 0, -length, height )
				end
				trace = { start = startPos, endpos = endPos, filter = filterList }
			else
				wallLocation2 = xAxis and traceData.HitPos.x or traceData.HitPos.y
				bool = false
			end
		elseif traceData.HitWorld then
			if wallLocation1 == -1 then
				trace.start = xAxis and ( traceData.HitPos + Vector( 50, 0, 0 ) ) or ( traceData.HitPos + Vector( 0, 50, 0 ) )
			else
				trace.start = xAxis and ( traceData.HitPos - Vector( 50, 0, 0 ) ) or ( traceData.HitPos - Vector( 0, 50, 0 ) )
			end
		else
			table.insert( filterList, traceData.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then
			MsgN( "[MW2 Killstreaks] FindBounds: reached max iterations, wall not found" )
			bool = false
		end
	end

	return wallLocation1, wallLocation2
end


function ENT:Initialize()
	self.Owner = self.Owner or nil  -- set by weapon base SWEP:Run() as ent.Owner

	-- FIX: added IsValid guard - if owner is nil/invalid, remove cleanly
	-- instead of crashing at GetWalkSpeed on a nil value
	if not IsValid( self.Owner ) then
		self:Remove()
		MsgN( "[MW2 Killstreaks] Entity spawned without valid owner - removed." )
		return
	end

	self.Wep = self.Wep or nil
	self.Sky = self:FindSky()
	self:SetModel( self.Model )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	self.PhysgunDisabled   = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )

	self.playerSpeeds = { self.Owner:GetWalkSpeed(), self.Owner:GetRunSpeed() }

	if self.restrictMovement then
		self.Owner:SetWalkSpeed( 1 )
		self.Owner:SetRunSpeed( 1 )
	else
		self.Owner:SetWalkSpeed( self.playerSpeeds[1] )
		self.Owner:SetRunSpeed( self.playerSpeeds[2] )
	end

	self:MW2_Init()
end


function ENT:MW2_Init()
end

function ENT:GetTeam()
	return self.Owner:Team()
end

function ENT:Destroy()
end


function ENT:FilterTarget( target, LOS )
	local haslos
	if not LOS then
		haslos = true
	else
		haslos = self:HasLOS( target )
	end

	if IsValid( target ) and haslos then
		if target:IsNPC() then
			if not table.HasValue( self.Friendlys, target:GetClass() ) then
				return true
			end
		elseif target:IsPlayer() then
			if target != self.Owner and target:Team() != self.Owner:Team() and GetConVar( "sbox_plpldamage" ):GetInt() != 0 then
				return true
			end
		end
	end
	return false
end


function ENT:HasLOS( target )
	local tracedata = {
		start  = self:GetPos(),
		endpos = target:LocalToWorld( target:OBBCenter() ),
		filter = self
	}
	local trace = util.TraceLine( tracedata )
	if IsValid( trace.Entity ) and ( trace.Entity == target or not table.HasValue( self.Friendlys, target:GetClass() ) ) then
		return true
	end
	return false
end


local function SpawnFlares( self, fpos )
	local flare = nil
	for i = 0, 20 do
		local flares = ents.Create( "sent_mw2_flares" )
		flares:SetPos( fpos )
		flares:Spawn()
		local Phys = flares:GetPhysicsObject()
		if Phys:IsValid() then
			Phys:Wake()
			Phys:ApplyForceCenter( Vector(
				math.random( -40, 40 ),
				math.random( -40, 40 ),
				math.random( -40, 40 )
			) * Phys:GetMass() )
		end
		flares:Activate()
		constraint.NoCollide( self, flares, 0, 0 )
		if flare == nil then flare = flares end
	end
	return flare
end


function ENT:DeployFlares( obj, fpos )
	if self.Flares <= 0 then return end
	if obj.FlareSpawned then return end
	local vel = obj:GetVelocity()
	if vel:Dot( vel:GetNormal() ) <= 0 then return end

	local trace = util.QuickTrace( obj:GetPos(), vel:GetNormal() * 10000, { obj } )
	if IsValid( trace.Entity ) and trace.Entity == self then
		self:SpawnDecoy( obj, SpawnFlares( self, fpos ) )
	end
	obj.FlareSpawned = true
	self.Flares = self.Flares - 1
end


function ENT:SpawnDecoy( missile, target )
	local decoy = ents.Create( "mw2_sent_decoyMissile" )
	decoy:SetVar( "Model", missile:GetModel() )
	decoy:SetVar( "Owner", missile:GetOwner() or missile.Owner )
	decoy:SetVar( "Target", target )

	local phys = missile:GetPhysicsObject()
	local vel
	if IsValid( phys ) then
		vel = phys:GetVelocity()
	else
		vel = missile:GetVelocity()
	end
	decoy:SetVar( "Velocity", vel:Dot( vel:GetNormal() ) )

	local pos = missile:GetPos()
	missile:Remove()
	decoy:SetPos( pos )
	decoy:Spawn()
end


function ENT:SetDropLocation( vec, ang )
	self.DropLoc = vec
	self.DropAng = Angle( 0, ang, 0 )
end


function ENT:OpenOverlayMap( select )
	self.Owner.DropLocEnt = self
	net.Start( "MW2_DropLoc_Overlay_UM" )
		net.WriteFloat( self:EntIndex() )
		net.WriteBool( select )
	net.Send( self.Owner )
end


local function SetLocation( size, pl )
	local ei  = net.ReadFloat()
	local ent = Entity( ei )
	if not IsValid( ent ) then
		ent = pl.DropLocEnt
	end
	local pos = net.ReadVector()
	local ang = net.ReadFloat()

	if IsValid( ent ) then
		ent:SetDropLocation( pos, ang != 0 and ang or nil )
	end
end

net.Receive( "MW2_DropLocation_Overlay_Stream", SetLocation )
