local width = 300;
local height = 250;
local centerX = ScrW()/2 - width/2
local centerY = ScrH()/2 - height/2
local KILLSTREAKS = { {"UAV", 3, "uav"}, {"Care Package", 4, "care_package"}, {"COUNTER UAV", 4, "mw2_Counter_UAV"}, {"Sentry Gun", 5, "mw2_sentry_gun"}, {"Predator Missile", 5, "predator_missile"}, {"Precision Airstrike", 6, "precision_airstrike"}, {"Harrier", 7, "harrier"}, {"Emergency Airdrop", 8, "Emergency_Airdrop"}, {"Stealth Bomber", 9, "stealth_bomber"}, {"AC-130", 11, "ac-130"}, {"EMP", 15, "mw2_EMP"}, {"NUKE", 25, "Tactical_Nuke"} }
local texturePath = "VGUI/entities/"
local killNumLabels = {}


local Frame_Number = 0  //  LOCAL VARIABLE REQUIRED IN ORDER FOR THE "Check_Frame_Number" FUNCTION TO WORK. KEEP AT "0" BECAUSE IF ALL KILLSTREAK WINDOWS ARE CLOSED, THERE ARE "0" MENUS VISIBLE


local Display_Relationship = CreateClientConVar( "MW2_DISPLAY_FRIEND", "1" );


local UAV_ACTIVE = false	//	CREATE LOCAL VARIABLE CALLED:	"UAV_ACTIVE"  -  SET INITIAL VALUE TO "FALSE"


local COUNTER_UAV_ACTIVE = false	//	CREATE LOCAL VARIABLE CALLED:	"COUNTER_UAV_ACTIVE"  -  SET INITIAL VALUE TO "FALSE"


local EMP_ACTIVE = false	//	CREATE LOCAL VARIABLE CALLED:	"EMP_ACTIVE"  -  SET INITIAL VALUE TO "FALSE"


surface.CreateFont("MW2Font",{font="BankGothic Md BT", size=20, weight=400, antialias=true, shadow=false} )


surface.CreateFont("MW2Font2",{font="BankGothic Md BT", size=20, weight=400, antialias=true, shadow=false} )


local function findValue(tab, var) -- tab is a 2d array
	for k,v in ipairs(tab) do
		if table.HasValue(v,var) then
			return v
		end
	end
	return nil;
end

local function getPos(tab, var)
	for k,v in ipairs(tab) do
		if v == var then
			return k;
		end
	end
	return -1;
end

local function setLabels(labelTable, values)
	for k,v in ipairs(labelTable) do
		if values[k] != nil then
			v:SetText(values[k] .. " kills")
			v:SizeToContents()
		else
			v:SetText("")
			v:SizeToContents()
		end
	end		
end

local numTab = {nil, nil, nil}

local function setImage(picTab, value, insert)	
	local killNum = findValue(KILLSTREAKS, value)[2];
	local path = findValue(KILLSTREAKS, value)[3];
	
	if insert then
		if numTab[1] == nil then
			numTab[1] = killNum;
			picTab[1]:SetImage(texturePath .. path)
			picTab[1]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[1] != nil && numTab[1] < killNum && numTab[2] == nil then
			numTab[2] = killNum;
			picTab[2]:SetImage(texturePath .. path)
			picTab[2]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[2] != nil && numTab[2] < killNum && numTab[3] == nil then
			numTab[3] = killNum;
			picTab[3]:SetImage(texturePath .. path)
			picTab[3]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[1] > killNum then
			if numTab[2] != nil then
				numTab[3] = numTab[2];
				picTab[3]:SetImage(picTab[2]:GetImage())
				picTab[3]:SetImageColor( Color(255,255,255,255) )
			end
			numTab[2] = numTab[1];
			numTab[1] = killNum			
			picTab[2]:SetImage(picTab[1]:GetImage())
			picTab[2]:SetImageColor( Color(255,255,255,255) )
			
			picTab[1]:SetImage(texturePath .. path)
			picTab[1]:SetImageColor( Color(255,255,255,255) )
		elseif numTab[2] > killNum then
			numTab[3] = numTab[2];
			numTab[2] = killNum
			picTab[3]:SetImage(picTab[2]:GetImage())
			picTab[3]:SetImageColor( Color(255,255,255,255) )
			
			picTab[2]:SetImage(texturePath .. path)
			picTab[2]:SetImageColor( Color(255,255,255,255) )
		end
	else
		
		if numTab[1] == killNum then
			numTab[1] = numTab[2];
			numTab[2] = numTab[3]
			numTab[3] = nil;
			if numTab[1] != nil then
				picTab[1]:SetImage(picTab[2]:GetImage())
				picTab[1]:SetImageColor( Color(255,255,255,255) )
			else
				picTab[1]:SetImageColor( Color(255,255,255,0) )				
			end
			if numTab[2] != nil then
				picTab[2]:SetImage(picTab[3]:GetImage())
				picTab[2]:SetImageColor( Color(255,255,255,255) )
			else
				picTab[2]:SetImageColor( Color(255,255,255,0) )				
			end
			picTab[3]:SetImageColor( Color(255,255,255,0) )				
			
		elseif numTab[2] == killNum then
			numTab[2] = numTab[3]
			numTab[3] = nil;
			if numTab[2] != nil then
				picTab[2]:SetImage(picTab[3]:GetImage())
				picTab[2]:SetImageColor( Color(255,255,255,255) )
			else
				picTab[2]:SetImageColor( Color(255,255,255,0) )				
			end
			picTab[3]:SetImageColor( Color(255,255,255,0) )				
		else
			numTab[3] = nil;
			picTab[3]:SetImageColor( Color(255,255,255,0) )				
		end
	end
	setLabels(killNumLabels,numTab)
end

local DermaFrame;

local function MW2TeamsTab(frame)
	
	
	local ButtonPanel = vgui.Create( "DPanel" )
	ButtonPanel:SetPos( 0, 0)
	ButtonPanel:SetSize( frame:GetWide() - 10, frame:GetTall() - 31 )
	ButtonPanel:SetPaintBackground(false)
	
	local buttonSize = 64
	local buttonSpaceing = (ButtonPanel:GetTall() - (buttonSize * 5) ) /  5
	local buttonX, buttonY = frame:GetWide()/2 - buttonSize/2, 10;
	local numButtons = 0;
	local MW2Voices = {"militia", "seals", "opfor", "rangers", "tf141"}
	local t = LocalPlayer():Team() - 1;
	--MsgN("Team = " .. tostring(t))
	for k,v in ipairs(MW2Voices) do
	
		local myButton = vgui.Create("DImageButton", ButtonPanel)
		myButton:SetMaterial( "models/deathdealer142/supply_crate/" .. MW2Voices[k] )
		myButton:SetPos( buttonX, (buttonSize * numButtons) + (buttonSpaceing * numButtons) + buttonY );
		myButton:SetSize(buttonSize, buttonSize)
		myButton.DoClick = function()
			t = k - 1;
			net.Start("SetMW2Voices")
				net.WriteFloat(k)
			net.SendToServer()
		end
		numButtons = numButtons + 1
	end
	ButtonPanel.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawRect( 0, 0, ButtonPanel:GetWide(), ButtonPanel:GetTall() ) -- Draw the rect	
		
		local y = (buttonSize * t) + (buttonSpaceing * t) + buttonY
		surface.SetDrawColor( 150, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawOutlinedRect( buttonX, y, 64, 64 ) -- Draw the rect
	end
	return ButtonPanel;
	
	
end


local function MW2UserVars( Frame )  //  CREATE LOCAL FUNCTION FOR THE "USER" VARIABLES  -  ACCEPT "Frame" AS PARAMETER
	
	
	local OptionPanel = vgui.Create( "DPanel" )  //  CREATE LOCAL PANEL FOR THE "USER" SETTINGS
	
	
	OptionPanel:SetPos( 0, 0 )	//	SET THE POSITION OF THE PANEL TO BE THE ORIGIN ( TOP-LEFT CORNER )
	
	
	OptionPanel:SetSize( Frame:GetWide() - 10, Frame:GetTall() - 31 )	//	SET THE SIZE OF THE PANEL
	
	
	OptionPanel:SetPaintBackground( false )  //  DO NOT INCLUDE BACKGROUND


/*

	
	local nuke = LocalPlayer():GetNetworkedBool("MW2NukeEffectOwner") or false;
	
	
	local nukeOwner = vgui.Create("DCheckBoxLabel", OptionPanel)
	
	
	nukeOwner:SetText("Nuke Affects Owner")
	if nuke then
		nukeOwner:SetValue(true)
	end
	
	
	nukeOwner:SetPos( 10, 10 )
	
	
	nukeOwner:SizeToContents()


	nukeOwner.OnChange = function()


		nuke = nukeOwner:GetChecked()


	end	

	
	local nX, nY = nukeOwner:GetPos();


*/
	
	
	local Sentry_Gun_Laser = vgui.Create( "DCheckBoxLabel", OptionPanel )	//	ON THE PANEL, CREATE A *LABELED CHECK-BOX*
	
	
		Sentry_Gun_Laser:SetText( "SENTRY  GUN  LASER:  Enable  /  Disable  ( Immediate Effect )" )	//	SET THE LABEL OF THE CHECK-BOX
	
	
		if LocalPlayer():GetVar( "ShowSentryLaser", false ) then  //  CHECK:  IF THE SYSTEM RECEIVES A REQUEST TO *SHOW* THE LASER, THEN...
	

			Sentry_Gun_Laser:SetValue( true )	//	SHOW A CHECK IN THE CHECK-BOX
	
	
		end  //  FINISH THE "IF" STATEMENT
		
		
		Sentry_Gun_Laser:SetPos( 10, 10 );	//	SET THE POSITION OF THE CHECK-BOX TO BE "10" PIXELS TO THE RIGHT, AND "10" PIXELS DOWN ( FROM THE ORIGIN )
		
		
		Sentry_Gun_Laser:SizeToContents()	//	SET THE SIZE OF THE CHECK-BOX TO THE CONTENTS OF THE MENU
		
		
		Sentry_Gun_Laser.OnChange = function()	//	WHEN THE SYSTEM DETECTS THAT THE USER CHECKS *OR* UNCHECKS THE BOX, DO THE FOLLOWING...
		
		
			LocalPlayer():SetVar( "ShowSentryLaser", Sentry_Gun_Laser:GetChecked() )	//	SET THE VARIABLE "ShowSentryLaser" TO THE STATE OF THE CHECK-BOX
	
	
		end  //  COMPLETE THE FUNCTION


	local Display_Friend = vgui.Create( "DCheckBoxLabel", OptionPanel )  //  CREATE A SECOND *LABELED CHECK-BOX*
	
	
		Display_Friend:SetText( "FRIENDLY  TAG:  Enable  /  Disable  ( Immediate Effect )" )  //	SET THE LABEL OF THE SECOND CHECK-BOX
	
	
		Display_Friend:SetPos( 10, 60 ); 	//	SET THE POSITION OF THE SECOND CHECK-BOX TO BE "10" PIXELS TO THE RIGHT, AND "60" PIXELS DOWN ( FROM THE ORIGIN )
	
	
		Display_Friend:SizeToContents()  //	SET THE SIZE OF THE SECOND CHECK-BOX TO THE CONTENTS OF THE MENU
	
	
		Display_Friend:SetConVar( "MW2_DISPLAY_FRIEND" )  //  WHEN THE USER "CHECKS" *OR* "UNCHECKS" THE BOX, TOGGLE THE STATE OF THE "MW2_DISPLAY_FRIEND" CONSOLE VARIABLE

	
/*
	

	local setButton = vgui.Create("DButton", OptionPanel)
	setButton:SetText("SAVE")	
	setButton:SetSize(50,30)
	setButton:SetPos( OptionPanel:GetWide()/2 - setButton:GetWide()/2, OptionPanel:GetTall() - setButton:GetTall() - 5 )
	setButton.DoClick = function()



		net.Start("setMW2PlayerVars")


			net.WriteBit(nuke and 1 or 0)


		net.SendToServer()
		
		
		--datastream.StreamToServer( "setMW2PlayerVars", {nuke} )
		
		
//		DermaFrame:Close();	LINE DISABLED  -  DO NOT ENABLE THIS LINE! DOING SO WILL CAUSE A RUN-TIME ERROR AND DAMAGE THE KILLSTREAK MENU, DISALLOWING ANY USE OR REMOVAL OF THE MENU VISUALLY! RESTART OF SERVER / CONNECTION IS REQUIRED TO FIX IF THE MENU IS DAMAGED!

		
	end	
	
	
*/
	
	
	OptionPanel.Paint = function() -- Paint function
		surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		surface.DrawRect( 0, 0, OptionPanel:GetWide(), OptionPanel:GetTall() ) -- Draw the rect
	end
	
	
	return OptionPanel;
	

end  //  COMPLETE FUNCTION ( FOR THE "USER" VARIABLES )


local function MW2AdminVars( Frame )	//  CREATE LOCAL FUNCTION FOR THE "ADMINISTRATOR" VARIABLES  -  ACCEPT "Frame" AS PARAMETER

	
	local Settings_Panel = vgui.Create( "DPanel" )	//  CREATE LOCAL PANEL FOR THE "ADMINISTRATOR" SETTINGS
	
	
		Settings_Panel:SetPos( 0, 0 )	//	SET THE POSITION OF THE PANEL TO BE THE ORIGIN ( TOP-LEFT CORNER )
	
	
		Settings_Panel:SetSize( Frame:GetWide() - 10, Frame:GetTall() - 31 )	//	SET THE SIZE OF THE PANEL
	
	
		Settings_Panel:SetPaintBackground( false )	//  DO NOT INCLUDE BACKGROUND
	
	
	local Killstreak_Status = vgui.Create( "DCheckBoxLabel", Settings_Panel )	//	CREATE A *LABELED CHECK-BOX*
	
	
		Killstreak_Status:SetText( "KILLSTREAKS:  Enable / Disable  ( Immediate Effect )" )  //	SET THE LABEL OF THE CHECK-BOX
	
	
		Killstreak_Status:SetPos( 10, 10 );  //	SET THE POSITION OF THE CHECK-BOX TO BE "10" PIXELS TO THE RIGHT, AND "10" PIXELS DOWN ( FROM THE ORIGIN )
	
	
		Killstreak_Status:SizeToContents()	//	SET THE SIZE OF THE CHECK-BOX TO THE CONTENTS OF THE MENU
	
	
		Killstreak_Status:SetConVar( "MW2_KILLSTREAKS_ENABLED" )	//  WHEN THE ADMINISTRATOR "CHECKS" *OR* "UNCHECKS" THE BOX, TOGGLE THE STATE OF THE "MW2_KILLSTREAKS_ENABLED" CONSOLE VARIABLE
	
	
	local Allow_Nuke = vgui.Create( "DCheckBoxLabel", Settings_Panel )	//	CREATE A SECOND *LABELED CHECK-BOX*
	
	
		Allow_Nuke:SetText( "NUKE:  Enable / Disable  ( Immediate Effect )" )	//	SET THE LABEL OF THE SECOND CHECK-BOX
	
	
		Allow_Nuke:SetPos( 10, 60 );	//	SET THE POSITION OF THE SECOND CHECK-BOX TO BE "10" PIXELS TO THE RIGHT, AND "60" PIXELS DOWN ( FROM THE ORIGIN )
	
	
		Allow_Nuke:SizeToContents()  //	SET THE SIZE OF THE SECOND CHECK-BOX TO THE CONTENTS OF THE MENU
	
	
		Allow_Nuke:SetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" )  //  WHEN THE ADMINISTRATOR "CHECKS" *OR* "UNCHECKS" THE BOX, TOGGLE THE STATE OF THE "MW2_ALLOW_CLIENT_USE_NUKE" CONSOLE VARIABLE
	
	
	local Allow_Teams = vgui.Create( "DCheckBoxLabel", Settings_Panel )  //	 CREATE A THIRD *LABELED CHECK-BOX*
	
	
		Allow_Teams:SetText( "TEAMS:  Enable / Disable  ( Immediate Effect )" )  //	SET THE LABEL OF THE THIRD CHECK-BOX
	
	
		Allow_Teams:SetPos( 10, 110 );	//	SET THE POSITION OF THE THIRD CHECK-BOX TO BE "10" PIXELS TO THE RIGHT, AND "110" PIXELS DOWN ( FROM THE ORIGIN )
	
	
		Allow_Teams:SizeToContents()	//	SET THE SIZE OF THE THIRD CHECK-BOX TO THE CONTENTS OF THE MENU
	
	
		Allow_Teams:SetConVar( "MW2_TEAMS_ENABLED" )	//  WHEN THE ADMINISTRATOR "CHECKS" *OR* "UNCHECKS" THE BOX, TOGGLE THE STATE OF THE "MW2_TEAMS_ENABLED" CONSOLE VARIABLE


	local DLabel = vgui.Create( "DLabel", Settings_Panel )	//	CREATE A TEMPORARY LABEL WITH NO SPECIFIC NAME


		DLabel:SetPos( 10, 300 )  //	SET THE POSITION OF THE LABEL TO BE "10" PIXELS TO THE RIGHT, AND "300" PIXELS DOWN ( FROM THE ORIGIN )


		DLabel:SetText( "THIS  SLIDER  ALLOWS  AN  ADMINISTRATOR  TO  SPECIFY \n\nHOW  MANY  NPC'S  NEED  TO  BE  KILLED  IN  ORDER  TO  EQUAL  1  KILL \n\nCOUNTED  TOWARDS  THE  KILLSTREAKS.  SET  THE  SLIDER  TO  '0'  TO \n\nDISALLOW  NPC  KILLS." )  //  SET THE TEXT TO BE DISPLAYED WITH THE LABEL


		DLabel:SizeToContents()  //	 SET THE SIZE OF THE LABEL TO BE RELATIVE TO THE CONTENTS OF THE MENU


	local NPC_Requirement = vgui.Create( "DNumSlider", Settings_Panel )  //	 CREATE A *NUMBER SLIDER*
	
	
		NPC_Requirement:SetPos( 10, 160 );	//	SET THE POSITION OF THE SLIDER TO BE "10" PIXELS TO THE RIGHT, AND "160" PIXELS DOWN ( FROM THE ORIGIN )
	
	
		NPC_Requirement:SetSize( 350, 100 )  //	SET THE SIZE OF THE SLIDER TO BE "350" PIXELS WIDE, AND "100" PIXELS TALL
	
	
		NPC_Requirement:SetText( "NPC  -  REQUIREMENT:" )	//	SET THE LABEL OF THE SLIDER
	
	
		NPC_Requirement:SetMin( 0 )  //  SET THE *MINIMUM* VALUE THAT THE SLIDER WILL PRODUCE
	
	
		NPC_Requirement:SetMax( 20 )  //  SET THE *MAXIMUM* VALUE THAT THE SLIDER WILL PRODUCE
	
	
		NPC_Requirement:SetDecimals( 0 )  //  RESTRICT THE SLIDER TO "WHOLE" NUMBERS *ONLY*
	
	
		NPC_Requirement:SetConVar( "MW2_NPC_REQUIREMENT" )	//  WHEN THE ADMINISTRATOR MOVES THE SLIDER, SET THE VALUE OF THE "MW2_NPC_REQUIREMENT" CONSOLE VARIABLE
	
	
	Settings_Panel.Paint = function() -- Paint function
		
		
		surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
		
		
		surface.DrawRect( 0, 0, Settings_Panel:GetWide(), Settings_Panel:GetTall() ) -- Draw the rect
	
	
	end
	
	
	return Settings_Panel;
	

end  //  COMPLETE FUNCTION ( FOR THE "ADMINISTRATOR" VARIABLES )


local function updatedPopup()

	local updatedPopup = vgui.Create('DFrame')
		updatedPopup:SetSize(318, 68)
		updatedPopup:SetPos(ScrW()/2 - updatedPopup:GetWide()/2, ScrH()/4 - updatedPopup:GetTall()/2 )
		updatedPopup:SetTitle('SVN Updated')
		updatedPopup:MakePopup()

	local pane = vgui.Create('DPanel', updatedPopup)
		pane:SetSize(300, 50)
		pane:SetPos(10, 30)
		pane.Paint = function()
			draw.RoundedBox( 6, 0, 0, pane:GetWide(), pane:GetTall(), Color( 50, 150, 50, 255 ) )
		end

	local Message = vgui.Create('DLabel', pane)
		Message:SetPos(5, 5)
		Message:SetText('The MW2 Killstreaks have been updated.\nYou should go and update your SVN to get the latest version')		
		Message:SetTextColor(Color(250, 240, 100, 255))
		Message:SetFont("DefaultLarge")
		Message:SizeToContents()
		
		pane:SetSize( Message:GetWide() + 20, Message:GetTall() + 10)
		updatedPopup:SetSize( pane:GetWide() + 15, pane:GetTall() + 10 + 30 )
end


local function getClientVersion()
	local fi = "lua/autorun/server/killstreakCounter.lua";
	local dir = nil;	
	local addons = file.FindDir("addons/*", true);
	
	for k,v in ipairs(addons) do
		if file.Exists("addons/" .. v .. "/" .. fi, true) then 
			dir = "addons/" .. v .. "/.svn/entries";
			break;
		end
	end
	
	if dir != nil && file.Exists(dir,true) then
	
		return tonumber(string.Explode("\n", file.Read( dir, true) )[4] )
	else
		return nil;
	end
end
local serverVer;
local userVer;
local myLabel;
local DisplayPanel;
local function updateContent()
	local ver = tonumber(userVer)
		local mes2 = serverVer .. "\n"
		if ver < serverVer then --When the user has an outdated version
			DisplayPanel._BGColor = Color(185,75,75, 255)
			myLabel:SetColor( Color(0,0,0,255) )
			mes2 = mes2 .. "You don't have the most upto date version of the MW2 Killstreaks\nPlease go and update the SVN"
			DisplayPanel:SetSize(DisplayPanel:GetParent():GetWide() - 10, myLabel:GetTall() + 10)
		elseif ver == serverVer then --When the user is up to date
			DisplayPanel._BGColor = Color(75,185,75, 255)
			myLabel:SetColor( Color(0,0,0,255) )
			mes2 = mes2 .. "You have the most current version of the MW2 Killstreaks"
		else --When the user has a higher version then the server, which shouldn't happen
		end
		myLabel:SetText(myLabel:GetText() .. mes2)
		myLabel:SizeToContents()
		DisplayPanel:SetSize(DisplayPanel:GetParent():GetWide() - 10, myLabel:GetTall() + 20)
end
--[[
local function serverCallBack(contents,size)
	serverVer = tonumber(string.match( contents, "Revision ([0-9]+)" ))
	updateContent()
	if serverVer && userVer && serverVer > userVer then
		updatedPopup();
	end
end
local function getServerVersion()
	http.Get("http://gmod-project-killstreaks.googlecode.com/svn/trunk/", "", serverCallBack)
end
getServerVersion()
userVer = getClientVersion();
]]
local function UpdateFrame(frame)
	if userVer == nil then return end
	local mes1 = "You have version " .. userVer .. "\nThe current version is "
	local VersionPanel = vgui.Create( "DPanel", frame)
		VersionPanel:SetPos( 5, 30)
		VersionPanel:SetSize( frame:GetWide() - 10, frame:GetTall() - 40 )
		VersionPanel.Paint = function() -- Paint function
			surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
			surface.DrawRect( 0, 0, VersionPanel:GetWide(), VersionPanel:GetTall() ) -- Draw the rect
		end
	DisplayPanel = vgui.Create( "DPanel", VersionPanel)
		DisplayPanel:SetPos( 5, 5)
		DisplayPanel:SetSize( DisplayPanel:GetParent():GetWide() - 10, 60 )
		DisplayPanel._BGColor = Color(75,75,75,255)
		DisplayPanel.Paint = function() -- The paint function		
			draw.RoundedBox( 4, 0, 0, DisplayPanel:GetWide(), DisplayPanel:GetTall(), DisplayPanel._BGColor )
		end
	myLabel= vgui.Create("DLabel", DisplayPanel)
		myLabel:SetText(mes1)
		myLabel:SetPos(10,10)
		myLabel:SizeToContents()
		DisplayPanel:SetSize(DisplayPanel:GetParent():GetWide() - 10, myLabel:GetTall() + 20)

	return VersionPanel;
end

local function DevFrame(frame)
	if not LocalPlayer():IsSuperAdmin() then return nil end
	local DevPanel = vgui.Create( "DPanelList", frame)
		DevPanel:SetPos( 5, 30)
		DevPanel:SetSize( frame:GetWide() - 10, frame:GetTall() - 40 )
		DevPanel:SetSpacing( 5 )
		DevPanel:EnableHorizontal( false )
		
		DevPanel.Paint = function() -- Paint function
			surface.SetDrawColor( 50, 50, 50, 255 ) -- Set our rect color below us; we do this so you can see items added to this panel
			surface.DrawRect( 0, 0, DevPanel:GetWide(), DevPanel:GetTall() ) -- Draw the rect
		end
		/*
		local overButton = vgui.Create("DButton")
		overButton:SetText("Overview Map")
		overButton:SetPos(10, 10);
		overButton:SizeToContents()
		overButton:SetSize( overButton:GetWide() + 20, overButton:GetTall() + 20 )
		overButton.DoClick = function()
			RunConsoleCommand( "gm_spawnsent", "sent_mestest" )
		end				
		DevPanel:AddItem(overButton)
		*/
		local airButton = vgui.Create("DButton")
		airButton:SetText("Air Strike")
		airButton:SetPos(10, 10);
		airButton:SizeToContents()
		airButton:SetSize( airButton:GetWide() + 20, airButton:GetTall() + 20 )
		airButton.DoClick = function()
			RunConsoleCommand( "gm_giveswep", "precision_airstrike_test" )
			DermaFrame:Close();
		end				
		DevPanel:AddItem(airButton)
		
		local stealthButton = vgui.Create("DButton")
		stealthButton:SetText("Stealth Bomber")
		stealthButton:SetPos(10, 10);
		stealthButton:SizeToContents()
		stealthButton:SetSize( stealthButton:GetWide() + 20, stealthButton:GetTall() + 20 )
		stealthButton.DoClick = function()
			RunConsoleCommand( "gm_giveswep", "stealth_bomber_test" )
			DermaFrame:Close();
		end				
		DevPanel:AddItem(stealthButton)
		
		local harrierButton = vgui.Create("DButton")
		harrierButton:SetText("Harrier")
		harrierButton:SetPos(10, 10);
		harrierButton:SizeToContents()
		harrierButton:SetSize( harrierButton:GetWide() + 20, harrierButton:GetTall() + 20 )
		harrierButton.DoClick = function()
			RunConsoleCommand( "gm_giveswep", "harrier_test" )
			DermaFrame:Close();
		end				
		DevPanel:AddItem(harrierButton)
		
		local HeliButton = vgui.Create("DButton")
		HeliButton:SetText("Attack Helicopter")
		HeliButton:SetPos(10, 10);
		HeliButton:SizeToContents()
		HeliButton:SetSize( HeliButton:GetWide() + 20, HeliButton:GetTall() + 20 )
		HeliButton.DoClick = function()
			RunConsoleCommand( "gm_giveswep", "mw2_attack_helicopter" )
			DermaFrame:Close();
		end				
		DevPanel:AddItem(HeliButton)
		
		/*
		local secButton = vgui.Create("DButton")
		secButton:SetText("Sector Test")
		secButton:SetPos(10, 10);
		secButton:SizeToContents()
		secButton:SetSize( secButton:GetWide() + 20, secButton:GetTall() + 20 )
		secButton.DoClick = function()
			RunConsoleCommand( "gm_spawnsent", "sent_sectortest" )
		end				
		DevPanel:AddItem(secButton)*/
		
	return DevPanel;
end


local function MW2KillstreakChooseFrame()	//	CREATE LOCAL FUNCTION CALLED:	"MW2KillstreakChooseFrame"
	
	
	local select3 = 0;
	local selectedNums = 0;
	local CAN_USE_NUKE = GetConVar( "MW2_ALLOW_CLIENT_USE_NUKE" ):GetInt()		//	CREATE LOCAL VARIABLE CALLED:	"CAN_USE_NUKE"	-	STORE THE CURRENT VALUE OF THE "MW2_ALLOW_CLIENT_USE_NUKE" CONSOLE VARIABLE
	local buttonHeight, buttonSpaceing = 30, 5;
	local buttonWidth, buttonX = 100, 10;	
	
	
	DermaFrame = vgui.Create( "DFrame" )
		
		
		DermaFrame:SetPos( centerX,centerY )
		DermaFrame:SetSize( width, height )
		DermaFrame:SetTitle( "Modern Warfare 2 - Killstreaks Menu" )	//	SET THE TITLE OF THE MENU TO READ:	"Modern Warfare 2 - Killstreaks Menu"
		DermaFrame:SetVisible( true )
		DermaFrame:SetDraggable( true )
		DermaFrame:ShowCloseButton( false )
		DermaFrame:MakePopup()
		
	local PropertySheet = vgui.Create( "DPropertySheet" )
		
		
		PropertySheet:SetParent( DermaFrame )
		PropertySheet:SetPos( 5, 30 )
		PropertySheet:SetSize( 340, 315 )
	
	local DermaPanel = vgui.Create( "DPanel", DermaFrame )
		
		
		DermaPanel:SetPos( 0, 22)
		DermaPanel:SetSize( width, height )
		DermaPanel:SetPaintBackground(false)

	local selectedLabel = vgui.Create("DLabel", DermaPanel)
	
	local dups = {4,5,7,9,11}
	local tables = {};
	local picLabels = {};
	local numButtons = 1;
	local selectedStreaks = {};
	local defaultColor, selectedColor, restrictedColor = Color( 39, 37, 54, 255 ), Color( 0, 255, 0, 50 ), Color(255,0,0,100);	
	
	
	for Key, Value in pairs( player.GetHumans() ) do	//	FOR EACH HUMAN PLAYER FOUND IN THE SERVER, DO THE FOLLOWING...
	
	
		if CAN_USE_NUKE != 0 /* and Value:IsAdmin() == false */ then	//	CHECK:	IF THE NUKE IS *ENABLED* FOR CLIENTS, THEN...
	
	
			KILLSTREAKS = { {"UAV", 3, "uav"}, {"Care Package", 4, "care_package"}, {"COUNTER UAV", 4, "mw2_Counter_UAV"}, {"Sentry Gun", 5, "mw2_sentry_gun"}, {"Predator Missile", 5, "predator_missile"}, {"Precision Airstrike", 6, "precision_airstrike"}, {"Harrier", 7, "harrier"}, {"Emergency Airdrop", 8, "Emergency_Airdrop"}, {"Stealth Bomber", 9, "stealth_bomber"}, {"AC-130", 11, "ac-130"}, {"EMP", 15, "mw2_EMP"}, {"NUKE", 25, "Tactical_Nuke"} }	//	GIVE ALL KILLSTREAKS TO THE PLAYER ( INCLUDING THE NUKE )
	
	
			for k, v in ipairs( KILLSTREAKS ) do
			
			
			local valButton = vgui.Create( "DButton", DermaPanel ); -- Create the button
			valButton:SetSize( buttonWidth, buttonHeight ); -- Set the size of the button
			valButton:SetPos( buttonX, (buttonHeight * numButtons) + (buttonSpaceing * (numButtons - 1)) - 22 ); -- Set the position of the button
			numButtons = numButtons + 1;
			valButton:SetText( v[2] .. ") " .. v[1] );
			valButton.name = v[1]
			valButton.Paint = function() -- The paint function		
				draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
			end
			local value = v[2]
			if table.HasValue(dups, value) then
				local tab = findValue(tables, value)
				if tab == nil then
					table.insert(tables, {value, valButton })
				else
					table.insert(tab, valButton)
				end
			end
			
			local pressed = false;
			valButton.DoClick = function(valButton)
				local tab = nil;
				local color = defaultColor;
				if !pressed && selectedNums < 3 && !valButton.locked then
					selectedNums = selectedNums + 1;
					color = selectedColor;
					pressed = true
					selectedLabel:SetText(selectedNums .." / 3  SELECTED")
					table.insert(selectedStreaks, valButton.name)					
					setImage(picLabels, valButton.name, true)
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), restrictedColor )
									v2.locked = true;
								end	
							end
						end
					end
				elseif pressed && !valButton.locked then
					selectedNums = selectedNums - 1;
					pressed = false;
					selectedLabel:SetText(selectedNums .." / 3  SELECTED")
					setImage(picLabels, valButton.name, false)
					table.remove(selectedStreaks, getPos(selectedStreaks,valButton.name))
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
									v2.locked = false;
								end	
							end
						end
					end		
				end		
				if !valButton.locked then
					valButton.Paint = function() -- The paint function
						draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), color )
					end		
				
				
				end
			
			
			end
		
		
		end


/*
		
	
		elseif Value:IsAdmin() == true then  //	 IF THE PLAYER CURRENTLY BEING PROCESSED *IS AN ADMINISTRATOR*, THEN...
		
		
			KILLSTREAKS = { {"UAV", 3, "uav"}, {"Care Package", 4, "care_package"}, {"COUNTER UAV", 4, "mw2_Counter_UAV"}, {"Sentry Gun", 5, "mw2_sentry_gun"}, {"Predator Missile", 5, "predator_missile"}, {"Precision Airstrike", 6, "precision_airstrike"}, {"Harrier", 7, "harrier"}, {"Emergency Airdrop", 8, "Emergency_Airdrop"}, {"Stealth Bomber", 9, "stealth_bomber"}, {"AC-130", 11, "ac-130"}, {"EMP", 15, "mw2_EMP"}, {"NUKE", 25, "Tactical_Nuke"} }	//	GIVE ALL KILLSTREAKS TO THE ADMINISTRATOR ( INCLUDING THE NUKE )
	
	
			for k, v in ipairs( KILLSTREAKS ) do
			
			
			local valButton = vgui.Create( "DButton", DermaPanel ); -- Create the button
			valButton:SetSize( buttonWidth, buttonHeight ); -- Set the size of the button
			valButton:SetPos( buttonX, (buttonHeight * numButtons) + (buttonSpaceing * (numButtons - 1)) - 22 ); -- Set the position of the button
			numButtons = numButtons + 1;
			valButton:SetText( v[2] .. ") " .. v[1] );
			valButton.name = v[1]
			valButton.Paint = function() -- The paint function		
				draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
			end
			local value = v[2]
			if table.HasValue(dups, value) then
				local tab = findValue(tables, value)
				if tab == nil then
					table.insert(tables, {value, valButton })
				else
					table.insert(tab, valButton)
				end
			end
			
			local pressed = false;
			valButton.DoClick = function(valButton)
				local tab = nil;
				local color = defaultColor;
				if !pressed && selectedNums < 3 && !valButton.locked then
					selectedNums = selectedNums + 1;
					color = selectedColor;
					pressed = true
					selectedLabel:SetText(selectedNums .." / 3  SELECTED")
					table.insert(selectedStreaks, valButton.name)					
					setImage(picLabels, valButton.name, true)
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), restrictedColor )
									v2.locked = true;
								end	
							end
						end
					end
				elseif pressed && !valButton.locked then
					selectedNums = selectedNums - 1;
					pressed = false;
					selectedLabel:SetText(selectedNums .." / 3  SELECTED")
					setImage(picLabels, valButton.name, false)
					table.remove(selectedStreaks, getPos(selectedStreaks,valButton.name))
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
									v2.locked = false;
								end	
							end
						end
					end		
				end		
				if !valButton.locked then
					valButton.Paint = function() -- The paint function
						draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), color )
					end		
				
				
				end
			
			
			end
		
		
		end
	

*/

	
		else	//	IF THE NUKE IS *NOT ENABLED* FOR CLIENTS, THEN...
		
		
			KILLSTREAKS = { {"UAV", 3, "uav"}, {"Care Package", 4, "care_package"}, {"COUNTER UAV", 4, "mw2_Counter_UAV"}, {"Sentry Gun", 5, "mw2_sentry_gun"}, {"Predator Missile", 5, "predator_missile"}, {"Precision Airstrike", 6, "precision_airstrike"}, {"Harrier", 7, "harrier"}, {"Emergency Airdrop", 8, "Emergency_Airdrop"}, {"Stealth Bomber", 9, "stealth_bomber"}, {"AC-130", 11, "ac-130"}, {"EMP", 15, "mw2_EMP"} }	//	GIVE ALL OTHER KILLSTREAKS TO THE PLAYER ( DO NOT INCLUDE THE NUKE )
	
	
			for k, v in ipairs( KILLSTREAKS ) do
			
			
			local valButton = vgui.Create( "DButton", DermaPanel ); -- Create the button
			valButton:SetSize( buttonWidth, buttonHeight ); -- Set the size of the button
			valButton:SetPos( buttonX, (buttonHeight * numButtons) + (buttonSpaceing * (numButtons - 1)) - 22 ); -- Set the position of the button
			numButtons = numButtons + 1;
			valButton:SetText( v[2] .. ") " .. v[1] );
			valButton.name = v[1]
			valButton.Paint = function() -- The paint function		
				draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
			end
			local value = v[2]
			if table.HasValue(dups, value) then
				local tab = findValue(tables, value)
				if tab == nil then
					table.insert(tables, {value, valButton })
				else
					table.insert(tab, valButton)
				end
			end
			
			local pressed = false;
			valButton.DoClick = function(valButton)
				local tab = nil;
				local color = defaultColor;
				if !pressed && selectedNums < 3 && !valButton.locked then
					selectedNums = selectedNums + 1;
					color = selectedColor;
					pressed = true
					selectedLabel:SetText(selectedNums .." / 3  SELECTED")
					table.insert(selectedStreaks, valButton.name)					
					setImage(picLabels, valButton.name, true)
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), restrictedColor )
									v2.locked = true;
								end	
							end
						end
					end
				elseif pressed && !valButton.locked then
					selectedNums = selectedNums - 1;
					pressed = false;
					selectedLabel:SetText(selectedNums .." / 3  SELECTED")
					setImage(picLabels, valButton.name, false)
					table.remove(selectedStreaks, getPos(selectedStreaks,valButton.name))
					tab = findValue(tables, valButton )
					if tab != nil then
						for k2,v2 in ipairs(tab) do					
							if v2 != valButton && type(v2) == "Panel" then
								v2.Paint = function() -- The paint function
									draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), defaultColor )
									v2.locked = false;
								end	
							end
						end
					end		
				end		
					
					
					if !valButton.locked then
						
						
						valButton.Paint = function() -- The paint function
						
						
							draw.RoundedBox( 6, 0, 0, valButton:GetWide(), valButton:GetTall(), color )
						
						
						end		
				
				
					end
			
			
				end
		
		
			end
		
		
		end  //  FINISH THE CHECK
		
		
	end  //  FINISH THE LOOP
	

	DermaPanel:SetSize( DermaFrame:GetWide(), (buttonHeight * numButtons) + (numButtons * buttonSpaceing) + 10 )
	PropertySheet:SetSize( DermaFrame:GetWide(), (buttonHeight * numButtons) + (numButtons * buttonSpaceing) + 10 )	
	DermaFrame:SetSize( PropertySheet:GetWide(), PropertySheet:GetTall() )
	
	local CBx, CBy = buttonWidth + buttonX + 15, DermaFrame:GetTall()/2
	local numPics = 0;
	local picD = 64;
	local picY = DermaFrame:GetTall()/2 - picD;
	local imagePanel = vgui.Create( "DPanel", DermaPanel )
	
	for i=1,3 do 
		local picImage = vgui.Create("DImage", DermaPanel)
		picImage:SetPos(CBx - 5 + ( 10 + numPics * picD ) + (25 * numPics), picY)
		picImage:SetSize(picD,picD)
		numPics = numPics + 1
		table.insert(picLabels, picImage)
	end	
	
	local x,y = picLabels[3]:GetPos();
	
	DermaPanel:SetSize( x + picD + 15, DermaFrame:GetTall())
	PropertySheet:SetSize( x + picD + 15, DermaFrame:GetTall())
	local x3,y3 = PropertySheet:GetPos()
	DermaFrame:SetSize( PropertySheet:GetWide() + x3 + 5, PropertySheet:GetTall() + y3 + 5 )
	
	local ySpace = 30
	imagePanel:SetPos( CBx - 5, picY - 10 )
	imagePanel:SetSize( x + picD + 15,  picD + ySpace )
	imagePanel.Paint = function() -- Paint function	
		surface.SetDrawColor( 50, 50, 50, 255 ) 
		local x1,y1 = imagePanel:GetPos() 
		local x2,y2 = picLabels[2]:GetPos()
		local x3,y3 = picLabels[3]:GetPos()
		surface.DrawRect( 0, 0, picD + 20, picD + ySpace ) 
		surface.DrawRect( x2 - x1 - 10, 0, picD + 20, picD + ySpace ) 
		surface.DrawRect( x3 - x1 - 10, 0, picD + 20, picD + ySpace ) 
	end
	local x,y = imagePanel:GetPos();
	
	selectedLabel:SetPos(CBx + 35, y + imagePanel:GetTall() + 10);
	selectedLabel:SetFont("MW2Font")
	selectedLabel:SetText("0 / 3  SELECTED")
	selectedLabel:SizeToContents()
	for i=1,3 do
		local x1,y1 = picLabels[i]:GetPos()
		killNumLabels[i] = vgui.Create("DLabel", DermaPanel)
		killNumLabels[i]:SetPos( x1, y1 + picD);
		killNumLabels[i]:SetFont("MW2Font2")
		killNumLabels[i]:SetText("")
		killNumLabels[i]:SizeToContents()
	end
	
	local x,y = selectedLabel:GetPos();
	
	local selectButton = vgui.Create("DButton", DermaPanel)
	selectButton:SetText("SAVE AND CLOSE")
	selectButton:SetPos(CBx + 35, y + selectedLabel:GetTall() + 5 )
	selectButton:SetSize(150,30)
	selectButton.DoClick = function()
		--PrintTable( selectedStreaks )
		selectedNums = 0;
		killNumLabels = {}
		numTab = {nil, nil, nil}
		net.Start("ChosenKillstreaks")
			net.WriteTable(selectedStreaks)
		net.SendToServer()
		--datastream.StreamToServer( "ChoosenKillstreaks", selectedStreaks )
		
		
		net.Start("setMW2PlayerVars")


			net.WriteBit(/*nuke and*/ 1 /*or 0*/)	//	SET VALUE TO ALWAYS BE TRUE. THE NUKE WILL *ALWAYS* HAVE AN EFFECT ON THE OWNER


		net.SendToServer()
		
		
		DermaFrame:Close();
		
		
		Frame_Number = 0	//	AFTER THE KILLSTREAK MENU HAS BEEN CLOSED, THE NUMBER OF KILLSTREAK MENUS *VISIBLE* IS ZERO (0)
		
		
	end
	
	
	DermaPanel.Paint = function() -- The paint function
		
		
		surface.SetDrawColor( 110, 110, 110, 255 ) -- What color ( R, B, G, A )
		
		
		surface.DrawRect( 0, 0, DermaPanel:GetWide(), DermaPanel:GetTall() )
	
	
	end
	
	
	if LocalPlayer():IsAdmin() == true then  //  SECURITY CHECK:  IF THE LOCAL PLAYER *IS AN ADMINISTRATOR*, THEN...
	
	
		PropertySheet:AddSheet( "Killstreak Menu", DermaPanel, "icon16/user.png", false, false, "Select Killstreaks" )	//	ADD A TAB CALLED "Killstreak Menu" TO THE MENU

	
		if UAV_ACTIVE == false and COUNTER_UAV_ACTIVE == false and EMP_ACTIVE == false then  //  CHECK:  IF THERE IS *NO* UAV, COUNTER UAV, OR EMP ACTIVE, THEN...
	
	
			PropertySheet:AddSheet( "Team Menu", MW2TeamsTab( DermaPanel ), "icon16/group.png", false, false, "Select Team" )	//	ADD A TAB CALLED "Team Menu" TO THE MENU


		else 	//  IF A UAV, COUNTER UAV, OR EMP *IS ACTIVE*, THEN...
		
		
			chat.AddText( Color( 255, 0, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THE TEAM MENU IS NOT AVAILABLE  -  THERE IS AN ACTIVE UAV, COUNTER-UAV, OR EMP!" )  //  PRINT A MESSAGE TO THE USER IN HIS OR HER CHAT FEED


		end  //  FINISH THE CHECK


		PropertySheet:AddSheet( "User Menu", MW2UserVars( DermaPanel ), "icon16/wrench.png", false, false, "Settings" )  //  ADD A TAB CALLED "User Menu" TO THE MENU
		
		
		PropertySheet:AddSheet( "Administrator Menu", MW2AdminVars( DermaPanel ), "icon16/key.png", false, false, "Administration Settings" )	//	ADD A SPECIAL TAB CALLED "Administrator Menu" TO THE MENU
		
	
	else	//	IF THE LOCAL PLAYER IS *NOT AN ADMINISTRATOR*, THEN...
	
	
		PropertySheet:AddSheet( "Killstreak Menu", DermaPanel, "icon16/user.png", false, false, "Select Killstreaks" )	//	ADD A TAB CALLED "Killstreak Menu" TO THE MENU

	
		if UAV_ACTIVE == false and COUNTER_UAV_ACTIVE == false and EMP_ACTIVE == false then  //  CHECK:  IF THERE IS *NO* UAV, COUNTER UAV, OR EMP ACTIVE, THEN...
	
	
			PropertySheet:AddSheet( "Team Menu", MW2TeamsTab( DermaPanel ), "icon16/group.png", false, false, "Select Team" )	//	ADD A TAB CALLED "Team Menu" TO THE MENU


		else	//  IF A UAV, COUNTER UAV, OR EMP *IS ACTIVE*, THEN...
		
		
			chat.AddText( Color( 255, 0, 0 ), "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  THE TEAM MENU IS NOT AVAILABLE  -  THERE IS AN ACTIVE UAV, COUNTER-UAV, OR EMP!" )  //  PRINT A MESSAGE TO THE USER IN HIS OR HER CHAT FEED


		end  //  FINISH THE CHECK


		PropertySheet:AddSheet( "User Menu", MW2UserVars( DermaPanel ), "icon16/wrench.png", false, false, "Settings" )  //  ADD A TAB CALLED "User Menu" TO THE MENU
	
	
	end  //  FINISH THE SECURITY CHECK
	
	
end  //  COMPLETE THE FUNCTION


net.Receive( "UAV_STATUS", function()	//	"LISTEN" FOR THE MESSAGE CALLED "UAV_STATUS" FROM THE SERVER


	UAV_ACTIVE = net.ReadBool()  //  SET THE CURRENT STATE OF THE UAV TO BE THE VALUE STORED IN THE MESSAGE ( net.ReadBool() )


	if UAV_ACTIVE == true and Frame_Number != 0 then  //  CHECK:  IF A UAV *IS ACTIVE*, **AND** A KILLSTREAK MENU IS *ALREADY OPEN*, THEN...


		DermaFrame:Close()  //  CLOSE THE KILLSTREAK MENU
		
		
		Frame_Number = 0  //	AFTER THE KILLSTREAK MENU HAS BEEN CLOSED, THE NUMBER OF KILLSTREAK MENUS *VISIBLE* IS ZERO (0)
		
		
	end  //  FINISH THE CHECK


end )  //	NOTIFY THE SYSTEM THAT THE MESSAGE HAS BEEN DEALT WITH APPROPRIATELY


net.Receive( "COUNTER_UAV_STATUS", function()	//	"LISTEN" FOR THE MESSAGE CALLED "COUNTER_UAV_STATUS" FROM THE SERVER


	COUNTER_UAV_ACTIVE = net.ReadBool()  //  SET THE CURRENT STATE OF THE COUNTER UAV TO BE THE VALUE STORED IN THE MESSAGE ( net.ReadBool() )


	if COUNTER_UAV_ACTIVE == true and Frame_Number != 0 then	//  CHECK:  IF A COUNTER UAV *IS ACTIVE*, **AND** A KILLSTREAK MENU IS *ALREADY OPEN*, THEN...


		DermaFrame:Close()	//  CLOSE THE KILLSTREAK MENU
		
		
		Frame_Number = 0	//	AFTER THE KILLSTREAK MENU HAS BEEN CLOSED, THE NUMBER OF KILLSTREAK MENUS *VISIBLE* IS ZERO (0)
		
		
	end  //  FINISH THE CHECK


end )	//	NOTIFY THE SYSTEM THAT THE MESSAGE HAS BEEN DEALT WITH APPROPRIATELY


net.Receive( "EMP_STATUS", function()	//	"LISTEN" FOR THE MESSAGE CALLED "EMP_STATUS" FROM THE SERVER


	EMP_ACTIVE = net.ReadBool()  //  SET THE CURRENT STATE OF THE EMP TO BE THE VALUE STORED IN THE MESSAGE ( net.ReadBool() )


	if EMP_ACTIVE == true and Frame_Number != 0 then	//  CHECK:  IF AN EMP *IS ACTIVE*, **AND** A KILLSTREAK MENU IS *ALREADY OPEN*, THEN...


		DermaFrame:Close()	//	CLOSE THE KILLSTREAK MENU
		
		
		Frame_Number = 0	//	AFTER THE KILLSTREAK MENU HAS BEEN CLOSED, THE NUMBER OF KILLSTREAK MENUS *VISIBLE* IS ZERO (0)
		
		
	end  //  FINISH THE CHECK


end )	//	NOTIFY THE SYSTEM THAT THE MESSAGE HAS BEEN DEALT WITH APPROPRIATELY


local function Check_Frame_Number()  //  CREATE A LOCAL FUNCTION CALLED:	"Check_Frame_Number"


	if Frame_Number == 0 then	//	DO A CHECK	-	IF THE CURRENT NUMBER OF KILLSTREAK MENUS VISIBLE (Frame_Number) IS EQUAL TO ZERO (0), THEN
	
	
		MW2KillstreakChooseFrame()	//	CREATE A KILLSTREAK MENU AND SHOW IT TO THE USER
	
	
		Frame_Number = Frame_Number + 1  //  AFTER THE KILLSTREAK MENU HAS BEEN CREATED, UPDATE THE CURRENT NUMBER OF KILLSTREAK MENUS THAT ARE VISIBLE
	
	
	else	//	IF THERE IS ALREADY A KILLSTREAK MENU SHOWING
	
	
		chat.AddText( "[ CALL OF DUTY - MODERN WARFARE 2 - KILLSTREAKS ADDON ]:  You may NOT have more than one window open at the same time!" )  //  PRINT A MESSAGE TO THE USER IN HIS OR HER CHAT FEED
	
	
	end  //  DO NOTHING MORE AND END THE CHECK
	

end  //  TELL THE SYSTEM THAT THE FUNCTION IS COMPLETE


concommand.Add( "OPEN_KILLSTREAK_MENU", Check_Frame_Number )	//	ADD A CONSOLE COMMAND CALLED:	OPEN_KILLSTREAK_MENU	-	WHEN THE COMMAND IS INPUT INTO THE CONSOLE, RUN THE CHECK FUNCTION EXPLAINED ABOVE