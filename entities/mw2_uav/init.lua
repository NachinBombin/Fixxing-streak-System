AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "UAV_STATUS" )
	util.AddNetworkString( "MW2_UAV_FRIENDLY" )
	util.AddNetworkString( "MW2_UAV_ENEMY" )
	util.AddNetworkString( "MW2_UAV_END" )
end

-- FIX: CurTime() at table-def scope is stale. Set to 0; assigned in Initialize.
ENT.FlightLength = 0
ENT.flightHeight  = nil
ENT.ang           = NULL
ENT.speed         = 1500
ENT.OurHealth     = 100

local IsUAVActive = false
local UAV_ACTIVE  = false


function ENT:Think()
	if self.PhysObj:IsAsleep() then
		self.PhysObj:Wake()
	end
	if not self:IsInWorld() then
		MsgN( "[ MW2 Killstreaks ] The UAV has returned to base!" )
		self:Remove()
	end
end


function ENT:PhysicsUpdate()
	self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.flightHeight ) )
	self.PhysObj:SetVelocity( self:GetForward() * 750 )
	self:SetAngles( self.ang )

	local Trace = util.QuickTrace( self:GetPos(), self:GetForward() * 4500, self )
	if Trace.HitSky then
		self.ang = self.ang + Angle( 0, -0.3, 0 )
	end

	if self.FlightLength < CurTime() then
		self:Remove()
	end
end


function ENT:GetTeam()
	return self.Owner:Team()
end


function ENT:Initialize()
	-- FIX: self.Owner = self:GetVar('owner') - dead API -> removed; set by weapon base
	if IsUAVActive then
		self:Remove()
		return
	end

	self:SetModel( "models/COD4/UAV/UAV.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	self.flightHeight = self:findGround() + 5000
	self:SetPos( Vector( self:FindEdge() - 500, 0, self.flightHeight ) )
	-- FIX: set at actual spawn time
	self.FlightLength = CurTime() + 30
	self.ang = Angle( 0, -90, 0 )

	self.PhysgunDisabled      = true
	self.m_tblToolsAllowed    = string.Explode( " ", "none" )

	IsUAVActive = true

	-- FIX: self:GetVar('Weapon'):PlaySound() - GetVar dead API; nil crash
	if IsValid( self.Wep ) then
		self.Wep:PlaySound()
	end

	UAV_ACTIVE = true
	net.Start( "UAV_STATUS" )
	net.WriteBool( UAV_ACTIVE )
	net.Send( player.GetHumans() )

	self:BROADCAST_UAV()
end


function ENT:BROADCAST_UAV()
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
			net.Start( "MW2_UAV_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_UAV_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:OnTakeDamage( dmg )
	self:TakePhysicsDamage( dmg )
	if self.OurHealth <= 0 then return end
	self.OurHealth = self.OurHealth - dmg:GetDamage()
	if self.OurHealth <= 0 then
		self:Destroy()
	end
end


function ENT:Destroy()
	local p = ents.Create( "info_particle_system" )
	p:SetPos( self:GetPos() )
	p:SetKeyValue( "effect_name", "cluster_explode" )
	p:SetKeyValue( "start_active", "1" )
	p:Spawn()
	p:Activate()
	p:Fire( "kill", "", 20 )
	self:Remove()
end


function ENT:FindSky()
	local maxheight  = 16384
	local startPos   = Vector( 0, 0, 0 )
	local endPos     = Vector( 0, 0, maxheight )
	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }
	local bool = true
	local maxNumber   = 0
	local skyLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitSky then
			skyLocation = td.HitPos.z
			bool = false
		elseif td.HitWorld then
			trace.start = td.HitPos + Vector( 0, 0, 50 )
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 300 then bool = false end
	end
	return skyLocation
end


function ENT:findGround()
	local minheight  = -16384
	local startPos   = Vector( 0, 0, self:FindSky() )
	local endPos     = Vector( 0, 0, minheight )
	local filterList = { self.Owner, self }
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
		-- FIX: maxNumber never incremented -> infinite loop
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then bool = false end
	end
	return groundLocation
end


function ENT:FindEdge()
	local dis        = 16384
	local height     = self:FindSky()
	local startPos   = Vector( 0, 0, height )
	local endPos     = Vector( dis, 0, height )
	local filterList = { self.Owner, self }
	local trace = { start = startPos, endpos = endPos, filter = filterList }
	local bool = true
	local maxNumber   = 0
	local WallLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitWorld then
			WallLocation = td.HitPos.x
			bool = false
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then bool = false end
	end
	return WallLocation
end


function ENT:OnRemove()
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
			net.Start( "MW2_UAV_END" )
			net.Send( Value )
		end
	end

	UAV_ACTIVE = false
	net.Start( "UAV_STATUS" )
	net.WriteBool( UAV_ACTIVE )
	net.Send( player.GetHumans() )
	IsUAVActive = false
end
