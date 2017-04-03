@cd ..\System
@del SoLToolz.ini
@del SoLToolzv12.*
@ucc make -ini=..\SoLToolzv12\make.ini
@ucc editor.stripsource SoLToolzv12.u
@pause
