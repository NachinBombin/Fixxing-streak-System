include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

if SERVER then
	util.AddNetworkString( "COUNTER_UAV_STATUS" )
	util.AddNetworkString( "MW2_COUNTER_UAV_FRIENDLY" )
	util.AddNetworkString( "MW2_COUNTER_UAV_ENEMY" )
end

-- FIX: FlightLength was CurTime() at table-def scope (stale). Set in Initialize.
ENT.FlightLength = 0
ENT.flightHeight  = nil
ENT.ang           = NULL
ENT.speed         = 1500
ENT.OurHealth     = 100


function ENT:Think()
	if self.PhysObj:IsAsleep() then
		self.PhysObj:Wake()
	end
	if not self:IsInWorld() then
		MsgN( "[MW2 Killstreaks] Counter-UAV has returned to base!" )
		self:RemoveCounterUAV()
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
		self:RemoveCounterUAV()
	end
end


function ENT:Initialize()
	-- FIX: removed self.Owner = self:GetVar("owner") - dead API, set by weapon base
	self:SetModel( "models/COD4/UAV/UAV.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	self.flightHeight = self:findGround() + 5000
	self.PhysgunDisabled   = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )

	self:SetPos( Vector( self:FindEdge() - 500, 0, self.flightHeight ) )
	-- FIX: set at actual spawn time
	self.FlightLength = CurTime() + 30
	self.ang = Angle( 0, -90, 0 )

	local Players = player.GetHumans()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	if teamsOn then
		for _, Value in pairs( Players ) do
			if Value:Team() == self.Owner:Team() then
				Value:SetNoTarget( true )
			end
		end
	else
		for _, Value in pairs( Players ) do
			if Value == self.Owner then
				Value:SetNoTarget( true )
			end
		end
	end

	-- FIX: self:GetVar("Weapon"):PlaySound() - GetVar is dead API; use self.Wep
	if IsValid( self.Wep ) then
		self.Wep:PlaySound()
	end

	net.Start( "COUNTER_UAV_STATUS" )
	net.WriteBool( true )
	net.Send( player.GetHumans() )

	self:BROADCAST_COUNTER_UAV()
end


function ENT:GetTeam()
	return self.Owner:Team()
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
	self:RemoveCounterUAV()
end


function ENT:RemoveCounterUAV()
	local Players = player.GetHumans()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	if teamsOn then
		for _, Value in pairs( Players ) do
			if Value:Team() == self.Owner:Team() then
				Value:SetNoTarget( false )
			end
		end
	else
		for _, Value in pairs( Players ) do
			if Value == self.Owner then
				Value:SetNoTarget( false )
			end
		end
	end

	net.Start( "COUNTER_UAV_STATUS" )
	net.WriteBool( false )
	net.Send( player.GetHumans() )

	self:Remove()
end


function ENT:BROADCAST_COUNTER_UAV()
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
			net.Start( "MW2_COUNTER_UAV_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_COUNTER_UAV_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:FindSky()
	local maxheight  = 16384
	local startPos   = Vector( 0, 0, 0 )
	local endPos     = Vector( 0, 0, maxheight )
	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }
	local bool = true
	local maxNumber  = 0
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
	local maxNumber   = 0
	local groundLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitWorld then
			groundLocation = td.HitPos.z
			bool = false
		else
			table.insert( filterList, td.Entity )
		end
		-- FIX: original never incremented maxNumber in this loop -> infinite loop risk
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
