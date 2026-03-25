include( "shared.lua" )

ENT.Model = Model( "models/deathdealer142/supply_crate/supply_crate.mdl" )

function ENT:SpawnFunction( ply, tr )
	if not tr.Hit then return end
	local ent = ents.Create( self.Classname )
	ent:SetPos( tr.HitPos + tr.HitNormal * 16 )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	-- FIX: self.Owner = self:GetVar('owner') dead API -> removed (set by parent)
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end
	self:OpenOverlayMap( true )
end
