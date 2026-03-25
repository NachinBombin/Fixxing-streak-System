include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

if SERVER then
	util.AddNetworkString( "MW2_AIRSTRIKE_FRIENDLY" )
	util.AddNetworkString( "MW2_AIRSTRIKE_ENEMY" )
end

ENT.findHoverZone    = true
ENT.Model            = "models/dav0r/camera.mdl"
ENT.jet1Alive        = false
ENT.jet2Alive        = false
ENT.jet3Alive        = false
ENT.spawnJet2        = false
ENT.spawnJet3        = false
-- FIX: ENT.SpawnDelay = CurTime() at table-def scope (stale) -> 0
ENT.SpawnDelay       = 0
ENT.playOnce         = true
ENT.WallLoc          = NULL
ENT.restrictMovement = true


local function Check_Status( Owner )
	-- FIX: guard against nil/invalid Owner
	if not IsValid( Owner ) then return 0 end
	return Owner:Alive() and 1 or 0
end


function ENT:Think()
	self:NextThink( CurTime() + 0.1 )

	local Status = Check_Status( self.Owner )

	if Status == 1 then
		if self.DropLoc == nil or self.DropAng == nil then return true end

		if self.findHoverZone then
			self.DropLoc       = self.DropLoc - Vector( 0, 0, 100 )
			self.findHoverZone = false
			self.WallLoc       = self:FindWall()
			self.FlyAng        = self.DropAng

			GAMEMODE:SetPlayerSpeed( self.Owner, self.playerSpeeds[1], self.playerSpeeds[2] )

			if IsValid( self.Wep ) then
				self.Wep:CallIn()
				self:CALL_AIRSTRIKE()
			end

			self.jet1Alive = true
			-- FIX: SetVar('JetDropZone'/'WallLocation'/'FlyAngle') dead API -> SetNWVector/SetNWAngle
			self.Jet1:SetNWVector( "JetDropZone",  self:FindDropZone1() )
			self.Jet1:SetNWVector( "WallLocation", self.WallLoc )
			self.Jet1:SetNWAngle(  "FlyAngle",     self.FlyAng )
			-- FIX: self:GetVar('FromCarePackage') -> GetNWBool
			self.Jet1:SetNWBool(   "FromCarePackage", self:GetNWBool( "FromCarePackage", false ) )
			self.Jet1:Spawn()
			self.Jet1:Activate()
			self.SpawnDelay = CurTime() + 2
		end

		if not self.findHoverZone and self.playOnce then
			if IsValid( self.Wep ) then self.Wep:PlaySound() end
			self.playOnce = false
		end

		if self.SpawnDelay <= CurTime() and self.jet1Alive then
			self.jet1Alive = false
			self.jet2Alive = true
			self.Jet2:SetNWVector( "JetDropZone",  self.DropLoc )
			self.Jet2:SetNWVector( "WallLocation", self.WallLoc )
			self.Jet2:SetNWAngle(  "FlyAngle",     self.FlyAng )
			self.Jet2:SetNWBool(   "FromCarePackage", self:GetNWBool( "FromCarePackage", false ) )
			self.Jet2:Spawn()
			self.Jet2:Activate()
			self.SpawnDelay = CurTime() + 2
		elseif self.SpawnDelay <= CurTime() and self.jet2Alive then
			self.jet2Alive = false
			self.Jet3:SetNWVector( "JetDropZone",  self:FindDropZone3() )
			self.Jet3:SetNWVector( "WallLocation", self.WallLoc )
			self.Jet3:SetNWAngle(  "FlyAngle",     self.FlyAng )
			self.Jet3:SetNWBool(   "FromCarePackage", self:GetNWBool( "FromCarePackage", false ) )
			self.Jet3:Spawn()
			self.Jet3:Activate()
			self:Remove()
		end
	else
		self:Remove()
	end

	return true
end


function ENT:MW2_Init()
	self:SetColor( Color( 255, 255, 255, 0 ) )
	self.PhysObj:EnableGravity( false )
	self:SetNotSolid( true )
	self:SetPos( Vector( 0, 0, 0 ) )

	-- FIX: Jet1/2/3:SetVar('owner') dead API -> direct .Owner assign
	self.Jet1 = ents.Create( "sent_jet" )
	self.Jet1.Owner = self.Owner

	self.Jet2 = ents.Create( "sent_jet" )
	self.Jet2.Owner = self.Owner

	self.Jet3 = ents.Create( "sent_jet" )
	self.Jet3.Owner = self.Owner

	-- FIX: self.Owner = self:GetVar('owner') in MW2_Init dead API -> removed
	self:OpenOverlayMap( true )
end


function ENT:CALL_AIRSTRIKE()
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
			net.Start( "MW2_AIRSTRIKE_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_AIRSTRIKE_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:OnTakeDamage( dmginfo )
	-- FIX: self.Entity:TakePhysicsDamage -> self:TakePhysicsDamage
	self:TakePhysicsDamage( dmginfo )
end


function ENT:FindWall()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * -100000, self ).HitPos
end

function ENT:FindDropZone1()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * -350, self ).HitPos
end

function ENT:FindDropZone3()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * 350, self ).HitPos
end
