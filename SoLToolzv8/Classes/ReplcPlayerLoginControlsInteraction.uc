// ====================================================================
// Interaction responsible for replacing original PlayerLoginControls panel
//
// Written by xDemic / Eliot
// (C) 2013, XDMC, Inc. All Rights Reserved
// ====================================================================
// Modified by void 2013
// ====================================================================

class ReplcPlayerLoginControlsInteraction extends Interaction;

var bool bMenuModified;

var bool bONS;
var bool bINV;

event NotifyLevelChange ()
{
  Master.RemoveInteraction(self);
}

final function ModifyMenu ()
{
  local UT2K4PlayerLoginMenu Menu;
  local int i;
  local GUITabButton GUITb;
  local string replacementClass;

  if (bMenuModified)
    return;

  Menu = UT2K4PlayerLoginMenu(GUIController(ViewportOwner.Actor.Player.GUIController).FindPersistentMenuByName(UnrealPlayer(ViewportOwner.Actor).LoginMenuClass));
  if ( Menu != None )
  {
    for ( i=0; i<Menu.C_Main.TabStack.Length;i++ ) //Find PlayerLoginControls in the GUITabButton array 'TabStack'
    {
      if ( Menu.C_Main.TabStack[i].MyPanel.IsA('UT2K4Tab_PlayerLoginControls') )
         GUITb = Menu.C_Main.TabStack[i];

      switch ( Menu.C_Main.TabStack[i].MyPanel.Class ) //ONS & INV loginmenu support.
      {
          case class'UT2k4Tab_PlayerLoginControlsOnslaught': replacementClass = "SoLToolzv8.XNEWTab_PlayerLoginControlsOnslaught";
          case class'UT2k4Tab_PlayerLoginControlsInvasion':  replacementClass = "SoLToolzv8.XNEWTab_PlayerLoginControlsInvasion";
          default: replacementClass = "SoLToolzv8.XNEWTab_PlayerLoginControls";
      }
    }

    Menu.c_Main.ReplaceTab(GUITb, "Game", replacementClass,, "Game Controls"); //Replace with ours
    Menu.C_Main.ActivateTab(GUITb,true); //Active tab when we open esc.
    bMenuModified = true;
  }
}

function Tick (float DeltaTime)
{
  if (!bMenuModified)
  {
    ModifyMenu();
  }
}

exec function Scream(string Message)
{
  ViewportOwner.Actor.ServerMutate("admin scream " $ Message);
}

exec function BindScream()
{
    local Console C;
    
    C = ViewportOwner.Actor.Player.Console;
	C.TypedStr = "Scream ";
	C.TypedStrPos = 7;
    C.TypingOpen();
}

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta )
{
    if  ( (Action == IST_Press) && (Key == IK_Pause) )
    {
        ViewportOwner.Actor.ServerMutate("admin pause");
        return true;
    }
    return false;
}

defaultproperties
{
     bRequiresTick=true
}
