include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

-- FIX: net strings for REQUEST_BOMBER (replaced dead umsg)
if SERVER then
	util.AddNetworkString( "MW2_BOMBER_FRIENDLY" )
	util.AddNetworkString( "MW2_BOMBER_ENEMY" )
end

ENT.Model            = Model( "models/dav0r/camera.mdl" )
ENT.restrictMovement = true
ENT.Bomber           = nil
ENT.WallLoc          = NULL
ENT.playOnce         = true
ENT.findHoverZone    = true
-- FIX: these were set to CurTime() at file-scope (table-def time), not spawn time.
-- Moved to MW2_Init() so they reflect actual spawn time.
ENT.DropDelay        = 0
ENT.InitialDelay     = 0


local function Check_Status( Owner )
	-- FIX: Owner can be nil/invalid if base Initialize() failed; guard it
	if not IsValid( Owner ) then return 0 end
	return Owner:Alive() and 1 or 0
end


function ENT:Think()
	self:NextThink( CurTime() + 0.1 )

	if IsValid( self.Bomber ) and not self.Bomber:IsInWorld() then
		self.Bomber:Remove()
		self:Remove()
		return true
	end

	local Status = Check_Status( self.Owner )

	if Status == 1 then
		if self.DropLoc == nil or self.DropAng == nil then return end

		if self.findHoverZone then
			self.findHoverZone = false
			self.WallLoc = self:FindWall()
			self.FlyAng  = self.DropAng

			-- FIX: GAMEMODE:SetPlayerSpeed is DarkRP-only; use direct calls
			if IsValid( self.Owner ) then
				self.Owner:SetWalkSpeed( self.playerSpeeds[1] )
				self.Owner:SetRunSpeed( self.playerSpeeds[2] )
			end

			if IsValid( self.Wep ) then
				self.Wep:CallIn()
				self:REQUEST_BOMBER()
			end
			self:SpawnBomber()
		else
			if not self.Bomber then self:Remove() return end
			self.Bomber.PhysObj:SetVelocity( self.Bomber:GetForward() * 5000 )
			if self.DropDelay < CurTime() and self.InitialDelay < CurTime() then
				self.DropDelay = CurTime() + .08
				self:SpawnBomb()
			end
		end

		if not self.findHoverZone and self.playOnce then
			if IsValid( self.Wep ) then self.Wep:PlaySound() end
			self.playOnce = false
		end
	else
		self:Remove()
	end

	return true
end


function ENT:MW2_Init()
	-- FIX: use self directly, not self.Entity (removed old pattern)
	self:SetModel( "models/dav0r/camera.mdl" )
	self:SetColor( Color( 255, 255, 255, 0 ) )
	self:SetPos( Vector( 0, 0, 0 ) )
	self.PhysObj:EnableGravity( false )
	self:SetNotSolid( true )
	-- FIX: self.Owner is already set by base ENT:Initialize(); GetVar removed.
	-- FIX: init timestamps set here at actual spawn time
	self.DropDelay    = CurTime()
	self.InitialDelay = CurTime()
	self:OpenOverlayMap( true )
end


function ENT:REQUEST_BOMBER()
	-- FIX: umsg.Start/End removed from GMod ~2013. Replaced with net library.
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
			net.Start( "MW2_BOMBER_FRIENDLY" )
			net.Send( Value )
		else
			net.Start( "MW2_BOMBER_ENEMY" )
			net.Send( Value )
		end
	end
end


function ENT:SpawnBomber()
	self.ground = self:findGround() + 4000
	self.Bomber = ents.Create( "prop_physics" )
	self.Bomber:SetModel( "models/military2/air/air_f117_l.mdl" )
	self.Bomber:SetColor( Color( 255, 255, 255, 255 ) )
	self.Bomber:SetPos( Vector( self.WallLoc.x, self.WallLoc.y, self.ground ) )
	self.Bomber:SetAngles( self.FlyAng )
	self.Bomber:PhysicsInit( SOLID_VPHYSICS )
	self.Bomber:SetMoveType( MOVETYPE_VPHYSICS )
	self.Bomber:SetSolid( SOLID_VPHYSICS )
	self.Bomber.PhysObj = self.Bomber:GetPhysicsObject()
	if self.Bomber.PhysObj:IsValid() then
		self.Bomber.PhysObj:Wake()
	end
	self.InitialDelay        = CurTime() + .6
	constraint.NoCollide( self.Bomber, game.GetWorld(), 0, 0 )
	self.Bomber.PhysgunDisabled = true
end


function ENT:SpawnBomb()
	local careFlag = self:GetNWBool( "FromCarePackage", false )

	-- FIX: SetVar/GetVar are removed datastream API. Assign directly on entity table.
	local bomb = ents.Create( "sent_air_strike_bomb" )
	bomb:SetPos( self.Bomber:GetPos() + self.Bomber:GetRight() * -50 )
	bomb:SetAngles( self.Bomber:GetAngles() )
	bomb.Owner           = self.Owner
	bomb.FromCarePackage = careFlag
	bomb.HasBeenDropped  = true
	bomb:Spawn()
	constraint.NoCollide( self.Bomber, bomb, 0, 0 )

	local bomb2 = ents.Create( "sent_air_strike_bomb" )
	bomb2:SetPos( self.Bomber:GetPos() + self.Bomber:GetRight() * 50 )
	bomb2:SetAngles( self.Bomber:GetAngles() )
	bomb2.Owner           = self.Owner
	bomb2.FromCarePackage = careFlag
	bomb2.HasBeenDropped  = true
	bomb2:Spawn()
	constraint.NoCollide( self.Bomber, bomb2, 0, 0 )
end


function ENT:OnTakeDamage( dmginfo )
	-- FIX: was self.Entity:TakePhysicsDamage -> use self directly
	self:TakePhysicsDamage( dmginfo )
end


function ENT:FindWall()
	return util.QuickTrace( self.DropLoc, self.DropAng:Forward() * -100000, self ).HitPos
end
