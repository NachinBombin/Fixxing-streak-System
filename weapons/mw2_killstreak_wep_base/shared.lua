local ModelExists = file.Exists( "models/weapons/v_slam.mdl", "GAME" )

if CLIENT then
	SWEP.Author       = "Death dealer142"
	SWEP.Purpose      = ""
	SWEP.Instructions = ""
	SWEP.Category     = "Modern Warfare 2 - Killstreaks"
	SWEP.Slot         = 0
	SWEP.SlotPos      = 5
end

SWEP.UseLaptop = false

SWEP.Spawnable      = false
SWEP.AdminSpawnable = false
SWEP.DrawAmmo       = false
SWEP.AutoSwitchTo   = true

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.Delay       = 0
SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"

SWEP.CallOnce          = true
SWEP.CalledIn          = false
SWEP.Ent               = ""
SWEP.drawTime          = 0
SWEP.drawBool          = true
SWEP.detonateTime      = 0
SWEP.detonateBool      = false
SWEP.holsterTime       = 0
SWEP.holsterBool       = false
SWEP.drawSequence      = nil
SWEP.detonateSequence  = nil
SWEP.holsterSequence   = nil
SWEP.DelaySound        = false


function SWEP:Initialize()
	if ModelExists and not self.UseLaptop then
		self.ViewModelFlip = true
		self.ViewModel     = "models/weapons/v_slam.mdl"
		self.WorldModel    = "models/weapons/w_slam.mdl"
	elseif self.UseLaptop then
		self.ViewModelFlip = false
		self.ViewModel     = "models/deathdealer142/laptop/v_laptop.mdl"
	end
end


function SWEP:Deploy()
	-- FIX: SetNetworkedString/Bool -> SetNWString/SetNWBool (removed in modern GMod)
	self.Owner:SetNWString( "UsedKillStreak", "" )

	-- FIX: GetNetworkedBool -> GetNWBool
	self.FromCare = self.Owner:GetNWBool( "IsKillStreakFromCarePackage", false )
	self.Owner:SetNWBool( "IsKillStreakFromCarePackage", false )

	-- FIX: `canUsePred` was an undefined global (always nil), making FromCare
	-- permanently true. Now correctly checks if this weapon was given via Give()
	-- by the killstreak system (UsedKillStreak NW var) vs. spawned from weapon menu.
	if self.Owner:GetNWString( "UsedKillStreak", "" ) != self:GetClass() then
		self.FromCare = true
	end

	if self.UseLaptop then
		self.drawSequence   = self:LookupSequence( "open" )
		self.holsterSequence = self:LookupSequence( "close" )
		self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
		self.drawTime = self:SequenceDuration() + CurTime()
		self:PlaySound()
	else
		if ModelExists then
			self.drawSequence     = self:LookupSequence( "detonator_draw" )
			self.detonateSequence = self:LookupSequence( "detonator_detonate" )
			self.holsterSequence  = self:LookupSequence( "detonator_holster" )
			self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_DRAW )
			self.drawTime = self:SequenceDuration() + CurTime()
			if not self.DelaySound then
				self:PlaySound()
			end
		else
			if self.CallOnce then
				self:Run()
				self.CalledIn = true
				if SERVER and not self.DelaySound then
					self:PlaySound()
				end
				self:Holster()
				self.CallOnce = false
			end
		end
	end
	return true
end


function SWEP:Think()
	if self.UseLaptop then
		if self:GetSequence() == self.drawSequence and CurTime() > self.drawTime and self.drawBool then
			self.drawBool = false
			self:Run()
			if not self.DelaySound then
				self:PlaySound()
			end
		elseif self.CalledIn and not self.holsterBool then
			self.Weapon:SendWeaponAnim( ACT_VM_HOLSTER )
			self.holsterTime = self:SequenceDuration() + CurTime()
			self.holsterBool = true
		elseif self:GetSequence() == self.holsterSequence and CurTime() > self.holsterTime and self.holsterBool then
			self:Holster()
		end
	else
		if ModelExists then
			if self:GetSequence() == self.drawSequence and CurTime() > self.drawTime and self.drawBool then
				self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_DETONATE )
				self.detonateTime = self:SequenceDuration() + CurTime()
				self.drawBool     = false
				self.detonateBool = true
				self:Run()
				self.CalledIn = true
			elseif self:GetSequence() == self.detonateSequence and CurTime() > self.detonateTime and self.detonateBool then
				self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_HOLSTER )
				self.holsterTime  = self:SequenceDuration() + CurTime()
				self.detonateBool = false
				self.holsterBool  = true
			elseif self:GetSequence() == self.holsterSequence and CurTime() > self.holsterTime and self.holsterBool then
				self:Holster()
			end
		end
	end
end


function SWEP:Holster()
	if SERVER then
		self.Owner:StripWeapon( self:GetClass() )
	end
	return true
end


function SWEP:Run()
	if CLIENT then return end

	local ent = ents.Create( self.Ent )
	-- FIX: SetVar/GetVar are datastream-era API, removed in modern GMod.
	-- The SENT base reads self.Owner and self.Wep directly off the entity table,
	-- so we assign them directly. SetNWString used for FromCarePackage so
	-- the SENT can read it cross-realm if needed.
	ent.Owner = self.Owner
	ent.Wep   = self
	ent:SetNWBool( "FromCarePackage", self.FromCare or false )
	ent:Spawn()
	ent:Activate()
end


function SWEP:PlaySound()
	if CLIENT then return end
	if not IsValid( self.Owner ) then return end

	if self.UseLaptop and not self.CalledIn then
		EmitSound(
			Sound( "killstreak_rewards/harrier_laptop.wav" ),
			self.Owner:GetPos(),
			self.Owner:EntIndex()
		)
	end
end


function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CallIn()
	self.CalledIn = true
end
