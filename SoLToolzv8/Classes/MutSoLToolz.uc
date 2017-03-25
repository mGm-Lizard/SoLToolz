// ====================================================================
// SoL Tools Mutator v4.0
//
// Written by xDemic
// (C) 2013, XDMC, Inc. All Rights Reserved
// ====================================================================
// Modified by void 2013
// ====================================================================
// v4.0 modified by Attila (xfire, skype: attila7600)
// ====================================================================

class MutSoLToolz extends Mutator Config(SoLToolz);

var config string Button1Text;
var config string Button1URL;
var config string Button2Text;
var config string Button2URL;
var config string Button3Text;
var config string Button3URL;
var config bool bLateJoinersToSpec;
var config bool bShowRevokeMenu;
var config string MsgOnForceSwitchTeam;
var config string MsgOnForceSpectate;
var config array<string> TradeMenu;
// var config bool bAutoResurrect;

var string RepButton1Text;
var string RepButton1URL;
var string RepButton2Text;
var string RepButton2URL;
var string RepButton3Text;
var string RepButton3URL;
var string RepTradeMenu;
var bool bRepShowRevokeMenu;
var string RepMsgOnForceSwitchTeam;
var string RepMsgOnForceSpectate;
var class<Combo> NecroComboClass;

// currently moved pawn's inventory backup
var array<class<Weapon> >         HeldWeapon;
var array<int>                    HeldAmmo;
var array<int>                    HeldAltAmmo;
var int                           SavedHealth;
var int                           SavedShield;

// var Sound Beep;

replication
{
    reliable if ((bNetInitial || bNetDirty) && Role==ROLE_Authority)
      RepTradeMenu, bRepShowRevokeMenu, RepMsgOnForceSpectate, RepMsgOnForceSwitchTeam,
      RepButton1Text, RepButton1URL, RepButton2Text, RepButton2URL, RepButton3Text, RepButton3URL;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting(default.RulesGroup, "Button1Text", "Custom Button Text", 0, 11, "Text", "32");
    PlayInfo.AddSetting(default.RulesGroup, "Button1URL", "Custom Button URL", 0, 12, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup, "Button2Text", "Custom Button Text", 0, 13, "Text", "32");
    PlayInfo.AddSetting(default.RulesGroup, "Button2URL", "Custom Button URL", 0, 14, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup, "Button3Text", "Custom Button Text", 0, 15, "Text", "32");
    PlayInfo.AddSetting(default.RulesGroup, "Button3URL", "Custom Button URL", 0, 16, "Text", "256");
	// PlayInfo.AddSetting(default.RulesGroup, "bAutoResurrect", "Auto-Activate Res Combo", 0, 13, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bLateJoinersToSpec", "Late Joining Players To Spec", 0, 17, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bShowRevokeMenu", "Show Revoke Menu Items", 0, 18, "Check");
    PlayInfo.AddSetting(default.RulesGroup, "MsgOnForceSwitchTeam", "Message To Players On Force Switch Team", 0, 19, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup, "MsgOnForceSpectate", "Message To Players On Force Spectate", 0, 20, "Text", "256");
}

static function string GetDescriptionText(string PropName)
{
	return PropName;
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	local int i;
    i = ServerState.ServerInfo.Length;
    ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "SoLToolz version";
   	ServerState.ServerInfo[i].Value = "v8";
}

function PreBeginPlay()
{
    Super.PreBeginPlay();

    SendTradeMenu();

    Level.Game.bPauseable = false;
    Level.Game.bAdminCanPause = false;
    bRepShowRevokeMenu = bShowRevokeMenu;
    RepMsgOnForceSwitchTeam = MsgOnForceSwitchTeam;
    RepMsgOnForceSpectate = MsgOnForceSpectate;
    RepButton1Text = Button1Text;
    RepButton1URL = Button1URL;
    RepButton2Text = Button2Text;
    RepButton2URL = Button2URL;
    RepButton3Text = Button3Text;
    RepButton3URL = Button3URL;    

    /* if(bAutoResurrect)
        SetTimer(3.0 * Level.TimeDilation, true);
    else
        SetTimer(0.0, false); */
}

/* function Timer()
{
    local Controller C;
    local Controller resRed, resBlue;
    local int reds, blues;
    local int redsOut, bluesOut;
    local int i;
    local class<Combo> ComboClass;

    for(C = Level.ControllerList; C != None; C = C.NextController)
    {
        if(C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.Team != None)
        {
            if(C.PlayerReplicationInfo.bOutOfLives)
            {
                if(C.PlayerReplicationInfo.Team.TeamIndex == 0)
                    redsOut++;
                if(C.PlayerReplicationInfo.Team.TeamIndex == 1)
                    bluesOut++;
            }
            else
            {
                if(C.PlayerReplicationInfo.Team.TeamIndex == 0)
                    reds++;
                if(C.PlayerReplicationInfo.Team.TeamIndex == 1)
                    blues++;
                if(C.Adrenaline >= 100.0)
                {
                    if(resRed == None && C.PlayerReplicationInfo.Team.TeamIndex == 0)
                        resRed = C;
                    if(resBlue == None && C.PlayerReplicationInfo.Team.TeamIndex == 1)
                        resBlue = C;
                }
            }
        }

        if(xPlayer(C) == None)
            continue;

        if(NecroComboClass == None)
        {
            for(i = 0; i < ArrayCount(xPlayer(C).ComboNameList); i++)
            {
                ComboClass = class<Combo>(DynamicLoadObject(xPlayer(C).ComboNameList[i], class'Class'));
                if( (ComboClass != None) &&
                    (ComboClass.default.keys[0] == 1) && (ComboClass.default.keys[1] == 1) &&
                    (ComboClass.default.keys[2] == 2) && (ComboClass.default.keys[3] == 2) )
                {
                    NecroComboClass = ComboClass;
                    // Log(Level.TimeSeconds $ " NECROCLASS IS " $ NecroComboClass);
                    break;
                }
            }
        }

        if(NecroComboClass == None)
        {
            // Log(Level.TimeSeconds $ " NO NECROCLASS");
            SetTimer(0.0, false);
            return;
        }
    }

    // Log(Level.TimeSeconds $ " reds=" $ reds $ ", blues=" $ blues $ ", redsOut=" $ redsOut $ ", bluesOut=" $ bluesOut);
    if(resRed != None && redsOut > 0 && blues > 0)
    {
        // Log(Level.TimeSeconds $ " FORCE RES ON " $ resRed.PlayerReplicationInfo.PlayerName);
        xPawn(resRed.Pawn).DoCombo(NecroComboClass);
        return;
    }
    if(resBlue != None && bluesOut > 0 && reds > 0)
    {
        // Log(Level.TimeSeconds $ " FORCE RES ON " $ resBlue.PlayerReplicationInfo.PlayerName);
        xPawn(resBlue.Pawn).DoCombo(NecroComboClass);
        return;
    }
} */

function bool SetSpec(out string Options)
{
	local string l, m, r;
	local int pos;
	pos = InStr(Options, "SpectatorOnly");
	if (pos != -1)
	{
		l = Left(Options, pos);
		//m = Mid(Options, pos, 15);
		r = Mid(Options, pos+15);
		pos = InStr(Options, "?");
		if (pos >= 0)
		{
			r = Mid(Options, pos);
		}
		else
		{
			r = "";
		}
		
		m = "SpectatorOnly=1";
		Options = l$m$r;
	}
	else
	{
		return false;
	}
	return true;
}

function ModifyLogin(out string Portal, out string Options)
{
	local bool bForceSpec;
	
	super.ModifyLogin(Portal, Options);
    
    if(bLateJoinersToSpec)
    {
        bForceSpec = Level.GRI.bMatchHasBegun && !Level.Game.bGameEnded;
        if (bForceSpec)
        {
            // Try toset spectator, if it returns false, append spectator (spectator flag not found)
            if (!SetSpec(Options))
                Options $= "?SpectatorOnly=1";
        }        
    }
}

function DoResOn(Controller C)
{
	local int i;
    local class<Combo> ComboClass;

	if(C != None)
	{
		if(NecroComboClass == None)
		{
			for(i = 0; i < ArrayCount(xPlayer(C).ComboNameList); i++)
			{
				ComboClass = class<Combo>(DynamicLoadObject(xPlayer(C).ComboNameList[i], class'Class'));
				if( (ComboClass != None) &&
					(ComboClass.default.keys[0] == 1) && (ComboClass.default.keys[1] == 1) &&
					(ComboClass.default.keys[2] == 2) && (ComboClass.default.keys[3] == 2) )
				{
					NecroComboClass = ComboClass;
					break;
				}
			}
		}
		
		if(NecroComboClass != None && xPawn(C.Pawn) != None && C.Adrenaline >= 100)
		{
			xPawn(C.Pawn).DoCombo(NecroComboClass);		
		}
	}
}

simulated function Tick(float DeltaTime)
{
    local PlayerController PC;
    
    if (Level.NetMode == NM_DedicatedServer)
    {
        Disable('Tick');
        return;
    }
    
    PC = Level.GetLocalPlayerController();
    if ( (PC != None) && (PC.Player != None) && (PC.Player.InteractionMaster != None) )
    {
        PC.Player.InteractionMaster.AddInteraction(string(Class'ReplcPlayerLoginControlsInteraction'),PC.Player);
        // Beep = Sound(DynamicLoadObject("AssaultSounds.HnShipFireReadyl01", class'Sound', true) );
        PC.ServerMutate("connected");
        Disable('Tick');
        return;
    }
}

simulated function ReceiveTradeMenu(string TradeMenu_t)
{
    local int i;

    i = Instr(TradeMenu_t, " ");
    if (i < 0)
        i = Len(TradeMenu_t);
    else
        ReceiveTradeMenu(Mid(TradeMenu_t, i + 1) );

    TradeMenu.Insert(0, 1);
    TradeMenu[0] = Left(TradeMenu_t, i);
}

simulated function PostNetReceive()
{
    if (Role == ROLE_Authority)
        return;
    
    Button1Text = RepButton1Text;
    Button1URL = RepButton1URL;
    Button2Text = RepButton2Text;
    Button2URL = RepButton2URL;
    Button3Text = RepButton3Text;
    Button3URL = RepButton3URL;
    
    TradeMenu.Length = 0;
    if (RepTradeMenu != "")
        ReceiveTradeMenu(RepTradeMenu);
    
    if (RepMsgOnForceSwitchTeam != "")
        class'Message_TeamSwitched'.default.TeamSwitchedMessage = RepMsgOnForceSwitchTeam;
    if (RepMsgOnForceSpectate != "")
        class'Message_TeamSwitched'.default.SpectatedMessage = RepMsgOnForceSpectate;
}

function Mutate(string Data, PlayerController Sender)
{
    local int ThePlayerID;
    local string Guid;
    local Controller C;
    local int i;
    local XNEWTab_ReplicationInfo RI;

    if ( left(Data, 9) ~= "connected" )
    {
       Guid = Sender.GetPlayerIDHash();
       for (i = 0; i < TradeMenu.Length; i++)
           if (Left(TradeMenu[i], Len(Guid)) ~= Guid)
           {
               foreach DynamicActors(class'XNEWTab_ReplicationInfo', RI)
                   if (RI.Player == Sender.PlayerReplicationInfo)
                       return;
               RI = Spawn(class'XNEWTab_ReplicationInfo');
               RI.Player = Sender.PlayerReplicationInfo;
               return;
           }
    }

    if ( Sender.PlayerReplicationInfo != None && Sender.PlayerReplicationInfo.bAdmin )
    {
        if (left(Data, 11) ~= "admin pause")
        {
           if (Level.Pauser == None)
               Level.Pauser = Sender.PlayerReplicationInfo;
           else
               Level.Pauser = None;
           return;
        }
    }

    if ( Sender.PlayerReplicationInfo != None && (Sender.PlayerReplicationInfo.bAdmin || CanTrade(Sender.PlayerReplicationInfo)) )
    {
        if ( left(Data, 17) ~= "admin changeteam " && len(Data) > 17 )
        {
             ThePlayerID = int(right(Data, len(Data) - 17));

             if ( ThePlayerID < 1 )
              return;

             for (C = Level.ControllerList; C != None; C = C.NextController)
             {
                if(C.PlayerReplicationInfo != None )
                     if ( C.PlayerReplicationInfo.PlayerID == ThePlayerID )
                     {
                       AdminForceSwitchTeam(C);
                       return;
                     }
             }
        }

        if ( left(Data, 15) ~= "admin spectate " && len(Data) > 15 )
        {
             ThePlayerID = int(right(Data, len(Data) - 15));

             if ( ThePlayerID < 1 )
              return;

             for (C = Level.ControllerList; C != None; C = C.NextController)
             {
                if(C.PlayerReplicationInfo != None )
                     if ( (C.PlayerReplicationInfo.PlayerID == ThePlayerID) && (PlayerController(C) != None) )
                     {
                       AdminForceSpectate(C);
                       return;
                     }
             }
        }

        if (left(Data, 14) ~= "admin killbot " && len(Data) > 14)
        {
             ThePlayerID = int( right(Data, len(Data) - 14) );

             if ( ThePlayerID < 1 )
              return;

             for (C = Level.ControllerList; C != None; C = C.NextController)
             {
                if(C.PlayerReplicationInfo != None)
                     if ( C.PlayerReplicationInfo.PlayerID == ThePlayerID )
                     {
                       DeathMatch(Level.Game).Killbot(C);
                       return;
                     }
             }
        }

        if (left(Data, 13) ~= "admin scream " && len(Data) > 13)
        {
           SendBlueMessage(right(Data, len(Data) - 13) );
        }

        if (left(Data, 12) ~= "admin regid " && len(Data) > 12)
        {
             ThePlayerID = int( right(Data, len(Data) - 12) );

             if ( ThePlayerID < 1 )
              return;

             for (C = Level.ControllerList; C != None; C = C.NextController)
             {
                if(C.PlayerReplicationInfo != None)
                {
                     if ( C.PlayerReplicationInfo.PlayerID == ThePlayerID )
                     {
                       if (AddRemoveAdmin(PlayerController(C), true) )
                       {
                           SaveConfig();
                           return;
                       }
                     }
                }
             }
        }

        if (left(Data, 14) ~= "admin unregid " && len(Data) > 14)
        {
             ThePlayerID = int( right(Data, len(Data) - 14) );

             if ( ThePlayerID-- < 1 )
                 return;

             for (C = Level.ControllerList; C != None; C = C.NextController)
             {
                 if (PlayerController(C) != None)
                 {
                     Guid = PlayerController(C).GetPlayerIDHash();
                     if (Left(TradeMenu[ThePlayerID], Len(Guid)) ~= Guid)
                     {
                       if (AddRemoveAdmin(PlayerController(C), false) )
                       {
                          SaveConfig();
                          return;
                       }
                     }
                 }
             }
             TradeMenu.Remove(ThePlayerID, 1);
             SendTradeMenu();
             SaveConfig();
             return;
        }

        if (left(Data, 15) ~= "admin forceres " && len(Data) > 15)
        {
             ThePlayerID = int( right(Data, len(Data) - 15) );

             if ( ThePlayerID < 1 )
                 return;

             for (C = Level.ControllerList; C != None; C = C.NextController)
             {
                if(C.PlayerReplicationInfo != None && C.PlayerReplicationInfo.PlayerID == ThePlayerID )
                {
					DoResOn(C);
					Log("Force Res On " $ C.PlayerReplicationInfo.PlayerName $ " !!! ");
					return;
                }
             }
        }
    }
    Super.Mutate(Data,Sender);
}

function bool CanTrade(PlayerReplicationInfo PRI)
{
    local XNEWTab_ReplicationInfo RI;

    if (PRI == None)
        return false;

    foreach PRI.DynamicActors(class'XNEWTab_ReplicationInfo', RI)
        if (RI.Player == PRI)
            return true;

    return false;
}

function SendTradeMenu()
{
    local string TradeMenu_t, NewName;
    local int i, j;

    for (i = 0; i < TradeMenu.Length; i++)
    {
        if (TradeMenu_t != "")
            TradeMenu_t $= " ";

        j = Instr(Mid(TradeMenu[i], 33), " ");
        if (j < 0)
            j = Len(TradeMenu[i]);

        NewName = Mid(TradeMenu[i], 33, j);
        if ( (NewName == "") || (NewName == " ") )
            TradeMenu_t $= ".";
        else
            TradeMenu_t $= NewName;
    }

    RepTradeMenu = TradeMenu_t;
    NetUpdateTime = Level.TimeSeconds - 1;
}

function bool AddRemoveAdmin(PlayerController Sender, bool bAdd)
{
    local string Guid;
    local int i;
    local XNEWTab_ReplicationInfo RI;

    Guid = Sender.GetPlayerIDHash();

    for (i = 0; i < TradeMenu.Length; i++)
        if (Left(TradeMenu[i], Len(Guid)) ~= Guid)
        {
            if (bAdd)
                return false;

            TradeMenu.Remove(i, 1);
            SendTradeMenu();

            foreach DynamicActors(class'XNEWTab_ReplicationInfo', RI)
                if (RI.Player == Sender.PlayerReplicationInfo)
                    RI.Destroy();
            return true;
        }

    if (!bAdd)
        return false;

    TradeMenu.Length = i + 1;
    TradeMenu[i] = Guid $ " " $ Sender.PlayerReplicationInfo.PlayerName;
    SendTradeMenu();

    foreach DynamicActors(class'XNEWTab_ReplicationInfo', RI)
        if (RI.Player == Sender.PlayerReplicationInfo)
            return true;

    RI = Spawn(class'XNEWTab_ReplicationInfo');
    RI.Player = Sender.PlayerReplicationInfo;
    return true;
}

// functions to safely switch player's or bot's team, keeping their weapons and health. ->
function SavePawnInv(Pawn P)
{
    local int Item;
    local Inventory Inv;
    local Weapon W;

    if (P == None)
        return;

    HeldWeapon.Length = 0;
    HeldAmmo.Length = 0;
    Item = 0;

    for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
    {
        W = Weapon(Inv);

        if (W != None)
        {
            HeldWeapon[Item]    = W.Class;
            HeldAmmo[Item]      = W.AmmoCharge[0];
            HeldAltAmmo[Item++] = W.AmmoCharge[1];
        }
    }

    SavedHealth = P.Health;
    SavedShield = P.ShieldStrength;
}

function RestorePawnInv(Pawn P)
{
    local int Item;
    local Weapon W;

    if (P == None)
        return;

    for (Item = 0; Item < HeldWeapon.Length; Item++)
    {
        W = Weapon(P.FindInventoryType(HeldWeapon[Item]) );

        if (W == None)
        {
            W = P.Spawn(HeldWeapon[Item],,,P.Location);
            if (W != None)
            {
                W.GiveTo(P);
                if (W != None)
                    W.PickupFunction(P);
            }
        }

        if (W != None)
        {
            W.AmmoCharge[0] = HeldAmmo[Item];
            W.AmmoCharge[1] = HeldAltAmmo[Item];
        }
    }

    P.Health = SavedHealth;
    P.ShieldStrength = SavedShield;
}

function SwitchTeam(Controller Player)
{
    local TeamInfo OldTeam;
    local bool bAlive;

    if (Player == None)
        return;

    bAlive = (Player.Pawn != None && Player.Pawn.Health > 0);
    OldTeam = Player.PlayerReplicationInfo.Team;

    if (Player.PlayerReplicationInfo.Team != None)
    {
        if (bAlive)
            SavePawnInv(Player.Pawn);

        Player.PlayerReplicationInfo.Team.RemoveFromTeam(Player);
        TeamGame(Level.Game).Teams[1-OldTeam.TeamIndex].AddToTeam(Player);

        if ( (Player.PlayerReplicationInfo.Team != OldTeam) && (Player.Pawn != None) )
        {
            //Player.Pawn.PlayerChangedTeam();
            Player.Pawn.Destroy();
            if (bAlive)
            {
                Level.Game.ReStartPlayer(Player);
                RestorePawnInv(Player.Pawn);
            }
            if (Bot(Player) != None)
            {
                if (Bot(Player).Squad != None)
                    Bot(Player).Squad.RemoveBot(Bot(Player));
                UnrealTeamInfo(Player.PlayerReplicationInfo.Team).AI.Squads.AddBot(Bot(Player));
            }
        }
    }
}
// <-
function AdminForceSwitchTeam(Controller Player)
{
 SwitchTeam(Player);

 if ( PlayerController(Player) != None)
    PlayerController(Player).ReceiveLocalizedMessage(class'Message_TeamSwitched', 1);
}

function AdminForceSpectate(Controller Player)
{
 PlayerController(Player).BecomeSpectator();

 if ( PlayerController(Player) != None)
    PlayerController(Player).ReceiveLocalizedMessage(class'Message_TeamSwitched', 2);
}

function SendBlueMessage(string Message)
{
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (PlayerController(C) != None)
            SendBlueMessageTo(PlayerController(C), Message);
    }
}

function SendBlueMessageTo(PlayerController Player, string Message)
{
    if (Message != "")
        Player.ClientMessage(Message, 'CriticalEvent');

    // if (Beep != None)
        // Player.ClientReliablePlaySound(Beep);
    Player.ClientReliablePlaySound(class'Message_TeamSwitched'.default.TeamSwitchSound);
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="SoL Toolz v8"
     Description="Adds additional features to the mid-game menu."
     bAlwaysRelevant=true
     RemoteRole=ROLE_SimulatedProxy
     bNetNotify=true
     Group="SoLToolzv8"
     RulesGroup="SoL Toolz v8"
     // bAutoResurrect=true
     bLateJoinersToSpec=true
     bShowRevokeMenu=false
     MsgOnForceSwitchTeam="Your team has been switched!"
     MsgOnForceSpectate="You have been moved to spectator!"
}
