// ====================================================================
// Tab for login/midgame menu that has all the important clickable controls
// This is the Invasion version (forces FFA mode even though Invasion is technically a team game)
//
// Written by Matt Oelfke
// (C) 2003, Epic Games, Inc. All Rights Reserved
// ====================================================================
// Modifed by xdemic to extend new PlayerLoginControls tab, 2\10\2013
// ====================================================================
// Modified by void 2013
// ====================================================================

class XNEWTab_PlayerLoginControlsInvasion extends XNEWTab_PlayerLoginControls;

function InitGRI()
{
	if ( !(GetGRI().GameClass == "Engine.GameInfo") )
	{
		bTeamGame = False;
		bFFAGame = True;
		Super.InitGRI();
	}
}

defaultproperties
{
}
