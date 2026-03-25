if ( CLIENT ) then
	SWEP.Author       = "Death dealer142"
	SWEP.Purpose      = ""
	SWEP.Instructions = ""
	SWEP.PrintName    = "Tactical Nuke"
	SWEP.Slot         = 5
	SWEP.SlotPos      = 5
end

if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.ViewModelFlip = true
SWEP.ViewModel     = "models/weapons/v_pistol.mdl"
SWEP.WorldModel    = "models/weapons/w_pistol.mdl"

SWEP.Spawnable      = false
SWEP.AdminSpawnable = true
SWEP.DrawAmmo       = false
SWEP.AutoSwitchTo   = true

SWEP.Primary.Recoil      = 0
SWEP.Primary.Damage      = 0
SWEP.Primary.NumShots    = 1
SWEP.Primary.Cone        = 0.075
SWEP.Primary.Delay       = 1
SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.Delay       = 0
SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"


function SWEP:Equip( NewOwner )
	NewOwner:SelectWeapon( self:GetClass() )
end

function SWEP:Deploy()
	local canUseNuke = self.Owner:GetNWString( "UsedKillStreak", "" )
	if canUseNuke != "Tactical_Nuke" then
		self.Owner:StripWeapon( self:GetClass() )
		return
	end
	self.Owner:SetNWString( "UsedKillStreak", "" )
	self:Run()
	self:Holster()
	return true
end

function SWEP:Holster()
	if self != nil and self.Owner:HasWeapon( self:GetClass() ) then
		self.Owner:StripWeapon( self:GetClass() )
	end
end

function SWEP:Run()
	local nuke = ents.Create( "sent_tactical_nuke_system" )
	-- FIX: nuke:SetVar('owner') dead API -> direct field assign BEFORE Spawn
	-- so that Initialize() -> SEND_NUKE() can read self.Owner safely
	nuke.Owner = self.Owner
	nuke:Spawn()
	nuke:Activate()
end

function SWEP:PrimaryAttack()   end
function SWEP:SecondaryAttack() end
