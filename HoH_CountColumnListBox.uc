// ====================================================================
//  Modified by Marco
// ====================================================================
class HoH_CountColumnListBox extends MapVoteCountMultiColumnListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(Class'HoH_CountColumnList');
	Super.InitComponent(MyController, MyOwner);
	
	if( PlayerOwner().PlayerReplicationInfo.bAdmin )		ContextMenu.AddItem("Admin Force Map");
}
function InternalOnClick(GUIContextMenu Sender, int Index)
{
	if (Sender != None)
	{
		if ( NotifyContextSelect(Sender, Index) )			return;

		switch (Index)
		{
			case 0:
				if( MapVotingPage(MenuOwner) != none )
					MapVotingPage(MenuOwner).SendVote(self);
				break;

			case 1:
				Controller.OpenMenu( string(Class'HoH_MapInfoPage'), MapVoteCountMultiColumnList(List).GetSelectedMapName() );
				break;
			case 2:
				if( HoH_MapVotingPageX(MenuOwner) != none )
					HoH_MapVotingPageX(MenuOwner).SendAdminSwitch(self);
				break;
		}
	}
}