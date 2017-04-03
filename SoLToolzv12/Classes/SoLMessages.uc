class SoLMessages extends LocalMessage;

#exec AUDIO IMPORT FILE=..\SoLToolzv12\Media\TeamSwitch.wav GROUP=Sounds

var Sound TeamSwitchSound;

var string TeamSwitchedMessage;
var string SpectatedMessage;
var Color TeamSwitchedColor;
var Color SpectatedColor;
var Color WarningColor;
var string Warnings[3];

static function string StripColor(string s)
{
	local int p;

    p = InStr(s,chr(27));
	while ( p>=0 )
	{
		s = left(s,p)$mid(S,p+4);
		p = InStr(s,Chr(27));
	}

	return s;
}

static function string GetString(
	optional int SwitchNum,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    // we handle message color in GetColor() !
    if (SwitchNum == 1)
        return StripColor(default.TeamSwitchedMessage);

    if (SwitchNum == 2)
        return StripColor(default.SpectatedMessage);
    
    if (SwitchNum > 10)
        return StripColor(default.Warnings[SwitchNum - 11]);
}

static function color GetColor(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2
    )
{
    // our localmessages will accept only single color for they entire (at the beginning of string) but they will fade out nice!
    local string s;
    
    if (Switch == 1)
    {
        s = default.TeamSwitchedMessage;
        if ( Asc(Mid(s, 0, 1)) == 27 )
            return class'Canvas'.static.MakeColor( Asc(Mid(s, 1, 1)),
                                                   Asc(Mid(s, 2, 1)),
                                                   Asc(Mid(s, 3, 1)) );
        else
            return default.TeamSwitchedColor;
    }

    if (Switch == 2)
    {
        s = default.SpectatedMessage;
        if ( Asc(Mid(s, 0, 1)) == 27 )
            return class'Canvas'.static.MakeColor( Asc(Mid(s, 1, 1)),
                                                   Asc(Mid(s, 2, 1)),
                                                   Asc(Mid(s, 3, 1)) );
        else
            return default.SpectatedColor;
    }
    
    if (Switch > 10)
    {
        s = default.Warnings[Switch - 11];
        if ( Asc(Mid(s, 0, 1)) == 27 )
            return class'Canvas'.static.MakeColor( Asc(Mid(s, 1, 1)),
                                                   Asc(Mid(s, 2, 1)),
                                                   Asc(Mid(s, 3, 1)) );
        else
            return default.WarningColor;
    }
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
    TeamSwitchSound=sound'TeamSwitch'
    TeamSwitchedMessage="Your team has been switched!"
    SpectatedMessage="You have been moved to spectator!"
    TeamSwitchedColor=(R=128,G=255,B=255,A=255)
    SpectatedColor=(R=96,G=255,B=96,A=255)
    WarningColor=(R=255,G=128,B=0,A=255)
    bIsUnique=True
    bFadeMessage=True
    Lifetime=5
    StackMode=SM_Down
    PosY=0.675000
}
