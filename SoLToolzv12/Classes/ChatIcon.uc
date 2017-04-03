class ChatIcon extends Actor;

#exec TEXTURE IMPORT FILE=..\SoLToolzv12\Media\TAGreen.tga GROUP=Textures

function PostBeginPlay()
{
    Owner.AttachToBone(self, 'head');
    SetRelativeLocation(vect(64,0,0) );
}

defaultproperties
{
    DrawScale=0.500000
    DrawType=DT_Sprite
    Style=STY_Masked
    Texture=Texture'TAGreen'
}
