class NodeUTStatsMutator expands Mutator;

var int CSP;

var (NodeUTStats) float SpawnKillTimeLimit;
var (NodeUTStats) float MultiKillTimeLimit;
var (NodeUTStats) bool bIgnoreMonsters;
var (NodeUTStats) string faces[39];

struct nPlayer{
	var PlayerReplicationInfo p;
	var Pawn pawn;
	var int spawns;
	var float lastSpawnTime;
	var int id;
	var int spawnKills;
	var int spawnKillSpree;
	var int bestSpawnKillSpree;
	var float lastKillTime;
	var int currentSpree;
	var int bestSpree;
	var int currentMulti;
	var int bestMulti;
	var int damageDone;
	var int damageTaken;
	var int netSpeed;
	var float mouseSens;
	var float dodgeClickTime;
	var int fov;
	var int settingChecks;
	var int monsterKills;
	var float shortestTimeBetweenKills;
	var float longestTImeBetweenKills;
};


var nPlayer nPlayers[64];


struct flagInfo{

	var float x;
	var float y;
	var float z;
	var int team;
};


var flagInfo nFlags[4];


function printLog(string s){

	Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.GetTimeStamp() $ Chr(9) $ s);
}


function int getPlayerIndex(PlayerReplicationInfo p){

	local int i;

	for(i = 0; i < 64; i++){

		if(nPlayers[i].id == p.PlayerID){
			return i;
		}
	}

	return -1;
}


function string getRandomFace(){
	
	local string currentFace;
	local int currentIndex;

	currentIndex = Rand(38);

	return faces[currentIndex];
	
}

function int insertNewPlayer(Pawn p){
	
	local int i;
	//local StatLog log;
	local int id;
	local PlayerPawn potato;


	
//	log = Level.Game.LocalLog;
	
	for(i = 0; i < 64; i++){
		
	
		if(nPlayers[i].id == -1){

			nPlayers[i].p = p.PlayerReplicationInfo;
			nPlayers[i].id = p.PlayerReplicationInfo.PlayerID;
			nPlayers[i].settingChecks = 0;
			nPlayers[i].netspeed = 0;
			nPlayers[i].mouseSens = 0;
			nPlayers[i].fov = 0;
			nPlayers[i].longestTimeBetweenKills = -1;
			nPlayers[i].shortestTimeBetweenKills = -1;
			nPlayers[i].lastKillTime = Level.TimeSeconds;

			if(nPlayers[i].p.TalkTexture != None){
				printLog("nstats"$Chr(9)$"Face"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$nPlayers[i].p.TalkTexture);
			}else{
				printLog("nstats"$Chr(9)$"Face"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$getRandomFace());
			}

			if(nPlayers[i].p.VoiceType != None){
				printLog("nstats"$Chr(9)$"Voice"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$nPlayers[i].p.VoiceType);
			}



			if(PlayerPawn(p) != None){

				printLog("nstats"$Chr(9)$"NetSpeed"$Chr(9)$nPlayers[i].p.PlayerID$Chr(9)$PlayerPawn(p).Player.CurrentNetSpeed);
			}
			
		
			return i;
		}
	}

	return -1;
}


function updateSpawnInfo(int offset){
		
	nPlayers[offset].spawns++;
	nPlayers[offset].lastSpawnTime = Level.TimeSeconds;

}


function initFlags(){

	local int i;

	for(i = 0; i < 4; i++){

		nFlags[i].team = -1;
		nFlags[i].x = 0;
		nFlags[i].y = 0;
		nFlags[i].z = 0;
	}
}

function LogFlagLocations(){

	local FlagBase currentFlag;
	local string position;

	initFlags();

	foreach AllActors(class'FlagBase', currentFlag){

		if(currentFlag.team >= 0 && currentFlag.team <= 3){

			nFlags[currentFlag.team].team = currentFlag.team;
			nFlags[currentFlag.team].x = currentFlag.Location.x;
			nFlags[currentFlag.team].y = currentFlag.Location.y;
			nFlags[currentFlag.team].z = currentFlag.Location.z;
		}

		position = currentFlag.Location.x $ Chr(9) $ currentFlag.Location.y $ Chr(9) $ currentFlag.Location.z;
		printLog("nstats" $Chr(9)$ "flag_location" $Chr(9)$ currentFlag.team $ Chr(9) $ position);
	}
}


function LogSpawnLocations(){

	local PlayerStart s;
	local string position;

	foreach AllActors(class'PlayerStart', s){

		position = s.Location.x $","$ s.Location.y $","$ s.Location.z;
		printLog("nstats" $Chr(9)$ "spawn_point" $Chr(9)$ s.Name $Chr(9)$ s.TeamNumber $Chr(9)$ position);
		
	}
}

function LogWeaponLocations(){


	local TournamentWeapon w;
	local string position;


	foreach AllActors(class'TournamentWeapon', w){
		
		position = w.Location.x $ ","$ w.Location.y $ "," $ w.location.z;		
		printLog( "nstats" $Chr(9)$ "weapon_location" $Chr(9)$ w.class $ Chr(9) $ w.Name $ Chr(9) $ position);
	}
}

function LogHealthLocations(){

	local TournamentHealth h;
	local string position;

	foreach AllActors(class'TournamentHealth', h){
		
		position = h.Location.x $ "," $ h.location.y $ "," $ h.location.z;
		printLog("nstats" $ Chr(9) $ "pickup_location" $ Chr(9) $ h.class $ Chr(9) $ h.Name $ Chr(9) $ position);
	}
}

function LogPickupLocations(){

	local TournamentPickup p;
	local string position;

	foreach AllActors(class'TournamentPickup', p){
		
		position = p.Location.x $ "," $p.location.y $ "," $ p.location.z;
		printLog("nstats" $ Chr(9) $ "pickup_location" $ Chr(9) $ p.class $ Chr(9) $ p.Name $ Chr(9) $ position);
	}
}


function LogAmmoLocations(){

	local TournamentAmmo a;
	local string position;

	foreach AllActors(class'TournamentAmmo', a){
		
		position = a.Location.x$","$a.location.y$","$a.location.z;
		
		printLog("nstats" $ Chr(9) $ "ammo_location" $ Chr(9) $ a.class $ Chr(9) $ a.name $ Chr(9) $ position);

	}
}

function PostBeginPlay(){

	local int i;
	

	LOG("¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬ NodeUTStats started ¬¬¬¬¬¬¬¬¬¬¬¬¬¬¬");


	LogSpawnLocations();
	LogFlagLocations();
	LogWeaponLocations();
	LogHealthLocations();
	LogPickupLocations();
	LogAmmoLocations();
	LogDomPoints();

	for(i = 0; i < 64; i++){
	
		nPlayers[i].id = -1;
		nPlayers[i].lastSpawnTime = -1;


	}
}


function bool bMonsterHuntGame(){

	
	local string find;

	local string gt;
	local int searchResult;


	gt = Caps(Level.Game.gamename);
	//Log("gametype = "$ gt);
	//gt = Caps(gt);
	//Log("gametype.Caps = "$ gt);

	find = Caps("Monster Hunt");
	

	searchResult = inStr(gt, find);

	if(searchResult != -1){
		return true;
	}

	find = Caps("MonsterHunt");
	
	searchResult = inStr(gt, find);

	if(searchResult != -1){
		return true;
	}

	find = Caps("Coop Game");

	searchResult = inStr(gt, find);

	if(searchResult != -1){
		return true;
	}

	

	return false;
}

function bool HandleEndGame(){


	local int i;

	
	if(!bMonsterHuntGame()){

		for(i = 0; i < 64; i++){
		
			if(nPlayers[i].id == -1){
				continue;
			}

			updateStats(i);
			updateSpecialEvents(i, true);

			printLog("nstats"$Chr(9)$"SpawnKills"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].spawnKills);
			printLog("nstats"$Chr(9)$"BestSpawnKillSpree"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestSpawnKillSpree);
			printLog("nstats"$Chr(9)$"BestSpree"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestSpree);
			printLog("nstats"$Chr(9)$"BestMulti"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].bestMulti);
			printLog("nstats"$Chr(9)$"shortestTimeBetweenKills" $Chr(9)$ nPlayers[i].id $Chr(9) $ nPlayers[i].shortestTimeBetweenKills);
			printLog("nstats"$Chr(9)$"longestTimeBetweenKills" $Chr(9)$ nPlayers[i].id $Chr(9) $ nPlayers[i].longestTimeBetweenKills);
			//Level.Game.LocalLog.LogEventString(Level.Game.LocalLog.getTimeStamp()$Chr(9)$"nstats"$Chr(9)$"MonsterKills"$Chr(9)$nPlayers[i].id$Chr(9)$nPlayers[i].monsterKills);
		}

	}else{
		
		printLog("Monster hunt game finished");
	}

	if(NextMutator != None){
		return NextMutator.HandleEndGame();
	}

	return false;
}


function updateStats(int PlayerIndex){

	
	local int bestSpawnSpree;
	local int currentSpawnSpree;
	local int bestSpree;
	local int currentSpree;

	bestSpawnSpree = nPlayers[PlayerIndex].bestSpawnKillSpree;
	currentSpawnSpree = nPlayers[PlayerIndex].spawnKillSpree;
	bestSpree = nPlayers[PlayerIndex].bestSpree;
	currentSpree = nPlayers[PlayerIndex].currentSpree;


	if(currentSpawnSpree > bestSpawnSpree){

		nPlayers[PlayerIndex].bestSpawnKillSpree = currentSpawnSpree;

		//Log(nPlayers[PlayerIndex].p.PlayerName$Chr(9)$" just got their best spawn kill spree ("$nPlayers[PlayerIndex].spawnKillSpree$") was ("$bestSpawnSpree$")");


	}

	nPlayers[PlayerIndex].spawnKillSpree = 0;

	if(currentSpree > bestSpree){
		//LOG(nPlayers[PlayerIndex].p.PlayerName$" just beat their best killing spree "$currentSpree$" was ("$bestSpree$")");
		nPlayers[PlayerIndex].bestSpree = currentSpree;
	}
}


function UpdateSpecialEvents(int PlayerId, bool bKilled){

	local int bestMulti;
	local int currentMulti;
	local int bestSpree;
	local int currentSpree;
	local float lastKillTime;

	bestMulti = nPlayers[PlayerId].bestMulti;
	currentMulti = nPlayers[PlayerId].currentMulti;

	bestSpree = nPlayers[PlayerId].bestSpree;
	currentSpree = nPlayers[PlayerId].currentSpree;

	lastKillTime = nPlayers[PlayerId].lastKillTime;

	if(bKilled){
	
		nPlayers[PlayerId].currentMulti = 0;
		nPlayers[PlayerId].currentSpree = 0;

		if(currentSpree > bestSpree){
			nPlayers[PlayerId].bestSpree = currentSpree;
		}

		if(currentMulti > bestMulti){
			nPlayers[PlayerId].bestMulti = currentMulti;
		}

		nPlayers[PlayerId].currentMulti = 0;
		nPlayers[PlayerId].currentSpree = 0;


		
	}else{
	
		nPlayers[PlayerId].currentSpree++;

		if(Level.TimeSeconds - lastKillTime <= MultiKillTimeLimit){
			
			nPlayers[PlayerId].currentMulti++;

		}else{
			
			if(currentMulti > bestMulti){
				nPlayers[PlayerId].bestMulti = currentMulti;
			}

			nPlayers[PlayerId].currentMulti = 1;
		}

	}

}


function LogKillDistance(Pawn Killer, Pawn Other){

	local float distance;
	
	local int killerId;
	local int otherId;
	local string killerLocation;
	local string victimLocation;

	if(Killer.PlayerReplicationInfo != None && Other.PlayerReplicationInfo != None){

		killerId = Killer.PlayerReplicationInfo.PlayerID;
		otherId = Other.PlayerReplicationInfo.PlayerID;

		distance = VSize(Killer.Location - Other.Location);

		killerLocation = killerId $ Chr(9) $ Killer.Location.x $ "," $ Killer.Location.y $ "," $ Killer.Location.z;
		victimLocation = otherId $ Chr(9) $ Other.Location.x $ "," $ Other.Location.y $ "," $ Other.Location.z;

		printLog("nstats" $Chr(9)$ "kill_distance" $Chr(9)$ distance $Chr(9)$ killerId $Chr(9)$ otherId);
		printLog("nstats" $Chr(9)$ "kill_location" $Chr(9) $  killerLocation $ Chr(9) $ victimLocation);
	}
}


function updateKillTimes(int index, float killTime){

	//local nPlayer p;
	local float offset;

	//p = nPlayers[index];

	offset = killTime - nPlayers[index].lastKillTime;
	
	if(offset < nPlayers[index].shortestTimeBetweenKills || nPlayers[index].shortestTimeBetweenKills == -1){		
		nPlayers[index].shortestTimeBetweenKills = offset;
	}

	if(offset > nPlayers[index].longestTimeBetweenKills || nPlayers[index].longestTimeBetweenKills == -1){
		nPlayers[index].longestTimeBetweenKills = offset;
	}

}

function flagInfo getFlag(int team){

	return nFlags[team];

}

function vector getFlagBaseLocation(int team){

	local flagInfo redFlag;
	local flagInfo blueFlag;
	local vector currentLocation;

	redFlag = getFlag(0);
	blueFlag = getFlag(1);

	if(team == 0){
		
		currentLocation.x = redFlag.x;// = [redFlag.x, redFlag.y, redFlag.z];
		currentLocation.y = redFlag.y;
		currentLocation.z = redFlag.z;

	}else if(team == 1){
	
		currentLocation.x = blueFlag.x;
		currentLocation.y = blueFlag.y;
		currentLocation.z = blueFlag.z;
	}


	return currentLocation;
}

function LogFlagKill(Pawn Killer, Pawn Victim){

	local float distanceToCap;
	local float distanceToBase;
	local float killDistance;
	local vector myBase;
	local vector enemyBase;
	local int victimTeam;

	victimTeam = Victim.PlayerReplicationInfo.team;

	killDistance = VSize(Killer.Location - Victim.Location);

	
	if(victimTeam == 0){
		myBase = getFlagBaseLocation(0);
		enemyBase = getFlagBaseLocation(1);
	}else{
		myBase = getFlagBaseLocation(1);
		enemyBase = getFlagBaseLocation(0);		
	}

	distanceToBase = VSize(Victim.Location - myBase);
	distanceToCap = VSize(Victim.Location - enemyBase);

	printLog("nstats"$Chr(9)$"flag_kill"$Chr(9)$ Killer.PlayerReplicationInfo.PlayerId $Chr(9)$ Victim.PlayerReplicationInfo.PlayerId $Chr(9) $ killDistance $ Chr(9) $ distanceToBase $ Chr(9) $ distanceToCap);
}


function logDomPoints(){

	local int i;
	local ControlPoint p;

	foreach AllActors(class'ControlPoint', p){
	
		printLog("nstats"$Chr(9)$"dom_point"$Chr(9)$ p.PointName $Chr(9)$ p.Location.x $","$ p.Location.y $","$ p.Location.z);
	}
}


function ScoreKill(Pawn Killer, Pawn Other){

	local int KillerId, OtherId;


	//LOG(Other.Class);
	
	
	if(Killer != None){

		if(Killer.PlayerReplicationInfo != None){

			//checkPlayerSettings(Killer);

			KillerId = getPlayerIndex(Killer.PlayerReplicationInfo);

			LogKillDistance(Killer, Other);

			

			
			//check if victim is a monster
			if(!Other.IsA('PlayerPawn') && !Other.IsA('HumanBotPlus')){
				printLog("nstats"$Chr(9)$"MonsterKill"$Chr(9)$Killer.PlayerReplicationInfo.PlayerID$Chr(9)$Other.Class);
			}

		}else{
			KillerId = -1;
		}
	}

	if(Other != None){

		if(Other.PlayerReplicationInfo != None){
			//checkPlayerSettings(Other);
			OtherId = getPlayerIndex(Other.PlayerReplicationInfo);
			//LOG(Other.PlayerReplicationInfo);

		}else{
			OtherId = -1;
		}
	}

	if(KillerId != -1){
		
		
		UpdateSpecialEvents(KillerId,false);

		updateKillTimes(KillerId, Level.TimeSeconds);

		nPlayers[KillerId].lastKillTime = Level.TimeSeconds;
		
		if(OtherId != -1){

			if(Level.TimeSeconds - nPlayers[OtherId].lastSpawnTime <= SpawnKillTimeLimit){
				//LOG("SPAWN KILLLLLL");
				nPlayers[KillerId].spawnKills++;
				nPlayers[KillerId].spawnKillSpree++;
				//nPlayers[KillerId].currentSpree++;
			}

			updateStats(OtherId);
			UpdateSpecialEvents(OtherId, true);

		}
	}


	if(OtherId != -1){
		//nPlayers[OtherId]
	}

	if(NextMutator != None){
		NextMutator.ScoreKill(Killer, Other);
	}

}



function LogSpawnLocation(Pawn Other){

	if(Other.PlayerReplicationInfo != None && Other.bIsPlayer){

		printLog("nstats"$Chr(9)$"spawn_loc"$Chr(9)$Other.PlayerReplicationInfo.PlayerID$Chr(9)$Other.Location.x$","$Other.Location.y$","$Other.Location.z);
	
	}
}



function ModifyPlayer(Pawn Other){

	local int currentPID;

	local NodeUTStatsPlayerReplicationInfo test;

	if(Other.PlayerReplicationInfo != None && Other.bIsPlayer){

		LogSpawnLocation(Other);
			
		currentPID = getPlayerIndex(Other.PlayerReplicationInfo);

		if(currentPID == -1){
			currentPID = InsertNewPlayer(Other);
		}	
	
		if(currentPID != -1){
			updateStats(currentPID);
			updateSpecialEvents(currentPID, true);
			updateSpawnInfo(currentPID);
		}
	}

	if (NextMutator != None)
      NextMutator.ModifyPlayer(Other);
}


function bool PreventDeath(Pawn Killed, Pawn Killer, name damageType, vector HitLocation){

	if(Killed.PlayerReplicationInfo != None){

		if(Killed.PlayerReplicationInfo.HasFlag != None){
			
			logFlagKill(Killer, Killed);
		}
	}

	if ( NextMutator != None )
		return NextMutator.PreventDeath(Killed,Killer, damageType,HitLocation);
	return false;
}

defaultproperties
{
      CSP=0
      SpawnKillTimeLimit=2.000000
      MultiKillTimeLimit=3.000000
      bIgnoreMonsters=False
      Faces(0)="soldierskins.hkil5vector"
      Faces(1)="soldierskins.blkt5malcom"
      Faces(2)="commandoskins.goth5grail"
      Faces(3)="soldierskins.sldr5johnson"
      Faces(4)="fcommandoskins.daco5jayce"
      Faces(5)="fcommandoskins.goth5visse"
      Faces(6)="commandoskins.daco5graves"
      Faces(7)="sgirlskins.venm5sarena"
      Faces(8)="soldierskins.raws5kregore"
      Faces(9)="sgirlskins.army5sara"
      Faces(10)="sgirlskins.garf5vixen"
      Faces(11)="commandoskins.daco5boris"
      Faces(12)="commandoskins.daco5luthor"
      Faces(13)="commandoskins.cmdo5blake"
      Faces(14)="commandoskins.daco5ramirez"
      Faces(15)="fcommandoskins.daco5kyla"
      Faces(16)="soldierskins.sldr5brock"
      Faces(17)="commandoskins.goth5kragoth"
      Faces(18)="sgirlskins.venm5cilia"
      Faces(19)="fcommandoskins.goth5freylis"
      Faces(20)="sgirlskins.garf5isis"
      Faces(21)="fcommandoskins.daco5tanya"
      Faces(22)="sgirlskins.army5lauren"
      Faces(23)="soldierskins.blkt5riker"
      Faces(24)="soldierskins.sldr5rankin"
      Faces(25)="soldierskins.blkt5othello"
      Faces(26)="fcommandoskins.goth5cryss"
      Faces(27)="fcommandoskins.daco5mariana"
      Faces(28)="soldierskins.raws5arkon"
      Faces(29)="commandoskins.cmdo5gorn"
      Faces(30)="fcommandoskins.goth5malise"
      Faces(31)="sgirlskins.fbth5annaka"
      Faces(32)="tcowmeshskins.warcowface"
      Faces(33)="bossskins.boss5xan"
      Faces(34)="sgirlskins.fwar5cathode"
      Faces(35)="soldierskins.hkil5matrix"
      Faces(36)="tskmskins.meks5disconnect"
      Faces(37)="fcommandoskins.aphe5indina"
      Faces(38)="soldierskins.hkil5tensor"
      nPlayers(0)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(1)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(2)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(3)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(4)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(5)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(6)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(7)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(8)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(9)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(10)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(11)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(12)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(13)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(14)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(15)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(16)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(17)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(18)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(19)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(20)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(21)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(22)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(23)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(24)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(25)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(26)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(27)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(28)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(29)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(30)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(31)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(32)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(33)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(34)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(35)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(36)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(37)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(38)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(39)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(40)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(41)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(42)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(43)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(44)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(45)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(46)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(47)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(48)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(49)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(50)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(51)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(52)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(53)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(54)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(55)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(56)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(57)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(58)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(59)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(60)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(61)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(62)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nPlayers(63)=(P=None,Pawn=None,spawns=0,lastSpawnTime=0.000000,Id=0,spawnKills=0,SpawnKillSpree=0,bestSpawnKillSpree=0,LastKillTime=0.000000,currentSpree=0,bestSpree=0,currentMulti=0,bestMulti=0,damageDone=0,damageTaken=0,NetSpeed=0,mouseSens=0.000000,DodgeClickTime=0.000000,FOV=0,settingChecks=0,monsterKills=0,shortestTimeBetweenKills=0.000000,longestTImeBetweenKills=0.000000)
      nFlags(0)=(X=0.000000,Y=0.000000,Z=0.000000,Team=0)
      nFlags(1)=(X=0.000000,Y=0.000000,Z=0.000000,Team=0)
      nFlags(2)=(X=0.000000,Y=0.000000,Z=0.000000,Team=0)
      nFlags(3)=(X=0.000000,Y=0.000000,Z=0.000000,Team=0)
}
