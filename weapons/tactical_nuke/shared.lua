if ( CLIENT ) then
	SWEP.Author				= "Death dealer142"
	SWEP.Purpose			= ""
	SWEP.Instructions		= ""
	SWEP.PrintName			= "Tactical Nuke"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 5	
end

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end


SWEP.ViewModelFlip		= true
SWEP.ViewModel			= "models/weapons/v_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true
SWEP.DrawAmmo			= false

SWEP.AutoSwitchTo		= true;

SWEP.Primary.Recoil		= 0
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.075
SWEP.Primary.Delay 		= 1

SWEP.Primary.ClipSize		= -1					// Size of a clip
SWEP.Primary.DefaultClip	= 1					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay 		= 0

SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"

/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Whip it out.
---------------------------------------------------------*/
function SWEP:Equip(NewOwner)
	NewOwner:SelectWeapon(self:GetClass())	
end

function SWEP:Deploy()	

	canUseNuke = self.Owner:GetNetworkedString("UsedKillStreak")
	if canUseNuke != "Tactical_Nuke" then
		self.Owner:StripWeapon(self:GetClass());
		return;
	end;
	self.Owner:SetNetworkedString("UsedKillStreak", "")

	self:Run();
	self:Holster();
	return true;
end

function SWEP:Holster()
	if self != nil && self.Owner:HasWeapon(self:GetClass()) then
		self.Owner:StripWeapon(self:GetClass());
	end
end

function SWEP:Run()
	self.Nuke = ents.Create("sent_tactical_nuke_system")
	self.Nuke:SetVar("owner",self.Owner)	
	self.Nuke:Spawn()

	self.Nuke:Activate()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end