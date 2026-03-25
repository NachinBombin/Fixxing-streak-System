if SERVER then
	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType = "shotgun"
end

if CLIENT then
	SWEP.PrintName = "Stinger"
	SWEP.Author    = "Death dealer142"
	SWEP.Slot      = 4
	SWEP.SlotPos   = 7
end

SWEP.Author       = "Death dealer142"
SWEP.Contact      = ""
SWEP.Purpose      = "Destroy stuff"
SWEP.Instructions = "Hold secondary fire until lock, then fire"
SWEP.Spawnable      = false
SWEP.AdminSpawnable = true

SWEP.ViewModel  = "models/weapons/v_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.Delay        = 0.9
SWEP.Primary.Recoil       = 0
SWEP.Primary.Damage       = 15
SWEP.Primary.NumShots     = 1
SWEP.Primary.Cone         = 0
SWEP.Primary.ClipSize     = 1
SWEP.Primary.DefaultClip  = 2
SWEP.Primary.Automatic    = false
SWEP.Primary.Ammo         = "rpg_round"

SWEP.Secondary.Delay       = 0.9
SWEP.Secondary.Recoil      = 0
SWEP.Secondary.Damage      = 0
SWEP.Secondary.NumShots    = 1
SWEP.Secondary.Cone        = 0
SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

SWEP.Target        = SWEP.Target or NULL
SWEP.Missile       = SWEP.Missile or NULL
SWEP.TempTarget    = NULL
SWEP.LockTime      = 0
SWEP.LockCount     = 0
SWEP.DidExplosion  = false
SWEP.CanFireMissile = true
SWEP.LastTarget    = NULL


function SWEP:Initialize()
	-- FIX: SetNetworkedBool removed in modern GMod -> SetNWBool
	self.Owner:SetNWBool( "TargetLock", false )
end


function SWEP:Think()
	-- FIX: !(SERVER) pattern normalized; CLIENT guard is cleaner
	if CLIENT then return end

	if self.Owner:KeyDown( IN_ATTACK2 ) and self.Missile == NULL and self.Target == NULL then
		local trace = self.Owner:GetEyeTrace()
		if self.Target == NULL and trace.Hit and IsValid( trace.Entity ) and not trace.Entity:IsPlayer() then
			if self.LockTime < CurTime() then
				self.LockTime  = CurTime() + 1
				self.LockCount = self.LockCount + 1
				self.Owner:ChatPrint( "Lock " .. self.LockCount )
				if self.LockCount >= 2 then
					self.Target = trace.Entity
					-- FIX: SetNetworkedBool -> SetNWBool
					self.Owner:SetNWBool( "TargetLock", true )
					self.Owner:ChatPrint( "Ready to fire" )
				end
			end
		else
			self.LockCount = 0
		end
	elseif self.Owner:KeyDown( IN_ATTACK ) and IsValid( self.Target ) then
		self:FireMissile()
		self:TakePrimaryAmmo( 1 )
	end

	if self.Owner:KeyReleased( IN_ATTACK2 ) then
		self.LockCount = 0
	end
end


function SWEP:DrawHUD()
	-- FIX: GetNetworkedBool -> GetNWBool; `trace` was an undeclared global, now local
	if not self.Owner:GetNWBool( "TargetLock" ) then
		local trace = self.Owner:GetEyeTrace()
		if trace.Hit and not trace.Entity:IsNPC() and not trace.Entity:IsPlayer() and IsValid( trace.Entity ) then
			self.LastTarget = trace.Entity
			self.TempTarget = trace.Entity
			self.TempTarget:SetColor( Color( 255, 0, 0, 255 ) )
		elseif self.TempTarget != NULL and IsValid( self.TempTarget ) and not IsValid( trace.Entity ) and trace.Entity != self.TempTarget then
			self.TempTarget:SetColor( Color( 255, 255, 255, 255 ) )
			self.TempTarget = NULL
		end
	end

	if self.Owner:GetNWBool( "TargetLock" ) then
		if IsValid( self.Target ) then
			if IsValid( self.TempTarget ) then
				self.TempTarget:SetColor( Color( 255, 255, 255, 255 ) )
			end
			self.TempTarget = NULL
			self.Target:SetColor( Color( 0, 255, 0, 255 ) )
		end
	end

	if self.LastTarget != NULL and IsValid( self.LastTarget ) then
		self.LastTarget:SetColor( Color( 255, 255, 255, 255 ) )
	end
end


function SWEP:FireMissile()
	if CLIENT then return end
	local missile = ents.Create( "stinger_missile" )
	missile:SetPos( self.Owner:GetShootPos() + self.Owner:GetUp() * 15 )
	missile:SetOwner( self.Owner )
	-- FIX: SetVar() is removed datastream API. Assign Target directly on
	-- the entity table so stinger_missile/init.lua can read missile.Target.
	missile.Owner  = self.Owner
	missile.Target = self.Target
	missile:Spawn()
	missile:Activate()

	self.Missile = missile
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	self.LastTarget = self.Target
	self.Target     = NULL
	-- FIX: SetNetworkedBool -> SetNWBool
	self.Owner:SetNWBool( "TargetLock", false )
end


function SWEP:Holster()
	self.TargetLock = false
	self.TempTarget = NULL
	self.LockCount  = 0
	return true
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
end
