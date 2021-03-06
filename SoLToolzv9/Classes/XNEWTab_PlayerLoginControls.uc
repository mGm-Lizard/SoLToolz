// ====================================================================
// Tab for login/midgame menu that has an added admin only teamswap,
// team trade, and killbot features.
//
// Written by xDemic
// (C) 2013, XDMC, Inc. All Rights Reserved
// ====================================================================
// Modified by void 2013
// ====================================================================

class XNEWTab_PlayerLoginControls extends UT2K4Tab_PlayerLoginControls;

var localized string SwitchTeamPlayer;
var localized string KillBot;

var localized string TradeString;
var localized string TradeSelectionError;

var bool bTradeMode;
var bool bNonAdminMenu; //true if not admin

var automated GUILabel l_TradeHint;
var automated GUIButton b_TradeTeam;
var automated GUIButton b_UserButton1;
var automated GUIButton b_UserButton2;
var automated GUIButton b_UserButton3;

var array<name> MenuCommand;
var MutSoLToolz Mut;

//============================
// Player trade feature code
//============================
function bool Trade(GUIComponent Sender)
{
   if (!bTeamGame )
    return false;

   bTradeMode = !bTradeMode;

   if ( bTradeMode )
   {
     b_TradeTeam.Caption = "�@@OK";
     l_TradeHint.Caption = TradeString;
   } else if ( PlayersAreSelected() ) {
     TradeSelectedPlayers();
     b_TradeTeam.Caption = "�@@Trade Team";
     l_TradeHint.Caption = "";
   } else {
     b_TradeTeam.Caption = "�@@Trade Team";
     l_TradeHint.Caption = TradeSelectionError;
   }

   ResetSelection();

   return true;
}

function bool UserButtonClick(GUIComponent Sender)
{
  if (Mut == None)
      foreach PlayerOwner().DynamicActors(class'MutSoLToolz', Mut)
          break;
  if (Sender == b_UserButton1)
      PlayerOwner().ConsoleCommand("start " $ Mut.Button1URL);
  if (Sender == b_UserButton2)
      PlayerOwner().ConsoleCommand("start " $ Mut.Button2URL);
  if (Sender == b_UserButton3)
      PlayerOwner().ConsoleCommand("start " $ Mut.Button3URL);

  return false;
}

function TradeSelectedPlayers()
{
   PlayerOwner().ServerMutate("admin changeteam"@li_Red.GetExtra());
   PlayerOwner().ServerMutate("admin changeteam"@li_Blue.GetExtra());
   SetTimer(0.5,false); //This refreshes the panel in 0.5 seconds so the list updates after players switch
}

function bool PlayersAreSelected()
{
   if ( li_Red.GetExtra() != "" && li_Blue.GetExtra() != "" )
     return true;
   else
     return false;
}

function ListChange( GUIComponent Sender )
{
	local GUIList List;

     if ( bTradeMode ) //when trading players each list can be selected.
       return;

	List = GUIList(Sender);
	if ( List == None )
		return;

	if ( List != li_Red )
		li_Red.SilentSetIndex(-1);

	if ( List != li_FFA )
		li_FFA.SilentSetIndex(-1);

	if ( List != li_Blue && li_Blue != None )
		li_Blue.SilentSetIndex(-1);
}

function bool InternalOnPreDraw(Canvas C)
{
    local PlayerReplicationInfo PRI;
    local SoLPlayerReplicationInfo RI;

    PRI = PlayerOwner().PlayerReplicationInfo;
    if(PRI != None)
    {
        RI = class'SoLPlayerReplicationInfo'.static.GetFor(PRI);

        if ( PRI.bAdmin || (RI != None && RI.bTradeMenu) )
        {
            ShowAdminFeatures();
        }
        else
        {
            UnShowAdminFeatures();
        }
    }

  if (Mut == None)
  {
      foreach PlayerOwner().DynamicActors(class'MutSoLToolz', Mut)
          break;
  }

  if (Mut.Button1Text != "" && Mut.Button1URL != "")
  {
      b_UserButton1.bVisible = true;
      b_UserButton1.Caption = "@�@" $ Mut.Button1Text;
  }
  else
      b_UserButton1.bVisible = false;

  if (Mut.Button2Text != "" && Mut.Button2URL != "")
  {
      b_UserButton2.bVisible = true;
      b_UserButton2.Caption = "@�@" $ Mut.Button2Text;
  }
  else
      b_UserButton2.bVisible = false;

  if (Mut.Button3Text != "" && Mut.Button3URL != "")
  {
      b_UserButton3.bVisible = true;
      b_UserButton3.Caption = "@�@" $ Mut.Button3Text;
  }
  else
      b_UserButton3.bVisible = false;

  return Super.InternalOnPreDraw(C);
}

function SetButtonPositions(Canvas C)
{
  if (b_UserButton1.bVisible && (b_UserButton1.WinTop < b_Settings.WinTop ) )
      b_Settings.WinTop = b_UserButton1.WinTop;

  if (b_UserButton2.bVisible && (b_UserButton2.WinTop < b_Settings.WinTop ) )
      b_Settings.WinTop = b_UserButton2.WinTop;

  if (b_UserButton3.bVisible && (b_UserButton3.WinTop < b_Settings.WinTop ) )
      b_Settings.WinTop = b_UserButton3.WinTop;

  if (b_TradeTeam.bVisible && (b_TradeTeam.WinTop < b_Settings.WinTop ) )
      b_Settings.WinTop = b_TradeTeam.WinTop;

  Super.SetButtonPositions(C);
}


function ShowAdminFeatures()
{
   if ( bNonAdminMenu && bTeamGame  ) //admin Team Trade button.
   {
     b_TradeTeam.bVisible=true;
     b_TradeTeam.Caption="�@@Trade Team";
     bNonAdminMenu=false;
   }
}

function UnShowAdminFeatures() //Hide admin features and reset captions.
{
    if ( !bNonAdminMenu )
    {
      b_TradeTeam.bVisible=false;
      b_TradeTeam.Caption="�@@Trade Team";
      l_TradeHint.Caption="";
      ResetSelection();
      bTradeMode=false;
      bNonAdminMenu=true;
    }
}

function ResetSelection()
{
    if ( li_Red != None && li_Blue != None )
    {
      li_Red.SilentSetIndex(-1);
      li_Blue.SilentSetIndex(-1);
    }
}
//============================
// end of trade feature code
//============================

function bool ContextMenuOpened( GUIContextMenu Menu )
{
	local GUIList List;
	local PlayerReplicationInfo PRI;
	local GameReplicationInfo GRI;
    local SoLPlayerReplicationInfo RI;
    local bool bIsAdmin, bCanTrade;
    local bool bReturn;
    local int i;

    Menu.ContextItems.Length = 0;
    MenuCommand.Length = 0;
    bReturn = Super.ContextMenuOpened(Menu);

    PRI = PlayerOwner().PlayerReplicationInfo;
	bIsAdmin = PRI.bAdmin;
    RI = class'SoLPlayerReplicationInfo'.static.GetFor(PRI);
	bCanTrade = RI.bTradeMenu;
    RI.Timer();     // DEBUG, REMOVE!!!!!!!!!!!!!!!!!!!!!!!!!!!

    if (Mut == None)
    {
        foreach PlayerOwner().DynamicActors(class'MutSoLToolz', Mut)
            break;
    }

    GRI = GetGRI();
	if (GRI == None)
		return false;

	List = GUIList(Controller.ActiveControl);
	if (List == None || !List.IsValid() )
		return false;

	PRI = GRI.FindPlayerByID( int(List.GetExtra()) );
	if (PRI == None)
		return false;

    i = Menu.ContextItems.Length;

	if (bIsAdmin || bCanTrade)
	{
        if (i > 0)
            Menu.ContextItems[i++] = "-";

		if (PRI.bBot) {
			Menu.ContextItems[i] = KillBot$"["$List.Get()$"]";
			MenuCommand[i++] = 'KillBot';
		}

		if (bTeamGame) {
			Menu.ContextItems[i] = SwitchTeamPlayer$"["$List.Get()$"]";
			MenuCommand[i++] = 'SwitchTeam';
		}

		Menu.ContextItems[i] = "Goto spectator "$"["$List.Get()$"]";
		MenuCommand[i++] = 'Spectate';

        Menu.ContextItems[i++] = "-";
		Menu.ContextItems[i] = "Force use resurrect "$"["$List.Get()$"]";
		MenuCommand[i++] = 'ForceRes';
	}

    if (i > 0)
        Menu.ContextItems[i++] = "-";
	Menu.ContextItems[i] = "Whois "$"["$List.Get()$"]";
	MenuCommand[i++] = 'Whois';

    if (bIsAdmin)
    {
        RI = class'SoLPlayerReplicationInfo'.static.GetFor(PRI);

        Menu.ContextItems[i++] = "-";
        if (RI.bMuted) {
            Menu.ContextItems[i] = "UnMute "$"["$List.Get()$"]";
            MenuCommand[i++] = 'UnMute';
        } else {
            Menu.ContextItems[i] = "Mute "$"["$List.Get()$"]";
            MenuCommand[i++] = 'Mute';
        }
        if (RI.bLlama) {
            Menu.ContextItems[i] = "UnLlama "$"["$List.Get()$"]";
            MenuCommand[i++] = 'UnLlama';
        } else {
            Menu.ContextItems[i] = "Llama "$"["$List.Get()$"]";
            MenuCommand[i++] = 'Llama';
        }

        Menu.ContextItems[i++] = "-";
        if (RI.bTradeMenu) {
            Menu.ContextItems[i] = "Revoke trademenu from "$"["$List.Get()$"]";
            MenuCommand[i++] = 'RemoveTradeMenu';
        } else {
            Menu.ContextItems[i] = "Grant trademenu for "$"["$List.Get()$"]";
            MenuCommand[i++] = 'AddTradeMenu';
        }
    }

    return true;
}

function ContextClick(GUIContextMenu Menu, int ClickIndex)
{
	local GUIList List;
	local PlayerReplicationInfo PRI;
	local GameReplicationInfo GRI;
    local PlayerController PC;
    local SoLPlayerReplicationInfo RI;

    if (MenuCommand[ClickIndex] == '')
    {
        Super.ContextClick(Menu, ClickIndex);
        return;
    }

	GRI = GetGRI();
	if (GRI == None)
		return;

	List = GUIList(Controller.ActiveControl);
	if (List == None)
		return;

	PRI = GRI.FindPlayerById( int(List.GetExtra()) );
	if (PRI == None)
		return;

    RI = class'SoLPlayerReplicationInfo'.static.GetFor(PRI);
    PC = PlayerOwner();

    switch (MenuCommand[ClickIndex])
    {
        case 'KillBot':
            PC.ServerMutate("admin killbot"@List.GetExtra());
            SetTimer(0.5, false);
            break;
        case 'SwitchTeam':
            PC.ServerMutate("admin changeteam"@List.GetExtra());
            SetTimer(0.5, false);
            break;
        case 'Spectate':
            PC.ServerMutate("admin spectate"@List.GetExtra());
            SetTimer(0.5, false);
            break;
        case 'AddTradeMenu':
            if (RI != None)
                RI.SetTradeMenu(true);
            break;
        case 'RemoveTradeMenu':
            if (RI != None)
                RI.SetTradeMenu(false);
            break;
        case 'Mute':
            if (RI != None)
                RI.SetMuted(true);
            break;
        case 'UnMute':
            if (RI != None)
                RI.SetMuted(false);
            break;
        case 'Llama':
            if (RI != None)
                RI.SetLlama(true);
            break;
        case 'UnLlama':
            if (RI != None)
                RI.SetLlama(false);
            break;            
		case 'Whois':
			PC.ClientMessage("�*** Running Whois on"@PRI.PlayerName@"***");
            // try both. AntiTCC and ClanManager version
			PC.ConsoleCommand("WhoIs"@StripColorCodes(PRI.PlayerName));
			PC.ConsoleCommand("CM WhoIs"@StripColorCodes(PRI.PlayerName));

			Controller.CloseMenu(false);
			PC.ConsoleCommand("ConsoleToggle");
			break;
		case 'ForceRes':
			PC.ServerMutate("admin forceres"@List.GetExtra());
			break;
    }
}

//OnTimer delegate assigned to this, SetTimer(0.5,false) is used to refresh lists after team switch functions are called.
//Has to be on a timer because the team data isn't updated instantly.
function RefreshPanel(GUIComponent Sender)
{
ShowPanel(false);
ShowPanel(true);
}

defaultproperties
{
     SwitchTeamPlayer="Switch Team "
     KillBot="Kill Bot "
     TradeString="Select 2 players to trade and click OK"
     TradeSelectionError="Woops, you must select one player from each team."
     bNonAdminMenu=True

     Begin Object Class=GUILabel Name=TradeLabel
         TextAlign=TXTA_Center
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         StyleName="textLabel"
         WinTop=0.720000
         WinLeft=0.200000
         WinWidth=0.600000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_TradeHint=TradeLabel

     Begin Object Class=GUIButton Name=TradeTeamButton
         Caption="Trade Team"
         StyleName="SquareButton"
         OnClick=XNEWTab_PlayerLoginControls.Trade
         WinWidth=0.29000
         WinHeight=0.050000
         WinTop=0.750
         bVisible=false
         bAutoSize=true
         bBoundToParent=true
         bScaleToParent=true
     End Object
     b_TradeTeam=TradeTeamButton

     Begin Object Class=GUIButton Name=UserButton1
         Caption="UserButton1"
         StyleName="SquareButton"
         OnClick=XNEWTab_PlayerLoginControls.UserButtonClick
         WinWidth=0.29000
         WinHeight=0.050000
         WinTop=0.750
         bAutoSize=true
         bBoundToParent=true
         bScaleToParent=true
     End Object
     b_UserButton1=UserButton1

     Begin Object Class=GUIButton Name=UserButton2
         Caption="UserButton2"
         StyleName="SquareButton"
         OnClick=XNEWTab_PlayerLoginControls.UserButtonClick
         WinWidth=0.29000
         WinHeight=0.050000
         WinTop=0.750
         bAutoSize=true
         bBoundToParent=true
         bScaleToParent=true
     End Object
     b_UserButton2=UserButton2

     Begin Object Class=GUIButton Name=UserButton3
         Caption="UserButton3"
         StyleName="SquareButton"
         OnClick=XNEWTab_PlayerLoginControls.UserButtonClick
         WinWidth=0.29000
         WinHeight=0.050000
         WinTop=0.750
         bAutoSize=true
         bBoundToParent=true
         bScaleToParent=true
     End Object
     b_UserButton3=UserButton3

     OnTimer=XNEWTab_PlayerLoginControls.RefreshPanel
}
