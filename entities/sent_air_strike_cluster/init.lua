AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

ENT.FireOnce = true


function ENT:Freeze()
	-- FIX: self.Entity:SetMoveType -> self:SetMoveType
	self:SetMoveType( MOVETYPE_NONE )
end


function ENT:Explode()
	local Ent = ents.Create( "prop_combine_ball" )
	-- FIX: self.Entity:GetPos -> self:GetPos
	Ent:SetPos( self:GetPos() )
	Ent:Spawn()
	Ent:Activate()
	Ent:EmitSound( "ambient/explosions/explode_3.wav" )
	Ent:Fire( "explode", "", 0 )

	for i = 1, 8 do
		local bomblet = ents.Create( "sent_bomblet" )
		bomblet:SetPos( self:GetPos() )
		-- FIX: bomblet:SetVar('owner'/'FromCarePackage') dead API -> direct table assign
		bomblet.Owner           = self.Owner
		bomblet.FromCarePackage = self:GetNWBool( "FromCarePackage", false )
		bomblet:Spawn()

		local Phys = bomblet:GetPhysicsObject()
		if Phys:IsValid() then
			Phys:Wake()
			Phys:ApplyForceCenter(
				Vector( math.random( 5 - 40, 40 ), math.random( 5 - 40, 40 ), math.random( 5 - 40, 40 ) ) * Phys:GetMass()
			)
		end
	end

	-- FIX: self.Entity:Remove -> self:Remove()
	self:Remove()
end


function ENT:Think()
	-- FIX: self:GetVar('HasBeenDropped') dead API -> self.HasBeenDropped (set directly by jet)
	if self.HasBeenDropped and self.FireOnce then
		timer.Simple( 1.5, function() if IsValid( self ) then self:Explode() end end )
		self.FireOnce = false
	end
end


function ENT:Initialize()
	-- FIX: self.Entity:SetModel/PhysicsInit/SetMoveType/SetSolid/GetPhysicsObject -> self:XXX
	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed (set by jet spawner)
	self:SetModel( "models/military2/bomb/bomb_jdam.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.FireOnce = true
	self.PhysObj  = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end
end
