// ====================================================================
//  Modified by Marco
// ====================================================================
class HoH_CountColumnList extends MapVoteCountMultiColumnList;

var eFontScale MyFontScale;  // soomebody is messing up with the self.FontScale


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	ScaleToResolution(MyController.ResX, MyController.ResY);
}
function ResolutionChanged(int ResX, int ResY)
{
	ScaleToResolution(ResX, ResY);
	Super.ResolutionChanged(ResX,ResY);
}
function ScaleToResolution(int ResX, int ResY)
{
	if (ResY < 1000) {
		MyFontScale = FNS_Small;
	} else {
		MyFontScale = FNS_Medium;
	}
}
function float MyItemHeight(Canvas c)
{
	local float XL, YL;

	SelectedStyle.TextSize(C, MSAT_Blurry, "XXX,", XL, YL, MyFontScale);
	return YL + 2;
}
function DrawItem(Canvas Canvas, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
	local float CellLeft, CellWidth;
	local GUIStyles DrawStyle;

	if( VRI == none )		return;
	// Draw the selection border
	if( bSelected )
	{
		SelectedStyle.Draw(Canvas,MenuState, X, Y-1, W, H+2 );
		DrawStyle = SelectedStyle;
	}
	else DrawStyle = Style;

	GetCellLeftWidth( 0, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		VRI.GameConfig[VRI.MapVoteCount[SortData[i].SortItem].GameConfigIndex].GameName, MyFontScale );

	GetCellLeftWidth( 1, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		VRI.MapList[VRI.MapVoteCount[SortData[i].SortItem].MapIndex].MapName, MyFontScale );

	GetCellLeftWidth( 2, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		string(VRI.MapVoteCount[SortData[i].SortItem].VoteCount), MyFontScale );

	GetCellLeftWidth( 3, CellLeft, CellWidth );
	DrawStyle.DrawText( Canvas, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left,
		HoH_VotingReplicationInfo(VRI).RepArray[VRI.MapVoteCount[SortData[i].SortItem].MapIndex], MyFontScale );
}
//------------------------------------------------------------------------------------------------
function string GetSortString( int i )
{
	local string ColumnData[5];

	ColumnData[0] = left(Caps(VRI.GameConfig[VRI.MapVoteCount[i].GameConfigIndex].GameName),15);
	ColumnData[1] = left(Caps(VRI.MapList[VRI.MapVoteCount[i].MapIndex].MapName),20);
	ColumnData[2] = right("0000" $ VRI.MapVoteCount[i].VoteCount,4);
	ColumnData[3] = HoH_VotingReplicationInfo(VRI).RepArray[VRI.MapVoteCount[i].MapIndex];
	
	if( Left(ColumnData[3],1)==Chr(0x1B) )		ColumnData[3] = Mid(ColumnData[3],4); // Remove color code from sorting.
	return ColumnData[SortColumn] $ ColumnData[PrevSortColumn];
}
defaultproperties
{
    MyFontScale=1
    ColumnHeadings=/* Array type was not detected. */
    InitColumnPerc=/* Array type was not detected. */
    ColumnHeadingHints=/* Array type was not detected. */
    GetItemHeight=HoH_CountColumnList.MyItemHeight
    FontScale=1
}