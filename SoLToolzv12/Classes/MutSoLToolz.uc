// ====================================================================
// SoL Tools Mutator v4.0
//
// Written by xDemic
// (C) 2013, XDMC, Inc. All Rights Reserved
// ====================================================================
// Modified by void 2013
// ====================================================================
// v12.0 modified by Attila
// ====================================================================

class MutSoLToolz extends Mutator Config(SoLToolz);

var const string RulesGroup_Buttons;
var const string RulesGroup_Llama;
var const string RulesGroup_Misc;

var private PlayerController LocalPC;
var private int BackupMaxSpectators;

var config string Button1Text;
var config string Button1URL;
var config string Button2Text;
var config string Button2URL;
var config string Button3Text;
var config string Button3URL;
var config bool bLateJoinersToSpec;
var config bool bSimpleTradeMenu;
var config bool bTalkingIcon;
var config string MsgOnForceSwitchTeam;
var config string MsgOnForceSpectate;
var config string MsgOnAutoSpectate;
var config string LlamaText1;
var config string LlamaText2;
var config string LlamaText3;
var config string LlamaText4;
var config string LlamaText5;
var config string LlamaText6;
var config string LlamaText7;
var config string LlamaText8;
var config string CustomMessage1;
var config string CustomMessage2;
var config string CustomMessage3;
var config array<string> TradeMenu;
var config array<string> MutedPlayers;
var array<string> Llamas;

var string RepButton1Text;
var string RepButton1URL;
var string RepButton2Text;
var string RepButton2URL;
var string RepButton3Text;
var string RepButton3URL;
var bool bRepSimpleTradeMenu;
var string RepMsgOnForceSwitchTeam;
var string RepMsgOnForceSpectate;
var string RepMsgOnAutoSpectate;
var string RepCustomMessage1;
var string RepCustomMessage2;
var string RepCustomMessage3;
var bool bSendAutoSpectMessage;
var class<Combo> NecroComboClass;

// currently moved pawn's inventory backup
var array<class<Weapon> >         HeldWeapon;
var array<int>                    HeldAmmo;
var array<int>                    HeldAltAmmo;
var int                           SavedHealth;
var int                           SavedShield;

replication
{
    reliable if (bNetInitial && Role==ROLE_Authority)
        RepMsgOnForceSpectate, RepMsgOnForceSwitchTeam, RepMsgOnAutoSpectate, bSendAutoSpectMessage,
        RepButton1Text, RepButton1URL, RepButton2Text, RepButton2URL, RepButton3Text, RepButton3URL,
        bRepSimpleTradeMenu, RepCustomMessage1, RepCustomMessage2, RepCustomMessage3;
}


static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting(default.RulesGroup_Buttons, "Button1Text", "Custom Button Text", 0, 11, "Text", "32");
    PlayInfo.AddSetting(default.RulesGroup_Buttons, "Button1URL", "Custom Button URL", 0, 12, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Buttons, "Button2Text", "Custom Button Text", 0, 13, "Text", "32");
    PlayInfo.AddSetting(default.RulesGroup_Buttons, "Button2URL", "Custom Button URL", 0, 14, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Buttons, "Button3Text", "Custom Button Text", 0, 15, "Text", "32");
    PlayInfo.AddSetting(default.RulesGroup_Buttons, "Button3URL", "Custom Button URL", 0, 16, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText1", "Llama Text", 0, 21, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText2", "Llama Text", 0, 22, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText3", "Llama Text", 0, 23, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText4", "Llama Text", 0, 24, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText5", "Llama Text", 0, 25, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText6", "Llama Text", 0, 26, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText7", "Llama Text", 0, 27, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Llama, "LlamaText8", "Llama Text", 0, 28, "Text", "256");
	PlayInfo.AddSetting(default.RulesGroup_Misc, "bLateJoinersToSpec", "Late Joining Players To Spec", 0, 30, "Check");
	PlayInfo.AddSetting(default.RulesGroup_Misc, "bSimpleTradeMenu", "Simplify Trade Menu", 0, 31, "Check");
	PlayInfo.AddSetting(default.RulesGroup_Misc, "bTalkingIcon", "Talking Icons", 0, 32, "Check");
    PlayInfo.AddSetting(default.RulesGroup_Misc, "MsgOnForceSwitchTeam", "Message To Players On Force Switch Team", 0, 33, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Misc, "MsgOnForceSpectate", "Message To Players On Force Spectate", 0, 34, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Misc, "MsgOnAutoSpectate", "Message To Players On Auto Spectate", 0, 35, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Misc, "CustomMessage1", "Custom Warning Message 1", 0, 36, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Misc, "CustomMessage2", "Custom Warning Message 2", 0, 37, "Text", "256");
    PlayInfo.AddSetting(default.RulesGroup_Misc, "CustomMessage3", "Custom Warning Message 3", 0, 38, "Text", "256");
}

static function string GetDescriptionText(string PropName)
{
	return PropName;
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	local int i, j;

    Super.GetServerDetails(ServerState);

    if(class'ServerSettings'.default.bReportServerAsDM)
        ServerState.GameType = "xDeathMatch";

    if(class'ServerSettings'.default.ServerColorName != "")
        ServerState.ServerName = class'ServerSettings'.default.ServerColorName;

    if(class'ServerSettings'.default.MapColorPrefix != "")
        ServerState.MapName = class'ServerSettings'.default.MapColorPrefix $ ServerState.MapName;

    i = ServerState.ServerInfo.Length;
    ServerState.ServerInfo.Length = i + 1;
	ServerState.ServerInfo[i].Key = "SoLToolz version";
   	ServerState.ServerInfo[i++].Value = "v12";

    for (j = 0; j < class'ServerSettings'.default.ServerDetails.Length; j++)
    {
        if(class'ServerSettings'.default.ServerDetails[j].Setting == "" ||
           class'ServerSettings'.default.ServerDetails[j].Value == "")
        {
            continue;
        }
        ServerState.ServerInfo.Length = i + 1;
        ServerState.ServerInfo[i].Key = class'ServerSettings'.default.ServerDetails[j].Setting;
        ServerState.ServerInfo[i++].Value = class'ServerSettings'.default.ServerDetails[j].Value;
    }
}

function PreBeginPlay()
{
    Super.PreBeginPlay();

    Level.Game.bPauseable = false;
    Level.Game.bAdminCanPause = false;
    RepButton1Text = Button1Text;
    RepButton1URL = Button1URL;
    RepButton2Text = Button2Text;
    RepButton2URL = Button2URL;
    RepButton3Text = Button3Text;
    RepButton3URL = Button3URL;
    bRepSimpleTradeMenu = bSimpleTradeMenu;
    RepMsgOnForceSwitchTeam = MsgOnForceSwitchTeam;
    RepMsgOnForceSpectate = MsgOnForceSpectate;
    RepMsgOnAutoSpectate = MsgOnAutoSpectate;
    RepCustomMessage1 = CustomMessage1;
    RepCustomMessage2 = CustomMessage2;
    RepCustomMessage3 = CustomMessage3;

    Spawn(class'SoLBroadcastHandler');
}

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
	super.ModifyLogin(Portal, Options);

    if(bLateJoinersToSpec && Level.GRI.bMatchHasBegun && !Level.Game.bGameEnded)
    {
        if (!bSendAutoSpectMessage && MsgOnAutoSpectate != "")
            bSendAutoSpectMessage = true;

        if (!SetSpec(Options))
        {
            Options $= "?SpectatorOnly=1";
            // temporay raise spect slots to make sure player can join there when spectating forced by "force-to-spec"
            BackupMaxSpectators = Level.Game.MaxSpectators;
            Level.Game.MaxSpectators = 32;
        }
        else
            BackupMaxSpectators = -1;
    }
    else
        BackupMaxSpectators = -1;
}

function ModifyPlayer(Pawn Other)
{
    local ChatIconControl CC;

    Super.ModifyPlayer(Other);

    if(!bTalkingIcon || PlayerController(Other.Controller) == None || Other.PlayerReplicationInfo == None)
        return;

    if(Other.FindInventoryType(class'ChatIconControl') != None)
        return;

    CC = Spawn(class'ChatIconControl', Other);
    if( CC != None )
        Other.AddInventory(CC);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (PlayerReplicationInfo(Other) != None && PlayerController(Other.Owner) != None && BackupMaxSpectators > 0)
    {
        Level.Game.MaxSpectators = BackupMaxSpectators;
        BackupMaxSpectators = -1;
    }

	return true;
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
				ComboClass = class<Combo>(DynamicLoadObject(xPlayer(C).ComboNameList[i], class'Class', true));
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
    if (Level.NetMode == NM_DedicatedServer)
    {
        Disable('Tick');
        return;
    }

    if (LocalPC == None)
        LocalPC = Level.GetLocalPlayerController();

    if ( (LocalPC != None) && (LocalPC.Player != None) && (LocalPC.Player.InteractionMaster != None) && (LocalPC.GameReplicationInfo != None) )
    {
        LocalPC.Player.InteractionMaster.AddInteraction(string(Class'ReplcPlayerLoginControlsInteraction'), LocalPC.Player);
        LocalPC.ServerMutate("sol_login");
        GotoState('WaitForMenuClose');
        return;
    }
}

simulated state WaitForMenuClose
{
    simulated function Tick(float DeltaTime)
    {
        if (GUIController(LocalPC.Player.GUIController).Count() == 0)
            GotoState('ShowSpectMessage');
    }
}

simulated state ShowSpectMessage
{
    simulated function Tick(float DeltaTime)
    {
        if (bSendAutoSpectMessage && RepMsgOnAutoSpectate != "")
        {
            LocalPC.ClientMessage(class'SoLMessages'.static.StripColor(RepMsgOnAutoSpectate), 'CriticalEvent');
            LocalPC.ClientReliablePlaySound(class'SoLMessages'.default.TeamSwitchSound);

            GotoState('NoTick');
        }
    }

Begin:
    Sleep(5.0);
    GotoState('NoTick');
}

simulated state NoTick
{
    ignores Tick;
}

simulated function PostNetReceive()
{
    if (RepMsgOnForceSwitchTeam != "")
        class'SoLMessages'.default.TeamSwitchedMessage = RepMsgOnForceSwitchTeam;

    if (RepMsgOnForceSpectate != "")
        class'SoLMessages'.default.SpectatedMessage = RepMsgOnForceSpectate;

    class'SoLMessages'.default.Warnings[0] = RepCustomMessage1;
    class'SoLMessages'.default.Warnings[1] = RepCustomMessage2;
    class'SoLMessages'.default.Warnings[2] = RepCustomMessage3;
}

private function bool IsGUIDOnline(string GUID)
{
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
        if(PlayerController(C) != None && PlayerController(C).GetPlayerIDHash() ~= Left(GUID, 32))
            return true;

    return false;
}

function Mutate(string Data, PlayerController Sender)
{
    local int ThePlayerID;
    local Controller C;
    local int i;
    local SoLPlayerReplicationInfo RI;

    if (left(Data, 9) ~= "sol_login")
    {
        RI = class'SoLPlayerReplicationInfo'.static.SpawnFor(Sender.PlayerReplicationInfo);
        if (RI == None)
            Warn("Failed to spawn SoLPlayerReplicationInfo!");
        return;
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

        if (left(Data, 16) ~= "admin trade list")
        {
            for (i = 0; i < TradeMenu.Length; i++)
                if (!IsGUIDOnline(TradeMenu[i]))
                    Sender.ClientMessage(i @ TradeMenu[i]);
            return;
        }

        if (left(Data, 19) ~= "admin trade delete " && len(Data) > 19)
        {
            ThePlayerID = int(right(Data, len(Data) - 19));
            Sender.ClientMessage(i @ TradeMenu[i] @ "no longer trade");
            TradeMenu.Remove(ThePlayerID, 1);
            return;
        }

        if (left(Data, 16) ~= "admin muted list")
        {
            for (i = 0; i < MutedPlayers.Length; i++)
                if (!IsGUIDOnline(MutedPlayers[i]))
                    Sender.ClientMessage(i @ MutedPlayers[i]);
            return;
        }

        if (left(Data, 19) ~= "admin muted delete " && len(Data) > 19)
        {
            ThePlayerID = int(right(Data, len(Data) - 19));
            Sender.ClientMessage(i @ TradeMenu[i] @ "no longer muted");
            TradeMenu.Remove(ThePlayerID, 1);
            return;
        }
    }

    RI = class'SoLPlayerReplicationInfo'.static.GetFor(Sender.PlayerReplicationInfo);
    if ( Sender.PlayerReplicationInfo != None && (Sender.PlayerReplicationInfo.bAdmin || (RI != None && RI.bTradeMenu)) )
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

        if (bSimpleTradeMenu && (Sender.PlayerReplicationInfo == None || !Sender.PlayerReplicationInfo.bAdmin))
        {
            Super.Mutate(Data, Sender);
            return;     // no more options for simple traders
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

        if (left(Data, 13) ~= "admin scream " && len(Data) > 13)
        {
           SendBlueMessage(right(Data, len(Data) - 13) );
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
					return;
                }
             }
        }
    }
    Super.Mutate(Data,Sender);
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
    PlayerController(Player).ReceiveLocalizedMessage(class'SoLMessages', 1);
}

function AdminForceSpectate(Controller Player)
{
 PlayerController(Player).BecomeSpectator();

 if ( PlayerController(Player) != None)
    PlayerController(Player).ReceiveLocalizedMessage(class'SoLMessages', 2);
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
        Player.ClientMessage(class'SoLMessages'.static.StripColor(Message), 'CriticalEvent');

    Player.ClientReliablePlaySound(class'SoLMessages'.default.TeamSwitchSound);
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="SoL Toolz v12"
     Description="Adds additional features to the mid-game menu."
     bAlwaysRelevant=true
     // bNetTemporary=true
     RemoteRole=ROLE_SimulatedProxy
     bNetNotify=true
     Group="SoLToolz"
     RulesGroup="SoL Toolz v12"
     RulesGroup_Buttons="SoL Toolz v12 - Buttons"
     RulesGroup_Llama="SoL Toolz v12 - Llama"
     RulesGroup_Misc="SoL Toolz v12 - Misc"
     // bAutoResurrect=true
     bLateJoinersToSpec=true
     MsgOnForceSwitchTeam=""
     MsgOnForceSpectate=""
     MsgOnAutoSpectate=""
}
