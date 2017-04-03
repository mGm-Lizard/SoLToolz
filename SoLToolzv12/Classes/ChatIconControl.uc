class ChatIconControl extends Inventory;

var ChatIcon ChatIcon;

function PostBeginPlay()
{
    SetTimer(0.25, true);
}

function Timer()
{
    local int Team;

    if(Pawn(Owner) != None && Pawn(Owner).Health > 0 && Pawn(Owner).bIsTyping)
    {
        Team = Pawn(Owner).GetTeamNum();

        if (Team == 0) {
            if(ChatIcon == None)
                ChatIcon = Spawn(class'ChatIconRed', Owner);
        }
        else if (Team == 1) {
            if(ChatIcon == None)
                ChatIcon = Spawn(class'ChatIconBlue', Owner);
        }
        else {
            if(ChatIcon == None)
                ChatIcon = Spawn(class'ChatIcon', Owner);
        }
    }
    else
    {
        if (ChatIcon != None)
            ChatIcon.Destroy();
    }
}

function Destroyed()
{
    if (ChatIcon != None)
        ChatIcon.Destroy();
}
