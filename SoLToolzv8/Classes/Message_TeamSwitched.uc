class Message_TeamSwitched extends LocalMessage;

#exec AUDIO IMPORT FILE=..\SoLToolzv8\Classes\TeamSwitch.wav GROUP=Sounds

var Sound TeamSwitchSound;

var localized string TeamSwitchedMessage;
var localized string SpectatedMessage;
var Color TeamSwitchedColor;
var Color SpectatedColor;

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    if (SwitchNum == 1)
        return default.TeamSwitchedMessage;

    if (SwitchNum == 2)
        return default.SpectatedMessage;
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
    if (Switch == 1)
        return default.TeamSwitchedColor;

    if (Switch == 2)
        return default.SpectatedColor;
}

static simulated function ClientReceive(
	PlayerController P,
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, SwitchNum, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if(UnrealPlayer(P)!=None)
		UnrealPlayer(P).ClientDelayedAnnouncement(default.TeamSwitchSound, 5);
}

defaultproperties
{
     TeamSwitchSound=sound'SoLToolzv8.Sounds.TeamSwitch'
     TeamSwitchedMessage="Your team has been switched!"
     SpectatedMessage="You have been moved to spectator!"
     TeamSwitchedColor=(R=128,G=255,B=255,A=255)
     SpectatedColor=(R=96,G=255,B=96,A=255)
     bIsUnique=True
     bFadeMessage=True
     Lifetime=5
     StackMode=SM_Down
     PosY=0.675000
}
