AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "MW2_PACKAGE_FRIENDLY" )
end

ENT.dropPos       = NULL
ENT.ground        = 0
-- FIX: CurTime() at table-def scope is stale -> 0
ENT.RemoveDelay   = 0
ENT.crate         = NULL
ENT.DropDaCrate   = false
ENT.DropOnce      = false
ENT.StartAngle    = NULL
ENT.WasInWorld    = false
ENT.IsInZone      = false
ENT.Top           = NULL
ENT.Back          = NULL
ENT.Model         = Model( "models/military2/air/air_h500.mdl" )

local radius      = 200
local roaterSound = Sound( "killstreak_misc/ah6_loop.wav" )


function ENT:PhysicsUpdate()
	-- FIX: self.Entity:GetForward/GetPos/SetPos/SetAngles/IsInWorld/Remove -> self:XXX
	if not self.IsInZone then
		self.PhysObj:SetVelocity( self:GetForward() * 1500 )
	else
		if not self.DropOnce then
			timer.Simple( 2, function() self:DropCrate() end )
			self.DropOnce = true
		end
	end

	self:SetPos( Vector( self:GetPos().x, self.dropPos.y, self.ground ) )
	self:SetAngles( self.StartAngle )

	if not self:IsInWorld() and self.WasInWorld and self.RemoveDelay < CurTime() then
		self.EMPSoundEmmiter:Stop()
		self:Remove()
		if IsValid( self.Top )  then self.Top:Remove()  end
		if IsValid( self.Back ) then self.Back:Remove() end
		return
	end

	if not self.WasInWorld and self:IsInWorld() then
		self.RemoveDelay = CurTime() + 2
		self.WasInWorld  = true
	end

	if self:FindDropZone( self.dropPos ) and not self.DropDaCrate then
		self.IsInZone = true
	end

	if IsValid( self.Top ) and IsValid( self.Back ) then
		self.Top:GetPhysicsObject():AddAngleVelocity( Vector( 0, 0, 300 ) )
		self.Back:GetPhysicsObject():AddAngleVelocity( Vector( 0, 25, 0 ) )
	end
end


function ENT:Initialize()
	-- FIX: self.Owner = self:GetVar('owner') - dead API -> removed; set by weapon base
	-- FIX: self.dropPos = self:GetVar('PackageDropZone') - dead API -> set by weapon before spawn
	self.ground     = self.dropPos.z + 1200

	local x = findWall( "x", self.ground )
	self.spawnZone  = Vector( x, self.dropPos.y, self.ground )
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

	self.Top = ents.Create( "prop_physics" )
	self.Top:SetModel( "models/military2/air/air_h500_r.mdl" )
	self.Top:SetPos( self:GetPos() + ( self:GetUp() * 50 ) )
	self.Top:Spawn()
	if IsValid( self.Top:GetPhysicsObject() ) then
		self.Top:GetPhysicsObject():EnableGravity( false )
	end

	self.Back = ents.Create( "prop_physics" )
	self.Back:SetModel( "models/military2/air/air_h500_sr.mdl" )
	self.Back:SetPos( self:GetPos() + ( self:GetForward() * -185 ) + ( self:GetUp() * 13 ) + ( self:GetRight() * -3 ) )
	self.Back:SetAngles( Angle( 0, 0, 180 ) )
	self.Back:Spawn()
	if IsValid( self.Back:GetPhysicsObject() ) then
		self.Back:GetPhysicsObject():EnableGravity( false )
	end

	self.crate = ents.Create( "sent_supplyCrate" )
	self.crate:SetPos( self:GetPos() + ( self:GetRight() * 1 ) + ( self:GetUp() * -64 ) + ( self:GetForward() * 8.5 ) )
	-- FIX: self.Entity:GetAngles() -> self:GetAngles()
	self.crate:SetAngles( self:GetAngles() + Angle( 0, 90, 0 ) )
	-- Note: crate still uses SetVar/GetVar for IsSentry passing; that is internal and unchanged
	self.crate.Owner  = self.Owner
	self.crate:SetVar( "IsSentry", self:GetVar( "IsSentry", false ) )
	self.crate:Spawn()
	if IsValid( self.crate:GetPhysicsObject() ) then
		self.crate:GetPhysicsObject():EnableGravity( false )
	end
	self.crate:SetNotSolid( true )

	constraint.NoCollide( self, self.crate, 0, 0 )
	-- FIX: constraint.Weld(self.Entity, ...) -> constraint.Weld(self, ...)
	constraint.Weld( self, self.crate, 0, 0, 0, false )
	constraint.NoCollide( self, game.GetWorld(), 0, 0 )
	constraint.NoCollide( self.Top, game.GetWorld(), 0, 0 )
	constraint.NoCollide( self.Back, game.GetWorld(), 0, 0 )
	constraint.Axis( self, self.Top,  0, 0, Vector( 0, 0, 0 ),      Vector( 0, 0, 0 ), 0, 0, 0, 1 )
	constraint.Axis( self, self.Back, 0, 0, Vector( -185, -3, 13 ), Vector( 0, 0, 0 ), 0, 0, 0, 1 )
	constraint.Keepupright( self.Top, Angle( 0, 0, 0 ), 0, 15 )

	self.EMPSoundEmmiter = CreateSound( self, roaterSound )
	self.EMPSoundEmmiter:Play()

	self:REQUEST_PACKAGE()
end


function ENT:REQUEST_PACKAGE()
	-- FIX: umsg.Start/End removed from GMod -> net library
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
			net.Start( "MW2_PACKAGE_FRIENDLY" )
			net.Send( Value )
		end
	end
end


function ENT:OnTakeDamage( dmginfo )
end


function ENT:FindDropZone( vec )
	local jetPos   = self:GetPos()
	local distance = jetPos - self.dropPos
	return math.abs( distance.x ) <= radius and math.abs( distance.y ) <= radius
end


function ENT:DropCrate()
	self.DropDaCrate = true
	if IsValid( self.crate:GetPhysicsObject() ) then
		self.crate:GetPhysicsObject():EnableGravity( true )
	end
	constraint.RemoveConstraints( self.crate, "Weld" )
	self.crate:SetNotSolid( false )
	self.IsInZone = false
end


function findGround()
	local minheight  = -16384
	local startPos   = Vector( 0, 0, 0 )
	local endPos     = Vector( 0, 0, minheight )
	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }
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
		-- FIX: maxNumber was never incremented -> infinite loop
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then bool = false end
	end
	return groundLocation
end


function findWall( axis, height )
	local length   = 16384
	local startPos = Vector( 0, 0, height )
	local endPos
	if axis == "x" then
		endPos = Vector( length, 0, height )
	elseif axis == "y" then
		endPos = Vector( 0, length, height )
	end
	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }
	local bool = true
	local maxNumber   = 0
	local wallLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitSky then
			if axis == "x" then wallLocation = td.HitPos.x
			elseif axis == "y" then wallLocation = td.HitPos.y end
			bool = false
		elseif td.HitWorld then
			if axis == "x" then trace.start = td.HitPos + Vector( 50, 0, 0 )
			elseif axis == "y" then trace.start = td.HitPos + Vector( 0, 50, 0 ) end
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then bool = false end
	end
	return wallLocation
end
