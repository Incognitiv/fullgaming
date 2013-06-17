#include FGS/new.inc

#define callback->%0(%1) forward %0(%1); public %0(%1)
#define SCM SendClientMessage
#define MSG SendClientMessage
#define MSGA SendClientMessageToAll
#define MSGFA(%0,%1,%2) format(msggg, 256, %1, %2), SendClientMessageToAll(%0, msggg)
new msggg[256];

#define MSGF(%0,%1,%2,%3) format(__msgs, 256, %2, %3), SendClientMessage(%0,%1,__msgs)
new __msgs[256];

#define mysql_query_format(%1,%2)\
    format(buff_str,sizeof(buff_str),%1,%2),mysql_query(buff_str)

new buff_str[500];
	
#define WriteLogFormat(%0,%1)\
	format(strss,sizeof(strss),%0,%1),WriteLog(strss)
new strss[132];
#define iFGS "{FF0000}»{FFFFFF}FG{FF0000}« "
//#define SERVER "{FF0000}Polish {FFFFFF}FullGame.pl {007900}DM{FFFFFF} "
#define COLOR_INVISIBLE 0xFFFFFF00

new WeapId[9][2] = {
{WEAPON_DEAGLE, 3000},
{WEAPON_SAWEDOFF, 6000},
{WEAPON_SHOTGUN, 2000},
{WEAPON_SHOTGSPA, 5000},
{WEAPON_UZI, 4000},
{WEAPON_MP5, 5000},
{WEAPON_TEC9, 5000},
{WEAPON_M4, 6000},
{WEAPON_SNIPER, 7000}};
new DrunkTimer[MAX_GRACZY];

enum PInfo
{
	Name[MAX_PLAYER_NAME],
    InteriorX,
   	AntySpawnKill,
    LevelUpTime,
	ClickedPlayer,
	bool:RampCreated,
    Color,
	RampTimer,
	RampEnabled,
    SpawnWeapons[sizeof(WeapId)],
    bool:TPRefused[MAX_PLAYERS],
	RconAkcja,
    Level,
    WeaponPickup,
	WeaponPickupTime,
	Gangster,
    VAnn,
	bool:Dotacja[2],
	Ramp,
	RampPers,
    bool:MGang,
	bool:NGang,
	LottoNumber,
	Admin,
	VIP,
	Portfel,
	NewNick[MAX_PLAYER_NAME],
	Skin,
	First,
	uID,
	Warns,
	deagle,
	minigun,
	sniper,
	chainsawn,
	wduel,
	pduel
};
new Player[MAX_PLAYERS][PInfo];


#define MAX_WARNS 6

stock IsAdmin(playerid, Lvl = 1) {
	if(IsPlayerAdmin(playerid))
	    return true;
	if(Player[playerid][Admin] >= Lvl)
	    return true;
	return false;
}
stock GetPlayerDistanceToPointEx(playerid,Float:x,Float:y,Float:z) //By Sacky (Edited by Smugller)
{
	new Float:x1,Float:y1,Float:z1;
	new Float:dis;
	GetPlayerPos(playerid,x1,y1,z1);
	dis = floatsqroot((x-x1)*(x-x1)+(y-y1)*(y-y1)+(z-z1)*(z-z1));
	return floatround(dis);
}
stock GetVehSpeed(vehid) // By Diler/PawnMan/RPS @edit DrunkeR
{
	new Float:pos[3];
	GetVehicleVelocity(vehid, pos[0], pos[1], pos[2]);
	return floatround(floatsqroot(floatpower(pos[0], 2) + floatpower(pos[1], 2) + floatpower(pos[2], 2)) * 200);
}
stock ReturnWeaponName(weaponid){
	new weaponname[32];
	GetWeaponName(weaponid,weaponname,sizeof(weaponname));
	if(weaponid == 0)
		format(weaponname,32,"Fist");
	
	return weaponname;
}


callback-> IsPlayerInArea(playerid, Float:minx, Float:maxx, Float:miny, Float:maxy){
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if (x > minx && x < maxx && y > miny && y < maxy) return 1;
	return 0;
}
callback-> isPlayerInArea(playerID, Float:data[4])
{
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerID, X, Y, Z);
	if(X >= data[0] && X <= data[2] && Y >= data[1] && Y <= data[3]) {
		return 1;
	}
	return 0;
}

stock SendClientMessageToAdmins(color, msg[]){
	foreachPly (x) {
		if(IsAdmin(x, 2)) {
				SendClientMessage(x, color, msg);
		}
	}
	return 1;
}

stock SendClientMessageToVip(color, msg[]) {
	foreachPly (x) {
		if(IsVIP(x) || IsAdmin(x, 1)) {
			SendClientMessage(x, color, msg);
		}
	}
	return 1;
}
stock SendClientMessageToMod(color, msg[]) {
	foreachPly (x) {
		if(IsAdmin(x,1)) {
			SendClientMessage(x, color, msg);
		}
	}
	return 1;
}
stock SendClientMessageToPlayers(color, msg[]) {
	foreachPly (x) {
		if (!IsAdmin(x,2)) SendClientMessage(x, color, msg);
	}
	return 1;
}

stock SendClientMessageToAdminsPM(color, msg[]) {
	foreachPly (x) {
		if(IsAdmin(x, 2)) {
			if(pmid1 != x && pmid2 != x){
				SendClientMessage(x, color, msg);
			}
		}
	}
	return 1;
}

stock SendClientMessageToAllDrag(color, msg[]) {
	foreachPly (x) {
		if(IsPlayerInArea(x,605.5474,1390.8591,-1423.9529,-1328.6188)){
			SendClientMessage(x, color, msg);
		}
	}
	return 1;
}

stock CreateMapIcons()
{
	CreateDynamicMapIcon(2253.2166,2453.9294,10.8203, 30,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2191.4653,1991.2842,11.7748, 52,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2454.5457,2064.0178,10.8203, 52,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2023.6055,1008.2421,10.3642, 43,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2509.0732,-1673.2594,13.3815, 25,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(-858.9744,-1941.0603,15.1729, 9,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(1071.7703,-2697.8354,11.2657, 9,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(3045.9048,971.1270,708.5760, 52,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2205.0712,-4014.3115,9.8170, 55,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(917.6343, -1945.317, 2.8884, 55,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2571.8450,-2941.2422,205.2634, 46,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(-544.5546,-480.4810,25.5178, 51,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2172.0037,1620.7543,999.9792, 44,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2504.5408,-1652.5894,13.5938, 21,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(-1987.7372,288.7828,34.5681, 36,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2014.7905,1106.9966,10.8203, 21,0,0,0,-1,1800.0);
		
	CreateDynamicMapIcon(2237.2031,-1717.2285,22.8527, 54,0,0,0,-1,1800.0); //Si³ownie
	CreateDynamicMapIcon(1958.2408,2299.4490,21.7280, 54,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(-2276.8953,-159.3267,46.2813, 54,0,0,0,-1,1800.0);

	CreateDynamicMapIcon(-2354.0466,-151.5577,40.5791, 10,0,0,0,-1,1800.0); //Burger Shoty
	CreateDynamicMapIcon(-2342.5105,1009.1888,55.9150, 10,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(-1922.8597,819.6209,76.9141, 10,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(799.8196,-1619.7946,19.5388, 10,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(1190.9974,-917.2220,43.2077, 10,0,0,0,-1,1800.0);

	CreateDynamicMapIcon(-319.4577,1049.8263,20.3403, 22,0,0,0,-1,1800.0); //Szpitale
	CreateDynamicMapIcon(1172.4885,-1323.1099,15.4025, 22,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(2034.3552,-1404.5022,17.2577, 22,0,0,0,-1,1800.0);
	CreateDynamicMapIcon(-2639.0107,638.8161,14.4531, 22,0,0,0,-1,1800.0);

	CreateDynamicMapIcon(2177.5488,941.4527,25.0981, 6,0,0,0,-1,1800.0); //AmmuNation
	CreateDynamicMapIcon(1386.5803,-1283.9615,33.4856, 6,0,0,0,-1,1800.0); //AmmuNation
	CreateDynamicMapIcon(2390.3362,-1994.0963,18.5529, 6,0,0,0,-1,1800.0); //AmmuNation
		
	CreateDynamicMapIcon(1570.6339,-1703.6871,5.7861, 30,0,0,0,-1,1800.0); //Police LS
	CreateDynamicMapIcon(-1633.0677,706.6133,48.9375, 30,0,0,0,-1,1800.0); //Police SF

	CreateDynamicMapIcon(1375.6439,240.7949,28.2266, 29,0,0,0,-1,1800.0); //Pizza
	CreateDynamicMapIcon(-1717.9935,1359.8541,17.2500, 29,0,0,0,-1,1800.0); //Pizza

	CreateDynamicMapIcon(934.0592,-1349.8695,23.0713, 14,0,0,0,-1,1800.0); //Cluckin' Bell
	CreateDynamicMapIcon(2391.5735,-1906.8853,21.4602, 14,0,0,0,-1,1800.0); //Cluckin' Bell

	CreateDynamicMapIcon(1732.3727,-1462.4307,33.0234, 20,0,0,0,-1,1800.0); //Fire Dept Los Santos
	CreateDynamicMapIcon(-2035.0851,68.8523,36.0985, 20,0,0,0,-1,1800.0); //Fire Dept San Fierro

	CreateDynamicMapIcon(2195.7256,1685.8405,12.3672, 25,0,0,0,-1,1800.0); //Calligula's Casino

	CreateDynamicMapIcon(2448.1860,-1973.3778,13.5469, 18,0,0,0,-1,1800.0); //Emmet

	CreateDynamicMapIcon(2313.3035,-1638.8582,18.5078, 49,0,0,0,-1,1800.0); //Drunk

	CreateDynamicMapIcon(-1937.9418,242.8015,41.0469, 27,0,0,0,-1,1800.0); //Mod garage San Fierro
	CreateDynamicMapIcon(2386.0403,1053.0532,18.3189, 27,0,0,0,-1,1800.0); //Mod garage Las Venturas
	CreateDynamicMapIcon(-2730.0979,217.6517,16.7736, 27,0,0,0,-1,1800.0); //Mod garage San Fierro Wheels Angel
	CreateDynamicMapIcon(2643.2285,-2043.7399,21.3213, 27,0,0,0,-1,1800.0); //Mod garage Los Santos LowRider
	CreateDynamicMapIcon(1046.5599,-1018.5216,41.5676, 27,0,0,0,-1,1800.0); //Mod garage Los Santos
	return 1;
}

// test reaction
CMD:reaction(playerid, params[])
{
	if(!IsAdmin(playerid, 2)) return SendClientMessage(playerid, -1, "Brak uprawnien.");
	
	if(!strcmp(params, "on"))
	{
		ReactionTest();
		return 1;
	} else if(!strcmp(params, "off"))
	{
		KillTimer(TimerReaction);
		TimerReaction = SetTimer("ReactionTest", 5*60*1000, false);
		TextDrawHideForAll(Kod);
		TestReaction = 0;
	}
	SCM(playerid, -1, "DONE.");
	return 1;
}
	
forward ReactionTimeout();
public ReactionTimeout()
{
	KillTimer(TimerReaction);
	TimerReaction = SetTimer("ReactionTest", 5*60*1000, false);
	TextDrawHideForAll(Kod);
	TestReaction = 0;
	SendClientMessageToAll(COLOR_ORANGE, "Nastêpny test reakcji poka¿e siê za 5 minut.");
}

forward ReactionTest();
public ReactionTest()
{
	if(Itter_Count(Player) == 0) return;
	
	KillTimer(TimerReaction);
	TimerReaction = SetTimer("ReactionTimeout", 60*2*1000, 0);
	TestReaction = 1;

	format(gStringReaction, sizeof(gStringReaction), "%c%c%c%c%c%c%c%c%c", 
		gReactionLetters[random(60)], gReactionLetters[random(60)], gReactionLetters[random(60)],
		gReactionLetters[random(60)], gReactionLetters[random(60)], gReactionLetters[random(60)],
		gReactionLetters[random(60)], gReactionLetters[random(60)], gReactionLetters[random(60)]);
		
	new buffer[64];
	format(buffer, sizeof(buffer), "Test reakcji: %s", gStringReaction);
	TextDrawSetString(Kod, buffer);
	TextDrawShowForAll(Kod);
}
// end reaction

stock TuneCar(vehicleid) // By DrunkeR
{
	switch(GetVehicleModel(vehicleid))
	{
		case 400:
		AddVehComp(vehicleid,1008,1009,1010,1013,1018,1019,1020,1021,1024,1086,1087);
		case 401:
		AddVehComp(vehicleid,1001,1003,1004,1005,1006,1007,1008,1009,1010,1013,1017,1019,1020,1086,10871142,1143,1144,1145);
		case 404:
		AddVehComp(vehicleid,1000,1002,1007,1008,1009,1010,1013,1016,1017,1019,1020,1021,1086,1087);
		case 405:
		AddVehComp(vehicleid,1000,1001,1008,1009,1010,1014,1018,1019,1020,1021,1023,1086,1087);
		case 410:
		AddVehComp(vehicleid,1001,1003,1007,1008,1009,1010,1013,1017,1019,1020,1021,1023,1024,1086,1087);
		case 415:
		AddVehComp(vehicleid,1001,1003,1007,1008,1009,1010,1017,1018,1019,1023,1086,1087);
		case 418:
		AddVehComp(vehicleid,1002,1006,1008,1009,1010,1016,1020,1021,1086,1087);
		case 420:
		AddVehComp(vehicleid,1001,1003,1004,1005,1008,1009,1010,1019,1021,1086,1087);
		case 421:
		AddVehComp(vehicleid,1000,1008,1009,1010,1014,1016,1018,1019,1020,1021,1023,1086,1087);
		case 422:
		AddVehComp(vehicleid,1007,1008,1009,1010,1013,1017,1019,1020,1021,1086,1087);
		case 426:
		AddVehComp(vehicleid,1001,1003,1004,1005,1006,1008,1009,1010,1019,1021,1086,1087);
		case 436:
		AddVehComp(vehicleid,1001,1003,1006,1007,1008,1009,1010,1013,1017,1019,1020,1021,1022,1086,1087);
		case 439:
		AddVehComp(vehicleid,1001,1003,1007,1008,1009,1010,1013,1017,1023,1086,1087,1142,1143,1144,1145);
		case 477:
		AddVehComp(vehicleid,1006,1007,1008,1009,1010,1017,1018,1019,1020,1021,1086,1087);
		case 478:
		AddVehComp(vehicleid,1004,1005,1008,1009,1010,1012,1013,1020,1021,1022,1024,1086,1087);
		case 489:
		AddVehComp(vehicleid,1000,1002,1004,1005,1006,1008,1009,1010,1013,1016,1018,1019,1020,1024,1086,1087);
		case 491:
		AddVehComp(vehicleid,1003,1007,1008,1009,1010,1014,1017,1018,1019,1020,1021,1023,1086,1087,1142,1143,1144,1145);
		case 492:
		AddVehComp(vehicleid,1000,1004,1005,1006,1008,1009,1010,1016,1086,1087);
		case 496:
		AddVehComp(vehicleid,1001,1002,1003,1006,1007,1008,1009,1010,1011,1017,1019,1020,1023,1086,1087);
		case 500:
		AddVehComp(vehicleid,1008,1009,1010,1013,1019,1020,1021,1024,1086,1087);
		case 505:
		AddVehComp(vehicleid,1000,1002,1004,1005,1006,1008,1009,1010,1013,1016,1018,1019,1020,1024,1086,1087);
		case 516:
		AddVehComp(vehicleid,1000,1002,1004,1007,1008,1009,1010,1015,1016,1017,1018,1019,1020,1021,1086,1087);
		case 517:
		AddVehComp(vehicleid,1002,1003,1007,1008,1009,1010,1016,1017,1018,1019,1020,1023,1086,1087,1142,1143,1144,1145);
		case 518:
		AddVehComp(vehicleid,1001,1003,1005,1006,1007,1008,1009,1010,1013,1017,1018,1020,1023,1086,1087,1142,1143,1144,1145);
		case 527:
		AddVehComp(vehicleid,1001,1007,1008,1009,1010,1014,1015,1017,1018,1020,1021,1086,1087);
		case 529:
		AddVehComp(vehicleid,1001,1003,1006,1007,1008,1009,1010,1011,1012,1017,1018,1019,1020,1023,1086,1087);
		case 534:
		AddVehComp(vehicleid,1008,1009,1010,1086,1087,1100,1101,1106,1122,1123,1124,1125,1126,1127,1178,1179,1180,1185);
		case 535:
		AddVehComp(vehicleid,1008,1009,1010,1086,1087,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1119,1120,1121);
		case 536:
		AddVehComp(vehicleid,1008,1009,1010,1086,1087,1103,1104,1105,1107,1108,1128,1181,1182,1183,1184);
		case 540:
		AddVehComp(vehicleid,1001,1004,1006,1007,1008,1009,1010,1017,1018,1019,1020,1023,1024,1086,1087,1142,1143,1144,1145);
		case 542:
		AddVehComp(vehicleid,1008,1009,1010,1014,1015,1018,1019,1020,1021,1086,1087,1142,1143,1144,1145);
		case 546:
		AddVehComp(vehicleid,1001,1002,1004,1006,1007,1008,1009,1010,1017,1018,1019,1023,1024,1086,1087,1142,1143,1144,1145);
		case 547:
		AddVehComp(vehicleid,1000,1003,1008,1009,1010,1016,1018,1019,1020,1021,1086,1087);
		case 549:
		AddVehComp(vehicleid,1001,1003,1007,1008,1009,1010,1011,1012,1017,1018,1019,1020,1023,1086,1087,1142,1143,1144,1145);
		case 550:
		AddVehComp(vehicleid,1001,1003,1004,1005,1006,1008,1009,1010,1018,1019,1020,1023,1086,1087,1142,1143,1144,1145);
		case 551:
		AddVehComp(vehicleid,1002,1003,1005,1006,1008,1009,1010,1016,1018,1019,1020,1021,1023,1086,1087);
		case 558:
		AddVehComp(vehicleid,1008,1009,1010,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,1163,1164,1165,1166,1167,1168);
		case 559:
		AddVehComp(vehicleid,1008,1009,1010,1065,1066,1067,1068,1069,1070,1071,1072,1086,1087,1158,1159,1160,1161,1162,1173);
		case 560:
		AddVehComp(vehicleid,1008,1009,1010,1026,1027,1028,1029,1030,1031,1032,1033,1086,1087,1138,1139,1140,1141,1169,1170);
		case 561:
		AddVehComp(vehicleid,1008,1009,1010,1055,1056,1057,1058,1059,1060,1061,1062,1063,1064,1086,1087,1154,1155,1156,1157);
		case 562:
		AddVehComp(vehicleid,1008,1009,1010,1034,1035,1036,1037,1038,1039,1040,1041,1086,1087,1146,1147,1148,1149,1171,1172);
		case 565:
		AddVehComp(vehicleid,1008,1009,1010,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1086,1087,1150,1151,1152,1153);
		case 567:
		AddVehComp(vehicleid,1008,1009,1010,1086,1087,1102,1129,1130,1131,1132,1133,1186,1187,1188,1189);
		case 575:
		AddVehComp(vehicleid,1008,1009,1010,1042,1043,1044,1086,1087,1099,1174,1175,1176,1177);
		case 576:
		AddVehComp(vehicleid,1008,1009,1010,1086,1087,1134,1135,1136,1137,1190,1191,1192,1193);
		case 580:
		AddVehComp(vehicleid,1001,1006,1007,1008,1009,1010,1017,1018,1020,1023,1086,1087);
		case 585:
		AddVehComp(vehicleid,1001,1003,1006,1007,1008,1009,1010,1013,1017,1018,1019,1020,1023,1086,1087,1142,1143,1144,1145);
		case 589:
		AddVehComp(vehicleid,1000,1004,1005,1006,1007,1008,1009,1010,1013,1016,1017,1018,1020,1024,1086,1087,1142,1143,1144,1145);
		case 600:
		AddVehComp(vehicleid,1004,1005,1006,1007,1008,1009,1010,1013,1017,1018,1020,1022,1086,1087);
		case 603:
		AddVehComp(vehicleid,1001,1006,1007,1008,1009,1010,1017,1018,1019,1020,1023,1024,1086,1087,1142,1143,1144,1145);
		case 402,409,411,412,419,424,
		438,442,445,451,458,466,
		467,474,475,479,480,506,
		507,526,533,541,545,555,
		566,579,587,602:
		AddVehComp(vehicleid,1008,1009,1010,1086,1087);
	}
	return 1;
}

forward CountDownAS();
public CountDownAS(){

	if(Count2 == -1){
		GameTextForAll("~y~STOP",3000,3);
		CountDowning = 0;
        SoundForAll(1057);
		return 1;
	}

	if (Count2 > 0){
		new string[5];
		format(string,5,"~w~%d",Count2);
		GameTextForAll(string, 2500, 3);
		Count2--;
        SoundForAll(1056);
		SetTimer("CountDownAS", 1000, 0);
	}
	else{
		GameTextForAll("~y~Start", 2500, 3);
		Count2 = 0;
        SoundForAll(1057);
		foreachPly (x) {
			TogglePlayerControllable(x,1);
		}
		CountDowning = 0;
	}
	return 1;
}

forward PickDestroy(o);
public PickDestroy(o)DestroyPickup(o);

stock PlayerIP(playerid)
{
	new ajpi[16];
	GetPlayerIp(playerid, ajpi, sizeof(ajpi));
	return ajpi;
}


stock PlayerToPoint(Float: radi, playerid, Float:x, Float:y, Float:z)
{
	if(IsPlayerInRangeOfPoint(playerid, radi, x, y, z)) return 1;
	return 0;
}

stock AddVehComp(vehicleid, ...)
{
	new Wheels[] =
	{
		1025, 1073, 1074, 1075,
		1076, 1077, 1078, 1079,
		1080, 1081, 1082, 1083,
		1084, 1085, 1096, 1097,
		1098
	};
	AddVehicleComponent(vehicleid, Wheels[random(sizeof(Wheels))]);
	ChangeVehiclePaintjob(vehicleid, random(3));

	for(new n = 1; n < numargs(); n++)
	AddVehicleComponent(vehicleid, getarg(n, 0));

	return 1;
}

forward GetDistanceBetweenPlayers(playerid,playerid2);
stock GetDistanceBetweenPlayers(playerid,playerid2){
	new Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2;
	new Float:dis;
	if (!IsPlayerConnected(playerid) || !IsPlayerConnected(playerid2)){
		return 0;
	}
	GetPlayerPos(playerid,x1,y1,z1);
	GetPlayerPos(playerid2,x2,y2,z2);
	dis = floatsqroot(floatpower(floatabs(floatsub(x2,x1)),2)+floatpower(floatabs(floatsub(y2,y1)),2)+floatpower(floatabs(floatsub(z2,z1)),2));
	return floatround(dis);
}

stock LoopingAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
	gPlayerUsingAnim[playerid] = true;
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
}

stock OnePlayAnim(playerid,animlib[],animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
	gPlayerUsingAnim[playerid] = true;
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp);
}


stock StopLoopingAnim(playerid)
{
	gPlayerUsingAnim[playerid] = false;
	ApplyAnimation(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
	ClearAnimations(playerid);
}


stock IsTrailer(playerid)
{
	new model = GetVehicleModel(playerid);
	switch(model)
	{
		case 435:return 0;
		case 450:return 0;
		case 591:return 0;
		case 606:return 0;
		case 610:return 0;
		case 584:return 0;
		case 608:return 0;
		case 611:return 0;
		case 607:return 0;

	}
	return 1;
}

stock GetVehicleModelIDFromName(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if(strfind(CarList[i],vname,true) != -1)
		return i+400;
	}
	return -1;
}

forward Float:GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance);
stock Float:GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
	return a;
}

stock PlayerName(playerid){
	static Namea[MAX_PLAYER_NAME];
	Namea[0] = 0;
	GetPlayerName(playerid, Namea, MAX_PLAYER_NAME);
	return Namea;
}

stock IsVIP(playerid) return Player[playerid][VIP];

callback-> VoteWylacz()
{

	TextDrawHideForAll(Glosowanie);
	VoteON = false;
	VotePozostalo = 0;
	VoteQuest[0] = 0;
	
	return 1;
}

#define PlayerKill(%0) PlayerName(%1)

stock PlayerSetColor(playerid)
{

	if(Invisible[playerid])
	{
		SetPlayerColor(playerid,0xFFFFFF00);
		return 1;
	}

	if(IsAdmin(playerid, 2))
	{
		SetPlayerColor(playerid,0xAAFFFFAA);
		return 1;
	}

	Player[playerid][Color] = SelectPlayerColor(random(100));
	SetPlayerColor(playerid, Player[playerid][Color]);

	return 1;
}

stock BanCheck(playerid) {
	new IP_[16];
	
	GetPlayerIp(playerid, IP_, sizeof (IP_));

	mysql_query_format ("select b.name, b.IP, b.type, b.date_created, unix_timestamp(b.date_end), date_format(b.date_end, '%%H:%%i, %%d.%%m.%%Yr'), b.reason, p.Nick FROM ban b JOIN fg_Players p ON b.admin = p.id WHERE '%s' like b.IP and date_created < NOW() and date_end > NOW() OR date_end IS NULL and b.active = 1 limit 1;", IP_);
	//mysql_query_format("SELECT `ban`.`name`,`ban`.`IP`,`ban`.`type`, UNIX_TIMESTAMP(`ban`.`time`), DATE_FORMAT(`ban`.`time`, '%%H:%%i, %%d.%%m.%%Yr'), `ban`.`date`, `fg_Players`.`Nick`, `ban`.`reason` FROM `ban` JOIN `fg_Players` WHERE (`ban`.`name` = '%s' OR `ban`.`IP` = '%s' OR `ban`.`IP` = '%d.%d.*.*') AND `ban`.`admin` = `fg_Players`.`id` AND (`ban`.`time` > NOW() OR `ban`.`time` IS NULL) AND `ban`.`active` = 1", PlayerName(playerid), IPp, ip[0], ip[1]);
	mysql_store_result();

	if(!mysql_num_rows()) {
		mysql_free_result();
		return 0;
	}

	new buffer_banned[300], type, str_time, date[20], time_left[20], admin_banned[MAX_PLAYER_NAME], reason[64], nick_banned[MAX_PLAYER_NAME], ip_banned[16];
	
	mysql_fetch_row (buffer_banned, "|");
	sscanf (buffer_banned, "p<|>s[24]s[16]ds[20]ds[20]s[64]s[24]", nick_banned, ip_banned, type, date, str_time, time_left, reason, admin_banned);
	mysql_free_result ();

	if(type) {
		mysql_query_format("SELECT 1 FROM `whitelist` WHERE `name` = '%s' limit 1;", PlayerName(playerid));
		mysql_store_result();
		if(mysql_num_rows()) {
			mysql_free_result();
			return 0;
		}
		mysql_free_result();

		format(buffer_banned, sizeof (buffer_banned), "Twój adres IP zosta³ zbanowany promieniowo.\n\nnSzczegó³y banicji:\nNick: %s\nData zbanowania: %s\nAdmin: %s\nPowód: %s\nAdres IP: %s", nick_banned, date, admin_banned, reason, ip_banned);
		ShowPlayerDialog(playerid, 13124, DIALOG_STYLE_MSGBOX, "{FF0000}Banicja", buffer_banned, "Wyjdz", "");
		return 1;
	}
	else {
		if(!str_time) {
			format(buffer_banned, sizeof (buffer_banned), "Twoje konto lub IP zosta³o zbanowanie permanentnie.\n\nnSzczegó³y banicji:\nNick: %s\nData zbanowania: %s\nAdmin: %s\nAdres IP: %s", nick_banned, date, admin_banned, reason, ip_banned);
			ShowPlayerDialog(playerid, 13124, DIALOG_STYLE_MSGBOX, "{FF0000}Banicja", buffer_banned, "Wyjdz", "");
			return 1;
		}
		else {
			format(buffer_banned, sizeof (buffer_banned), "Twoje konto zosta³o zbanowane do %s.\n\nSzczegó³y banicji:\nNick: %s\nData zbanowania: %s\nAdmin: %s\nPowód: %s\nAdres IP: %s", time_left, nick_banned, date, admin_banned, reason, ip_banned);
			ShowPlayerDialog(playerid, 13124, DIALOG_STYLE_MSGBOX, "{FF0000}Banicja", buffer_banned, "Wyjdz", "");
			return 1;
		}
	}
}

stock SoundForAll(sound)
{
	foreachPly (x) {
		PlayerPlaySound(x,sound,0.0,0.0,0.0);
	}
}	

WriteLog(const log[])
{
	printf ("%s", log);
}
/*
stock CreatePlayerTD(playerid)
{
	RaceInfo[playerid] = CreatePlayerTextDraw(playerid,454.000000,318.000000,"_");
	PlayerTextDrawBackgroundColor(playerid,RaceInfo[playerid],0x000000ff);
	PlayerTextDrawFont(playerid,RaceInfo[playerid],1);
	PlayerTextDrawLetterSize(playerid,RaceInfo[playerid],0.399999,1.600000);
	PlayerTextDrawColor(playerid,playerid, RaceInfo[playerid],0xffffffff);
	PlayerTextDrawSetProportional(playerid,RaceInfo[playerid],1);
	PlayerTextDrawSetOutline(playerid,RaceInfo[playerid],1);
	PlayerTextDrawSetShadow(playerid,RaceInfo[playerid],1);
	PlayerTextDrawAlignment(playerid,RaceInfo[playerid],0);

	TDNick[playerid] = CreatePlayerTextDraw(playerid,20.000000,434.000000,"(0) Game");
	PlayerTextDrawAlignment(playerid,TDNick[playerid],0);
	PlayerTextDrawBackgroundColor(playerid,TDNick[playerid],0xffffff33);
	PlayerTextDrawFont(playerid,TDNick[playerid],1);
	PlayerTextDrawLetterSize(playerid,TDNick[playerid],0.199999,1.000000);
	PlayerTextDrawColor(playerid,TDNick[playerid],0x000000ff);
	PlayerTextDrawSetOutline(playerid,TDNick[playerid],1);
	PlayerTextDrawSetShadow(playerid,TDNick[playerid],1);
	PlayerTextDrawSetProportional(playerid,TDNick[playerid],1);

	StatyPingu[playerid] = CreatePlayerTextDraw(playerid,110.000000,436.000000,"89 ms");
	PlayerTextDrawAlignment(playerid,StatyPingu[playerid],3);
	PlayerTextDrawBackgroundColor(playerid,StatyPingu[playerid],0xffffff33);
	PlayerTextDrawFont(playerid,StatyPingu[playerid],1);
	PlayerTextDrawLetterSize(playerid,StatyPingu[playerid],0.199999,1.000000);
	PlayerTextDrawColor(playerid,StatyPingu[playerid],0x000000ff);
	PlayerTextDrawSetOutline(playerid,StatyPingu[playerid],1);
	PlayerTextDrawSetShadow(playerid,StatyPingu[playerid],1);
	PlayerTextDrawSetProportional(playerid,StatyPingu[playerid],1);

	LevelTD[playerid] = CreatePlayerTextDraw(playerid,130.000000,436.000000,"27");
	PlayerTextDrawAlignment(playerid,LevelTD[playerid],0);
	PlayerTextDrawFont(playerid,LevelTD[playerid],1);
	PlayerTextDrawLetterSize(playerid,LevelTD[playerid],0.299999,1.100000);
	PlayerTextDrawBackgroundColor(playerid,LevelTD[playerid],0xffffff33);
	PlayerTextDrawColor(playerid,LevelTD[playerid],0x000000ff);
	PlayerTextDrawSetOutline(playerid,LevelTD[playerid],1);
	PlayerTextDrawSetProportional(playerid,LevelTD[playerid],1);
	PlayerTextDrawSetShadow(playerid,LevelTD[playerid],1);

	ExpTD[playerid] = CreatePlayerTextDraw(playerid,159.000000,436.000000,"8/24");
	PlayerTextDrawAlignment(playerid,ExpTD[playerid],1);
	PlayerTextDrawBackgroundColor(playerid,ExpTD[playerid],0xffffff33);
	PlayerTextDrawFont(playerid,ExpTD[playerid],1);
	PlayerTextDrawLetterSize(playerid,ExpTD[playerid],0.199999,1.100000);
	PlayerTextDrawColor(playerid,ExpTD[playerid],0x000000ff);
	PlayerTextDrawSetOutline(playerid,ExpTD[playerid],1);
	PlayerTextDrawSetProportional(playerid,ExpTD[playerid],1);
	PlayerTextDrawSetShadow(playerid,ExpTD[playerid],1);

	ZabojstwTD[playerid] = CreatePlayerTextDraw(playerid,225.000000,436.000000,"926");
	PlayerTextDrawAlignment(playerid,ZabojstwTD[playerid],0);
	PlayerTextDrawBackgroundColor(playerid,ZabojstwTD[playerid],0xffffff33);
	PlayerTextDrawFont(playerid,ZabojstwTD[playerid],1);
	PlayerTextDrawLetterSize(playerid,ZabojstwTD[playerid],0.299999,1.100000);
	PlayerTextDrawColor(playerid,ZabojstwTD[playerid],0x000000ff);
	PlayerTextDrawSetOutline(playerid,ZabojstwTD[playerid],1);
	PlayerTextDrawSetShadow(playerid,ZabojstwTD[playerid],1);
	PlayerTextDrawSetProportional(playerid,ZabojstwTD[playerid],1);

	CzasGryTD[playerid] = CreatePlayerTextDraw(playerid,285.000000,436.000000,"2 h 26 min");
	PlayerTextDrawAlignment(playerid,CzasGryTD[playerid],0);
	PlayerTextDrawBackgroundColor(playerid,CzasGryTD[playerid],0xffffff33);
	PlayerTextDrawFont(playerid,CzasGryTD[playerid],1);
	PlayerTextDrawLetterSize(playerid,CzasGryTD[playerid],0.299999,1.100000);
	PlayerTextDrawColor(playerid,CzasGryTD[playerid],0x000000ff);
	PlayerTextDrawSetOutline(playerid,CzasGryTD[playerid],1);
	PlayerTextDrawSetProportional(playerid,CzasGryTD[playerid],1);
	PlayerTextDrawSetShadow(playerid,CzasGryTD[playerid],1);

	AnnTD[playerid] = CreatePlayerTextDraw(playerid,320.000000,150.000000, "_");
	TextDrawTextSize(AnnTD[playerid],300.000000,300.000000);
	PlayerTextDrawColor(playerid,AnnTD[playerid], 0xFFFFFFFF);
	PlayerTextDrawAlignment(playerid,AnnTD[playerid],2);
	PlayerTextDrawBackgroundColor(playerid,AnnTD[playerid],0x00000040);
	PlayerTextDrawFont(playerid,AnnTD[playerid],1);
	PlayerTextDrawLetterSize(playerid,AnnTD[playerid],0.50000,1.6000);
	PlayerTextDrawSetProportional(playerid,AnnTD[playerid],1);
	PlayerTextDrawSetOutline(playerid,AnnTD[playerid],1);
	
	CarInfo[playerid] = CreatePlayerTextDraw(playerid,553.000000,330.000000,"~b~~h~WCZYTYWANIE~n~X km/h   ]]]]]]");
	PlayerTextDrawAlignment(playerid,CarInfo[playerid],2);
	PlayerTextDrawBackgroundColor(playerid,CarInfo[playerid],0x000000ff);
	PlayerTextDrawFont(playerid,CarInfo[playerid],2);
	PlayerTextDrawLetterSize(playerid,CarInfo[playerid],0.399999,1.500000);
	PlayerTextDrawColor(playerid,CarInfo[playerid],0xffffffff);
	PlayerTextDrawSetProportional(playerid,CarInfo[playerid],1);
	PlayerTextDrawSetShadow(playerid,CarInfo[playerid],1);
	//return 1;
}*/
new Float:CelaSpawn[11][3] = {
	{-1849.7830,1036.6741,49.0326},
	{-1849.8215,1031.6779,48.9995},
	{-1849.4756,1027.5597,48.9738},
	{-1849.5778,1023.4279,48.9462},
	{-1849.4622,1019.3947,48.9201},
	{-1850.0167,1014.3398,48.8845},
	{-1848.8113,1010.5651,48.8647},
	{-1849.4840,1004.8911,48.8245},
	{-1849.4874,1001.3494,48.8011},
	{-1849.5114,1018.5952,46.0939},
	{-1849.0236,1027.4972,46.0576}
};
new playerColors[100] = {
0x1874CDAA,0xFFB90Faa,0xDC143Caa,0x98F5FFaa,0x7FFFD4aa,0x912CEEaa,0xC00040aa,0x66cc99aa,0x00ccccaa,0x33ccffaa,
0x33FFFFAA,0x009933aa,0xFF3333aa,0x3333CCaa,0x003366aa,0x008080aa,0xB22222aa,0xFF1493aa,0x8A2BE2aa,0x32CD32aa,
0xE0FFFFAA,0x00BFFFaa,0xFF6030aa,0xFFB100aa,0x406090aa,0x0000FFaa,0x8000FFaa,0x40E010aa,0xFF8040aa,0xFF00F0aa,
0xC0FF50AA,0x80FFC0aa,0x8020FFaa,0x40A0E0aa,0xFFFF40aa,0x008040FF,0xC02050aa,0xFFA070aa,0xFF8010aa,0xFF2030aa,
0x80A0C0AA,0x80C040AA,0x24C005aa,0x00FFFFaa,0x00A0D0aa,0x004070aa,0x80E0FFaa,0x8020B0aa,0xA79C20aa,0x0080B0aa,
0x80C0FFAA,0x004080AA,0xE0D560aa,0xFF00D5aa,0xF4A460aa,0x4169E1aa,0x006400aa,0x00FFFFaa,0xDAA520aa,0x9370DBaa,
0x000080AA,0xDC143CAA,0xFF4500aa,0x708090aa,0xFF6347aa,0x800080aa,0x00FF7Faa,0x20B2AAaa,0xFF1493aa,0x6633ffaa,
0x00ff99AA,0xcccc00AA,0xffcc00aa,0xff9900aa,0xcc66ffaa,0x5F9F9Faa,0x7093DBaa,0x238E23aa,0x4D4DFFaa,0x3333ffaa,
0x9F945CAA,0xDCDE3DAA,0x10C9C5aa,0x70524Daa,0x0BE472aa,0x8A2CD7aa,0x6152C2aa,0xCF72A9aa,0xE59338aa,0xEEDC2Daa,
0x3FE65CAA,0xFFD720AA,0xBD34DAaa,0x54137Daa,0xAF2FF3aa,0x4B8987aa,0xE3AC12aa,0xC1F7ECaa,0xA04E0Aaa,0xD8C762aa
};
stock SelectPlayerColor(playerid)
{
	#pragma unused playerid
	return playerColors[random (sizeof (playerColors))];
}
new Float:gRandomPlayerSpawns[29][4] = {
	{1046.6985,-2470.4265,3.0708,57.3478},
	{2938.0244,-744.8797,7.4766,267.8807},
	{-2943.3792,-203.6268,10.6883,89.0869},
	{948.788574, 2439.683350, 10.874555,0.0000},
	{1184.7300,-1323.5900,13.5738,268.3000},
	{1555.1100,-1365.0500,329.4535,30.4700},
	{296.6456,1992.7300,17.6406,183.4263},
	{-2647.6147,632.6185,14.4545,178.2300},
	{2292.5259,2469.1602,10.8203,87.2566},
	{-1251.5940, -37.0473, 14.4846,177.3333},
	{-1426.5869,501.2663,3.0391,89.8767},
    {2264.2097,1398.7369,42.8203,270.6329},
	{2206.0476,1284.8809,10.8203,269.8790},
	{-810.4446,1817.1174,7.0000,272.9978},
	{-227.8089,4300.1089,85.1468,18.0443}, //Puszcza
	{-5906.8789,-2154.0754,69.2307,52.0007}, //Kanaly
	{1384.0399,267.9193,19.5669,65.9075},
	{665.1572,-583.4140,16.3359,86.9334},
	{2585.36596680,-3780.53417969,12.14526510,0.0000},
	{1899.8889,2403.6035,10.9547,268.3536},
	{-2157.1404,-425.8986,35.3359,243.5235},
	{-2530.1057,-610.3799,132.5625,266.9446},
	{623.1945,-1391.3428,13.3554,272.2177},
	{1045.0673,-347.7749,73.9922,88.8454},
	{2663.7100,665.5128,10.8203,239.1025},
    {1214.8420,2205.0249,511.9854,0.00000},
    {3280.3330,-1646.8104,26.4978,0.00000},
    {3928.7375,54.7928,17.8382,0.00000},
	{-1547.1345,-2739.2080,48.5407,146.3788}
};

forward ControlOn(playerid);
public ControlOn(playerid) {
	if(IsPlayerConnected(playerid) == 0) return 0;
	TogglePlayerControllable(playerid, 1);
	return 1;
}

stock UpSpec(playerid)
{
	if(gSpectateID[playerid] >= MAX_GRACZY) return 1;
	
	for(new i = gSpectateID[playerid]; i < MAX_GRACZY; i++)
	{
		if(i == gSpectateID[playerid]) continue;
		if(IsPlayerConnected(i) && i != playerid && GetPlayerState(i) > 0 && GetPlayerState(i) < 7)
		{
			StartSpec(playerid, i);
			break;
		}
	}
	return 1;
}

stock DownSpec(playerid)
{
	if(gSpectateID[playerid] < 1) return 1;
	
	for(new i = gSpectateID[playerid]; --i;)
	{
		if(i == gSpectateID[playerid]) continue;
		if(IsPlayerConnected(i) && i != playerid && GetPlayerState(i) > 0 && GetPlayerState(i) < 7)
		{
			StartSpec(playerid, i);
			break;
		}
	}
	return 1;
}

stock StartSpec(playerid, specid) 
{
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(specid));
	SetPlayerInterior(playerid, GetPlayerInterior(specid));
	
	gSpectateID[playerid] = specid;
	if(IsPlayerInAnyVehicle(specid))
	{
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectateVehicle(playerid, GetPlayerVehicleID(specid));
	}
	else {
		TogglePlayerSpectating(playerid, 1);
		PlayerSpectatePlayer(playerid, specid);
	}
	
	new buf[50];
	format(buf,sizeof(buf),"_~n~_~n~_~n~_~n~_~n~~w~%s - ID:%d", PlayerName(specid), specid);
	AnnForPlayer(playerid, 3500, buf);
	return 1;
}

stock StopSpec(playerid)
{
	TogglePlayerSpectating(playerid, 0);
	AnnForPlayer(playerid, 1000, "_~n~_~n~_~n~_~n~_~n~~w~Stop Spec");
	gSpectateID[playerid] = -1;
	return 1;
}

stock SetPlayerRandomSpawn(playerid)
{

	SetCameraBehindPlayer(playerid);
	ResetPlayerWeapons(playerid);

//	TogglePlayerControllable(playerid, 0);
	//SetTimerEx("JailUnfreeze",2500,0,"i",playerid);

	if(PlayerGangInfo[playerid][gID] != -1)
	{
	    new id = PlayerGangInfo[playerid][gID];
	    if(floatround(GangInfo[id][gSpawnX]) != 0)
		{
	    	SetPlayerPos(playerid,GangInfo[id][gSpawnX],GangInfo[id][gSpawnY],GangInfo[id][gSpawnZ]);
	    	SetPlayerInterior(playerid,0);
			SetPlayerVirtualWorld(playerid,0);
			PlayerSetColor(playerid);
			SetPlayerTeam(playerid,playerid+10);
			GiveStandardWeapon(playerid);
	    	return 1;
	    }
	}

	if(MaDom[playerid])
	{
		new x=HouseID[playerid];
		SetPlayerPos(playerid,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
		PlayerSetColor(playerid);
		SetPlayerTeam(playerid,playerid+10);
		GiveStandardWeapon(playerid);
		return 1;
	}

	new rand = random(sizeof(gRandomPlayerSpawns));
	SetPlayerPos(playerid, gRandomPlayerSpawns[rand][0], gRandomPlayerSpawns[rand][1], gRandomPlayerSpawns[rand][2]);
	SetPlayerFacingAngle(playerid, gRandomPlayerSpawns[rand][3]);
	SetPlayerInterior(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
	PlayerSetColor(playerid);
	SetPlayerTeam(playerid,playerid+10);
	GiveStandardWeapon(playerid);
	return 1;
}

/*
fileGet (const fname[], const key[]) {
	new buf[255], name_row[32], name_values[128], File:fget = fopen (fname, io_read);
	if (!fget) {
		print ("Function [fileGet]: Nie mozna otworzyc pliku.");
		fclose (fget);
	}
	while (fread (fget, buf)) {
		file_stripNewline (buf);
		if (sscanf (buf, "p<=>s[32]s[128]", name_row, name_values)) continue;
		if (!strcmp (name_row, key, true)) {
			file_stripNewline (name_values);
			fclose (fget);
			return name_values;
		}
	}
	fclose (fget);
	return name_values;
}

file_stripNewline (string[]) {
	new length = strlen (string);
	if (!string[0]) return;
	if ((string[length - 1] == '\n') || (string[length - 1] == '\r')) {
		string[length - 1] = 0;
		if (!string[0]) return;
		if ((string[length - 2] == '\n') || (string[length - 2] == '\r')) string[length - 2] = 0;
	}
}*/

stock checkPlayerCrash (ply) 
{
	if (!IsPlayerConnected (ply)) return 0;
	
	new nick[19], buffer_crash[40];
	
	GetPlayerName (ply, nick, sizeof (nick));
	
	// format do pliku
	format (buffer_crash, sizeof (buffer_crash), "%s%s.crh", PATH_PLAYER_CRASH, nick);
	
	if (!fexist (buffer_crash)) return 0;
	else {
		SetPVarInt (ply, #crash.time, strval (fileGet (buffer_crash, "time")));
		SetPVarFloat (ply, #crash.x, floatstr (fileGet (buffer_crash, "x")));
		SetPVarFloat (ply, #crash.y, floatstr (fileGet (buffer_crash, "y")));
		SetPVarFloat (ply, #crash.z, floatstr (fileGet (buffer_crash, "z")));
		SetPVarFloat (ply, #crash.rot, floatstr (fileGet (buffer_crash, "rot")));
		fremove (buffer_crash);
	}
	return 1;
}

stock createCrashFileByPlayer (ply) {
	if (!IsPlayerConnected (ply)) return 0;
	
	new nick[19], Float:vpos[4], File:crashfile, buffer_crash[127];
	
	GetPlayerPos (ply, vpos[0], vpos[1], vpos[2]);
	GetPlayerFacingAngle (ply, vpos[3]);
	GetPlayerName (ply, nick, sizeof (nick));
	
	// format do pliku
	format (buffer_crash, sizeof (buffer_crash), "%s%s.crh", PATH_PLAYER_CRASH, nick);
	
	// tworzenie pliku po crashu
	crashfile = fopen (buffer_crash, io_write);
	if (!crashfile) {
		printf ("[createCrsahFileByPlayer:!crashfile]: Nie mozna stworzyc pliku.");
		return 0;
	}
	
	// sprawdzanie czy na serwerze gra mniej niz 15 minut
	if (getPlayerOnlineMinutes(ply)%60 < 3) {
		return 1;
	}
	
	// formatowanie tagow i zapis danych
	format (buffer_crash, sizeof (buffer_crash), "time=%d\r\nx=%4.3f\r\ny=%4.3f\r\nz=%4.2f\r\nrot=%3.2f", getPlayerOnlineTime(ply), vpos[0], vpos[1], vpos[2], vpos[3]);
	// zapis
	fwrite (crashfile, buffer_crash);
	// zamykanie pliku
	fclose (crashfile);
	// zwracamy true jesli powiedziecie sie wszystko ;-)
	return 1;
}

CMD:crashplayer (playerid, params[]) 
{
	if (!IsAdmin (playerid, 4)) return 0;
	new target;
	if (isnull (params)) return SendClientMessage (playerid, -1, "Uzyj: /crashplayer <id>");
	if (sscanf (params, "u", target)) return SendClientMessage (playerid, -1, "Uzyj: /crashplayer <id>");
	if (target == 0xffff) return SendClientMessage (playerid, -1, "Gracz nie ma na serwerze");
	
	new Float:pos[3];
	SetPlayerVirtualWorld (target, 5000);
	GetPlayerPos(target, pos[0], pos[1], pos[2]);
 	CreatePlayerObject(target, 385, pos[0], pos[1], pos[2], 0, 0, 0);
	SendClientMessage (playerid, -1, "Done.");
	return 1;
}