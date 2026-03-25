include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

ENT.SearchSize          = 0
ENT.SpawnHeight         = 0
ENT.MaxHeight           = 0
ENT.Damage              = 0
ENT.AIGunner            = true
ENT.BarrelAttachment    = ""
ENT.LifeDuration        = 0
ENT.SectorHoldDuration  = 0
ENT.MaxSpeed            = 0
ENT.MinSpeed            = 0
ENT.ShootTime           = 0
ENT.MaxBullets          = 0
ENT.BarrelCoolDownDelay = 0
ENT.ourHealth           = 0
ENT.SpinAnimation       = ""
ENT.Ground              = 0
ENT.Sectors             = {}
ENT.TempSectors         = {}
ENT.Target              = nil
ENT.CurSector           = nil
-- FIX: all CurTime() fields at table-def scope (stale) -> 0
ENT.SectorDelay         = 0
ENT.Life                = 0
ENT.IsInSector          = false
ENT.CurHeight           = 0
ENT.turnDelay           = 0
ENT.Pitch               = 0
ENT.Roll                = 0
ENT.PrevSector          = nil
ENT.FireDelay           = 0
ENT.Leave               = false
ENT.speedScaler         = 0
ENT.targetSpeedScaler   = 0
ENT.TargetAcquired      = false
ENT.BulletsShot         = 0
ENT.CoolDownTime        = 0
ENT.CoolDown            = false
ENT.Destroyed           = false
ENT.Removed             = false
ENT.bullseye            = nil
ENT.CurSpeed            = 0
ENT.radius              = 1500


local function removeSector( tab, value )
	for k, v in pairs( tab ) do
		if v == value then table.remove( tab, k ) end
	end
end

local function searchBox( startVec, endVec, size )
	local s = Vector( startVec.x, startVec.y, 0 )
	local e = Vector( endVec.x,   endVec.y,   0 )
	local ang = ( e - s ):Angle():Right()
	local st  = s + ( ang * size / 2 )
	ang = ( s - e ):Angle():Right()
	local en  = e + ( ang * size / 2 )
	return Vector( st.x, st.y, startVec.z ), Vector( en.x, en.y, endVec.z )
end


function ENT:MW2_Init()
	self.Ground = self:findGround()
	self.MapBounds.xPos, self.MapBounds.xNeg = self:FindBounds( true )
	self.MapBounds.yPos, self.MapBounds.yNeg = self:FindBounds( false )
	self.Sectors = {}
	self:SetupSectors()
	self.TempSectors = self.Sectors
	self.CurHeight   = self.Ground + self.SpawnHeight
	self:SetPos( Vector( self.MapBounds.xPos, 0, self.CurHeight ) )
	self:SetAngles( Angle( 0, 180, 0 ) )
	-- FIX: assign live CurTime() values here, not at table-def scope
	self.Life      = CurTime() + self.LifeDuration
	self.speedScaler = 0
	self:SetAiTarget()
	self:SetDisposition()
	self:Helicopter_Init()
end

function ENT:Helicopter_Init() end


function ENT:Think()
	self:NextThink( CurTime() + 0.001 )

	if IsValid( self ) and not self:IsInWorld() then
		self:Remove()
	end

	if self.Leave and not self.Destroyed then
		local curSpeed = Lerp( self.speedScaler, 0, self.MaxSpeed )
		self.PhysObj:SetVelocity( self:GetForward() * curSpeed )
		self.speedScaler = self.speedScaler + 0.01
		self:SetPitch( true )
		self:SetRoll( false )
		return true
	end

	if self.Life < CurTime() and not self.Destroyed then
		self:RemoveHeli()
		return true
	end

	if self.Destroyed then
		if self.SpinAnimation == "" and self.turnDelay < CurTime() then
			self:SetAngles( Angle( 0, self:GetAngles().y + 1, 0 ) )
			self.PhysObj:ApplyForceCenter( Vector( 1, 0, self.PhysObj:GetMass() * -1000 ) )
			self.turnDelay = CurTime() + 0.005
		end
		return true
	end

	if self.Flares > 0 then
		local entsInSphere = ents.FindInSphere( self:GetPos(), self.radius )
		for _, v in pairs( entsInSphere ) do
			if v != self and v:GetClass() != "mw2_sent_decoyMissile" then
				self:DeployFlares( v, self:GetPos() )
			end
		end
	end

	if self.CurSector == nil then
		if table.Count( self.TempSectors ) <= 0 then self.TempSectors = self.Sectors end
		local sec = self:FindSector()
		if sec != self.PrevSector then
			self.CurSector  = sec
			self.IsInSector = false
		end
	end

	if not self.IsInSector and not self.TargetAcquired then
		self:MoveToArea()
	elseif self.IsInSector and self.CurSector != nil then
		self:SetPitch( false )
		if self.SectorDelay < CurTime() then
			self.PrevSector = self.CurSector
			self.CurSector  = nil
		end
	end

	self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self.CurHeight ) )

	if self.AIGunner then
		if not self:VerifyTarget() then self:FindTarget() end
		if self:VerifyTarget() then
			if self.BulletsShot <= self.MaxBullets then
				self:EngageTarget()
			elseif not self.CoolDown then
				self.CoolDownTime = CurTime() + self.BarrelCoolDownDelay
				self.CoolDown = true
			elseif self.CoolDownTime > CurTime() then
				self.CoolDown    = false
				self.BulletsShot = 0
			end
		end
	end

	return true
end


function ENT:FindSector()
	local maxCount  = 0
	local maxSector = nil
	for _, v in pairs( self.TempSectors ) do
		local count = v.Enemies()
		if maxCount < count then
			maxCount  = count
			maxSector = v
		end
	end
	return maxSector ~= nil and maxSector or table.Random( self.TempSectors )
end


function ENT:MoveToArea()
	local targetPos  = Vector( self.CurSector.MidPoint.x, self.CurSector.MidPoint.y, self:GetPos().z )
	local dis        = self:GetPos():Distance( targetPos )
	local speedFactor = 1
	local disAway    = 2
	local speed      = self:CalculateSpeed( targetPos )
	local dir        = ( targetPos - self:GetPos() ):GetNormal()
	local ourAng     = self:GetAngles()
	local ang        = ( targetPos - self:GetPos() ):Angle().y

	if ourAng.y < 0 then ourAng.y = 360 + ourAng.y end

	if self.turnDelay < CurTime() then
		local turnF = 1
		ang = math.Round( ang )
		if ang >= 360 then ang = 0 end
		if ang > math.Round( ourAng.y ) then
			self:SetPitch( false )
			self:SetRoll( true )
			self:SetAngles( Angle( self.Pitch, ourAng.y + turnF, self.Roll ) )
		elseif ang < math.Round( ourAng.y ) then
			self:SetPitch( false )
			self:SetRoll( true )
			self:SetAngles( Angle( self.Pitch, ourAng.y - turnF, self.Roll ) )
		else
			self:SetPitch( true )
			self:SetRoll( false )
		end
		self.turnDelay = CurTime() + 0.01
	end

	local move = self:CalculateHeight( targetPos )
	if not move then return end

	if dis < self.SearchSize / 4 and dis >= disAway then
		speedFactor = math.Clamp( dis / ( self.SearchSize / 4 ), 0, 1 )
		self:SetPitch( false )
		self.PhysObj:SetVelocity( dir * ( speed * speedFactor ) )
	elseif dis < disAway then
		self.IsInSector  = true
		self.SectorDelay = CurTime() + self.SectorHoldDuration
		self.PhysObj:SetVelocity( dir * 0 )
	elseif move then
		local curSpeed = Lerp( self.speedScaler, 0, self.MaxSpeed )
		self.PhysObj:SetVelocity( self:GetForward() * curSpeed )
		self.speedScaler = self.speedScaler + 0.01
	end

	if self.PrevSector then
		local curSecPos = Vector( self.PrevSector.MidPoint.x, self.PrevSector.MidPoint.y, self:GetPos().z )
		dis = self:GetPos():Distance( curSecPos )
		if dis < self.SearchSize / 4 then
			speedFactor = math.Clamp( dis / ( self.SearchSize / 4 ), 0.1, 1 )
		else
			self.PrevSector = nil
		end
	end
end


function ENT:CalculateHeight( targetPos )
	local cur  = self:GetPos()
	local data = util.QuickTrace( self:GetPos(), self.PhysObj:GetVelocity():GetNormal() * self.SearchSize / 2, { self } )
	local hitpos = data.HitPos

	if not data.HitWorld then
		self.CurHeight = self.CurHeight - 3
		if self.Ground + self.SpawnHeight > self.CurHeight then
			self.CurHeight = self.Ground + self.SpawnHeight
		end
		return true
	end

	local dis1       = cur:Distance( targetPos )
	local dis2       = cur:Distance( hitpos )
	local totalHeight = self.Ground + self.SpawnHeight + self.MaxHeight

	if dis1 > dis2 then
		if self.CurHeight < totalHeight and self:CanRaise() then
			self.CurHeight = self.CurHeight + 3
			return dis2 >= 1000
		end
	else
		if self.Ground + self.SpawnHeight < self.CurHeight then
			self.CurHeight = self.CurHeight - 3
		end
		return true
	end
	if self.Ground + self.SpawnHeight > self.CurHeight then
		self.CurHeight = self.Ground + self.SpawnHeight
	end
	return true
end


function ENT:CanRaise()
	local hitPos = util.QuickTrace( self:GetPos(), self:GetForward() * self.SearchSize / 2, { self } ).HitPos
	local loc    = hitPos + ( self:GetForward() * 200 )
	local trace  = { start = Vector( loc.x, loc.y, self.Sky ), endpos = loc }
	local tr     = util.TraceLine( trace )
	local hit    = tr.HitPos + Vector( 0, 0, 500 )
	local totalHeight = self.Ground + self.SpawnHeight + self.MaxHeight
	if hit.z <= totalHeight then
		return true
	else
		self.CurSector = nil
		return false
	end
end


function ENT:CalculateSpeed( targetPos )
	local ang = math.NormalizeAngle( ( targetPos - self:GetPos() ):Angle().y - self:GetAngles().y )
	local factor   = math.abs( ang ) / 180
	local speedDif = self.MaxSpeed - self.MinSpeed
	return self.MaxSpeed - ( speedDif * math.Round( factor ) )
end


function ENT:SetPitch( inc )
	if inc then
		if self.Pitch <= 15 then self.Pitch = self.Pitch + 1 end
	else
		if self.Pitch > 0  then self.Pitch = self.Pitch - 1 end
	end
	self:SetAngles( Angle( self.Pitch, self:GetAngles().y, self:GetAngles().r ) )
end

function ENT:SetRoll( inc )
	if inc then
		if self.Roll <= 20 then self.Roll = self.Roll + 1 end
	else
		if self.Roll > 0   then self.Roll = self.Roll - 1 end
	end
	self:SetAngles( Angle( self:GetAngles().p, self:GetAngles().y, self.Roll ) )
end


function ENT:SetupSectors()
	local pos = self.Owner:GetPos()
	local x1, x2 = pos.x + 5120, pos.x - 5120
	local y1, y2 = pos.y + 5120, pos.y - 5120
	local tX, tY = 0, 0
	local bool = true
	while bool do
		tX, tY = 0, 0
		x1 = pos.x + 5120
		while x1 >= x2 do
			tX = ( x1 - self.SearchSize >= x2 ) and ( x1 - self.SearchSize ) or x2
			if y1 - self.SearchSize >= y2 then
				tY = y1 - self.SearchSize
			else
				tY   = y2
				bool = false
			end
			self:InitSector( x1, y1, tX, tY )
			x1 = x1 - self.SearchSize
		end
		y1 = y1 - self.SearchSize
	end
end


function ENT:InitSector( x, y, x2, y2 )
	local sec    = { x = x, y = y, x2 = x2, y2 = y2 }
	local midX   = x - ( ( x - x2 ) / 2 )
	local midY   = y - ( ( y - y2 ) / 2 )
	sec.MidPoint = { x = midX, y = midY }

	local function EnemyCount( entTab )
		local count = 0
		for _, v in pairs( entTab ) do
			if self:FilterTarget( v, true ) then count = count + 1 end
		end
		return count
	end

	sec.Enemies = function()
		local maxVec = Vector( x,  y,  self.Ground + self.SpawnHeight + self.MaxHeight )
		local minVec = Vector( x2, y2, -16384 )
		return EnemyCount( ents.FindInBox( minVec, maxVec ) )
	end

	if self:PointInWorld( midX, midY ) then
		table.insert( self.Sectors, sec )
	end
end


function ENT:PointInWorld( x, y )
	local trace = {
		start  = Vector( x, y, self.Sky ),
		endpos = Vector( x, y, -16384 ),
		filter = { self.Owner, self }
	}
	local hitHeight = util.TraceLine( trace ).HitPos.z
	return hitHeight < self.Ground + self.SpawnHeight + self.MaxHeight
end


function ENT:FindTarget()
	local pos = self:GetPos()
	local des = pos + ( self:GetForward() * self.SearchSize * 1.5 )
	pos.z = self.Ground + self.SpawnHeight + self.MaxHeight
	des.z = -16384
	local maxVec, minVec = searchBox( pos, des )
	local es = ents.FindInBox( minVec, maxVec )
	self.Target = self:PrioritizeTargets( es )

	if self.Target == nil and self.IsInSector and self.CurSector != nil then
		maxVec = Vector( self.CurSector.x,  self.CurSector.y,  self.Ground + self.SpawnHeight + self.MaxHeight )
		minVec = Vector( self.CurSector.x2, self.CurSector.y2, -16384 )
		es = ents.FindInBox( minVec, maxVec )
		for _, v in pairs( es ) do
			if self:FilterTarget( v, true ) then
				self.Target = v
				break
			end
		end
	end

	if IsValid( self.Target ) then
		self.TargetAcquired   = true
		self.targetSpeedScaler = 0
		local vel = self.PhysObj:GetVelocity()
		self.CurSpeed = vel:Dot( vel:GetNormal() )
	end
end


function ENT:PrioritizeTargets( targets )
	local prio1, prio2 = {}, {}
	for _, v in pairs( targets ) do
		if self:FilterTarget( v, true ) and v:GetEnemy() == self then
			table.insert( prio1, v )
		elseif self:FilterTarget( v, true ) then
			table.insert( prio2, v )
		end
	end
	if table.Count( prio1 ) + table.Count( prio2 ) <= 0 then return nil
	elseif table.Count( prio1 ) > 0 then return table.Random( prio1 )
	else return table.Random( prio2 ) end
end


function ENT:VerifyTarget()
	if IsValid( self.Target ) and self:HasLOS( self.Target ) then return true end
	self.Target        = nil
	self.TargetAcquired = false
	return false
end


function ENT:EngageTarget()
	local ourAng = self:GetAngles()
	local ang    = ( self.Target:GetPos() - self:GetPos() ):Angle().y
	if ourAng.y < 0 then ourAng.y = 360 + ourAng.y end

	if self.turnDelay < CurTime() then
		ang = math.Round( ang )
		if ang >= 360 then ang = 0 end
		if ang > math.Round( ourAng.y ) then
			self:SetAngles( Angle( self.Pitch, ourAng.y + 1, self.Roll ) )
			self:SetRoll( false )
		elseif ang < math.Round( ourAng.y ) then
			self:SetAngles( Angle( self.Pitch, ourAng.y - 1, self.Roll ) )
			self:SetRoll( false )
		elseif self.FireDelay < CurTime() then
			self:ShootTarget()
			self.FireDelay = CurTime() + self.ShootTime
		end
		self.turnDelay = CurTime() + 0.01
	end

	if not self.IsInSector then
		local p1  = Vector( self:GetPos().x, self:GetPos().y, 0 )
		local p2  = Vector( self.Target:GetPos().x, self.Target:GetPos().y, 0 )
		local dis = math.Dist( p1.x, p1.y, p2.x, p2.y )
		local len = 1800
		if dis >= len + 300 then
			self.PhysObj:SetVelocity( self:GetForward() * self.CurSpeed )
			self:SetPitch( true )
			self:SetRoll( false )
		elseif dis < len + 300 then
			local curSpeed = Lerp( self.targetSpeedScaler, 0, self.MaxSpeed )
			self.PhysObj:SetVelocity( self:GetForward() * curSpeed )
			self.targetSpeedScaler = math.Clamp( self.targetSpeedScaler - 0.01, 0, 1 )
		elseif dis < len then
			self.PhysObj:SetVelocity( self:GetForward() * 0 )
			self:SetPitch( false )
			self:SetRoll( false )
		end
	end
end


function ENT:ShootTarget()
	-- FIX: bullet was global (missing local) + self.Entity:FireBullets -> self:FireBullets
	local bullet = {}
	bullet.Src      = self:GetAttachment( self:LookupAttachment( self.BarrelAttachment ) ).Pos
	local dir       = ( self.Target:LocalToWorld( self.Target:OBBCenter() ) - bullet.Src ):GetNormal()
	bullet.Attacker  = self.Owner
	bullet.Dir       = dir
	bullet.Spread    = Vector( 0.02, 0.02, 0 )
	bullet.Num       = 1
	bullet.Damage    = self.Damage
	bullet.Force     = 5
	bullet.Tracer    = 1
	bullet.TracerName = "HelicopterTracer"
	self:FireBullets( bullet )
	self.BulletsShot = self.BulletsShot + 1
	self:EmitSound( "weapons/smg1/smg1_fire1.wav", 100, 200 )
end


function ENT:OnTakeDamage( dmg )
	if self.ourHealth <= 0 then return end
	if dmg:IsExplosionDamage() then
		self:DestroyHeli()
		return
	end
	self.ourHealth = self.ourHealth - dmg:GetDamage()
	if self.ourHealth <= 0 then self:DestroyHeli() end
end


function ENT:DestroyHeli()
	self.ourHealth = 0
	self.Destroyed = true
	if self.SpinAnimation != "" then
		self:ResetSequence( self:LookupSequence( self.SpinAnimation ) )
	end
	self.PhysObj:EnableGravity( true )
	self.turnDelay = CurTime() - 1
	self.Smoke = ents.Create( "info_particle_system" )
	self.Smoke:SetPos( self:GetPos() )
	self.Smoke:SetKeyValue( "effect_name",  "smoke_burning_engine_01" )
	self.Smoke:SetKeyValue( "start_active", "1" )
	self.Smoke:Spawn()
	self.Smoke:Activate()
	self.Smoke:SetParent( self )
end


function ENT:PhysicsCollide( data, physobj )
	if not self.Destroyed or not data.HitEntity:IsWorld() then return end
	if not self.Removed then
		self.Smoke:Fire( "kill", "", 0 )
		self.Removed = true
		self:Remove()
	end
end


function ENT:RemoveHeli()
	self.Leave       = true
	self.speedScaler = 0
	self:SetNotSolid( true )
end


function ENT:SetDisposition()
	local enemys = ents.FindByClass( "npc_*" )
	for _, v in ipairs( enemys ) do
		if not table.HasValue( self.Friendlys, v:GetClass() ) then
			v:AddEntityRelationship( self.bullseye, D_HT, 99 )
		end
	end
end


function ENT:SetAiTarget()
	self.bullseye = ents.Create( "npc_bullseye" )
	self.bullseye:SetPos( self:LocalToWorld( self:OBBCenter() ) )
	self.bullseye:SetKeyValue( "spawnflags", "196608" )
	self.bullseye:SetParent( self )
	self.bullseye.PhysgunDisabled      = true
	self.bullseye.m_tblToolsAllowed    = string.Explode( " ", "none" )
	self.bullseye:Spawn()
end
