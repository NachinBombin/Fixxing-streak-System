AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )
include( "nuke_vars_init.lua" )


function ENT:Initialize()
	self.WaveResolution   = GetConVarNumber( "nuke_waveresolution" ) or 0.2
	self.IgnoreRagdoll    = util.tobool( GetConVarNumber( "nuke_ignoreragdoll" ) or 1 )
	self.BreakConstraints = util.tobool( GetConVarNumber( "nuke_breakconstraints" ) or 1 )
	self.DoDisintegration = util.tobool( GetConVarNumber( "nuke_disintegration" ) or 1 )
	self.EpicBlastWave    = util.tobool( GetConVarNumber( "nuke_epic_blastwave" ) or 1 )

	-- FIX: self.Entity:SetMoveType/DrawShadow/SetCollisionBounds/PhysicsInitBox/GetPhysicsObject/SetNotSolid/Fire -> self:XXX
	self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow( false )
	self:SetCollisionBounds( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )
	self:PhysicsInitBox( Vector( -20, -20, -10 ), Vector( 20, 20, 10 ) )

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableCollisions( false )
	end

	self:SetNotSolid( true )
	util.PrecacheModel( "models/player/charple01.mdl" )

	self.Yield        = ( GetConVarNumber( "nuke_yield" ) or 100 ) / 100
	self.YieldSlow    = self.Yield ^ 0.75
	self.YieldSlowest = self.Yield ^ 0.5
	-- FIX: self.Entity:GetPos -> self:GetPos
	self.SplodePos = self:GetPos() + Vector( 0, 0, 4 )

	-- FIX: self.Owner = self.Entity:GetVar('owner') dead API -> removed (set by nuke_system spawner)
	-- FIX: self.Weapon = self.Entity deprecated alias -> removed

	self:Fire( "kill", "", 6 * self.YieldSlow )

	local blastradius = 2300 * self.YieldSlow
	if blastradius > 14000 then blastradius = 14000 end

	if self.Yield > 0.13 then
		local trace = {
			start  = self.SplodePos,
			endpos = self.SplodePos - Vector( 0, 0, 4096 ),
			mask   = MASK_SOLID_BRUSHONLY
		}
		local traceRes           = util.TraceLine( trace )
		local ShortestTraceLength = 4096
		local LongOnes            = 0

		for i = 1, 6 do
			for k = -1, 1, 2 do
				for j = -1, 1, 2 do
					local dist = k * i * j * 120
					trace.start  = self.SplodePos + Vector( dist, dist, 0 )
					trace.endpos = trace.start - Vector( dist, dist, 4096 )
					traceRes = util.TraceLine( trace )
					local TraceLength = traceRes.Fraction * 4096
					if TraceLength < ShortestTraceLength then ShortestTraceLength = TraceLength end
					if TraceLength > 2048 then LongOnes = LongOnes + 1 end
				end
			end
		end

		local effectdata = EffectData()
		effectdata:SetMagnitude( self.Yield )

		if LongOnes > 10 then
			trace.start  = self.SplodePos
			trace.endpos = trace.start - Vector( 0, 0, 23000 )
			traceRes = util.TraceLine( trace )
			effectdata:SetOrigin( self.SplodePos )
			effectdata:SetScale( traceRes.Fraction * 23000 )
			util.Effect( "nuke_effect_air", effectdata )
		else
			self.SplodePos.z = self.SplodePos.z - ShortestTraceLength
			effectdata:SetOrigin( self.SplodePos )
			effectdata:SetScale( ShortestTraceLength )
			util.Effect( "nuke_effect_ground", effectdata )
			if self.EpicBlastWave then
				util.Effect( "nuke_blastwave", effectdata )
			else
				util.Effect( "nuke_blastwave_cheap", effectdata )
			end
		end

		local shake = ents.Create( "env_shake" )
		shake:SetKeyValue( "amplitude",  "16" )
		shake:SetKeyValue( "duration",   6 * self.YieldSlow )
		shake:SetKeyValue( "radius",     16384 )
		shake:SetKeyValue( "frequency",  230 )
		shake:SetPos( self.SplodePos )
		shake:Spawn()
		shake:Fire( "StartShake", "", "0.6" )
		shake:Fire( "kill", "", "8" )

		for _, v in pairs( ents.FindByClass( "func_breakable_surf" ) ) do
			local dist = ( v:GetPos() - self.SplodePos ):Length()
			if dist < 7 * blastradius then v:Fire( "Shatter", "", dist / 17e3 ) end
		end
		for _, v in pairs( ents.FindByClass( "func_breakable" ) ) do
			local dist = ( v:GetPos() - self.SplodePos ):Length()
			if dist < 7 * blastradius then v:Fire( "break", "", dist / 17e3 ) end
		end
	else
		local effectdata = EffectData()
		-- FIX: self.Entity:GetPos -> self:GetPos
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetNormal( Vector( 0, 0, 1 ) )
		effectdata:SetMagnitude( 1 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 1 )
		if self.Yield < 0.04 then
			util.Effect( "StunstickImpact", effectdata )
			util.Effect( "Impact", effectdata )
			util.Effect( "ManhackSparks", effectdata )
			util.Effect( "WheelDust", effectdata )
		else
			util.Effect( "Explosion", effectdata )
		end
		self.TimeLeft = CurTime() - 1
		self.DrawFX   = false
	end
end
