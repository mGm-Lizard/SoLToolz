class SoLPlayerReplicationInfo extends ReplicationInfo;

var private MutSoLToolz Mut;
var private PlayerReplicationInfo PRI;

var bool bTradeMenu;
var bool bMuted;
var bool bLlama;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        PRI;

    reliable if ((bNetInitial || bNetDirty) && Role == ROLE_Authority)
        bTradeMenu, bMuted, bLlama;

    reliable if (Role < ROLE_Authority)
        ServerSetTradeMenu, ServerSetMuted, ServerSetLlama;
}

static function SoLPlayerReplicationInfo GetFor(PlayerReplicationInfo ThisPRI)
{
    local SoLPlayerReplicationInfo RI;

    if (ThisPRI == None)
        return None;

    foreach ThisPRI.DynamicActors(class'SoLPlayerReplicationInfo', RI)
        if (RI.PRI == ThisPRI)
            return RI;

    return None;
}

static function SoLPlayerReplicationInfo SpawnFor(PlayerReplicationInfo ThisPRI)
{
    local string PlayerGUID;
    local SoLPlayerReplicationInfo RI;

    if (ThisPRI == None || ThisPRI.Role < ROLE_Authority)      // no spawn for clients
        return None;

    foreach ThisPRI.DynamicActors(class'SoLPlayerReplicationInfo', RI)
    {
        if (RI.PRI == None || RI.Owner == None)
            RI.Destroy();
        if (RI.PRI == ThisPRI)
            return RI;
    }
    
    if (PlayerController(ThisPRI.Owner) != None && MessagingSpectator(ThisPRI.Owner) == None)
    {
        RI = ThisPRI.Spawn(default.Class, ThisPRI.Owner);
        RI.PRI = ThisPRI;

        RI.InitMutator();
        PlayerGUID = PlayerController(ThisPRI.Owner).GetPlayerIDHash();
        RI.InitTradeMenu(PlayerGUID);
        RI.InitMuted(PlayerGUID);
        RI.InitLlama(PlayerGUID);

        return RI;
    }

    return None;
}

// internal.
protected function InitMutator()
{
    local Mutator M;

    for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
        if (MutSoLToolz(M) != None)
        {
            Mut = MutSoLToolz(M);
            return;
        }
}

protected function InitTradeMenu(string PlayerGUID)
{
    local int i;

    bTradeMenu = false;

    for (i = 0; i < Mut.TradeMenu.Length; i++)
        if(Left(Mut.TradeMenu[i], 32) ~= PlayerGUID)
        {
            bTradeMenu = true;
            return;
        }
}

protected function InitMuted(string PlayerGUID)
{
    local int i;

    bMuted = false;

    for (i = 0; i < Mut.MutedPlayers.Length; i++)
        if(Left(Mut.MutedPlayers[i], 32) ~= PlayerGUID)
        {
            bMuted = true;
            return;
        }
}

protected function InitLlama(string PlayerGUID)
{
    local int i;

    bLlama = false;

    for (i = 0; i < Mut.Llamas.Length; i++)
        if(Left(Mut.Llamas[i], 32) ~= PlayerGUID)
        {
            bLlama = true;
            return;
        }
}

// client -> server
simulated function SetTradeMenu(bool bNewTradeMenu)
{
    local PlayerController OwnPC;
    local SoLPlayerReplicationInfo OwnRI;
    
    if (bTradeMenu == bNewTradeMenu)
        return;
    
    OwnPC = Level.GetLocalPlayerController();
    if (OwnPC != None)
        OwnRI = class'SoLPlayerReplicationInfo'.static.GetFor(OwnPC.PlayerReplicationInfo);
    if (OwnPC != None && OwnRI != None)     // c-s replication only work reliable with players' own objects
        OwnRI.ServerSetTradeMenu(OwnPC, self, bNewTradeMenu);
}

protected function ServerSetTradeMenu(PlayerController Sender, SoLPlayerReplicationInfo Context, bool bNewTradeMenu)
{
    local int i;
    local string PlayerGUID;
    
    if (Context != self)
    {
        Context.ServerSetTradeMenu(Sender, Context, bNewTradeMenu);
        return;
    }
    
    if (bTradeMenu == bNewTradeMenu ||
        Sender == None || Sender.PlayerReplicationInfo == None || !Sender.PlayerReplicationInfo.bAdmin ||
        PlayerController(Owner) == None || PlayerController(Owner).PlayerReplicationInfo == None)
    {
        return;
    }

    PlayerGUID = PlayerController(Owner).GetPlayerIDHash();

    for (i = Mut.TradeMenu.Length - 1; i >= 0; i--)
        if (Left(Mut.TradeMenu[i], 32) ~= PlayerGUID)
            break;

    if (bNewTradeMenu && i < 0)
    {
        if (Mut.TradeMenu.Length == 1 && Mut.TradeMenu[0] == "")
            Mut.TradeMenu[0] = PlayerGUID $ " " $ PlayerController(Owner).PlayerReplicationInfo.PlayerName;
        else
            Mut.TradeMenu[Mut.TradeMenu.Length] = PlayerGUID $ " " $ PlayerController(Owner).PlayerReplicationInfo.PlayerName;
    }

    if (!bNewTradeMenu && i >= 0)
    {
        if (Mut.TradeMenu.Length == 1)
            Mut.TradeMenu[0] = "";          // not remove last element because of UT's bug
        else
            Mut.TradeMenu.Remove(i, 1);
    }

    Mut.SaveConfig();

    bTradeMenu = bNewTradeMenu;
    // bMuted = bNewMuted;
    // bLlama = bNewLlama;
}

simulated function SetMuted(bool bNewMuted)
{
    local PlayerController OwnPC;
    local SoLPlayerReplicationInfo OwnRI;
    
    if (bMuted == bNewMuted)
        return;

    OwnPC = Level.GetLocalPlayerController();
    if (OwnPC != None)
        OwnRI = class'SoLPlayerReplicationInfo'.static.GetFor(OwnPC.PlayerReplicationInfo);
    if (OwnPC != None && OwnRI != None)
        OwnRI.ServerSetMuted(OwnPC, self, bNewMuted);
}

protected function ServerSetMuted(PlayerController Sender, SoLPlayerReplicationInfo Context, bool bNewMuted)
{
    local int i;
    local string PlayerGUID;

    if (Context != self)
    {
        Context.ServerSetMuted(Sender, Context, bNewMuted);
        return;
    }
    
    if (bMuted == bNewMuted ||
        Sender == None || Sender.PlayerReplicationInfo == None || !Sender.PlayerReplicationInfo.bAdmin ||
        PlayerController(Owner) == None || PlayerController(Owner).PlayerReplicationInfo == None)
    {
        return;
    }

    PlayerGUID = PlayerController(Owner).GetPlayerIDHash();

    for (i = Mut.MutedPlayers.Length - 1; i >= 0; i--)
        if (Left(Mut.MutedPlayers[i], 32) ~= PlayerGUID)
            break;

    if (bNewMuted && i < 0)
    {
        if (Mut.MutedPlayers.Length == 1 && Mut.MutedPlayers[0] == "")
            Mut.MutedPlayers[0] = PlayerGUID $ " " $ PlayerController(Owner).PlayerReplicationInfo.PlayerName;
        else
            Mut.MutedPlayers[Mut.MutedPlayers.Length] = PlayerGUID $ " " $ PlayerController(Owner).PlayerReplicationInfo.PlayerName;
    }

    if (!bNewMuted && i >= 0)
    {
        if (Mut.MutedPlayers.Length == 1)
            Mut.MutedPlayers[0] = "";
        else
            Mut.MutedPlayers.Remove(i, 1);
    }    

    Mut.SaveConfig();

    bMuted = bNewMuted;
}

simulated function SetLlama(bool bNewLlama)
{
    local PlayerController OwnPC;
    local SoLPlayerReplicationInfo OwnRI;
    
    if (bLlama == bNewLlama)
        return;

    OwnPC = Level.GetLocalPlayerController();
    if (OwnPC != None)
        OwnRI = class'SoLPlayerReplicationInfo'.static.GetFor(OwnPC.PlayerReplicationInfo);
    if (OwnPC != None && OwnRI != None)
        OwnRI.ServerSetLlama(OwnPC, self, bNewLlama);
}

protected function ServerSetLlama(PlayerController Sender, SoLPlayerReplicationInfo Context, bool bNewLlama)
{
    local int i;
    local string PlayerGUID;

    if (Context != self)
    {
        Context.ServerSetLlama(Sender, Context, bNewLlama);
        return;
    }
    
    if (bLlama == bNewLlama ||
        Sender == None || Sender.PlayerReplicationInfo == None || !Sender.PlayerReplicationInfo.bAdmin ||
        PlayerController(Owner) == None || PlayerController(Owner).PlayerReplicationInfo == None)
    {
        return;
    }

    PlayerGUID = PlayerController(Owner).GetPlayerIDHash();

    for (i = Mut.Llamas.Length - 1; i >= 0; i--)
        if (Left(Mut.Llamas[i], 32) ~= PlayerGUID)
            break;

    if (bNewLlama && i < 0)
        Mut.Llamas[Mut.Llamas.Length] = PlayerGUID $ " " $ PlayerController(Owner).PlayerReplicationInfo.PlayerName;

    if (!bNewLlama && i >= 0)
        Mut.Llamas.Remove(i, 1);

    bLlama = bNewLlama;
}
