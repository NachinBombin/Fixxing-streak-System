AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.Model            = "models/dav0r/camera.mdl"
ENT.findHoverZone    = true
ENT.jet1Alive        = false
ENT.jet2Alive        = false
ENT.jet3Alive        = false
ENT.spawnJet2        = false
ENT.spawnJet3        = false
-- FIX: ENT.SpawnDelay = CurTime() at table-def scope (stale) -> 0
ENT.SpawnDelay       = 0
ENT.playOnce         = true
ENT.restrictMovement = true


local function Check_Status( Owner )
	if not IsValid( Owner ) then return 0 end
	return Owner:Alive() and 1 or 0
end


function ENT:Think()
	self:NextThink( CurTime() + 0.1 )

	local Status = Check_Status( self.Owner )

	if Status == 1 then
		if self.DropLoc == nil then return true end

		if self.findHoverZone then
			self.findHoverZone = false
			GAMEMODE:SetPlayerSpeed( self.Owner, self.playerSpeeds[1], self.playerSpeeds[2] )
			if IsValid( self.Wep ) then self.Wep:CallIn() end

			self.jet1Alive = true
			-- FIX: SetVar('JetDropZone') dead API -> SetNWVector
			self.Jet1.Owner = self.Owner
			self.Jet1:SetNWVector( "JetDropZone", self.DropLoc )
			-- FIX: SetVar('FromCarePackage') -> SetNWBool
			self.Jet1:SetNWBool( "FromCarePackage", self:GetNWBool( "FromCarePackage", false ) )
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
			self.Jet2.Owner = self.Owner
			self.Jet2:SetNWVector( "JetDropZone", self.DropLoc )
			self.Jet2:SetNWBool( "FromCarePackage", self:GetNWBool( "FromCarePackage", false ) )
			self.Jet2:Spawn()
			self.Jet2:Activate()
			self.SpawnDelay = CurTime() + 2
		elseif self.SpawnDelay <= CurTime() and self.jet2Alive then
			self.jet2Alive = false
			self.Harrier.Owner = self.Owner
			self.Harrier:SetNWVector( "HarrierHoverZone", self.DropLoc )
			self.Harrier:SetNWBool( "FromCarePackage", self:GetNWBool( "FromCarePackage", false ) )
			self.Harrier:Spawn()
			self.Harrier:Activate()
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

	-- FIX: Jet1/Jet2/Harrier:SetVar('owner') dead API -> direct .Owner assign
	self.Jet1 = ents.Create( "sent_jet" )
	self.Jet1.Owner = self.Owner

	self.Jet2 = ents.Create( "sent_jet" )
	self.Jet2.Owner = self.Owner

	self.Harrier = ents.Create( "sent_harrier" )
	self.Harrier.Owner = self.Owner

	self:OpenOverlayMap( false )
end
