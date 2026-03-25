local width  = 300
local height = 250
local centerX = ScrW() / 2 - width / 2
local centerY = ScrH() / 2 - height / 2

local KILLSTREAKS_BASE = {
	{ "UAV",                 3,  "uav" },
	{ "Care Package",        4,  "care_package" },
	{ "COUNTER UAV",         4,  "mw2_Counter_UAV" },
	{ "Sentry Gun",          5,  "mw2_sentry_gun" },
	{ "Predator Missile",    5,  "predator_missile" },
	{ "Precision Airstrike", 6,  "precision_airstrike" },
	{ "Harrier",             7,  "harrier" },
	{ "Emergency Airdrop",   8,  "Emergency_Airdrop" },
	{ "Stealth Bomber",      9,  "stealth_bomber" },
	{ "AC-130",              11, "ac-130" },
	{ "EMP",                 15, "mw2_EMP" },
}
local KILLSTREAKS_NUKE = table.Copy( KILLSTREAKS_BASE )
table.insert( KILLSTREAKS_NUKE, { "NUKE", 25, "Tactical_Nuke" } )

local texturePath  = "VGUI/entities/"
local killNumLabels = {}

local Frame_Number = 0

local Display_Relationship = CreateClientConVar( "MW2_DISPLAY_FRIEND", "1" )

local UAV_ACTIVE         = false
local COUNTER_UAV_ACTIVE = false
local EMP_ACTIVE         = false

surface.CreateFont( "MW2Font",  { font = "BankGothic Md BT", size = 20, weight = 400, antialias = true, shadow = false } )
surface.CreateFont( "MW2Font2", { font = "BankGothic Md BT", size = 20, weight = 400, antialias = true, shadow = false } )


local function findValue( tab, var )
	for k, v in ipairs( tab ) do
		if table.HasValue( v, var ) then return v end
	end
	return nil
end

local function getPos( tab, var )
	for k, v in ipairs( tab ) do
		if v == var then return k end
	end
	return -1
end

local function setLabels( labelTable, values )
	for k, v in ipairs( labelTable ) do
		if values[k] != nil then
			v:SetText( values[k] .. " kills" )
		else
			v:SetText( "" )
		end
		v:SizeToContents()
	end
end

local numTab = { nil, nil, nil }

local function setImage( picTab, value, insert )
	local entry   = findValue( KILLSTREAKS_NUKE, value ) or findValue( KILLSTREAKS_BASE, value )
	if not entry then return end
	local killNum = entry[2]
	local path    = entry[3]

	if insert then
		if numTab[1] == nil then
			numTab[1] = killNum
			picTab[1]:SetImage( texturePath .. path )
			picTab[1]:SetImageColor( Color( 255, 255, 255, 255 ) )
		elseif numTab[1] != nil and numTab[1] < killNum and numTab[2] == nil then
			numTab[2] = killNum
			picTab[2]:SetImage( texturePath .. path )
			picTab[2]:SetImageColor( Color( 255, 255, 255, 255 ) )
		elseif numTab[2] != nil and numTab[2] < killNum and numTab[3] == nil then
			numTab[3] = killNum
			picTab[3]:SetImage( texturePath .. path )
			picTab[3]:SetImageColor( Color( 255, 255, 255, 255 ) )
		elseif numTab[1] > killNum then
			if numTab[2] != nil then
				numTab[3] = numTab[2]
				picTab[3]:SetImage( picTab[2]:GetImage() )
				picTab[3]:SetImageColor( Color( 255, 255, 255, 255 ) )
			end
			numTab[2] = numTab[1]
			numTab[1] = killNum
			picTab[2]:SetImage( picTab[1]:GetImage() )
			picTab[2]:SetImageColor( Color( 255, 255, 255, 255 ) )
			picTab[1]:SetImage( texturePath .. path )
			picTab[1]:SetImageColor( Color( 255, 255, 255, 255 ) )
		elseif numTab[2] > killNum then
			numTab[3] = numTab[2]
			numTab[2] = killNum
			picTab[3]:SetImage( picTab[2]:GetImage() )
			picTab[3]:SetImageColor( Color( 255, 255, 255, 255 ) )
			picTab[2]:SetImage( texturePath .. path )
			picTab[2]:SetImageColor( Color( 255, 255, 255, 255 ) )
		end
	else
		if numTab[1] == killNum then
			numTab[1] = numTab[2]
			numTab[2] = numTab[3]
			numTab[3] = nil
			if numTab[1] != nil then
				picTab[1]:SetImage( picTab[2]:GetImage() )
				picTab[1]:SetImageColor( Color( 255, 255, 255, 255 ) )
			else
				picTab[1]:SetImageColor( Color( 255, 255, 255, 0 ) )
			end
			if numTab[2] != nil then
				picTab[2]:SetImage( picTab[3]:GetImage() )
				picTab[2]:SetImageColor( Color( 255, 255, 255, 255 ) )
			else
				picTab[2]:SetImageColor( Color( 255, 255, 255, 0 ) )
			end
			picTab[3]:SetImageColor( Color( 255, 255, 255, 0 ) )
		elseif numTab[2] == killNum then
			numTab[2] = numTab[3]
			numTab[3] = nil
			if numTab[2] != nil then
				picTab[2]:SetImage( picTab[3]:GetImage() )
				picTab[2]:SetImageColor( Color( 255, 255, 255, 255 ) )
			else
				picTab[2]:SetImageColor( Color( 255, 255, 255, 0 ) )
			end
			picTab[3]:SetImageColor( Color( 255, 255, 255, 0 ) )
		else
			numTab[3] = nil
			picTab[3]:SetImageColor( Color( 255, 255, 255, 0 ) )
		end
	end
	setLabels( killNumLabels, numTab )
end

local DermaFrame

local function MW2TeamsTab( frame )
	local ButtonPanel = vgui.Create( "DPanel" )
	ButtonPanel:SetPos( 0, 0 )
	ButtonPanel:SetSize( frame:GetWide() - 10, frame:GetTall() - 31 )
	ButtonPanel:SetPaintBackground( false )

	local buttonSize    = 64
	local buttonSpacing = ( ButtonPanel:GetTall() - ( buttonSize * 5 ) ) / 5
	local buttonX       = frame:GetWide() / 2 - buttonSize / 2
	local buttonY       = 10
	local numButtons    = 0
	local MW2Voices     = { "militia", "seals", "opfor", "rangers", "tf141" }
	local t             = LocalPlayer():Team() - 1

	for k, v in ipairs( MW2Voices ) do
		local myButton = vgui.Create( "DImageButton", ButtonPanel )
		myButton:SetMaterial( "models/deathdealer142/supply_crate/" .. MW2Voices[k] )
		myButton:SetPos( buttonX, ( buttonSize * numButtons ) + ( buttonSpacing * numButtons ) + buttonY )
		myButton:SetSize( buttonSize, buttonSize )
		myButton.DoClick = function()
			t = k - 1
			net.Start( "SetMW2Voices" )
				net.WriteFloat( k )
			net.SendToServer()
		end
		numButtons = numButtons + 1
	end

	ButtonPanel.Paint = function()
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 0, 0, ButtonPanel:GetWide(), ButtonPanel:GetTall() )
		local y = ( buttonSize * t ) + ( buttonSpacing * t ) + buttonY
		surface.SetDrawColor( 150, 50, 50, 255 )
		surface.DrawOutlinedRect( buttonX, y, 64, 64 )
	end
	return ButtonPanel
end


local function MW2UserVars( Frame )
	local OptionPanel = vgui.Create( "DPanel" )
	OptionPanel:SetPos( 0, 0 )
	OptionPanel:SetSize( Frame:GetWide() - 10, Frame:GetTall() - 31 )
	OptionPanel:SetPaintBackground( false )

	local Sentry_Gun_Laser = vgui.Create( "DCheckBoxLabel", OptionPanel )
	Sentry_Gun_Laser:SetText( "SENTRY  GUN  LASER:  Enable  /  Disable  ( Immediate Effect )" )
	-- FIX: GetNetworkedBool -> GetNWBool
	if LocalPlayer():GetVar( "ShowSentryLaser", false ) then
		Sentry_Gun_Laser:SetValue( true )
	end
	Sentry_Gun_Laser:SetPos( 10, 10 )
	Sentry_Gun_Laser:SizeToContents()
	Sentry_Gun_Laser.OnChange = function()
		LocalPlayer():SetVar( "ShowSentryLaser", Sentry_Gun_Laser:GetChecked() )
	end

	local Display_Friend = vgui.Create( "DCheckBoxLabel", OptionPanel )
	Display_Friend:SetText( "FRIENDLY  TAG:  Enable  /  Disable  ( Immediate Effect )" )
	Display_Friend:SetPos( 10, 60 )
	Display_Friend:SizeToContents()
	Display_Friend:SetConVar( "MW2_DISPLAY_FRIEND" )

	OptionPanel.Paint = function()
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 0, 0, OptionPanel:GetWide(), OptionPanel:GetTall() )
	end
	return OptionPanel
end


local function MW2AdminVars( Frame )
	local Settings_Panel = vgui.Create( "DPanel" )
	Settings_Panel:SetPos( 0, 0 )
	Settings_Panel:SetSize( Frame:GetWide() - 10, Frame:GetTall() - 31 )
	Settings_Panel:SetPaintBackground( false )

	local Killstreak_Status = vgui.Create( "DCheckBoxLabel", Settings_Panel )
	Killstreak_Status:SetText( "KILLSTREAKS:  Enable / Disable  ( Immediate Effect )" )
	Killstreak_Status:SetPos( 10, 10 )
	Killstreak_Status:SizeToContents()
	Killstreak_Status:SetConVar( "MW2_KILLSTREAKS_ENABLED" )

	local Allow_Nuke = vgui.Create( "DCheckBoxLabel", Settings_Panel )
	Allow_Nuke:SetText( "NUKE:  Enable / Disable  ( Immediate Effect )" )
	Allow_Nuke:SetPos( 10, 60 )
	Allow_Nuke:SizeToContents()
	Allow_Nuke:SetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" )

	local Allow_Teams = vgui.Create( "DCheckBoxLabel", Settings_Panel )
	Allow_Teams:SetText( "TEAMS:  Enable / Disable  ( Immediate Effect )" )
	Allow_Teams:SetPos( 10, 110 )
	Allow_Teams:SizeToContents()
	Allow_Teams:SetConVar( "MW2_TEAMS_ENABLED" )

	local DLabel = vgui.Create( "DLabel", Settings_Panel )
	DLabel:SetPos( 10, 300 )
	DLabel:SetText( "THIS SLIDER LETS AN ADMIN SET HOW MANY NPCs = 1 KILL\nTOWARDS KILLSTREAKS. SET TO '0' TO DISALLOW NPC KILLS." )
	DLabel:SizeToContents()

	local NPC_Requirement = vgui.Create( "DNumSlider", Settings_Panel )
	NPC_Requirement:SetPos( 10, 160 )
	NPC_Requirement:SetSize( 350, 100 )
	NPC_Requirement:SetText( "NPC  -  REQUIREMENT:" )
	NPC_Requirement:SetMin( 0 )
	NPC_Requirement:SetMax( 20 )
	NPC_Requirement:SetDecimals( 0 )
	NPC_Requirement:SetConVar( "MW2_NPC_REQUIREMENT" )

	Settings_Panel.Paint = function()
		surface.SetDrawColor( 50, 50, 50, 255 )
		surface.DrawRect( 0, 0, Settings_Panel:GetWide(), Settings_Panel:GetTall() )
	end
	return Settings_Panel
end


-- FIX: dead SVN version check removed (googlecode.com shut down, caused nil errors on getClientVersion)


-- FIX: extracted duplicated button-building loop into a single helper
local function buildButtons( DermaPanel, streakList, picLabels, selectedStreaks, selectedNums, selectedLabel, buttonHeight, buttonSpacing, buttonWidth, buttonX, tables, dups )
	local numButtons        = 1
	local defaultColor      = Color( 39, 37, 54, 255 )
	local selectedColor     = Color( 0, 255, 0, 50 )
	local restrictedColor   = Color( 255, 0, 0, 100 )

	for k, v in ipairs( streakList ) do
		local valButton = vgui.Create( "DButton", DermaPanel )
		valButton:SetSize( buttonWidth, buttonHeight )
		valButton:SetPos( buttonX, ( buttonHeight * numButtons ) + ( buttonSpacing * ( numButtons - 1 ) ) - 22 )
		numButtons = numButtons + 1
		valButton:SetText( v[2] .. ")  " .. v[1] )
		valButton.name = v[1]
		valButton.Paint = function()
			draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
		end

		local value = v[2]
		if table.HasValue( dups, value ) then
			local tab = findValue( tables, value )
			if tab == nil then
				table.insert( tables, { value, valButton } )
			else
				table.insert( tab, valButton )
			end
		end

		local pressed = false
		valButton.DoClick = function( btn )
			local tab   = nil
			local color = defaultColor

			if not pressed and selectedNums[1] < 3 and not btn.locked then
				selectedNums[1] = selectedNums[1] + 1
				color   = selectedColor
				pressed = true
				selectedLabel:SetText( selectedNums[1] .. " / 3  SELECTED" )
				table.insert( selectedStreaks, btn.name )
				setImage( picLabels, btn.name, true )
				tab = findValue( tables, btn )
				if tab != nil then
					for k2, v2 in ipairs( tab ) do
						if v2 != btn and type( v2 ) == "Panel" then
							v2.Paint = function()
								draw.RoundedBox( 6, 0, 0, btn:GetWide(), btn:GetTall(), restrictedColor )
								v2.locked = true
							end
						end
					end
				end
			elseif pressed and not btn.locked then
				selectedNums[1] = selectedNums[1] - 1
				pressed = false
				selectedLabel:SetText( selectedNums[1] .. " / 3  SELECTED" )
				setImage( picLabels, btn.name, false )
				table.remove( selectedStreaks, getPos( selectedStreaks, btn.name ) )
				tab = findValue( tables, btn )
				if tab != nil then
					for k2, v2 in ipairs( tab ) do
						if v2 != btn and type( v2 ) == "Panel" then
							v2.Paint = function()
								draw.RoundedBox( 6, 0, 0, btn:GetWide(), btn:GetTall(), defaultColor )
								v2.locked = false
							end
						end
					end
				end
			end

			if not btn.locked then
				btn.Paint = function()
					draw.RoundedBox( 6, 0, 0, btn:GetWide(), btn:GetTall(), color )
				end
			end
		end
	end
	return numButtons
end


local function MW2KillstreakChooseFrame()
	local selectedNums  = { 0 } -- wrapped in table so closure mutation works across buildButtons
	local CAN_USE_NUKE  = GetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" ):GetInt()
	local buttonHeight  = 30
	local buttonSpacing = 5
	local buttonWidth   = 100
	local buttonX       = 10

	DermaFrame = vgui.Create( "DFrame" )
	DermaFrame:SetPos( centerX, centerY )
	DermaFrame:SetSize( width, height )
	DermaFrame:SetTitle( "Modern Warfare 2 - Killstreaks Menu" )
	DermaFrame:SetVisible( true )
	DermaFrame:SetDraggable( true )
	DermaFrame:ShowCloseButton( false )
	DermaFrame:MakePopup()

	local PropertySheet = vgui.Create( "DPropertySheet" )
	PropertySheet:SetParent( DermaFrame )
	PropertySheet:SetPos( 5, 30 )
	PropertySheet:SetSize( 340, 315 )

	local DermaPanel = vgui.Create( "DPanel", DermaFrame )
	DermaPanel:SetPos( 0, 22 )
	DermaPanel:SetSize( width, height )
	DermaPanel:SetPaintBackground( false )

	local selectedLabel  = vgui.Create( "DLabel", DermaPanel )
	local dups           = { 4, 5, 7, 9, 11 }
	local tables         = {}
	local picLabels      = {}
	local selectedStreaks = {}

	-- FIX: was triple-copy-pasted block; now a single call with correct streak list
	local streakList = ( CAN_USE_NUKE != 0 ) and KILLSTREAKS_NUKE or KILLSTREAKS_BASE
	local numButtons = buildButtons(
		DermaPanel, streakList, picLabels, selectedStreaks,
		selectedNums, selectedLabel,
		buttonHeight, buttonSpacing, buttonWidth, buttonX,
		tables, dups
	)

	DermaPanel:SetSize( DermaFrame:GetWide(), ( buttonHeight * numButtons ) + ( numButtons * buttonSpacing ) + 10 )
	PropertySheet:SetSize( DermaFrame:GetWide(), ( buttonHeight * numButtons ) + ( numButtons * buttonSpacing ) + 10 )
	DermaFrame:SetSize( PropertySheet:GetWide(), PropertySheet:GetTall() )

	local CBx      = buttonWidth + buttonX + 15
	local numPics  = 0
	local picD     = 64
	local picY     = DermaFrame:GetTall() / 2 - picD
	local imagePanel = vgui.Create( "DPanel", DermaPanel )

	for i = 1, 3 do
		local picImage = vgui.Create( "DImage", DermaPanel )
		picImage:SetPos( CBx - 5 + ( 10 + numPics * picD ) + ( 25 * numPics ), picY )
		picImage:SetSize( picD, picD )
		numPics = numPics + 1
		table.insert( picLabels, picImage )
	end

	local x, y = picLabels[3]:GetPos()
	DermaPanel:SetSize( x + picD + 15, DermaFrame:GetTall() )
	PropertySheet:SetSize( x + picD + 15, DermaFrame:GetTall() )
	local x3, y3 = PropertySheet:GetPos()
	DermaFrame:SetSize( PropertySheet:GetWide() + x3 + 5, PropertySheet:GetTall() + y3 + 5 )

	local ySpace = 30
	imagePanel:SetPos( CBx - 5, picY - 10 )
	imagePanel:SetSize( x + picD + 15, picD + ySpace )
	imagePanel.Paint = function()
		surface.SetDrawColor( 50, 50, 50, 255 )
		local x1, y1 = imagePanel:GetPos()
		local x2, y2 = picLabels[2]:GetPos()
		local x3, y3 = picLabels[3]:GetPos()
		surface.DrawRect( 0,           0, picD + 20, picD + ySpace )
		surface.DrawRect( x2 - x1 - 10, 0, picD + 20, picD + ySpace )
		surface.DrawRect( x3 - x1 - 10, 0, picD + 20, picD + ySpace )
	end

	local ix, iy = imagePanel:GetPos()
	selectedLabel:SetPos( CBx + 35, iy + imagePanel:GetTall() + 10 )
	selectedLabel:SetFont( "MW2Font" )
	selectedLabel:SetText( "0 / 3  SELECTED" )
	selectedLabel:SizeToContents()

	for i = 1, 3 do
		local x1, y1 = picLabels[i]:GetPos()
		killNumLabels[i] = vgui.Create( "DLabel", DermaPanel )
		killNumLabels[i]:SetPos( x1, y1 + picD )
		killNumLabels[i]:SetFont( "MW2Font2" )
		killNumLabels[i]:SetText( "" )
		killNumLabels[i]:SizeToContents()
	end

	local sx, sy = selectedLabel:GetPos()
	local selectButton = vgui.Create( "DButton", DermaPanel )
	selectButton:SetText( "SAVE AND CLOSE" )
	selectButton:SetPos( CBx + 35, sy + selectedLabel:GetTall() + 5 )
	selectButton:SetSize( 150, 30 )
	selectButton.DoClick = function()
		selectedNums[1] = 0
		killNumLabels   = {}
		numTab          = { nil, nil, nil }

		net.Start( "ChosenKillstreaks" )
			net.WriteTable( selectedStreaks )
		net.SendToServer()

		net.Start( "setMW2PlayerVars" )
			net.WriteBit( 1 ) -- server receives this; nuke always affects owner
		net.SendToServer()

		DermaFrame:Close()
		Frame_Number = 0
	end

	DermaPanel.Paint = function()
		surface.SetDrawColor( 110, 110, 110, 255 )
		surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
	end

	PropertySheet:AddSheet( "Killstreak Menu",   DermaPanel,                      "icon16/user.png",   false, false, "Select Killstreaks" )

	if UAV_ACTIVE == false and COUNTER_UAV_ACTIVE == false and EMP_ACTIVE == false then
		PropertySheet:AddSheet( "Team Menu", MW2TeamsTab( DermaPanel ), "icon16/group.png", false, false, "Select Team" )
	else
		chat.AddText( Color( 255, 0, 0 ), "[ MW2 KILLSTREAKS ]:  Team Menu unavailable - UAV, Counter-UAV, or EMP is active!" )
	end

	PropertySheet:AddSheet( "User Menu",         MW2UserVars( DermaPanel ),        "icon16/wrench.png", false, false, "Settings" )

	if LocalPlayer():IsAdmin() then
		PropertySheet:AddSheet( "Administrator Menu", MW2AdminVars( DermaPanel ), "icon16/key.png", false, false, "Administration Settings" )
	end
end


net.Receive( "UAV_STATUS", function()
	UAV_ACTIVE = net.ReadBool()
	if UAV_ACTIVE == true and Frame_Number != 0 then
		DermaFrame:Close()
		Frame_Number = 0
	end
end )

net.Receive( "COUNTER_UAV_STATUS", function()
	COUNTER_UAV_ACTIVE = net.ReadBool()
	if COUNTER_UAV_ACTIVE == true and Frame_Number != 0 then
		DermaFrame:Close()
		Frame_Number = 0
	end
end )

net.Receive( "EMP_STATUS", function()
	EMP_ACTIVE = net.ReadBool()
	if EMP_ACTIVE == true and Frame_Number != 0 then
		DermaFrame:Close()
		Frame_Number = 0
	end
end )


local function Check_Frame_Number()
	if Frame_Number == 0 then
		MW2KillstreakChooseFrame()
		Frame_Number = Frame_Number + 1
	else
		chat.AddText( "[ MW2 KILLSTREAKS ]:  You may not have more than one window open at the same time!" )
	end
end

concommand.Add( "OPEN_KILLSTREAK_MENU", Check_Frame_Number )
