class HoH_VotingReplicationInfo extends VotingReplicationInfo
	DependsOn(HoH_VotingHandler);

#exec obj load file="KFAnnounc.uax" package="HoH_Game"

var array<string> RepArray,SortedArray; // Displayed rep string

var sound AnnounceSnds[13];
var byte MapRepVote;
var bool bClientHasInit;
var bool bShowMapLike;
var bool bRandomVote;      // Si el jugador votó por Random
var int RandomVoteCount;   // Contador de votos random

replication
{
	reliable if( Role==ROLE_Authority && bNetInitial )
		bShowMapLike;
	reliable if( Role==ROLE_Authority )
		ReceiveMapInfoRep, bRandomVote, RandomVoteCount;
	reliable if( Role<ROLE_Authority )
		SendMapRepVote, SendRandomVote;
}
simulated final function InitClient()
{
	local PlayerController PC;

	bClientHasInit = true;
	PC = Level.GetLocalPlayerController();
	if( PC!=None )
		Class'HoH_LevelCleanup'.Static.AddVotingReplacement(PC);
}
simulated function Tick(float DeltaTime)
{
	if( !bClientHasInit ) InitClient();
	Super.Tick(DeltaTime);
}
simulated function PlayCountDown(int Count)
{
	local byte Idx;

	if( PlayerOwner==None )		return;
	switch( Count )
	{
	case 60:
		Idx = 12;
		break;
	case 30:
		Idx = 11;
		break;
	case 20:
		Idx = 10;
		break;
	default:
		Idx = Min(Count-1,9);
		break;
	}
	PlayerOwner.ClientPlaySound(AnnounceSnds[Idx],true,2.f,SLOT_Talk);
	PlayerOwner.ReceiveLocalizedMessage(Class'HoH_VoteTimeMessage',Idx);
}
simulated function OpenWindow()
{
	if( GetController().FindMenuByClass(Class'HoH_MapVotingPageX')==None ) // Only open when aren't already open.
	{
		GetController().OpenMenu(string(Class'HoH_MapVotingPageX'));
		if (bShowMapLike) {
			GetController().OpenMenu(string(Class'HoH_LikePage'));
		}
	}
}
function TickedReplication_MapList(int Index, bool bDedicated)
{
 	local VotingHandler.MapVoteMapList MapInfo;

	MapInfo = VH.GetMapList(Index);
	DebugLog("___Sending " $ Index $ " - " $ MapInfo.MapName);

	if( bDedicated )
	{
		ReceiveMapInfoRep(MapInfo,HoH_VotingHandler(VH).RepArray[Index]); // replicate one map each tick until all maps are replicated.
		bWaitingForReply = True;
	}
	else
	{
		MapList[MapList.Length] = MapInfo;
		InitRepStr(MapList.Length-1,HoH_VotingHandler(VH).RepArray[Index]);
	}
}
simulated function ReceiveMapInfoRep( VotingHandler.MapVoteMapList MapInfo, HoH_VotingHandler.FMapRepType Rep )
{
	MapList[MapList.Length] = MapInfo;
	InitRepStr(MapList.Length-1,Rep);
	ReplicationReply();
}
simulated final function InitRepStr( int i, HoH_VotingHandler.FMapRepType Rep )
{
	local float Rating;
	local byte R,G;

	RepArray.Length 	 = i+1;
	SortedArray.Length 	 = i+1;
	// Map not yet rated.
	if( Rep.Positive	== 0 && Rep.Negative==0 )
	{
		SortedArray[i] 	 = "0000";

		// Map never played.
		if( MapList[i].PlayCount==0 )
			RepArray[i]  = "**NEW**";
		else RepArray[i] = "N/A";
	}
	else
	{
		Rating = float(Rep.Positive) / float(Rep.Positive + Rep.Negative); // Scaled 0-1 (0 = negative, 1 = positive)

		if( Rating<0.5f )
		{
			R = 255;
			G = 510.f*Rating;
			if( G==0 || G==10 )	++G;
		}
		else
		{
			R = 510.f*(1.f-Rating);
			G = 255;
			if( R==0 || R==10 )	++R;
		}
		RepArray[i] 	= Chr(0x1B)$Chr(R)$Chr(G)$Chr(1)$(Rating*100.f)@"% ("$Rep.Positive$"/"$(Rep.Positive+Rep.Negative)@"likes)";
		SortedArray[i]  = string(int(Rating*100.f));
		SortedArray[i]  = Right("0000"$SortedArray[i],4);
	}
}
simulated function bool SetMapLike(bool bLiked)
{
	local byte NewValue;

	NewValue = 2 - byte(bLiked);
	if (NewValue == MapRepVote)		return false;

	MapRepVote = NewValue;
	SendMapRepVote(MapRepVote);
	return true;
}
function SendMapRepVote(byte value)
{
	MapRepVote = value;
}
function SendRandomVote()
{
    // Similar a SendMapVote en el código original
    if(VH != None)
    {
        HoH_VotingHandler(VH).SubmitRandomVote(Owner);
    }
}
// Función para recibir actualizaciones de votos random
simulated function ReceiveRandomVoteCount(int NewCount)
{
    RandomVoteCount = NewCount;

    // Actualizar la UI si está abierta
    if(PlayerOwner != None && PlayerOwner.Player != None)
    {
        if(HoH_MapVotingPageX(GetController().ActivePage) != None)
        {
            HoH_MapVotingPageX(GetController().ActivePage).UpdateRandomVoteCount(RandomVoteCount);
        }
    }
}
// Función para verificar si el jugador puede votar random
simulated function bool CanVoteRandom()
{
    // No permitir voto random si ya votó por un mapa
    if(MapVote != -1)
        return false;

    // No permitir voto random si ya votó random
    if(bRandomVote)
        return false;

    return true;
}
defaultproperties
{
    bRandomVote=false
    RandomVoteCount=0	
	
    AnnounceSnds[0]=Sound'KFAnnounc.one'
    AnnounceSnds[1]=Sound'KFAnnounc.two'
    AnnounceSnds[2]=Sound'KFAnnounc.three'
    AnnounceSnds[3]=Sound'KFAnnounc.four'
    AnnounceSnds[4]=Sound'KFAnnounc.five'
    AnnounceSnds[5]=Sound'KFAnnounc.six'
    AnnounceSnds[6]=Sound'KFAnnounc.seven'
    AnnounceSnds[7]=Sound'KFAnnounc.eight'
    AnnounceSnds[8]=Sound'KFAnnounc.nine'
    AnnounceSnds[9]=Sound'KFAnnounc.ten'
    AnnounceSnds[10]=Sound'KFAnnounc.20_seconds'
    AnnounceSnds[11]=Sound'KFAnnounc.30_seconds_remain'
    AnnounceSnds[12]=Sound'KFAnnounc.1_minute_remains'
}