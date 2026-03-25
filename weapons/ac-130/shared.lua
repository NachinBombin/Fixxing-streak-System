game.AddParticles("particles/mw2_explodonates.pcf")

--PrecacheParticleSystem("mw2_explodonates")
if ( CLIENT ) then
	SWEP.PrintName			= "AC-130"
end

SWEP.UseLaptop = true;
SWEP.Base 				= "mw2_killstreak_wep_base"
SWEP.AdminSpawnable		= true
SWEP.Ent = "sent_ac-130"

