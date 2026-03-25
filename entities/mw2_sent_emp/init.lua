AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "EMP_STATUS" )
	util.AddNetworkString( "MW2_EMP_FireEMP" )
	util.AddNetworkString( "MW2_EMP_FRIENDLY" )
	util.AddNetworkString( "MW2_EMP_ENEMY" )
	util.AddNetworkString( "MW2_EMP_OWNER" )
	util.AddNetworkString( "MW2_EMP_RemoveEMP" )
end

-- FIX: ENT.Timer = CurTime() at table-def scope is stale. Set in Initialize.
ENT.Duration    = 60
ENT.Timer       = 0
ENT.Killstreaks = { "mw2_counterUAV", "mw2_SentryGun", "mw2_UAV", "sent_ac-130", "sent_harrier", "npc_bullseye" }

local empSound = Sound( "killstreak_misc/em_pulse.wav" )


function ENT:Initialize()
	-- FIX: removed self.Owner = self:GetVar("owner") - dead datastream API
	self:SetModel( "models/dav0r/camera.mdl" )
	self:SetColor( Color( 255, 255, 255 ) )
	self:SetPos( Vector( 0, 0, self:FindSky() - 200 ) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:GetPhysicsObject():EnableGravity( false )
	self:SetNotSolid( true )

	-- FIX: was global, now instance variable
	self.EmpTeam = -1
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0
	if teamsOn then
		self.EmpTeam = self.Owner:Team()
	end

	self:Create_EMP_Effect()
	self:Kill_Killstreaks()
	-- FIX: set at actual spawn time
	self.Timer = CurTime() + self.Duration

	self.EMPSoundEmitter = CreateSound( self, empSound )
	self.EMPSoundEmitter:Play()

	net.Start( "EMP_STATUS" )
	net.WriteBool( true )
	net.Send( player.GetHumans() )

	self:FIRE_EMP()
end


function ENT:FIRE_EMP()
	-- FIX: all umsg.Start/End replaced with net library
	local Players = player.GetHumans()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	for _, Value in pairs( Players ) do
		local isFriendly
		if teamsOn then
			isFriendly = Value:Team() == self.Owner:Team()
		else
			isFriendly = Value == self.Owner
		end

		-- Send EMP fire notification to everyone
		net.Start( "MW2_EMP_FireEMP" )
		if teamsOn then
			net.WriteInt( self.Owner:Team(), 16 )
		else
			net.WriteInt( isFriendly and 1 or 0, 16 )
		end
		net.Send( Value )

		if isFriendly then
			Value:SetNoTarget( true )
			net.Start( "MW2_EMP_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_EMP_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:Think()
	if self.Timer <= CurTime() then
		self:Remove_EMP()
	end
	-- FIX: self.Entity:NextThink -> self:NextThink
	self:NextThink( CurTime() + 0.01 )
	return true
end


function ENT:Create_EMP_Effect()
	local p = ents.Create( "info_particle_system" )
	p:SetPos( self:GetPos() )
	p:SetKeyValue( "effect_name", "EMP" )
	p:SetKeyValue( "start_active", "1" )
	p:Spawn()
	p:Activate()
	p:Fire( "kill", "", 40 )
end


function ENT:Kill_Killstreaks()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	for _, cls in pairs( self.Killstreaks ) do
		for _, ks in pairs( ents.FindByClass( cls ) ) do
			-- FIX: Value:GetVar("owner") is dead API. Owner is stored on .Owner
			local ksOwner = ks.Owner
			local shouldKill = false

			if teamsOn then
				shouldKill = IsValid( ksOwner ) and ksOwner:Team() != self.Owner:Team()
			else
				shouldKill = ksOwner != self.Owner
			end

			if shouldKill then
				if ks:IsNPC() and ks:GetClass() == "npc_bullseye" then
					ks:Fire( "kill", "", 0 )
				else
					ks:Destroy()
				end
			end
		end
	end
end


function ENT:Remove_EMP()
	local Players = player.GetHumans()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	-- FIX: umsg per-player loops replaced with net.Broadcast
	net.Broadcast( "MW2_EMP_RemoveEMP" )

	for _, Value in pairs( Players ) do
		local isFriendly
		if teamsOn then
			isFriendly = Value:Team() == self.Owner:Team()
		else
			isFriendly = Value == self.Owner
		end
		if isFriendly then
			Value:SetNoTarget( false )
		end
	end

	net.Start( "EMP_STATUS" )
	net.WriteBool( false )
	net.Send( player.GetHumans() )

	self:Remove()
end


function ENT:FindSky()
	local maxheight  = 16384
	local startPos   = Vector( 0, 0, 0 )
	local endPos     = Vector( 0, 0, maxheight )
	local filterList = {}
	local trace = { start = startPos, endpos = endPos, filter = filterList }
	local bool = true
	local num  = 0
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
		num = num + 1
		if num >= 300 then bool = false end
	end
	return skyLocation
end
