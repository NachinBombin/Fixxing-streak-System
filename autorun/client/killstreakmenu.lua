local function Killstreak_Options( PANEL )
	PANEL:ClearControls()
	local Menu_Button = {}
	Menu_Button.Label   = "Killstreak Menu"
	Menu_Button.Command = "Open_Killstreak_Menu"
	PANEL:AddControl( "Button", Menu_Button )
end

local function Load_Menu()
	spawnmenu.AddToolMenuOption( "Utilities", "User", "MW2KillStreaksUser", "Modern Warfare 2 - Killstreaks Addon", "", "", Killstreak_Options )
end

hook.Add( "PopulateToolMenu", "MW2KillstreakMenus", Load_Menu )
