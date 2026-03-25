AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

if SERVER then
	util.AddNetworkString( "SupplyCrate_DrawBar" )
	util.AddNetworkString( "CHECK_PLAYER_INPUT" )
	util.AddNetworkString( "SupplyCrate_GiveReward" )
	util.AddNetworkString( "START_CAPTURING" )
	util.AddNetworkString( "STOP_CAPTURING" )
end

local MW2Killstreaks = { "ammo", "uav", "mw2_counter_uav", "predator_missile", "mw2_sentry_gun", "precision_airstrike", "harrier", "stealth_bomber", "ac-130", "mw2_EMP" }

local ammoSlot    = 1
local uavSlot     = 2
local counterSlot = 3
local predatorSlot= 4
local sentrySlot  = 5
local precisionSlot=6
local harrierSlot = 7
local attackSlot  = harrierSlot
local stealthSlot = 8
local paveSlot    = stealthSlot
local acSlot      = 9
local chopperSlot = acSlot
local empSlot     = 10


ENT.Players    = {}
ENT.GiveReward = false
ENT.Reward     = nil
ENT.Winner     = nil
ENT.Model      = Model( "models/deathdealer142/supply_crate/supply_crate.mdl" )


function ENT:Initialize()
	-- FIX: self:GetVar('owner') dead API -> removed; Owner set by parent
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.PhysObj = self:GetPhysicsObject()
	if self.PhysObj:IsValid() then
		self.PhysObj:Wake()
	end

	self.PhysgunDisabled   = true
	self.m_tblToolsAllowed = string.Explode( " ", "none" )

	self.Reward = self:PickReward()
	-- FIX: SetNetworkedString -> SetNWString
	self:SetNWString( "SupplyCrate_Reward", self.Reward )
	-- FIX: GetNetworkedString -> GetNWString
	self:SetSkin( self.Owner:GetNWString( "MW2TeamSound", "0" ) - 1 )
end


function ENT:PickReward()
	-- FIX: self:GetVar('IsSentry') dead API -> GetNWBool
	if self:GetNWBool( "IsSentry", false ) then
		return MW2Killstreaks[sentrySlot]
	end
	-- FIX: self:GetVar('CrateType') dead API -> self.CrateType (set by spawner)
	local crateType = self.CrateType or self:GetNWString( "CrateType", "sent_CarePackage" )
	local num = math.random( 1, 100 )
	local str = ""
	if crateType == "sent_CarePackage" then
		if     num <= 15                   then str = MW2Killstreaks[ammoSlot]
		elseif num > 15  and num <= 30     then str = MW2Killstreaks[uavSlot]
		elseif num > 30  and num <= 43     then str = MW2Killstreaks[counterSlot]
		elseif num > 43  and num <= 53     then str = MW2Killstreaks[sentrySlot]
		elseif num > 53  and num <= 63     then str = MW2Killstreaks[predatorSlot]
		elseif num > 63  and num <= 73     then str = MW2Killstreaks[precisionSlot]
		elseif num > 73  and num <= 79     then str = MW2Killstreaks[harrierSlot]
		elseif num > 79  and num <= 85     then str = MW2Killstreaks[attackSlot]
		elseif num > 85  and num <= 89     then str = MW2Killstreaks[paveSlot]
		elseif num > 89  and num <= 93     then str = MW2Killstreaks[stealthSlot]
		elseif num > 93  and num <= 96     then str = MW2Killstreaks[chopperSlot]
		elseif num > 96  and num <= 99     then str = MW2Killstreaks[acSlot]
		elseif num > 99                    then str = MW2Killstreaks[empSlot]
		end
	else
		if     num <= 12                   then str = MW2Killstreaks[ammoSlot]
		elseif num > 12  and num <= 24     then str = MW2Killstreaks[uavSlot]
		elseif num > 24  and num <= 40     then str = MW2Killstreaks[counterSlot]
		elseif num > 40  and num <= 56     then str = MW2Killstreaks[sentrySlot]
		elseif num > 56  and num <= 70     then str = MW2Killstreaks[predatorSlot]
		elseif num > 70  and num <= 80     then str = MW2Killstreaks[precisionSlot]
		elseif num > 80  and num <= 85     then str = MW2Killstreaks[harrierSlot]
		elseif num > 85  and num <= 90     then str = MW2Killstreaks[attackSlot]
		elseif num > 90  and num <= 93     then str = MW2Killstreaks[paveSlot]
		elseif num > 93  and num <= 96     then str = MW2Killstreaks[stealthSlot]
		elseif num > 96  and num <= 98     then str = MW2Killstreaks[chopperSlot]
		elseif num > 98  and num <= 100    then str = MW2Killstreaks[acSlot]
		end
	end
	return str
end


function ENT:Think()
	if self.GiveReward then
		self.Winner.MW2KV.addKillStreak( self.Winner, self.Reward, true )
		for Key, Value in pairs( self.Players ) do
			-- FIX: SetNetworkedBool -> SetNWBool
			Value:SetNWBool( "SupplyCrate_DrawBarBool", false )
			Value.UseBool = false
			table.remove( self.Players, Key )
			Value:Freeze( false )
		end
		self:Remove()
		return
	end

	for Key, Value in pairs( self.Players ) do
		if Value:KeyReleased( IN_USE ) == true and Value.UseBool == true then
			Value:SetNWBool( "SupplyCrate_DrawBarBool", false )
			Value.UseBool = false
			table.remove( self.Players, Key )
			Value:Freeze( false )
		end
	end
end


function ENT:Use( PLY )
	if not PLY.UseBool or PLY.UseBool == nil then
		table.insert( self.Players, PLY )
		-- FIX: SetNetworkedBool -> SetNWBool
		PLY:SetNWBool( "SupplyCrate_DrawBarBool", true )
		PLY.SupplyCrate = self
		PLY.UseBool     = true

		if PLY == self.Owner then
			-- FIX: SetNetworkedFloat -> SetNWFloat
			PLY:SetNWFloat( "SupplyCrate_Inc", 4 )
			PLY:Freeze( true )
		elseif PLY:Team() == self.Owner:Team() and PLY != self.Owner then
			PLY:SetNWFloat( "SupplyCrate_Inc", 2 )
			PLY:Freeze( true )
		else
			PLY:SetNWFloat( "SupplyCrate_Inc", 1 )
			PLY:Freeze( true )
		end

		-- FIX: umsg.Start/End x2 -> net library
		net.Start( "SupplyCrate_DrawBar" )
		net.Send( PLY )
		net.Start( "CHECK_PLAYER_INPUT" )
		net.Send( PLY )
	end
end


function Give_Reward( SIZE, PL )
	if not IsValid( PL.SupplyCrate ) or PL:Alive() == false then return end
	PL.SupplyCrate.GiveReward = true
	PL.SupplyCrate.Winner     = PL
	timer.Remove( "CAPTURE_TIMER" )
	PL:Freeze( false )
end
net.Receive( "SupplyCrate_GiveReward", Give_Reward )


function START_CAPTURE( SIZE, PLY )
	timer.Create( "CAPTURE_TIMER", 0.5, 0, function()
		if PLY:KeyDown( IN_USE ) == false then
			STOP_CAPTURE( SIZE, PLY )
		end
	end )
	PLY:SetNWBool( "SupplyCrate_DrawBarBool", true )
	PLY.UseBool = true
	PLY:Freeze( true )
end
net.Receive( "START_CAPTURING", START_CAPTURE )


function STOP_CAPTURE( SIZE, PLY )
	timer.Remove( "CAPTURE_TIMER" )
	PLY:SetNWBool( "SupplyCrate_DrawBarBool", false )
	PLY.UseBool = false
	PLY:Freeze( false )
end
net.Receive( "STOP_CAPTURING", STOP_CAPTURE )
