AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "MW2_Nukes_SetUpHUD" )
	util.AddNetworkString( "MW2_NUKE_FRIENDLY" )
	util.AddNetworkString( "MW2_NUKE_ENEMY" )
	util.AddNetworkString( "MW2_Nuke_RemoveHUD" )
end

-- FIX: ENT.TimeToDetonate/TimerDelay = CurTime() at table-def scope (stale) -> 0
ENT.TimeToDetonate = 0
ENT.DetonatePos    = NULL
ENT.CountDown      = 10
ENT.TimerDelay     = 0
ENT.NukeSpawned    = false

ENT.Killable_Killstreaks = { "mw2_counterUAV", "mw2_SentryGun", "mw2_UAV", "sent_ac-130", "sent_harrier", "npc_bullseye" }


function ENT:Initialize()
	SetGlobalString( "MW2_Nuke_CountDown_Timer", "" )
	-- FIX: set timestamps live at spawn time
	self.TimeToDetonate = CurTime() + 10
	self.TimerDelay     = CurTime()
	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed (set by weapon)
	SetGlobalString( "MW2_Nuke_Player", tostring( IsValid( self.Owner ) and self.Owner:GetName() or "" ) )
	self:SetModel( "models/dav0r/camera.mdl" )
	self:SetPos( Vector( 0, 0, self:findGround() ) )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:GetPhysicsObject():EnableGravity( false )
	self:SetNotSolid( true )

	-- FIX: umsg.Start/End -> net library
	for _, Value in pairs( player.GetHumans() ) do
		net.Start( "MW2_Nukes_SetUpHUD" )
		net.Send( Value )
	end

	self:SEND_NUKE()
end


function ENT:SEND_NUKE()
	-- FIX: umsg.Start/End x4 -> net library
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
			net.Start( "MW2_NUKE_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_NUKE_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:Think()
	if CurTime() < self.TimeToDetonate and self.TimerDelay < CurTime() then
		self.TimerDelay = CurTime() + 0.1
		self.CountDown  = self.CountDown - 0.1
		SetGlobalString( "MW2_Nuke_CountDown_Timer", tostring( self.CountDown ) )
	elseif CurTime() > self.TimeToDetonate and not self.NukeSpawned then
		self:SpawnNuke()
		timer.Simple( 5, function() if IsValid( self ) then self:Remove() end end )
	end
	-- FIX: self.Entity:NextThink -> self:NextThink
	self:NextThink( CurTime() + 0.01 )
	return true
end


function ENT:SpawnNuke()
	self.NukeSpawned = true
	-- FIX: umsg.Start/End -> net library
	net.Start( "MW2_Nuke_RemoveHUD" )
	net.Send( self.Owner )

	local nuke = ents.Create( "sent_tactical_nuke" )
	nuke:SetPos( self:GetPos() )
	-- FIX: nuke:SetVar('owner') dead API -> direct assign
	nuke.Owner = self.Owner
	nuke:Spawn()
	nuke:Activate()

	self:killEveryOneWithNuke()
end


function ENT:killEveryOneWithNuke()
	local Entities = ents.GetAll()
	local FRAGS = 0

	for _, v in pairs( Entities ) do
		for _, V in pairs( self.Killable_Killstreaks ) do
			local Active_Killstreaks = ents.FindByClass( V )
			for _, Value in pairs( Active_Killstreaks ) do
				if Value:IsNPC() and Value:GetClass() == "npc_bullseye" then
					Value:Fire( "kill", "", 0 )
				else
					Value:Destroy()
				end
			end
		end

		if v:IsPlayer() and v != self.Owner then
			SlowDownPlayers( v )
			FRAGS = FRAGS + 1
			-- FIX: v:GetNetworkedBool -> v:GetNWBool
		elseif v:IsPlayer() and v == self.Owner and v:GetNWBool( "MW2NukeEffectOwner" ) then
			SlowDownPlayers( v )
			FRAGS = FRAGS + 1
		elseif v:IsNPC() and v:GetClass() != "npc_bullseye" then
			if v:GetClass() != "npc_strider" and v:GetClass() != "bullseye_strider_focus"
				and v:GetClass() != "npc_rollermine" and v:GetClass() != "npc_turret_floor" then
				timer.Simple( 5, function()
					if IsValid( v ) then
						TurnIntoRagdoll( v )
					end
				end )
			else
				v:Fire( "Break", "", 0 )
			end
		end
		FRAGS = FRAGS + 1
	end

	if IsValid( self.Owner ) then
		self.Owner:AddFrags( FRAGS )
	end
end


function SLOW_PLAYER_MOVEMENT( PLAYER, MOVEMENT )
	MOVEMENT:SetVelocity( PLAYER:GetVelocity() / 2 )
end


function SlowDownPlayers( pl )
	hook.Add( "Move", "SLOW_PLAYER_MOVEMENT", function( PLY, DATA )
		SLOW_PLAYER_MOVEMENT( PLY, DATA )
	end )
	-- Note: pp_bloom_* global assignments below are server-side no-ops (client-only vars)
	-- Kept as-is since they are harmless; client-side effects handled via cl_init
	timer.Simple( 0.3,  function() pp_bloom_darken=0; pp_bloom_multiply=0.1; pp_bloom=1 end )
	timer.Simple( 0.5,  function() pp_bloom_multiply=0.2; pp_bloom=1 end )
	timer.Simple( 0.7,  function() pp_bloom_multiply=0.3; pp_bloom=1 end )
	timer.Simple( 0.9,  function() pp_bloom_multiply=0.4; pp_bloom=1 end )
	timer.Simple( 0.11, function() pp_bloom_multiply=0.5; pp_bloom=1 end )
	timer.Simple( 0.13, function() pp_bloom_multiply=0.6; pp_bloom=1 end )
	timer.Simple( 0.15, function() pp_bloom_multiply=0.7; pp_bloom=1 end )
	timer.Simple( 0.17, function() pp_bloom_multiply=0.8; pp_bloom=1 end )
	timer.Simple( 0.19, function() pp_bloom_multiply=1.0; pp_bloom=1 end )
	timer.Simple( 5, function()
		hook.Remove( "Move", "SLOW_PLAYER_MOVEMENT" )
		if IsValid( pl ) then pl:Kill() end
	end )
	timer.Simple( 10, function() pp_bloom=0 end )
end


function TurnIntoRagdoll( NPC )
	if IsValid( NPC ) then
		timer.Simple( 5, function()
			local tempRag = ents.Create( "prop_ragdoll" )
			tempRag:SetModel( NPC:GetModel() )
			tempRag:SetPos( NPC:GetPos() )
			NPC:Remove()
			tempRag:Spawn()
		end )
	end
end


function ENT:findGround()
	local filterList = {}
	local trace = {
		start  = Vector( 0, 0, 0 ),
		endpos = Vector( 0, 0, -16384 ),
		filter = filterList
	}
	local bool           = true
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
			MsgN( "[MW2 Killstreaks] NukeSystem findGround: max iterations reached" )
			bool = false
		end
	end
	return groundLocation
end
