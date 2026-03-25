
local ModelExsists			= file.Exists("models/weapons/v_slam.mdl","GAME")
if ( CLIENT ) then
	SWEP.Author				= "Death dealer142"
	SWEP.Purpose			= ""
	SWEP.Instructions		= ""
	SWEP.Category			= "Modern Warfare 2 - Killstreaks"
	SWEP.Slot				= 0
	SWEP.SlotPos			= 5
	
end

SWEP.UseLaptop = false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false
SWEP.DrawAmmo			= false

SWEP.AutoSwitchTo		= true;

SWEP.Primary.ClipSize		= -1					// Size of a clip
SWEP.Primary.DefaultClip	= 1					// Default number of bullets in a clip
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay 		= 0

SWEP.Secondary.ClipSize		= -1					// Size of a clip
SWEP.Secondary.DefaultClip	= -1					// Default number of bullets in a clip
SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto
SWEP.Secondary.Ammo		= "none"

SWEP.CallOnce = true;

SWEP.CalledIn = false;

SWEP.Ent = "";

SWEP.drawTime = 0;
SWEP.drawBool = true;
SWEP.detonateTime = 0;
SWEP.detonateBool = false;
SWEP.holsterTime = 0;
SWEP.holsterBool = false;
SWEP.drawSequence = nil;
SWEP.detonateSequence = nil;
SWEP.holsterSequence = nil;
SWEP.DelaySound = false;

function SWEP:Initialize()	
	if ModelExsists && !self.UseLaptop then
		self.ViewModelFlip		= true
		self.ViewModel			= "models/weapons/v_slam.mdl"
		self.WorldModel			= "models/weapons/w_slam.mdl"
	elseif self.UseLaptop then
		self.ViewModelFlip		= false
		self.ViewModel			= "models/deathdealer142/laptop/v_laptop.mdl"
	end
end
--[[
function SWEP:Equip(NewOwner)
	NewOwner:SelectWeapon(self:GetClass())	
end]]

/*---------------------------------------------------------
   Name: SWEP:Deploy()
   Desc: Cause the weapon that starts the killstreak to go through its animations
---------------------------------------------------------*/
function SWEP:Deploy()		
	self.Owner:SetNetworkedString("UsedKillStreak", "")
	
	self.FromCare = self.Owner:GetNetworkedBool("IsKillStreakFromCarePackage",false)
	self.Owner:SetNetworkedBool("IsKillStreakFromCarePackage",false)
	
	if canUsePred != self:GetClass() then -- this is to check if the player is an admin and used the weapon from the weapon menu
		self.FromCare = true;
	end
	
	if self.UseLaptop then		
		
		self.drawSequence = self:LookupSequence("open")
		self.holsterSequence = self:LookupSequence("close")
		self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
		self.drawTime = self:SequenceDuration() + CurTime();
		
		self:PlaySound()
		
	else
		if ModelExsists then
			self.drawSequence = self:LookupSequence("detonator_draw")
			self.detonateSequence = self:LookupSequence("detonator_detonate")
			self.holsterSequence = self:LookupSequence("detonator_holster")

			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
			self.drawTime = self:SequenceDuration() + CurTime();
			if !self.DelaySound  then
				self:PlaySound();
			end
		else
			if self.CallOnce then
				self:Run();
				--timer.Simple(1, self.Run, self);				
				self.CalledIn = true;
				if SERVER and !self.DelaySound  then
					self:PlaySound();
				end
				--timer.Simple(1, self.Run, self)
				self:Holster();
				self.CallOnce = false;			
			end
		end
	end
	return true;
end

function SWEP:Think()
	if self.UseLaptop then
		if self:GetSequence() == self.drawSequence && CurTime() > self.drawTime && self.drawBool then
			self.drawBool = false;
			self:Run();
			if !self.DelaySound  then
				self:PlaySound();
			end
		elseif self.CalledIn && !self.holsterBool then
			self.Weapon:SendWeaponAnim(ACT_VM_HOLSTER)
			self.holsterTime = self:SequenceDuration( ) + CurTime();
			self.holsterBool = true;	
		elseif self:GetSequence() == self.holsterSequence && CurTime() > self.holsterTime && self.holsterBool then			
			self:Holster();			
		end
	else
		if ModelExsists then
			if self:GetSequence() == self.drawSequence && CurTime() > self.drawTime && self.drawBool then
				self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
				self.detonateTime = self:SequenceDuration( ) + CurTime();
				self.drawBool = false;
				self.detonateBool = true;			
				self:Run();
				self.CalledIn = true;
			elseif self:GetSequence() == self.detonateSequence && CurTime() > self.detonateTime && self.detonateBool then
				self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_HOLSTER)
				self.holsterTime = self:SequenceDuration( ) + CurTime();
				self.detonateBool = false;
				self.holsterBool = true;		
			elseif self:GetSequence() == self.holsterSequence && CurTime() > self.holsterTime && self.holsterBool then			
				self:Holster();			
			end
		end
	end
end

function SWEP:Holster()
	if SERVER then
		self.Owner:StripWeapon(self:GetClass());
	end
	return true
end

function SWEP:Run()
	if CLIENT then return end
	local ent = ents.Create(self.Ent)
	ent:SetVar("owner",self.Owner)
	ent:SetVar("Weapon",self)
	ent.Wep = self
	ent:SetVar("FromCarePackage", self.FromCare)
	ent:Spawn()
	ent:Activate()
end

function SWEP:PlaySound()
	
	
	if CLIENT then return end
	
	
	if not IsValid(self.Owner) then return end

	
	if self.UseLaptop == true and self.CalledIn == false then	//	CHECK TO SEE IF THE KILLSTREAK USES THE LAPTOP *AND* THAT IT IS *NOT* BEING CLOSED. IF THIS IS TRUE, THEN
	
	
		EmitSound( Sound( "killstreak_rewards/harrier_laptop.wav" ), self.Owner:GetPos(), self.Owner:EntIndex() )  //  WHEN THE LAPTOP IS OPENED (IMPLEMENTED IN THE ABOVE FUNCTIONS), PLAY THE SOUND OF IT BEING OPENED

	
/*	THIS CODE BLOCK HAS BEEN DISABLED	-	BUGGY AND WILL CAUSE CONFLICTS
	
	
	umsg.Start("playWeaponInboundSound", self.Owner);
		umsg.String(self:GetClass().."")
	umsg.End()

	
*/


	end

	
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CallIn()
	self.CalledIn = true;
end