include( 'shared.lua' )

local lpl       = nil
local fullWidth = 175
local height    = 10
-- FIX: ScrW/ScrH at file scope are stale on map load; must be evaluated at draw time
local setHook   = false

local Laser = Material( "cable/redlaser" )

game.AddParticles( "particles/muzzleflashes.pcf" )


function getEntityWidthLengthHeight( ent )
	local min, max = ent:WorldSpaceAABB()
	return max - min
end


function ENT:Draw()
	self.Entity:DrawModel()

	if not IsValid( lpl ) then return end

	-- FIX: lpl:GetVar -> lpl:GetNWBool
	if lpl:GetNWBool( "ShowSentryLaser", false ) then
		local barrel = self:GetAttachment( self:LookupAttachment( self.BarrelAttachment ) )
		local sPos   = barrel.Pos
		local ang    = Angle( self:GetPoseParameter( "aim_pitch" ), barrel.Ang.y, 0 ):Forward()
		local tracePos = util.QuickTrace( sPos, ang * self.Dis, self )
		local hit    = tracePos.HitPos
		render.SetMaterial( Laser )
		render.DrawBeam( sPos, hit, 5, 0, 0, Color( 255, 255, 255, 255 ) )
	end

	-- FIX: lpl:GetNetworkedString -> lpl:GetNWString
	local team = lpl:GetNWString( "MW2TeamSound", "" )
	local str  = ""
	if team == "1" then
		str = "militia"
	elseif team == "2" then
		str = "seals"
	elseif team == "3" then
		str = "opfor"
	elseif team == "4" then
		str = "rangers"
	elseif team == "5" then
		str = "tf141"
	end
	if string.len( str ) < 1 then return end

	local tex     = Material( "models/deathdealer142/supply_crate/" .. str )
	local wlh     = getEntityWidthLengthHeight( self )
	local eHeight = wlh.z
	local entPos  = self:GetPos() + Vector( 0, 0, eHeight + 8 )

	cam.Start3D2D( entPos, Angle( 0, LocalPlayer():GetAngles().y - 90, 90 ), 1 )
		surface.SetMaterial( tex )
		surface.SetDrawColor( 255, 255, 255 )
		surface.DrawTexturedRect( -8, -8, 16, 16 )
	cam.End3D2D()
end


-- FIX: usermessage.Hook -> net.Receive; data:ReadEntity() -> net.ReadEntity()
local function SetOwner()
	lpl = net.ReadEntity()
end

net.Receive( "setMW2SentryGunOwner", SetOwner )
