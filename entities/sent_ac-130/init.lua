AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "MW2_LOCKHEED_FRIENDLY" )
	util.AddNetworkString( "MW2_LOCKHEED_ENEMY" )
	util.AddNetworkString( "AC_130_SetUpHUD" )
	util.AddNetworkString( "AC_130_RemoveHUD" )
	util.AddNetworkString( "AC_130_Error" )
	util.AddNetworkString( "AC130_GunSound" )
end

-- FIX: all CurTime() at table-def scope (stale) -> 0; assigned live in Initialize()
ENT.camera              = NULL
ENT.sky                 = 0
ENT.ang                 = NULL
ENT.cameraAng           = Angle( 0, 0, 0 )
ENT.weapon              = 0
ENT.DelayTime105mm      = 0
ENT.DelayTime40mm       = 0
ENT.DelayTime25mm       = 0
ENT.CoolDownTime25mm    = 0
ENT.SwitchDelay         = 0
ENT.Max40mmShotDelay    = 0
ENT.TurnDelay           = 0
ENT.Max40mm             = 0
ENT.missile             = NULL
ENT.AC130Life           = 0
ENT.AC130Time           = 40
ENT.OneSecond           = 0
ENT.Flares              = 2
ENT.OwnerPos            = NULL
ENT.BulletsShot         = 0
ENT.StayAlive           = true
ENT.rotateAroundPlayer  = true
ENT.playerPos           = NULL
ENT.disFromPl           = 3000
ENT.PlayerAng           = NULL

local sound105mm = Sound( "killstreak_rewards/ac-130_105mm_fire.wav" )
local sound40mm  = Sound( "killstreak_rewards/ac-130_40mm_fire.wav" )
local sound25mm  = Sound( "killstreak_rewards/ac-130_25mm_fire.wav" )


function ENT:PhysicsUpdate()
	if not IsValid( self ) then return end
	if self.StayAlive then
		-- FIX: self.Entity:GetPos/GetForward -> self:XXX
		self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.sky ) )
		self.PhysObj:SetVelocity( self:GetForward() * 300 )
		self:SetAngles( self.ang )
		self.camera:SetPos( self:GetPos() + ( self:GetRight() * -97 ) + ( self:GetUp() * 97 ) + ( self:GetForward() * -242 ) )
		self.camera:SetAngles( self.Owner:GetAimVector():Angle() + Angle( 40, 0, 0 ) - self.cameraAng )
		self.Entity.Seat:SetPos( self.OwnerPos )
		self.Entity.Seat:SetAngles( self.ang )
		self.HUDXPos = self:GetPos().x
		self.HUDYPos = self:GetPos().y
		self.HUDAGL  = self:GetPos().z
		-- FIX: SetNetworkedInt -> SetNWInt
		self.Owner:SetNWInt( "Ac_130_HUDXPos", self.HUDXPos )
		self.Owner:SetNWInt( "Ac_130_HUDYPos", self.HUDYPos )
		self.Owner:SetNWInt( "Ac_130_HUDAGL",  self.HUDAGL )
		self:UpdateReloadingStates()

		if self.rotateAroundPlayer then
			local dis = Vector( self:GetPos().x, self:GetPos().y, 0 ):Distance( Vector( self.playerPos.x, self.playerPos.y, 0 ) )
			if self.disFromPl < dis and self.TurnDelay < CurTime() then
				self.ang       = self.ang + Angle( 0, 0.1, 0 )
				self.TurnDelay = CurTime() + 0.02
			end
		end

		local Trace = util.QuickTrace( self:GetPos(), self:GetForward() * 3000, self )
		if Trace.HitSky then
			self.ang = self.ang + Angle( 0, 0.3, 0 )
		end

		if self.Owner:KeyDown( IN_ATTACK ) then
			if self.weapon == 0 and self.DelayTime105mm <= CurTime() then
				self:FireMissile( self.camera:GetForward(), "105mm" )
				self.DelayTime105mm   = CurTime() + 5
				self.Is105mmReloading = true
				timer.Create( "TimerStop105mmRel", 5, 1, function() self:StopReloadingForHUD( "105mm" ) end )
			elseif self.weapon == 1 and self.DelayTime40mm <= CurTime() and self.Max40mmShotDelay <= CurTime() then
				self:FireMissile( self.camera:GetForward(), "40mm" )
				self.Max40mm = self.Max40mm + 1
				if self.Max40mm >= 4 then
					self.Max40mm          = 0
					self.Is40mmReloading  = true
					self.Max40mmShotDelay = CurTime() + 5
					timer.Create( "TimerStop40mmRel", 5, 1, function() self:StopReloadingForHUD( "40mm" ) end )
				end
				self.DelayTime40mm = CurTime() + 0.28
			elseif self.weapon == 2 and self.DelayTime25mm <= CurTime() and self.CoolDownTime25mm <= CurTime() then
				self:Shoot25mm()
				self.DelayTime25mm = CurTime() + 0.1
				if self.BulletsShot >= 30 then
					self.BulletsShot      = 0
					self.Is25mmReloading  = true
					self.CoolDownTime25mm = CurTime() + 5
					timer.Create( "TimerStop25mmRel", 5, 1, function() self:StopReloadingForHUD( "25mm" ) end )
				end
			end
		elseif self.Owner:KeyDown( IN_ATTACK2 ) and self.SwitchDelay < CurTime() then
			self.BulletsShot = 0
			self.Max40mm     = 0
			self.SwitchDelay = CurTime() + 0.25
			self.weapon      = self.weapon + 1
			if self.weapon > 2 then self.weapon = 0 end
			-- FIX: SetNetworkedInt -> SetNWInt
			self.Owner:SetNWInt( "Ac_130_weapon", self.weapon )
		end

		if self.weapon == 0 then
			self.Owner:SetFOV( 75, 0 )
		elseif self.weapon == 1 then
			self.Owner:SetFOV( 25, 0 )
		elseif self.weapon == 2 then
			self.Owner:SetFOV( 8, 0 )
		end

		if not self.Owner:Alive() then
			self:RemoveAC130()
		end

		if self.AC130Life <= CurTime() then
			self:RemoveAC130()
		end

		if self.OneSecond <= CurTime() then
			self.OneSecond = CurTime() + 1
			self.AC130Time = self.AC130Time - 1
			self.Owner:SetNWInt( "Ac_130_Time", self.AC130Time )
		end

		local orgin_ents = ents.FindInSphere( self:GetPos(), 1000 )
		if self.Flares > 0 then
			for _, v in pairs( orgin_ents ) do
				if v:GetClass() == "rpg_missile" or v:GetClass() == "stinger_missile" then
					v:Remove()
					for i = 0, 20 do self:SpawnFlares() end
					self.Flares = self.Flares - 1
				end
			end
		end

		if not self.Owner:InVehicle() then
			self.Owner:EnterVehicle( self.Entity.Seat )
		end
	else
		self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.sky ) )
		self.PhysObj:SetVelocity( self:GetForward() * 1000 )
		self:SetAngles( self.ang )
	end

	if not self:IsInWorld() then
		self:Remove()
	end
end


function ENT:Think()
	if not IsValid( self.PhysObj ) or not self.PhysObj:IsValid() then
		self:Remove()
		return
	end
	if self.PhysObj:IsAsleep() then
		self.PhysObj:Wake()
	end
end


function ENT:Initialize()
	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed; set by weapon base
	-- FIX: self.Wep = self:GetVar('Weapon') dead API -> self.Wep set by weapon base
	self.playerPos = self.Owner:GetPos()
	self.PlayerAng = self.Owner:GetAngles()

	self.sky = self:findGround()
	if self.sky == -1 then
		self:Remove()
		return
	end
	self.sky = self.sky + 6000

	-- FIX: set stale timer fields at actual spawn time
	self.AC130Life = CurTime() + 40
	self.AC130Time = 40
	self.OneSecond = CurTime()

	local lplPos   = self.Owner:GetPos()
	local forw     = self.Owner:GetForward()
	local spawnPos = lplPos + ( ( -1 * forw ) * 2000 )
	spawnPos = Vector( spawnPos.x, spawnPos.y, self.sky )
	if not util.IsInWorld( spawnPos ) then
		spawnPos = lplPos + Vector( 0, 0, self.sky )
	end

	if not util.IsInWorld( spawnPos ) then
		MsgN( "[MW2 Killstreaks] AC-130 spawn position out of world: " .. tostring( spawnPos ) )
		self:Remove()
		-- FIX: umsg.Start/End -> net library
		net.Start( "AC_130_Error" )
		net.Send( self.Owner )
		if IsValid( self.Wep ) then self.Wep:CallIn() end
		return
	end

	-- FIX: self.Entity:SetModel/PhysicsInit/SetMoveType/SetSolid/SetPos/SetAngles -> self:XXX
	self:SetModel( "models/military2/air/air_130_l.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetPos( spawnPos )
	self:SetAngles( Angle( 0, self.Owner:GetAngles().y - 90, 0 ) )
	self.ang = self:GetAngles()

	self.camera = ents.Create( "prop_physics" )
	self.camera:SetModel( "models/dav0r/camera.mdl" )
	self.camera:SetPos( self:GetPos() + ( self:GetRight() * -97 ) + ( self:GetUp() * 97 ) + ( self:GetForward() * -242 ) )
	self.camera:SetAngles( Angle( 0, 90, 0 ) )
	self.camera:SetColor( Color( 255, 255, 255, 0 ) )
	self.camera:Spawn()
	self.camera:GetPhysicsObject():EnableGravity( false )
	self.camera:SetNotSolid( true )
	constraint.NoCollide( self, self.camera, 0, 0 )

	-- FIX: self.Entity:GetPhysicsObject -> self:GetPhysicsObject
	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	self.OwnerPos = self.Owner:GetPos()
	self.Entity.Seat = ents.Create( "prop_vehicle_prisoner_pod" )
	self.Entity.Seat:SetKeyValue( "vehiclescript", "scripts/vehicles/JetSeat.txt" )
	self.Entity.Seat:SetModel( "models/nova/airboat_seat.mdl" )
	self.Entity.Seat:SetPos( self.OwnerPos )
	self.Entity.Seat:SetAngles( self.ang )
	self.Entity.Seat:SetColor( Color( 255, 255, 255, 0 ) )
	self.Entity.Seat:Spawn()

	self.Owner:EnterVehicle( self.Entity.Seat )
	self.Owner:SetViewEntity( self.camera )
	-- FIX: SetNetworkedInt -> SetNWInt
	self.Owner:SetNWInt( "Ac_130_weapon", 0 )
	self.Owner:SetNWInt( "Ac_130_Time",   self.AC130Time )

	-- FIX: umsg.Start/End -> net library
	net.Start( "AC_130_SetUpHUD" )
	net.Send( self.Owner )

	self.EMPSoundEmmiter = CreateSound( self.camera, "ac-130_kill_sounds/AC130_idle_inside.mp3" )
	self.EMPSoundEmmiter:SetSoundLevel( 100 )
	self.EMPSoundEmmiter:ChangeVolume( 1, 0 )
	self.EMPSoundEmmiter:Play()

	self:REQUEST_LOCKHEED()
end


function ENT:REQUEST_LOCKHEED()
	-- FIX: umsg.Start/End x4 -> net library
	local Players = player.GetHumans()
	local teamsOn = GetConVar( "MW2_TEAMS_ENABLED" ):GetInt() != 0

	for _, Value in pairs( Players ) do
		local isFriendly
		if teamsOn then
			isFriendly = Value:Team() == self.Owner:Team()
		else
			isFriendly = Value == self.Owner
		end
		if isFriendly then
			net.Start( "MW2_LOCKHEED_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_LOCKHEED_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:FireMissile( target, weaponType )
	-- FIX: missileSound was global -> local
	local missileSound = NULL
	if weaponType == "105mm" then
		self.missile = ents.Create( "sent_105mm" )
		missileSound = sound105mm
	elseif weaponType == "40mm" then
		self.missile = ents.Create( "sent_40mm" )
		missileSound = sound40mm
	elseif weaponType == "25mm" then
		self.missile = ents.Create( "sent_25mm" )
		missileSound = "killstreak_rewards/ac-130_25mm_fire.wav"
	end

	net.Start( "AC130_GunSound" )
	net.WriteString( weaponType )
	net.Send( self.Owner )

	self.missile:SetPos( self:GetPos() )
	self.missile:SetAngles( target:Angle() )
	-- FIX: self.missile:SetVar('owner') dead API -> SetNWEntity
	-- FIX: self.missile:SetVar('FromCarePackage') -> SetNWBool
	self.missile.Owner = self.Owner
	self.missile:SetNWBool( "FromCarePackage", self:GetNWBool( "FromCarePackage", false ) )
	self.missile:Spawn()
	self:EmitSound( missileSound, 180, 100 )
	self.missile:EmitSound( missileSound, 180, 100 )
	self.camera:EmitSound( missileSound, 180, 100 )
	constraint.NoCollide( self, self.missile, 0, 0 )
end


function ENT:Shoot25mm()
	local HERounds = function( attacker, tr, dmginfo )
		local imp = EffectData()
		imp:SetOrigin( tr.HitPos )
		imp:SetNormal( tr.HitNormal )
		imp:SetScale( 8 )
		imp:SetRadius( 8 )
		imp:SetMagnitude( 8 )
		util.Effect( "AR2Explosion", imp )
		util.BlastDamage( dmginfo:GetInflictor(), attacker, tr.HitPos, 25, 12 )
		return true
	end
	-- FIX: bullet was global -> local; self.Entity:FireBullets -> self:FireBullets
	local bullet = {}
	bullet.Src        = self.camera:GetPos()
	bullet.Attacker   = self.Owner
	bullet.Dir        = self.camera:GetForward()
	bullet.Spread     = Vector( 0.0001, 0.0001, 0 )
	bullet.Num        = 1
	bullet.Damage     = 35
	bullet.Force      = 5
	bullet.Tracer     = 1
	bullet.TracerName = "HelicopterTracer"
	bullet.Callback   = HERounds
	self:FireBullets( bullet )
	self:EmitSound( sound25mm )
	self.BulletsShot = self.BulletsShot + 1
	net.Start( "AC130_GunSound" )
	net.WriteString( "25mm" )
	net.Send( self.Owner )
end


function ENT:SpawnFlares()
	local flares = ents.Create( "sent_flares" )
	flares:SetPos( self:GetPos() )
	flares:Spawn()
	flares:Activate()
	constraint.NoCollide( self, flares, 0, 0 )
end


function ENT:OnTakeDamage( dmg )
	if dmg:IsExplosionDamage() and self.Flares <= 0 then
		self:Destroy()
	end
end


function ENT:StopReloadingForHUD( weaponType )
	if weaponType == "105mm" then
		self.Is105mmReloading = false
	elseif weaponType == "40mm" then
		self.Is40mmReloading  = false
	elseif weaponType == "25mm" then
		self.Is25mmReloading  = false
	end
end


function ENT:Destroy()
	self:RemoveAC130()
end


function ENT:GetTeam()
	return self.Owner:Team()
end


function ENT:RemoveAC130()
	for _, name in ipairs( { "TimerStop105mmRel", "TimerStop40mmRel", "TimerStop25mmRel" } ) do
		if timer.Exists( name ) then timer.Destroy( name ) end
	end
	self.Is105mmReloading = false
	self.Is40mmReloading  = false
	self.Is25mmReloading  = false
	self:UpdateReloadingStates()
	-- FIX: umsg.Start/End -> net library
	net.Start( "AC_130_RemoveHUD" )
	net.Send( self.Owner )
	self.Owner:SetViewEntity( self.Owner )
	self.Owner:ExitVehicle()
	self.Owner:SetFOV( 75, 0 )
	self.camera:Remove()
	self.Entity.Seat:Remove()
	self.StayAlive = false
	constraint.NoCollide( self, game.GetWorld(), 0, 0 )
	local wep = self.Owner:GetActiveWeapon()
	if IsValid( wep ) then wep.MouseSensitivity = 1 end
	if IsValid( self.Wep ) then self.Wep:CallIn() end
	self.Owner:SetAngles( self.PlayerAng )
end


function ENT:UpdateReloadingStates()
	-- FIX: SetNetworkedBool -> SetNWBool
	self.Owner:SetNWBool( "Ac_130_105mmReloading", self.Is105mmReloading )
	self.Owner:SetNWBool( "Ac_130_40mmReloading",  self.Is40mmReloading )
	self.Owner:SetNWBool( "Ac_130_25mmReloading",  self.Is25mmReloading )
end


function ENT:findGround()
	local minheight  = -16384
	local startPos   = self.Owner:GetPos()
	local filterList = { self.Owner, self }
	local trace = {
		start  = startPos,
		endpos = Vector( startPos.x, startPos.y, minheight ),
		filter = filterList
	}
	local bool = true
	local maxNumber      = 0
	local groundLocation = -1
	while bool do
		local td = util.TraceLine( trace )
		if td.HitWorld then
			groundLocation = td.HitPos.z
			bool = false
		else
			table.insert( filterList, td.Entity )
		end
		maxNumber = maxNumber + 1
		if maxNumber >= 100 then
			MsgN( "[MW2 Killstreaks] AC-130 findGround: max iterations reached" )
			bool = false
		end
	end
	return groundLocation
end
