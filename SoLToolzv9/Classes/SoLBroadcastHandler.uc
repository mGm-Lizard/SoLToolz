class SoLBroadcastHandler extends BroadcastHandler;

var private MutSoLToolz Mut;
var private array<string> LlamaText;      // blank-free copy of Mut's LlamaText's

var private int   LlamaRand;
var private float LastRandTime;

function PreBeginPlay()
{
    local BroadcastHandler Bh;
    local Mutator M;

    foreach DynamicActors(class'BroadcastHandler', Bh)
        if(Bh.class == self.class && Bh != self)
        {
            Destroy();
            return;
        }

    foreach DynamicActors(class'BroadcastHandler', Bh)
        if(Bh.class ==Level.Game.default.BroadcastClass)
        {
            Bh.RegisterBroadcastHandler(self);
            foreach DynamicActors(class'Mutator', M)
                if (MutSoLToolz(M) != None)
                {
                    Mut = MutSoLToolz(M);
                    break;
                }
            FillLlamaTextArray();
            return;
        }

    Warn("Failed to register SoLBroadcastHandler!");
}

private function FillLlamaTextArray()
{
    LlamaText.Length = 8;
    LlamaText[7] = Mut.LlamaText8;
    LlamaText[6] = Mut.LlamaText7;
    LlamaText[5] = Mut.LlamaText6;
    LlamaText[4] = Mut.LlamaText5;
    LlamaText[3] = Mut.LlamaText4;
    LlamaText[2] = Mut.LlamaText3;
    LlamaText[1] = Mut.LlamaText2;
    LlamaText[0] = Mut.LlamaText1;

    if(LlamaText[7] == "") LlamaText.Remove(7, 1);
    if(LlamaText[6] == "") LlamaText.Remove(6, 1);
    if(LlamaText[5] == "") LlamaText.Remove(5, 1);
    if(LlamaText[4] == "") LlamaText.Remove(4, 1);
    if(LlamaText[3] == "") LlamaText.Remove(3, 1);
    if(LlamaText[2] == "") LlamaText.Remove(2, 1);
    if(LlamaText[1] == "") LlamaText.Remove(1, 1);
    if(LlamaText[0] == "") LlamaText.Remove(0, 1);
}

function bool AcceptBroadcastText(PlayerController Receiver, PlayerReplicationInfo SenderPRI, out string Msg, optional name Type)
{
    local SoLPlayerReplicationInfo RI;

    if ( (SenderPRI != None) && ((Type == 'Say') || (Type == 'TeamSay')) )
    {
        RI = class'SoLPlayerReplicationInfo'.static.GetFor(SenderPRI);
        if (RI != None)
        {
            if (RI.bMuted)
                return false;

            if (RI.bLlama && LlamaText.Length > 0)
            {
                if (LastRandTime + 0.5 < Level.TimeSeconds)
                {
                    LlamaRand = Rand(LlamaText.Length);
                    LastRandTime = Level.TimeSeconds;
                }
                Msg = LlamaText[LlamaRand];
            }
        }
    }

	if ( NextBroadcastHandler != None )
		return NextBroadcastHandler.AcceptBroadcastText(Receiver, SenderPRI, Msg, Type);

	return true;
}
