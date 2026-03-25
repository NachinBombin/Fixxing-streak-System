//if !MW2KillStreakAddon then return end


local function Killstreak_Options( PANEL )	//	CREATE LOCAL FUNCTION CALLED "Killstreak_Options"  -  ACCEPT THE "PANEL" AS THE PARAMETER


	PANEL:ClearControls()	//	CLEAR ALL CONTROLS ON THE PANEL
	
	
	Menu_Button = {}  //  CREATE A MENU BUTTON AND CALL IT:  Menu_Button
	
	
		Menu_Button.Label = "Killstreak Menu"	//	SET THE *LABEL* OF THE BUTTON TO "Killstreak Menu"
	
	
		Menu_Button.Command = "Open_Killstreak_Menu"	//	WHEN CLICKING THE BUTTON, DISPLAY THE KILLSTREAK MENU
	
	
	PANEL:AddControl( "Button", Menu_Button )	//	ADD THE NEWLY-CREATED BUTTON TO THE PANEL
	
	
end  //  COMPLETE THE FUNCTION


local function Load_Menu()	//	CREATE LOCAL FUNCTION CALLED:  Load_Menu()

		
	spawnmenu.AddToolMenuOption( "Utilities", "User", "MW2KillStreaksUser", "Modern Warfare 2 - Killstreaks Addon", "", "", Killstreak_Options )	//	ADD TO THE "UTILITIES" TAB A "Modern Warfare 2 - Killstreaks Addon" OPTION UNDER "User"  -  RUN CUSTOM FUNCTION CALLED "Killstreak_Options"


end  //  COMPLETE THE FUNCTION


hook.Add( "PopulateToolMenu", "MW2KillstreakMenus", Load_Menu )  //	 ADD CUSTOM HOOK:	POPULATE THE MENU BY RUNNING CUSTOM FUNCTION "Load_Menu" ABOVE