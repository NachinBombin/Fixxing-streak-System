AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Think()
	if self:WaterLevel() > 0 then
		self:Explode()
	end
end

function ENT:Freeze()
	self.Entity:SetMoveType(MOVETYPE_NONE)
end

function ENT:Explode()

	util.BlastDamage(self, self.Owner, self:GetPos(), 500, 100)
	local ParticleExplode = ents.Create("info_particle_system")
	ParticleExplode:SetPos(self:GetPos())
	ParticleExplode:SetKeyValue("effect_name", "cluster_explode")
	ParticleExplode:SetKeyValue("start_active", "1")
	ParticleExplode:Spawn()
	ParticleExplode:Activate()
	ParticleExplode:Fire("kill", "", 20) -- Be sure to leave this at 20, or else the explosion may not be fully rendered because 2/3 of the effects have smoke that stays for a while.
	
	
	self:EmitSound( "weapons/explode3.wav", 200 )
	
	
	timer.Simple( 1, function()  //  CREATE A "SIMPLE" TIMER THAT LASTS FOR "1" SECOND TO ALLOW *SAFE REMOVAL* OF THE ENTITY
	
		
		if self:IsValid() == true then  //  CHECK:	IF ( AFTER "1" SECOND ), THE ENTITY IS STILL VALID ( ALIVE ), THEN...
		

			self:Remove()	//  REMOVE THE ENTITY


		end  //  FINISH THE CHECK


	end )  //  FINISH THE TIMER
	
	
end

function ENT:PhysicsCollide( data, physobj )
    if data.Speed > 1 and data.DeltaTime > 0.1 && data.HitEntity:GetClass() != self:GetClass() then -- if it hits an object at over 1 speed
		self:Explode()	    
	end
end

function ENT:Initialize()
	self.Entity:SetModel("models/items/ar2_grenade.mdl")
	self.Entity:SetColor(Color(50, 50, 50, 255))
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Owner = self:GetVar("owner",Entity(1))	
	
	local Phys = self.Entity:GetPhysicsObject()
	if Phys:IsValid() then
		Phys:Wake()
	end
	
	self.PhysgunDisabled = true
end