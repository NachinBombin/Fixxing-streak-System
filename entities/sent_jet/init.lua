AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local FLY_BY = Sound( "killstreak_misc/jet_fly_by.wav" )
local RADIUS  = 500

ENT.dropPos           = NULL
ENT.Model             = Model( "models/military2/air/air_f35_l.mdl" )
ENT.ground            = 0
-- FIX: ENT.dropDelay = CurTime() at table-def scope (stale) -> 0
ENT.dropDelay         = 0
ENT.droppedBombset1   = false
ENT.droppedBombset2   = false
ENT.bomb              = NULL
ENT.bomb2             = NULL
ENT.bomb3             = NULL
ENT.bomb4             = NULL
ENT.DropDaBomb        = false
ENT.StartAngle        = NULL
ENT.WasInWorld        = false


function ENT:PhysicsUpdate()
	self.PhysObj:SetVelocity( self:GetForward() * 7000 )
	self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.ground ) )
	self:SetAngles( self.StartAngle )

	if not self:IsInWorld() and self.WasInWorld then
		self:Remove()
	end
	if not self.WasInWorld and self:IsInWorld() then
		self.WasInWorld = true
	end

	if self:FindDropZone( self.dropPos ) and self.dropDelay < CurTime() and ( not self.droppedBombset1 or not self.droppedBombset2 ) then
		self:EmitSound( FLY_BY, 100 )
		self.dropDelay = CurTime() + 0.1
		self:DropBomb()
	end
end


function ENT:MW2_Init()
	-- FIX: self:GetVar('WallLocation'/'FlyAngle'/'JetDropZone') dead API -> GetNWVector/GetNWAngle
	self.StartPos = self:GetNWVector( "WallLocation", NULL )
	self.FlyAng   = self:GetNWAngle(  "FlyAngle",    NULL )
	self.dropPos  = self:GetNWVector( "JetDropZone",  NULL )
	self.ground   = self:findGround() + 2000

	if self.StartPos != NULL and self.FlyAng != NULL then
		self.spawnZone  = Vector( self.StartPos.x, self.StartPos.y, self.ground )
		self.StartAngle = self.FlyAng
	else
		local x, x2    = self:FindBounds( true )
		self.spawnZone  = Vector( x, self.dropPos.y, self.ground )
		self.StartAngle = Angle( 0, 180, 0 )
		-- FIX: SetNetworkedVector -> SetNWVector
		self.Owner:SetNWVector( "Harrier_Spawn_Pos", self.spawnZone )
	end

	-- FIX: self.Entity:SetPos/SetAngles -> self:XXX
	self:SetPos( self.spawnZone )
	self:SetAngles( self.StartAngle )

	self:FindMinHeight()
	self.spawnZone.z = self:FindMinHeight()
	self:SetPos( self.spawnZone )
	self:SpawnBombs()

	-- FIX: constraint.NoCollide(self.Entity,...) -> self
	constraint.NoCollide( self, game.GetWorld(), 0, 0 )
	self.PhysgunDisabled = true
end


ENT.BombPos = { Vector( -149, 99, -21 ), Vector( -149, -99, -21 ), Vector( -176, 144, -21 ), Vector( -176, -144, -21 ) }
ENT.Bombs   = {}
function ENT:SpawnBombs()
	local bombSent = "sent_air_strike_cluster"
	for _, v in pairs( self.BombPos ) do
		local bomb = ents.Create( bombSent )
		bomb:SetPos( self:LocalToWorld( v ) )
		bomb:SetAngles( self:GetAngles() )
		-- FIX: bomb:SetVar('owner'/'FromCarePackage') dead API -> direct table assign
		bomb.Owner           = self.Owner
		bomb.FromCarePackage = self:GetNWBool( "FromCarePackage", false )
		bomb:Spawn()
		bomb:SetNotSolid( true )
		constraint.NoCollide( self, bomb, 0, 0 )
		constraint.Weld( self, bomb, 0, 0, 0, false )
		bomb.PhysgunDisabled = true
		table.insert( self.Bombs, bomb )
	end
end


function ENT:FindMinHeight()
	local startPos   = self:GetPos()
	local filterList = { self }
	local trace = {
		start  = startPos,
		endpos = startPos + ( self:GetForward() * 1000000 ),
		filter = filterList
	}
	local bool        = true
	local maxNumber   = 0
	local skyLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitSky then
			skyLocation = td.HitPos.z
			bool = false
		elseif td.HitWorld then
			local loc = td.HitPos
			local skytrace = { start = Vector( loc.x, loc.y, self.Sky ), endpos = loc }
			local tr  = util.TraceLine( skytrace )
			local hit = tr.HitPos + Vector( 0, 0, 500 )
			trace.start  = hit
			trace.endpos = hit
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 300 then
			MsgN( "[MW2 Killstreaks] Jet FindMinHeight: max iterations reached" )
			bool = false
		end
	end
	if self:GetPos().z > skyLocation then return self:GetPos().z end
	return skyLocation
end


function ENT:OnTakeDamage( dmginfo ) end


function ENT:FindDropZone( VECTOR )
	-- FIX: self.Entity:GetPos -> self:GetPos
	local jetPos   = self:GetPos()
	local DISTANCE = jetPos - self.dropPos
	if math.abs( DISTANCE.x ) <= RADIUS and math.abs( DISTANCE.y ) <= RADIUS then
		return true
	end
	return false
end


function ENT:DropBomb()
	if not self.droppedBombset1 then
		for i = 1, 2 do
			local bomb = self.Bombs[i]
			constraint.RemoveConstraints( bomb, "Weld" )
			bomb:SetNotSolid( false )
			bomb:GetPhysicsObject():SetVelocity( Vector( 0, 0, 0 ) )
			-- FIX: bomb:SetVar('HasBeenDropped') dead API -> direct assign
			bomb.HasBeenDropped = true
		end
		table.remove( self.Bombs, 2 )
		table.remove( self.Bombs, 1 )
		self.droppedBombset1 = true
	elseif not self.droppedBombset2 then
		for i = 1, 2 do
			local bomb = self.Bombs[i]
			constraint.RemoveConstraints( bomb, "Weld" )
			bomb:SetNotSolid( false )
			bomb:GetPhysicsObject():SetVelocity( Vector( 0, 0, 0 ) )
			bomb.HasBeenDropped = true
		end
		table.remove( self.Bombs, 2 )
		table.remove( self.Bombs, 1 )
		self.droppedBombset2 = true
	end
end
