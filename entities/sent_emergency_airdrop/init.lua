AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "MW2_AIRDROP_FRIENDLY" )
end

ENT.dropPos      = NULL
local RADIUS     = 100
ENT.ground       = 0
ENT.RemoveDelay  = 0
ENT.crate        = NULL
ENT.DropDaCrate  = false
ENT.StartAngle   = NULL
ENT.WasInWorld   = false
ENT.Model        = Model( "models/military2/air/air_130_l.mdl" )


function ENT:Initialize()
	hook.Add( "PhysgunPickup", "DisallowJetPickUp", physgunJetPickup )
	-- FIX: self:GetVar('owner') dead API -> removed; Owner set by weapon base
	-- FIX: self:GetVar('PackageDropZone') dead API -> GetNWVector
	self.dropPos   = self:GetNWVector( "PackageDropZone", NULL )

	self.ground = self:findGround() + 2000

	local x = self:findWall( "x", self.ground )
	self.spawnZone = Vector( x, self.dropPos.y, self.ground )
	self.StartAngle = Angle( 0, 180, 0 )

	self:SetModel( self.Model )
	self:SetColor( Color( 255, 255, 255, 255 ) )
	self:SetPos( self.spawnZone )
	self:SetAngles( self.StartAngle )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:EnableGravity( false )
		self.PhysObj:Wake()
	end

	-- FIX: self.Entity -> self
	constraint.NoCollide( self, game.GetWorld(), 0, 0 )
	self:REQUEST_AIRDROP()
end


function ENT:PhysicsUpdate()
	-- FIX: self.Entity:GetForward/GetPos/SetPos/SetAngles/IsInWorld/Remove -> self:XXX
	self.PhysObj:SetVelocity( self:GetForward() * 3500 )
	self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.ground ) )
	self:SetAngles( self.StartAngle )

	if not self:IsInWorld() and self.WasInWorld and self.RemoveDelay < CurTime() then
		self:Remove()
		hook.Remove( "PhysgunPickup", "DisallowJetPickUp" )
		return
	end

	if not self.WasInWorld and self:IsInWorld() then
		self.RemoveDelay = CurTime() + 2
		self.WasInWorld  = true
	end

	if self:FindDropZone( self.dropPos ) and not self.DropDaCrate then
		self.DropDaCrate = true
		timer.Create( "EmAd_crateTimer", 0.1, 4, function() self:DropCrate() end )
	end
end


function ENT:REQUEST_AIRDROP()
	-- FIX: umsg.Start/End -> net library
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
			net.Start( "MW2_AIRDROP_FRIENDLY" )
			net.Send( Value )
		end
	end
end


function ENT:OnTakeDamage( dmginfo ) end


function ENT:FindDropZone( vec )
	-- FIX: self.Entity:GetPos -> self:GetPos
	local jetPos   = self:GetPos()
	local distance = jetPos - self.dropPos
	if math.abs( distance.x ) <= RADIUS and math.abs( distance.y ) <= RADIUS then
		return true
	end
	return false
end


function ENT:DropCrate()
	self.DropDaCrate = true
	local crate = ents.Create( "sent_supplyCrate" )
	crate:SetPos( self:GetPos() + ( self:GetRight() * -3.5 ) + ( self:GetUp() * 16.6 ) + ( self:GetForward() * -393 ) )
	-- FIX: crate:SetVar('CrateType'/'owner') dead API -> direct table assign
	crate.Owner     = self.Owner
	crate.CrateType = self:GetClass()
	crate:Spawn()
	constraint.NoCollide( self, crate, 0, 0 )
end


-- FIX: findGround/findWall were bare globals -> ENT methods
function ENT:findGround()
	local minheight  = -16384
	local startPos   = Vector( 0, 0, 0 )
	local filterList = {}
	local trace = { start = startPos, endpos = Vector( 0, 0, minheight ), filter = filterList }
	local bool = true
	local maxNumber      = 0
	local groundLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitWorld then
			groundLocation = td.HitPos.z
			bool = false
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then
			MsgN( "[MW2 Killstreaks] EmAd findGround: max iterations reached" )
			bool = false
		end
	end
	return groundLocation
end


function ENT:findWall( axis, height )
	local length   = 16384
	local startPos = Vector( 0, 0, height )
	local endPos   = axis == "x" and Vector( length, 0, height ) or Vector( 0, length, height )
	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }
	local bool = true
	local maxNumber    = 0
	local wallLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitSky then
			wallLocation = axis == "x" and td.HitPos.x or td.HitPos.y
			bool = false
		elseif td.HitWorld then
			if axis == "x" then
				trace.start = td.HitPos + Vector( 50, 0, 0 )
			else
				trace.start = td.HitPos + Vector( 0, 50, 0 )
			end
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then
			MsgN( "[MW2 Killstreaks] EmAd findWall: max iterations reached" )
			bool = false
		end
	end
	return wallLocation
end


function physgunJetPickup( ply, ent )
	if ent:GetClass() == "sent_jet" or ent:GetClass() == "sent_air_strike_cluster" then
		return false
	else
		return true
	end
end
