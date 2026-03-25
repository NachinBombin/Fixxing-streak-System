include( "shared.lua" )
AddCSLuaFile( "shared.lua" )

ENT.SpawnEffectsOnce = false
ENT.Smoke            = nil

function ENT:Initialize()
	self:SetModel( "models/Items/grenadeAmmo.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end
	self.Smoke = ents.Create( "info_particle_system" )
end


game.AddParticles( "particles/carepackagemarker.pcf" )

function ENT:PhysicsCollide( data, physobj )
	if not self.SpawnEffectsOnce then
		self.SpawnEffectsOnce = true
		self.Smoke:SetKeyValue( "effect_name",  "Smoke" )
		self.Smoke:SetKeyValue( "start_active", "1" )
		self.Smoke:SetPos( self:GetPos() )
		self.Smoke:Spawn()
		self.Smoke:Activate()
		self.Smoke:Fire( "kill", "", 12 )

		local dropType = self.DropType or self:GetNWString( "DropType", "sent_CarePackage" )
		if dropType == "sent_CarePackage" then
			self:PlaySound( "care_package" )
		elseif dropType == "Sentry_Gun" then
			self:PlaySound( "mw2_sentry_gun" )
		else
			self:PlaySound( "emergency_airdrop" )
		end

		timer.Simple( 2,  function() if IsValid( self ) then self:StartDrop() end end )
		timer.Simple( 12, function() if IsValid( self ) then self:Remove()    end end )
	end
	if IsValid( self.Smoke ) then
		self.Smoke:SetPos( self:GetPos() )
	end
end


function ENT:StartDrop()
	self.DropType = self.DropType or self:GetNWString( "DropType", "sent_CarePackage" )
	local ent
	if self.DropType == "Sentry_Gun" then
		ent = ents.Create( "sent_CarePackage" )
		ent:SetNWBool( "IsSentry", true )
	else
		ent = ents.Create( self.DropType )
	end
	-- FIX: was setting ent:SetNWVector('PackageDropZone') AFTER Spawn,
	-- but sent_carepackage/Initialize reads self.dropPos synchronously.
	-- Set as direct field BEFORE Spawn so it is available immediately.
	ent.Owner   = self.Owner
	ent.dropPos = self:GetPos()
	ent:Spawn()
	ent:Activate()
end


function ENT:PlaySound( soundName )
	-- no-op: sounds handled client-side
end
