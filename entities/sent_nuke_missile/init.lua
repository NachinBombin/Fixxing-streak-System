AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

local sndThrustLoop = Sound( "Missile.Accelerate" )
local sndStop       = Sound( "ambient/_period.wav" )

local function Arm( EntTable )
	EntTable.Armed = true
	-- FIX: self.Entity:SetNWBool -> self:SetNWBool
	EntTable:SetNWBool( "armed", true )
	EntTable.PhysObj:EnableGravity( false )
	EntTable:SpawnTrail()
	EntTable:StartSounds()
end


function ENT:Initialize()
	-- FIX: self.Entity:SetModel/PhysicsInit/SetMoveType/SetSolid -> self:XXX
	self:SetModel( "models/Weapons/W_missile_closed.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	-- FIX: self.Entity:GetPhysicsObject -> self:GetPhysicsObject
	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed; set by spawner
	self.EmittingSound = false
	self.NextUse       = 0
	self.Armed         = false
	self:SetNWBool( "armed", false )

	timer.Simple( 0.5, function() Arm( self ) end )
end


function ENT:PhysicsCollide( data, physobj )
	if self.Armed and data.Speed > 50 and data.DeltaTime > 0.15 then
		local nuke = ents.Create( "sent_nuke" )
		-- FIX: self.Entity:GetPos -> self:GetPos
		nuke:SetPos( self:GetPos() )
		-- FIX: nuke:SetVar('owner') dead API -> direct assign
		nuke.Owner = self.Owner
		nuke:Spawn()
		nuke:Activate()
		self:StopSounds()
		-- FIX: self.Entity:Remove -> self:Remove
		self:Remove()
	end
end


function ENT:OnTakeDamage( dmginfo )
	-- FIX: self.Entity:TakePhysicsDamage -> self:TakePhysicsDamage
	self:TakePhysicsDamage( dmginfo )
end


function ENT:Use( activator, caller )
	if self.NextUse > CurTime() then return end
	if self.Armed then
		self.Armed = false
		self.PhysObj:EnableGravity( true )
		self:SetNWBool( "armed", false )
		if IsValid( self.Trail ) then self.Trail:Remove() end
		self:StopSounds()
	else
		Arm( self )
		self.Owner = activator
	end
	self.NextUse = CurTime() + 0.3
end


function ENT:Think()
	if self.Armed then
		-- FIX: self.Entity:GetForward -> self:GetForward
		self.PhysObj:SetVelocity( self:GetForward() * 900 )

		if IsValid( self.Trail ) then
			-- FIX: self.Entity:GetPos/GetForward -> self:XXX
			self.Trail:SetPos( self:GetPos() - 16 * self:GetForward() )
			self.Trail:SetLocalAngles( Angle( 0, 0, 0 ) )
		else
			self:SpawnTrail()
		end

		self:StartSounds()
	end
end


function ENT:OnRemove()
	self:StopSounds()
end


function ENT:StartSounds()
	if not self.EmittingSound then
		-- FIX: self.Entity:EmitSound -> self:EmitSound
		self:EmitSound( sndThrustLoop )
		self.EmittingSound = true
	end
end


function ENT:StopSounds()
	if self.EmittingSound then
		-- FIX: self.Entity:StopSound/EmitSound -> self:XXX
		self:StopSound( sndThrustLoop )
		self:EmitSound( sndStop )
		self.EmittingSound = false
	end
end


function ENT:SpawnTrail()
	self.Trail = ents.Create( "env_rockettrail" )
	-- FIX: self.Entity:GetPos/GetForward -> self:XXX
	self.Trail:SetPos( self:GetPos() - 16 * self:GetForward() )
	-- FIX: self.Trail:SetParent(self.Entity) -> self
	self.Trail:SetParent( self )
	self.Trail:SetLocalAngles( Angle( 0, 0, 0 ) )
	self.Trail:Spawn()
end
