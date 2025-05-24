// Created by Marco
class HoH_LikePage extends LargeWindow;

var automated GUILabel l_Text;
var automated GUIButton b_Like,b_Dislike;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	b_Like.Caption 		= MakeColorCode(Class'Canvas'.Static.MakeColor(64,255,64))$b_Like.Caption;
	b_Dislike.Caption 	= MakeColorCode(Class'Canvas'.Static.MakeColor(255,64,64))$b_Dislike.Caption;
}
function bool LikeClick(GUIComponent Sender)
{
	HoH_VotingReplicationInfo(PlayerOwner().VoteReplicationInfo).SetMapLike(Sender==b_Like);
	Controller.CloseMenu();
	return false;
}
defaultproperties
{
	Begin Object Class=GUILabel Name=LikeInfo
        Caption="Did you like this map?"
        TextAlign=1
        TextColor=(R=255,G=255,B=64,A=255)
        WinTop=0.2000000
        WinLeft=0.1000000
        WinWidth=0.8000000
        WinHeight=0.4000000
	End Object
    l_Text=GUILabel'HoH_Game.HoH_LikePage.LikeInfo'

	Begin Object Class=GUIButton Name=LikeButton
        Caption="Like"
        WinTop=0.5300000
        WinLeft=0.3800000
        WinWidth=0.1100000
        WinHeight=0.0750000
        OnClick=HoH_LikePage.LikeClick
        OnKeyEvent=LikeButton.InternalOnKeyEvent
	End Object
    b_Like=GUIButton'HoH_Game.HoH_LikePage.LikeButton'

	Begin Object Class=GUIButton Name=DislikeButton
        Caption="Dislike"
        WinTop=0.5300000
        WinLeft=0.5100000
        WinWidth=0.1100000
        WinHeight=0.0750000
        OnClick=HoH_LikePage.LikeClick
        OnKeyEvent=DislikeButton.InternalOnKeyEvent
	End Object
	b_Dislike=GUIButton'HoH_Game.HoH_LikePage.DislikeButton'
	
    WindowName="Map review"
    bRequire640x480=false
    WinTop=0.3500000
    WinLeft=0.3000000
    WinWidth=0.4000000
    WinHeight=0.3000000
    bAcceptsInput=false
}