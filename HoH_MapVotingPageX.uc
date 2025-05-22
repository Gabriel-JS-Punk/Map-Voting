class HoH_MapVotingPageX extends ROMapVotingPage;

var automated moEditBox SearchEdit;
var localized string strHelp;

function InitComponent(GUIController InController, GUIComponent InOwner)
{
    Super.InitComponent(InController, InOwner);
    
    // Cambiamos el color a verde de los captions
    if(SearchEdit != None)
    {
        SearchEdit.SetCaption(Chr(0x1B) $ Chr(1) $ Chr(255) $ Chr(1) $ "F3 Map Search:");
    }
    
    if(co_GameType != None)
    {
        co_GameType.SetCaption(Chr(0x1B) $ Chr(1) $ Chr(255) $ Chr(1) $ "F4 Select Game Type:");
    }
}

function InternalOnOpen()
{
    super.InternalOnOpen();

    if (!bHasFocus) {
        lb_MapListBox.SetVisibility(false);
        lb_VoteCountListBox.SetVisibility(false);
        return;
    }

    lb_MapListBox.SetVisibility(true);
    lb_VoteCountListBox.SetVisibility(true);

    if (f_Chat.ed_Chat.GetText() != "") {
        f_Chat.ed_Chat.SetFocus(none);
        SetFocus(f_Chat.ed_Chat);
        f_Chat.ed_Chat.MyEditBox.CaretPos = len(f_Chat.ed_Chat.GetText());
        f_Chat.ed_Chat.MyEditBox.bAllSelected = false;
    }
    else {
        Controller.PlayInterfaceSound(CS_Edit);
        SearchEdit.SetFocus(none);
    }
    // Usamos los valores RGB directamente como se hace en HoH_VotingReplicationInfo
    f_Chat.ReceiveChat(Chr(3) $ Chr(0x1B) $ Chr(1) $ Chr(255) $ Chr(1) $ strHelp);
}

// Also allow admins force mapswitch.
final function SendAdminSwitch(GUIComponent Sender)
{
	local int MapIndex,GameConfigIndex;

	if( Sender == lb_VoteCountListBox.List )
	{
		MapIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapIndex();
		if( MapIndex>=0 )
			GameConfigIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedGameConfigIndex();
	}
	else
	{
		MapIndex = MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapIndex();
		if( MapIndex>=0 )
			GameConfigIndex = int(co_GameType.GetExtra());
	}
	if( MapIndex>=0 )
		MVRI.SendMapVote(MapIndex,-(GameConfigIndex+1)); // Send with negative game index to indicate admin switch.
}

// Allow admins vote like all other players.
function SendVote(GUIComponent Sender)
{
	local int MapIndex,GameConfigIndex;

	if( Sender == lb_VoteCountListBox.List )
	{
		MapIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapIndex();
		if( MapIndex>=0 )
			GameConfigIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedGameConfigIndex();
	}
	else
	{
		MapIndex = MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapIndex();
		if( MapIndex>=0 )
			GameConfigIndex = int(co_GameType.GetExtra());
	}
	if( MapIndex>=0 )
	{
		if( MVRI.MapList[MapIndex].bEnabled )
			MVRI.SendMapVote(MapIndex,GameConfigIndex);
		else PlayerOwner().ClientMessage(lmsgMapDisabled);
	}
}

function GameTypeChanged(GUIComponent Sender)
{
	super.GameTypeChanged(Sender);
	SearchEdit.SetText("");
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float delta)
{
	local Interactions.EInputKey iKey;
	if (State != 3)
		return false;

	iKey = EInputKey(Key);
	if (iKey >= IK_F1 && iKey < IK_F12) {
		// F keys
		switch (iKey) {
			case IK_F1:
				Controller.PlayInterfaceSound(CS_Edit);
				f_Chat.ReceiveChat(strHelp);
				return true;
			case IK_F2:
				Controller.PlayInterfaceSound(CS_Edit);
				f_Chat.ed_Chat.SetFocus(none);
				SetFocus(f_Chat.ed_Chat);
				return true;
			case IK_F3:
				Controller.PlayInterfaceSound(CS_Edit);
				SearchEdit.SetFocus(none);
				SetFocus(SearchEdit);
				return true;
			case IK_F4:
				Controller.PlayInterfaceSound(CS_Edit);
				co_GameType.SetFocus(none);
				SetFocus(co_GameType);
				co_GameType.MyComboBox.ShowListBox(co_GameType.MyComboBox);
				return true;
		}
	}
	return false;
}

function bool OnGameTypeKey(out byte Key, out byte State, float delta)
{
	local Interactions.EInputKey iKey;

	if (State != 3)
		return false;

	iKey = EInputKey(Key);
	if (iKey == IK_Enter) {
		Controller.PlayInterfaceSound(CS_Edit);
		co_GameType.MyComboBox.ShowListBox(co_GameType.MyComboBox);
		if (!co_GameType.MyComboBox.MyListBox.bVisible) {
			SearchEdit.SetFocus(none);
			SetFocus(SearchEdit);
		}
		return true;
	}
	return false;
}


function bool OnSearchKey(out byte Key, out byte st, float delta)
{
	if (st != 3)
		return false;  // not a key press

	// redirect Fn keys to BuyMenuTab
	if (Key >= 0x70 && Key < 0x7C) {
		return InternalOnKeyEvent(Key, st, delta);
	}

	switch (Key) {
		case 0x08: // IK_Backspace
			if (Controller.CtrlPressed) {
				SearchEdit.SetText("");
				Key = 0;
				st = 0;
				return true;
			}
			break;
		case 0x0D: // IK_Enter
			SendVote(lb_MapListBox.List);
			return true;
		case 0x26: // IK_Up
			lb_MapListBox.List.Up();
			return true;
		case 0x28: // IK_Down
			lb_MapListBox.List.Down();
			return true;
	}
	return SearchEdit.MyEditBox.InternalOnKeyEvent(Key, st, delta);
}

function bool OnSearchKeyType(out byte Key, optional string Unicode)
{
    if (Key == 127) {
        return true;  // control characters
    }
    if (Unicode == "`" || Unicode == "~") {
        // ignore console key input
        return true;
    }
    return SearchEdit.MyEditBox.InternalOnKeyType(Key, Unicode);
}

function OnSearchChange(GUIComponent Sender)
{
    local string s;

    s = SearchEdit.GetText();
	HoH_MultiColumnList(lb_MapListBox.List).ApplyFilter(s);
}

function bool AlignBK(Canvas C)
{

	if (lb_VoteCountListbox.MyList != none) {
		i_MapCountListBackground.WinWidth  = lb_VoteCountListbox.MyList.ActualWidth();
		i_MapCountListBackground.WinHeight = lb_VoteCountListbox.MyList.ActualHeight();
		i_MapCountListBackground.WinLeft   = lb_VoteCountListbox.MyList.ActualLeft();
		i_MapCountListBackground.WinTop    = lb_VoteCountListbox.MyList.ActualTop();
	}
	if (lb_MapListBox.MyList != none) {
		i_MapListBackground.WinWidth  	= lb_MapListBox.MyList.ActualWidth();
		i_MapListBackground.WinHeight 	= lb_MapListBox.MyList.ActualHeight();
		i_MapListBackground.WinLeft  	= lb_MapListBox.MyList.ActualLeft();
		i_MapListBackground.WinTop	 	= lb_MapListBox.MyList.ActualTop();
	}
	return false;
}


defaultproperties
{
	Begin Object Class=moEditBox Name=SearchEditbox
		CaptionWidth=0.350000
		//Caption="F3 Map Search:"
		OnCreateComponent=SearchEditbox.InternalOnCreateComponent
		WinTop=0.315000
		WinLeft=0.066000
		WinWidth=0.850000
		WinHeight=0.037500
		TabOrder=2
		bBoundToParent=true
		bScaleToParent=true
		OnChange=HoH_MapVotingPageX.OnSearchChange
		OnKeyType=HoH_MapVotingPageX.OnSearchKeyType
		OnKeyEvent=HoH_MapVotingPageX.OnSearchKey
	End Object
	SearchEdit=moEditBox'HoH_Game.HoH_MapVotingPageX.SearchEditbox'

	strHelp="Commands keys: '.' for TeamSay '+' for Like this map '-' for Dislike this map.| "
	Begin Object Class=HoH_MultiColumnListBox Name=MapListBox
		HeaderColumnPerc(0)=0.520000 // Antes era 0.500000
		HeaderColumnPerc(1)=0.150000
		HeaderColumnPerc(2)=0.130000
		HeaderColumnPerc(3)=0.200000
		bVisibleWhenEmpty=true
		OnCreateComponent=MapListBox.InternalOnCreateComponent
		StyleName="ServerBrowserGrid"
		WinTop=0.370000
		WinLeft=0.020000
		WinWidth=0.960000
		WinHeight=0.340000
		TabOrder=3
		bBoundToParent=true
		bScaleToParent=true
		OnRightClick=MapListBox.InternalOnRightClick
	End Object
	lb_MapListBox=HoH_MultiColumnListBox'HoH_Game.HoH_MapVotingPageX.MapListBox'

	Begin Object Class=HoH_CountColumnListBox Name=VoteCountListBox
		HeaderColumnPerc(0)=0.300000
		HeaderColumnPerc(1)=0.300000
		HeaderColumnPerc(2)=0.200000
		HeaderColumnPerc(3)=0.200000
		bVisibleWhenEmpty=true
		OnCreateComponent=VoteCountListBox.InternalOnCreateComponent
		WinTop=0.050000
		WinLeft=0.020000
		WinWidth=0.960000
		WinHeight=0.220000
		TabOrder=0
		bBoundToParent=true
		bScaleToParent=true
		OnRightClick=VoteCountListBox.InternalOnRightClick
	End Object
	lb_VoteCountListBox=HoH_CountColumnListBox'HoH_Game.HoH_MapVotingPageX.VoteCountListBox'

	Begin Object Class=moComboBox Name=GameTypeCombo
		bReadOnly=true
		CaptionWidth=0.350000
		//Caption="F4 Select Game Type:"
		OnCreateComponent=GameTypeCombo.InternalOnCreateComponent
		WinTop=0.275000
		WinLeft=0.066000
		WinWidth=0.850000
		WinHeight=0.037500
		TabOrder=1
		bBoundToParent=true
		bScaleToParent=true
		OnKeyEvent=HoH_MapVotingPageX.OnGameTypeKey
	End Object
	co_GameType=moComboBox'HoH_Game.HoH_MapVotingPageX.GameTypeCombo'

	Begin Object Class=GUIImage Name=MapListBackground
		Image=Texture'KF_InterfaceArt_tex.Menu.Thin_border_SlightTransparent'
		ImageStyle=ISTY_Stretched
		OnDraw=HoH_MapVotingPageX.AlignBK
	End Object
	i_MapListBackground=GUIImage'HoH_Game.HoH_MapVotingPageX.MapListBackground'

	Begin Object Class=HoH_MapVoteFooterX Name=ChatFooter
		WinTop=0.705000
		WinLeft=0.020000
		WinWidth=0.960000
		WinHeight=0.275000
		TabOrder=10
	End Object
	f_Chat=HoH_MapVoteFooterX'HoH_Game.HoH_MapVotingPageX.ChatFooter'

	OnKeyEvent=HoH_MapVotingPageX.InternalOnKeyEvent
}