class XNEWTab_ReplicationInfo extends ReplicationInfo;
// marker class only, if its exists, that player can use TradeMenu
 
var PlayerReplicationInfo Player;

replication {
    reliable if (bNetInitial && Role==ROLE_Authority)
      Player;
}

function Tick(float DeltaTime)
{
    if (Player == None)
    {
        Disable('Tick');
        Destroy();
    }
}
