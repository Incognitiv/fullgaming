#include <a_samp>
#include <mysql>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <dropweapons>
#include <regex>
#include <dmap>
#include <YSI\y_timers>
#include <YSI\y_iterate>

#pragma tabsize 0

#if !defined isnull
	#define isnull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#endif

#define foreachPly(%1) foreach(new %1 : Player)

#define FILE_SETTINGS "/GoldMap/Ustawienia.ini"
#define FILE_TOTALSTAT "/GoldMap/Statystyki.ini"

#define WERSJA_TD "3.1.1629"
#define OBECNA_WERSJA "ver. 3.1.1629"
#define KOMPILACJA "skompilowano dnia 2013-06-09 02:54 przez kamil-pc"

new DEBUG_MODE = 0;

KickEx (ply) {
	SetTimerEx(!#kickPly, 200, false, "i", ply);
}

forward kickPly(p); public kickPly(p) Kick (p);

new serverHighestID;
new VoteQuest[80];

isNumeric (const string[]) { // by ktos tam
	if (isnull (string)) return 0;
	for (new i, j = strlen (string); i<j; i++) {
		if (!((string[i] <= '9' && string[i] >= '0') || (i==0 && (string[i]=='-' || string[i]=='+')))) {
			return false;
		}
	}
	return 0;
}

stock mktime(hour,minute,second,day,month,year) {
	new timestamp2;

	timestamp2 = second + (minute * 60) + (hour * 3600);

	new days_of_month[12];

	if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) ) {
			days_of_month = {31,29,31,30,31,30,31,31,30,31,30,31}; // Schaltjahr
		} else {
			days_of_month = {31,28,31,30,31,30,31,31,30,31,30,31}; // keins
		}
	new days_this_year = 0;
	days_this_year = day;
	if(month > 1) { // No January Calculation, because its always the 0 past months
		for(new i=0; i<month-1;i++) {
			days_this_year += days_of_month[i];
		}
	}
	timestamp2 += days_this_year * 86400;

	for(new j=1970;j<year;j++) {
		timestamp2 += 31536000;
		if ( ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0) )  timestamp2 += 86400; // Schaltjahr + 1 Tag
	}

	return timestamp2;
}

#define dli(%1,%2,%3,%4) ((%1==1)?(%2):(((%1% 10>1)&&(%1% 10<5)&&!((%1% 100>=10)&&(%1% 100<=21)))?(%3):(%4)))

#define VW_WG			20
#define VW_CHOWANY		21
#define VW_DERBY		22
#define VW_SS			23
#define VW_TOWER		24
#define VW_HAY			25
#define VW_ONEDE		26
#define VW_MINIGUN		27
#define VW_SNIPER		28
#define VW_CHAINSAWN 	29

#include "FGS/colors"
#include "FGS/definitions"
#include "FGS/visual"
#include "FGS/function"
#include "FGS/cars"
#include "FGS/timers"
#include "FGS/object"
#include "FGS/attractions"
#include "FGS/games"
#include "FGS/cmd_register"
#include "FGS/cmd_admin"
#include "FGS/cmd_mod"
#include "FGS/cmd_vip"
#include "FGS/cmd_players"
#include "FGS/cmd_teleports"
#include "FGS/cmd_anims"

#include "FGS/fuckcleo"
#include "FGS/priv_vehicles"
//#include "FGS/priv_vehicless

#define REVISION "1111"

// PORTFEL GRACZA
#define API_URL	"serv4web.pl/Api?aut_id=706916952&sms="

enum _API_sms { 
	API_SVR[4], KWOTA,SMS, 
	SMS_MSG[16], COST[6] 
};

new API_sms[][_API_sms] = {
	{"s1", 2, 72464, "PLN.SERV4WEB2", "2,46"},
	{"s2", 6, 75464, "PLN.SERV4WEB5", "6,15"},
	{"s3", 11, 79464, "PLN.SERV4WEB9", "11,07"},
	{"s5", 23, 91955, "PLN.SERV4WEB19", "23,37"},
	{"s6", 30, 92555, "PLN.SERV4WEB25", "30,35"}
};

new 
	Float:ccccc_posX[MAX_GRACZY],
	Float:ccccc_posY[MAX_GRACZY],
	Float:ccccc_posZ[MAX_GRACZY]
;

new MySQL:MySQLcon;
new ZabitychPodRzad[MAX_GRACZY];
new bool:PlayerTut[MAX_GRACZY];
new InRC[MAX_GRACZY];
new CurrTimer;
new TrzyDeTimer[MAX_GRACZY];
new LastInfo;
new bool:CarInfoChce[MAX_GRACZY];
new BurdelikUser[MAX_GRACZY];
new BurdelUser;
new BurdelUserTwo;
new BocianieGniazdo;
new CPNEnter;
new CPNExit;
new RestaEnter;
new RestaExit;
new BarEnter;
new BarExit;
new ObokBazyEnter;
new ObokBazyExit;
new Burdelik;
new BurdelikExit;
new BurdelikAction;
new loteria;
new loteriavip;
new MGangPickup;
new NGangPickup;
new sflotw;
new sflotd;
new strefasniper2;
new strefasniper3;
new strefasniper;
new dowodzenie;
new dowodzeniewnetrze;
new PickupBasen;
new latarniaplaza;
new infotrening;
new infobrama2;
new infobramapd1;
new infobramapd2;
new strazak;
new wojskowy;
new autokomis;
new bronieb;
new grove;
new windamost;
new WindaLVDol;
new WindaLVGora;
new PanelID[MAX_GRACZY];

callback-> UpdateNextLevel(x)
{
    if(IsPlayerConnected(x))
	{
		Respekt[x] += 1;
  		Player[x][Level] = GetPlayerLevel(x);
	}
	return 1;
}

stock StrToLower(StriNg[]){
	new Result[255];
	for(new Char = 0; Char < strlen(StriNg); Char++){
	    if(StriNg[Char] >= 'A' && StriNg[Char] <= 'Z')
	        format(Result, sizeof(Result), "%s%c", Result, tolower(StriNg[Char]));
		else
			format(Result, sizeof(Result), "%s%c", Result, StriNg[Char]);
	}
	return Result;
}

stock CreateGangZoneInArea(zonename,radius,posx,posy)
{
	zonename = GangZoneCreate(posx-radius,posy-radius,posx+radius,posy+radius);
	return 1;
}

//----kana³y------

stock IsValidDescription(String[])
{
	if(strlen(String) > MAX_DESC)
	    return false;

    for(new Char = 0; Char < strlen(String); Char++)
    {
        if(String[Char] >= 'a' && String[Char] <= 'z')
            continue;
		if(String[Char] >= 'A' && String[Char] <= 'Z')
		    continue;
		if(String[Char] >= '0' && String[Char] <= '9')
		    continue;
		if(String[Char] == ' ' || String[Char] == '.' || String[Char] == ',' || String[Char] == '!' || String[Char] == '?' || String[Char] == '-' || String[Char] == '[' || String[Char] == ']')
		    continue;
		return false;
	}
	return true;
}

forward ShowAndHide(Text:TD, AlphaC, AlphaB, time);
public ShowAndHide(Text:TD, AlphaC, AlphaB, time)
{
	KillTimer(CurrTimer);

	if (time > 0) {

		if (AlphaC < ALPHA_C) AlphaC += COLOR_STEP;
		if (AlphaC > ALPHA_C) AlphaC = ALPHA_C;
		if (AlphaB < ALPHA_B) AlphaB += BACK_STEP;
		if (AlphaB > ALPHA_B) AlphaB = ALPHA_B;

		TextDrawColor(TD, ((ANN_COLOR>>>8)<<8)|AlphaC);
		TextDrawBackgroundColor(TD, ((BACK_COLOR>>>8)<<8)|AlphaB);
		TextDrawShowForAll(TD);

		if (AlphaC == ALPHA_C && AlphaB == ALPHA_B)
			CurrTimer = SetTimerEx("ShowAndHide", time, false, "dddd", _:TD, AlphaC, AlphaB, 0);
		else
		    CurrTimer = SetTimerEx("ShowAndHide", DELAY, false, "dddd", _:TD,  AlphaC, AlphaB, time);

	} else {
		if (AlphaC > 0) AlphaC -= COLOR_STEP;
		if (AlphaC < 0) AlphaC = 0;
		if (AlphaB > 0) AlphaB -= BACK_STEP;
		if (AlphaB < 0) AlphaB = 0;

		TextDrawColor(TD, ((ANN_COLOR>>>8)<<8)|AlphaC);
		TextDrawBackgroundColor(TD, ((BACK_COLOR>>>8)<<8)|AlphaB);
  		TextDrawShowForAll(TD);

  		if (AlphaC == 0 && AlphaB == 0)
			TextDrawHideForAll(TD);
		else {
		    CurrTimer = SetTimerEx("ShowAndHide", DELAY, false, "dddd", _:TD, AlphaC, AlphaB, 0);
		}
	}
}

forward FadeForPlayer(time, string[]);
public FadeForPlayer(time, string[])
{
	TextDrawSetString(AnnFade, string);
	ShowAndHide(AnnFade, 0, 0, time*1000);
}

static const Infos[18][222] =
{
	" * "C_INFO" Pamiêtaj je¿eli widzisz gracza ³ami¹cego regulamin wpisz /raport [ID] [Powód].",
	" * "C_INFO" Grasz na serwerze 1 raz? Podstawowe komendy to: /cmd, /atrakcje, /teles, /cars.",
	" * "C_INFO" Pragniesz wyró¿niaæ siê od pozosta³ych graczy? Konto VIP ci to umo¿liwi! Wiêcej pod /vip.",
	" * "C_INFO" Nie podoba ci siê pogoda? Wpisz /pogoda aby j¹ zmieniæ.",
	" * "C_INFO" Komend¹ /idzdo [ID] teleportujesz siê do innego gracza.",
	" * "C_INFO" Za pe³n¹ godzinê gry na serwerze otrzymujesz premiê w wysokoœci 100 pkt exp!",
	" * "C_INFO" Nie wiesz o co chodzi z tym exp i level? Wpisz /exphelp",
	" * "C_INFO" Masz ochotê na niez³¹ zabawê? Wpisz /atrakcje!",
	" * "C_INFO" Komend¹ /nBronie zmieniasz wygl¹d modeli broni na nowe.",
	" * "C_INFO" Wszystkie komendy serwera znajdziesz pod komend¹ /cmd",
	" * "C_INFO" Chcesz pos³uchaæ radia? Wpisz /radio",
	" * "C_INFO" Chcesz mieæ prywatny zapisywany pojazd? Wpisz /pojazd.",
	" * "C_INFO" Chcesz mieæ w³asny gang na serwerze? Zdob¹dŸ w³adzê i wpisz /gang",
	" * "C_INFO" Nie wiesz jak zdobywaæ Exp? Aby siê dowiedzieæ wpisz /ExpHelp",
	" * "C_INFO" Nie znasz regulaminu serwera? Wpisz /regulamin.",
	" * "C_INFO" Nie jesteœ zarejestrowany? Nie zapisuj¹ ci siê staty? Wpisz /Rejestracja",
	" * "C_INFO" Chcesz mieæ neony przy samochodzie? /neony !",
	" * "C_INFO" Chcesz zobaczyæ TOP-10? W tym celu wpisz komendê /Staty"
};

#define A_CHAR(%0) for(new i = strlen(%0) - 1; i >= 0; i--)\
	if(%0[i] == '%')\
		%0[i] = '#'

stock TuneVehicle(vehicleid)
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
        default:
        return 0;
	}
    return 1;
}

stock GetVehicleTunigType(vehicleid) // by DrunkeR
{
    switch(GetVehicleModel(vehicleid))
    {
        case 400, 401, 402, 404, 405, 409, 410, 411, 415, 418,
             419, 420, 421, 422, 424, 426, 436, 439, 442, 445,
             451, 458, 466, 467, 474, 475, 477, 478, 479, 480,
             489, 491, 492, 496, 500, 505, 506, 507, 516, 517,
             518, 526, 527, 529, 533, 540, 541, 542, 545, 546,
             547, 549, 550, 551, 555, 575, 579, 580, 585, 587,
             589, 600, 602, 603:
            return 1; // Modifications: Transfender ( Various )

        case 558, 559, 560, 561, 562, 565:
            return 2; // Modifications: Wheel Arch Angels ( Sport Vehicles )

        case 412, 534, 535, 536, 566, 567, 576:
            return 3; // Modifications: Loco Low Co ( Lowriders )
    }
    return 0; // Modifications: None
}

stock MyStrCmp(StringOne[], StringTwo[])
{
	if(strlen(StringOne) != strlen(StringTwo))
	    return false;
	for(new Char = 0; Char < strlen(StringOne); Char++)
	    if(StringOne[Char] != StringTwo[Char])
	        return false;
	return true;
}


stock ShowVehicleControlDialog(playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		return ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG, DIALOG_STYLE_LIST, "Kontrola Pojazdu", "¤ Silnik\n¤ Œwiat³a\n¤ Alarm\n¤ Drzwi Otwórz Zamknij\n¤ Maska\n¤ Baga¿nik\n¤ Tablica Rejestracyjna", "OK", "Anuluj");
	}
	else return SendClientMessage(playerid, 0x08FD04FF, " * Musisz byæ w pojeŸdzie aby u¿yæ tej komendy!");
}

static const weaponNames[MAX_WEAPONS][15] = {
	"Shotgun",
	"Combat Shotgun",
	"Micro Uzi",
	"Tec9",
	"MP5",
	"AK47",
	"M4"
};
static const weaponIDs[MAX_WEAPONS] = {
	25,     //Shotgun
	27,     //Combat shotgun
	28,     //Micro Uzi
	32,     //Tec9
	30,     //AK47
	31     //M4
};
static const weaponCost[MAX_WEAPONS] = {
	7000,
	15000,
	7000,
	5000,
	15000,
	25000,
	30000
};
static const weaponAmmo[MAX_WEAPONS] = {
	50,
	80,
	500,
	500,
	750,
	500,
	500
};

new GameCreate;

new PlayerWeapon[MAX_GRACZY][3];
new PlayerWeaponAmmo[MAX_GRACZY][3];

main()
{
    print("											   ");
	print("-> GameMode FullGaming "WERSJA_TD" Za³adowany !!!");
    print("											   ");
}

stock GetRandomColor(Type = 0, Model)
{
	if(Model == 420 || Model == 409 || Model == 601 || Model == 597 || Model == 599 || Model == 596 || Model == 432 || Model == 416 || Model == 433 || Model == 490 || Model == 407 || Model == 470 || Model == 437 || Model == 438)
	    return -1;
	if(Type == 0)
		return random(126);
	return random(2);
}

/*
AddAllClass(Float:x,Float:y,Float:z,Float:r,w1,a1,w2,a2,w3,a3)
for(new i = 1; i < 300; i++) AddPlayerClass(i,x,y,z,r,w1,a1,w2,a2,w3,a3);
*/
NGangQuit(PlayerId)
{
	PlayerSetColor(PlayerId);
	Player[PlayerId][NGang] = false;
}

MGangQuit(PlayerId)
{
 	PlayerSetColor(PlayerId);
	Player[PlayerId][MGang] = false;
}

IsValidSkin(skinid){
	#define MAX_BAD_SKINS 3
	new badSkins[MAX_BAD_SKINS] = {
	0,74, 268
	};
	if (skinid < 0 || skinid > 299) return false;
	for (new i = 0; i < MAX_BAD_SKINS; i++) {
		if (skinid == badSkins[i]) return false;
	}
	#undef MAX_BAD_SKINS
	return true;
}

public OnPlayerCleoDetected(playerid, cleoid)
{
	switch(cleoid)
	{
		case CLEO_FAKEKILL:
		{	
			banPlayer(playerid, "Fake kills");
		}
		case CLEO_CARWARP:
		{
			banPlayer(playerid, "Car warping");
		}
		case CLEO_PLAYERBUGGER:
		{
			banPlayer(playerid, "Playerbugger");
		}
		case CLEO_CARSWING:
		{
			banPlayer(playerid, "Car swing");
		}
		case CLEO_CAR_PARTICLE_SPAM:
		{
			banPlayer(playerid, "Car particle spam");
		}
	}
	return 1;
}

stock GetPlayerIP(playerid)
{
	new __ip__[16];
	GetPlayerIp(playerid, __ip__, 16);
	return __ip__;
}

stock banPlayer(playerid, reason[], admin=INVALID_PLAYER_ID, time = -1) // time default in days - using on antycheats
{
	new buf[128];
	if(time == -1 && admin == INVALID_PLAYER_ID) // default
	{
		format(buf, sizeof(buf), "INSERT INTO `ban` (`name`, `IP`, `type`, `date_created`, `date_end`, `admin`, `reason`) VALUES ('%s', '%s', '0', NOW(), DATE_ADD(NOW(), INTERVAL %d SECOND), '%d', '%s')", PlayerName(playerid), GetPlayerIP(playerid), 2*86400, 316, reason);
	} else {
		format(buf, sizeof(buf), "INSERT INTO `ban` (`name`, `IP`, `type`, `date_created`, `date_end`, `admin`, `reason`) VALUES ('%s', '%s', '0', NOW(), DATE_ADD(NOW(), INTERVAL %d SECOND), '%d', '%s')", PlayerName(playerid), GetPlayerIP(playerid), 2*86400, admin, reason);
	}
	mysql_query(buf);
	
	format(buf, sizeof(buf), " %s (%d) zosta³ zbanowany przez %s", PlayerName(playerid), playerid, (admin==INVALID_PLAYER_ID)?("Antycheat"): PlayerName(admin));
	SendClientMessageToAll(COLOR_RED, buf);
	
	format(buf, sizeof(buf), " Powód: %s", reason);
	SendClientMessageToAll(COLOR_RED, buf);
	KickEx(playerid);
	return 1;
}

stock dbstrtok(str[],ArgNum)
{

	new res[128];
	new pos[2];
	new num;
	new size = strlen(str);
	for(new x=0;x<size;x++){
		if(strfind(str[x],"|",true) == 0){
			num ++;
			if(ArgNum > 1){
				if(num == ArgNum-1){
					pos[0] = x;
				}

				if(num == ArgNum){
					pos[1] = x;
					break;
				}
			}else{
				pos[1] = x;
				break;
			}
		}
	}
	if(pos[1] == 0) pos[1] = size;
	if(ArgNum == 1){
		pos[0] = 0;
	}else{
		pos[0] ++;
	}
	strmid(res,str,pos[0],pos[1]);

	return res;
}

stock house_Get(x,arg)
{
	new res[128];
	new tmp[256];
	new id[4];
	valstr(id,x);
	new size = strlen(id);

	new File:domy = fopen("/GoldMap/Domy.txt",io_read);
	while(fread(domy,tmp)){
		new idd[4];
		strmid(idd,tmp,1,size);
		if(strcmp(id,idd,true)==0){
            res = dbstrtok(tmp,arg);
	    }
	}

	return res;
}

stock house_Update(x,arg,var[])
{

	new tmp[256];
	new id[4];
	valstr(id,x);
	new size = strlen(id);

	new File:domy = fopen("/GoldMap/Domy.txt",io_read);
	new File:domy2 = fopen("/GoldMap/Domy.tmp",io_write);
	while(fread(domy,tmp)){
		new idd[4];
		strmid(idd,tmp,0,size);
		new string[256];
		format(string,sizeof(string),"%s",tmp);
		if(strcmp(id,idd,true)==0){
	 		size = strlen(tmp);
			new cd;
			new pos[2];
			for(new i=0;i<size;i++){
			    if(strfind(tmp[i],"|",true)==0){
					cd ++;
					if(cd == arg-1){
					    pos[0] = i;
					}
					if(cd == arg){
					    pos[1] = i;
					    break;
					}
			    }
			}
			strmid(string,tmp,0,pos[0]+1);
			strcat(string,var);
			strdel(tmp,0,pos[1]);
			strcat(string,tmp);
	    }
	    fwrite(domy2,string);
	}
	fclose(domy);
	fclose(domy2);
	domy = fopen("/GoldMap/Domy.tmp",io_read);
	domy2 = fopen("/GoldMap/Domy.txt",io_write);
	while(fread(domy,tmp)){
	    fwrite(domy2,tmp);
	}
	fclose(domy);
	fclose(domy2);
	fremove("/GoldMap/Domy.tmp");

	return 1;
}

stock SellGun(playerid,gun,ammo,cost)
{
	if(Money[playerid] < cost && !IsVIP(playerid) && !IsAdmin(playerid, 1)) return SendClientMessage(playerid,COLOR_RED2," * Nie staæ ciê na t¹ broñ!");

	GivePlayerWeapon(playerid,gun,ammo);
	if(gun == 39) GivePlayerWeapon(playerid,40,1);
	Money[playerid] -= cost;
	GivePlayerMoney(playerid,0-cost);
	SendClientMessage(playerid,COLOR_GREEN," * Broñ zakupiona!");

	return 1;
}


stock Float:GetPlayerFallSpeed(playerid)
{
	new Float:fX,Float:fY,Float:fZ;
	GetPlayerVelocity(playerid, fX, fY, fZ);
	return floatmul(floatmul(fZ, fZ), 100);
}

stock IsPlayerRegistered(playerid)
{
    new tmp[256];
	new nick[25];
	GetPlayerName(playerid,nick,sizeof(nick));
	tmp = mysql_get("Nick",nick,"Pass","fg_Players");
	if(strlen(tmp) < 5 || strcmp(tmp,"(null)",false)==0) return 0;
	format(Pass[playerid],25,"%s",tmp);
	return 1;
}

stock IsNickRegistered(nick[])
{
	new tmp[256];
	tmp = mysql_get("Nick",nick,"Pass","fg_Players");
	if(strlen(tmp) < 5 || strcmp(tmp,"(null)",false)==0) return 0;
	return 1;
}

stock mysql_get(where[],fieldname[],variable[],db[])
{

	new dest[256];
	mysql_query_format("SELECT %s FROM %s WHERE %s = '%s' LIMIT 1;",variable,db,where,fieldname);

	mysql_store_result();
	mysql_fetch_row(dest, "|",);
	mysql_free_result();

	return dest;
}


stock IsPlayerInFreeZone(playerid)
{

	if(IsPlayerInArea(playerid, -102.0093,488.8185, 1661.8014, 2204.8889)) return 1;
	if(IsPlayerInArea(playerid,392.2149,782.6511,716.4636,1049.3254)) return 1;
	if(PlayerToPoint(140,playerid,2618.8625,2729.7747,36.5386)) return 1; //Minigun

	return 0;
}

stock EnableCountKillsArena(playerid)
{

	if(IsPlayerInArea(playerid, -102.0093,488.8185, 1661.8014, 2204.8889)) return 1;
	if(IsPlayerInArea(playerid,392.2149,782.6511,716.4636,1049.3254)) return 1;
	if(PlayerToPoint(140,playerid,2618.8625,2729.7747,36.5386)) return 1;
	if(PlayerToPoint(140,playerid,792.9435,-228.3622,16.2965)) return 1;

	return 0;
}

stock IsPlayerInBezDmZone(playerid)
{
    if(PlayerToPoint(50,playerid, 2461.4441,-2633.7026,13.6628)) return 1; //spawn z [TURBO] doki ls
    if(PlayerToPoint(200,playerid, 1895.4630,-439.2105,22.0969)) return 1; //tereno
    if(PlayerToPoint(200,playerid, -816.2776,1815.7792,7.0000)) return 1; //tama
    if(PlayerToPoint(300,playerid, -725.3582,1852.0554,-0.5141)) return 1; //tama
	if(IsPlayerInArea(playerid, 2874.8083,4436.8809,-2260.1697,-1247.6035)) return 1; //F1

	return 0;
}

stock PlayerLeaveGang(playerid)
{

	new GangID = PlayerGangInfo[playerid][gID];
	if(GangID == -1) return 1;
	PlayerGangInfo[playerid][gID] = -1;
	PlayerLabelOff(playerid);

	if(GangInfo[GangID][gLeader] == playerid){

	    new bool:cd;
	    foreachPly (x) {
			if(PlayerGangInfo[x][gID] == GangID){
	            GangInfo[GangID][gLeader] = x;
	            SendClientMessage(x,COLOR_ORANGE,"Twój szef opuœci³ gang i ty zosta³eœ(aœ) Szefem!");
	            cd = true;
	            break;
	    	}
	    }

	    if(!cd){
	        GangInfo[GangID][gLeader] = -1;
	    }

	}


	return 1;
}

new 
	Float:gPlayerCarUpdateVelocity[MAX_GRACZY][3],
	Float:gPlayerCarUpdateHP[MAX_GRACZY];

stock CarUpdate(playerid) 
{	
	GetVehicleVelocity(gPlayerLastVID[playerid], gPlayerCarUpdateVelocity[playerid][0], gPlayerCarUpdateVelocity[playerid][1], gPlayerCarUpdateVelocity[playerid][2]);
	GetVehicleHealth(gPlayerLastVID[playerid], gPlayerCarUpdateHP[playerid]);
	
	gPlayerCarUpdateHP[playerid] = ((gPlayerCarUpdateHP[playerid] - 250.0) / 750.0) * 100.0;
	if(gPlayerCarUpdateHP[playerid] < 0.0) gPlayerCarUpdateHP[playerid] = 0.0;
	if(gPlayerCarUpdateHP[playerid] > 100.0) gPlayerCarUpdateHP[playerid] = 100.0;
	
	static string[20];	
	format(string, sizeof (string), "%.1f ~h~kmh", ((gPlayerCarUpdateVelocity[playerid][0]*gPlayerCarUpdateVelocity[playerid][0] + gPlayerCarUpdateVelocity[playerid][1]*gPlayerCarUpdateVelocity[playerid][1] + gPlayerCarUpdateVelocity[playerid][2]*gPlayerCarUpdateVelocity[playerid][2]) * 210.528));
	PlayerTextDrawSetString(playerid, playerTd_carspeed[playerid], string);
	
	format (string, sizeof (string), "HP: ~h~%.1f", gPlayerCarUpdateHP[playerid]);
	PlayerTextDrawSetString(playerid, playerTd_carhealth[playerid], string);
}

forward Lotto();
public Lotto()
{
	new RandomInt = random(46)+1;
	new Winners, WinnerId;

	foreachPly (x) {
		if (Player[x][LottoNumber] == RandomInt) {
		    WinnerId = x;
		    Winners++;
		}
	}

	LottoMoney = LottoMoney*2;

    new String[256];
    
	if(Winners == 0)
	{
	    format(String, sizeof(String), " * {eab171}Wylosowana liczba lotto to {ffe5a1}%d{eab171}. Nikt nie wygra³, pula %d$ przechodzi na kolejne losowanie.", RandomInt, LottoMoney);
	    SendClientMessageToAll(0xffe5a1FF, String);
	}
	else if(Winners == 1)
	{
		GivePlayerMoney(WinnerId, LottoMoney);
		Money[WinnerId] += LottoMoney;
		format(String, sizeof(String), " * {eab171}Wylosowana liczba lotto to {ffe5a1}%d{eab171}. Zwyciêzc¹ jest %s (id %d). Nagroda: %d$.", RandomInt, PlayerName(WinnerId), WinnerId, LottoMoney);
	    LottoMoney = 0;
	    SendClientMessageToAll(0xffe5a1FF, String);
	}
	else if(Winners > 1)
	{
	    foreachPly (x) {
			if (Player[x][LottoNumber] == RandomInt)
			{
				GivePlayerMoney(x, LottoMoney/Winners);
				Money[x] += LottoMoney/Winners;
			}
		}
		format(String, sizeof(String), " * {eab171}Wylosowana liczba lotto to {ffe5a1}%d{eab171}. Liczba zwyciêzców którzy otrzymuj¹ po %d$: %d", RandomInt, LottoMoney/Winners, Winners);
		LottoMoney = 0;
	    SendClientMessageToAll(0xffe5a1FF, String);
	}

	SendClientMessageToAll(0xffe5a1FF, " * {eab171}Kolejne losowanie lotto ju¿ za 10 minut. Wpisz {ffe5a1}/lotto [1-46] {eab171}by wzi¹æ udzia³.");

	foreachPly (x) {
	    Player[x][LottoNumber] = 0;
	}
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	tVehicles[vehicleid][vo_paintjob] = paintjobid;
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	tVehicles[vehicleid][vo_color][0] = color1;
	tVehicles[vehicleid][vo_color][1] = color2;
	return 1;
}

forward WinSound(playerid);
public WinSound(playerid)
{
    PlayerPlaySound(playerid, 1185, 0, 0, 0);
	SetTimerEx("SoundOff",7000,0,"i",playerid);
	return 1;
}

forward LadowanieJetArena(playerid);
public LadowanieJetArena(playerid)
{
 	TogglePlayerControllable(playerid, 0);
	SetTimerEx("JetArenaLoadOff",3000,0,"i",playerid);
	return 1;
}

forward Tutor(playerid); //Start
public Tutor(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	TogglePlayerControllable(playerid,0);
	SetPlayerPos(playerid,2195.3462,-1596.8409,14.3516);
	SetPlayerCameraPos(playerid,2208.3191,-1623.3127,64.7033);
	SetPlayerCameraLookAt(playerid,2071.0593,-1443.1624,37.2109);
	TextDrawShowForPlayer(playerid,Tut[0]);
	SetTimerEx("Tutor1",7000,0,"i",playerid);
	return 1;
}

forward Tutor1(playerid); //Grecja
public Tutor1(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,573.2372,-7425.4888,32.4351);
	SetPlayerCameraPos(playerid,533.4780,-7503.1543,49.9161);
	SetPlayerCameraLookAt(playerid,573.2372,-7425.4888,32.4351);
	TextDrawHideForPlayer(playerid,Tut[0]);
	TextDrawShowForPlayer(playerid,Tut[1]);
	SetTimerEx("Tutor2",7000,0,"i",playerid);
	return 1;
}

forward Tutor2(playerid); //Party
public Tutor2(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,3915.5225,55.9640,25.4667);
	SetPlayerCameraPos(playerid,3867.5796,67.0181,40.1770);
	SetPlayerCameraLookAt(playerid,3915.5225,55.9640,25.4667);
	TextDrawHideForPlayer(playerid,Tut[1]);
	TextDrawShowForPlayer(playerid,Tut[2]);
	SetTimerEx("Tutor3",7000,0,"i",playerid);
	return 1;
}

forward Tutor3(playerid); //Statek
public Tutor3(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,2072.9946,1536.5538,-5.7514);
	SetPlayerCameraPos(playerid,2072.9946,1536.5538,36.7514);
	SetPlayerCameraLookAt(playerid,2002.6093,1543.1289,13.5859);
	TextDrawHideForPlayer(playerid,Tut[2]);
	TextDrawShowForPlayer(playerid,Tut[3]);
	SetTimerEx("Tutor4",7000,0,"i",playerid);
	return 1;
}

forward Tutor4(playerid); //Posiadlosci
public Tutor4(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,2634.0510,2290.8293,-5.5552);
	SetPlayerCameraPos(playerid,2634.0510,2290.8293,26.5552);
	SetPlayerCameraLookAt(playerid,2626.5522,2328.6133,10.6719);
	TextDrawHideForPlayer(playerid,Tut[3]);
	TextDrawShowForPlayer(playerid,Tut[4]);
	SetTimerEx("Tutor5",7000,0,"i",playerid);
	return 1;
}

forward Tutor5(playerid); //Tune
public Tutor5(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,2400.0579,999.2484,-5.7637);
	SetPlayerCameraPos(playerid,2400.0579,999.2484,28.7637);
	SetPlayerCameraLookAt(playerid,2384.9045,1038.7445,10.8203);
	TextDrawHideForPlayer(playerid,Tut[4]);
	TextDrawShowForPlayer(playerid,Tut[5]);
	SetTimerEx("Tutor6",7000,0,"i",playerid);
	return 1;
}

forward Tutor6(playerid); //Wojsko
public Tutor6(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,204.3113,1749.6913,-5.8474);
	SetPlayerCameraPos(playerid,204.3113,1749.6913,79.8474);
	SetPlayerCameraLookAt(playerid,319.5278,1933.2469,17.6406);
	TextDrawHideForPlayer(playerid,Tut[5]);
	TextDrawShowForPlayer(playerid,Tut[6]);
	SetTimerEx("Tutor7",7000,0,"i",playerid);
	return 1;
}

forward Tutor7(playerid); //Osiedle
public Tutor7(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,1257.1792,2601.7065,-5.2751);
	SetPlayerCameraPos(playerid,1257.1792,2601.7065,38.2751);
	SetPlayerCameraLookAt(playerid,1428.5012,2583.9221,11.6264);
	TextDrawHideForPlayer(playerid,Tut[6]);
	TextDrawShowForPlayer(playerid,Tut[7]);
	SetTimerEx("Tutor8",7000,0,"i",playerid);
	return 1;
}

forward Tutor8(playerid); //Jet Arena
public Tutor8(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,3315.2673,804.0073,39.8216);
	SetPlayerCameraPos(playerid,3241.4482,709.8154,17.0262);
	SetPlayerCameraLookAt(playerid,3315.2673,804.0073,39.8216);
	TextDrawHideForPlayer(playerid,Tut[7]);
	TextDrawShowForPlayer(playerid,Tut[8]);
	SetTimerEx("Tutor9",7000,0,"i",playerid);
	return 1;
}

forward Tutor9(playerid); //Arena
public Tutor9(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,731.3359,-262.1291,-5.2454);
	SetPlayerCameraPos(playerid,731.3359,-262.1291,61.2454);
	SetPlayerCameraLookAt(playerid,803.7893,-250.6236,18.8576);
	TextDrawHideForPlayer(playerid,Tut[8]);
	TextDrawShowForPlayer(playerid,Tut[9]);
	SetTimerEx("Tutor10",7000,0,"i",playerid);
	return 1;
}

forward Tutor10(playerid); //Forteca
public Tutor10(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,855.8929,-1445.0751,13.6078);
	SetPlayerCameraPos(playerid,821.7388,-1455.7183,31.9664);
	SetPlayerCameraLookAt(playerid,855.8929,-1445.0751,13.6078);
	TextDrawHideForPlayer(playerid,Tut[9]);
	TextDrawShowForPlayer(playerid,Tut[10]);
	SetTimerEx("Tutor11",7000,0,"i",playerid);
	return 1;
}

forward Tutor11(playerid); //Baza2
public Tutor11(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,2440.6387,1201.0798,-5.6308);
	SetPlayerCameraPos(playerid,2440.6387,1201.0798,63.6308);
	SetPlayerCameraLookAt(playerid,2387.6975,1131.8801,34.2529);
	TextDrawHideForPlayer(playerid,Tut[10]);
	TextDrawShowForPlayer(playerid,Tut[11]);
	SetTimerEx("Tutor12",7000,0,"i",playerid);
	return 1;
}

forward Tutor12(playerid); //Baza4
public Tutor12(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,1934.4976,1398.9083,-5.6376);
	SetPlayerCameraPos(playerid,1934.4976,1398.9083,68.6376);
	SetPlayerCameraLookAt(playerid,1865.6162,1316.2638,55.3731);
	TextDrawHideForPlayer(playerid,Tut[11]);
	TextDrawShowForPlayer(playerid,Tut[12]);
	SetTimerEx("Tutor13",7000,0,"i",playerid);
	return 1;
}

forward Tutor13(playerid); //Widok na LV
public Tutor13(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	SetPlayerPos(playerid,1939.3855,855.4321,-5.9870);
	SetPlayerCameraPos(playerid,1939.3855,855.4321,111.9870);
	SetPlayerCameraLookAt(playerid,2033.5056,1012.6932,58.6332);
	TextDrawHideForPlayer(playerid,Tut[12]);
	TextDrawShowForPlayer(playerid,Tut[13]);
	SetTimerEx("Tutor14",7000,0,"i",playerid);
	return 1;
}

forward Tutor14(playerid);
public Tutor14(playerid)
{
	if(!PlayerTut[playerid]) return 1;
	TextDrawHideForPlayer(playerid,Tut[13]);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid,1);
	SetPlayerRandomSpawn(playerid);
	PlayerTut[playerid] = false;
	return 1;
}

forward SekundaFunc();
public SekundaFunc()
{
	new str[64];
	foreachPly (x) {
	    if(GetPVarInt(x, "Skoczyl") == 1)
	    {
	        new Float:X, Float:Y, Float:Z, Float:AverageZ;
			GetPlayerPos(x, X, Y, Z);
			if((Z - AverageZ) < 5)
			{
			    format(str, sizeof str, "SKOCZYLES - %dm.", GetPlayerDistanceToPointEx(x, -1692.6345,-1895.6777,104.6306));
				SendClientMessage(x, 0xff0000ff, str);
	   			format(str, sizeof str, "%dm", GetPlayerDistanceToPointEx(x, -1692.6345,-1895.6777,104.6306));
		    	GameTextForPlayer(x, str, 1000, 3);
				SetPVarInt(x, "NaSkoczni", 0);
				SetPVarInt(x, "Skoczyl", 0);
			}
		}

		if(Player[x][WeaponPickupTime] > 0)
			{
			    Player[x][WeaponPickupTime]--;
			    if(Player[x][WeaponPickupTime] <= 0)
			        Player[x][WeaponPickup] = -1;
		}

		if(Player[x][LevelUpTime] > 0)
		{
 			Player[x][LevelUpTime]--;
			if(Player[x][LevelUpTime] < 1)
			{
		    	PlayerPlaySound(x, 1186, 0.0, 0.0, 0.0);
			}
		}

		if(IsVIP(x))
		{
			if(Player[x][VAnn] > 0)
	  		Player[x][VAnn]--;
		}
	}
	if(VipAnnTime > 0)
	{
	    VipAnnTime--;
	    if(VipAnnTime <= 0)
		{
		    TextDrawHideForAll(tdVipAnn[0]);
		    TextDrawHideForAll(tdVipAnn[1]);
			TextDrawHideForAll(VannBox);
		}
	}

	return 1;
}

forward GodzinaFunc();
public GodzinaFunc()
{
    DelPojazdy();   
	return 1;
}

forward Min10Func();
public Min10Func()
{
	new tmp[170],active,ogloszenie[160];
    mysql_query("SELECT `value`, `Active` FROM config WHERE `ID` = '5'");
    mysql_store_result();
	mysql_fetch_row(tmp);
	sscanf(tmp,"p<|>s[128]d",ogloszenie,active);
	if(active == 1){
		SendClientMessageToAll (-1, " ");
		SendClientMessageToAll(-1, "-- Og³oszenie --");
		MSGFA(0xE08725FF, "%s", ogloszenie);
		SendClientMessageToAll (-1, " ");
	}
	mysql_free_result();
		
	new Hour, Minute;
	gettime(Hour, Minute);
	
	Lotto();
	SetWorldTime(Hour);
	SetWeather(random(7));

	new string[128];
	foreachPly (x) {
		GetPlayerPos(x,ccccc_posX[x],ccccc_posY[x],ccccc_posZ[x]);
		if (ccccc_posX[x] == AfkPosX[x] && ccccc_posY[x] == AfkPosY[x] && ccccc_posZ[x] == AfkPosZ[x] && ccccc_posX[x] != 0.0 && ccccc_posY[x] != 0.0 && ccccc_posZ[x] != 0.0){
			SendClientMessage(x,COLOR_RED2,"Zosta³eœ(aœ) wyrzucony/a za zbyt d³ug¹ nieaktywnoœæ!");
			format(string, sizeof(string), " * Gracz %s zosta³ wyrzucony za zbyt d³ug¹ nieaktywnoœæ!",PlayerName(x));
			SendClientMessageToAll(COLOR_RED2,string);
			KickEx(x);
			kicks++;
		} else {
			GetPlayerPos(x,AfkPosX[x],AfkPosY[x],AfkPosZ[x]);
		}
		SetPlayerTime(x, Hour, Minute);
	}
	StatRefresh();
	return 1;
}

forward MinutaFunc();
public MinutaFunc()
{
	new year,mon,day;
	getdate(year,mon,day);

	new strinD[20];
	gettime(Hours, Minutes);
	format(strinD, sizeof(strinD), "%02d:%02d", Hours,Minutes);
	TextDrawSetString(Czas, strinD);
    format(strinD, 32, "worldtime %02d:%02d",Hours,Minutes);
	SendRconCommand(strinD);
	if(Hours == 23 && Minutes == 59)
	{	
        DomyCzynsz();
	}
    switch(random(2))
	{
		case 0:
		{
			MoveObject(lift1,948.794312, 2439.689941, 42.391544,6);
            MoveObject(lift2,957.270447, 2432.764160, 81.292969,6);
            MoveObject(lift3,956.364319, 2442.081299, 198.766342,6);
		}
		case 1:
		{
			MoveObject(lift1,948.788574, 2439.683350, 9.874555,6);
            MoveObject(lift2,957.282593, 2432.806641, 42.432281,6);
            MoveObject(lift3,957.160950, 2442.099365, 81.161102,6);
		}
	}

	return 1;
}

forward DwieMinutyFunc();
public DwieMinutyFunc()
{
    if(LastInfo >= sizeof(Infos)) LastInfo = 0;
 	SendClientMessageToAll(0xac3e00FF, Infos[LastInfo]);

    LastInfo++;

	switch(random(6))
	{
		case 0:
		{
            SetWeather(10);
		}
		case 1:
		{
			SetWeather(11);
		}
        case 2:
		{
            SetWeather(10);
		}
		case 3:
		{
			SetWeather(1);
		}
        case 4:
		{
            SetWeather(4);
		}
		case 5:
		{
			SetWeather(2);
		}
	}
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid) {
	
	new drzwi, bool:cel;
	drzwi = vehicleDoorState[vehicleid];
	
	if((forplayerid == vehicleDoorOwner[vehicleid]) || (tVehicles[vehicleid][vo_private] && tVehicles[vehicleid][vo_owningPlayerId]==forplayerid))
	{
		drzwi = 0;
	}
	
	if(IsPlayerInAnyVehicle(forplayerid))
	{
		new vid = GetPlayerVehicleID(forplayerid);
		if (vid!=vehicleid && GetVehicleModel(vid)==525 && !IsTrailerAttachedToVehicle(vid))	// towtruck
			if ((!tVehicles[vehicleid][vo_occupied] && tVehicles[vehicleid][vo_used] && !tVehicles[vehicleid][vo_private]) ||
				(tVehicles[vehicleid][vo_static] && !tVehicles[vehicleid][vo_used] && !tVehicles[vehicleid][vo_occupied] && 
				 random(10)==1))
				cel=true;	
	}

	SetVehicleParamsForPlayer(vehicleid, forplayerid, cel, drzwi);
    return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	tVehicles[vehicleid][vo_used]=false;
	tVehicles[vehicleid][vo_occupied]=false;
	tVehicles[vehicleid][vo_driver]=INVALID_PLAYER_ID;


	if(tVehicles[vehicleid][vo_private]) {
		if (tVehicles[vehicleid][vo_owningPlayerId]!=INVALID_PLAYER_ID) {
			SendClientMessage(tVehicles[vehicleid][vo_owningPlayerId],COLOR_INFO,"Twoj pojazd wrocil na miejsce spawnu.");
			return pv_SpawnVehicle(tVehicles[vehicleid][vo_owningPlayerId]);
		} else {
			tVehicles[vehicleid][vo_private]=false;
			tVehicles[vehicleid][vo_pvid]=-1;
			pvData[tVehicles[vehicleid][vo_pvid]][pv_vid] = INVALID_VEHICLE_ID;
		}
		return 1;
	}

	vehicleDoorState[vehicleid] = 0;
	vehicleDoorOwner[vehicleid] = INVALID_PLAYER_ID;
	tVehicles[vehicleid][vo_licensePlateSet]=false;
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	tVehicles[vehicleid][vo_used]=false;
	tVehicleUsed[vehicleid]=false;
	tVehicles[vehicleid][vo_occupied]=false;
	tVehicles[vehicleid][vo_driver]=INVALID_PLAYER_ID;

	if(tVehicles[vehicleid][vo_private]) {
			if (tVehicles[vehicleid][vo_owningPlayerId]!=INVALID_PLAYER_ID) {
				SendClientMessage(tVehicles[vehicleid][vo_owningPlayerId],COLOR_INFO,"Twoj pojazd wrocil na miejsce spawnu.");
				// w tej funkcji nastapi zniszczenie aktualnego pojazdu i zespawnowanie go pod domem gracza
				pv_SpawnVehicle(tVehicles[vehicleid][vo_owningPlayerId]);
			} else {	// wlasciciel sie rozlaczyl a pojazd ulegl respawnowi
				tVehicles[vehicleid][vo_private]=false;
				tVehicles[vehicleid][vo_pvid]=-1;
				pvData[tVehicles[vehicleid][vo_pvid]][pv_vid] = INVALID_VEHICLE_ID;
				DestroyVehicle(vehicleid);
			}
			return 1;
	}
	if(vehicleid > staticVehicleCount) tVehicleSpawned[vehicleid]=true;

	new vmodel=GetVehicleModel(vehicleid); 
	tVehicles[vehicleid][vo_paintjob]=0;

	if (tVehicles[vehicleid][vo_static]) 
	{
		vehicleDoorState[vehicleid] = 0;
		SetVehicleParamsEx(vehicleid, 1, 1, random(2), 0, 0, 0, 0);
		switch(vmodel){
			case 400,401,404,405,410,415,418,420,421,422,426,436,439,477,478,489,491,492,496,500,505,516,517,518,527,529,534,
				535,536,540,542,546,547,549,550,551,558,559,560,561,562,565,567,575,576,580,585,589,600,603: {
				if (random(3)==1)
					TuneCar(vehicleid);
				if (random(3)==1) {
					tVehicles[vehicleid][vo_paintjob]=random(3);
					ChangeVehiclePaintjob(vehicleid, tVehicles[vehicleid][vo_paintjob]);
				}
			}			
		}
	}

	return 1;
}

forward ShowPlayerPasek(playerid);
public ShowPlayerPasek(playerid)
{
	TextDrawShowForPlayer(playerid, playerHudBoxMain);
      
	TextDrawShowForPlayer(playerid, playerHudLabele[0]);
	TextDrawShowForPlayer(playerid, playerHudLabele[1]);
	TextDrawShowForPlayer(playerid, playerHudLabele[2]);
	TextDrawShowForPlayer(playerid, playerHudLabele[3]);
		   
	TextDrawShowForPlayer(playerid, playerHudPaski[0]);
	TextDrawShowForPlayer(playerid, playerHudPaski[1]);
	TextDrawShowForPlayer(playerid, playerHudPaski[2]);
	TextDrawShowForPlayer(playerid, playerHudPaski[3]);
	TextDrawShowForPlayer(playerid, playerHudPaski[4]);
	TextDrawShowForPlayer(playerid, playerHudPaski[5]);
		
	PlayerTextDrawShow(playerid, playerTd_exp[playerid]);
	PlayerTextDrawShow(playerid, playerTd_level[playerid]);
	PlayerTextDrawShow(playerid, playerTd_timeplay[playerid]);
	PlayerTextDrawShow(playerid, playerTd_portfel[playerid]);

	return 1;
}

forward HidePlayerPasek(playerid);
public HidePlayerPasek(playerid) 
{
	TextDrawHideForPlayer(playerid, playerHudBoxMain);
      
	TextDrawHideForPlayer(playerid, playerHudLabele[0]);
	TextDrawHideForPlayer(playerid, playerHudLabele[1]);
	TextDrawHideForPlayer(playerid, playerHudLabele[2]);
	TextDrawHideForPlayer(playerid, playerHudLabele[3]);
		   
	TextDrawHideForPlayer(playerid, playerHudPaski[0]);
	TextDrawHideForPlayer(playerid, playerHudPaski[1]);
	TextDrawHideForPlayer(playerid, playerHudPaski[2]);
	TextDrawHideForPlayer(playerid, playerHudPaski[3]);
	TextDrawHideForPlayer(playerid, playerHudPaski[4]);
	TextDrawHideForPlayer(playerid, playerHudPaski[5]);
		
	PlayerTextDrawHide(playerid, playerTd_exp[playerid]);
	PlayerTextDrawHide(playerid, playerTd_level[playerid]);
	PlayerTextDrawHide(playerid, playerTd_timeplay[playerid]);
	PlayerTextDrawHide(playerid, playerTd_portfel[playerid]);
	
	return 1;
}

forward RaportUnlock(playerid);
public RaportUnlock(playerid)
{
	RaportBlock[playerid] = false;
	return 1;
}

forward IdzdoUnlock(PlayerId);
public IdzdoUnlock(PlayerId)
{
	IdzdoBlock[PlayerId] = false;
	return 1;
}

forward VannUnlock(PlayerId);
public VannUnlock(PlayerId)
{
	VannBlock[PlayerId] = false;
	return 1;
}

forward SetPlayerRandomKask(playerid);
public SetPlayerRandomKask(playerid)
{
	switch(random(4))
	{
		case 0: SetPlayerAttachedObject(playerid,1,18976,2,0.05,0.01,0.00,3.0,82.0,87.0,1.00,1.00,1.00);
		case 1: SetPlayerAttachedObject(playerid,1,18977,2,0.05,0.01,0.00,3.0,82.0,87.0,1.00,1.00,1.00);
        case 2: SetPlayerAttachedObject(playerid,1,18978,2,0.05,0.01,0.00,3.0,82.0,87.0,1.00,1.00,1.00);
		case 3: SetPlayerAttachedObject(playerid,1,18979,2,0.05,0.01,0.00,3.0,82.0,87.0,1.00,1.00,1.00);
	}
	return 1;
}


PlayerSpeedometer(playerid, option=1)
{
	if(!CarInfoChce[playerid]) return;
	if(option)
	{
		PlayerTextDrawSetString(playerid, playerTd_carname[playerid], "_");
		PlayerTextDrawSetString(playerid, playerTd_carspeed[playerid], "_");
		PlayerTextDrawSetString(playerid, playerTd_carhealth[playerid], "_");
		
		new string[52];
		format(string, sizeof(string), "~r~~h~~h~~h~%s", CarList[GetVehicleModel(GetPlayerVehicleID(playerid))-400]);
		
		PlayerTextDrawSetString(playerid, playerTd_carname[playerid], string);
	    
		PlayerTextDrawShow(playerid, playerTd_carname[playerid]);
		PlayerTextDrawShow(playerid, playerTd_carspeed[playerid]);
		PlayerTextDrawShow(playerid, playerTd_carhealth[playerid]);
		TextDrawShowForPlayer(playerid, car_box);
	} else {
		PlayerTextDrawHide(playerid, playerTd_carname[playerid]);
		PlayerTextDrawHide(playerid, playerTd_carspeed[playerid]);
		PlayerTextDrawHide(playerid, playerTd_carhealth[playerid]);
		TextDrawHideForPlayer(playerid, car_box);
	}
}

public OnPlayerStateChange(playerid, newstate, oldstate) 
{	
	if((newstate == 2 && oldstate == 1) || (newstate == 3 && oldstate == 1))
	{
		gPlayerLastVID[playerid] = GetPlayerVehicleID(playerid);
		if(newstate == PLAYER_STATE_DRIVER)
		{	
			if (tVehicles[gPlayerLastVID[playerid]][vo_private] && 
				tVehicles[gPlayerLastVID[playerid]][vo_owningPlayerId] != INVALID_PLAYER_ID && 
				tVehicles[gPlayerLastVID[playerid]][vo_owningPlayerId] != playerid) 
			{
					RemovePlayerFromVehicle(playerid);
					return 0;
			}
			if(tVehicles[gPlayerLastVID[playerid]][vo_private])
			{
				SCM(playerid, COLOR_YELLOW, "Wszedles do swojego prywatnego pojazdu.");
				GetVehiclePos(GetPlayerVehicleID(playerid), pvData[gpVehicleid[playerid]][pv_dist][0], pvData[gpVehicleid[playerid]][pv_dist][1], pvData[gpVehicleid[playerid]][pv_dist][2]);
				SetPVarInt(playerid, "pv_timer", SetTimerEx("privVehicles_refresh", 1000, true, "d", playerid));
			}
			PlayerSpeedometer(playerid, 1);
			tVehicles[gPlayerLastVID[playerid]][vo_driver] = playerid;
		} else if(newstate == PLAYER_STATE_PASSENGER)
		{
			PlayerSpeedometer(playerid, 1);
		}
		
		foreachPly(x) {
			if(gSpectateID[x] == playerid && GetPlayerState(x) == PLAYER_STATE_SPECTATING){
				PlayerSpectateVehicle(x, GetPlayerVehicleID(playerid));
			}
		}
	}
	
	if((newstate != PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) && (oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER))
	{
		if(GetPVarInt(playerid, "pv_timer")>0) KillTimer(GetPVarInt(playerid, "pv_timer"));
		PlayerSpeedometer(playerid, 0);
	}
	
	if((newstate == 1 && oldstate == 2) || (newstate == 1 && oldstate == 3))
	{
		if(oldstate == PLAYER_STATE_DRIVER) {
			tVehicles[gPlayerLastVID[playerid]][vo_driver] = INVALID_PLAYER_ID;
		}
		PlayerSpeedometer(playerid, 0);
		foreachPly(x) {
			if(gSpectateID[x] == playerid && GetPlayerState(x) == PLAYER_STATE_SPECTATING){
				PlayerSpectatePlayer(x, playerid);
			}
		}
	}
	return 1;
}

forward MpozostaloUnlock(playerid);
public MpozostaloUnlock(playerid)
{
	MpozostaloBlock[playerid] = false;
	return 1;
}

forward AutoUnlock(playerid);
public AutoUnlock(playerid)
{
	AutoBlock[playerid] = false;
	return 1;
}

forward Top10Unlock(id);
public Top10Unlock(id)
{
	Top10Block[id] = false;
	return 1;
}


forward Odliczanka();
public Odliczanka() {

	if(!VoteON) return 1;

	new string[160];
	VotePozostalo --;
	format(string, sizeof(string), "%s %s ~n~~y~%2d       ~w~/TAK   ~g~%d   ~w~/NIE   ~r~%d", VoteQuest, (strlen (VoteQuest)>=35)? ("~n~"): (""), VotePozostalo, LiczbaTak, LiczbaNie);
	TextDrawSetString(Glosowanie,string);

	// "%s %s~n~~y~%d       ~w~/TAK   ~g~%d   ~w~/NIE   ~r~%d"
	// "%s %s ~n~~y~TAK!    ~w~Glosow: 30"
	if(VotePozostalo <= 0){
		if(LiczbaTak > LiczbaNie){
			format(string, sizeof(string), "%s ~n~ ~n~~y~TAK!    ~w~Glosow: %d", VoteQuest, LiczbaTak);
		}
		else if(LiczbaTak < LiczbaNie){
			format(string, sizeof(string), "%s ~n~ ~n~~y~NIE!    ~w~Glosow: %d", VoteQuest, LiczbaNie);
		}
		else if(LiczbaTak == LiczbaNie){
			format(string, sizeof(string), "%s ~n~ ~n~~y~REMIS!", VoteQuest);
		}

		TextDrawSetString(Glosowanie,string);
		SetTimer("VoteWylacz",6000,0);
	}else{
		SetTimer("Odliczanka",1000,0);
	}

	return 1;
}

forward PlayerLabelOff(playerid);
public PlayerLabelOff(playerid)
{
    if(pAttraction[playerid] == 1 && GetPVarInt(playerid, "pZapisanyCH") == 1)
	{
	    Update3DTextLabelText(PlayerLabel[playerid],0x0," ");
	}
	else if(PlayerGangInfo[playerid][gID] != -1)
	{
	    new id = PlayerGangInfo[playerid][gID];
	    new color = GangInfo[id][gColor];
	    Update3DTextLabelText(PlayerLabel[playerid],color,GangInfo[id][gName]);
		KillTimer(TrzyDeTimer[playerid]);
		return 1;
	}
	else
	{
		TrzyDeTimer[playerid] = SetTimerEx("Update3DExp", 7000, true, "d", playerid); //7 Sekund
	}
	return 1;
}

forward Update3DExp(playerid);
public Update3DExp(playerid)
{
    new buffer[128];
	if(IsVIP(playerid))
	{
     	format(buffer, sizeof(buffer), "PREMIUM\n\n{BEBEBE}Exp: %d\nLevel: %d", Respekt[playerid], Player[playerid][Level]);

		Update3DTextLabelText(PlayerLabel[playerid],0xFFE500FF, buffer);
		return 1;
	}

	format(buffer, sizeof(buffer), "{BEBEBE}Exp: %d {ffffff}| {BEBEBE}Level: %d", Respekt[playerid], Player[playerid][Level]);
    Update3DTextLabelText(PlayerLabel[playerid],0xBEBEBEFF,buffer);
	return 1;
}

forward JailPlayer(playerid,reason[],time);
public JailPlayer(playerid,reason[],time)
{
	new string[256];
	time = time*60000;
	Wiezien[playerid] = true;
	if(!JailText[playerid]){
		format(string, sizeof(string), "Trafi³eœ(aœ) do wiêzienia na %d minut za: %s",time/60000,reason);
		SendClientMessage(playerid,COLOR_RED2, string);
		JailText[playerid] = true;
		SetTimerEx("JailTextUnlock",5000,0,"i",playerid);
	}

	new rand = random(sizeof(CelaSpawn));
	PlayerTeleport(playerid,0,CelaSpawn[rand][0], CelaSpawn[rand][1], CelaSpawn[rand][2]);

	TogglePlayerControllable(playerid,0);
	SetPlayerVirtualWorld(playerid,10);
	//ResetPlayerWeapons(playerid);
	//SetTimerEx("JailUnfreeze",2000,0,"i",playerid);
	KillTimer(JailTimer[playerid]);
	JailTimer[playerid] = SetTimerEx("UnjailPlayer",time,0,"i",playerid);

	format(string,sizeof(string),"1. Zakaz u¿ywania cheatów/spamerów/trainerow etc.\n2. Zakaz podszywania siê pod graczy/administracjê.\n3. Nie zabijaj w strefie 'Bez DM'\n4. Bronie specjalne u¿ywaj tylko w 'Strefie Œmierci'\n5. Nie dokuczaj innym graczom.\n6. Nie buguj serwera!");
	ShowPlayerDialog(playerid,22,0,"Regulamin Serwera",string,"OK","OK");

	return 1;
}

forward DomKoniecOgladania(playerid,x);
public DomKoniecOgladania(playerid,x)
{

	SetPlayerInterior(playerid,0);
	SetPlayerVirtualWorld(playerid,0);
	SetPlayerPos(playerid,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
	SendClientMessage(playerid,COLOR_RED2,"Min¹³ czas na ogl¹danie domu!");

	return 1;
}

forward SoloEnd(loser);
public SoloEnd(loser)
{
	new x1 = SoloPlayer[0];
	new x2 = SoloPlayer[1];

	if(x1 != loser){
		SetPlayerPos(x1,1966.0569,-2497.5547,43.5088);
		ResetPlayerWeapons(x1);
		SoloScore[x1] ++;
		SoloScore[x2] --;
	}
	if(x2 != loser){
		SetPlayerPos(x2,1966.0569,-2497.5547,43.5088);
		ResetPlayerWeapons(x2);
		SoloScore[x2] ++;
		SoloScore[x1] --;
	}

	SoloON = false;
	SoloPlayer[0] = -1;
	SoloPlayer[1] = -1;


	foreachPly (x) {
		SoloWyzywa[x] = -1;
		SoloBron[x] = 0;
	}

	return 1;
}

forward StartSolo(gracz1,gracz2,bron);
public StartSolo(gracz1,gracz2,bron)
{
	SoloON = true;

	SetPlayerPos(gracz1,1915.9880,-2475.7432,43.5088);
	SetPlayerPos(gracz2,1958.9172,-2520.1323,43.5088);

	SetPlayerFacingAngle(gracz1,205.00);
	SetPlayerFacingAngle(gracz2,70.00);

	SetCameraBehindPlayer(gracz1);
	SetCameraBehindPlayer(gracz2);

	TogglePlayerControllable(gracz1,0);
	TogglePlayerControllable(gracz2,0);

	ResetPlayerWeapons(gracz1);
	ResetPlayerWeapons(gracz2);

	GivePlayerWeapon(gracz1, bron, 3000);
	GivePlayerWeapon(gracz2, bron, 3000);

	SetPlayerHealth(gracz1,100);
	SetPlayerHealth(gracz2,100);

	SetPlayerArmour(gracz1,0);
	SetPlayerArmour(gracz2,0);

	SoloPlayer[0] = gracz1;
	SoloPlayer[1] = gracz2;
	new string[100];
	format(string, sizeof(string), "Solo Rozpoczête: %s vs %s  Broñ: %s", PlayerName(gracz1), PlayerName(gracz2),ReturnWeaponName(bron));

	foreachPly (x) {
		if(PlayerToPoint(100,x,1963.0099,-2503.1980,43.5088))
		{
			SendClientMessage(x,COLOR_ORANGE,string);
		}
	}

	Solocd();

	return 1;
}

forward Solocd();
public Solocd()
{
	if (SoloCD > 0)
	{

		GameTextForPlayer(SoloPlayer[0],CountText[SoloCD-1], 2500, 3);
		GameTextForPlayer(SoloPlayer[1],CountText[SoloCD-1], 2500, 3);
		PlayerPlaySound(SoloPlayer[0],1056,0,0,0);
		PlayerPlaySound(SoloPlayer[1],1056,0,0,0);

		SoloCD--;
		SetTimer("Solocd", 1000, 0);
	}
	else
	{

		GameTextForPlayer(SoloPlayer[0],"~r~Walcz !!!", 2500, 3);
		GameTextForPlayer(SoloPlayer[1],"~r~Walcz !!!", 2500, 3);
		PlayerPlaySound(SoloPlayer[0],1057,0,0,0);
		PlayerPlaySound(SoloPlayer[1],1057,0,0,0);
		TogglePlayerControllable(SoloPlayer[0],1);
		TogglePlayerControllable(SoloPlayer[1],1);

		SoloCD = 3;
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	printf("[RCON-LOGGING] Successfully logged (IP: %s, RCONPASS: %s", ip, password);
	if(!success)
	{
		printf("[RCON-LOGGING] Unsuccessfully IP: %s Pass: %s",ip, password);
		SendRconCommand("rcon_password !@#$%^&*()_+");
		SetTimer("RconOff", 5000, true);
	}
	return 1;
}

forward AnnForPlayer(playerid,time,string[]);
public AnnForPlayer(playerid,time,string[])
{
	PlayerTextDrawShow(playerid,AnnTD[playerid]);
	PlayerTextDrawSetString(playerid, AnnTD[playerid],string);
	KillTimer(AnnTimer[playerid]);
	AnnTimer[playerid] = SetTimerEx("AnnTDoff",time,0,"i",playerid);

	return 1;
}

forward AnnTDoff(playerid);
public AnnTDoff(playerid)
{

	PlayerTextDrawHide(playerid,AnnTD[playerid]);
	PlayerTextDrawSetString(playerid, AnnTD[playerid],"_");

	return 1;
}

forward StuntVeh(playerid);
public StuntVeh(playerid)
{
	if(!IsVehicleInUse(TPcar[playerid])) DestroyVehicle(TPcar[playerid]);
	TPcar[playerid] = CreateVehicle(522 ,1067.0068,1319.8843,247.3987,0,405,405, 9999);
	PutPlayerInVehicle(playerid,TPcar[playerid],0);
	return 1;
}

forward ZjazdVeh(playerid);
public ZjazdVeh(playerid)
{
	if(!IsVehicleInUse(TPcar[playerid])) DestroyVehicle(TPcar[playerid]);
	TPcar[playerid] = CreateVehicle(411 ,-507.5543,3233.2744,605.2291,240.8887,405,405, 9999);
	PutPlayerInVehicle(playerid,TPcar[playerid],0);
	return 1;
}

forward Zjazd2Veh(playerid);
public Zjazd2Veh(playerid)
{
	if(!IsVehicleInUse(TPcar[playerid])) DestroyVehicle(TPcar[playerid]);
	TPcar[playerid] = CreateVehicle(411 ,775.5983, 2493.1392, 489.5291,90.3379,405,405, 9999);
	PutPlayerInVehicle(playerid,TPcar[playerid],0);
	return 1;
}

forward CarTeleport(playerid,interior,Float:x,Float:y,Float:z);
public CarTeleport(playerid,interior,Float:x,Float:y,Float:z)
{

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new VehicleID = GetPlayerVehicleID(playerid);
		SetVehiclePos(VehicleID, x,y,z);
		SetPlayerInterior(playerid,interior);
		LinkVehicleToInterior(VehicleID,interior);
		SetVehicleVirtualWorld(VehicleID,0);
	} else {
		SetPlayerPos(playerid, x,y,z);
		SetPlayerVirtualWorld(playerid,0);
		SetPlayerInterior(playerid,interior);
	}
	//TogglePlayerControllable(playerid,0);
	//SetTimerEx("JailUnfreeze",2000,0,"i",playerid);

	return 1;
}

forward PlayerTeleport(playerid, interior, Float:x, Float:y, Float:z);
public PlayerTeleport(playerid, interior, Float:x, Float:y, Float:z)
{
	SetPlayerPos(playerid, x, y, z);
	SetPlayerInterior(playerid, interior);
	SetPlayerVirtualWorld(playerid, 0);
	
	SetTimerEx("checkTeleportZ", 450, 0, "df", playerid, z);
	return 1;
}

forward checkTeleportZ(playerid, Float:z);
public checkTeleportZ(playerid, Float:z)
{
	new Float:PP[3];
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehiclePos(GetPlayerVehicleID(playerid), PP[0], PP[1], PP[2]);
		if(PP[2]-z<2)
		{
			SetVehiclePos(GetPlayerVehicleID(playerid), PP[0], PP[1], z);
		}
	} else {
		GetPlayerPos(playerid, PP[0], PP[1], PP[2]);
		if(PP[2]-z<1)
		{
			SetPlayerPos(playerid, PP[0], PP[1], z);
		}
	}
	return 1;
}

forward GivePlayerCar(playerid, modelid);
public GivePlayerCar(playerid, modelid)
{

	if(GetPlayerInterior(playerid) != 0)
	{
		SendClientMessage(playerid,COLOR_RED2," * Pojazdy mo¿na kupowaæ tylko na dworze!");
		return 1;
	}

	if(ZmieniaAuto[playerid]){

		if(AutoBlock[playerid]){
			SendClientMessage(playerid,COLOR_RED2," * Mo¿esz zmieniaæ auto raz na 2 min!");
			return 1;
		}

		AutoBlock[playerid] = true;
		SetTimerEx("AutoUnlock",120000,0,"i",playerid);

		new x=HouseID[playerid];

		new tmp[128];

        tmp = house_Get(x,6);
		new Float:xxx, Float:yyy, Float:zzz, Float:ang;
		sscanf (tmp, "p<,>ffff", xxx, yyy, zzz, ang);

		DestroyVehicle(HouseInfo[x][hCarid]);
		
		new caridstr[5];
		valstr(caridstr,modelid);
		house_Update(x,5,caridstr);

		SendClientMessage(playerid,COLOR_GREEN," * Zmieni³eœ(aœ) sobie pojazd domowy!");

		HouseInfo[x][hCarid] = CreateVehicle(modelid,xxx,yyy,zzz,ang,-1,-1, 999999);

		return 1;
	}

	SendClientMessage(playerid, COLOR_GREEN, " * Pojazd zosta³ zespawnowany!");

	new Float:PP[4], vehid;
	
	GetPlayerPos(playerid, PP[0], PP[1], PP[2]);
	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleZAngle(GetPlayerVehicleID(playerid), PP[3]);
	} else {
		GetPlayerFacingAngle(playerid, PP[3]);
	}
	
	if(GetPlayerVehicleSeat(playerid) == 0)
	{
		vehid = GetPlayerVehicleID(playerid);
		RemovePlayerFromVehicle(playerid);
		RespawnVehicle(vehid);
	}
	
	vehid = CreateVehicle(modelid, PP[0], PP[1], PP[2], PP[3], -1, -1, 600);
	PutPlayerInVehicle(playerid, vehid, 0);
	tVehicleSpawned[vehid] = true;
	
	SetVehicleParamsForPlayer(vehid, playerid, 0, 0);
	vehicleDoorState[vehid] = 0;
	vehicleDoorOwner[vehid] = playerid;
	return 1;
}

forward RconOff(playerid);
public RconOff(playerid)
{
	SendRconCommand("rcon_password PASSFGSERV@2k13_RCON");
    SetTimer("RconOff",5000,false);
	return 1;
}

public OnPlayerUpdate(playerid) 
{
	
	if(IsPlayerInBezDmZone(playerid)) 
	{
		SetPlayerArmedWeapon(playerid, 0);
	}
	
	static pstate = 0;
	
	if (GetTickCount()%3 == 0) return 1;
	
	pstate = GetPlayerState (playerid);
	if (pstate == PLAYER_STATE_DRIVER || pstate == PLAYER_STATE_PASSENGER)
	{
		CarUpdate (playerid);
	}
	return 1;
}

forward SoundOff(playerid);
public SoundOff(playerid)
{
	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	return 1;
}

forward loadoff(playerid);
public loadoff(playerid)
{
    TogglePlayerControllable(playerid, 1);
	return 1;
}

forward JetArenaLoadOff(playerid);
public JetArenaLoadOff(playerid)
{
    TogglePlayerControllable(playerid, 1);
	SetPlayerSpecialAction(playerid, 2);
	return 1;
}

SendPlayerRequestToTeleport(playerid, playertp) {

	SetPVarInt (playerid, #teleport.tpto, playertp);

	if(Player[playertp][RconAkcja] == 1) {
    	SendClientMessage(playerid, COLOR_GREEN, " * W tej chwili nie mo¿na teleportowaæ siê do tego gracza.");
		return 1;
	}

	if (pAttraction[playertp]) return SCM(playerid, COLOR_GREEN, " * Gracz jest na atrakcji.");
	if (pData[playertp][chainsawn] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (pData[playertp][de] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (pData[playertp][sniper] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (pData[playertp][minigun] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (Wiezien[playertp]) return SCM(playerid, COLOR_GREEN, " * Gracz jest na wiêzieniu!");

	new String[128];
	
	format(String, sizeof(String), "Gracz %s (%d) chce siê do ciebie teleportowaæ\nWyra¿asz na to zgodê?", PlayerName(playerid), playerid);
	ShowPlayerDialog (playertp, DIALOG_TP, DIALOG_STYLE_MSGBOX, "Teleport", String, "Akceptuj", "Odrzuæ");
	SendClientMessage(playerid, COLOR_GREEN, "  * Zaproszenie zosta³o wys³ane.");
	
	IdzdoBlock[playerid] = true;
	SetTimerEx("IdzdoUnlock", 15000, 0, "i", playerid);
	Player[playerid][ClickedPlayer] = -1;
	
	return 1;
}


forward UnPanorama(playerid);
public UnPanorama(playerid)
{
	TextDrawHideForPlayer(playerid,Panorama[0]);
	TextDrawHideForPlayer(playerid,Panorama[1]);
  
	TextDrawHideForPlayer(playerid,TextDrawLogoGra1);
	TextDrawHideForPlayer(playerid,TextDrawLogoGra2);
	TextDrawHideForPlayer(playerid,TextDrawLogoGra3);

	return 1;
}


forward Spam();
public Spam()
{
	foreachPly (i) {
		if(SpamStrings[i] > 0) {
			SpamStrings[i] --;
		}
		if(SpamStrings[i] > 2){
			SpamStrings[i] = 2;
		}
		if(CMDspam[i] > 0) {
			CMDspam[i] --;
		}
		if(CMDspam[i] > 3){
			CMDspam[i] = 3;
		}
	}
	return 1;
}

forward SERVER_OFF();
public SERVER_OFF(){
	SendRconCommand("exit");
	return 1;
}



forward UnmutePlayer(playerid);
public UnmutePlayer(playerid)
{
	playermuted[playerid] = false;
	KillTimer(MuteTimer[playerid]);
	SendClientMessage(playerid,COLOR_GREEN," * Zosta³eœ(aœ) odciszony/a!");
	return 1;
}


forward UnjailPlayer(playerid);
public UnjailPlayer(playerid)
{
	Wiezien[playerid] = false;
	KillTimer(JailTimer[playerid]);
	SetPlayerRandomSpawn(playerid);
	SendClientMessage(playerid,COLOR_GREEN,"Odby³eœ(aœ) swoj¹ karê i mo¿esz ju¿ graæ");
	return 1;
}

forward PMOff(gracz);
public PMOff(gracz)
{
	TextDrawHideForPlayer(gracz,PM1);
	KillTimer(PMTimer[gracz]);
	return 1;
}

forward DragTeleport(playerid);
public DragTeleport(playerid)
{
	new vehid;
	vehid = GetPlayerVehicleID(playerid);
	SetVehicleVirtualWorld(vehid,0);
	SetVehicleToRespawn(vehid);
	SetPlayerVirtualWorld(playerid,0);
	PlayerTeleport(playerid,0,623.1945,-1391.3428,13.0539);
	return 1;
}

forward Float:GetDistanceBetweenPoints3D(Float:vX1, Float:vY1, Float:vZ1, Float:vX2, Float:vY2, Float:vZ2);
stock Float:GetDistanceBetweenPoints3D(Float:vX1, Float:vY1, Float:vZ1, Float:vX2, Float:vY2, Float:vZ2) {
	return floatsqroot(floatpower(floatabs(floatsub(vX1, vX2)), 2) + floatpower(floatabs(floatsub(vY1, vY2)), 2) + floatpower(floatabs(floatsub(vZ1, vZ2)), 2));
}

forward CDTextUnlock();
public CDTextUnlock()
{
	CDText = false;
	return 1;
}

forward JailTextUnlock(playerid);
public JailTextUnlock(playerid)
{
	JailText[playerid] = false;
	return 1;
}
/*
forward ArenaTextUnlock();
public ArenaTextUnlock()
{
	ArenaText = false;
	return 1;
}

forward RPGTextUnlock();
public RPGTextUnlock()
{
	RPGText = false;
	return 1;
}



forward JetArenaTextUnlock();
public JetArenaTextUnlock()
{
	JetArenaText = false;
	return 1;
}
*/
forward PlayerUpdate();
public PlayerUpdate()
{

	//OnlPlS = 0;
	OnlAD = 0;
    OnlMOD = 0;
	OnlVIP = 0;
	new xx = sizeof(Abronie);

	foreachPly (x) 
	{
		ResetPlayerMoney(x);
		GivePlayerMoney(x, Money[x]);

		if(Wiezien[x])
		{
			if(!PlayerToPoint(100, x, -1850.0167+random(4-1), 1014.3398+random(4-1), 48.8845))
			{
				new rand = random(sizeof(CelaSpawn));
				SetPlayerPos(x, CelaSpawn[rand][0], CelaSpawn[rand][1], CelaSpawn[rand][2]);
				SetPlayerInterior(x,0);
				SendClientMessage(x,COLOR_RED2," * Jesteœ w wiêzieniu i nie mo¿esz z niego uciec.");
				ResetPlayerWeapons(x);
			}
		}

		new bool:IsInFreeZone;
		if(GetPlayerInterior(x) == 0)
		{
			if(!IsPlayerInFreeZone(x))
			{
				TextDrawHideForPlayer(x,FreeZone);
			}else{
				TextDrawShowForPlayer(x,FreeZone);
				IsInFreeZone = true;
			}
		}

		if(GetPlayerInterior(x) == 0)
		{
			if(IsPlayerInBezDmZone(x))
			{
				TextDrawShowForPlayer(x,BezDmZone);
			}else{
				TextDrawHideForPlayer(x,BezDmZone);
			}
		}
	    if(IsAdmin(x, 2))
		{
	    	OnlAD ++;
	    }
        
		if(Player[x][Admin] == 1)
		{
			OnlMOD ++;
		}
		
		if(IsVIP(x))
		{
			OnlVIP ++;
		}

		if(IsAdmin(x, 2)) continue;
		if(Immunitet[x]) continue;
		
		if(GetPlayerPing(x) > 400)
		{
			switch(Pinger[x]++)
			{
				case 1: SendClientMessage(x,COLOR_RED2,"Uwaga! Przekraczasz maksymalny dopuszczalny ping 400ms (1/5)");
				case 2: SendClientMessage(x,COLOR_RED2,"Uwaga! Przekraczasz maksymalny dopuszczalny ping 400ms (2/5)");
				case 3: SendClientMessage(x,COLOR_RED2,"Uwaga! Przekraczasz maksymalny dopuszczalny ping 400ms (3/5)");
				case 4: SendClientMessage(x,COLOR_RED2,"Uwaga! Przekraczasz maksymalny dopuszczalny ping 400ms (4/5)");
				case 5: 
				{
					new buf[127];
					format(buf, sizeof(buf), " %s (%d) zosta³ wyrzucony. Powód: zbyt wysoki ping.", PlayerName(x), x);
					SendClientMessageToAll(COLOR_RED, buf);
					KickEx(x);
				}
			}
		} else {
			Pinger[x] = 0;
		}

		if(pAttraction[x]) continue;
		if(IsPlayerInAnyVehicle(x)) continue;
		if(IsInFreeZone) continue;

		new pweapons = GetPlayerWeapon(x);
		for(new i; i != xx; i++)
		{
			if(Abronie[i] == pweapons)
			{
				RemovePlayerWeapon(x, pweapons);
				SendClientMessage(x, COLOR_RED2, " Tej broni mo¿esz u¿ywaæ tylko w Wolnej strefie.");
				break;
			}
		}
	}
	return 1;
}

stock RemovePlayerWeapon(playerid, weaponid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	new pWeapons[2][13];
	
	for(new i; i < 13; i++)
	{
		GetPlayerWeaponData(playerid, i, pWeapons[0][i], pWeapons[1][i]);
	}
	
	for(new i; i < 13; i++)
	{
		if(pWeapons[0][i] != 0 && pWeapons[0][i] != weaponid)
		{
			GivePlayerWeapon(playerid, pWeapons[0][i], pWeapons[1][i]);
		}
	}
	return 1;
}

stock TeleportPlayerToPlayer (playerid, toplayerid) {
	new Float:PlayerPos[3];
	GetPlayerPos (toplayerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);

	new ToPlayerInterior = Player[toplayerid][InteriorX];
	new PlayerInterior = Player[playerid][InteriorX];
	if (PlayerInterior != ToPlayerInterior)
		SetPlayerInterior (playerid, ToPlayerInterior);

	if(!IsPlayerInAnyVehicle (playerid))
		SetPlayerPos (playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);
	else
	{
		if(PlayerInterior != ToPlayerInterior)
			LinkVehicleToInterior(GetPlayerVehicleID(playerid), ToPlayerInterior);

		SetVehiclePos(GetPlayerVehicleID(playerid), PlayerPos[0], PlayerPos[1], PlayerPos[2]);
		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPlayerVirtualWorld(toplayerid));
	}

	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(toplayerid));
}
	
callback->OnResponseFromAPI(index, response_code, data[]){
	if(response_code == 200){
		new API_response = strval(data[strfind(data, "status=") + 7]);
		new kodsms[64];
		GetPVarString(index, "KODSMS",kodsms,sizeof kodsms);
		switch(API_response){
			case 500, 505:{
				mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Problem Techniczny', '%s')", PlayerName(index),kodsms);
				SendClientMessage(index, 0xFFFFFFFF, "Przepraszamy, problem techniczny.");
			} 
			case 501:{
				mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Zly kod wybranej uslugi', '%s')", PlayerName(index),kodsms);
				SendClientMessage(index, 0xFFFFFFFF, "Z³y kod wybranej us³ugi!");
			} case 502:{
				mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Bledny kod', '%s')", PlayerName(index),kodsms);
				SendClientMessage(index, 0xFFFFFFFF, "Kod nieprawid³owy.");
			} case 503:{
				SendClientMessage(index, 0xFFFFFFFF, "Kod nieprawid³owy, zosta³ ju¿ wykorzystany.");
				mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Kod wykorzystany', '%s')", PlayerName(index),kodsms);
			} case 504: {
				new str4[128],monn[32];
				mysql_query_format("UPDATE `fg_Players` SET `Portfel`=Portfel+%d WHERE `Nick`='%s'",API_sms[GetPVarInt(index, "portfel_smsid")][KWOTA],PlayerName(index));
				mysql_query_format("SELECT `Portfel` FROM `fg_Players` WHERE `Nick`='%s'",PlayerName(index));
				mysql_store_result();
				mysql_fetch_row(monn);
				mysql_free_result();
				format(str4, sizeof str4, "{EAB171}Do³adowa³eœ portfel kwot¹: {AC3E00}%d{EAB171}z³ {EAB171}Stan Portfela: {AC3E00}%s{EAB171}z³",API_sms[GetPVarInt(index, "portfel_smsid")][KWOTA],monn);
				ShowPlayerDialog(index, 6969, 0, "Do³adowanie", str4, "OK", "");
				Player[index][Portfel] += API_sms[GetPVarInt(index, "portfel_smsid")][KWOTA];
				mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Sukces kwota %d', '%s')", PlayerName(index),API_sms[GetPVarInt(index, "portfel_smsid")][KWOTA],kodsms);
			}
		}
	}
	return 0;
}
stock GetPlayerCashInPortfel(playerid)
{
	mysql_query_format("SELECT `Portfel` FROM `fg_Players` WHERE `Nick` = '%s'",PlayerName(playerid));
	mysql_store_result(); 
	new rows = mysql_fetch_int(); 
	mysql_free_result();
	return rows;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) 
{
	A_CHAR(inputtext);
	
	if(dialogid == DIALOG_ZALOZ)
	{
		switch(listitem)
		{
			case 0:SetPlayerAttachedObject( playerid, 0, 2226, 1, 0.000000, -0.203173, -0.080502, 0.000000, 22.671218, 0.000000, 1.000000, 1.000000, 1.000000 );
			case 1:SetPlayerAttachedObject( playerid, 0, 19065, 2, 0.113131, 0.018596, 0.000000, 94.697052, 90.118164, 0.000000, 1.226595, 1.226595, 1.226595 );
			case 2:SetPlayerAttachedObject( playerid, 0, 18635, 2, -0.250711, -0.464394, 0.159861, 258.909912, 45.141162, 5.301577, 1.920960, 1.920960, 1.920960 );
			case 3:SetPlayerAttachedObject( playerid, 0, 18644, 2, 0.151123, 0.345173, 0.019663, 275.692535, 10.100483, 357.343811, 1.924180, 1.924180, 1.924180 );
			case 4:SetPlayerAttachedObject( playerid, 0, 1060, 1, 0.239907, -0.077574, 0.000871, 2.348074, 87.804405, 357.280487, 0.652846, 0.652846, 0.652846 );
			case 5:SetPlayerAttachedObject( playerid, 0, 18975, 2, 0.086262, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000 );
			case 6:SetPlayerAttachedObject( playerid, 0, 18890, 5, 0.037106, 0.096538, 0.019960, 337.156921, 4.156515, 252.433853, 1.000000, 1.000000, 1.000000 );
			case 7:SetPlayerAttachedObject( playerid, 0, 19137, 2, 0.092990, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 1.076031, 1.076031, 1.076031 );
			case 8:SetPlayerAttachedObject( playerid, 0, 18873, 1, -0.012269, 0.021618, 0.112074, 255.530456, 177.323989, 63.659469, 4.356958, 4.356958, 4.356958 );
			case 9:SetPlayerAttachedObject( playerid, 0, 1485, 2, 0.102237, 0.094420, -0.038719, 61.115173, 0.000000, 140.122970 );
			case 10:SetPlayerAttachedObject( playerid, 0, 18962, 2, 0.146981, 0.013410, 0.000000, 0.000000, 0.000000, 0.000000, 1.223083, 1.223083, 1.223083 );
			case 11:SetPlayerAttachedObject( playerid, 0, 339, 2, 0.178890, 0.004188, 0.130645, 346.583984, 188.009109, 12.984556 );
			case 12:SetPlayerAttachedObject( playerid, 0, 1238, 2, 0.435544, -0.001684, 0.000000, 0.000000, 90.000000, 285.874969 );
			case 13:SetPlayerAttachedObject( playerid, 0, 1549, 1, -0.173378, 0.021022, -0.012099, 3.122609, 87.657714, 355.966491, 1.000000, 1.000000, 1.000000 );
			case 14:SetPlayerAttachedObject( playerid, 0, 1453, 1, -0.202300, 0.010707, -0.029694, 0.737283, 267.933135, 0.000000, 1.000000, 1.000000, 1.000000 );
			case 15:SetPlayerAttachedObject( playerid, 0, 3785, 1, 0.073756, -0.125172, 0.002187, 30.842874, 88.859939, 234.537429, 1.000000, 1.000000, 1.000000 );
			case 16:SetPlayerAttachedObject( playerid, 0, 18873, 1, -0.012269, 0.021618, 0.112074, 255.530456, 177.323989, 63.659469, 4.356958, 4.356958, 4.356958 );
			case 17:SetPlayerAttachedObject( playerid, 0, 2663, 2, 0.233547, 0.028803, 0.017788, 271.072326, 88.000000, 0.000000 );
			case 18:SetPlayerAttachedObject( playerid, 0, 1609, 1, 0.041243, -0.101723, 0.016250, 89.706207, 349.184875, 272.334106, 0.190168, 0.190168, 0.190168 );
			case 19:SetPlayerAttachedObject( playerid, 0, 18637, 5, 0.0, 0.0, -0.2, 90.0, 0.0, 90.0, 1.0, 1.0, 1.0 );
			case 20:SetPlayerAttachedObject( playerid, 0, 18632, 6, 0.07, 0.0, 0.0, 180.0, 0.0, 0.0, 1.0, 1.0, 1.0);
			case 21:RemovePlayerAttachedObject(playerid, 0);
		}
	}
	new mon[128],
		str4[128];
		
	if(dialogid == GUI_BANK)
	{
		if(response == 0)return 1;
		switch(listitem){
            case 0: ShowPlayerDialog(playerid, GUI_BANK_WPLAC, 1, "{FFE5A1}Bank > Wplac", "{EAB171}Podaj kwote któr¹ chcesz wp³aciæ na konto: ", "Wp³aæ", "WyjdŸ");
            case 1: ShowPlayerDialog(playerid, GUI_BANK_WYPLAC, 1, "{FFE5A1}Bank > Wyplac", "{EAB171}Podaj kwote któr¹ chcesz wyp³aciæ z konta: ", "Wyp³aæ", "WyjdŸ");
            case 2:{
                mysql_query_format("SELECT `Bank` FROM `fg_Players` WHERE `Nick` = '%s'", PlayerName(playerid));
                mysql_store_result();
                mysql_fetch_row(mon);
                mysql_free_result();

                format(str4, sizeof str4, "{FFE5A1}Stan twojego konta bankowego wynosi {EAB171}%s$", mon);
                ShowPlayerDialog(playerid, GUI_BANK_STAN, 0, "{FFE5A1}Stan Konta", str4, "OK", "");
                return 1;
            }
            case 3: ShowPlayerDialog(playerid, GUI_BANK_PRZELEW, 1, "{FFE5A1}Bank > Przelew", "{EAB171}Podaj kwote któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
        }
        return 1;
    }
   	if(dialogid == GUI_BANK_WPLAC){
        if(response == 0) return 1;
        if(GetPlayerMoney(playerid) < strval(inputtext)) return ShowPlayerDialog(playerid, GUI_BANK_WPLAC, 1, "{FFE5A1}Bank > Wplac", "{EAB171}Nie masz tyle kasy!\n{EAB171}Podaj kwote któr¹ chcesz wp³aciæ na konto: ", "Wp³aæ", "WyjdŸ");
        mysql_query_format("UPDATE `fg_Players` SET `Bank` = `Bank` + %d WHERE `Nick` = '%s'", strval(inputtext), PlayerName(playerid));
        mysql_query_format("SELECT `Bank` FROM `fg_Players` WHERE `Nick` = '%s'", PlayerName(playerid));
        mysql_store_result();
        mysql_fetch_row(mon);
        mysql_free_result();
        MSGF(playerid, COLOR_RED, "{FFE5A1}Wplaci³eœ do banku: {AC3E00}%d$. {FFE5A1}Obecny stan konta: {AC3E00}%s$", strval(inputtext), mon);
        GivePlayerMoney(playerid, -strval(inputtext));
        return 1;
    }
    if(dialogid == GUI_BANK_WYPLAC){
		if(response == 0) return 1;
        mysql_query_format("SELECT `Bank` FROM `fg_Players` WHERE `Nick` = '%s'", PlayerName(playerid));
        mysql_store_result();
        mysql_fetch_row(mon);
        mysql_free_result();
        if(strval(mon) < strval(inputtext)) return ShowPlayerDialog(playerid, GUI_BANK_WYPLAC, 1, "{FFE5A1}Bank > Wyplac", "{EAB171}Nie masz tyle kasy!\n{EAB171}Podaj kwote któr¹ chcesz wyp³aciæ z konta: ", "Wyp³aæ", "WyjdŸ");
        mysql_query_format("UPDATE `fg_Players` SET `Bank` = `Bank` - %d WHERE `Nick` = '%s'", strval(inputtext), PlayerName(playerid));
        MSGF(playerid, COLOR_RED, "{FFE5A1}Wyplaci³eœ z banku: {AC3E00}%d$. {FFE5A1}Obecny stan konta: {AC3E00}%d$", strval(inputtext), strval(mon)-strval(inputtext));
        GivePlayerMoney(playerid, strval(inputtext));
        return 1;
    }
    if(dialogid == GUI_BANK_PRZELEW){
        if(response == 0) return 1;
		mysql_query_format("SELECT `Bank` FROM `fg_Players` WHERE `Nick` = '%s'", PlayerName(playerid));
        mysql_store_result();
        mysql_fetch_row(mon);
        if(strval(mon) < strval(inputtext)) return ShowPlayerDialog(playerid, GUI_BANK_PRZELEW, 1, "{FFE5A1}Bank > Przelew", "{FFE5A1}Nie posiadasz takiej iloœci pieniêdzy\n{FFE5A1}Podaj kwote któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
		SetPVarInt(playerid, "k", strval(inputtext));
        format(str4, sizeof str4, "{FFE5A1}Kwota: {AC3E00}%d$\n{FFE5A1}Podaj id gracza:", strval(inputtext));
        ShowPlayerDialog(playerid, GUI_BANK_PRZELEW2, 1, "{FFE5A1}Bank > Przelew", str4, "Przelej", "Wyjdz");
        return 1;
    }
    if(dialogid == GUI_BANK_PRZELEW2){
        if(response == 0) return 1;
        if(!IsPlayerConnected(strval(inputtext))) return SendClientMessage(playerid, COLOR_RED, "{FF732F}»»»{CC0000} Nie ma takiego gracza!");
		if(!logged[strval(inputtext)]) return SendClientMessage(playerid, COLOR_RED, "{FF732F}»»»{CC0000} Gracz nie jest zarejestrowany!");
        mysql_query_format("UPDATE `fg_Players` SET `Bank` =`Bank` + %d WHERE `Nick` = '%s'", GetPVarInt(playerid, "k"), PlayerName(strval(inputtext)));
        mysql_query_format("UPDATE `fg_Players` SET `Bank` =`Bank` - %d WHERE `Nick` = '%s'", GetPVarInt(playerid, "k"), PlayerName(playerid));
		mysql_query_format("SELECT `Bank` FROM `fg_Players` WHERE `Nick`='%s'",PlayerName(playerid));
		mysql_store_result();
        mysql_fetch_row(mon);
        mysql_free_result();
		new monn[128];
		mysql_query_format("SELECT `Bank` FROM `fg_Players` WHERE `Nick`='%s'",PlayerName(strval(inputtext)));
		mysql_store_result();
        mysql_fetch_row(monn);
        mysql_free_result();
        MSGF(playerid, COLOR_RED, "{FFE5A1}Przela³eœ graczowi {AC3E00}%s {FFE5A1}na jego konto kwotê {AC3E00}%d${FFE5A1}. Obecny stan konta: {AC3E00}%s$", PlayerName(strval(inputtext)),GetPVarInt(playerid, "k"), mon);
		MSGF(strval(inputtext), COLOR_RED, "{FFE5A1}Gracz %s {FFE5A1}przela³ na twoje konto kwotê {AC3E00}%d${FFE5A1}. Obecny stan konta: {AC3E00}%s$", PlayerName(playerid), GetPVarInt(playerid, "k"), monn);
		return 1;
    }
	if(dialogid == GUI_EXP_PRZELEW){
        if(response == 0) return 1;
        if(Respekt[playerid] < strval(inputtext)) return ShowPlayerDialog(playerid, GUI_EXP_PRZELEW, 1, "{FFE5A1}Portfel > Przelew EXP", "{FFE5A1}Nie posiadasz takiej iloœci EXP\n{FFE5A1}Podaj kwote któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
        if(strval(inputtext) < 1  || strval(inputtext) > 10000) return ShowPlayerDialog(playerid, GUI_EXP_PRZELEW, 1, "{FFE5A1}Portfel > Przelew EXP", "{FFE5A1}Z³a liczba EXP\n{FFE5A1}Podaj kwote któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
		SetPVarInt(playerid, "e", strval(inputtext));
        format(str4, sizeof str4, "{FFE5A1}Kwota: {AC3E00}%d EXP\n{FFE5A1}Podaj id gracza:", strval(inputtext));
        ShowPlayerDialog(playerid, GUI_EXP_PRZELEW2, 1, "{FFE5A1}Portfel > Przelew", str4, "Przelej", "Wyjdz");
        return 1;
    }
    if(dialogid == GUI_EXP_PRZELEW2){
        if(response == 0) return 1;
        if(!IsPlayerConnected(strval(inputtext))) return SendClientMessage(playerid, COLOR_RED, "{FF732F}»»»{CC0000} Nie ma takiego gracza!");
		if(!logged[strval(inputtext)]) return SendClientMessage(playerid, COLOR_RED, "{FF732F}»»»{CC0000} Gracz nie jest zarejestrowany!");
		new player_exp = GetPVarInt(playerid, "e");
		Respekt[playerid] -= player_exp;
		Respekt[strval(inputtext)] += player_exp;
        MSGF(playerid, COLOR_RED, "{FFE5A1}Przela³eœ graczowi {AC3E00}%s {FFE5A1}na jego konto  {AC3E00}%d EXP{FFE5A1}. Obecnie posiadasz: {AC3E00}%d EXP", PlayerName(strval(inputtext)),GetPVarInt(playerid, "e"), Respekt[playerid]);
		MSGF(strval(inputtext), COLOR_RED, "{FFE5A1}Gracz %s {FFE5A1}przela³ na twoje konto {AC3E00}%d EXP{FFE5A1}. Obecny stan konta: {AC3E00}%d EXP", PlayerName(playerid), GetPVarInt(playerid, "e"), Respekt[strval(inputtext)]);
		mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Przelew na Nick: %s', 'Kwota: %d')", PlayerName(playerid),PlayerName(strval(inputtext)), GetPVarInt(playerid, "e"));
		return 1;
    }
	if(dialogid == GUI_KASA_PRZELEW){
        if(response == 0) return 1;
		mysql_query_format("SELECT `Portfel` FROM `fg_Players` WHERE `Nick` = '%s'", PlayerName(playerid));
        mysql_store_result();
        mysql_fetch_row(mon);
        if(strval(mon) < strval(inputtext)) return ShowPlayerDialog(playerid, GUI_KASA_PRZELEW, 1, "{FFE5A1}Portfel > Przelew", "{FFE5A1}Nie posiadasz takiej iloœci pieniêdzy\n{FFE5A1}Podaj kwote któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
        if(strval(inputtext) < 1  || strval(inputtext) > 100) return ShowPlayerDialog(playerid, GUI_KASA_PRZELEW, 1, "{FFE5A1}Portfel > Przelew", "{FFE5A1}Nie posiadasz takiej iloœci pieniêdzy\n{FFE5A1}Podaj kwote któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
		SetPVarInt(playerid, "p", strval(inputtext));
        format(str4, sizeof str4, "{FFE5A1}Kwota: {AC3E00}%dZ£\n{FFE5A1}Podaj id gracza:", strval(inputtext));
        ShowPlayerDialog(playerid, GUI_KASA_PRZELEW2, 1, "{FFE5A1}Portfel > Przelew", str4, "Przelej", "Wyjdz");
        return 1;
    }
    if(dialogid == GUI_KASA_PRZELEW2){
        if(response == 0) return 1;
        if(!IsPlayerConnected(strval(inputtext))) return SendClientMessage(playerid, COLOR_RED, "{FF732F}»»»{CC0000} Nie ma takiego gracza!");
		if(!logged[strval(inputtext)]) return SendClientMessage(playerid, COLOR_RED, "{FF732F}»»»{CC0000} Gracz nie jest zarejestrowany!");
        mysql_query_format("UPDATE `fg_Players` SET `Portfel` =`Portfel` + %d WHERE `Nick` = '%s'", GetPVarInt(playerid, "p"), PlayerName(strval(inputtext)));
        mysql_query_format("UPDATE `fg_Players` SET `Portfel` =`Portfel` - %d WHERE `Nick` = '%s'", GetPVarInt(playerid, "p"), PlayerName(playerid));
		mysql_query_format("SELECT `Portfel` FROM `fg_Players` WHERE `Nick`='%s'",PlayerName(playerid));
		mysql_store_result();
        mysql_fetch_row(mon);
        mysql_free_result();
		new monn[128];
		mysql_query_format("SELECT `Portfel` FROM `fg_Players` WHERE `Nick`='%s'",PlayerName(strval(inputtext)));
		mysql_store_result();
		new portfel_cash = GetPVarInt(playerid, "p");
		Player[playerid][Portfel] -= portfel_cash;
		Player[strval(inputtext)][Portfel] +=portfel_cash;
        mysql_fetch_row(monn);
        mysql_free_result();
        MSGF(playerid, COLOR_RED, "{FFE5A1}Przela³eœ graczowi {AC3E00}%s {FFE5A1}na jego konto kwotê {AC3E00}%dZ£{FFE5A1}. Obecny stan konta: {AC3E00}%sZ£", PlayerName(strval(inputtext)),GetPVarInt(playerid, "p"), mon);
		MSGF(strval(inputtext), COLOR_RED, "{FFE5A1}Gracz %s {FFE5A1}przela³ na twoje konto kwotê {AC3E00}%dZ£{FFE5A1}. Obecny stan konta: {AC3E00}%sZ£", PlayerName(playerid), GetPVarInt(playerid, "p"), monn);
       mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Przelew na Nick: %s', 'Kwota: %d')", PlayerName(playerid),PlayerName(strval(inputtext)), GetPVarInt(playerid, "p"));
	   return 1;
    }
	if(dialogid == DIALOG_EXITARENA && response)
	{
		if(pData[playerid][chainsawn] == 1)
		{
			pData[playerid][chainsawn] = 0;
			SetPlayerRandomSpawn(playerid);
			SetPlayerVirtualWorld(playerid,0);
			SetPlayerInterior(playerid,0);
			SetPlayerHealth(playerid,100.00);
			return 1;
		}
		else if(pData[playerid][de] == 1)
		{
			pData[playerid][de] = 0;
			SetPlayerRandomSpawn(playerid);
			SetPlayerVirtualWorld(playerid,0);
			SetPlayerInterior(playerid,0);
			SetPlayerHealth(playerid,100.00);
			return 1;
		}
		else if(pData[playerid][sniper] == 1)
		{
			pData[playerid][sniper] = 0;
			SetPlayerRandomSpawn(playerid);
			SetPlayerVirtualWorld(playerid,0);
			SetPlayerInterior(playerid,0);
			SetPlayerHealth(playerid,100.00);
			return 1;
		}
		else if(pData[playerid][minigun] == 1)
		{
			pData[playerid][minigun] = 0;
			SetPlayerRandomSpawn(playerid);
			SetPlayerVirtualWorld(playerid,0);
			SetPlayerInterior(playerid,0);
			SetPlayerHealth(playerid,100.00);
			return 1;
		}
		return 1;
	}

	if(dialogid == DIALOG_NEWNICK)
	{
		if(response == 1)
		{
			new pass[64];
			mysql_real_escape_string(inputtext, pass);
			mysql_query_format("SELECT `Nick` FROM `fg_Players` WHERE Nick = '%s' AND `Pass`='%s' limit 1;",PlayerName(playerid),pass);
			
			mysql_store_result();
			if(!mysql_num_rows())
			{
		        SendClientMessage(playerid, COLOR_RED2, "Podano b³êdne has³o! Zacznij od pocz¹tku");		
				return 0;
			}
			new tmps[256];
			mysql_query_format("UPDATE `fg_Players` SET `Nick`='%s', `Next_Nick`=DATE_ADD(NOW(), INTERVAL 72 HOUR) WHERE `Nick`='%s' LIMIT 1",Player[playerid][NewNick],PlayerName(playerid));
			mysql_query_format( "UPDATE `Kody` SET `Nick`='%s' WHERE `Nick` = '%s LIMIT 1'",Player[playerid][NewNick]);
			format(tmps,sizeof(tmps),"{FFE5A1}Statystyki przeniesone na nick: %s!\n{FFE5A1}Gdy wyjdziesz z serwera to wejdŸ ju¿ na nowym nicku.\n{FFE5A1}Kolejna zmiana nicku mo¿liwa za 72h!",Player[playerid][NewNick]);
		
			ShowPlayerDialog(playerid,DIALOG_PORTFEL_VIP+189,0,"{FFE5A1}Sukces!",tmps,"OK", "" );
			SetPlayerName(playerid,Player[playerid][NewNick]);		
			SaveData(playerid);
				
			new x=HouseID[playerid];

			if(x >= 0){
				format(HouseInfo[x][hOwner],MAX_PLAYER_NAME,"%s",PlayerName(playerid));
				house_Update(x,2,PlayerName(playerid));
			}
			return 1;
		}
		return 1;
	}
	if(dialogid == DIALOG_PORTFEL_SHOP_CAPTCHA)
	{
		if(!response)
			return DeletePVar(playerid, "vip_captcha");
		new info[64], captcha[6], chars[] ={
			'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'r',
			's', 'k', 'u', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
		GetPVarString(playerid, "vip_captcha", captcha, sizeof captcha);
	
		if(!strcmp(inputtext,  captcha) && inputtext[0]) {
			ShowPlayerDialog(playerid, DIALOG_PORTFEL_SHOP_LIST, DIALOG_STYLE_LIST, "Doladowanie portfela", "2z³ do portfela koszt (2,46 z³)\n6z³ do portfela koszt (6,15 z³)\n11z³ do portfela koszt (11,07 z³)\n23z³ do portfela koszt (23,37 z³)\n30z³ do portfela koszt (30,75 z³)", "Gotowe", "Anuluj");
			DeletePVar(playerid, "vip_captcha");
		} else {
			for(new c; c != sizeof captcha; c++)
				captcha[c] = chars[random(sizeof chars)];
			SetPVarString(playerid, "vip_captcha", captcha);
			format(info, sizeof info, "{EAB171}Przepisz kod, aby kontynowaæ:\n{AC3E00}%s", captcha);
			ShowPlayerDialog(playerid, DIALOG_PORTFEL_SHOP_CAPTCHA, DIALOG_STYLE_INPUT, "KOD CAPTCHA ZABEZPIECZENIA", info, "Gotowe", "Anuluj");
		}
		return 1;
	}
	if(dialogid ==  DIALOG_PORTFEL_SHOP_LIST)
	{
		if(!response)
				return 1;
		new msg[512];
		SetPVarInt(playerid, "portfel_smsid", listitem);
		format(msg, sizeof msg, "{EAB171}Administracja nie ponosi odpowiedzialnoœci za b³êdne wys³ane treœci oraz b³êdnie podane nr wysy³aj¹c smsa akceptujesz regulamin{EAB171}\nktóry znajdziesz pod: /portfel >Regulamin albo FullGaming.pl/premium\n\n{EAB171}Wyœlij SMS o treœci {AC3E00}%s{EAB171} na numer {AC3E00}%d {EAB171}(koszt {AC3E00}%s {EAB171}z³ z VAT), podaj kod zwrotny:", API_sms[listitem][SMS_MSG], API_sms[listitem][SMS], API_sms[listitem][COST]);
		ShowPlayerDialog(playerid, DIALOG_PORTFEL_SHOP_CODE, DIALOG_STYLE_INPUT, "Do³adowanie Portfela", msg, "Gotowe", "Anuluj");
		return 1;
	}
	if(dialogid == DIALOG_PORTFEL_SHOP_CODE)
	{
		
		if(!inputtext[0])
		{
			SendClientMessage(playerid, 0xFF0000FF, "B³êdny kod, spróbuj od pocz¹tku.");
			return 1;
		}
		for(new c; c != strlen(inputtext); c++)
			switch(tolower(inputtext[c])){
				case '0' .. '9', 'a' .. 'z': continue;
				default:{
					SendClientMessage(playerid, 0xFF0000FF, "B³êdny kod, spróbuj od pocz¹tku.");
					return 1;
				}
			}
		SendClientMessage(playerid, 0xFFFFFFFF, "Proszê czekaæ, trwa sprawdzanie kodu...");
		new api_url[128];
		format(api_url, sizeof api_url, API_URL"%s&code=%s", API_sms[GetPVarInt(playerid, "portfel_smsid")][API_SVR], inputtext);
		SetPVarString(playerid, "KODSMS", inputtext);
		HTTP(playerid, HTTP_GET, api_url, "", "OnResponseFromAPI");
		return 1;
	}
	if(dialogid ==  DIALOG_PORTFEL_WYBOR)
	{
		//{AC3E00}Wp³aæ\n{EAB171}Wyp³aæ 1 ciemny 2 jasny
		if(!response)
			return 1;
		switch(listitem)
		{
			case 0: ShowPlayerDialog(playerid,DIALOG_PORTFEL_VIP,2," {FFE5A1}Sklep-VIP","{EAB171}14dni Cena:\t {AC3E00}2{EAB171}z³\n{EAB171}30dni Cena:\t {AC3E00}6{EAB171}z³\n{EAB171}45dni Cena:\t {AC3E00}9{EAB171}z³\n{EAB171}60dni Cena:\t {AC3E00}12{EAB171}z³\n{EAB171}90dni Cena:\t {AC3E00}16{EAB171}z³\n","Kup", "Anuluj" );
			case 1: ShowPlayerDialog(playerid,DIALOG_PORTFEL_SCORE,2," {FFE5A1}Sklep-Exp","{EAB171}500Exp Cena:\t {AC3E00}1{EAB171}z³\n{EAB171}1000Exp Cena:\t {AC3E00}3{EAB171}z³\n{EAB171}3000Exp Cena:\t {AC3E00}6{EAB171}z³\n{EAB171}5000Exp Cena:\t {AC3E00}8{EAB171}z³\n{EAB171}10000Exp Cena:\t {AC3E00}15{EAB171}z³\n","Kup", "Anuluj");
				
		}
		return 1;
	}
	if(dialogid ==  DIALOG_PORTFEL_VIP)
	{
		if(!response) 
			return 1;
		new bufff[256],buffff[128],kwota = 0,dni = 0;
		if(listitem == 0)     {kwota = 2;  dni = 14;}
		else if(listitem == 1){kwota = 6;  dni = 30;}
		else if(listitem == 2){kwota = 9;  dni = 45;}
		else if(listitem == 3){kwota = 12;  dni = 60;}
		else if(listitem == 4){kwota = 16; dni = 90;}

		if(GetPlayerCashInPortfel(playerid) < kwota-0.01) 
			return ShowPlayerDialog(playerid,DIALOG_PORTFEL_VIP+109,0,"{FFE5A1}ERROR","{FFE5A1}Nie masz takiej sumy w portfelu!\n{FFE5A1}Do³aduj pierw portfel","OK", "" );
		if(Player[playerid][VIP])
		{
				mysql_query_format("UPDATE `fg_Players` SET `Portfel`=`Portfel`-%d,`Vip` = DATE_ADD(`Vip`, INTERVAL '%d'*86400 SECOND) WHERE `Nick`='%s' LIMIT 1", kwota,dni,PlayerName(playerid));
		}
		else 
		{
			mysql_query_format("UPDATE `fg_Players` SET `Portfel`=`Portfel`-%d,`Vip` = DATE_ADD(NOW(), INTERVAL '%d'*86400 SECOND) WHERE `Nick`='%s' LIMIT 1", kwota,dni,PlayerName(playerid));
		}
		mysql_query_format("SELECT `Vip` FROM `fg_Players` WHERE `Nick`='%s'",PlayerName(playerid));
		mysql_store_result();
		mysql_fetch_row(buffff);
		mysql_free_result();
		Player[playerid][VIP] = true;
		format(bufff,sizeof bufff,"{FFE5A1}Twoje konto VIP wa¿ne do {DEAF21}%s ",buffff);
		ShowPlayerDialog(playerid,DIALOG_PORTFEL_VIP+108,0,"{FFE5A1}Sukces!",bufff,"OK", "");
		Player[playerid][Portfel] -= kwota;
		OnlVIP++;
		mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'VIP DO: %s', 'Portfel - ViP')", PlayerName(playerid),buffff);
		return 1;
	}
	if(dialogid ==  DIALOG_PORTFEL_SCORE)
	{
		if(!response) 
			return 1;
		new bufffs[162],kwotaa = 0,score = 0;
		if(listitem == 0)     {kwotaa = 1;  score = 500; }
		else if(listitem == 1){kwotaa = 3;  score = 1000; }
		else if(listitem == 2){kwotaa = 6;  score = 3000; }
		else if(listitem == 3){kwotaa = 8;  score = 5000; }
		else if(listitem == 4){kwotaa = 15; score = 10000;}
		if(GetPlayerCashInPortfel(playerid) < kwotaa-0.01)
			return ShowPlayerDialog(playerid,DIALOG_PORTFEL_SCORE+189,0,"{FFE5A1}ERROR","{FFE5A1}Nie masz takiej sumy w portfelu!\n{FFE5A1}Do³aduj pierw portfel","OK", "" );
			
		mysql_query_format("UPDATE `fg_Players` SET `Score`=`Score`+%d, `Portfel`=`Portfel`-%d WHERE `Nick`='%s' LIMIT 1", score,kwotaa,PlayerName(playerid));
		mysql_query_format("INSERT INTO `portfel_log` (`Nick`, `Data`, `Status`,`Kod`) VALUES ('%s', NOW(), 'Score: %d Kupil: %d', 'Portfel- Exp')", PlayerName(playerid),Respekt[playerid],score);

		Respekt[playerid] += score;
		Player[playerid][Level] = GetPlayerLevel(playerid);
		format(bufffs,sizeof bufffs,"{FFE5A1}Zakupi³eœ {DEAF21}%d {FFE5A1}Exp, ³¹cznie posiadasz{DEAF21}%d {FFE5A1}Score",score,Respekt[playerid]);
		ShowPlayerDialog(playerid,DIALOG_PORTFEL_SCORE+187,0,"{FFE5A1}Sukces!",bufffs,"OK", "");
		Player[playerid][Portfel] -= kwotaa;
		SaveData(playerid);		
		return 1;
	}
	if(dialogid == DIALOG_PORTFEL_CMD)
	{
		new str7[128],monn[32];
		if(!response) return 1;
		switch(listitem){
			case 0: {
				new info[64], captcha[6], chars[] ={
					'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'r',
					's', 'k', 'u', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
				for(new c; c != sizeof captcha; c++)
					captcha[c] = chars[random(sizeof chars)];
				SetPVarString(playerid, "vip_captcha", captcha);
				format(info, sizeof info, "{EAB171}Przepisz kod, CAPTCHA aby kontynowaæ:\n{AC3E00}%s", captcha);
				ShowPlayerDialog(playerid, DIALOG_PORTFEL_SHOP_CAPTCHA, DIALOG_STYLE_INPUT, "{FFE5A1}Portfel gracza", info, "Gotowe", "Anuluj");
				return 1;
			} 
			case 1:{
				mysql_query_format("SELECT `Portfel` FROM `fg_Players`  WHERE `Nick`='%s' LIMIT 1",PlayerName(playerid));
				mysql_store_result();
				mysql_fetch_row(monn);
				mysql_free_result();
				format(str7, sizeof str7, "{FFE5A1}Stan twojego portfela wynosi {EAB171}%sz³", monn);
				
				ShowPlayerDialog(playerid, DIALOG_PORTFEL_STAN, 0, "{FFE5A1}Stan Portfela", str7, "OK", "");
				return 1;
			}
			case 2: ShowPlayerDialog(playerid,DIALOG_PORTFEL_WYBOR,2,"{FFE5A1}Sklep","{EAB171}Doladuj konto VIP\n{EAB171}Kup Exp","OK", "Anuluj" );
			case 3:{
				new StrinG[1700];
				StrinG = "{FF0000}1. Administracja nie ponosi odpowiedzialoœci za:\n\t";
				strcat(StrinG,"{FF0000}- B³êdne treœci smsa\n\t");
				strcat(StrinG,"{FF0000}- B³êdny numer smsa\n\t");
				strcat(StrinG,"{FF0000}- Za utratê œrodków w portfelu wynikaj¹c¹ z dzia³ania si³y wy¿szej lub niespodziewanych b³êdów systemu po stronie naszej jak i stronie operatora us³ug Premium SMS.\n\n");
				strcat(StrinG,"{FF0000}2. Nie ma mo¿liwoœci zwrócenia kosztów za do³adowania wykonane w celu do³adowania portfela.\n\t{FF0000}Do³adowuj¹c portfel gracz jest œwiadomy ¿e mo¿e to wykorzystaæ tylko i wy³¹cznie na us³ugi dodatkowe na serwerze.\n\n");
				strcat(StrinG,"{FF0000}3. W przypadku otrzymania bana na serwerze, nie ma mo¿liwoœci zwrotu œrodków wp³aconych do portfela.\n\t{FF0000}Wa¿noœæi us³ug wykupionych za pomoc¹ œrodków z portfela, w przypadku bana up³ywa w normalny sposób. Jeœli gracz chce odzyskaæ do nich dostêp, musi ubiegaæ siê o odbanowanie.\n\n");
				strcat(StrinG,"{FF0000}4. Œrodki zgromadzone w portfelu mog¹ zostaæ wykorzystane na us³ugi dodatkowe na serwerze takie jak: Konto V.I.P,Score itp.\n\n");
				strcat(StrinG,"{FF0000}5. Do³adowuj¹c swój portfel, gracz akceptuje warunki niniejszego regulaminu oraz regulaminu operatora us³ug Premium SMS\n");
				strcat(StrinG,"\n\n{C0C0C0}Pe³ny regulamin znajdziesz pod adresem {FFFFFF}FullGaming.pl/portfel");
				strcat(StrinG,"\n {C0C0C0}© {FFFFFF}2013");
				ShowPlayerDialog(playerid,DIALOG_PORTFEL_STAN,0,"{FFE5A1}Regulamin portfela",StrinG,"OK", "" );
				}
			case 4: ShowPlayerDialog(playerid,DIALOG_PORTFEL_PRZESLIJ,2,"{FFE5A1}Sklep","{EAB171}Przeœlij wirtualne pieni¹dze\n{EAB171}Przeœlij Exp","OK", "Anuluj" );
		}
		return 1;
	}
	if(dialogid == DIALOG_PORTFEL_PRZESLIJ && response)
	{
		switch(listitem)
		{
			case 0: ShowPlayerDialog(playerid, GUI_KASA_PRZELEW, 1, "{FFE5A1}Portfel > Portfel Gracza Przelew", "{EAB171}Podaj kwote w Z£ któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
			case 1: ShowPlayerDialog(playerid, GUI_EXP_PRZELEW, 1, "{FFE5A1}Portfel > EXP", "{EAB171}Podaj kwote EXP któr¹ chcesz przelaæ na konto innego gracza: ", "Przelej", "WyjdŸ");
		}
		return 1;
	}

    if(dialogid == DIALOG_MPLAYER && response)
	{
		foreachPly (x) {
			PlayAudioStreamForPlayer(x, inputtext);		
		}
	}
	if(dialogid == DIALOG_ADMINER)
	{
	    if(response)
	    {
	        new StrinG[2500];

			StrinG = "{FF0000}/Walizka - Stawiasz walizkê\n";
		    strcat(StrinG,"{FF0000}/Podkowa {FFFFFF}- Stawiasz podkowê\n");
			strcat(StrinG,"{FF0000}/GiveGun [ID] [ID Broni] {FFFFFF}- Dajesz broñ\n");
		    strcat(StrinG,"{FF0000}/Granaty {FFFFFF}- Dajesz wszystkim granaty\n");
		    strcat(StrinG,"{FF0000}/Combat {FFFFFF}- Dajesz wszystkim combat shotgun\n");
		    strcat(StrinG,"{FF0000}/Tec {FFFFFF}- Dajesz wszystkim TEC-9\n");
		    strcat(StrinG,"{FF0000}/Sniper {FFFFFF}- Dajesz wszystkim Sniper-Rifle\n");
		    strcat(StrinG,"{FF0000}/M4 {FFFFFF}- Dajesz wszystkim M4\n");
		    strcat(StrinG,"{FF0000}/Shotgun {FFFFFF}- Dajesz wszystkim shotguna\n");
		    strcat(StrinG,"{FF0000}/MP5 {FFFFFF}- Dajesz wszystkim MP5\n");
		    strcat(StrinG,"{FF0000}/SO {FFFFFF}- Dajesz wszystkim Sawn-Off-Shotgun\n");
		    strcat(StrinG,"{FF0000}/DE {FFFFFF}- Dajesz wszystkim Desert-Eagle\n");
		    strcat(StrinG,"{FF0000}/Heal50 {FFFFFF}- Uzdrawiasz graczy w promieniu 50 metrów\n");
		    strcat(StrinG,"{FF0000}/Armor50 {FFFFFF}- Dajesz pancerz graczom w promieniu 50 metrów\n");
		    strcat(StrinG,"{FF0000}/Crate /UnCrate {FFFFFF}- Kratowanie gracza\n");
		    strcat(StrinG,"{FF0000}/Respawn [ID] {FFFFFF}- Respawnujesz gracza\n");
			strcat(StrinG,"{FF0000}/SetIp {FFFFFF}- Zmieniasz interior gracza\n");
		    strcat(StrinG,"{FF0000}/SetWorld {FFFFFF}- Zmieniasz Virtual-World gracza\n");
		    strcat(StrinG,"{FF0000}/SkinP [ID] [ID Skina] {FFFFFF}- Zmieniasz skina wybranemu ID\n");
		    strcat(StrinG,"{FF0000}/DelWalizka [ID] {FFFFFF}- Usuwasz walizkê\n");
		    strcat(StrinG,"{FF0000}/UnBan [IP] {FFFFFF}- Dajesz UnBana\n");
			strcat(StrinG,"{FF0000}/DelPodkowa {FFFFFF}- Usuwasz podkowê\n");
			strcat(StrinG,"{FF0000}/God [ID] {FFFFFF}- Dajesz goda\n");
		    strcat(StrinG,"{FF0000}/ArmourGod [ID] {FFFFFF}- Nieskoñczona kamizelka\n");
		    strcat(StrinG,"{FF0000}/VehGod [ID] {FFFFFF}- Niezniszczalny pojazd\n");
		    strcat(StrinG,"{FF0000}/JetPack [ID] {FFFFFF}- Dajesz jetpacka\n");
		    strcat(StrinG,"{FF0000}/killp [ID] {FFFFFF}- Zabijasz gracza\n");
			strcat(StrinG,"{FF0000}/DA50 {FFFFFF}- Rozbrajasz graczy w promieniu 50 metrów\n");
			strcat(StrinG,"{FF0000}/Disarm [ID] {FFFFFF}- Rozbrajasz gracza");

			ShowPlayerDialog(playerid,DIALOG_ADMINER,0,"Komendy administracji",StrinG,"Cofnij","OK");
	    }
		else
		{
		    ShowPlayerDialog(playerid,DIALOG_ADMIN_KUPNO,DIALOG_STYLE_LIST,"Konto premium","¤ Informacje\n¤ Mo¿liwoœci konta premium\n¤ Komendy konta premium\n¤ Kupno konta Admin","Wybierz","Anuluj");
		}
	}

	if(dialogid == DIALOG_VGRANATY && response)
	{
	    Respekt[playerid] -= 20;
		Player[playerid][Level] = GetPlayerLevel(playerid);
		GivePlayerWeapon(playerid, 16, 30);
		return 1;
    }

	if(dialogid == DIALOG_HOUSE1)
    {
		IDHouse = strval(inputtext);
        SendClientMessage(playerid, COLOR_GREEN, "  * Teraz idŸ tam gdzie ma byæ dom i wpisz /Dalej.");
		OneHouse = true;
	}

    if(dialogid == DIALOG_HOUSE2)
    {
		SendClientMessage(playerid, COLOR_GREEN, "  * Teraz wsi¹dŸ w jakiœ pojazd i zaparkuj go w miejscu prywatnego pojazdu.");
        SendClientMessage(playerid, COLOR_GREEN, "  * A potem wpisz /Dalej3.");
		IDVehicleHouse = strval(inputtext);
        ThriHouse = true;
		TwoHouse = false;
	}

    if(dialogid == DIALOG_HOUSE3)
    {
		RespektHouse = strval(inputtext);
		ThriHouse = false;
        ShowPlayerDialog(playerid, DIALOG_HOUSE4,DIALOG_STYLE_INPUT,"Virtual World","WprowadŸ Virtual World domu:","OK","Anuluj");
	}

    if(dialogid == DIALOG_HOUSE4)
    {
        new tmp[256];
		new File:Domy = fopen("/GoldMap/Domy.txt", io_append);
		format(tmp, sizeof tmp, "\r\n%d||%f,%f,%f|%f,%f,%f|%d|%f,%f,%f,%f|%d|0|%d|%d", IDHouse,HousePos[0],HousePos[1],HousePos[2],HousePosIn[0],HousePosIn[1],HousePosIn[2],IDVehicleHouse,VehHousePos[0],VehHousePos[1],VehHousePos[2],z_rot,RespektHouse,InteriorHouse,strval(inputtext));
		fwrite(Domy, tmp);
        HouseInfo[IDHouse][hCarid] = CreateVehicle(IDVehicleHouse,VehHousePos[0],VehHousePos[1],VehHousePos[2],z_rot,-1,-1,600000);
		HouseInfo[IDHouse][hPick] = CreatePickup(1273,2,HousePos[0],HousePos[1],HousePos[2]);
		HouseInfo[IDHouse][hOpen] = false;

        HouseInfo[IDHouse][hCost] = RespektHouse;
		format(tmp,sizeof(tmp),"Dom w budowie\nCzynsz %d Exp na dzieñ\nKoniec budowy godzina: 0:00\nID: %d",HouseInfo[IDHouse][hCost], IDHouse);
		HouseInfo[IDHouse][hLabel] = Create3DTextLabel(tmp, 0xE8AA00FF, HousePos[0],HousePos[1],HousePos[2]+0.75, 30.0, 0, 1);
        foreachPly (x) {
			SetPlayerMapIcon(x, IDHouse, HousePos[0],HousePos[1],HousePos[2], 32,0);
		}
		fclose(Domy);
	}

	if(dialogid == DIALOG_NUTA && response) {
		if (!(4 <= strlen (inputtext) < 256)) {
			ShowPlayerDialog(playerid, DIALOG_NUTA1, DIALOG_STYLE_INPUT, "Player", "Podaj bezpoœredni link do utworu/stacji radiowej która ma graæ\nLink musi zaczynaæ siê od www albo http", "Graj", "Anuluj");
			return SendClientMessage (playerid, -1, "Wyst¹pi³ nieoczekiwany b³¹d.");
		}
		
		PlayAudioStreamForPlayer(playerid, inputtext);

		new String[255];
		format(String, sizeof(String), "Odtwarzanie %s", inputtext);
		SendClientMessage (playerid, COLOR_GREEN, String);
	    return 1;
	}
	if(dialogid == DIALOG_RADIO) {
		
		
		if (!response) return 1;
		switch (listitem) {
			case 0: ShowPlayerDialog(playerid, DIALOG_RADIO2, DIALOG_STYLE_LIST, "{18339E}Lista radiostacji", "Radio Party - K. G³ówny\nClub Party\nRadio Eska\nRadio Eska - Club\nRadio Eska - Classic Rock\nRadio Zet\nRadio Maxxx\nRMF FM\nPolska Stacja - Hip-Hop\nAnty Radio", "Wybierz", "Anuluj");
			case 1: ShowPlayerDialog(playerid, DIALOG_NUTA, DIALOG_STYLE_INPUT,"{18339E}Player", "Podaj bezpoœredni link do utworu/stacji radiowej, która ma graæ:", "Graj", "Anuluj");
			case 2: {
				StopAudioStreamForPlayer(playerid);
				SendClientMessage(playerid,0xFFFFFFFF,"Zatrzyma³eœ odtwarzanie radia.");
			}
		}
	}
	//Radio - Stacje
	if(dialogid == DIALOG_RADIO2) {
		
		if (!response) return 1;
		switch (listitem) {
			case 0: { // radio party - glowny
				PlayAudioStreamForPlayer(playerid, "http://s2.radioparty.pl:8005");
				SendClientMessage (playerid, -1, "Odtwarzanie: Radio Party.");
			}
			case 1: { // club party
				PlayAudioStreamForPlayer(playerid, "http://s1.slotex.pl:8654");
				SendClientMessage (playerid, -1, "Odtwarzanie: Club Party.");
			} 
			case 2: { // radio eska - wroclaw
				PlayAudioStreamForPlayer(playerid, "http://poznan4-2.radio.pionier.net.pl:8000/pl/eska-wroclaw.ogg");
				SendClientMessage (playerid, -1, "Odtwarzanie: Radio Eska.");
			} // 
			case 3: {
				PlayAudioStreamForPlayer(playerid, "http://poznan6.radio.pionier.net.pl:8000/eska-stream4-1.mp3");
				SendClientMessage (playerid, -1, "Odtwarzanie: Radio Eska - Club.");
			} // 
			case 4: {
				PlayAudioStreamForPlayer(playerid, "http://poznan6.radio.pionier.net.pl:8000/eska-stream13-1.mp3");
				SendClientMessage (playerid, -1, "Odtwarzanie: Radio Eska - Classic Rock.");
			}
			case 5: {
				PlayAudioStreamForPlayer(playerid, "http://91.121.179.221:8050");
				SendClientMessage (playerid, -1, "Odtwarzanie: Radio Zet.");
			}
			case 6: {
				PlayAudioStreamForPlayer(playerid, "http://31.192.216.4:8000/rmf_maxxx");
				SendClientMessage (playerid, -1, "Odtwarzanie: Radio Maxxx.");
			}
			case 7: {
				PlayAudioStreamForPlayer(playerid, "http://195.150.20.243:8000/rmf_fm");
				SendClientMessage (playerid, -1, "Odtwarzanie: RMF FM.");
			}
			case 8: {
				PlayAudioStreamForPlayer(playerid, "http://91.121.164.186:9350");
				SendClientMessage (playerid, -1, "Odtwarzanie: Polska Stacja - Hip-Hop.");
			}
			case 9: {
				PlayAudioStreamForPlayer(playerid, "http://94.23.89.48:7000");
				SendClientMessage (playerid, -1, "Odtwarzanie: Anty Radio.");
			} // 
		}
	}
    if(dialogid == DIALOG_VIP)
    {
        switch(listitem)
        {
        	case 0:
         	{
         		new string[1000];

				strcat(string,"Konto premium (VIP) to ranga specjalna tylko dla wybranych graczy.\n");
				strcat(string,"Dziêki niemu gra jest o wiele prostrza i ciekawsza!\n");
				strcat(string,"Twoje konto jest na 31 DNI mo¿esz je przed³u¿yæ wysy³aj¹c ponownie SMS!\n\n");
				strcat(string,"Aby zakupiæ konto premium udaj siê na www.FullGaming.pl");

				ShowPlayerDialog(playerid,DIALOG_VIP2,0,"Informacje - VIP",string,"OK","Cofnij");
           	}
			case 1:
 			{
 				new string[2000];

				strcat(string,"{FFFFFF}Konto Premium {FFFF00}VIP{FFFFFF}.\n\n");
				strcat(string,"{FFFFFF}- Ranga na chacie {FFFF00}(VIP){FFFFFF}: Kupujcie VIP!\n");
				strcat(string,"{FFFF00}- {FFFFFF}Mozliwosc pisania na srodku ekranu\n");
				strcat(string,"{FFFF00}- {FFFFFF}Teleportowanie siê do innych bez pytania\n");
				strcat(string,"{FFFF00}- {FFFFFF}Dodawanie sobie dowolnej broni wraz z amunicja\n");
				strcat(string,"{FFFF00}- {FFFFFF}Dodawanie sobie nielimitowanej ilosci pieniedzy\n");
				strcat(string,"{FFFF00}- {FFFFFF}Dodawanie innym ograniczana ilosc pieniedzy\n");
				strcat(string,"{FFFF00}- {FFFFFF}Ustawianie dowolnej godziny na serwerze\n");
				strcat(string,"{FFFF00}- {FFFFFF}Szacunek z strony innych\n");
				strcat(string,"{FFFF00}- {FFFFFF}Pisanie na prywatnym czacie Vipow i Adminow\n");
				strcat(string,"{FFFF00}- {FFFFFF}Naprawianie pojazdu dowolnemu graczowi za darmo\n");
				strcat(string,"{FFFF00}- {FFFFFF}Posiadanie wyrozniajacego sie koloru Zoltego\n");
				strcat(string,"{FFFF00}- {FFFFFF}Posiadanie napisu Konto Premium nad nickiem\n");
				strcat(string,"{FFFF00}- {FFFFFF}Uzdrawianie dowolnego gracza za darmo\n");
				strcat(string,"{FFFF00}- {FFFFFF}Dodawanie sobie kamizelki kuloodpornej za darmo\n");
				strcat(string,"{FFFF00}- {FFFFFF}Teleportowanie jednego gracza do drugiego\n\n\n");
				strcat(string,"{FFFF00}_______________________________________________________________\n");
				strcat(string,"{FFFFFF}Jesli jestes zainteresowany posiadaniem konta VIP\n");
				strcat(string,"{FFFF00}Odwiedzaj nasza strone: www.FullGaming.pl");
				strcat(string,ServerUrl);

				ShowPlayerDialog(playerid,DIALOG_VIP2,0,"Mo¿liwoœci - VIP",string,"OK","Cofnij");
 			}
			case 2:
 			{
 				new string[2000];

			    strcat(string,"{FFFF00}/StartEv {FFFFFF}- Startujesz zabawê.\n");
                strcat(string,"{FFFF00}/vGranaty {FFFFFF}- Granaty specjalnie dla VIP.\n");
				strcat(string,"{FFFF00}/Vjetpack {FFFFFF}- Dostajesz plecak odrzutowy (Jetpack).\n");
			    strcat(string,"{FFFF00}/Vdotacja {FFFFFF}- Dotacja w wysokoœci 1 miliona $.\n");
				strcat(string,"{FFFF00}/Vinvisible {FFFFFF}- Niewidzialnoœæ na mapie.\n");
				strcat(string,"{FFFF00}/Ogloszenie {FFFFFF}- Og³oszenie na œrodku ekranu.\n");
				strcat(string,"{FFFF00}/Vpozostalo {FFFFFF}- Wa¿noœæ konta [VIP].\n");
				strcat(string,"{FFFF00}/Vcar [nazwa] {FFFFFF}- Spawnowanie pojazdu poprzez nazwê.\n");
				strcat(string,"{FFFF00}/Vzestaw  {FFFFFF}- Zestaw broni [VIP].\n");
				strcat(string,"{FFFF00}/Vgivecash [id] [kwota] {FFFFFF}- Dodawanie pieniêdzy graczowi.\n");
				strcat(string,"{FFFF00}/Vsettime [godzina] {FFFFFF}- Zmiana godziny na serwerze.\n");
				strcat(string,"{FFFF00}/Vbron [id_broni] [ammo]  {FFFFFF}- Dodawanie dowolnej broni.\n");
				strcat(string,"{FFFF00}/Vlistabroni {FFFFFF}- Lista ID broni.\n");
				strcat(string,"{FFFF00}/Vsay [tekst] {FFFFFF}- Czat [VIP-MSG].\n");
				strcat(string,"{FFFF00}/Pmv [tskst] {FFFFFF}- Prywatny czat Administracji i VIP'ów.\n");
				strcat(string,"{FFFF00}/Vrepair [id]  {FFFFFF}- Naprawa pojazdu dowolnemu graczowi.\n");
				strcat(string,"{FFFF00}/Vcolor {FFFFFF}- Zmiana koloru nicku na ¿ó³ty.\n");
				strcat(string,"{FFFF00}/Vheal [id] {FFFFFF}- Uzdrowienie dowolnego gracza.\n");
				strcat(string,"{FFFF00}/Varmor {FFFFFF}- Natychmiastowa kamizelka.\n");
				strcat(string,"{FFFF00}/VTp [ID:1] [ID:2] {FFFFFF}- Teleport gracza 1 do gracza 2.\n\n");
			    strcat(string,"{FFFF00}/Varmor {FFFFFF}- Natychmiastowa kamizelka.\n");
				strcat(string,"{FFFFFF}________________________________________________________________________\n");
				strcat(string,"{FFFFFF}Zapamiêtaj gdy bêd¹ nadu¿ywane te komendy mo¿e to siê wi¹zaæ z utrat¹ [VIP].");

				ShowPlayerDialog(playerid,DIALOG_VIP2,0,"Komendy - VIP",string,"OK","Cofnij");
 			}
			case 3:
			{
                new string[700];

				strcat(string,"{FFFFFF}Kupno konta premium (VIP)\n\n");
				strcat(string,"{FFFF00}Cena {FFFFFF}- 6 z³ (7,30 z VAT).\n\n");
				strcat(string,"{FFFFFF}Tresæ SMS znajdziesz pod komend¹ /VIP\n\n");
			    strcat(string,"{FFFFFF}Je¿eli wys³a³eœ(aœ) SMS wejdŸ na {FFFF00}www.FullGaming.pl\n");
				strcat(string,"{FFFFFF}Pamiêtaj! W komendzie /VIP treœæ SMS przypisana jest na twój obecny nick na którym jesteœ teraz w grze online!\n\n");
                strcat(string,"{FFFFFF}Gdy wyœlesz SMS konto VIP aktywuje siê na tym nicku w którym w³aœne jesteœ na serwerze.\n\n");
				strcat(string,"Konto premium wa¿ne jest na {FFFF00}31 dni{FFFFFF}. Je¿eli dany termin minie to zakup VIP'a ponownie.\n\n\n");
                strcat(string,"W razie jakich kolwiek problemów/niedogodnoœci prosimy kierowaæ do nas drog¹ mailow¹: bok@FullGaming.pl");

				ShowPlayerDialog(playerid,DIALOG_VIP2,0,"Kupno - VIP",string,"OK","Cofnij");
			}
		}
    }
    if(dialogid == DIALOG_VIP2)
    {
		if(!response)
		{
		    ShowPlayerDialog(playerid,DIALOG_VIP,DIALOG_STYLE_LIST,"Konto premium (VIP)","¤ Informacje\n¤ Mo¿liwoœci konta premium\n¤ Komendy konta premium\n¤ Kupno konta VIP","Wybierz","Anuluj");
		}
    }
    if(dialogid == DIALOG_MOD)
    {
		if(response)
		{
		    new string[1000];

			strcat(string,"{28DC28}/Armorall {FFFFFF}- Dajesz armor wszystkim.\n");
		    strcat(string,"{28DC28}/Mgod {FFFFFF}- Dajesz sobie goda.\n");
			strcat(string,"{28DC28}/Jail {FFFFFF}- wiêzisz gracza.\n");
            strcat(string,"{28DC28}/DelPodkowa {FFFFFF}- usuwasz podkowê.\n");
			strcat(string,"{28DC28}/UnJail {FFFFFF}- wiêzisz gracza.\n");
			strcat(string,"{28DC28}/Killp {FFFFFF}- zabijasz gracza.\n");
			strcat(string,"{28DC28}/AcolorVeh {FFFFFF}- zmieniasz kolor pojazdu.\n");
		    strcat(string,"{28DC28}/Kick {FFFFFF}- kickujesz gracza.\n");
			strcat(string,"To dopiero pocz¹tek mo¿liwoœci moderatora.\n\n");
			strcat(string,"___________________________________\n");
			strcat(string,"Pamietaj jednak ze naduzycia zwiazane z tymi komendami\n");
			strcat(string,"moga sie wiazac z odebraniem ci rangi MODERATOR!");
		
		    ShowPlayerDialog(playerid,DIALOG_MOD2,0,"Komendy Moderatora",string,"Cofnij","Wyjdz");
		}
    }
    if(dialogid == DIALOG_MOD2)
    {
		if(response)
		{
		    new string[2000];

		    strcat(string,"{28DC28}/Podkowa {FFFFFF}- Gubisz gdzieœ podkowê.\n");
			strcat(string,"{28DC28}/Jetpack {FFFFFF}- Dajesz wybranemu graczu plecak odrzutowy (Jetpack).\n");
		    strcat(string,"{28DC28}/AnnColor {FFFFFF}- Lista dostêpnych kolorów tekstu /ann.\n");
		    strcat(string,"{28DC28}/StartEv {FFFFFF}- Start Zabawy.\n");
			strcat(string,"{28DC28}/StartVote {FFFFFF}- G³osowanie.\n");
		    strcat(string,"{28DC28}/Respawn ID {FFFFFF}- Respawnujesz gracza.\n");
			strcat(string,"{28DC28}/StopVote {FFFFFF}- Stop glosowania.\n");
			strcat(string,"{28DC28}/RspAuta {FFFFFF}- Respawnujesz pojazdy.\n");
		    strcat(string,"{28DC28}/CS [sekundy] {FFFFFF}- Odliczanie.\n");
			strcat(string,"{28DC28}/Invisible {FFFFFF}- Jesteœ niewidzialny na mapie.\n");
			strcat(string,"{28DC28}/Ann {FFFFFF}- Piszesz na œrodku ekranu.\n");
			strcat(string,"{28DC28}/Mpozostalo {FFFFFF}- Wa¿noœæ konta premium [Moderator].\n");
			strcat(string,"{28DC28}/Cars {FFFFFF}- Lista pojazdow do spawnowania.\n");
			strcat(string,"{28DC28}/P [nazwa] {FFFFFF}- Spawnujesz dowolny pojazd podajac jego nazwe.\n");
			strcat(string,"{28DC28}/Givecash [id] [kwota] {FFFFFF}- Dajesz wybranemu graczowi kase.\n");
			strcat(string,"{28DC28}/Settime [godzina] {FFFFFF}- Ustawiasz godzine na serwerze.\n");
			strcat(string,"{28DC28}/Givegun {FFFFFF}- Dajesz broñ graczom.\n");
			strcat(string,"{28DC28}/Weaponlist {FFFFFF}- Lista broni.\n");
			strcat(string,"{28DC28}/Msay [tekst] {FFFFFF}- Piszesz na czacie jako MOD-MSG.\n");
			strcat(string,"{28DC28}/Pmv [tskst] {FFFFFF}- Piszesz na prywatnym czacie Adminow Vipow i Moderatorow.\n");
			strcat(string,"{28DC28}/Repair [id]  {FFFFFF}- Naprawiasz graczowi pojazd.\n");
			strcat(string,"{28DC28}/Mcolor {FFFFFF}- Dajesz sobie zielony kolor moderatora.\n");
			strcat(string,"{28DC28}/Heal [id] {FFFFFF}- Uzdrawiasz gracza.\n");
			strcat(string,"{28DC28}/Armorid {FFFFFF}- Dajesz kamizelke.\n");
		    strcat(string,"{28DC28}/TP {FFFFFF}- Teleportujesz.\n");
			strcat(string,"* Wiêcej komend moderatora pod /Mpomoc2\n\n");
			strcat(string,"___________________________________\n");
			strcat(string,"Pamietaj jednak ze naduzycia zwiazane z tymi komendami\n");
			strcat(string,"moga sie wiazac z odebraniem ci rangi MODERATOR!");

			ShowPlayerDialog(playerid,DIALOG_MOD,0,"Komendy Moderatora",string,"Dalej","Wyjdz");
		  
		}
    }
	if(dialogid == DIALOG_ACMD)
    {
		if(response)
		{
			new StrinG[2500];

			StrinG = "{FF0000}/Walizka - Stawiasz walizkê\n";
		    strcat(StrinG,"{FF0000}/Podkowa {FFFFFF}- Stawiasz podkowê\n");
			strcat(StrinG,"{FF0000}/GiveGun [ID] [ID Broni] {FFFFFF}- Dajesz broñ\n");
		    strcat(StrinG,"{FF0000}/Granaty {FFFFFF}- Dajesz wszystkim granaty\n");
		    strcat(StrinG,"{FF0000}/Combat {FFFFFF}- Dajesz wszystkim combat shotgun\n");
		    strcat(StrinG,"{FF0000}/Tec {FFFFFF}- Dajesz wszystkim TEC-9\n");
		    strcat(StrinG,"{FF0000}/Sniper {FFFFFF}- Dajesz wszystkim Sniper-Rifle\n");
		    strcat(StrinG,"{FF0000}/M4 {FFFFFF}- Dajesz wszystkim M4\n");
		    strcat(StrinG,"{FF0000}/Shotgun {FFFFFF}- Dajesz wszystkim shotguna\n");
		    strcat(StrinG,"{FF0000}/MP5 {FFFFFF}- Dajesz wszystkim MP5\n");
		    strcat(StrinG,"{FF0000}/SO {FFFFFF}- Dajesz wszystkim Sawn-Off-Shotgun\n");
		    strcat(StrinG,"{FF0000}/DE {FFFFFF}- Dajesz wszystkim Desert-Eagle\n");
		    strcat(StrinG,"{FF0000}/Heal50 {FFFFFF}- Uzdrawiasz graczy w promieniu 50 metrów\n");
		    strcat(StrinG,"{FF0000}/Armor50 {FFFFFF}- Dajesz pancerz graczom w promieniu 50 metrów\n");
		    strcat(StrinG,"{FF0000}/Crate /UnCrate {FFFFFF}- Kratowanie gracza\n");
		    strcat(StrinG,"{FF0000}/Respawn [ID] {FFFFFF}- Respawnujesz gracza\n");
			strcat(StrinG,"{FF0000}/SetIp {FFFFFF}- Zmieniasz interior gracza\n");
		    strcat(StrinG,"{FF0000}/SetWorld {FFFFFF}- Zmieniasz Virtual-World gracza\n");
      		strcat(StrinG,"{FF0000}/SkinP [ID] [ID Skina] {FFFFFF}- Zmieniasz skina wybranemu ID\n");
		    strcat(StrinG,"{FF0000}/God [ID] {FFFFFF}- Dajesz goda\n");
		    strcat(StrinG,"{FF0000}/ArmourGod [ID] {FFFFFF}- Nieskoñczona kamizelka\n");
		    strcat(StrinG,"{FF0000}/VehGod [ID] {FFFFFF}- Niezniszczalny pojazd\n");
		    strcat(StrinG,"{FF0000}/JetPack [ID] {FFFFFF}- Dajesz jetpacka\n");
		    strcat(StrinG,"{FF0000}/killp [ID] {FFFFFF}- Zabijasz gracza\n");
			strcat(StrinG,"{FF0000}/DA50 {FFFFFF}- Rozbrajasz graczy w promieniu 50 metrów\n");
			strcat(StrinG,"{FF0000}/Disarm [ID] {FFFFFF}- Rozbrajasz gracza");

			ShowPlayerDialog(playerid,DIALOG_ACMD2,0,"Komendy administracji",StrinG,"OK","Cofnij");
		}
    }
    if(dialogid == DIALOG_ACMD2)
    {
		if(!response)
		{
			new StrinG[3000];

			StrinG = "{FF0000}/CZ - czyscisz caly czat\n";
		    strcat(StrinG,"{FF0000}/Say [tekst] {FFFFFF}- Piszesz informacjê na chacie >>> tekst\n");
		    strcat(StrinG,"{FF0000}/TP [ID:1] [ID:2] {FFFFFF}- Teleportujesz id 1 do id 2\n");
		    strcat(StrinG,"{FF0000}/SetTime [Godzina] {FFFFFF}- Zmieniasz czas na serwerze\n");
		    strcat(StrinG,"{FF0000}/AColor [ID] [ID] {FFFFFF}- Zmieniasz kolor nicku gracza\n");
		    strcat(StrinG,"{FF0000}/Info [ID] {FFFFFF}- Sprawdzasz IP gracza\n");
		    strcat(StrinG,"{FF0000}/P [Nazwa] {FFFFFF}- Spawnujesz pojazd na sta³e\n");
			strcat(StrinG,"{FF0000}/Weather [ID] {FFFFFF}- Zmieniasz pogodê na serwerze\n");
		    strcat(StrinG,"{FF0000}/A [tekst] {FFFFFF}- piszesz na Admin Chacie\n");
		    strcat(StrinG,"{FF0000}/Raports {FFFFFF}- Sprawdzasz zg³oszone raporty\n");
		    strcat(StrinG,"{FF0000}/GiveCash [kasa] {FFFFFF}- Dajesz kasê\n");
		    strcat(StrinG,"{FF0000}/GiveScore [respekt] {FFFFFF}- dajesz respekt\n");
			strcat(StrinG,"{FF0000}/Bomby [on/off] {FFFFFF}- wlaczasz lib wylaczasz mo¿liwoœæ podkladania bomb\n");
		 	strcat(StrinG,"{FF0000}/Freeze50 {FFFFFF}- Zamra¿asz graczy w promieniu 50 metrów.\n");
			strcat(StrinG,"{FF0000}/UnFreeze50 {FFFFFF}- Odmra¿asz graczy w promieniu 50 metrów.\n");
			strcat(StrinG,"{FF0000}/JoinInfo(on/off) {FFFFFF}- wlaczasz/wylaczasz informacje o wchodzeniu graczy\n");
			strcat(StrinG,"{FF0000}/JoinInfoAdmin(on/off) {FFFFFF}- wlaczasz/wylaczasz info o wchodzeniu graczy dla adminow\n");
			strcat(StrinG,"{FF0000}/TT [id_gracza] {FFFFFF}- teleportujesz sie do gracza\n");
			strcat(StrinG,"{FF0000}/TH [id_gracza] {FFFFFF}- teleportujesz gracza do siebie\n");
			strcat(StrinG,"{FF0000}/LockAll {FFFFFF}- zamykasz wszystkie pojazdy\n");
			strcat(StrinG,"{FF0000}/UnLockAll {FFFFFF}- otwierasz wszystkie pojazdy\n");
			strcat(StrinG,"{FF0000}/RspAuta {FFFFFF}- respawn wszystkich pojazdow\n");
			strcat(StrinG,"{FF0000}/RspTrailers {FFFFFF}- respawn wszystkich przyczep\n");
			strcat(StrinG,"{FF0000}/DelTrailers {FFFFFF}- usuwasz stworzone naczepy\n");
			strcat(StrinG,"{FF0000}/DelCar {FFFFFF}- usuwasz pojazd w ktorym jestes\n");
			strcat(StrinG,"{FF0000}/Prot/UnProt [id] {FFFFFF}- dajesz/odbierasz immunitet graczowi \n");
			strcat(StrinG,"{FF0000}/Cenz /Uncenz [id] {FFFFFF}- cenzurujesz/odcenzurowujesz gracza\n");
			strcat(StrinG,"{FF0000}/Spec /Specoff [id] {FFFFFF}- ogladasz/przestajesz ogladac gracza\n");
			strcat(StrinG,"{FF0000}/SVall {FFFFFF}- zapisujesz wszystkim staty\n");
			strcat(StrinG,"{FF0000}/jail [id] [czas]   /UnWiez [id] {FFFFFF}- dajesz/wyciagasz gracza z wiezienia\n");
			strcat(StrinG,"{FF0000}/Mute [id] [czas]   /UnMute [id] {FFFFFF}- uciszasz/odciszasz gracza\n");
			strcat(StrinG,"{FF0000}/Kick [id] [powod] {FFFFFF}- wywalasz gracza z serwa\n");
			strcat(StrinG,"{FF0000}/Ban [id] [powod] {FFFFFF}- banujesz gracza\n");
			strcat(StrinG,"{FF0000}/Explode [id] {FFFFFF}- wysadzasz gracza \n");
			strcat(StrinG,"{FF0000}/Remove [ID] {FFFFFF}- wywalasz gracza z pojazdu\n");
			strcat(StrinG,"{FF0000}/PodgladPM(on/off) {FFFFFF}- wlaczasz/wylaczasz podglad prywatnych wiadomosci");

			ShowPlayerDialog(playerid,DIALOG_ACMD,0,"Komendy administracji",StrinG,"DALEJ","Anuluj");
		}
    }
	if(dialogid == weaponmodels)
    {
        switch(listitem)
        {
        	case 0:
         	{
         		RemovePlayerAttachedObject(playerid,0);
         		SetPlayerAttachedObject(playerid, 0, 2044, 6, 0.100000, 0.000000, 0.000000, -90.000000, 0.000000, 180.000000, 2.500000, 3.20000, 5.00000 ); // CJ_MP5K - Replaces MP5
         		GivePlayerWeapon(playerid, 29, 500);
           	}
			case 1:
 			{
 				RemovePlayerAttachedObject(playerid,0);
 				SetPlayerAttachedObject(playerid, 0, 2045, 6, 0.039999, 0.000000, 0.250000, 90.000000, 0.000000, 0.000000, 3.800000, 1.300000, 3.800000 ); // CJ_BBAT_NAILS - Replaces Bat
 				GivePlayerWeapon(playerid, 5, 500);
 			}
			case 2:
 			{
 				RemovePlayerAttachedObject(playerid,0);
 				SetPlayerAttachedObject(playerid, 0, 2036, 6, 0.300000, 0.0000000, 0.020000, 90.000000, 358.000000, 0.000000, 1.000000,1.90000, 3.000000 ); // CJ_psg1 - Replaces ak47
 				GivePlayerWeapon(playerid, 30, 500);
 			}
 			case 3:
    		{
 				RemovePlayerAttachedObject(playerid,0);
 				SetPlayerAttachedObject(playerid, 0, 2976, 6, -0.100000, 0.000000, 0.100000, 0.000000, 80.000000, 0.000000, 1.000000, 1.000000, 1.500000 ); // green_gloop - Replaces Spas
 				GivePlayerWeapon(playerid, 27, 500);
     		}
      	}
    }

	if(dialogid == DIALOG_VANN && response)
	{
	    if(strlen(inputtext) < 1 || strlen(inputtext) > 80)
	    {
	        SendClientMessage(playerid, COLOR_ERROR, "  * Niepoprawna d³ugoœæ og³oszenia.");
	        return 1;
	    }

		if(VipAnnTime > 0)
		{
		    SendClientMessage(playerid, COLOR_ERROR, "  * Poczekaj chwile, a¿ aktualne og³oszenie zniknie.");
		    return 1;
		}

		for(new Char = 0; Char < strlen(inputtext); Char++)
		{
		    if(inputtext[Char] == '~')
		    {
			    SendClientMessage(playerid, COLOR_ERROR, "  * Og³oszenie nie mo¿e zawieraæ znaku tyldy - \"~\".");
			    return 1;
		    }
		}

		new String[255];
		format(String, sizeof(String), "~n~~y~%s (%d): ~w~%s", PlayerName(playerid), playerid, inputtext);
		TextDrawSetString(tdVipAnn[1], String);
		TextDrawShowForAll(tdVipAnn[0]);
		TextDrawShowForAll(tdVipAnn[1]);
        TextDrawShowForAll(VannBox);
		VipAnnTime = 30;
	    //Player[playerid][Exp] -= 20;
	    Player[playerid][VAnn] = 5*60;
		//SavePlayer(playerid);
		//UpdatePlayerScore(playerid);
		return 1;
	}

	if(dialogid == DIALOG_WINDALV)
    {
        switch(listitem)
        {
            case 0:
            {
            	MoveObject(WindaLV, 2180.48, 1029.68, 80.00,4);
            	SendClientMessage(playerid,COLOR_GREEN," * Winda jedzie w górê.");
			}
			case 1:
   			{
   				MoveObject(WindaLV, 2180.48, 1029.68, 11.30,4);
   				SendClientMessage(playerid,COLOR_GREEN," * Winda jedzie w dó³.");
			}
  		}
    }

    if(dialogid == DIALOG_FIVE_ONE)
    {
        switch(listitem)
        {
            case 0:
            {
            	MoveObject(FiveOne, 2681.86, 644.39, 10.45,4);
                MoveObject(FiveTwo, 2681.87, 653.39, 10.45,4);
				SendClientMessage(playerid,COLOR_GREEN," * Brama otwarta.");
			}
			case 1:
   			{
   				MoveObject(FiveOne, 2681.86, 644.39, 5.00,4);
                MoveObject(FiveTwo, 2681.87, 653.39, 5.00,4);
   				SendClientMessage(playerid,COLOR_GREEN," * Brama zamkniêta.");
			}
  		}
    }

    if(dialogid == DIALOG_FIVE_TWO)
    {
        switch(listitem)
        {
            case 0:
            {
            	MoveObject(FiveOneTwo, 2733.03, 665.64, 10.41,4);
                MoveObject(FiveTwoTwo, 2733.03, 665.64, 10.41,4);
				SendClientMessage(playerid,COLOR_GREEN," * Brama otwarta.");
			}
			case 1:
   			{
   				MoveObject(FiveOneTwo, 2733.03, 665.64, 5.00,4);
                MoveObject(FiveTwoTwo, 2733.03, 665.64, 5.00,4);
   				SendClientMessage(playerid,COLOR_GREEN," * Brama zamkniêta.");
			}
  		}
    }

    if(dialogid == DIALOG_WINDALV)
    {
        switch(listitem)
        {
            case 0:
            {
            	MoveObject(WindaLV, 2180.48, 1029.68, 80.00,4);
            	SendClientMessage(playerid,COLOR_GREEN," * Winda jedzie w górê.");
			}
			case 1:
   			{
   				MoveObject(WindaLV, 2180.48, 1029.68, 11.30,4);
   				SendClientMessage(playerid,COLOR_GREEN," * Winda jedzie w dó³.");
			}
  		}
    }

	if(dialogid == DIALOG_LOTERIA_VIP)
    {
        switch(listitem)
        {
            case 0:
            {
                if(!IsVIP(playerid) && !IsAdmin(playerid,1)) return SendClientMessage(playerid,COLOR_RED2," * Nie posiadasz uprawnieñ!");
				LosowankoVIP(playerid);
            }
			case 1:
   			{
   				Losowanko(playerid);
   			}
        }
    }

	if(dialogid == DIALOG_LOTERIA)
    {
        switch(listitem)
        {
            case 0:
            {
            	Losowanko(playerid);
            }
        }
    }

	if(dialogid == 1020)
	{
	    if(response == 1)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
	                SetPlayerPos(playerid, 1262.5927,-2057.0884,59.3713);
					SendClientMessage(playerid, COLOR_ORANGE,"[BBT] Bad Boys Team");
	            }
	            case 1:
	            {
	                SendClientMessage(playerid, COLOR_ORANGE," * Ta funkcja jest chwilowo niedostêpna");
	            }
	            case 2:
	            {
	                SendClientMessage(playerid, COLOR_ORANGE," * Ta funkcja jest chwilowo niedostêpna");
				}
				case 3:
				{
				    SendClientMessage(playerid, COLOR_ORANGE," * Ta funkcja jest chwilowo niedostêpna");
				}
			}
		}
	}

/*	if(dialogid == DIALOG_HUD)
	{
	    if(response == 1)
	    {
	        switch(listitem)
	        {
	            case 0:
	            {
					TextDrawColor(Sprite0[playerid],57);
                 //   TextDrawColor(Sprite1[playerid],54);
					TextDrawShowForPlayer(playerid, Sprite0[playerid]);
    				//TextDrawShowForPlayer(playerid, Sprite1[playerid]);
				}
	            case 1:
	            {
                    TextDrawColor(Sprite0[playerid],0xECFF6E44);
                   // TextDrawColor(Sprite1[playerid],0xECFF6E44);
					TextDrawShowForPlayer(playerid, Sprite0[playerid]);
    				//TextDrawShowForPlayer(playerid, Sprite1[playerid]);
				}
	            case 2:
	            {
                    TextDrawColor(Sprite0[playerid],0xFF141444);
                 //   TextDrawColor(Sprite1[playerid],0xFF141444);
					TextDrawShowForPlayer(playerid, Sprite0[playerid]);
    			//	TextDrawShowForPlayer(playerid, Sprite1[playerid]);
				}
				case 3:
				{
                    TextDrawColor(Sprite0[playerid],0x14FF3F44);
                //    TextDrawColor(Sprite1[playerid],0x14FF3F44);
					TextDrawShowForPlayer(playerid, Sprite0[playerid]);
    			//	TextDrawShowForPlayer(playerid, Sprite1[playerid]);
				}
				case 4:
				{
                    TextDrawColor(Sprite0[playerid],0xFF660044);
                //    TextDrawColor(Sprite1[playerid],0xFF660044);
					TextDrawShowForPlayer(playerid, Sprite0[playerid]);
    			//	TextDrawShowForPlayer(playerid, Sprite1[playerid]);
				}
                case 5:
				{
                    TextDrawColor(Sprite0[playerid],0xFF00D044);
                 //   TextDrawColor(Sprite1[playerid],0xFF00D044);
					TextDrawShowForPlayer(playerid, Sprite0[playerid]);
    			//	TextDrawShowForPlayer(playerid, Sprite1[playerid]);
				}
				case 6:
				{
     				TextDrawColor(Sprite0[playerid],0xBA823844);
                 //   TextDrawColor(Sprite1[playerid],0xBA823844);
					TextDrawShowForPlayer(playerid, Sprite0[playerid]);
    			//	TextDrawShowForPlayer(playerid, Sprite1[playerid]);
				}
			}
		}
	}
*/
	if(dialogid == 878)
	{
		if(response)
		{
			if(listitem==0)
			{
				DestroyObject(neon[GetPlayerVehicleID(playerid)][0]);
				DestroyObject(neon[GetPlayerVehicleID(playerid)][1]);
				neon[GetPlayerVehicleID(playerid)][0] = CreateObject(18647,0,0,0,0,0,0,100.0);
				neon[GetPlayerVehicleID(playerid)][1] = CreateObject(18647,0,0,0,0,0,0,100.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				SendClientMessage(playerid, 0xFFFFFFAA, " * Neon Czerwony Zainstalowany ");
			}
			if(listitem==1)
			{
				DestroyObject(neon[GetPlayerVehicleID(playerid)][0]);
				DestroyObject(neon[GetPlayerVehicleID(playerid)][1]);
				neon[GetPlayerVehicleID(playerid)][0] = CreateObject(18648,0,0,0,0,0,0,100.0);
				neon[GetPlayerVehicleID(playerid)][1] = CreateObject(18648,0,0,0,0,0,0,100.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				SendClientMessage(playerid, 0xFFFFFFAA, " * Neon Siwy Zainstalowany ");
			}
			if(listitem==2)
			{
				DestroyObject(neon[GetPlayerVehicleID(playerid)][0]);
				DestroyObject(neon[GetPlayerVehicleID(playerid)][1]);
				neon[GetPlayerVehicleID(playerid)][0] = CreateObject(18649,0,0,0,0,0,0,100.0);
				neon[GetPlayerVehicleID(playerid)][1] = CreateObject(18649,0,0,0,0,0,0,100.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				SendClientMessage(playerid, 0xFFFFFFAA, " * Neon Zielony Zainstalowany ");
			}
			if(listitem==3)
			{
				DestroyObject(neon[GetPlayerVehicleID(playerid)][0]);
				DestroyObject(neon[GetPlayerVehicleID(playerid)][1]);
				neon[GetPlayerVehicleID(playerid)][0] = CreateObject(18650,0,0,0,0,0,0,100.0);
				neon[GetPlayerVehicleID(playerid)][1] = CreateObject(18650,0,0,0,0,0,0,100.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				SendClientMessage(playerid, 0xFFFFFFAA, " * Neon ¯ó³ty Zainstalowany ");
			}
			if(listitem==4)
			{
				DestroyObject(neon[GetPlayerVehicleID(playerid)][0]);
				DestroyObject(neon[GetPlayerVehicleID(playerid)][1]);
				neon[GetPlayerVehicleID(playerid)][0] = CreateObject(18651,0,0,0,0,0,0,100.0);
				neon[GetPlayerVehicleID(playerid)][1] = CreateObject(18651,0,0,0,0,0,0,100.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				SendClientMessage(playerid, 0xFFFFFFAA, " * Neon Ró¿owy Zainstalowany ");
			}
			if(listitem==5)
			{
				DestroyObject(neon[GetPlayerVehicleID(playerid)][0]);
				DestroyObject(neon[GetPlayerVehicleID(playerid)][1]);
				neon[GetPlayerVehicleID(playerid)][0] = CreateObject(18652,0,0,0,0,0,0,100.0);
				neon[GetPlayerVehicleID(playerid)][1] = CreateObject(18652,0,0,0,0,0,0,100.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][0], GetPlayerVehicleID(playerid), -0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				AttachObjectToVehicle(neon[GetPlayerVehicleID(playerid)][1], GetPlayerVehicleID(playerid), 0.8, 0.0, -0.70, 0.0, 0.0, 0.0);
				SendClientMessage(playerid, 0xFFFFFFAA, " * Neon Bia³y Zainstalowany ");
			}
			if(listitem==6)
			{
				DestroyObject(neon[GetPlayerVehicleID(playerid)][0]);
				DestroyObject(neon[GetPlayerVehicleID(playerid)][1]);
                SendClientMessage(playerid, 0xFFFFFFAA, " * Neony usuniête! ");
			}
		}
		return 1;
	}

	if(dialogid == DIALOG_TP) {
	    
		new playertp = 0;
		foreachPly (i) {
			if (GetPVarInt (i, #teleport.tpto) == playerid) {
				playertp = i;
				DeletePVar (playertp, #teleport.tpto);
				break;
			}
		}
		
		if (response) {
			TeleportPlayerToPlayer (playertp, playerid);
			SendClientMessage(playertp, COLOR_GREEN, "  * Gracz zaakceptowa³ zaproszenie.");
	    }
	    else {
	        SendClientMessage(playertp, COLOR_ERROR, "  * Gracz odrzuci³ zaproszenie.");
	    }
	    return 1;
	}
	
	if(dialogid == DIALOG_REPORT && response)
	{
        new PlayerId = Player[playerid][ClickedPlayer];

		if(RaportBlock[playerid]){
	    SendClientMessage(playerid,COLOR_RED2,"Mo¿esz wysy³aæ raport co 1 min.");

		return 1;
	}

	if( PlayerId < 0 || PlayerId >= MAX_GRACZY) return SendClientMessage(playerid, COLOR_RED, "Zle ID gracza");
	if(!IsPlayerConnected(PlayerId)) return SendClientMessage(playerid, COLOR_RED, "Nie ma takiego gracza");

	if(strlen(inputtext) >= 32){
	    SendClientMessage(playerid,COLOR_RED2,"Powód mo¿e mieæ max. 30 znaków!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	if(!IsValidDescription(inputtext))
	{
		SendClientMessage(playerid, COLOR_RED2, "Raport zawiera niepoprawne znaki!");
		ShowPlayerDialog(playerid, DIALOG_REPORT, DIALOG_STYLE_INPUT, "Raportuj gracza", "Wpisz treœæ raportu:", "Wyœlij", "Anuluj");
		return 1;
	}

	new bool:ret;
	for(new x=0;x<10;x++){
		if(RaportID[x] == PlayerId){
		    SendClientMessage(playerid,COLOR_RED2,"Ten gracz ju¿ zosta³ zg³oszony administracji!");
            PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
			ret = true;
			break;
		}
	}

	if(ret) return 1;

	RaportBlock[playerid] = true;
	SetTimerEx("RaportUnlock",60000,0,"i",playerid);

	SendClientMessage(playerid, COLOR_GREEN, "Raport zosta³ wys³any!");
	new tmp[64];
	format(tmp,sizeof(tmp),"%s (%d) przysy³a raport! SprawdŸ /Reports",PlayerName(playerid),playerid);

	RaportCD ++;
	if(RaportCD >= 10) RaportCD = 0;

	format(Raport[RaportCD],32,"%s",inputtext);
	RaportID[RaportCD] = PlayerId;

	foreachPly (x) {
		if(IsAdmin(playerid,2)){
			PlayerPlaySound(x, 1147, 0, 0, 0);
			SendClientMessage(x,COLOR_LIGHTRED,tmp);
			GameTextForPlayer(x, "~g~~h~Raport!", 2000, 1);
		}
	}
		Player[playerid][ClickedPlayer] = -1;
		return 1;
	}

	if(dialogid == DIALOG_PLAYER && response)
	{
        new PlayerId = Player[playerid][ClickedPlayer];
		if(listitem == 0) {
			if (IdzdoBlock[playerid]) {
				SendClientMessage(playerid,COLOR_RED2,"Mo¿esz tego u¿ywaæ co 15 sek!");
				return 1;
			}
			
			SendPlayerRequestToTeleport (playerid, PlayerId);
			Player[playerid][ClickedPlayer] = -1;
	    }
	    else if(listitem == 1)
	    {
			new IsVip[20];

			if(!IsVIP(PlayerId))
				format(IsVip, sizeof(IsVip), " ");
			else
				format(IsVip, sizeof(IsVip), "{FFFF00}ViP");

			if (logged[PlayerId]) {
				
			new Title[255], String[400];
			format(Title, sizeof(Title), "Statystyki gracza %s (id %d):", PlayerName(PlayerId), PlayerId);
			format(String, sizeof(String), "{959595}Zabitych: {FFFFFF}%d\n{959595}Zabitych pod rz¹d: {FFFFFF}%d\n{959595}Œmierci: {FFFFFF}%d\n{959595}Samobójstw: {FFFFFF}%d\n{959595}Pieni¹dze w kieszeni: {FFFFFF}%d\n{959595}Nagroda za g³owê: {FFFFFF}%d\n{959595}Exp: {FFFFFF}%d\n\n%s", kills[PlayerId], killsinarow[PlayerId], deaths[PlayerId], suicides[PlayerId], Money[PlayerId], bounty[PlayerId], Respekt[PlayerId], IsVip);
			ShowPlayerDialog(playerid, 865, DIALOG_STYLE_MSGBOX, Title, String, "Zamknij", "Zamknij");
			}else{
			SendClientMessage(playerid,COLOR_RED2,"Ten gracz nie jest zalogowany!");
			}
			Player[playerid][ClickedPlayer] = -1;
	    	}
	    else if(listitem == 2)
	    {
			ShowPlayerDialog(playerid, DIALOG_REPORT, DIALOG_STYLE_INPUT, "Raportuj gracza", "Wpisz treœæ raportu:", "Wyœlij", "Anuluj");
	    }
		return 1;
	}

	if(dialogid == VEHICLE_CONTROL_DIALOG && response)
	{
		switch(listitem)
		{
			case 0: ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+100, DIALOG_STYLE_MSGBOX, "Silnik", "W³¹cz lub wy³¹cz silnik", "Odpal", "Zgas");
			case 1: ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+200, DIALOG_STYLE_MSGBOX, "Œwiat³a", "W³¹cz lub wy³¹cz œwiat³a.\n\nUwaga: Œwiat³a s¹ widoczne tylko w nocy.", "Wlacz", "Wylacz");
			case 2: ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+300, DIALOG_STYLE_MSGBOX, "Alarm", "W³¹cz lub wy³¹cz alarm.\n\nUwaga: Alarm nie wy³¹cza siê sam,\nMusisz go wy³¹czyæ manualnie.", "Wlacz", "Wylacz");
			case 3: ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+400, DIALOG_STYLE_MSGBOX, "Otwieranie drzwi", "Otwórz lub zamknij drzwi.\n\nUwaga: Tylko ty mo¿esz wejœæ do pojazdu gdy jest zamkniêty.\nJednak zostaje zamkniêty do innych.", "Otworz", "Zamknij");
			case 4: ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+500, DIALOG_STYLE_MSGBOX, "Maska", "Otwórz lub zamknij maskê.", "Otworz", "Zamknij");
			case 5: ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+600, DIALOG_STYLE_MSGBOX, "Baga¿nik", "Otwórz lub zamknij baga¿nik.", "Otworz", "Zamknij");
			case 6: ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+700, DIALOG_STYLE_INPUT, "Tablica rejestracyjna", "Wpisz tekst który ma siê pokazaæ na Tablicy Rejestracyjnej:\n\n(Minimun: 1 znak | Maximum: 8 znakow)", "Wpisz", "Anuluj");
		}
		return 1;
	}
	if(dialogid == VEHICLE_CONTROL_DIALOG+100)
	{
		if(response)
		{
		    SendClientMessage(playerid, 0x08FD04FF, " * Uruchomi³eœ(aœ) silnik pojazdu.");
           	GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
            SetVehicleParamsEx(GetPlayerVehicleID(playerid), 1, lights, alarm, doors, bonnet, boot, objective);
		}
		if(!response)
		{
			SendClientMessage(playerid, 0x08FD04FF, " * Zgasi³eœ(aœ) silnik pojazdu.");
			GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
  			SetVehicleParamsEx(GetPlayerVehicleID(playerid), 0, lights, alarm, doors, bonnet, boot, objective);
		}
		#if defined AUTO_REOPEN_DIALOG
		ShowVehicleControlDialog(playerid);
		#endif
		return 1;
	}
	if(dialogid == VEHICLE_CONTROL_DIALOG+200)
	{
  		if(response)
		{
      		SendClientMessage(playerid, 0x08FD04FF, " * Œwiat³a pojazdu w³¹czone.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, 1, alarm, doors, bonnet, boot, objective);
		}
		if(!response)
		{
			SendClientMessage(playerid, 0x08FD04FF, " * Œwiat³a pojazdu wy³¹czone.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, 0, alarm, doors, bonnet, boot, objective);
		}
		#if defined AUTO_REOPEN_DIALOG
		ShowVehicleControlDialog(playerid);
		#endif
		return 1;
	}
	if(dialogid == VEHICLE_CONTROL_DIALOG+300)
	{
  		if(response)
		{
		    SendClientMessage(playerid, 0x08FD04FF, " * Alarm zosta³ w³¹czony.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, 1, doors, bonnet, boot, objective);
  		}
		if(!response)
		{
			SendClientMessage(playerid, 0x08FD04FF, " * Alarm zosta³ wy³¹czony.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, 0, doors, bonnet, boot, objective);
		}
		#if defined AUTO_REOPEN_DIALOG
		ShowVehicleControlDialog(playerid);
		#endif
		return 1;
	}
	if(dialogid == VEHICLE_CONTROL_DIALOG+400)
	{
  		if(response)
		{
		    SendClientMessage(playerid, 0x08FD04FF, " * Drzwi pojazdu zosta³y otworzone.");
		}
		if(!response)
		{
			SendClientMessage(playerid, 0x08FD04FF, " * Drzwi pojazdu zosta³y zamkniête.");
		}
		#if defined AUTO_REOPEN_DIALOG
		ShowVehicleControlDialog(playerid);
		#endif
		return 0;
	}
	if(dialogid == VEHICLE_CONTROL_DIALOG+500)
	{
  		if(response)
		{
		    SendClientMessage(playerid, 0x08FD04FF, " * Maska pojazdu zosta³a otwarta.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, 1, boot, objective);
		}
		if(!response)
		{
			SendClientMessage(playerid, 0x08FD04FF, " * Maska pojazdu zosta³a zamkniêta.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, 0, boot, objective);
		}
		#if defined AUTO_REOPEN_DIALOG
		ShowVehicleControlDialog(playerid);
		#endif
		return 1;
	}
	if(dialogid == VEHICLE_CONTROL_DIALOG+600)
	{
  		if(response)
		{
		    SendClientMessage(playerid, 0x08FD04FF, " * Baga¿nik zosta³ otwarty.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, 1, objective);
		}
		if(!response)
		{
			SendClientMessage(playerid, 0x08FD04FF, " * Baga¿nik zosta³ zamkniêty.");
		    GetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, boot, objective);
			SetVehicleParamsEx(GetPlayerVehicleID(playerid), engine, lights, alarm, doors, bonnet, 0, objective);
		}
		#if defined AUTO_REOPEN_DIALOG
		ShowVehicleControlDialog(playerid);
		#endif
		return 0;
	}
	if(dialogid == VEHICLE_CONTROL_DIALOG+700)
	{
        if(!IsValidDescription(inputtext))
		{
		SendClientMessage(playerid, COLOR_RED2, "Tablica niemo¿e posiadaæ znaków specjalnych!");
		ShowPlayerDialog(playerid, VEHICLE_CONTROL_DIALOG+700, DIALOG_STYLE_INPUT, "Tablica rejestracyjna", "Wpisz tekst który ma siê pokazaæ na Tablicy Rejestracyjnej:\n\n(Minimun: 1 znak | Maximum: 8 znakow)", "Wpisz", "Anuluj");
		return 1;
		}

		new string[128], Float:X, Float:Y, Float:Z, Float:angle;
		if(strlen(inputtext) < 1 || strlen(inputtext) > 8) return SendClientMessage(playerid, 0x08FD04FF, " * Tekst jest zbyt d³ugi!");
		else
		{
		    format(string, sizeof(string), " * Zmieni³eœ(aœ) tekst tablicy rejestracyjnej na: {E91616}'%s'.", inputtext);
		    SendClientMessage(playerid, 0x08FD04FF, string);
		    GetPlayerPos(playerid, X, Y, Z);
		    GetPlayerFacingAngle(playerid, angle);
		    SetVehicleNumberPlate(GetPlayerVehicleID(playerid), inputtext);
		    SetVehicleToRespawn(GetPlayerVehicleID(playerid));
			GetPlayerPos(playerid, X, Y, Z);
			SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
			SetVehicleZAngle(GetPlayerVehicleID(playerid), angle);
			PutPlayerInVehicle(playerid, GetPlayerVehicleID(playerid), 0);
			SetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z+2);
		}
		return 1;
	}
	if(dialogid == DIALOG_UNKNOWN_COMMAND)
	{
 		if(response)
 		{
				new StrinG[2400];
				StrinG = "{717C89}/KolorAuto {FFFFFF}- zmieniasz sobie losowo kolor pojazdu\n";
                strcat(StrinG,"{717C89}/HUD {FFFFFF}- Zmieniasz kolor szaty graficznej.\n");
				strcat(StrinG,"{717C89}/TDPanel - Panel Text Draw'ów\n");
                strcat(StrinG,"{717C89}/Randka [ID] - Idziesz na randkê\n");
				strcat(StrinG,"{717C89}/Losowanie {FFFFFF}- moze cos wygrasz...\n");
				strcat(StrinG,"{717C89}/TDpanel {FFFFFF}- panel zarzadzania TextDraw'ami\n");
				strcat(StrinG,"{717C89}/Staty {FFFFFF}- panel roznych statystyk i TOP-list\n");
				strcat(StrinG,"{717C89}/Podloz {FFFFFF}- podkladasz bombe \n");
				strcat(StrinG,"{717C89}/GiveCash [ID_gracza] [kwota] {FFFFFF}- dajesz graczowi podana ilosc pieniedzy\n");
				strcat(StrinG,"{717C89}/Hitman [ID_gracza] [kwota] {FFFFFF}- wyznaczasz nagrode za zabicie gracza\n");
				strcat(StrinG,"{717C89}/Bounty [ID_gracza] {FFFFFF}- sprawdzasz nagrode jaka jest za zabicie gracza\n");
				strcat(StrinG,"{717C89}/Kup {FFFFFF}- kupujesz wybrany biznes\n");
				strcat(StrinG,"{717C89}/KupDom {FFFFFF}- kupujesz wybrany dom\n");
				strcat(StrinG,"{717C89}/Admins {FFFFFF}- pokazuje obecnych administratorow\n");
				strcat(StrinG,"{717C89}/Vips {FFFFFF}- pokazuje obecnych Vipow\n");
                strcat(StrinG,"{717C89}/Mods {FFFFFF}- lista moderatorow\n");
				strcat(StrinG,"{717C89}/Fopen {FFFFFF}- otwierasz fortece (Farma na wsi) \n");
				strcat(StrinG,"{717C89}/Fclose {FFFFFF}- zamykasz fotrece (Farma na wsi)\n");
				strcat(StrinG,"{717C89}/Bronie {FFFFFF}- lista broni do kupienia\n");
				strcat(StrinG,"{717C89}/PM [ID_gracza] [tekst] {FFFFFF}- wysylasz prywatna wiadomosc do gracza\n");
				strcat(StrinG,"{717C89}/BuyWeapon [ID_broni] {FFFFFF}- kupujesz bron na stale (Ammunation)\n");
				strcat(StrinG,"{717C89}/DelWeapons {FFFFFF}- usuwasz swoje stale bronie\n");
				strcat(StrinG,"{717C89}/Weapons {FFFFFF}- lista broni do kupienia na stale\n");
				strcat(StrinG,"{717C89}/Lock {FFFFFF}- zamykasz pojazd\n");
				strcat(StrinG,"{717C89}/UnLock {FFFFFF}- otwierasz pojazd\n");
				strcat(StrinG,"{717C89}/Odleglosc [ID_gracza] {FFFFFF}- pojazuje odleglosc od gracza\n");
				strcat(StrinG,"{717C89}/Skok [500-20000] {FFFFFF}- wykonujesz skok spadochronowy z okreslonej wysokosci\n");

				ShowPlayerDialog(playerid,1054,0,"Komendy na serwerze",StrinG,"OK","OK");
				}
	    return 1;
	}
    if(dialogid == DIALOG_UNKNOWN_COMMAND2)
	{
 		if(response)
 		{
				new StrinG[2400];
				StrinG = "{717C89}/CarDive {FFFFFF}- wystrzeliwujesz w gore pojazd i spadasz\n";
				strcat(StrinG,"{717C89}/100hp {FFFFFF}- uleczasz sie\n");
                strcat(StrinG,"{717C89}/BuyWeapon [ID] [Ammo] {FFFFFF}- kupujesz broñ na spawn\n");
				strcat(StrinG,"{717C89}/CB {FFFFFF}- CB-Radio w pojeŸdzie!\n");
	            strcat(StrinG,"{FF0000}/Cars {FFFFFF}- Pojazdy do spawnu\n");
				strcat(StrinG,"{717C89}/CCB {FFFFFF}- Wybór kana³u do CB-Radia!\n");
				strcat(StrinG,"{717C89}/Armour {FFFFFF}- dostajesz kamizelkê kuloodporn¹\n");
	            strcat(StrinG,"{717C89}/Lotto {FFFFFF}- Losowanie lotto\n");
				strcat(StrinG,"{717C89}/Dotacja {FFFFFF}- dostajesz kasê\n");
				strcat(StrinG,"{717C89}/Pojazdy {FFFFFF}- lista pojazdow do kupienia\n");
				strcat(StrinG,"{717C89}/Posiadlosci /Posiadlosci2 {FFFFFF}- pokazuje liste i wlascicieli biznesow\n");
				strcat(StrinG,"{717C89}/NRG {FFFFFF}- dostajesz motor NRG-500\n");
				strcat(StrinG,"{717C89}/Kill {FFFFFF}- popelniasz samobojstwo\n");
				strcat(StrinG,"{717C89}/Tune {FFFFFF}- tuningujesz swój pojazd\n");
				strcat(StrinG,"{717C89}/TuneMenu {FFFFFF}- otwiera menu z opcjami tuningu pojazdu\n");
				strcat(StrinG,"{717C89}/Flip {FFFFFF}- stawiasz swój pojazd na kola\n");
				strcat(StrinG,"{717C89}/NOS {FFFFFF}- wstawiasz do pojazdu nitro\n");
				strcat(StrinG,"{717C89}/ZW /JJ /Siema /Nara /Witam /Pa {FFFFFF}- wiadomo o co chodzi...\n");
				strcat(StrinG,"{717C89}/Napraw {FFFFFF}- naprawiasz swój pojazd\n");
				strcat(StrinG,"{717C89}/SavePos {FFFFFF}- ustawiasz chwilowy teleport dla wszystkich\n");
				strcat(StrinG,"{717C89}/TelPos {FFFFFF}- teleportujesz sie do chwilowego teleportu\n");
				strcat(StrinG,"{717C89}/SP {FFFFFF}- zapisujesz swój prywatny teleport\n");
				strcat(StrinG,"{717C89}/LP {FFFFFF}- teleportujesz sie to swojego teleportu\n");
				strcat(StrinG,"{717C89}/Raport [ID_gracza] [powod] {FFFFFF}- wysylasz raport adminowi na gracza \n");
				strcat(StrinG,"{717C89}/Odlicz {FFFFFF}- wlaczasz odliczanie\n");
				strcat(StrinG,"{717C89}/StylWalki {FFFFFF}- wybierasz swój styl walki\n");
				strcat(StrinG,"{717C89}/Rozbroj {FFFFFF}- rozbrajasz siebie\n");
				strcat(StrinG,"{717C89}/RespektHelp {FFFFFF}- informacja co to jest respekt\n");
				strcat(StrinG,"{717C89}/VipInfo {FFFFFF}- poznaj mo¿liwoœæi vipa\n ");
	            strcat(StrinG,"{717C89}/ModInfo {FFFFFF}- sprawdzasz mo¿liwoœæi moderatora\n");
				strcat(StrinG,"{717C89}/Autor {FFFFFF}- pokazuje autora tego gamemoda\n");
	            strcat(StrinG,"{717C89}/Skin [id] {FFFFFF}- zmieniasz sobie skina podajac jego ID\n");
				strcat(StrinG,"{FF0000}/Komendy2 {FFFFFF}- Dalsza lista komend...");

				ShowPlayerDialog(playerid,DIALOG_UNKNOWN_COMMAND,0,"Komendy na serwerze",StrinG,"DALEJ","OK");
				}
	    return 1;
	}

	if(dialogid == DIALOG_ATRAKCJE)
	{
 		if(response)
 		{
			new StrinG[2400];

			StrinG = "{717C89}/Willa {FFFFFF}- Ogromna Willa Madd Dogga\n";
   			strcat(StrinG,"{717C89}/Drift1-5 {FFFFFF}- Tory wyczynowe do driftingu\n");
			strcat(StrinG,"{717C89}/ArenaSolo {FFFFFF}- Walki 1 vs 1 na Ciekawej Arenie za nagrodê\n");
			strcat(StrinG,"{717C89}/Solo1-5 {FFFFFF}- Tutaj odbywaj¹ siê solówki graczy\n");
			strcat(StrinG,"{717C89}/Port {FFFFFF}- Doki portowe w Los Santos\n");
			strcat(StrinG,"{717C89}/Bagno {FFFFFF}- Ciekawe otoczenie obiektów na bagnie SF-LS\n");
   			strcat(StrinG,"{717C89}/Tereno2 {FFFFFF}- Jazda w Technicznym Terenie.\n");
			strcat(StrinG,"{717C89}/Statek {FFFFFF}- Atrakcyjny statek w LV z bocianim gniazdem itp\n");
			strcat(StrinG,"{717C89}/Impra {FFFFFF}- Impreza dyskotekowa\n");
			strcat(StrinG,"{717C89}/Gora {FFFFFF}- Ogromna Góra Chilliad w ciekawym otoczeniu obiektów\n");
			strcat(StrinG,"{717C89}/Miasteczko {FFFFFF}- Ma³e miasteczko\n");
			strcat(StrinG,"{717C89}/ME {FFFFFF}- Piszesz na czacie (me)\n");
			strcat(StrinG,"{717C89}/Piramida {FFFFFF}- Piramida w LV z wjazdem na 3D rury\n");
			strcat(StrinG,"{717C89}/Pustynia {FFFFFF}- Pustynia na starym lotnisku LV\n");
			strcat(StrinG,"{717C89}/WG {FFFFFF}- Wojna Gangów \n");
			strcat(StrinG,"{717C89}/CF {FFFFFF}- Capture The Flag - Walka o Flagê\n");
			strcat(StrinG,"{717C89}/DB {FFFFFF}- Destruction Derby na arenie\n");
			strcat(StrinG,"{717C89}/SS {FFFFFF}- Skoki spadochronowe w grupie\n");
			strcat(StrinG,"{717C89}/WS {FFFFFF}- Wyœcig samochodowy za nagrody\n");
			strcat(StrinG,"{717C89}/CH {FFFFFF}- Zabawa w chowanego na serwerze\n ");
   			strcat(StrinG,"{717C89}/LB {FFFFFF}- Labirynt ten kto 1 znajdzie wyjœcie wygrywa\n");
			strcat(StrinG,"{717C89}/AmmuNation {FFFFFF}- Teleport do AmmuNation\n");
   			strcat(StrinG,"{717C89}/Drag {FFFFFF}- Wyœcig Drag na 1/4 Mili z przeciwnikami\n");
   			strcat(StrinG,"\n");
			strcat(StrinG,"{717C89}/Komendy {FFFFFF}- Tutaj znajdziesz listê podstawowych komend serwera");

			ShowPlayerDialog(playerid,1054,0,"{717C89}Atrakcje",StrinG,"OK","OK");
		}
	    return 1;
	}

	if(dialogid == 1)
	{
		if(response)
		{
		    switch(listitem)
		    {
		        case 0: SellGun(playerid,38,5000,1000000);
		        case 1: SellGun(playerid,35,5000,500000);
		        case 2: SellGun(playerid,36,5000,750000);
		        case 3: SellGun(playerid,37,5000,400000);
		        case 4: SellGun(playerid,39,5000,200000);
		        case 5: SellGun(playerid,16,100,150000);
		    }
		}
		return 1;
	}
	if(dialogid == 2)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: SellGun(playerid,1,1,100);
				case 1: SellGun(playerid,2,1,100);
				case 2: SellGun(playerid,3,1,100);
				case 3: SellGun(playerid,4,1,100);
				case 4: SellGun(playerid,5,1,100);
				case 5: SellGun(playerid,6,1,100);
				case 6: SellGun(playerid,7,1,100);
				case 7: SellGun(playerid,8,1,100);
				case 8: SellGun(playerid,9,1,1500);
				case 9: SellGun(playerid,10,1,100);
				case 10: SellGun(playerid,14,1,100);
				case 11: SellGun(playerid,17,10,5000);
				case 12: SellGun(playerid,22,350,3000);
				case 13: SellGun(playerid,23,200,4000);
				case 14: SellGun(playerid,24,200,5000);
				case 15: SellGun(playerid,25,200,5000);
				case 16: SellGun(playerid,26,100,8000);
				case 17: SellGun(playerid,27,150,25000);
				case 18: SellGun(playerid,28,500,10000);
				case 19: SellGun(playerid,29,550,12000);
				case 20: SellGun(playerid,30,550,13000);
				case 21: SellGun(playerid,31,600,15000);
				case 22: SellGun(playerid,32,500,10000);
				case 23: SellGun(playerid,33,200,5000);
				case 24: SellGun(playerid,34,50,20000);
				case 25: SellGun(playerid,41,500,100);
				case 26: SellGun(playerid,42,500,500);
				case 27: SellGun(playerid,46,1,100);
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_LOWISKO)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
        		SendClientMessage(playerid,COLOR_YELLOW,"(£owisko) Teleportowano siê do miejsca numer 1!");
                SetPlayerPos(playerid,1995.7472,1520.9368,17.0625);
				}
				case 1:
				{
                SendClientMessage(playerid,COLOR_YELLOW,"(£owisko) Teleportowano siê do miejsca numer 2!");
                SetPlayerPos(playerid,-811.2654,-1949.7509,9.1696);
				}
				case 2:
				{
                SendClientMessage(playerid,COLOR_YELLOW,"(£owisko) Teleportowano siê do miejsca numer 3!");
                SetPlayerPos(playerid,379.6913,-1936.6538,7.8359);
				}
				case 3:
				{
                SendClientMessage(playerid,COLOR_YELLOW,"(£owisko) Teleportowano siê do miejsca numer 4!");
                SetPlayerPos(playerid,2331.5251,496.7823,4.6922);
				}
				case 4:
				{
                SendClientMessage(playerid,COLOR_YELLOW,"(£owisko) Teleportowano siê do miejsca numer 5!");
                SetPlayerPos(playerid,-649.8740,2133.1616,60.3828);
				}
				case 5:
				{
                SendClientMessage(playerid,COLOR_YELLOW,"(£owisko) Teleportowano siê do miejsca numer 6!");
                SetPlayerPos(playerid,-1721.8055,226.6514,1.9609);
				}
                case 6:
				{
                SendClientMessage(playerid,COLOR_YELLOW,"(£owisko) Teleportowano siê do miejsca numer 7!");
                SetPlayerPos(playerid,-2654.4146,1588.2233,64.1286);
				}
			}
		}
		return 1;
	}
	if(dialogid == DIALOG_WALKA)
	{
		if(response)
		{
			switch(listitem)
			{
			    case 0:
			    {
					SetPlayerFightingStyle(playerid,4);
					SendClientMessage(playerid, COLOR_ORANGE, "Wybra³eœ(aœ) Normalny Styl Walki");
				}
				case 1:
				{
					SetPlayerFightingStyle(playerid, FIGHT_STYLE_BOXING);
					SendClientMessage(playerid, COLOR_ORANGE, "Wybra³eœ(aœ) Boxerski Styl Walki");
				}
				case 2:
				{
					SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
					SendClientMessage(playerid, COLOR_ORANGE, "Wybra³eœ(aœ) Styl Walki Karate");
				}
				case 3:
				{
					SetPlayerFightingStyle(playerid, FIGHT_STYLE_KNEEHEAD);
					SendClientMessage(playerid, COLOR_ORANGE, "Wybra³eœ(aœ) Styl Skin Head");
				}
                case 4:
				{
					SetPlayerFightingStyle(playerid, FIGHT_STYLE_GRABKICK);
					SendClientMessage(playerid, COLOR_ORANGE, "Wybra³eœ(aœ) Styl Kick Boxing");
				}
                case 5:
				{
					SetPlayerFightingStyle(playerid, FIGHT_STYLE_ELBOW);
					SendClientMessage(playerid, COLOR_ORANGE, "Wybra³eœ(aœ) Styl Czarnucha");
				}
			}
		}
		return 1;
	}
	if(dialogid == 3)
	{
		if(response)
		{
		    switch(listitem)
		    {
		        case 0:
		        {
					new string[1230];
					strcat(string,"Admiral\nAlpha\nAmbulans\nBaggage\nBandito\nBanshee\nBarracks\nBenson\nBfinject\nBlade\nBlistac\nBloodra\nBobcat\nBoxburg\nBoxville\nBravura\nBroadway\nBuccanee\nBuffalo\nBullet\nBurrito\nBus\nCabbie\nCaddy\nCadrona\nCamper\nCement\nCheetah\nClover\nClub\nCoach\nCombine\nComet\nCopCarla\nCopCarru\nCopCarsf\nCopCarvg\nCft30\nDozer\nDumper\nDuneride\nElegant\nElegy\nEmperor\nEnforcer\nEsperant\nEuros\nFbiranch\nFbitruck\nFeltze\n");
					strcat(string,"Firela\nFiretruck\nFlash\nFlatbed\nForklift\nFortune\nGlendale\nGreenwoo\nHermes\nHotdog\nHotknife\nHotrina\nHotrinb\nHotring\nHuntley\nHustler\nInfernus\nIntruder\nJester\nJourney\nKart\nLandstalker\nLinerunner\nMajestic\nManana\nMerit\nMesa\nMoonbeam\nMower\nMrwhoop\nMonster\nMonsterA\nMonsterB\nMule\nNebula\nNewsvan\nOceanic\nPacker\nPatriot\nPeren\nPetro\nPhoenix\nPicador\nPony\nPremier\nPrevion\nPrimo\nRancher\nRoadtrain\n");
					strcat(string,"Regina\nRemington\nRomero\nRumpoid\nSabre\nSadler\nSandking\nSavanna\nSecurica\nSentinel\nSlamvan\nSolair\nStafford\nStallion\nStratum\nStretch\nSultan\nSunrise\nSupergt\nSwatvan\nSweeper\nTahoma\nTampa\nTaxi\nTopfun\nTornado\nTowtruck\nTractor\nTrash\nTug\nTurismo\nUranus\nUtility\nVincent\nVirgo\nVoodoo\nVortex\nWashington\nWillard\nWindsor\nYankee\nYosemite\nZR-350");
					ShowPlayerDialog(playerid,10,DIALOG_STYLE_LIST,"Samochody",string,"Wybierz","Cofnij");
				}
				case 1:
				{
					ShowPlayerDialog(playerid,11,DIALOG_STYLE_LIST,"Motory/Rowery","Bike\nBMX\nMountain Bike\nNRG-500\nFaggio\nFCR-900\nFreeway\nWayfarer\nSanchez\nQuad\nHPV-1000\nPCJ-600\nBF-400","Wybierz","Cofnij");
				}
				case 2:
				{
					ShowPlayerDialog(playerid,12,DIALOG_STYLE_LIST,"Lodzie","Dinghy\nJetmax\nMarquis\nReefer\nSpeeder\nSqualo\nTropic","Wybierz","Cofnij");
				}
				case 3:
				{
					ShowPlayerDialog(playerid,13,DIALOG_STYLE_LIST,"Samoloty/Helikoptery","Dodo\nStunt\nBeagle\nSkimmer\nShamal\nCargobob\nLeviathn\nMaverick\nRaindanc\nSparrow\nSeaSparrow","Wybierz","Cofnij");
				}
                case 4:
				{
					ShowPlayerDialog(playerid,100,DIALOG_STYLE_LIST,"Zabawki RC","RC Bandit\nRC Barron\nRC Cam\nRC Goblin\nRC Raider\nRC Tiger","Wybierz","Cofnij");
				}

			}
		}
		return 1;
	}

	if(dialogid == 7) //Dialog logowania
	{

		if(response == 1)
		{
			new pass[128], tmp[128];
			mysql_real_escape_string(inputtext, pass);
			mysql_query_format("SELECT id, Score,Bank,Bounty,Kills,Deaths,Row_Kills,Suicides,Used_Score,Arena,Skin,Drag,Time,AdminLevel,UNIX_TIMESTAMP(`Vip`) ,Portfel, Warn , `Deagle`, `Minigun`, `Sniper`, `Chainsawn`, `DuelW`, `DuelP` FROM `fg_Players` WHERE Nick = '%s' AND `Pass`='%s' LIMIT 1",PlayerName(playerid),pass);
			
			
			mysql_store_result();
			if(!mysql_num_rows())
			{
				BadPasCount[playerid] ++;
				if(BadPasCount[playerid] >= 3){
					SendClientMessage(playerid,COLOR_ORANGE,"Zbyt du¿o razy wpisa³eœ(aœ) b³êdne has³o");
					KickEx(playerid);
				}
		        SendClientMessage(playerid, COLOR_RED2, "Podano b³êdne has³o!");
				new buf[255];
				format(buf, sizeof(buf)-1, "Witaj, %s!\nKonto pod tym nickiem jest zarejestrowane\nWpisz swoje haslo, w przeciwnym wypadku opusc serwer\n\n{ff0000}Podano nieprawidlowe haslo do tego konta", PlayerName(playerid));
				ShowPlayerDialog(playerid, 7, DIALOG_STYLE_PASSWORD, " Witamy na FullGaming!", buf, "Zaloguj", "Wyjdz");
				return 0;
			}			
		

			
			mysql_fetch_row(tmp, "|");
			new u = playerid;
			new mozevip;
			sscanf(tmp,"p<|>ddddddddddddddddddddddd",
				Player[u][uID],Respekt[u],bank[u],bounty[u],kills[u],deaths[u],killsinarow[u],suicides[u],wykorzystanyrespekt[u],SoloScore[u],Player[u][Skin],DragTime[u],TimePlay[u],Player[u][Admin],mozevip,Player[u][Portfel],Player[u][Warns],Player[playerid][deagle],Player[playerid][minigun],Player[playerid][sniper],Player[playerid][chainsawn],Player[playerid][wduel],Player[playerid][pduel]);
			if(!Player[playerid][Admin])
			{
				if(mozevip > gettime()) 
				{ 
					Player[u][VIP] = true; 
				}
			}
			mysql_free_result();
			
			mysql_query_format("UPDATE `fg_Players` SET `Online`='1' WHERE `id`='%d' ",Player[playerid][uID]);
			//Uwa¿aj to bêdzie dzia³aæ tylko w systemie na mysql. Je¿eli zmienisz na system na pliki to nie bêdzie dzia³aæ wogule system zapisywania kodów.

			
			if(Player[playerid][uID]>0)
			{
				gpVehicleid[playerid] = pv_findVehicleByOwnerID(Player[playerid][uID]);
			} else {
				gpVehicleid[playerid] = -1;
			}
			
			if(gpVehicleid[playerid]>=0)
			{
				SCM(playerid, COLOR_INFO, "Twoj prywatny pojazd czeka tam gdzie go poprzednio zostawi³eœ. Aby go przywo³aæ u¿yj /mp");
				pv_SpawnVehicle(playerid);
			}
				
			format(tmp,sizeof(tmp),"SELECT Ilosc FROM Kody WHERE Nick = '%s' LIMIT 1;",PlayerName(playerid));
			mysql_query(tmp);
			mysql_store_result();
			mysql_fetch_row(tmp, " ");
			sscanf(tmp,"d",WygraneKod[playerid]);
			mysql_free_result();
		
			format(LoginNick[playerid],MAX_PLAYER_NAME,"%s",PlayerName(playerid));
			logged[playerid] = true;
			format(tmp, sizeof(tmp), "Zalogowano pomyœlnie! Witaj {FFFFFF}%s{FFFF00}.", PlayerName(playerid));
			SendClientMessage(playerid, COLOR_YELLOW, tmp);
			Player[playerid][Level] = GetPlayerLevel(playerid);
	
			GetPlayerIp (playerid, tmp, sizeof (tmp));
			mysql_query_format("update fg_Players SET datetime_last = NOW(), ip_last = '%s' where Nick = '%s';",tmp,PlayerName(playerid));
		//	if(Player[playerid][Skin] > 0){
		//		TextDrawShowForPlayer(playerid,powitanie[4]);
          //      TextDrawShowForPlayer(playerid,powitanie[3]);
		//	}



			for(new x=0;x<HOUSES_LOOP;x++){
				if(strfind(LoginNick[playerid],HouseInfo[x][hOwner],true)==0){
					MaDom[playerid] = true;
					HouseID[playerid] = x;
					break;
				}
			}

			MozeMowic[playerid] = true;

		}

		return 1;
	}
	if(dialogid == 8)
	{
		if(response == 1)
		{

			if(20 < strlen(inputtext) || strlen(inputtext) < 5) {
				SendClientMessage(playerid, COLOR_RED2, "Has³o musi mieæ od 5 do 20 znaków");
				ShowPlayerDialog(playerid,8,DIALOG_STYLE_PASSWORD,"{FFFFFF}Panel Rejestracji","{FFFF00}Dziêkujemy za poddanie konta rejestracji!\nAby siê zarejestrowaæ wymyœl has³o które\nbêdziesz musia³ wpisywaæ przy ka¿dym ponownym wejœciu na serwer\n\n{FFFFFF}Poni¿ej podaj wymyœlone has³o:","Rejestruj","Anuluj");
				return 1;
			}

            if(!IsValidDescription(inputtext))
	    	{
		        SendClientMessage(playerid, COLOR_RED2, "Has³o mo¿e siê sk³adaæ tylko z liczb i liter [a-z] [A-Z] [0-9]");
	            ShowPlayerDialog(playerid,8,DIALOG_STYLE_PASSWORD,"{FFFFFF}Panel Rejestracji","{FFFF00}Dziêkujemy za poddanie konta rejestracji!\nAby siê zarejestrowaæ wymyœl has³o które\nbêdziesz musia³ wpisywaæ przy ka¿dym ponownym wejœciu na serwer\n\n{FFFFFF}Poni¿ej podaj wymyœlone has³o:","Rejestruj","Anuluj");
				return 1;
	    	}
			new pass[40], ip[16];
			GetPlayerIp (playerid, ip, sizeof (ip));
			mysql_real_escape_string(inputtext, pass);
			mysql_query_format("INSERT INTO `fg_Players` SET `Nick` = '%s',`Nick_Register`='%s',`Pass`='%s',datetime_registered=NOW(), datetime_last = NOW(), ip_registered = '%s', ip_last = '%s', `Score` = '0',`Bank` = '0',`Bounty` = '0',Vip = '0', `Kills` = '0',`Deaths` = '0',`Suicides` = '0',`Used_Score` = '0',`Skin` = '0',`Row_Kills` = '0',`Arena` = '0',`Drag` = '100000',`Online`='1'",PlayerName(playerid),PlayerName(playerid),pass, ip, ip);
			//mysql_query_format("UPDATE `fg_Players` SET `Online`='1' WHERE `Nick`='%s'",PlayerName(playerid));
			mysql_query_format("INSERT INTO `Kody` SET `Nick` = '%s',Ilosc='%d'",PlayerName(playerid),WygraneKod[playerid]);
			mysql_query_format("SELECT `id` FROM `fg_Players` WHERE `Nick`='%s'",PlayerName(playerid));
			mysql_store_result();
			mysql_fetch_row(Player[playerid][uID]);
			mysql_free_result();
			
// no to sprawdŸmy efekt koñcowy ;P
//ok czekaj chce zrobiæ sobie porz¹dek
//patrz na to F5 wciœnij

			users ++;
			SendClientMessage(playerid, COLOR_GREEN, "");
			new string[128];			
			format(string, sizeof(string), "{00FF00}Utworzono konto o nazwie: %s {00FFFF}Twoje haslo to: %s\n{FF0000}Zapamiêtaj has³o do przysz³ego logowania", PlayerName(playerid), pass);
			//format(string, sizeof(string), " * Utworzono konto: %s , Has³o dostêpu: %s \n Zapamiêtaj has³o do przysz³ego logowania", PlayerName(playerid), inputtext);
			ShowPlayerDialog(playerid,600,DIALOG_STYLE_MSGBOX,"{FFFFFF}Panel Rejestracji",string,"Ok","");

			format(string, sizeof(string), "Utworzyles konto o nazwie %s. {00FFFF}Twoje haslo to: %s\n{FF0000}Zapamiêtaj has³o do przysz³ego logowania", PlayerName(playerid), pass);
			SendClientMessage(playerid, COLOR_GREEN, string);
            PlayerPlaySound(playerid,1186,0.0,0.0,0.0);
        	PlayerPlaySound(playerid,1149,0.0,0.0,0.0);

			MSGFA(COLOR_SEAGREEN, "Mamy nowego zarejestrowanego gracza! {FFFF00}%s {00EEAD}witamy!", PlayerName(playerid));
			format(Pass[playerid],21,"%s",inputtext);
			format(LoginNick[playerid],MAX_PLAYER_NAME,"%s",PlayerName(playerid));
			logged[playerid] = true;
			Registered[playerid] = true;
		}

		if(response == 0){
			SendClientMessage(playerid,COLOR_RED2," * Anulowano rejestracjê nicku.");
		}

		return 1;
	}
	if(dialogid == 9)
	{
		if(response == 1)
		{

			if(20 < strlen(inputtext) || strlen(inputtext) < 5) {
				SendClientMessage(playerid, COLOR_RED2, " * Has³o musi mieæ od 5 do 20 znaków");
				ShowPlayerDialog(playerid,9,1,"Zmiana Has³a","{FFFF00}Podaj nowe has³o do tego konta","Zmieniam","Anuluj");
				return 1;
			}

			if(!IsValidDescription(inputtext))
	    	{
				SendClientMessage(playerid, COLOR_RED2, "Has³o mo¿e siê sk³adaæ tylko z liczb i liter [a-z] [A-Z] [0-9]");
				ShowPlayerDialog(playerid,9,1,"Zmiana Has³a","{FFFF00}Podaj nowe has³o do tego konta","Zmieniam","Anuluj");
				return 1;
	    	}
			new pass[40];
			mysql_real_escape_string(inputtext, pass);
			mysql_query_format("UPDATE `fg_Players` SET `Pass`='%s' WHERE `id`='%d'",pass,Player[playerid][uID]);
			format(Pass[playerid],40,"%s",inputtext);
			MSGF(playerid, COLOR_GREEN, " * Zmieniono has³o na: %s || Prosimy o zapamiêtanie has³a.", pass);
		}
		if(response == 0){
			SendClientMessage(playerid,COLOR_RED2," * Anulowa³eœ(aœ) zmianê has³a tego konta");
		}

		return 1;
	}
	if(dialogid == 10)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: GivePlayerCar(playerid,445);
				case 1: GivePlayerCar(playerid,602);
				case 2: GivePlayerCar(playerid,416);
				case 3: GivePlayerCar(playerid,485);
				case 4: GivePlayerCar(playerid,568);
				case 5: GivePlayerCar(playerid,429);
				case 6: GivePlayerCar(playerid,433);
				case 7: GivePlayerCar(playerid,499);
				case 8: GivePlayerCar(playerid,424);
				case 9: GivePlayerCar(playerid,536);
				case 10: GivePlayerCar(playerid,496);
				case 11: GivePlayerCar(playerid,504);
				case 12: GivePlayerCar(playerid,422);
				case 13: GivePlayerCar(playerid,609);
				case 14: GivePlayerCar(playerid,498);
				case 15: GivePlayerCar(playerid,401);
				case 16: GivePlayerCar(playerid,575);
				case 17: GivePlayerCar(playerid,518);
				case 18: GivePlayerCar(playerid,402);
				case 19: GivePlayerCar(playerid,541);
				case 20: GivePlayerCar(playerid,482);
				case 21: GivePlayerCar(playerid,431);
				case 22: GivePlayerCar(playerid,438);
				case 23: GivePlayerCar(playerid,457);
				case 24: GivePlayerCar(playerid,527);
				case 25: GivePlayerCar(playerid,483);
				case 26: GivePlayerCar(playerid,524);
				case 27: GivePlayerCar(playerid,415);
				case 28: GivePlayerCar(playerid,542);
				case 29: GivePlayerCar(playerid,589);
				case 30: GivePlayerCar(playerid,437);
				case 31: GivePlayerCar(playerid,532);
				case 32: GivePlayerCar(playerid,480);
				case 33: GivePlayerCar(playerid,596);
				case 34: GivePlayerCar(playerid,599);
				case 35: GivePlayerCar(playerid,597);
				case 36: GivePlayerCar(playerid,598);
				case 37: GivePlayerCar(playerid,578);
				case 38: GivePlayerCar(playerid,486);
				case 39: GivePlayerCar(playerid,406);
				case 40: GivePlayerCar(playerid,573);
				case 41: GivePlayerCar(playerid,507);
				case 42: GivePlayerCar(playerid,562);
				case 43: GivePlayerCar(playerid,585);
				case 44: GivePlayerCar(playerid,427);
				case 45: GivePlayerCar(playerid,419);
				case 46: GivePlayerCar(playerid,587);
				case 47: GivePlayerCar(playerid,490);
				case 48: GivePlayerCar(playerid,528);
				case 49: GivePlayerCar(playerid,533);
				case 50: GivePlayerCar(playerid,544);
				case 51: GivePlayerCar(playerid,407);
				case 52: GivePlayerCar(playerid,565);
				case 53: GivePlayerCar(playerid,455);
				case 54: GivePlayerCar(playerid,530);
				case 55: GivePlayerCar(playerid,526);
				case 56: GivePlayerCar(playerid,466);
				case 57: GivePlayerCar(playerid,492);
				case 58: GivePlayerCar(playerid,474);
				case 59: GivePlayerCar(playerid,588);
				case 60: GivePlayerCar(playerid,434);
				case 61: GivePlayerCar(playerid,502);
				case 62: GivePlayerCar(playerid,503);
				case 63: GivePlayerCar(playerid,494);
				case 64: GivePlayerCar(playerid,579);
				case 65: GivePlayerCar(playerid,545);
				case 66: GivePlayerCar(playerid,411);
				case 67: GivePlayerCar(playerid,546);
				case 68: GivePlayerCar(playerid,559);
				case 69: GivePlayerCar(playerid,508);
				case 70: GivePlayerCar(playerid,571);
				case 71: GivePlayerCar(playerid,400);
				case 72: GivePlayerCar(playerid,403);
				case 73: GivePlayerCar(playerid,517);
				case 74: GivePlayerCar(playerid,410);
				case 75: GivePlayerCar(playerid,551);
				case 76: GivePlayerCar(playerid,500);
				case 77: GivePlayerCar(playerid,418);
				case 78: GivePlayerCar(playerid,572);
				case 79: GivePlayerCar(playerid,423);
				case 80: GivePlayerCar(playerid,444);
				case 81: GivePlayerCar(playerid,556);
				case 82: GivePlayerCar(playerid,557);
				case 83: GivePlayerCar(playerid,414);
				case 84: GivePlayerCar(playerid,516);
				case 85: GivePlayerCar(playerid,582);
				case 86: GivePlayerCar(playerid,467);
				case 87: GivePlayerCar(playerid,443);
				case 88: GivePlayerCar(playerid,470);
				case 89: GivePlayerCar(playerid,404);
				case 90: GivePlayerCar(playerid,514);
				case 91: GivePlayerCar(playerid,603);
				case 92: GivePlayerCar(playerid,600);
				case 93: GivePlayerCar(playerid,413);
				case 94: GivePlayerCar(playerid,426);
				case 95: GivePlayerCar(playerid,436);
				case 96: GivePlayerCar(playerid,547);
				case 97: GivePlayerCar(playerid,489);
				case 98: GivePlayerCar(playerid,515);
				case 99: GivePlayerCar(playerid,479);
				case 100: GivePlayerCar(playerid,534);
				case 101: GivePlayerCar(playerid,442);
				case 102: GivePlayerCar(playerid,440);
				case 103: GivePlayerCar(playerid,475);
				case 104: GivePlayerCar(playerid,543);
				case 105: GivePlayerCar(playerid,495);
				case 106: GivePlayerCar(playerid,567);
				case 107: GivePlayerCar(playerid,428);
				case 108: GivePlayerCar(playerid,405);
				case 109: GivePlayerCar(playerid,535);
				case 110: GivePlayerCar(playerid,458);
				case 111: GivePlayerCar(playerid,580);
				case 112: GivePlayerCar(playerid,439);
				case 113: GivePlayerCar(playerid,561);
				case 114: GivePlayerCar(playerid,409);
				case 115: GivePlayerCar(playerid,560);
				case 116: GivePlayerCar(playerid,550);
				case 117: GivePlayerCar(playerid,506);
				case 118: GivePlayerCar(playerid,601);
				case 119: GivePlayerCar(playerid,574);
				case 120: GivePlayerCar(playerid,566);
				case 121: GivePlayerCar(playerid,549);
				case 122: GivePlayerCar(playerid,420);
				case 123: GivePlayerCar(playerid,559);
				case 124: GivePlayerCar(playerid,576);
				case 125: GivePlayerCar(playerid,525);
				case 126: GivePlayerCar(playerid,531);
				case 127: GivePlayerCar(playerid,408);
				case 128: GivePlayerCar(playerid,583);
				case 129: GivePlayerCar(playerid,451);
				case 130: GivePlayerCar(playerid,558);
				case 131: GivePlayerCar(playerid,552);
				case 132: GivePlayerCar(playerid,540);
				case 133: GivePlayerCar(playerid,451);
				case 134: GivePlayerCar(playerid,412);
				case 135: GivePlayerCar(playerid,539);
				case 136: GivePlayerCar(playerid,421);
				case 137: GivePlayerCar(playerid,529);
				case 138: GivePlayerCar(playerid,555);
				case 139: GivePlayerCar(playerid,456);
				case 140: GivePlayerCar(playerid,554);
                case 141: GivePlayerCar(playerid,477);
			}
		}else{

			if(!ZmieniaAuto[playerid]){
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery \n> Lodzie \n> Samoloty/Helikoptery \n> Zabawki RC", "Dalej", "Anuluj");
			}else{
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery ", "Dalej", "Anuluj");
			}
		}

		return 1;
	}
	if(dialogid == 11)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: GivePlayerCar(playerid,509);
				case 1: GivePlayerCar(playerid,481);
				case 2: GivePlayerCar(playerid,510);
				case 3: GivePlayerCar(playerid,522);
				case 4: GivePlayerCar(playerid,462);
				case 5: GivePlayerCar(playerid,521);
				case 6: GivePlayerCar(playerid,463);
				case 7: GivePlayerCar(playerid,586);
				case 8: GivePlayerCar(playerid,468);
				case 9: GivePlayerCar(playerid,471);
                case 10: GivePlayerCar(playerid,523);
				case 11: GivePlayerCar(playerid,461);
				case 12: GivePlayerCar(playerid,581);
			}
		}else{

			if(!ZmieniaAuto[playerid]){
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery \n> Lodzie \n> Samoloty/Helikoptery \n> Zabawki RC", "Dalej", "Anuluj");
			}else{
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery ", "Dalej", "Anuluj");
			}
		}

		return 1;
	}
	if(dialogid == 12)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: GivePlayerCar(playerid,473);
				case 1: GivePlayerCar(playerid,493);
				case 2: GivePlayerCar(playerid,484);
				case 3: GivePlayerCar(playerid,453);
				case 4: GivePlayerCar(playerid,452);
				case 5: GivePlayerCar(playerid,446);
				case 6: GivePlayerCar(playerid,454);
			}
		}else{

			if(!ZmieniaAuto[playerid]){
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery \n> Lodzie \n> Samoloty/Helikoptery \n> Zabawki RC", "Dalej", "Anuluj");
			}else{
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery ", "Dalej", "Anuluj");
			}
		}

		return 1;
	}
	if(dialogid == 13)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0: GivePlayerCar(playerid,593);
				case 1: GivePlayerCar(playerid,513);
				case 2: GivePlayerCar(playerid,511);
				case 3: GivePlayerCar(playerid,460);
				case 4: GivePlayerCar(playerid,519);
				case 5: GivePlayerCar(playerid,548);
				case 6: GivePlayerCar(playerid,417);
				case 7: GivePlayerCar(playerid,487);
				case 8: GivePlayerCar(playerid,563);
				case 9: GivePlayerCar(playerid,469);
                case 10: GivePlayerCar(playerid,447);
			}
		}else{

			if(!ZmieniaAuto[playerid]){
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery \n> Lodzie \n> Samoloty/Helikoptery \n> Zabawki RC", "Dalej", "Anuluj");
			}else{
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery ", "Dalej", "Anuluj");
			}
		}

		return 1;
	}
	if(dialogid == 100)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					GivePlayerCar(playerid,441);
					InRC[playerid] = true;
				}
				case 1:
				{
					GivePlayerCar(playerid,464);
                    InRC[playerid] = true;
				}
				case 2:
				{
					GivePlayerCar(playerid,594);
                    InRC[playerid] = true;
				}
				case 3:
				{
					GivePlayerCar(playerid,501);
                    InRC[playerid] = true;
				}
				case 4:
				{
					GivePlayerCar(playerid,465);
                    InRC[playerid] = true;
				}
				case 5:
				{
					GivePlayerCar(playerid,564);
                    InRC[playerid] = true;
				}
			}
		}else{

			if(!ZmieniaAuto[playerid]){
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery \n> Lodzie \n> Samoloty/Helikoptery \n> Zabawki RC", "Dalej", "Anuluj");
			}else{
				ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery ", "Dalej", "Anuluj");
			}
		}

		return 1;
	}
	if(dialogid == 14)
	{
		if(response)
		{
            new vehicleid = GetPlayerVehicleID(playerid);
			switch(listitem)
		    {
				case 0: ShowPlayerDialog(playerid, 15, DIALOG_STYLE_LIST, "Felgi", "Switch\nMega\nCutter\nOffroad\nShadow\nRimshine\nWires\nClassic\nTwist\nGrove\nImport\nDollar\nTrance\nAtomic\nAhab\nVirtual\nAccess\n", "Wybierz", "Wróæ");
		        case 1: ShowPlayerDialog(playerid, 16, DIALOG_STYLE_LIST, "Kolory", "Czarny\nBialy\nSzary\nZolty\nNiebieski\nBlekitny\nGranatowy\nFiloetowy\nCzerwony\nJasny Czerwony\nZielony\nRozowy", "Wybierz", "Wróæ");
				case 2:
				{
					PlayerPlaySound(playerid, 1133, 0, 0, 0);
					AddVehicleComponent(vehicleid, 1087);
					ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Tuning Menu", "Felgi\nKolory\nHydraulika\nNitro\nStereo\nPaint Job", "Wybierz", "Anuluj");
				}
		        case 3:
		        {
					PlayerPlaySound(playerid, 1133, 0, 0, 0);
					AddVehicleComponent(vehicleid, 1010);
					ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Tuning Menu", "Felgi\nKolory\nHydraulika\nNitro\nStereo\nPaint Job", "Wybierz", "Anuluj");
		        }
		        case 4:
		        {
					PlayerPlaySound(playerid, 1133, 0, 0, 0);
					AddVehicleComponent(vehicleid, 1086);
					ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Tuning Menu", "Felgi\nKolory\nHydraulika\nNitro\nStereo\nPaint Job", "Wybierz", "Anuluj");
		        }
		        case 5: ShowPlayerDialog(playerid, 36, DIALOG_STYLE_LIST, "Paint Job", "Paint Job 1\nPaint Job 2\nPaint Job 3\nUsun Paint Job'a", "Wybierz", "Wróæ");
			}
		}
		return 1;
	}
	if(dialogid == 15)
	{
		if(response == 1)
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			switch(listitem)
			{
			    case 0: AddVehicleComponent(vehicleid, 1080); //Switch
			    case 1: AddVehicleComponent(vehicleid, 1074); //Mega
			    case 2: AddVehicleComponent(vehicleid, 1079); //Cutter
			    case 3: AddVehicleComponent(vehicleid, 1025); //Offroad
			    case 4: AddVehicleComponent(vehicleid, 1073); //Shadow
			    case 5: AddVehicleComponent(vehicleid, 1075); //Rimshine
			    case 6: AddVehicleComponent(vehicleid, 1076); //Wires
			    case 7: AddVehicleComponent(vehicleid, 1077); //Classic
			    case 8: AddVehicleComponent(vehicleid, 1078); //Twist
			    case 9: AddVehicleComponent(vehicleid, 1081); //Grove
			    case 10: AddVehicleComponent(vehicleid, 1082); //Import
			    case 11: AddVehicleComponent(vehicleid, 1083); //Dollar
			    case 12: AddVehicleComponent(vehicleid, 1084); //Trance
			    case 13: AddVehicleComponent(vehicleid, 1085); //Atomic
			    case 14: AddVehicleComponent(vehicleid, 1096); //Ahab
			    case 15: AddVehicleComponent(vehicleid, 1097); //Virtual
			    case 16: AddVehicleComponent(vehicleid, 1098); //Access
			}
			ShowPlayerDialog(playerid, 15, DIALOG_STYLE_LIST, "Felgi", "Switch\nMega\nCutter\nOffroad\nShadow\nRimshine\nWires\nClassic\nTwist\nGrove\nImport\nDollar\nTrance\nAtomic\nAhab\nVirtual\nAccess\n", "Wybierz", "Wróæ");
		}else{
			ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Tuning Menu", "Felgi\nKolory\nHydraulika\nNitro\nStereo\nPaint Job", "Wybierz", "Anuluj");
		}
		return 1;
	}
	if(dialogid == 16)
	{
		if(response == 1)
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			switch(listitem)
			{
			    case 0: ChangeVehicleColor(vehicleid, 0, 0);
			    case 1: ChangeVehicleColor(vehicleid, 1, 1);
			    case 2: ChangeVehicleColor(vehicleid, 33, 33);
			    case 3: ChangeVehicleColor(vehicleid, 6, 6);
			    case 4: ChangeVehicleColor(vehicleid, 108, 108);
			    case 5: ChangeVehicleColor(vehicleid, 7, 7);
			    case 6: ChangeVehicleColor(vehicleid, 79, 79);
			    case 7: ChangeVehicleColor(vehicleid, 405, 405);
			    case 8: ChangeVehicleColor(vehicleid, 3, 3);
			    case 9: ChangeVehicleColor(vehicleid, 166, 166);
			    case 10: ChangeVehicleColor(vehicleid, 16, 16);
			    case 11: ChangeVehicleColor(vehicleid, 146, 146);
			}
			ShowPlayerDialog(playerid, 16, DIALOG_STYLE_LIST, "Kolory", "Czarny\nBialy\nSzary\nZolty\nNiebieski\nBlekitny\nGranatowy\nFiloetowy\nCzerwony\nJasny Czerwony\nZielony\nRozowy", "Wybierz", "Wróæ");		}else{
			ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Tuning Menu", "Felgi\nKolory\nHydraulika\nNitro\nStereo\nPaint Job", "Wybierz", "Anuluj");
		}
		return 1;
	}
	if(dialogid == 17){
		if(response){

			if(listitem == 0){

				if (logged[playerid]) {
					new string[270];
					new Float:sec = TimePlay[playerid];
					sec = sec/60;
					sec = sec - (TimePlay[playerid]/60);
					sec = 60*sec;
					new a = SoloScore[playerid];
					new b = DragTime[playerid]/1000;
					new c = DragTime[playerid]-((DragTime[playerid]/1000)*1000);

					format(string, sizeof(string), "Zabitych: %d\nZabitych pod rzad: %d\nSmierci: %d\nSamobojstwa: %d\nTwoje wszystkie pieniadze: $%d\nNagroda za twoja smierc:	$%d\nLaczny czas grania: %d godzin, %d minut\nWynik z Areny Solo: %d\nNajlepszy czas na Dragu: %d:%03d", kills[playerid],killsinarow[playerid],deaths[playerid],suicides[playerid],GetPlayerMoney(playerid)+bank[playerid],bounty[playerid],TimePlay[playerid]/60,floatround(sec),a,b,c);
					ShowPlayerDialog(playerid,18,0,"Twoje Statystyki:",string,"Cofnij","Wyjscie");
				}else{
					SendClientMessage(playerid,COLOR_RED2,"Nie jestes zarejestrowany/a i nie masz swoich statystyk!");
					ShowPlayerDialog(playerid,17,2,"Panel Statystyk","Twoje Statystyki \nStatystyki Serwa \nRespekt Top10 \nKillers Top10 \nDrag TOP-10 \nArena Solo TOP-10","Dalej","Wyjdz");
				}


			}else if(listitem == 1){

				new string[256];
				format(string, sizeof(string), "Zarejestrowanych: %d\nRekord graczy: %d\nZabojstw: %d\nsmierci: %d\nSamobojstw: %d\nKickow: %d\nBanow: %d\nWejsc na serwer: %d\nRekord graczy ustanowiono w dniu: %s",users,rekordgraczy,globkills,globdeaths,globsuicides,kicks,bans,joins, GetServerData ("mostonlinedate"));
				ShowPlayerDialog(playerid,19,0,"Statystyki Serwera:",string,"Cofnij","Wyjscie");
			}
			if(listitem == 2){
				if(!Top10Block[0]){

					Top10Block[0] = true;
					SetTimerEx("Top10Unlock",300000,0,"i",0);
					strdel(Top10Text[0],0,512);
					
					mysql_query("SELECT Nick, Score FROM fg_Players ORDER BY `Score` DESC LIMIT 10;");
					mysql_store_result ();
					new str[62], nick[21], score;
					for (new i, x = mysql_num_rows (); i < x; i++) {
						mysql_fetch_row(str, "|",MySQLcon);
						sscanf (str, "p<|>s[21]d", nick, score);
						format (Top10Text[0], 512, "%s\n%d.\t%s - %i", Top10Text[0], i+1, nick, score);
					}
					mysql_free_result(MySQLcon);
				}

				ShowPlayerDialog(playerid,20,0,"Respekt TOP-10:",Top10Text[0],"Cofnij","Wyjscie");
			}else if(listitem == 3){
				if(!Top10Block[1]){

					Top10Block[1] = true;
					SetTimerEx("Top10Unlock",300000,0,"i",1);
					strdel(Top10Text[1],0,512);

					mysql_query("SELECT Nick, Kills FROM fg_Players ORDER BY `Kills` DESC LIMIT 10;");
					mysql_store_result ();
					new str[62], nick[21], topkills;
					for (new i, x = mysql_num_rows (); i < x; i++) {
						mysql_fetch_row(str, "|",MySQLcon);
						sscanf (str, "p<|>s[21]d", nick, topkills);
						format (Top10Text[1], 512, "%s\n%d.\t%s - %i", Top10Text[1], i+1, nick, topkills);
					}
					mysql_free_result(MySQLcon);
				}

				ShowPlayerDialog(playerid,21,0,"Killers TOP-10:",Top10Text[1],"Cofnij","Wyjscie");

			}else if(listitem == 4){
				if(!Top10Block[2]){

					Top10Block[2] = true;
					SetTimerEx("Top10Unlock",300000,0,"i",2);
					strdel(Top10Text[2],0,512);

					mysql_query("SELECT Nick, Drag FROM fg_Players ORDER BY `Drag` ASC LIMIT 10;");
					mysql_store_result ();
					new i;
					new str[62], nick[21], dragtime;
					
					for (new x = mysql_num_rows (); x >= 0; x--) {
						mysql_fetch_row(str, "|",MySQLcon);
						sscanf (str, "p<|>s[21]d", nick, dragtime);
						if (dragtime == 100000) continue;
						if (i == 0) 
							format (Top10Text[2], 512, "%s\n%d.\t%s - %02d.%03d (rekord)", Top10Text[2], i+1, nick, dragtime/1000, dragtime - ((dragtime/1000)*1000));
						else
							format (Top10Text[2], 512, "%s\n%d.\t%s - %02d.%03d", Top10Text[2], i+1, nick, dragtime/1000, dragtime - ((dragtime/1000)*1000));
						i++;
					}
					mysql_free_result(MySQLcon);
				}
			

				ShowPlayerDialog(playerid,21,0,"Drag TOP-10:",Top10Text[2],"Cofnij","Wyjscie");


			}else if(listitem == 5){
				if(!Top10Block[3]){

					Top10Block[3] = true;
					SetTimerEx("Top10Unlock",300000,0,"i",3);
					strdel(Top10Text[3],0,512);

					mysql_query("SELECT Nick, Arena FROM fg_Players ORDER BY `Arena` DESC LIMIT 10;");
					mysql_store_result ();
					new str[62], nick[21], score;
					for (new i, x = mysql_num_rows (); i < x; i++) {
						mysql_fetch_row(str, "|",MySQLcon);
						sscanf (str, "p<|>s[21]d", nick, score);
						format (Top10Text[3], 512, "%s\n%d.\t%s - %d", Top10Text[3], i+1, nick, score);
					}
					
					mysql_free_result(MySQLcon);
				}

				ShowPlayerDialog(playerid,25,0,"Arena Solo TOP-10:",Top10Text[3],"Cofnij","Wyjscie");

			} else if(listitem == 6){
				if(!Top10Block[4]){

					Top10Block[4] = true;
					SetTimerEx("Top10Unlock",300000,0,"i",4);
					strdel(Top10Text[4],0,512);

					mysql_query("SELECT Nick, Time FROM fg_Players ORDER BY `Time` DESC LIMIT 10;");
					mysql_store_result ();
					new str[62], nick[21], time, minuty;
					
					/*
						select Nick, Time, FLOOR(Time/60) as godziny, FLOOR((Time/60/60))*60 as minuty from fg_Players order by Time desc limit 10;
					*/
					
					for (new i, x = mysql_num_rows (); i < x; i++) {
						mysql_fetch_row(str, "|",MySQLcon);
						sscanf (str, "p<|>s[21]d", nick, time);
						minuty = floatround(time%60);
						format (Top10Text[4], 512, "%s\n%d.\t%s	-- %02dgodz. i %02dmin.", Top10Text[4], i+1, nick, time/60, minuty);
					}
					
					mysql_free_result(MySQLcon);
				}

				ShowPlayerDialog(playerid,25,0,"Czas Grania TOP-10:",Top10Text[4],"Cofnij","Wyjscie");


			} else if(listitem == 7)
			{
				if(!Top10Block[5])
				{
					Top10Block[5] = true;
					SetTimerEx("Top10Unlock",300000,0,"i",5);
					strdel(Top10Text[5],0,512);
					
					mysql_query("SELECT Nick, Ilosc FROM kody ORDER BY Ilosc DESC LIMIT 10;");
					mysql_store_result();
					
					new str[64], nick[24], ilosc;
					for (new i, x = mysql_num_rows (); i < x; i++) 
					{
						mysql_fetch_row(str, "|", MySQLcon);
						sscanf(str, "p<|>s[24]d", nick, ilosc);
						format(Top10Text[5], 512, "%s\n%d.\t%s -- %d", Top10Text[5], i+1, nick, ilosc);
					}
					mysql_free_result(MySQLcon);
				}

				ShowPlayerDialog(playerid,25,0,"Przepisanych testów reakcji:",Top10Text[5],"Cofnij","Wyjscie");
			}
		}
		return 1;
	}
	if(dialogid == 18){
		if(response){
			ShowPlayerDialog(playerid,17,2,"Panel Statystyk","Twoje Statystyki \nStatystyki Serwa \nRespekt TOP-10 \nKillers TOP-10 \nDrag TOP-10 \nArena Solo TOP-10 \nCzas Grania TOP-10\nTest Reakcji TOP-10","Dalej","Wyjdz");
		}
		return 1;
	}

	if(dialogid == 19){
		if(response){
			ShowPlayerDialog(playerid,17,2,"Panel Statystyk","Twoje Statystyki \nStatystyki Serwa \nRespekt TOP-10 \nKillers TOP-10 \nDrag TOP-10 \nArena Solo TOP-10 \nCzas Grania TOP-10\nTest Reakcji TOP-10","Dalej","Wyjdz");
		}
		return 1;
	}

	if(dialogid == 20){
		if(response){
			ShowPlayerDialog(playerid,17,2,"Panel Statystyk","Twoje Statystyki \nStatystyki Serwa \nRespekt TOP-10 \nKillers TOP-10 \nDrag TOP-10 \nArena Solo TOP-10 \nCzas Grania TOP-10\nTest Reakcji TOP-10","Dalej","Wyjdz");
		}
		return 1;
	}

	if(dialogid == 21){
		if(response){
			ShowPlayerDialog(playerid,17,2,"Panel Statystyk","Twoje Statystyki \nStatystyki Serwa \nRespekt TOP-10 \nKillers TOP-10 \nDrag TOP-10 \nArena Solo TOP-10 \nCzas Grania TOP-10\nTest Reakcji TOP-10","Dalej","Wyjdz");
		}
		return 1;
	}

	if(dialogid == 25){
		if(response){
			ShowPlayerDialog(playerid,17,2,"Panel Statystyk","Twoje Statystyki \nStatystyki Serwa \nRespekt TOP-10 \nKillers TOP-10 \nDrag TOP-10 \nArena Solo TOP-10 \nCzas Grania TOP-10\nTest Reakcji TOP-10","Dalej","Wyjdz");
		}
		return 1;
	}

//dialogid 22 jest tylko do odczytu

	if(dialogid == 23){
		if(response){
			foreachPly (x) {
				SetPlayerVirtualWorld(x,WorldChange);
			}
			new string2[128];
			format(string2, sizeof(string2), "Admin {FF0000}%s {AA3333}zmieni³/a wszystkim Virtual Worlda na {FF0000}%d", PlayerName(playerid),WorldChange);
			SendClientMessageToAll(COLOR_RED, string2);
            SoundForAll(1150);

		}else{
			WorldChange = 0;
		}
		return 1;
	}
	if(dialogid == 24){
		if(response){

			if(!SoloON){
				SendClientMessage(SoloWyzywa[playerid],COLOR_GREEN,"Przeciwnik zaakceptowa³ wyzwanie!");
				new x = SoloWyzywa[playerid];
				StartSolo(playerid,x,SoloBron[x]);
			}else{
				SendClientMessage(SoloWyzywa[playerid],COLOR_RED2,"Przeciwnik zaakceptowa³ wyzwanie, jednak ktoœ ju¿ wczeœniej rozpocz¹³ solowke");
				SendClientMessage(playerid,COLOR_RED2,"Ju¿ trwa jakaœ solówka!");
			}

		}else{
			SendClientMessage(SoloWyzywa[playerid],COLOR_RED2,"Przeciwnik nie zaakceptowa³ twojego wyzwania!");
		}

		return 1;
	}
	if(dialogid == 28){
		if(response){

			if(listitem == 0){
				ShowPlayerDialog(playerid, 29, 0, "Wszystkie TextDrawy"," ","ON","OFF");
				PanelID[playerid] = 0;
			}
			if(listitem == 1){
				ShowPlayerDialog(playerid, 29, 0, "Zegar"," ","ON","OFF");
				PanelID[playerid] = 1;
			}
			if(listitem == 2){
				ShowPlayerDialog(playerid, 29, 0, "Pasek Stanu"," ","ON","OFF");
				PanelID[playerid] = 2;
			}
			if(listitem == 3){
				ShowPlayerDialog(playerid, 29, 0, "Nazwa Serwa"," ","ON","OFF");
				PanelID[playerid] = 3;
			}
			if(listitem == 4){
				ShowPlayerDialog(playerid, 29, 0, "Tabelka Chowanego"," ","ON","OFF");
				PanelID[playerid] = 4;
			}
			if(listitem == 5){
				ShowPlayerDialog(playerid, 29, 0, "Ogloszenia"," ","ON","OFF");
				PanelID[playerid] = 5;
			}
			if(listitem == 6){
				ShowPlayerDialog(playerid, 29, 0, "Glosowania"," ","ON","OFF");
				PanelID[playerid] = 6;

			}
			if(listitem == 7){
				ShowPlayerDialog(playerid, 29, 0, "Tabelka Zapisow"," ","ON","OFF");
				PanelID[playerid] = 7;

			}
			if(listitem == 8){
				ShowPlayerDialog(playerid, 29, 0, "Status pojazdu"," ","ON","OFF");
				PanelID[playerid] = 8;
			}
			if(listitem == 9){
				ShowPlayerDialog(playerid, 29, 0, "Podpowiedzi"," ","ON","OFF");
				PanelID[playerid] = 9;
			}
			if(listitem == 10){
				ShowPlayerDialog(playerid, 29, 0, "Gwiazdki (Levele)"," ","ON","OFF");
				PanelID[playerid] = 10;
			}
		}
		return 1;
	}
	if(dialogid == 29){
		if(response){

			if(PanelID[playerid] == 0){

				SendClientMessage(playerid, COLOR_GREEN, "Wszystkie TextDrawy w³¹czone!");
				Hudded[playerid] = false;

   				TextDrawShowForPlayer(playerid,logoFullGaming);
				TextDrawShowForPlayer(playerid,urlFullGaming);
				ShowPlayerPasek(playerid);
				TextDrawShowForPlayer(playerid, Czas);


				TextDrawShowForPlayer(playerid, tabelka_zapisow_box);
				TextDrawShowForPlayer(playerid, tabelka_zapisow_label[0]);
				TextDrawShowForPlayer(playerid, tabelka_zapisow_label[1]);

				if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER){
					PlayerTextDrawShow(playerid, playerTd_carname[playerid]);
					PlayerTextDrawShow(playerid, playerTd_carspeed[playerid]);
					PlayerTextDrawShow(playerid, playerTd_carhealth[playerid]);
                    TextDrawShowForPlayer(playerid, car_box);
				}

				CarInfoChce[playerid] = true;
				ChceAnn[playerid] = true;

				VoteChce[playerid] = true;

				if(VoteON){
					TextDrawShowForPlayer(playerid,Glosowanie);
				}


			}else if(PanelID[playerid] == 1){

				SendClientMessage(playerid, COLOR_GREEN, "Zegar w³¹czony!");
				TextDrawShowForPlayer(playerid, Czas);

			}else if(PanelID[playerid] == 2){

				SendClientMessage(playerid, COLOR_GREEN, "Pasek Stanu w³¹czony!");
				ShowPlayerPasek(playerid);

			}else if(PanelID[playerid] == 3){

				SendClientMessage(playerid, COLOR_GREEN, "Nazwa Serwa w³¹czona!");

			}else if(PanelID[playerid] == 4){

				SendClientMessage(playerid, COLOR_GREEN, "Tabela Chowanego w³¹czona!");


			}else if(PanelID[playerid] == 5){

				SendClientMessage(playerid, COLOR_GREEN, "Og³oszenia w³¹czone!");
				ChceAnn[playerid] = true;


			}else if(PanelID[playerid] == 6){

				SendClientMessage(playerid, COLOR_GREEN, "G³osowania w³¹czone!");
				VoteChce[playerid] = true;

				if(VoteON){
					TextDrawShowForPlayer(playerid,Glosowanie);
				}


			}else if(PanelID[playerid] == 7){

				TextDrawShowForPlayer(playerid, tabelka_zapisow_box);
				TextDrawShowForPlayer(playerid, tabelka_zapisow_label[0]);
				TextDrawShowForPlayer(playerid, tabelka_zapisow_label[1]);


				SendClientMessage(playerid, COLOR_GREEN, "Tabelka Zapisów w³¹czona!");

			}else if(PanelID[playerid] == 8){

				if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER){
					PlayerTextDrawShow(playerid, playerTd_carname[playerid]);
					PlayerTextDrawShow(playerid, playerTd_carspeed[playerid]);
					PlayerTextDrawShow(playerid, playerTd_carhealth[playerid]);
                    TextDrawShowForPlayer(playerid, car_box);
				}
				CarInfoChce[playerid] = true;
				SendClientMessage(playerid, COLOR_GREEN, "Status pojazdu w³¹czony!");

			}else if(PanelID[playerid] == 9){

				SendClientMessage(playerid, COLOR_GREEN, "Podpowiedzi w³¹czone!");

			}else if(PanelID[playerid] == 10){

				SendClientMessage(playerid, COLOR_GREEN, "(Gwiazdki) Levele w³¹czone!");

			}
		}else{
			if(PanelID[playerid] == 0){

				SendClientMessage(playerid, COLOR_GREEN, "Wszystkie TextDrawy wy³¹czone!");

				HidePlayerPasek(playerid);
   				Hudded[playerid] = true;

   				TextDrawHideForPlayer(playerid,logoFullGaming);
				TextDrawHideForPlayer(playerid,urlFullGaming);
				TextDrawHideForPlayer(playerid, Czas);

				TextDrawHideForPlayer(playerid, tabelka_zapisow_box);
				TextDrawHideForPlayer(playerid, tabelka_zapisow_label[0]);
				TextDrawHideForPlayer(playerid, tabelka_zapisow_label[1]);
			//	for(new x=0;x<10;x++)
			//	{
			//		TextDrawHideForPlayer(playerid,ZapisyBack[x]);
			//	}


				PlayerTextDrawHide(playerid, playerTd_carname[playerid]);
				PlayerTextDrawHide(playerid, playerTd_carspeed[playerid]);
				PlayerTextDrawHide(playerid, playerTd_carhealth[playerid]);
				TextDrawHideForPlayer(playerid, car_box);

				CarInfoChce[playerid] = false;

				ChceAnn[playerid] = false;

				VoteChce[playerid] = false;

				if(VoteON){
					TextDrawHideForPlayer(playerid,Glosowanie);
				}


			}else if(PanelID[playerid] == 1){

				SendClientMessage(playerid, COLOR_GREEN, "Zegar wy³¹czony!");
				TextDrawHideForPlayer(playerid, Czas);

			}else if(PanelID[playerid] == 2){

				SendClientMessage(playerid, COLOR_GREEN, "Pasek Stanu wy³¹czony!");
				HidePlayerPasek(playerid);

			}else if(PanelID[playerid] == 3){

				SendClientMessage(playerid, COLOR_GREEN, "Nazwa Serwa wy³¹czona!");

			}else if(PanelID[playerid] == 4){


			}else if(PanelID[playerid] == 5){

				SendClientMessage(playerid, COLOR_GREEN, "Og³oszenia wy³¹czone!");
				ChceAnn[playerid] = false;


			}else if(PanelID[playerid] == 6){

				SendClientMessage(playerid, COLOR_GREEN, "G³osowania wy³¹czone!");
				VoteChce[playerid] = false;

				if(VoteON){
					TextDrawHideForPlayer(playerid,Glosowanie);
				}

			}else if(PanelID[playerid] == 7){
	
				TextDrawHideForPlayer(playerid, tabelka_zapisow_box);
				TextDrawHideForPlayer(playerid, tabelka_zapisow_label[0]);
				TextDrawHideForPlayer(playerid, tabelka_zapisow_label[1]);
		//	for(new x=0;x<10;x++)
		//	{
		//		TextDrawHideForPlayer(playerid,ZapisyBack[x]);
		//	}

			SendClientMessage(playerid, COLOR_GREEN, "Tabelka Zapisów wy³¹czona!");

			}else if(PanelID[playerid] == 8){

				PlayerTextDrawHide(playerid, playerTd_carname[playerid]);
				PlayerTextDrawHide(playerid, playerTd_carspeed[playerid]);
				PlayerTextDrawHide(playerid, playerTd_carhealth[playerid]);
				TextDrawHideForPlayer(playerid, car_box);

			    CarInfoChce[playerid] = false;
				SendClientMessage(playerid, COLOR_GREEN, "Status pojazdu wy³¹czony!");

			}else if(PanelID[playerid] == 9){
				SendClientMessage(playerid, COLOR_GREEN, "Podpowiedzi wy³¹czone!");

			}else if(PanelID[playerid] == 10){

			SendClientMessage(playerid, COLOR_GREEN, "(Gwiazdki) Levele wy³¹czone!");

			}
		}
		ShowPlayerDialog(playerid, 28, DIALOG_STYLE_LIST, "Zarzadzanie TextDrawami!", "Wszystkie \nZegar \nPasek Stanu \nNazwa Serwa \nTabelka Chowanego \nOgloszenia \nGlosowanie \nTabelka Zapisow \nStatus pojazdu\nPodpowiedzi\nGwiazdki (Levele)", "OK", "Anuluj");
		return 1;
	}
	if(dialogid == 30){
		if(response){

			if(listitem == 0){
    			new StrinG[2400];
				StrinG = "{717C89}/CarDive {FFFFFF}- wystrzeliwujesz w gore pojazd i spadasz\n";
				strcat(StrinG,"{717C89}/100hp {FFFFFF}- uleczasz sie\n");
                strcat(StrinG,"{717C89}/BuyWeapon [ID] [Ammo] {FFFFFF}- kupujesz broñ na spawn\n");
				strcat(StrinG,"{717C89}/Armour {FFFFFF}- dostajesz kamizelkê kuloodporn¹\n");
				strcat(StrinG,"{717C89}/Dotacja {FFFFFF}- dostajesz kasê\n");
				strcat(StrinG,"{717C89}/Pojazdy {FFFFFF}- lista pojazdow do kupienia\n");
				strcat(StrinG,"{717C89}/Posiadlosci /Posiadlosci2 {FFFFFF}- pokazuje liste i wlascicieli biznesow\n");
				strcat(StrinG,"{717C89}/NRG {FFFFFF}- dostajesz motor NRG-500\n");
				strcat(StrinG,"{717C89}/Kill {FFFFFF}- popelniasz samobojstwo\n");
				strcat(StrinG,"{717C89}/Tune {FFFFFF}- tuningujesz swój pojazd\n");
				strcat(StrinG,"{717C89}/TuneMenu {FFFFFF}- otwiera menu z opcjami tuningu pojazdu\n");
				strcat(StrinG,"{717C89}/Flip {FFFFFF}- stawiasz swój pojazd na kola\n");
				strcat(StrinG,"{717C89}/NOS {FFFFFF}- wstawiasz do pojazdu nitro\n");
				strcat(StrinG,"{717C89}/ZW /JJ /Siema /Nara /Witam /Pa {FFFFFF}- wiadomo o co chodzi...\n");
				strcat(StrinG,"{717C89}/Napraw {FFFFFF}- naprawiasz swój pojazd\n");
				strcat(StrinG,"{717C89}/SavePos {FFFFFF}- ustawiasz chwilowy teleport dla wszystkich\n");
				strcat(StrinG,"{717C89}/TelPos {FFFFFF}- teleportujesz sie do chwilowego teleportu\n");
				strcat(StrinG,"{717C89}/SP {FFFFFF}- zapisujesz swój prywatny teleport\n");
				strcat(StrinG,"{717C89}/LP {FFFFFF}- teleportujesz sie to swojego teleportu\n");
				strcat(StrinG,"{717C89}/Raport [ID_gracza] [powod] {FFFFFF}- wysylasz raport adminowi na gracza \n");
				strcat(StrinG,"{717C89}/Odlicz {FFFFFF}- wlaczasz odliczanie\n");
				strcat(StrinG,"{717C89}/StylWalki {FFFFFF}- wybierasz swój styl walki\n");
				strcat(StrinG,"{717C89}/Rozbroj {FFFFFF}- rozbrajasz siebie\n");
				strcat(StrinG,"{717C89}/RespektHelp {FFFFFF}- informacja co to jest respekt\n");
				strcat(StrinG,"{717C89}/VipInfo {FFFFFF}- poznaj mo¿liwoœæi vipa\n ");
	            strcat(StrinG,"{717C89}/ModInfo {FFFFFF}- sprawdzasz mo¿liwoœæi moderatora\n");
				strcat(StrinG,"{717C89}/Autor {FFFFFF}- pokazuje autora tego gamemoda\n");
                strcat(StrinG,"{717C89}/Skin [id] {FFFFFF}- zmieniasz sobie skina podajac jego ID\n");
                strcat(StrinG,"\n");
				strcat(StrinG,"{FF0000}/Komendy2 {FFFFFF}- Druga lista komend");

				ShowPlayerDialog(playerid,32,0,"Komendy graczy",StrinG,"Cofnij",">>>");

			}else if(listitem == 1){

				if(!IsAdmin(playerid,2) && !IsVIP(playerid)){
					SendClientMessage(playerid,COLOR_RED2," * Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
					ShowPlayerDialog(playerid,30,2,"| FullGaming | POMOC","Komendy> Gracz \nKomendy> VIP\nKomendy> Admin \nKomendy> Konto \nKomendy> Dom \nKomendy> Gang \nKomendy> Respekt \nKomendy> Animacje \nKomendy> Teleporty \nKomendy> Atrakcje \nPANEL> Gangi\nPANEL> TextDrawy\nINFO> Regulamin\nINFO> Respekt\nINFO> Gwiazdki (Levele)\nINFO> Konto VIP\nINFO> Nowosci\nINFO> Autor","Dalej","Wyjdz");
					return 1;
				}
				new string[2000];

			    strcat(string,"{FFFF00}/StartEv {FFFFFF}- Startujesz zabawe!!!\n");
                strcat(string,"{FFFF00}/vGranaty {FFFFFF}- Granaty specjalnie dla VIP.\n");
				strcat(string,"{FFFF00}/Vjetpack {FFFFFF}- Dajesz jetpacka!!! NOWE\n");
			    strcat(string,"{FFFF00}/Vdotacja {FFFFFF}- dostajesz 1 mln kiedy zechcerz!!! NOWE\n");
				strcat(string,"{FFFF00}/Vinvisible {FFFFFF}- Jesteœ niewidzialny na mapie!!! NOWE\n");
				strcat(string,"{FFFF00}/ogloszenie {FFFFFF}- Piszesz na srodku ekranu jako VIP!!! NOWE\n");
				strcat(string,"{FFFF00}/Vpozostalo {FFFFFF}- Sprawdzasz waznosc swojego konta VIP\n");
				strcat(string,"{FFFF00}/Cars {FFFFFF}- lista pojazdow do spawnowania\n");
				strcat(string,"{FFFF00}/Vcar [nazwa] {FFFFFF}- spawnujesz dowolny pojazd podajac jego nazwe\n");
				strcat(string,"{FFFF00}/Vzestaw  {FFFFFF}- Dostajesz zestaw broni Vip'a\n");
				strcat(string,"{FFFF00}/Vgivecash [id] [kwota] {FFFFFF}- Dajesz wybranemu graczowi kase\n");
				strcat(string,"{FFFF00}/Vsettime [godzina] {FFFFFF}- Ustawiasz godzine na serwerze\n");
				strcat(string,"{FFFF00}/Vbron [id_broni] [ammo]  {FFFFFF}- Dajesz sobie dowolna bron\n");
				strcat(string,"{FFFF00}/Vlistabroni {FFFFFF}- Lista ID wszyskich broni\n");
				strcat(string,"{FFFF00}/Vsay [tekst] {FFFFFF}- Piszesz na czacie jako VIP-MSG\n");
				strcat(string,"{FFFF00}/Pmv [tskst] {FFFFFF}- Piszesz na prywatnym czacie Adminow i Vipow\n");
				strcat(string,"{FFFF00}/Vrepair [id]  {FFFFFF}- Naprawiasz graczowi pojazd\n");
				strcat(string,"{FFFF00}/Vcolor {FFFFFF}- Dajesz sobie zolty kolor vipa\n");
				strcat(string,"{FFFF00}/Vheal [id] {FFFFFF}- Uzdrawiasz gracza\n");
				strcat(string,"{FFFF00}/Varmor {FFFFFF}- Dajesz sobie kamizelke\n");
				strcat(string,"{FFFF00}/VTp [id:1] [id:2] {FFFFFF}- teleportujesz gracza 1 do gracza 2\n\n");
				strcat(string,"___________________________________\n");
				strcat(string,"Pamietaj jednak ze naduzycia zwiazane z tymi komendami\n");
				strcat(string,"moga sie wiazac z odebraniem ci rangi VIP!");

				ShowPlayerDialog(playerid,31,0,"Komendy Vipa",string,"Cofnij","Wyjdz");

			}else if(listitem == 2){

				if(!IsAdmin(playerid,1)){
					SendClientMessage(playerid,COLOR_RED2," * Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
					ShowPlayerDialog(playerid,30,2,"| FullGaming | POMOC","CMD> Gracz \nCMD> VIP\nCMD> Admin \nCMD> Konto \nCMD> Dom \nCMD> Gang \nCMD> Respekt \nCMD> Animacje \nCMD> Teleporty \nCMD> Atrakcje \nPANEL> Gangi\nPANEL> TextDrawy\nINFO> Regulamin\nINFO> Respekt\nINFO> Gwiazdki (Levele)\nINFO> Konto VIP\nINFO> Nowosci\nINFO> Autor","Dalej","Wyjdz");
					return 1;
				}

                new StrinG[3000];

				StrinG = "{FF0000}/CZ - czyscisz caly czat\n";
			    strcat(StrinG,"{FF0000}/Say [tekst] {FFFFFF}- Piszesz informacjê na chacie >>> tekst\n");
			    strcat(StrinG,"{FF0000}/TP [ID:1] [ID:2] {FFFFFF}- Teleportujesz id 1 do id 2\n");
			    strcat(StrinG,"{FF0000}/SetTime [Godzina] {FFFFFF}- Zmieniasz czas na serwerze\n");
			    strcat(StrinG,"{FF0000}/AColor [ID] [ID] {FFFFFF}- Zmieniasz kolor nicku gracza\n");
			    strcat(StrinG,"{FF0000}/Info [ID] {FFFFFF}- Sprawdzasz IP gracza\n");
			    strcat(StrinG,"{FF0000}/P [Nazwa] {FFFFFF}- Spawnujesz pojazd na sta³e\n");
				strcat(StrinG,"{FF0000}/Weather [ID] {FFFFFF}- Zmieniasz pogodê na serwerze\n");
			    strcat(StrinG,"{FF0000}/A [tekst] {FFFFFF}- piszesz na Admin Chacie\n");
			    strcat(StrinG,"{FF0000}/Raports {FFFFFF}- Sprawdzasz zg³oszone raporty\n");
			    strcat(StrinG,"{FF0000}/GiveCash [kasa] {FFFFFF}- Dajesz kasê\n");
			    strcat(StrinG,"{FF0000}/GiveScore [respekt] {FFFFFF}- dajesz respekt\n");
				strcat(StrinG,"{FF0000}/Bomby [on/off] {FFFFFF}- wlaczasz lib wylaczasz mo¿liwoœæ podkladania bomb\n");
			 	strcat(StrinG,"{FF0000}/Freeze50 {FFFFFF}- Zamra¿asz graczy w promieniu 50 metrów.\n");
				strcat(StrinG,"{FF0000}/UnFreeze50 {FFFFFF}- Odmra¿asz graczy w promieniu 50 metrów.\n");
				strcat(StrinG,"{FF0000}/JoinInfo(on/off) {FFFFFF}- wlaczasz/wylaczasz informacje o wchodzeniu graczy\n");
				strcat(StrinG,"{FF0000}/JoinInfoAdmin(on/off) {FFFFFF}- wlaczasz/wylaczasz info o wchodzeniu graczy dla adminow\n");
				strcat(StrinG,"{FF0000}/TT [id_gracza] {FFFFFF}- teleportujesz sie do gracza\n");
				strcat(StrinG,"{FF0000}/TH [id_gracza] {FFFFFF}- teleportujesz gracza do siebie\n");
				strcat(StrinG,"{FF0000}/LockAll {FFFFFF}- zamykasz wszystkie pojazdy\n");
				strcat(StrinG,"{FF0000}/UnLockAll {FFFFFF}- otwierasz wszystkie pojazdy\n");
				strcat(StrinG,"{FF0000}/RspAuta {FFFFFF}- respawn wszystkich pojazdow\n");
				strcat(StrinG,"{FF0000}/RspTrailers {FFFFFF}- respawn wszystkich przyczep\n");
				strcat(StrinG,"{FF0000}/DelTrailers {FFFFFF}- usuwasz stworzone naczepy\n");
				strcat(StrinG,"{FF0000}/DelCar {FFFFFF}- usuwasz pojazd w ktorym jestes\n");
				strcat(StrinG,"{FF0000}/Prot/UnProt [id] {FFFFFF}- dajesz/odbierasz immunitet graczowi \n");
				strcat(StrinG,"{FF0000}/Cenz /Uncenz [id] {FFFFFF}- cenzurujesz/odcenzurowujesz gracza\n");
				strcat(StrinG,"{FF0000}/Spec /Specoff [id] {FFFFFF}- ogladasz/przestajesz ogladac gracza\n");
				strcat(StrinG,"{FF0000}/SVall {FFFFFF}- zapisujesz wszystkim staty\n");
				strcat(StrinG,"{FF0000}/jail [id] [czas]   /UnWiez [id] {FFFFFF}- dajesz/wyciagasz gracza z wiezienia\n");
				strcat(StrinG,"{FF0000}/Mute [id] [czas]   /UnMute [id] {FFFFFF}- uciszasz/odciszasz gracza\n");
				strcat(StrinG,"{FF0000}/Kick [id] [powod] {FFFFFF}- wywalasz gracza z serwa\n");
				strcat(StrinG,"{FF0000}/Ban [id] [powod] {FFFFFF}- banujesz gracza\n");
				strcat(StrinG,"{FF0000}/Explode [id] {FFFFFF}- wysadzasz gracza \n");
				strcat(StrinG,"{FF0000}/Remove [ID] {FFFFFF}- wywalasz gracza z pojazdu\n");
				strcat(StrinG,"{FF0000}/PodgladPM(on/off) {FFFFFF}- wlaczasz/wylaczasz podglad prywatnych wiadomosci");

				ShowPlayerDialog(playerid,DIALOG_ACMD,0,"Komendy administracji",StrinG,"DALEJ","Anuluj");

			}else if(listitem == 3){

				new string[320];
				format(string,sizeof(string),"* /rejestracja  - Rejstracja nowego konta (nicku na ktorym grasz) \n* /logowanie  - Logowanie do konta (Jesli automatycznie nie pokazuje sie okno logowania \n* /ZmienHaslo  - zmiana hasla konta \n* /NowyNick  - przenoszenie statystyk na nowe konto \n\nW przypadku problemow z kontem zglos sie na %s",ServerUrl);
				ShowPlayerDialog(playerid,31,0,"Komendy zarzadzania kontem",string,"Cofnij","Wyjdz");

			}else if(listitem == 4){

				new StrinG[1024];
				StrinG = "* /KupDom  - kupujesz dom \n";
				strcat(StrinG,"* /ZobaczDom  - ogladasz dom od srodka przed kupnem \n");
				strcat(StrinG,"* /SprzedajDom  - sprzedajesz swój dom \n");
				strcat(StrinG,"* /ZamknijDom  - zamykasz dom \n");
				strcat(StrinG,"* /OtworzDom  - otwierasz dom \n");
				strcat(StrinG,"* /AutoDom  - przywolujesz swoje auto przed dom \n");
				strcat(StrinG,"* /ZmienAuto  - zmieniasz auto domowe \n");
				strcat(StrinG,"* /TPdom  - teleport do domu\n");
				strcat(StrinG,"* /Wejdz  - wchodzisz do domu\n");
				strcat(StrinG,"* /Wyjdz - wychodzisz z domu\n\n\n");
				strcat(StrinG,"__[ZARZADZANIE KONTEM DOMOWYM]__\n\n");
				strcat(StrinG,"* /OplacDom [kwota]  - wplacasz na konto domowe Respekt do oplacania czynszu\n");
				strcat(StrinG,"* /WyplacDom [kwota]  - wyplacasz z konta domowego Respekt\n");
				strcat(StrinG,"* /StanKonta  - sprawdzasz stan konta domowego \n\n");
				strcat(StrinG,"Czynsz jest pobierany nawet gdy nie grasz na serwerze!");

				ShowPlayerDialog(playerid,32,0,"Komendy zarzadzania domem",StrinG,"Cofnij","Wyjdz");

			}else if(listitem == 5){

                new StrinG[128];
				StrinG = "* Wszystkie opcje dotyczace gangu znajdziesz w:  /Gang\n\n";
				strcat(StrinG,"! tekst - aby pisac na czacie gangu np.   !siemka");

				ShowPlayerDialog(playerid,31,0,"Komendy zarzadzania gangami",StrinG,"Cofnij","Wyjdz");

			}else if(listitem == 6){

			    new StrinG[256];
				StrinG = "* /rKasa - dostajesz $50 000  (20 pkt. exp)\n";
				strcat(StrinG,"* /rArmor - dostajesz kamizelke (30 pkt. exp)\n");
				strcat(StrinG,"* /rZestaw - dostajesz zestaw broni (50 pkt. exp)\n");
				strcat(StrinG,"* /rInvisible - niewidzialnosc na mapie (15 pkt. exp)\n");
				strcat(StrinG,"* /rDualUzi - podwojne Uzi (100 pkt. exp)\n");
				strcat(StrinG,"* /rDualSO - podwojny obrzyn (100 pkt. exp)");

				ShowPlayerDialog(playerid,31,0,"Komendy za exp",StrinG,"Cofnij","Wyjdz");

			}else if(listitem == 7){

				new StrinG[1024];
				StrinG = "/Rece     /Rece2    /Rece3    /Rece4 \n";
				strcat(StrinG,"/Rece5    /Rece6    /Bar2     /Bar3 \n");
				strcat(StrinG,"/Szafka   /Zegarek  /Lez      /Hide\n");
				strcat(StrinG,"/Rzygaj   /Grubas   /Grubas2  /Taichi\n");
				strcat(StrinG,"/Siadaj   /Chat     /Ratunku  /Kopniak\n");
				strcat(StrinG,"/Dance    /Fucku    /Cellin   /Cellout\n");
				strcat(StrinG,"/Pij      /Smoke    /Fsmoke   /Krzeslo\n");
				strcat(StrinG,"/Krzeslo2 /Calus    /Trup     /Trup2\n");
				strcat(StrinG,"/Wankin   /Wankout  /Deal     /Boks\n");
				strcat(StrinG,"/Lol      /Bomba    /Aresztuj /Opalaj\n");
				strcat(StrinG,"/Opalaj2  /Opalaj3  /Turlaj   /Klaps\n");
				strcat(StrinG,"/Kradnij  /Kaleka   /Swat     /Swat2\n");
				strcat(StrinG,"/Swat3    /Piwo     /Drunk    /Rap\n");
				strcat(StrinG,"/Lookout  /Napad    /Papieros /Cpun\n");
				strcat(StrinG,"/Cpun2    /Cpun3    /Cpun4    /Cpun5\n");
				strcat(StrinG,"/Skok2    /Skok3    /Jedz     /Jedz2\n");
				strcat(StrinG,"/Jedz3    /Wino     /Taniec   /Taniec2\n");
				strcat(StrinG,"/Taniec3  /Taniec4  /Taniec5  /Taniec6\n");
				strcat(StrinG,"/Taniec7  /Rolki    /Sprunk   /Inbedleft\n");
				strcat(StrinG,"/Inbedright /Poddajsie  /Aresztowany  /Aresztuj2");

				ShowPlayerDialog(playerid,31,0,"Animacje",StrinG,"Cofnij","Wyjdz");

			}else if(listitem == 8){

					new string[1300];

                    strcat(string,"/Island /StuntZone /pub /pustynia /gora /City2\n");
					strcat(string,"/Sfinks /WaterLand /MiniPort /Skocznia /Ziolo /Stadion\n");
					strcat(string,"/Part    /NRGPark    /Stunt    /Wyskok /Puszcza\n");
				    strcat(string,"/LV       /LS       /SF       /LVlot /Grecja\n");
					strcat(string,"/SFlot   /LSlot  /Impra    /Kosciol /House /Castle\n");
					strcat(string,"/4smoki   /TuneLV   /TuneSF   /TuneLS /Stunt /\n");
					strcat(string,"/PlazaSF  /Plaza    /Molo     /DB /Lost /Bogowie\n");
					strcat(string,"/VC       /Tama     /Zadupie  /Kart /PodWoda /Labirynt2\n");
					strcat(string,"/Drag     /Zjazd    /Zjazd2   /PGR /Kosmos /Nascar\n");
					strcat(string,"/DD       /g1       /g2       /g3 /HappyLand\n");
					strcat(string,"/g4       /Salon    /Osiedle(1-5) /F1\n");
					strcat(string,"/Stunt    /StuntCity    /Baza(1-4) /Tortury\n");
					strcat(string,"/KSS      /Drift(1-7)  /Zakochani  /Miasteczko /Kanaly\n");
					strcat(string,"/Wiezowiec  /SkatePark /Lot  /Lot2 /Przyszlosc /City /Party\n");
					strcat(string,"/Ammo   /RCshop   /CPN   /CJgarage /tokiodrift\n");
					strcat(string,"/Calligula   /Andromeda   /Wooziebed   /Jaysdin\n");
					strcat(string,"/WOC   /TDdin   /Brothel   /Brothel2 /Rats\n");
				    strcat(string,"/kart2     /citydrift   /Baza5   /Domek\n");
					strcat(string,"/MiniPort       /Afganistan       /Wietnam\n");
					strcat(string,"/Warsztat       /Warsztat2    /Bar\n");
					strcat(string,"/Lot    /Dirt    /Wjazd    /PodWoda /PeronLS /PeronLV /PeronSF\n");
					strcat(string,"Pamietaj to nie wszystkie teleporty! Wiecej pod /Atrakcje");


				ShowPlayerDialog(playerid,31,0,"Teleporty",string,"Cofnij","Wyjdz");

			}else if(listitem == 9){

			    new StrinG[2400];

				StrinG = "{717C89}/MiniPort {FFFFFF}- Ma³e doki portowe z statkiem i skrytk¹\n";
                strcat(StrinG,"{FF0000}/Wieza {FFFFFF}- Wieza Eiffla!\n");
				strcat(StrinG,"{FF0000}/JetArena {FFFFFF}- Arena Jetpack\n");
				strcat(StrinG,"{FF0000}/nBronie {FFFFFF}- Nowe modele broni\n");
				strcat(StrinG,"{717C89}/Lowisko {FFFFFF}- Chcesz lowic ryby? Wejdz tutaj!\n");
				strcat(StrinG,"{717C89}/ArenaDD {FFFFFF}- Demolotion Derby!\n");
				strcat(StrinG,"{717C89}/mGang {FFFFFF}- Gang malinowych ziomków!\n");
	            strcat(StrinG,"{717C89}/nGang {FFFFFF}- Gang niebieskich\n");
				strcat(StrinG,"{717C89}/WaterLand {FFFFFF}- Wodny Park dla samochodów\n");
	            strcat(StrinG,"{717C89}/Park {FFFFFF}- Park wypoczynkowy z ma³ym basenem i dodatkami...\n");
				strcat(StrinG,"{717C89}/Lotto {FFFFFF}- Losowanie lotto\n");
				strcat(StrinG,"{717C89}/Skocznia {FFFFFF}- Skocznia narciarska dla pojazdów\n");
				strcat(StrinG,"{717C89}/CityDrift {FFFFFF}- Tor wyœcigowo driftowy dla pojazdów\n");
				strcat(StrinG,"{717C89}/Tor {FFFFFF}- Tor wyœcigowy\n");
				strcat(StrinG,"{717C89}/Wjazd {FFFFFF}- Drewniany œwiat wjazdów\n");
				strcat(StrinG,"{717C89}/Skok2-9 {FFFFFF}- Skok spadochronowy z du¿ej odleg³oœci\n");
	            strcat(StrinG,"{717C89}/Warsztat {FFFFFF}- Warsztat samochodowy\n");
				strcat(StrinG,"{717C89}/Warsztat2 {FFFFFF}- Warsztat samochodowy lvlot\n");
				strcat(StrinG,"{717C89}/Wyskok {FFFFFF}- Wyskok dla pojazdów\n");
				strcat(StrinG,"{717C89}/Zjazd {FFFFFF}- Zjazd samochodem z ogromnej wysokoœci\n");
				strcat(StrinG,"{717C89}/Zjazd2 {FFFFFF}- Zjazd samochodem z bardzo ogromnej wysokoœci\n");
				strcat(StrinG,"{717C89}/Kart {FFFFFF}- Tor gokartowy na Pla¿y w LS\n");
				strcat(StrinG,"{717C89}/Rury {FFFFFF}- Dynamiczne 3D Rury\n");
				strcat(StrinG,"{717C89}/Stunt {FFFFFF}- Park wyczynowy dla zawodowców\n");
				strcat(StrinG,"{717C89}/Afganistan {FFFFFF}- Wojsko Afganistañskie\n");
				strcat(StrinG,"{717C89}/Wietnam {FFFFFF}- Wietnam wojskowy\n");
				strcat(StrinG,"{717C89}/Minigun {FFFFFF}- Arena minigunowa \n");
				strcat(StrinG,"{717C89}/RPG {FFFFFF}- Arena RPG\n");
				strcat(StrinG,"{717C89}/Arena {FFFFFF}- Arena walk w ciekawym otoczeniu\n");
				strcat(StrinG,"{717C89}/DD {FFFFFF}- Arena Destruction Derby\n");
				strcat(StrinG,"{717C89}/KSS {FFFFFF}- Zawodowy stunt Vice-Stadium\n");
				strcat(StrinG,"{717C89}/Liberty {FFFFFF}- Liberty City w GTA SA\n ");
	            strcat(StrinG,"{717C89}/G1-5 {FFFFFF}- Parkingi samochodowe\n");
				strcat(StrinG,"{717C89}/Forteca {FFFFFF}- Forteca ufortyfikowana otwierana od wewn¹trz\n");
	            strcat(StrinG,"{717C89}/Baza1-5 {FFFFFF}- Ufortyfikowane bazy graczy z wieloma mo¿liwoœciami\n");
				strcat(StrinG,"{717C89}/Atrakcje2 {FFFFFF}- Tutaj znajdziesz dalsz¹ listê atrakcji serwera");

				ShowPlayerDialog(playerid,31,0,"Atrakcje Serwera FullGaming",StrinG,"Dalej","Wyjdz");

			}else if(listitem == 10){

				ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");

			}else if(listitem == 11){

				ShowPlayerDialog(playerid, 28, DIALOG_STYLE_LIST, "Zarzadzanie TextDrawami!", "Wszystkie \nZegar \nPasek Stanu \nNazwa Serwa\nTabelka Chowanego \nOgloszenia \nGlosowanie \nTabelka Zapisow \nStatus pojazdu\nPodpowiedzi\nGwiazdki (Levele)", "OK", "Anuluj");

			}else if(listitem == 12){

				new string[512];
				format(string,sizeof(string),"1. Zakaz u¿ywania cheatów/spamerów/trainerow etc.\n2. Zakaz podszywania siê pod graczy/administracjê.\n3. Nie zabijaj w strefie 'Bez DM'\n4. Bronie specjalne u¿ywaj tylko w 'Strefie Œmierci'\n5. Nie dokuczaj innym graczom.\n6. Nie buguj serwera!");
				ShowPlayerDialog(playerid,31,0,"Regulamin Serwera",string,"Cofnij","WyjdŸ");

			}else if(listitem == 13){

			    new string[800];

				strcat(string,"Dzieki punktom exp zdobywasz nowe poziomy (levele),(Gwiazdki)\n");
			    strcat(string,"Respekt to twoj szacunek wobec innych graczy\n");
				strcat(string,"Im wiêkszy masz level tym lepsze rzeczy dostajesz na spawnie\n");
				strcat(string,"Jeœli chcesz zobaczyc jakie to sa rzeczy wpisz:  /gwiazdki\n");
				strcat(string,"Respekt mozesz wykorzystac na specjalne komendy:  /Rcmd\n");
				strcat(string,"Punktami exp mozesz oplacac wynajmowany dom\n\n");
				strcat(string,"JAK ZDOBYWAC RESPEKT?\n\n");
				strcat(string,"- Za zabijanie innych graczy (pamietajac o tym ze nie wszedzie mozna to robic)\n");
				strcat(string,"- Za wygrywanie na atrakcjach, np. /WG /CF /DB  (zobacz /Atrakcje)\n");
				strcat(string,"- Respekt otrzymujesz dodatkowo po prostu za to ze grasz u nas!\n");
				strcat(string,"- Za godzine grania wychodzi 50 exp\n");
				strcat(string,"- Za pelna godzine grania (bez wychodzenia) jest premia dodatkowo 100 exp!\n");
				strcat(string,"- Jesli twoj nick rozpoczyna sie tagiem [FGS] otrzymujesz 100 procent wiecej pkt exp za czas grania (150)!");

				ShowPlayerDialog(playerid,31,0,"INFO> Level",string,"OK","OK");

			}else if(listitem == 14){

			    new string[1000];

				strcat(string,"Level - 1. (od 50 exp) - dodatkowo $40 000 na spawnie\n");
				strcat(string,"Level - 2. (od 100 exp)\n");
				strcat(string,"Level - 3. (od 200 exp) - dodatkowo 10 procent kamizelki na spawnie\n");
				strcat(string,"Level - 4. (od 400 exp)\n");
				strcat(string,"Level - 5. (od 800 exp) - dodatkowo $80 000 na spawnie\n");
				strcat(string,"Level - 6. (od 1600 exp)\n");
				strcat(string,"Level - 7. (od 3000 exp) - dodatkowo CombatShotgun na spawnie\n");
				strcat(string,"Level - 8. (od 5000 exp)\n");
				strcat(string,"Level - 9. (od 8000 exp) - dodatkowo po³owa kamizelki na spawnie\n");
				strcat(string,"Level - 10. (od 12000 exp)\n");
				strcat(string,"Level - 11. (od 15000 exp) - dodatkowo ca³a kamizelka na spawnie\n");
			    strcat(string,"Level - 12. (od 17000 exp)\n");
			    strcat(string,"Level - 13. (od 19000 exp) - dodatkowo $100 000 na spawnie\n");
			    strcat(string,"Level - 14. (od 21000 exp)\n");
			    strcat(string,"Level - 15. (od 23000 exp) - dodatkowo M4 na spawnie\n");
			    strcat(string,"Level - 16. (od 26000 exp)\n");
			    strcat(string,"Level - 17. (od 30000 exp) - dodatkowo pistolet z t³umikiem na spawnie\n");
			    strcat(string,"Level - 18. (od 40000 exp)\n");
				strcat(string,"Level - 19. (od 50000 exp) - Specjalna ranga (Skiller)");
			    strcat(string,"Level - 20. (od 70000 exp) - dodatkowo Ladunki Wybuchowe na spawnie");

				ShowPlayerDialog(playerid,31,0,"INFO> Level",string,"OK","OK");

			}else if(listitem == 15){

                new string[1000];

				strcat(string,"{FFFFFF}----------------Konto Premium {FFFF00}VIP{FFFFFF}----------------\n\n");
				strcat(string,"{FFFFFF}* Ranga na chacie {FFFF00}(VIP): tekst\n");
				strcat(string,"{FFFF00}* Mozliwosc pisania na srodku ekranu\n");
				strcat(string,"{FFFF00}* Teleportowanie siê do innych bez pytania\n");
				strcat(string,"{FFFF00}* Dodawanie sobie dowolnej broni wraz z amunicja\n");
				strcat(string,"{FFFF00}* Dodawanie sobie nielimitowanej ilosci pieniedzy\n");
				strcat(string,"{FFFF00}* Dodawanie innym ograniczana ilosc pieniedzy\n");
				strcat(string,"{FFFF00}* Ustawianie dowolnej godziny na serwerze\n");
				strcat(string,"{FFFF00}* Szacunek z strony innych\n");
				strcat(string,"{FFFF00}* Pisanie na prywatnym czacie Vipow i Adminow\n");
				strcat(string,"{FFFF00}* Naprawianie pojazdu dowolnemu graczowi za darmo\n");
				strcat(string,"{FFFF00}* Posiadanie wyrozniajacego sie koloru Zoltego\n");
				strcat(string,"{FFFF00}* Posiadanie napisu Konto Premium nad nickiem\n");
				strcat(string,"{FFFF00}* Uzdrawianie dowolnego gracza za darmo\n");
				strcat(string,"{FFFF00}* Dodawanie sobie kamizelki kuloodpornej za darmo\n");
				strcat(string,"{FFFF00}* Teleportowanie jednego gracza do drugiego\n\n\n");
				strcat(string,"{FFFF00}______________________________________________\n");
				strcat(string,"{FFFFFF}Jesli jestes zainteresowany posiadaniem konta VIP\n");
				strcat(string,"{FFFF00}Odwiedzaj nasza strone: ");
				strcat(string,ServerUrl);

				ShowPlayerDialog(playerid,31,0,"INFO> Konto VIP",string,"Cofnij","Wyjdz");
			}else if(listitem == 16){

                new StrinG[1024];
				StrinG = "{FFFFFF}- {FFFF00}Dodano strefê Bez DM i Strefê œmierci.\n";
                strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano ka¿d¹ rangê obok nicku na czacie.\n");
                strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano znaczn¹ iloœæ komend VIP.\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano nowe bronie do (/Bronie).\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Status wyscigu znajduje siê nad licznikiem.\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano pasek podpowiedzi na dole ekranu.\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano nowe areny do (/WG).\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Ulepszono liste obecnych adminow (/Admins).\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano nowy system gangow (/Gang).\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano nowy system nitro (na trzymanie klawisza).\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Dodano pasek stanu pojazdu (licznik itd.).\n");
				strcat(StrinG,"{FFFFFF}- {FFFF00}Calkiem nowe kolory szaty graficznej.");

				ShowPlayerDialog(playerid,31,0,"Lista 10 ostatnich zmian na serwerze:",StrinG,"Cofnij","Wyjdz");

			}else if(listitem == 17){

			   	cmd_autor (playerid, "");
			}

		}
		return 1;
	}
	if(dialogid == 31){
		if(response){
			ShowPlayerDialog(playerid,30,2,"-=| FullGaming |=-  POMOC","CMD> Gracz \nCMD> VIP\nCMD> Admin \nCMD> Konto \nCMD> Dom \nCMD> Gang \nCMD> Respekt \nCMD> Animacje \nCMD> Teleporty \nCMD> Atrakcje \nPANEL> Gangi\nPANEL> TextDrawy\nINFO> Regulamin\nINFO> Respekt\nINFO> Level\nINFO> Konto VIP\nINFO> Nowosci\nINFO> Autor","Dalej","Wyjdz");
		}
		return 1;
	}

	if(dialogid == 32){
		if(response){
			ShowPlayerDialog(playerid,30,2,"-=| FullGaming |=-  POMOC","CMD> Gracz \nCMD> VIP\nCMD> Admin \nCMD> Konto \nCMD> Dom \nCMD> Gang \nCMD> Respekt \nCMD> Animacje \nCMD> Teleporty \nCMD> Atrakcje \nPANEL> Gangi\nPANEL> TextDrawy\nINFO> Regulamin\nINFO> Respekt\nINFO> Level\nINFO> Konto VIP\nINFO> Nowosci\nINFO> Autor","Dalej","Wyjdz");
		}else{

			new StrinG[1200];
			StrinG = "{717C89}/CarDive {FFFFFF}- wystrzeliwujesz w gore pojazd i spadasz\n";
			strcat(StrinG,"{717C89}/100hp {FFFFFF}- uleczasz sie\n");
            strcat(StrinG,"{717C89}/BuyWeapon [ID] [Ammo] {FFFFFF}- kupujesz broñ na spawn\n");
			strcat(StrinG,"{717C89}/Armour {FFFFFF}- dostajesz kamizelkê kuloodporn¹\n");
			strcat(StrinG,"{717C89}/Dotacja {FFFFFF}- dostajesz kasê\n");
			strcat(StrinG,"{717C89}/Pojazdy {FFFFFF}- lista pojazdow do kupienia\n");
			strcat(StrinG,"{717C89}/Posiadlosci /Posiadlosci2 {FFFFFF}- pokazuje liste i wlascicieli biznesow\n");
			strcat(StrinG,"{717C89}/NRG {FFFFFF}- dostajesz motor NRG-500\n");
			strcat(StrinG,"{717C89}/Kill {FFFFFF}- popelniasz samobojstwo\n");
			strcat(StrinG,"{717C89}/Tune {FFFFFF}- tuningujesz swój pojazd\n");
			strcat(StrinG,"{717C89}/TuneMenu {FFFFFF}- otwiera menu z opcjami tuningu pojazdu\n");
			strcat(StrinG,"{717C89}/Flip {FFFFFF}- stawiasz swój pojazd na kola\n");
			strcat(StrinG,"{717C89}/NOS {FFFFFF}- wstawiasz do pojazdu nitro\n");
			strcat(StrinG,"{717C89}/ZW /JJ /Siema /Nara /Witam /Pa {FFFFFF}- wiadomo o co chodzi...\n");
			strcat(StrinG,"{717C89}/Napraw {FFFFFF}- naprawiasz swój pojazd\n");
			strcat(StrinG,"{717C89}/SavePos {FFFFFF}- ustawiasz chwilowy teleport dla wszystkich\n");
			strcat(StrinG,"{717C89}/TelPos {FFFFFF}- teleportujesz sie do chwilowego teleportu\n");
			strcat(StrinG,"{717C89}/SP {FFFFFF}- zapisujesz swój prywatny teleport\n");
			strcat(StrinG,"{717C89}/LP {FFFFFF}- teleportujesz sie to swojego teleportu\n");
			strcat(StrinG,"{717C89}/Raport [ID_gracza] [powod] {FFFFFF}- wysylasz raport adminowi na gracza \n");
			strcat(StrinG,"{717C89}/Odlicz {FFFFFF}- wlaczasz odliczanie\n");
			strcat(StrinG,"{717C89}/StylWalki {FFFFFF}- wybierasz swój styl walki\n");
			strcat(StrinG,"{717C89}/Rozbroj {FFFFFF}- rozbrajasz siebie\n");
			strcat(StrinG,"{717C89}/RespektHelp {FFFFFF}- informacja co to jest respekt\n");
			strcat(StrinG,"{717C89}/VipInfo {FFFFFF}- poznaj mo¿liwoœæi vipa\n ");
            strcat(StrinG,"{717C89}/ModInfo {FFFFFF}- sprawdzasz mo¿liwoœæi moderatora\n");
			strcat(StrinG,"{717C89}/Autor {FFFFFF}- pokazuje autora tego gamemoda\n");
			strcat(StrinG,"{717C89}/Skin [id] {FFFFFF}- zmieniasz sobie skina podajac jego ID\n");
            strcat(StrinG,"\n");
			strcat(StrinG,"{FF0000}/Komendy2 {FFFFFF}- Druga lista komend");

			ShowPlayerDialog(playerid,33,0,"Komendy na serwerze",StrinG,"<<<","Wyjdz");

		}
		return 1;
	}
	if(dialogid == 33){
		if(response){

			    new StrinG[2400];
				StrinG = "{717C89}/KolorAuto {FFFFFF}- zmieniasz sobie losowo kolor pojazdu\n";
                strcat(StrinG,"{717C89}/HUD {FFFFFF}- Zmieniasz kolor szaty graficznej.\n");
				strcat(StrinG,"{717C89}/TDPanel - Panel Text Draw'ów\n");
                strcat(StrinG,"{717C89}/Randka [ID] - Idziesz na randkê\n");
				strcat(StrinG,"{717C89}/Losowanie {FFFFFF}- moze cos wygrasz...\n");
				strcat(StrinG,"{717C89}/TDpanel {FFFFFF}- panel zarzadzania TextDraw'ami\n");
				strcat(StrinG,"{717C89}/Staty {FFFFFF}- panel roznych statystyk i TOP-list\n");
				strcat(StrinG,"{717C89}/Podloz {FFFFFF}- podkladasz bombe \n");
				strcat(StrinG,"{717C89}/GiveCash [ID_gracza] [kwota] {FFFFFF}- dajesz graczowi podana ilosc pieniedzy\n");
				strcat(StrinG,"{717C89}/Hitman [ID_gracza] [kwota] {FFFFFF}- wyznaczasz nagrode za zabicie gracza\n");
				strcat(StrinG,"{717C89}/Bounty [ID_gracza] {FFFFFF}- sprawdzasz nagrode jaka jest za zabicie gracza\n");
				strcat(StrinG,"{717C89}/Kup {FFFFFF}- kupujesz wybrany biznes\n");
				strcat(StrinG,"{717C89}/KupDom {FFFFFF}- kupujesz wybrany dom\n");
				strcat(StrinG,"{717C89}/Admins {FFFFFF}- pokazuje obecnych administratorow\n");
				strcat(StrinG,"{717C89}/Vips {FFFFFF}- pokazuje obecnych Vipow\n");
                strcat(StrinG,"{717C89}/Mods {FFFFFF}- lista moderatorow\n");
				strcat(StrinG,"{717C89}/Fopen {FFFFFF}- otwierasz fortece (Farma na wsi) \n");
				strcat(StrinG,"{717C89}/Fclose {FFFFFF}- zamykasz fotrece (Farma na wsi)\n");
				strcat(StrinG,"{717C89}/Bronie {FFFFFF}- lista broni do kupienia\n");
				strcat(StrinG,"{717C89}/PM [ID_gracza] [tekst] {FFFFFF}- wysylasz prywatna wiadomosc do gracza\n");
				strcat(StrinG,"{717C89}/BuyWeapon [ID_broni] {FFFFFF}- kupujesz bron na stale (Ammunation)\n");
				strcat(StrinG,"{717C89}/DelWeapons {FFFFFF}- usuwasz swoje stale bronie\n");
				strcat(StrinG,"{717C89}/Weapons {FFFFFF}- lista broni do kupienia na stale\n");
				strcat(StrinG,"{717C89}/Lock {FFFFFF}- zamykasz pojazd\n");
				strcat(StrinG,"{717C89}/UnLock {FFFFFF}- otwierasz pojazd\n");
				strcat(StrinG,"{717C89}/Odleglosc [ID_gracza] {FFFFFF}- pojazuje odleglosc od gracza\n");
				strcat(StrinG,"{717C89}/Skok [500-20000] {FFFFFF}- wykonujesz skok spadochronowy z okreslonej wysokosci\n");

				ShowPlayerDialog(playerid,32,0,"Komendy graczy",StrinG,"Cofnij",">>>");

		}
		return 1;
	}

	if(dialogid == 35){

 		if(listitem >= 10){ return 1;}
		if(response){

		    if(RaportID[listitem] == -1){
		        SendClientMessage(playerid,COLOR_RED2,"Ten raport zosta³ usuniêty lub sprawdzony!");
		    	return 1;
		    }

			if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING){
				GetPlayerPos(playerid,SpecPosX[playerid],SpecPosY[playerid],SpecPosZ[playerid]);
				SpecInt[playerid] = GetPlayerInterior(playerid);
				SpecVW[playerid] = GetPlayerVirtualWorld(playerid);
			}

			new specplayerid = RaportID[listitem];
			SetPlayerInterior(playerid,GetPlayerInterior(specplayerid));
			SetPlayerVirtualWorld(playerid,GetPlayerVirtualWorld(specplayerid));

			new sss[128];
			format(sss,sizeof(sss),"Ogl¹dasz gracza: %s (%d) z powodu: {AA3333}%s",PlayerName(specplayerid),specplayerid,Raport[listitem]);
			SendClientMessage(playerid,COLOR_ORANGE,sss);

			TogglePlayerSpectating(playerid, 1);
			if(!IsPlayerInAnyVehicle(specplayerid)){
				PlayerSpectatePlayer(playerid, specplayerid);
			}else{
				PlayerSpectateVehicle(playerid,GetPlayerVehicleID(specplayerid));
			}
			gSpectateID[playerid] = specplayerid;
			gSpectateType[playerid] = 1;
			RaportID[listitem] = -1;


		}else{

			RaportID[listitem] = -1;
			SendClientMessage(playerid,COLOR_RED2,"Raport zosta³ anulowany");


			new str[700];
			for(new x=0;x<10;x++){
			new name[25];
			if(RaportID[x] < 0){
				format(str,sizeof(str),"%s\nBrak Raportu",str);
			}else{
				GetPlayerName(RaportID[x],name,sizeof(name));
				format(str,sizeof(str),"%s\n%s(%d) >> %s",str,name,RaportID[x],Raport[x]);
			}
			}
			strins(str,"\nWyjdz",strlen(str),sizeof(str));

			ShowPlayerDialog(playerid,35,2,"Lista Raportow",str,"Spec","Usun");

		}
	    return 1;
	}
	if(dialogid == 36)
	{
	    if(response)
		{
            new vehicleid = GetPlayerVehicleID(playerid);
			ChangeVehicleColor(vehicleid,1,1);
			switch(listitem)
	    	{
	    	    case 0: ChangeVehiclePaintjob(vehicleid,0);
	    	    case 1: ChangeVehiclePaintjob(vehicleid,1);
	    	    case 2: ChangeVehiclePaintjob(vehicleid,2);
	    	    case 3: ChangeVehiclePaintjob(vehicleid,3);
	    	    case 4: ChangeVehiclePaintjob(vehicleid,4);
			}

	    	ShowPlayerDialog(playerid, 36, DIALOG_STYLE_LIST, "Paint Job", "Paint Job 1\nPaint Job 2\nPaint Job 3\nUsun Paint Job'a", "Wybierz", "Wróæ");

	    }else{

			ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Tuning Menu", "Felgi\nKolory\nHydraulika\nNitro\nStereo\nPaint Job", "Wybierz", "Anuluj");

	    }
		return 1;
	}
	if(dialogid == 37){
		if(response){

		    if(listitem == 0){

		        if(PlayerGangInfo[playerid][gID] != -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Masz ju¿ gang!");
		        	return 1;
		        }

		        new IsFreeGang = -1;

		        for(new x=0;x<MAX_GANGS;x++){
		        if(GangInfo[x][gLeader] == -1){
		            IsFreeGang = x;
		            break;
		        }
		        }

		        if(IsFreeGang == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Na serwerze jest ju¿ za du¿o gangów!");
		        	return 1;
		        }


		        PlayerGangInfo[playerid][gDialog] = 1;
		        ShowPlayerDialog(playerid,38,1,"Tworzenie Gangu","Podaj nazwe dla gangu","Utworz","Cofnij");

			}else if(listitem == 1){


		        if(PlayerGangInfo[playerid][gID] == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie posiadasz gangu!");
		        	return 1;
		        }

		        new id = PlayerGangInfo[playerid][gID];
		        if(GangInfo[id][gLeader] != playerid){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ szefem gangu!");
		        	return 1;
		        }

		        foreachPly (x) {
		        if(x != playerid){
		            if(PlayerGangInfo[x][gID] == id){
						PlayerGangInfo[x][gID] = -1;
						PlayerLabelOff(x);
						SendClientMessage(x,COLOR_RED2,"Twoj gang zostal usuniêty przez szefa!");
		            }
		        }
		        }

		        GangInfo[id][gLeader] = -1;
		        PlayerGangInfo[playerid][gID] = -1;

                PlayerLabelOff(playerid);
				PlayerGangInfo[playerid][gDialog] = 0;
		       	ShowPlayerDialog(playerid,38,0,"Usuwanie Gangu","Twoj gang zostal usuniety poprawnie!","OK","OK");

		    }else if(listitem == 2){


		    	if(PlayerGangInfo[playerid][gID] == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie posiadasz gangu!");
		        	return 1;
		        }

		        new id = PlayerGangInfo[playerid][gID];
		        if(GangInfo[id][gLeader] != playerid){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ szefem gangu!");
		        	return 1;
		        }

		        PlayerGangInfo[playerid][gDialog] = 2;
		        ShowPlayerDialog(playerid,38,1,"Rekrutacja Gangu","Podaj ID gracza\nkrotego chcesz zaprosic do gangu","Zapros","Cofnij");

			}else if(listitem == 3){

		    	if(PlayerGangInfo[playerid][gID] == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie posiadasz gangu!");
		        	return 1;
		        }

		        new id = PlayerGangInfo[playerid][gID];
		        if(GangInfo[id][gLeader] != playerid){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ szefem gangu!");
		        	return 1;
		        }

		        new string[256];
		        new bool:first = true;
		        foreachPly (x) {
		        if(PlayerGangInfo[x][gID] == id){
		            if(first){
		            	format(string,sizeof(string),"%s\n",PlayerName(x));
		            	first = false;
		            }else{
		            	format(string,sizeof(string),"%s%s\n",string,PlayerName(x));
		            }
		        }
		        }

		        PlayerGangInfo[playerid][gDialog] = 3;
		        if(strlen(string) >= 3){
		        	ShowPlayerDialog(playerid,38,2,"Wywalanie z Gangu",string,"Wywal","Cofnij");
		        }else{
		            SendClientMessage(playerid,COLOR_RED2,"Nie masz nikogo w gangu!");
		        }

		    }else if(listitem == 4){


		    	if(PlayerGangInfo[playerid][gID] == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie posiadasz gangu!");
		        	return 1;
		        }

		        new id = PlayerGangInfo[playerid][gID];
		        if(GangInfo[id][gLeader] != playerid){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ szefem gangu!");
		        	return 1;
		        }

		        new Float:x,Float:y,Float:z;
		        GetPlayerPos(playerid,x,y,z);
		        GangInfo[id][gSpawnX] = x;
		        GangInfo[id][gSpawnY] = y;
		        GangInfo[id][gSpawnZ] = z;

		        PlayerGangInfo[playerid][gDialog] = 0;
		        ShowPlayerDialog(playerid,38,0,"Spawn Gangu","Teraz czlonkowie gangu bada respawnowas sie\nw miejscu w ktorym stoisz","OK","OK");

			}else if(listitem ==  5){

		    	if(PlayerGangInfo[playerid][gID] == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie posiadasz gangu!");
		        	return 1;
		        }

		        new id = PlayerGangInfo[playerid][gID];
		        if(GangInfo[id][gLeader] != playerid){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ szefem gangu!");
		        	return 1;
		        }

				PlayerGangInfo[playerid][gDialog] = 5;
		    	ShowPlayerDialog(playerid,38,2,"Kolor Gangu","Czarny \nBialy \nSzary \nPomaranczowy \nZielony \nCzerwony \nNiebieski \nBlekitny \nRozowy \nFielotowy","Ustaw","Cofnij");


			}else if(listitem == 6){

				if(PlayerGangInfo[playerid][gID] != -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Masz ju¿ gang!");
		        	return 1;
		        }

				new bool:first = true;
				new string[512];
				for(new x=0;x<MAX_GANGS;x++){
				if(PlayerGangInfo[playerid][gInvites][x]){
				    if(first){
				    	format(string,sizeof(string),"%s",GangInfo[x][gName]);
				    	first = false;
				    }else{
				    	format(string,sizeof(string),"%s\n%s",string,GangInfo[x][gName]);
				    }
				}
				}

				if(strlen(string) < 2){

				PlayerGangInfo[playerid][gDialog] = 0;
		        ShowPlayerDialog(playerid,38,0,"Dolacz do Gangu","Brak zaproszen do gangu","OK","OK");

				}else{

				PlayerGangInfo[playerid][gDialog] = 4;
		        ShowPlayerDialog(playerid,38,2,"Dolacz do Gangu",string,"Dolacz","Cofnij");

		        }

			}else if(listitem == 7){

				if(PlayerGangInfo[playerid][gID] == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie posiadasz gangu!");
		        	return 1;
		        }

				PlayerGangInfo[playerid][gDialog] = 0;
				PlayerLeaveGang(playerid);
		        SendClientMessage(playerid,COLOR_ORANGE,"Opuœci³eœ(aœ) swój gang!");


		    }else if(listitem == 8){
		        //Info Gang

		        if(PlayerGangInfo[playerid][gID] == -1){
		            ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
					SendClientMessage(playerid,COLOR_RED2,"Nie posiadasz gangu!");
		        	return 1;
		        }


				new id = PlayerGangInfo[playerid][gID];
				new lid = GangInfo[id][gLeader];
				new string[320];
		        new memb[256];
		        new leader[25];
		        GetPlayerName(lid,leader,sizeof(leader));

		        foreachPly (x) {
		        if(PlayerGangInfo[x][gID] == id && x != lid){
		            format(memb,sizeof(memb),"%s\n%s",memb,PlayerName(x));
		        }
		        }

		        format(string,sizeof(string),"Nazwa: %s\nSzef: %s\nCzlonkowie:\n%s",GangInfo[id][gName],leader,memb);

		        PlayerGangInfo[playerid][gDialog] = 0;
		        ShowPlayerDialog(playerid,38,0,"Informacje o twoim gangu",string,"OK","OK");

		    }else if(listitem == 9){

		        new string[512];

		        for(new x=0;x<MAX_GANGS;x++){
		            if(GangInfo[x][gLeader] > -1){
		            format(string,sizeof(string),"%s\n%s",string,GangInfo[x][gName]);
		        }
		        }

		        PlayerGangInfo[playerid][gDialog] = 0;
		        if(strlen(string) >= 3){
		        	ShowPlayerDialog(playerid,38,0,"Istniejace Gangi",string,"OK","OK");
		        }else{
		        	ShowPlayerDialog(playerid,38,0,"Istniejace Gangi","Na serwerze nie ma obecnie\nzadnego gangu!","OK","OK");
		        }


		    }

		}
		return 1;
	}
	if(dialogid == 38){

		if(PlayerGangInfo[playerid][gDialog] == 0){
		    ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
			return 1;
		}


		if(PlayerGangInfo[playerid][gDialog] == 1){

			if(!response){
		        ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
				return 1;
			}

			if(strlen(inputtext) > 20 || strlen(inputtext) < 3){
		        ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
				SendClientMessage(playerid,COLOR_RED2,"Nazwa gangu musi mieæ od 3 do 20 znaków!");
			    return 1;
			}

			new IsFreeGang = -1;

			for(new x=0;x<MAX_GANGS;x++){
		        if(GangInfo[x][gLeader] == -1){
		            IsFreeGang = x;
		            break;
		        }
		    }

		    if(IsFreeGang == -1){
		        ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
				SendClientMessage(playerid,COLOR_RED2,"Na serwerze jest ju¿ za du¿o gangów!");
		        return 1;
		    }

		    GangInfo[IsFreeGang][gLeader] = playerid;
		    PlayerGangInfo[playerid][gID] = IsFreeGang;
			format(GangInfo[IsFreeGang][gName],21,"%s",inputtext);
			GangInfo[IsFreeGang][gSpawnX] = 0.0;
			GangInfo[IsFreeGang][gSpawnY] = 0.0;
			GangInfo[IsFreeGang][gSpawnZ] = 0.0;
			GangInfo[IsFreeGang][gColor] = 0x000000FF;
			Update3DTextLabelText(PlayerLabel[playerid],0x000000FF,GangInfo[IsFreeGang][gName]);
            KillTimer(TrzyDeTimer[playerid]);

			PlayerGangInfo[playerid][gDialog] = 0;
			ShowPlayerDialog(playerid,38,0,"Tworzenie Gangu","Twoj gang zostal utworzony.\nMozesz teraz rekrutowac czlonkow","OK","OK");

			return 1;
		}


		if(PlayerGangInfo[playerid][gDialog] == 2){

			if(!response){
		        ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
				return 1;
			}

			new id = PlayerGangInfo[playerid][gID];
			new gracz = strval(inputtext);

			if(gracz < 0 || gracz >= MAX_GRACZY || !IsPlayerConnected(gracz)){
			    PlayerGangInfo[playerid][gDialog] = 2;
		        ShowPlayerDialog(playerid,38,1,"Rekrutacja Gangu","Podaj ID gracza\nkrotego chcesz zaprosic do gangu","Zapros","Cofnij");
				SendClientMessage(playerid,COLOR_RED2," * Nie ma takiego gracza!");
				return 1;
			}

			PlayerGangInfo[gracz][gInvites][id] = true;
			new string[64];
			format(string,sizeof(string),"Zaprosiles(as) do gangu gracza: %s",PlayerName(gracz));
			PlayerGangInfo[playerid][gDialog] = 0;
			ShowPlayerDialog(playerid,38,0,"Rekrutacja Gangu",string,"OK","OK");
			format(string,sizeof(string),"Zosta³eœ(aœ) zaproszony/a do gangu: %s",GangInfo[id][gName]);
			SendClientMessage(gracz,COLOR_ORANGE,string);
			SendClientMessage(gracz,COLOR_ORANGE,"Mo¿esz do niego do³¹czyæ w panelu:  /GangDolacz");

			return 1;
		}



		if(PlayerGangInfo[playerid][gDialog] == 3){

			if(!response){
		        ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
				return 1;
			}

			new id = PlayerGangInfo[playerid][gID];

			new num;
			foreachPly (x) {
      		if(PlayerGangInfo[x][gID] == id){

   			    if(num == listitem){
   			        SendClientMessage(x,COLOR_RED2,"Szef wyrzuci³ ciê z gangu!");
   			        PlayerLeaveGang(x);
	   	 			break;
   			    }
   			    num ++;
   			}
   			}


			return 1;
		}

		if(PlayerGangInfo[playerid][gDialog] == 4){

			if(!response){
		        ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
				return 1;
			}


			new num;
			for(new x=0;x<MAX_GANGS;x++){
			if(PlayerGangInfo[playerid][gInvites][x]){
				if(num == listitem){

					new cd;
					foreachPly (i) {
					if(PlayerGangInfo[i][gID] == x){
	    				cd ++;
					}
					}

	    			if(cd >= MAX_GANG_MEMBERS){
					    SendClientMessage(playerid,COLOR_RED2,"Niestety ten gang ma ju¿ max. iloœæ cz³onków");
					    break;
				 	}

				 	if(GangInfo[x][gLeader] == -1){
				 	    PlayerGangInfo[playerid][gInvites][x] = false;
				 	    SendClientMessage(playerid,COLOR_RED2,"Niestety ale ten gang ju¿ siê rozpad³!");
				 	    break;
				 	}

					PlayerGangInfo[playerid][gID] = x;
	   				PlayerGangInfo[playerid][gInvites][x] = false;
	   				Update3DTextLabelText(PlayerLabel[playerid],GangInfo[x][gColor],GangInfo[x][gName]);
                    KillTimer(TrzyDeTimer[playerid]);
		   			SendClientMessage(playerid,COLOR_ORANGE,"Do³¹czy³eœ(aœ) do wybranego gangu!");
	    			break;
				}
				num ++;
			}
			}

			return 1;
		}

		if(PlayerGangInfo[playerid][gDialog] == 5){

			if(!response){
		        ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
				return 1;
			}

			new id = PlayerGangInfo[playerid][gID];

			switch(listitem){
				case 0:{
			        GangInfo[id][gColor] = 0x000000FF;
				}
				case 1:{
			        GangInfo[id][gColor] = 0xFFFFFFFF;
				}
				case 2:	{
			        GangInfo[id][gColor] = 0xC0C0C0FF;
				}
				case 3:{
			        GangInfo[id][gColor] = 0xFF8040FF;
				}
				case 4:{
			        GangInfo[id][gColor] = 0x00E600FF;
				}
				case 5:{
			        GangInfo[id][gColor] = 0xFF0000FF;
				}
				case 6:{
			        GangInfo[id][gColor] = 0x0080FFFF;
				}
				case 7:{
			        GangInfo[id][gColor] = 0x80FFFFFF;
				}
				case 8:{
			        GangInfo[id][gColor] = 0xFF00FFFF;
				}
				case 9:{
			        GangInfo[id][gColor] = 0x8000FFFF;
				}
			}

			foreachPly (x) {
			if(PlayerGangInfo[x][gID] == id){
				Update3DTextLabelText(PlayerLabel[x],GangInfo[id][gColor],GangInfo[id][gName]);
				SendClientMessage(x,GangInfo[id][gColor],"Kolor twojego gangu zosta³ zmieniony na ten");
			}
			}

			return 1;
		}

		return 1;
	}



//Nastêpny wolny to 39

	return 0;
}

forward NotDrunk(playerid);
public NotDrunk(playerid)
{
	SetPlayerDrunkLevel(playerid,0);
	KillTimer(DrunkTimer[playerid]);
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	Player[playerid][ClickedPlayer] = clickedplayerid;
	ShowPlayerDialog(playerid, DIALOG_PLAYER, DIALOG_STYLE_LIST, PlayerName(clickedplayerid), "¤ IdŸ do gracza\n¤ Statystyki\n¤ Raportuj ³amanie regulaminu", "Wybierz", "Anuluj");

	return 1;
}


forward DelTrailers();
public DelTrailers()
{

	for(new x=MaxPojazdow;x<3000;x++)
	{
		if(!IsTrailer(x))
		{
			DestroyVehicle(x);
		}
	}

	SendClientMessageToAll(COLOR_LIGHTGREEN," * Stworzone naczepy zosta³y usuniête");
    SoundForAll(1150);
	return 1;
}

forward DelPojazdy();
public DelPojazdy()
{

	/*for(new x=MaxPojazdow;x<3000;x++)
	{
		if(GetVehicleModel(x) == 0) continue;
		if(!IsVehicleInUse(x) && IsTrailer(x))
		{
		    new bool:block;
		    for(new i=0;i<HOUSES_LOOP;i++){
		    	if(HouseInfo[i][hCarid] == x){
					block = true;
					break;
				}
			}
			if(block) continue;
			DestroyVehicle(x);
		}
	}*/

	//SendClientMessageToAll(COLOR_LIGHTGREEN," * Nieu¿ywane stworzone pojazdy usuniête!");
    //SoundForAll(1150);
	return 1;
}

forward SetDragCheckpoints(playerid);
public SetDragCheckpoints(playerid)
{

	foreachPly (x) {
		if(Drager[x]){
			if(PlayerToPoint(3.0,x,664.1330,-1392.5837,13.1778)){
				Drager1[x] = true;
				SetPlayerRaceCheckpoint(x,0,753.8131,-1392.4583,13.1739,848.0184,-1392.2720,13.1114,5);
			}
			else if(PlayerToPoint(3.0,x,664.3258,-1397.8151,13.1221)){
				Drager2[x] = true;
				SetPlayerRaceCheckpoint(x,0,754.4495,-1397.7930,12.9921,848.2114,-1397.7303,12.7792,5);
			}
			else if(PlayerToPoint(3.0,x,663.8873,-1402.8795,13.0817)){
				Drager3[x] = true;
				SetPlayerRaceCheckpoint(x,0,757.4145,-1403.0627,13.2752,848.5390,-1402.8962,13.1847,5);
			}
			else if(PlayerToPoint(3.0,x,663.6431,-1408.2515,13.0918)){
				Drager4[x] = true;
				SetPlayerRaceCheckpoint(x,0,753.5180,-1408.1012,13.0800,848.4573,-1408.2458,12.9308,5);
			}
		}
	}
	return 1;
}

forward DragTimerr(playerid);
public DragTimerr(playerid)
{

	DragON = false;
	DragMiejsce = 0;
	Dragliczba = 0;

	SendClientMessageToAllDrag(COLOR_RED2," * Wyœcig DRAG zosta³ zatrzymany przez Serwer");
    SoundForAll(1150);
	foreachPly (x) {
		if(Drager[x]){
			DisablePlayerCheckpoint(x);
			DisablePlayerRaceCheckpoint(x);
			Drager[x] = false;
			Drager1[x] = false;
			Drager2[x] = false;
			Drager3[x] = false;
			Drager4[x] = false;
			DragCheck[x] = 0;
			SetPlayerVirtualWorld(x,0);
		}
	}

	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	
	if(ispassenger)
	{
		if(GetVehicleModel(vehicleid) == 519)
		{
			IsInShml[playerid]=vehicleid;

			SetPlayerFacingAngle(playerid, 0);
			SetCameraBehindPlayer(playerid);

			SetPlayerInterior(playerid, 1);
			SetPlayerPos(playerid, 1.5527,32.4773,1199.5938);

		}
		return 1;
	}

	if(vehicleid < MaxPojazdow) return 1;

	for(new x=0;x<HOUSES_LOOP;x++){
		if(vehicleid == HouseInfo[x][hCarid]){

			if(HouseID[playerid] != x){
				SendClientMessage(playerid,COLOR_RED2,"To jest prywatny pojazd!");
				SendClientMessage(playerid,COLOR_RED2,"Aby taki mieæ musisz kupiæ dom! (/Osiedle1-5)");
				new Float:fx,Float:y,Float:z;
				GetPlayerPos(playerid,fx,y,z);
				SetPlayerPos(playerid,fx,y,z+2);
				break;
			}

		}
	}
	return 1;
}

forward DetonUnlock(playerid);
public DetonUnlock(playerid)
{
	MozeDetonowac[playerid] = true;
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if(pickupid == PickupID[0] || pickupid == PickupID[1] || pickupid == PickupID[2])
	{
	    new str[128];
	    format(str, sizeof str, "Predkosc na progu: %dkm/h", GetVehSpeed(GetPlayerVehicleID(playerid)));
	    SendClientMessage(playerid, 0xff0000ff, str);
	    format(str, sizeof str, "%dkm/h", GetVehSpeed(GetPlayerVehicleID(playerid)));
	    GameTextForPlayer(playerid, str, 1000, 3);
	    SetPVarInt(playerid, "Pickup", 1);
	    SetPVarInt(playerid, "Skoczyl", 1);
	    PlayerPlaySound(playerid, 1147, 0.0, 0.0, 0.0);
	    SetPVarInt(playerid, "pickupID", 0);
	}

    if(pickups[pickupid][creation_time] != 0)
	{
		Player[playerid][WeaponPickup] = pickupid;
		Player[playerid][WeaponPickupTime] = 5;
		GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~w~                             Wcisnij caps-lock~n~                             by podniesc bron.", 3999, 5);
	}
	if(pickupid == TDCPick)
	{
		SendClientMessage(playerid, 0xFF9900AA, "Dosta³eœ(aœ) Mega zestaw Broni!");
		GivePlayerWeapon(playerid, 24,3000);
		GivePlayerWeapon(playerid, 28,3000);
		GivePlayerWeapon(playerid, 31,3000);
		GivePlayerWeapon(playerid, 26,3000);
		GivePlayerWeapon(playerid, 34,3000);
		SetPlayerHealth(playerid, 100);
		SetPlayerArmour(playerid,100);
        SoundForAll(1150);
		PlayerPlaySound(playerid, 1039, 0, 0, 0);
		return 1;
	}

	if(BagEnabled && BagPickup == pickupid && !IsAdmin(playerid,1))
	{
	    GivePlayerMoney(playerid, BagCash);
		Money[playerid] += BagCash;
		new BagExp = 15+random(25);
	    Respekt[playerid] += BagExp;

        new String[255];
        format(String, sizeof(String), "  * %s (%d) znalaz³ walizkê. Zgarnia %d$ i %d exp.", PlayerName(playerid), playerid, BagCash, BagExp);
		SendClientMessageToAll(COLOR_GREEN, String);
        SoundForAll(1057);

        ControlLevelUp(playerid);
        DestroyPickup(BagPickup);
        BagCash = 0;
        BagEnabled = false;

		return 1;
	}

    if(PodkowaEnabled && PodkowaPickup == pickupid && !IsAdmin(playerid,1))
	{
	    GivePlayerMoney(playerid, PodkowaCash);
		Money[playerid] += PodkowaCash;
		new PodkowaExp = 10+random(20);
	    Respekt[playerid] += PodkowaExp;

        new String[255];
        format(String, sizeof(String), "  * %s (%d) znalaz³ podkowê. Zgarnia %d$ i %d exp.", PlayerName(playerid), playerid, PodkowaCash, PodkowaExp);
		SendClientMessageToAll(COLOR_BLUEX, String);
        SoundForAll(1057);

        ControlLevelUp(playerid);

        DestroyPickup(PodkowaPickup);
        PodkowaCash = 0;
        PodkowaEnabled = false;

		return 1;
	}

	if(pickupid == WindaLVDol){
    ShowPlayerDialog(playerid, DIALOG_WINDALV, DIALOG_STYLE_LIST, "Winda", "¤ Do góry\n¤ Na dó³", "Ok", "Anuluj");
	return 1;
	}

	if(pickupid == WindaLVGora){
    ShowPlayerDialog(playerid, DIALOG_WINDALV, DIALOG_STYLE_LIST, "Winda", "¤ Do góry\n¤ Na dó³", "Ok", "Anuluj");
	return 1;
	}

	if(pickupid == BocianieGniazdo){
    SendClientMessage(playerid, 0xFF9900AA, "Bocianie Gniazdo!");
    SetPlayerPos(playerid,2000.5577,1547.3541,39.9573);
	return 1;
	}

    if(pickupid == CPNEnter){
    SetPlayerPos(playerid,664.0999,-573.0919,16.3359);
	SetPlayerFacingAngle(playerid, 301.2554);
	return 1;
	}

	if(pickupid == CPNExit){
    SetPlayerPos(playerid,1939.3868,2386.4165,10.820);
    SetPlayerFacingAngle(playerid, 93.2001);
	return 1;
	}

    if(pickupid == BarEnter){
    PlayerTeleport(playerid,1,681.4750,-451.1510,-25.6172);
	return 1;
	}

	if(pickupid == BarExit){
    SetPlayerPos(playerid,681.6179,-476.9895,16.3359);
    SetPlayerFacingAngle(playerid, 176.5824);
	SetPlayerInterior(playerid, 0);
	return 1;
	}

    if(pickupid == RestaEnter){
    SetPlayerInterior(playerid,1);
	SetPlayerFacingAngle(playerid,1);
	SetPlayerPos(playerid,-794.9943,492.0277,1376.1953);
	return 1;
	}

	if(pickupid == RestaExit){
    SetPlayerPos(playerid,-181.9678,1091.6656,19.7422);
    SetPlayerFacingAngle(playerid, 31.6353);
    SetPlayerInterior(playerid, 0);
	return 1;
	}

	if(pickupid == ObokBazyEnter){
    SetPlayerPos(playerid,1946.8477,2374.7900,23.8516);
	SetPlayerFacingAngle(playerid, 249.3104);
	return 1;
	}
	
	if(pickupid == ObokBazyExit){
    SetPlayerPos(playerid,658.4244,-573.6930,16.3359);
    SetPlayerFacingAngle(playerid, 352.3746);
	return 1;
	}

	if(pickupid == Burdelik){
   
   	PlayerTeleport(playerid,6,747.6089,1438.7130,1102.9531);
	GameTextForPlayer(playerid,"~p~~h~BURDELIK", 2500, 3);
	return 1;
	}

    if(pickupid == BurdelikExit){

   	PlayerTeleport(playerid,0,2017.2015,1103.1182,10.8203);
	SetPlayerFacingAngle(playerid, 211.4860);
	return 1;
	}

    if(pickupid == BurdelikAction){

	BurdelikUser[playerid] ++;
	
	if(BurdelikUser[playerid] == 1)
	{
		BurdelUser = playerid;
	}
	
	if(BurdelikUser[playerid] == 2)
	{
		BurdelUserTwo = playerid;
	}
	
	if(BurdelikUser[playerid] == 2)
	{
	    SetPlayerPos(BurdelUser,739.2759,1436.8022,1102.7031);
	    SetPlayerFacingAngle(BurdelUser,254.4665);
        ApplyAnimation(BurdelUser,"BLOWJOBZ","null",0,0,0,0,0,0);
		SetPlayerPos(BurdelUserTwo,739.7010,1436.8805,1102.7031);
	    SetPlayerFacingAngle(BurdelUserTwo,92.1584);
        ApplyAnimation(BurdelUserTwo,"sex","SEX_1to2_W",4.1,0,1,1,1,1);
		BurdelikUser[playerid] = 0;
	}

	return 1;
	}

    if(pickupid == FivePickupOne)
	{
        ShowPlayerDialog(playerid, DIALOG_FIVE_ONE, DIALOG_STYLE_LIST, "Brama", "¤ Otwórz\n¤ Zamknij", "Ok", "Anuluj");
		return 1;
	}

    if(pickupid == FivePickupTwo)
	{
        ShowPlayerDialog(playerid, DIALOG_FIVE_ONE, DIALOG_STYLE_LIST, "Brama", "¤ Otwórz\n¤ Zamknij", "Ok", "Anuluj");
		return 1;
	}

    if(pickupid == FivePickupThree)
	{
        ShowPlayerDialog(playerid, DIALOG_FIVE_TWO, DIALOG_STYLE_LIST, "Brama", "¤ Otwórz\n¤ Zamknij", "Ok", "Anuluj");
		return 1;
	}

    if(pickupid == FivePickupFour)
	{
        ShowPlayerDialog(playerid, DIALOG_FIVE_TWO, DIALOG_STYLE_LIST, "Brama", "¤ Otwórz\n¤ Zamknij", "Ok", "Anuluj");
		return 1;
	}

	if(pickupid == loteria){
    SendClientMessage(playerid, 0xFF9900AA, "Loteria.");
    ShowPlayerDialog(playerid, DIALOG_LOTERIA, DIALOG_STYLE_LIST, "Loteria", "¤ Kup Los", "Ok", "Anuluj");
	return 1;
	}

	if(pickupid == loteriavip)
	{
 	if(!IsVIP(playerid) && !IsAdmin(playerid,2)) return SendClientMessage(playerid,COLOR_RED2," * Nie posiadasz uprawnieñ!");

	SendClientMessage(playerid, 0xFF9900AA, "Loteria specjalna [VIP].");
    ShowPlayerDialog(playerid, DIALOG_LOTERIA_VIP, DIALOG_STYLE_LIST, "Loteria", "¤ Kup Los Specjalny [VIP]\n¤ Kup Los [Normalny]", "Ok", "Anuluj");
    
	return 1;
	}

	if(pickupid == NGangPickup){

	if(Player[playerid][MGang])
	    MGangQuit(playerid);

    new Stringa[128];
	format(Stringa, sizeof(Stringa), " * %s (id %d) do³¹czy³ do gangu niebieskich (/ngang).", PlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_LIGHTBLUE, Stringa);
	SetPlayerColor(playerid, COLOR_LIGHTBLUE);
    SetPlayerInterior(playerid,8);
	SetPlayerFacingAngle(playerid,2.2168);
	SetPlayerPos(playerid,2807.1050,-1171.4563,1025.5703);
	GivePlayerWeapon(playerid, 24, 100);
	GivePlayerWeapon(playerid, 34, 100);
	Player[playerid][NGang] = true;
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "  * Do³¹czy³eœ do gangu niebieskich. Ziomków z Twojego gangu poznasz po niebieskim napisie nad nickiem.");
	SendClientMessage(playerid, COLOR_LIGHTBLUE, "  * Komendy niebieskich znajdziesz pod /ncmd");
	return 1;
	}

    if(pickupid == MGangPickup){

	if(Player[playerid][NGang])
	    NGangQuit(playerid);

    new Stringe[255];
	format(Stringe, sizeof(Stringe), "  * %s (id %d) do³¹czy³ do gangu malinowych ziomków (/mgang).", PlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_RASPBERRY, Stringe);
	SetPlayerColor(playerid, COLOR_RASPBERRY);
    SetPlayerInterior(playerid,5);
	SetPlayerFacingAngle(playerid,237.1721);
	SetPlayerPos(playerid,316.6441,1122.1029,1083.8828);
	GivePlayerWeapon(playerid, 24, 100);
	GivePlayerWeapon(playerid, 34, 100);
	Player[playerid][MGang] = true;
	SendClientMessage(playerid, COLOR_RASPBERRY, "  * Do³¹czy³eœ do gangu maliny. Ziomków z Twojego gangu poznasz po malinowym kolorze.");
	SendClientMessage(playerid, COLOR_RASPBERRY, "  * Komendy malinowego gangu znajdziesz pod /mcmd");
	return 1;
	}

    if(pickupid == sflotw){
	SetPlayerPos(playerid,-1541.5645,-443.8336,6.1000);
	return 1;
	}

    if(pickupid == sflotd){
	SetPlayerPos(playerid,-1545.2131,-438.5093,6.0000);
	return 1;
	}

	if(pickupid == strefasniper2){
    SetPlayerPos(playerid,2106.9412,1002.7258,45.6641);
	return 1;
	}

	if(pickupid == strefasniper3){
    SetPlayerPos(playerid,2094.8647,1015.7961,10.8203);
	return 1;
	}

	if(pickupid == windamost){
    SetPlayerPos(playerid,-2662.3604,1595.0948,225.7578);
    GivePlayerWeapon(playerid, 46,1);
	return 1;
	}

	if(pickupid == strefasniper){
    GivePlayerWeapon(playerid, 34,100);
	SetPlayerPos(playerid,2093.6548,1510.9944,35.4844);
	return 1;
	}

    if(pickupid == strazak){
    new stringp[128];
	format(stringp, sizeof(stringp), "Gracza %s wzywa pos³uga w stra¿y po¿arnej. {FF0000}(/SF)",PlayerName(playerid));
	SendClientMessageToAll(0x755A1FFF,stringp);
	GivePlayerWeapon(playerid, 42,400);
    SoundForAll(1150);
	SetPlayerSkin(playerid,279);
	return 1;
	}

    if(pickupid == wojskowy){
    new stringq[256];
	format(stringq, sizeof(stringq), "Gracz %s wst¹pi³ do wojska na {FF0000}(/Afganistan)",PlayerName(playerid));
	SendClientMessageToAll(0x755A1FFF,stringq);
	GivePlayerWeapon(playerid, 30,200);
    SoundForAll(1150);
	SetPlayerSkin(playerid,287);
	return 1;
	}

	if(pickupid == autokomis){
    SendClientMessage(playerid, 0xFF9900AA, "Salon samochodowy");
    new stringw[64];
	format(stringw, sizeof(stringw), "Gracz %s ogl¹da modele szybkich aut. {FF0000}(/Salon)",PlayerName(playerid));
    CarTeleport(playerid,0,-1987.7372,288.7828,34.5681);
	SendClientMessageToAll(0x755A1FFF,stringw);
    SoundForAll(1150);
	ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery \n> Lodzie \n> Samoloty/Helikoptery \n> Zabawki RC", "Dalej", "Anuluj");
	return 1;
	}

	if(pickupid == bronieb){
    SendClientMessage(playerid, 0xFF9900AA, "Automat z broñmi!");
    new stringr[2000];
	format(stringr, sizeof(stringr), "Gracza %s wci¹gn¹³ automat z broñmi! {FF0000}(/Tereno)",PlayerName(playerid));
	SendClientMessageToAll(0x755A1FFF,stringr);
    SoundForAll(1050);

	strcat(stringr,"{FFFF00}Kastet {FFFFFF}- $100\n{FFFF00}Kij Golfowy {FFFFFF}- $100\n{FFFF00}Palka Policyjna {FFFFFF}- $100\n{FFFF00}Noz {FFFFFF}- $100\n{FFFF00}Baseball {FFFFFF}- $100\nLopata {FFFFFF}- $100\n{FFFF00}Kij Bilardowy {FFFFFF}- $100\n{FFFF00}Katana {FFFFFF}- $100\n{FFFF00}Pila Lancuchowa {FFFFFF}- $1500\n{FFFF00}Dildo {FFFFFF}- $100\n{FFFF00}Kwiaty {FFFFFF}- $100\n{FFFF00}Gaz Lzawiacy {FFFFFF}- $5000\n{FFFF00}9mm {FFFFFF}- $3000\n{FFFF00}Silencer {FFFFFF}- $4000\n");
	strcat(stringr,"{FFFF00}Desert Eagle {FFFFFF}- $5000\n{FFFF00}Shotgun {FFFFFF}- $5000\n{FFFF00}Sawn-off {FFFFFF}- $8000\n{FFFF00}Combat Shotgun {FFFFFF}- $25000\n{FFFF00}Micro SMG {FFFFFF}- $10000\n{FFFF00}MP5 {FFFFFF}- $12000\n{FFFF00}AK-47 {FFFFFF}- $13000\n{FFFF00}M4 {FFFFFF}- $15000\n{FFFF00}Tec9 {FFFFFF}- $10000\n{FFFF00}Country Rifle {FFFFFF}- $5000\n{FFFF00}Sniper Rifle {FFFFFF}- $20000\n{FFFF00}Spray {FFFFFF}- $100\n{FFFF00}Gasnica {FFFFFF}- $500\n{FFFF00}Spadochron {FFFFFF}- $100");

	ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST,"Bronie do kupienia:", stringr, "Kup", "Wyjdz");
	return 1;
	}

	if(pickupid == grove){
    SendClientMessage(playerid, 0xFF9900AA, "Wst¹pi³eœ do gangu Grove Street.");
    GivePlayerWeapon(playerid, 28,500);
    SetPlayerSkin(playerid,107);
	return 1;
	}

	if(pickupid == infotrening){
    SendClientMessage(playerid, 0xFF9900AA, "Strefa Treningowa.");
    GivePlayerWeapon(playerid, 34,100);
	return 1;
	}

	if(pickupid == infobramapd1){
    SendClientMessage(playerid, 0xFF9900AA, "/BramaOpen - Otwiera Bramê");
    SendClientMessage(playerid, 0xFF9900AA, "/BramaClose - Zamyka Bramê");
	return 1;
	}

    if(pickupid == infobramapd2){
    SendClientMessage(playerid, 0xFF9900AA, "/Bopen - Otwiera Bramê");
    SendClientMessage(playerid, 0xFF9900AA, "/Bclose - Zamyka Bramê");
	return 1;
	}

	if(pickupid == infobrama2){
    SendClientMessage(playerid, 0xFF9900AA, "/BramaOpen - Otwiera Bramê");
    SendClientMessage(playerid, 0xFF9900AA, "/BramaClose - Zamyka Bramê");
	return 1;
	}

	if(pickupid == dowodzenie){
    SendClientMessage(playerid, 0xFF9900AA, "Centrum dowodzenia");
	SetPlayerPos(playerid,217.2884,1826.7943,6.4141);
	return 1;
	}

    if(pickupid == PickupBasen){
    SendClientMessage(playerid, 0xFF9900AA, "Basen");
	PlayerTeleport(playerid,0,-2943.3792,-203.6268,10.6883);
	SetPlayerFacingAngle(playerid,89.0869);
	return 1;
	}

    if(pickupid == latarniaplaza){
    SendClientMessage(playerid, 0xFF9900AA, "Latarnia Morska");
	SetPlayerPos(playerid,153.5126,-1949.6436,47.8750);
	return 1;
	}

	if(pickupid == dowodzeniewnetrze){
    SendClientMessage(playerid, 0xFF9900AA, "Podwórze afganistanu");
	SetPlayerPos(playerid,27.4414,1822.0250,17.6406);
	return 1;
	}

	new string[140];
	for(new x=0;x<HOUSES_LOOP;x++){
		if(pickupid == HouseInfo[x][hPick]){
			PlayerPlaySound(playerid, 1150, 0, 0, 0);

			if(HouseID[playerid] == x){
				AnnForPlayer(playerid,5000,"Witaj w swoim domu~n~aby wejsc wpisz ~y~/Wejdz");
				break;
			}

			if(strlen(HouseInfo[x][hOwner]) >= 3){

				format(string,sizeof(string),"Witaj w domu ~r~%s~n~~w~aby wejsc wpisz ~y~/Wejdz",HouseInfo[x][hOwner]);
				AnnForPlayer(playerid,5000,string);
				break;

			}else{

				format(string,sizeof(string),"Mozesz wynajac ten dom za: ~n~~r~%d Exp na dzien~n~~w~Uzywajac komendy: ~y~/KupDom~n~~w~Aby go obejrzec ~g~/ZobaczDom",HouseInfo[x][hCost]);
				AnnForPlayer(playerid,10000,string);
				break;

			}
		}
	}

	return 1;
}

LevelUp(PlayerId)
{
	PlayerPlaySound(PlayerId, 1183, 0, 0, 0);
	Player[PlayerId][Level] = GetPlayerLevel(PlayerId);
	Player[PlayerId][LevelUpTime] = LEVEL_UP_TIME;

	new String[255];
	format(String, sizeof(String), "  * {eab171}Gratulacje! Gracz {ffe5a1}%s (%d) {eab171}osi¹gn¹³ {ffe5a1}%d {eab171}level.", PlayerName(PlayerId), PlayerId, Player[PlayerId][Level]);
	SendClientMessageToAll(0xffe5a1FF, String);
	LogPlayerLevel(PlayerId);
}

stock GetPlayerLevel(PlayerId)
{
	new Lvl;
	do {
	    Lvl++;
	} while(Lvl*Lvl*6 < Respekt[PlayerId]);
	return (Lvl-1 < 1) ? 1 : Lvl-1;
}

stock GetPlayerNextExp(PlayerId)
{
	return (Player[PlayerId][Level]+1)*(Player[PlayerId][Level]+1)*6;
}

/*GivePlayerEquipment(PlayerId)
{
	new PLVL = Player[PlayerId][Level];
	GivePlayerWeapon(PlayerId, 4, 1);
	if(PLVL <= 2)
	    GivePlayerWeapon(PlayerId, 22, 500);
	else if(PLVL > 2)
	    GivePlayerWeapon(PlayerId, 24, 300);

	if(PLVL <= 3)
	    GivePlayerWeapon(PlayerId, 30, 500);
	else if(PLVL > 3 && PLVL <= 5)
	    GivePlayerWeapon(PlayerId, 29, 500);
	else if(PLVL > 5)
	    GivePlayerWeapon(PlayerId, 31, 500);

	if(PLVL <= 2)
	    GivePlayerWeapon(PlayerId, 25, 500);
	else if(PLVL > 2 && PLVL <= 4)
	    GivePlayerWeapon(PlayerId, 27, 500);
	else if(PLVL > 4)
	    GivePlayerWeapon(PlayerId, 26, 500);

	GivePlayerWeapon(PlayerId, 16, PLVL-1);

	if(PLVL >= 10)
	    GivePlayerWeapon(PlayerId, 34, 500);

	if(PLVL >= 8)
		SetPlayerArmour(PlayerId, 100.0);

	for(new Order = 0; Order < sizeof(WeapId); Order++)
	    if(Player[PlayerId][SpawnWeapons][Order] > 0)
	        GivePlayerWeapon(PlayerId, WeapId[Order][0], Player[PlayerId][SpawnWeapons][Order]*WEAPON_AMMO);
}*/
stock LogPlayerLevel(playerid)
{
	mysql_query_format("INSERT INTO `level_log` (`Data`,`Nick`,`Level`) VALUES(NOW(),'%s', '%d')",PlayerName(playerid),Player[playerid][Level]);
}

forward HitmanUnlock(playerid);
public HitmanUnlock(playerid)
{
	HitmanBlock[playerid] = false;
	return 1;
}

forward SiemaUnlock(playerid);
public SiemaUnlock(playerid)
{
	SiemaBlock[playerid] = false;
	return 1;
}

forward HouseBadExit(x,playerid);
public HouseBadExit(x,playerid)
{

	if(!PlayerToPoint(15,playerid,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z])){
		SetPlayerPos(playerid,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
	}

	return 1;
}

forward HouseWorld(playerid);
public HouseWorld(playerid)
{
	SetPlayerVirtualWorld(playerid,0);
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{

	foreachPly (x) {
		if(gSpectateID[x] == playerid && GetPlayerState(x) == PLAYER_STATE_SPECTATING){
			SetPlayerInterior(x,newinteriorid);
		}
	}

	if(newinteriorid != 0) return 1;

	for(new x=0;x<HOUSES_LOOP;x++){
		if(oldinteriorid == HouseInfo[x][hInterior] && GetPlayerVirtualWorld(playerid) == HouseInfo[x][hWorld]){
			if(PlayerToPoint(5,playerid,HouseInfo[x][hexit_x],HouseInfo[x][hexit_y],HouseInfo[x][hexit_z])){
				SetTimerEx("HouseBadExit",3000,0,"dd",x,playerid);
				break;
			}
		}
	}

	return 1;
}

forward Detonacja(playerid);
public Detonacja(playerid)
{
	Bomber[playerid] = false;
	CreateExplosion(BombX[playerid], BombY[playerid], BombZ[playerid], 6, 100.0);
	PickDestroy(Bombus[playerid]);

	return 1;
}

forward Staty(); 
public Staty() 
{
    static str[64] = {0}, players_ = 0;
	str[0] = 0;
	
	players_ = Itter_Count(Player);
    PirateShipScoreUpdate();
 	
	format(str, sizeof(str), "%d %s (~y~%d~w~/~g~%d~w~/~r~%d~w~)", players_, dli(players_, "gracz", "graczy", "graczy"),OnlVIP, OnlMOD, OnlAD);
	TextDrawSetString(OnlineUsers, str);
		
	foreachPly (i) 
	{

		format(str, sizeof(str), "%02dh%02dm", (gettime() - gPlayerTime[(i)])/3600, floatround((gettime() - gPlayerTime[(i)])/60%60));
		PlayerTextDrawSetString(i, playerTd_timeplay[i], str);

		if(logged[i]){
			format(str, sizeof(str), "%d/%d",Respekt[i],GetPlayerNextExp(i));
			PlayerTextDrawSetString(i, playerTd_exp[i], str);
			
			format(str, sizeof(str), "%02d pln", Player[i][Portfel]);
			PlayerTextDrawSetString(i, playerTd_portfel[i], str);
			
			format(str, sizeof(str), "%02d", GetPlayerLevel(i));
			PlayerTextDrawSetString(i, playerTd_level[i], str);
			
			SetPlayerScore(i, Respekt[i]), ControlLevelUp(i);
		}
		else
		{
			PlayerTextDrawSetString(i, playerTd_exp[i], "~r~~h~~h~/register");
			PlayerTextDrawSetString(i, playerTd_portfel[i], "00 zl");
			PlayerTextDrawSetString(i, playerTd_level[i], "~r~~h~---");
			SetPlayerScore(i, Respekt[i]);
		}


		if(!logged[i]) continue;

		if((gettime() - gPlayerTime[(i)])/3600 > RespektPremia[i]){
			RespektPremia[i] ++;
			WinSound(i);
			if(!GSTag[i]){
				SendClientMessage(i,COLOR_GREEN,"Otrzyma³eœ(aœ) premiê exp za pe³n¹ godzine grania");
                ControlLevelUp(i);
				GameTextForPlayer(i,"~w~EXP ~g~~h~+100", 2500, 3);
				Respekt[i] += 100;
                PlayerPlaySound(i,1149,0.0,0.0,0.0);
			}else{
				SendClientMessage(i,COLOR_GREEN,"Otrzyma³eœ(aœ) premiê exp za pe³n¹ godzine grania + Tag [FGS]");
                ControlLevelUp(i);
				GameTextForPlayer(i,"~w~EXP ~g~~h~+150", 2500, 3);
				Respekt[i] += 150;
                PlayerPlaySound(i,1149,0.0,0.0,0.0);
			}
		}

	}
	return 1;
}

forward Uleczenie(playerid);
public Uleczenie(playerid)
{
	SetPlayerHealth(playerid, 100);
	SendClientMessage(playerid,COLOR_GREEN,"Zosta³eœ(aœ) Uleczony/a!");
	return 1;
}

forward Armorx(playerid);
public Armorx(playerid)
{
	SetPlayerArmour(playerid, 100);
	SendClientMessage(playerid,COLOR_GREEN,"Otrzyma³eœ(aœ) Armour!");
	return 1;
}

forward SetRandomWeather();
public SetRandomWeather()
{
	new hour;
	gettime(hour);
	SetWorldTime(hour);
	SetWeather(random(6));

	return 1;
}

#define KEY_PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define KEY_RELEASED(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

Float:GetOptimumRampDistance(playerid) {
	new ping = GetPlayerPing(playerid), Float:dist;
	dist = floatpower (ping, 0.25);
	dist = dist*4.0;
	dist = dist+5.0;
	return dist;

}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys == 1 || newkeys == 9 || newkeys == 33 && oldkeys != 1 || oldkeys != 9 || oldkeys != 33)
	{
	    if(IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleSeat(playerid) == 0)
	    {
			new CarId = GetPlayerVehicleID(playerid);
			switch(GetVehicleModel(CarId))
			{
				case 611: return 0;
			}

			AddVehicleComponent(CarId, 1010);
		}
	}

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && PRESSED(KEY_SECONDARY_ATTACK) && InRC[playerid])
    {
        new Float:fx,Float:y,Float:z;
		GetVehiclePos(GetPlayerVehicleID(playerid), fx,y,z);
		RemovePlayerFromVehicle(playerid);
		SetPlayerPos(playerid,fx,y,z+2);
		InRC[playerid] = false;
	}

    if(newkeys == 128 && Player[playerid][WeaponPickup] != 1)
	{
		GivePlayerWeapon(playerid, pickups[Player[playerid][WeaponPickup]][weapon], pickups[Player[playerid][WeaponPickup]][amunicja]);
		DestroyPickup(Player[playerid][WeaponPickup]);
		Player[playerid][WeaponPickup] = -1;
		Player[playerid][WeaponPickupTime] = 0;
	}

	if(newkeys == 16){
		if(IsInShml[playerid] > 0){
   			new Float:X,Float:Y,Float:Z;
			GetVehiclePos(IsInShml[playerid], X, Y, Z);
			SetPlayerPos(playerid, X+4, Y, Z);
			SetPlayerInterior(playerid, 0);
			IsInShml[playerid]=0;
		}
	}

	if(Player[playerid][RampEnabled] == 1)
	{
		if (IsPlayerInAnyVehicle(playerid) && GetPlayerVehicleSeat(playerid) == 0 && (newkeys == KEY_ACTION || newkeys == 9))
		{
			new Arabam = GetPlayerVehicleID(playerid);
			switch(GetVehicleModel(Arabam))
			{
				case 592,577,511,512,593,520,553,476,519,460,513,487,488,548,425,417,497,563,447,469:
				return 1;
			}

			if(Player[playerid][RampCreated] == true)
			{
				KillTimer(Player[playerid][RampTimer]);
				DestroyPlayerObject(playerid, Player[playerid][Ramp]);
			}

			new Float:pX, Float:pY, Float:pZ, Float:vA;
			GetVehiclePos (Arabam, pX, pY, pZ);
			vA = GetXYInFrontOfPlayer(playerid, pX, pY, GetOptimumRampDistance(playerid));
			Player[playerid][Ramp] = CreatePlayerObject (playerid, Player[playerid][RampPers], pX, pY, pZ - 0.5, 0.0, 0.0, vA);
			Player[playerid][RampCreated] = true;
			Player[playerid][RampTimer] = SetTimerEx("DestroyRamp", 4000, 0, "d", playerid);
		}
	}

	if(newkeys == KEY_FIRE){
		if(gPlayerUsingAnim[playerid]){
			StopLoopingAnim(playerid);
			ClearAnimations(playerid);
		}
	}

	if(CanNitro[playerid]){
		if(newkeys == 1 || newkeys == 9 || newkeys == 33 && oldkeys != 1 || oldkeys != 9 || oldkeys != 33){
			new carid = GetPlayerVehicleID(playerid);
			new vmodel = GetVehicleModel(carid);
			switch(vmodel)
			{
				case 446,432,448,452,424,453,454,461,462,463,468,471,430,472,449,473,481,484,493,495,509,510,521,538,522,523,532,537,570,581,586,590,569,595,604,611: return 0;
			}
			AddVehicleComponent(carid, 1010);
		}
	}
    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && PRESSED(KEY_SUBMISSION) )
	{
		RepairVehicle(GetPlayerVehicleID(playerid));
		GameTextForPlayer(playerid,"~y~Pojazd naprawiony!",2000,5);
		PlayerPlaySound(playerid, 1133, 0.0, 0.0, 0.0);
		return 0;
	}
	return 0;
}

forward DestroyRamp(PlayerId);
public DestroyRamp(PlayerId) {
	if(Player[PlayerId][RampCreated]) {
		Player[PlayerId][RampCreated] = false;
		return DestroyPlayerObject(PlayerId, Player[PlayerId][Ramp]);
	}
	else
		return 0;
}

//------------------------------------------------------------------------------------------------------

forward PirateShipScoreUpdate();
public PirateShipScoreUpdate()
{
	foreachPly (i) {
		if(PlayerToPoint(15,i,2001.6912,1544.4111,13.5859)){
			GivePlayerMoney(i, 2000);
			Money[i] += 2000;
		}
	}
}


//------------------------------------------------------------------------------------------------------


stock SaveData(playerid)
{
	new skins_player = GetPlayerSkin(playerid);
	new buff[500];
	format(buff,sizeof buff,"UPDATE `fg_Players` SET `Score` = '%d',`Bank` = '%d',`Bounty` = '%d',`Kills` = '%d',`Deaths` = '%d',`Suicides` = '%d',`Used_Score` = '%d',`Skin` = '%d',`Row_Kills` = '%d',`Arena` = '%d',`Drag` = '%d',`Time` = '%d' WHERE `id` = '%d'",
		Respekt[playerid],bank[playerid],bounty[playerid],kills[playerid],deaths[playerid],suicides[playerid],wykorzystanyrespekt[playerid],skins_player,killsinarow[playerid],SoloScore[playerid],DragTime[playerid],TimePlay[playerid],Player[playerid][uID]);
	mysql_query(buff);
	mysql_query_format("UPDATE `fg_Players` SET `Deagle`='%d', `Minigun`='%d',`Sniper`='%d', `Chainsawn`='%d',`DuelW`='%d', `DuelP`='%d' WHERE `id`='%d'",Player[playerid][deagle],Player[playerid][minigun],Player[playerid][sniper],Player[playerid][chainsawn],Player[playerid][wduel],Player[playerid][pduel],Player[playerid][uID]);
	return 1;
}


forward StatRefresh();
public StatRefresh() {
	new stan = mysql_ping(MySQLcon);
	if (stan != 0){
		SendClientMessageToAll(COLOR_RED2,"MySQL ERROR: Brak polaczenia z baza danych!");
		mysql_ping (MySQLcon);
	}

	new stan2 = mysql_ping(MySQLcon);
	if(!stan2 && stan != 0){
		SendClientMessageToAll(COLOR_GREEN,"MySQL INFO: Odnowiono polaczenie z baza danych!");
	}
	
	SetServerDataInt ("mostonlineply", rekordgraczy);
	SetServerDataInt ("joincount", joins);
	SetServerDataInt ("killcount", globkills);
	SetServerDataInt ("kickcount", kicks);
	SetServerDataInt ("deathcount", globdeaths);
	SetServerDataInt ("globsuicides", globsuicides);
	SetServerDataInt ("bancount", bans);
	
	new string[64];
	foreachPly (x) {
		if(logged[x]){
			SaveData(x);
			format(string,sizeof(string),"Statysyki zapisane na nick: %s",PlayerName(x));
			SendClientMessage(x,COLOR_GREEN,string);
		}
	}

	return 1;
}

forward Losowanko(playerid);
public Losowanko(playerid)
{
	new losek = random(21);

	if(losek == 0)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygrales(aœ) m4!");
		GivePlayerWeapon(playerid, 31, 2000);
	}
	else if(losek == 1)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) nó¿! ");
		GivePlayerWeapon(playerid, 4, 1);
	}
	else if(losek == 2)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) wibrator");
		GivePlayerWeapon(playerid, 12, 1);
	}
	else if(losek == 3)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) Snajperkê!!!");
		GivePlayerWeapon(playerid, 34, 100);
	}
	else if(losek == 4)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) skin dziadka");
		SetPlayerSkin(playerid, 49);
		GivePlayerWeapon(playerid, 15 ,1);
	}
	else if(losek == 5)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ(aœ)");
	}
	else if(losek == 6)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) fortune");
		GivePlayerMoney(playerid, 1);
		Money[playerid] += 1;
	}
	else if(losek == 7)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) trochê kaski na wydatki");
		GivePlayerMoney(playerid, 1000000);
		Money[playerid] += 1000000;
	}
	else if(losek == 8)
	{
		SendClientMessage(playerid, COLOR_LIGHTRED,"Niestety Tym Razem Wygra³eœ(aœ) pobyt w wiêzieniu!");
		JailPlayer(playerid,"Nagroda z Losowania",3);
	}
	else if(losek == 9)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ(aœ)");
	}
	else if(losek == 10)
	{
		SendClientMessage(playerid, COLOR_LIGHTRED,"Niestety Tym Razem Wygra³eœ(aœ) pobyt w wiêzieniu!");
		JailPlayer(playerid,"Nagroda z Losowania",3);
	}
	else if(losek == 11)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) Reset kasy");
		ResetPlayerMoney(playerid);
		Money[playerid] = 0;
	}
	else if(losek == 12)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) D³ug!");
		ResetPlayerMoney(playerid);
		Money[playerid] = 0;
		GivePlayerMoney(playerid, -10000);
		Money[playerid] -= 10000;
	}
	else if(losek == 13)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) Teleport");
		SetPlayerPos(playerid, -1383.3280,-1507.3010,102.2328);
	}
	else if(losek == 15)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) œmieræ");
		SetPlayerHealth(playerid, 0);
	}
	else if(losek == 16)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) ¯ycie = 1 hp");
		SetPlayerHealth(playerid, 1);
	}
	else if(losek == 17)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) ³opatê");
		GivePlayerWeapon(playerid, 6, 1);
	}
	else if(losek == 18)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ(aœ)");
	}
	else if(losek == 19)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) Mega Zestaw");
		GivePlayerWeapon(playerid, 29, 2000);
		GivePlayerWeapon(playerid, 31, 2000);
		GivePlayerWeapon(playerid, 34, 2000);
		GivePlayerWeapon(playerid, 24, 2000);
		SetPlayerArmour(playerid, 100);
		SetPlayerHealth(playerid, 100);
		GivePlayerMoney(playerid, 1000000);
		Money[playerid] += 1000000;
	}
	else if(losek == 20)
	{
		SendClientMessage(playerid, COLOR_LIGHTRED,"Niestety Tym Razem Wygra³eœ(aœ) pobyt w wiêzieniu!");
		JailPlayer(playerid,"Nagroda z Losowania",3);
	}
	return 1;
}

forward LosowankoVIP(playerid);
public LosowankoVIP(playerid)
{
	new losekx = random(21);

	if(losekx == 0)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygrales(aœ) Jetpack!");
		SetPlayerSpecialAction(playerid, 2);
	}
	else if(losekx == 1)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) 1 pkt exp!");
		Respekt[playerid] += 1;
        ControlLevelUp(playerid);
	}
	else if(losekx == 2)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) teleport! (Sex Shop)");
		PlayerTeleport(playerid,6,747.6089,1438.7130,1102.9531);
		GameTextForPlayer(playerid,"~g~~h~SEX SHOP", 2500, 3);
	    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	}
	else if(losekx == 3)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) Mega Pa³kê!");
		RemovePlayerAttachedObject(playerid,0);
  	    SetPlayerAttachedObject( playerid, 0, 2045, 6, 0.039999, 0.000000, 0.250000, 90.000000, 0.000000, 0.000000, 3.800000, 1.300000, 3.800000 ); // CJ_BBAT_NAILS - Replaces Bat
	    GivePlayerWeapon(playerid, 5, 0xffff); // you could change the amount or even remove this if it doesn't apply to you're gm
	}
	else if(losekx == 4)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) Laser!");
		RemovePlayerAttachedObject(playerid,0);
	    SetPlayerAttachedObject( playerid, 0, 2976, 6, -0.100000, 0.000000, 0.100000, 0.000000, 80.000000, 0.000000, 1.000000, 1.000000, 1.500000 ); // green_gloop - Replaces Spas
	    GivePlayerWeapon(playerid, 27, 0xffff);
	}
	else if(losekx == 5)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ(aœ)");
	}
	else if(losekx == 6)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) spawn!");
		SetPlayerRandomSpawn(playerid);
	}
	else if(losekx == 7)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) skok spadochronowy!");
		new Float:PlayerPos[3];
  		GivePlayerWeapon(playerid, 46, 1);
	 	GetPlayerPos(playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);
	 	SetPlayerPos(playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]+500.0);
		SetPlayerHealth(playerid, 100.0);
 		CreateExplosion(PlayerPos[0], PlayerPos[1], PlayerPos[2], 7, 5.0);
	}
	else if(losekx == 8)
	{
		SendClientMessage(playerid, COLOR_LIGHTRED,"Niestety Tym Razem Wygra³eœ(aœ) pobyt w wiêzieniu! (5 minut)");
		JailPlayer(playerid,"Nagroda z Losowania!",5);
	}
	else if(losekx == 9)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ(aœ)");
	}
	else if(losekx == 10)
	{
		SendClientMessage(playerid, COLOR_LIGHTRED,"Niestety Tym Razem Wygra³eœ(aœ) pobyt w wiêzieniu! (1 Minuta)");
		JailPlayer(playerid,"Nagroda z Losowania",1);
	}
	else if(losekx == 11)
	{

		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) pust¹ Paczkê Broni!");
		ResetPlayerWeapons(playerid);
	}
	else if(losekx == 12)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) explozjê!");
		new Float:PlayerPos[3];
	 	GetPlayerPos(playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);
 		CreateExplosion(PlayerPos[0], PlayerPos[1], PlayerPos[2], 7, 5.0);
	}
	else if(losekx == 13)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ!");
	}
	else if(losekx == 15)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ!");
	}
	else if(losekx == 16)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ spadek zdrowia!");
		SetPlayerHealth(playerid, 1);
	}
	else if(losekx == 17)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) ³opatê do kopania grobu!");
		GivePlayerWeapon(playerid, 6, 1);
	}
	else if(losekx == 18)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Nic nie wygra³eœ(aœ)");
	}
	else if(losekx == 19)
	{
		SendClientMessage(playerid, 0xFFFFFFAA,"Wygra³eœ(aœ) Mega Zestaw i kasê!");

		GivePlayerWeapon(playerid, 31, 2000);
		GivePlayerWeapon(playerid, 34, 2000);
		GivePlayerWeapon(playerid, 24, 2000);
		SetPlayerArmour(playerid, 100);
		SetPlayerHealth(playerid, 100);
		GivePlayerMoney(playerid, 1000000);
		Money[playerid] += 1000000;
	}
	else if(losekx == 20)
	{
		SendClientMessage(playerid, COLOR_LIGHTRED,"Niestety Tym Razem Wygra³eœ(aœ) pobyt w wiêzieniu! (1 minuta)");
		JailPlayer(playerid,"Nagroda z losowania!",1);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	if(playerid >= MAX_PLAYERS-1){
		SCM(playerid,-1,"Osi¹gniêto maksymalny limit graczy");
		KickEx(playerid);
		return 0;
	}
	if(BanCheck(playerid)) {
		KickEx(playerid);
		return 0;
	}
//	mysql_query_format("UPDATE `OnLine`,`records` SET `OnLine`.`samp_Name` = '%s', `records`.`record`=`record`+1 WHERE `OnLine`.`samp_ID` ='%d', `records`.`id`='5'", PlayerName(playerid), playerid);
	mysql_query_format("UPDATE `OnLine` SET `samp_Name` = '%s' WHERE `samp_ID` = %d", PlayerName(playerid), playerid);
	joins++;
	
	new tmp[170],active,song[160];
    mysql_query("SELECT `value`, `Active` FROM config WHERE `ID` = '6'");
    mysql_store_result();
	mysql_fetch_row(tmp);
	sscanf(tmp,"p<|>s[128]d",song,active);
	if(active == 1){PlayAudioStreamForPlayer(playerid,song);}
	mysql_free_result();
    if(IsPlayerNPC(playerid)) return 1;
	
	if (playerid > serverHighestID) serverHighestID = playerid;
	
	if (DEBUG_MODE) printf ("OPC: ServerHighestID: %d, playerid: %d", serverHighestID, playerid);
	/*for(new i = GetMaxPlayers(); i !=0;i--)	{
		if(IsPlayerConnected(i)){
			OnlPl=i+1;
			break;
		}
	}*/
	
	new online_players = Itter_Count(Player);
	if(online_players > rekordgraczy){
		rekordgraczy = online_players;
		mysql_query ("update fg_stats set ovalue = NOW() where name = 'mostonlinedate';");
		MSGFA(COLOR_LIGHTGREEN,"Nowy rekord graczy! %d",online_players);
	}

	gPlayerTime[playerid] = gettime();
	Player[playerid][First] = 1;
	Player[playerid][VIP] = 0;
	Player[playerid][Admin] = 0;
	Player[playerid][Warns] = 0;
	Player[playerid][Portfel] = 0;
	pData[playerid][minigun]  = 0;
	pData[playerid][de] = 0;
	pData[playerid][sniper]  = 0;
	pData[playerid][chainsawn] = 0;
	Player[playerid][deagle] =0;
	Player[playerid][minigun] =0;
	Player[playerid][sniper] =0;
	Player[playerid][chainsawn] = 0;
	Player[playerid][wduel] = 0;
	Player[playerid][pduel] = 0;
	Player[playerid][Skin] = 400;
    Player[playerid][Color] = SelectPlayerColor(random(100));
	SetPlayerColor(playerid, Player[playerid][Color]);

    new ip[18], pname[MAX_PLAYER_NAME], pname2[MAX_PLAYER_NAME];
	GetPlayerIp(playerid, ip, sizeof(ip));
	GetPlayerName(playerid, pname2, sizeof(pname2));
	strmid(pname, pname2, 0, strfind(pname2, "_"));
	Hudded[playerid] = false;
	
    for(new x=0;x<MAX_GANGS;x++)
	{
    	PlayerGangInfo[playerid][gInvites][x] = false;
    }
	
	TextDrawShowForPlayer(playerid,Panorama[1]);
	TextDrawShowForPlayer(playerid,Panorama[0]);
	
	TextDrawShowForPlayer(playerid,TextDrawLogoGra1);
	TextDrawShowForPlayer(playerid,TextDrawLogoGra2);
    TextDrawShowForPlayer(playerid,TextDrawLogoGra3);

    Player[playerid][VAnn] = 0;
	AFKMeter[playerid] = false;
  //  IsInJetArena[playerid] = -1;
	Player[playerid][ClickedPlayer] = -1;
    Player[playerid][Level] = 1;
	Locked[playerid] = 0;
    Player[playerid][LottoNumber] = 0;
    InAir[playerid] = 0;
    Player[playerid][RampEnabled] = 0; // WKURWIAJ¥CE RAMPY, OD TERAZ BÊD¥ WY£¥CZONE.
	// Player[playerid][RampEnabled] = 1;
    Player[playerid][RconAkcja] = 0;
	Player[playerid][RampPers] = 1655;
    Player[playerid][Dotacja][0] = false;
	Player[playerid][Dotacja][1] = false;
	Player[playerid][Admin] = false;
    Nrgs[playerid] = 0;
	Player[playerid][Gangster] = -1;
	Player[playerid][MGang] = false;
    CountArenaKills[playerid] = 0;
    Player[playerid][WeaponPickup] = -1;
	Player[playerid][WeaponPickupTime] = 0;
 	VannBlock[playerid] = false;
	Player[playerid][NGang] = false;
	InRC[playerid] = false;
	SendDeathMessage(255,playerid,200);
    ZabitychPodRzad[playerid] = 0;
    PlayerTut[playerid] = false;
    PlayerGangInfo[playerid][gID] = -1;
    CarInfoChce[playerid] = true;
	UziSkill[playerid] = 0;
	SOSkill[playerid] = 0;
    Bombus[playerid] = -1;
	KillBug[playerid] = false;
	ChcePM[playerid] = true;
	RaportBlock[playerid] = false;
	GSTag[playerid] = false;
	PlayerWeapon[playerid][0] = 0;
	PlayerWeapon[playerid][1] = 0;
	PlayerWeapon[playerid][2] = 0;
	PlayerWeaponAmmo[playerid][0] = 0;
	PlayerWeaponAmmo[playerid][1] = 0;
	PlayerWeaponAmmo[playerid][2] = 0;
	bank[playerid] = 0;
	bounty[playerid] = 0;
	kills[playerid] = 0;
	deaths[playerid] = 0;
	killsinarow[playerid] = 0;
	suicides[playerid] = 0;
	wykorzystanyrespekt[playerid] = 0;
	DragTime[playerid] = 100000;
	VpozostaloBlock[playerid] = false;
	AutoBlock[playerid] = false;
	VoteChce[playerid] = true;
	Money[playerid] = 0;
	HouseID[playerid] = -1;
	pLocX[playerid] = 0.0;
	pLocY[playerid] = 0.0;
	pLocZ[playerid] = 0.0;
	Freeze[playerid] = false;
	SoloWyzywa[playerid] = -1;
	ZmieniaAuto[playerid] = false;
	MaDom[playerid] = false;
	SpecOff[playerid] = false;
	SpecVW[playerid] = 0;
	SpecInt[playerid] = 0;
	DragTick[playerid] = 0;
	strdel(Pass[playerid],0,21);
	Invisible[playerid] = false;
	BadPasCount[playerid] = 0;
	VipMozeLogowac[playerid] = false;
	AFK[playerid] = false;
	ChceAnn[playerid] = true;
	RespektPremia[playerid] = 0;
	JailText[playerid] = false;
	Floater[playerid] = false;
	Wiezien[playerid] = false;
	Wybieralka[playerid] = false;
	DragCheck[playerid] = 0;
	Drager[playerid] = false;
	Drager1[playerid] = false;
	Drager2[playerid] = false;
	Drager3[playerid] = false;
	Drager4[playerid] = false;
	TimePlay[playerid] = 0;
	SpamStrings[playerid] = 0;
	CMDspam[playerid] = 0;
	Immunitet[playerid] = false;
	FirstSpawn[playerid] = false;
	MozeDetonowac[playerid] = true;
	SiemaBlock[playerid] = false;
	HitmanBlock[playerid] = false;
	playermuted[playerid] = false;
	Cenzor[playerid] = false;
	Bomber[playerid] = false;
	logged[playerid] = false;
	Pinger[playerid] = 0;
	Respekt[playerid] = 0;
	if(strfind (PlayerName(playerid),"[FG]",true)==0 || strfind (PlayerName(playerid),"FG",true)==0) {
		GSTag[playerid] = true;
	}

//Usuniêcie starych obiektów z Police LS

	RemoveBuildingForPlayer(playerid, 4024, 1479.8672, -1790.3984, 56.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 4044, 1481.1875, -1785.0703, 22.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 4057, 1479.5547, -1693.1406, 19.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 1527, 1448.2344, -1755.8984, 14.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 4210, 1479.5625, -1631.4531, 12.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 713, 1457.9375, -1620.6953, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 713, 1496.8672, -1707.8203, 13.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 1430.1719, -1719.4688, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1451.6250, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 4002, 1479.8672, -1790.3984, 56.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 3980, 1481.1875, -1785.0703, 22.3828, 0.25);
	RemoveBuildingForPlayer(playerid, 4003, 1481.0781, -1747.0313, 33.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1467.9844, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1485.1719, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1713.5078, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.6953, -1716.7031, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1505.1797, -1727.6719, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1713.7031, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1289, 1504.7500, -1711.8828, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1445.0078, -1704.7656, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1702.3594, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1676.6875, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1445.0078, -1692.2344, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1656.2500, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1636.2344, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1445.8125, -1650.0234, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1433.7109, -1619.0547, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 1443.2031, -1592.9453, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1457.7266, -1710.0625, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1461.6563, -1707.6875, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1704.6406, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1463.0625, -1701.5703, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.6953, -1702.5313, 15.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1457.5547, -1697.2891, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1694.0469, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.3828, -1692.3906, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 4186, 1479.5547, -1693.1406, 19.5781, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1461.1250, -1687.5625, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1463.0625, -1690.6484, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 641, 1458.6172, -1684.1328, 11.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1457.2734, -1666.2969, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1468.9844, -1682.7188, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1471.4063, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1479.3828, -1682.3125, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1458.2578, -1659.2578, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1449.8516, -1655.9375, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1477.9375, -1652.7266, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1479.6094, -1653.2500, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1457.3516, -1650.5703, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1454.4219, -1642.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1467.8516, -1646.5938, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1472.8984, -1651.5078, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1465.9375, -1639.8203, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1231, 1466.4688, -1637.9609, 15.6328, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1449.5938, -1635.0469, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1467.7109, -1632.8906, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1465.8906, -1629.9766, 15.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1472.6641, -1627.8828, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1479.4688, -1626.0234, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 3985, 1479.5625, -1631.4531, 12.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 4206, 1479.5547, -1639.6094, 13.6484, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1465.8359, -1608.3750, 15.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1466.4844, -1598.0938, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1451.3359, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1471.3516, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1704.5938, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 700, 1494.2109, -1694.4375, 13.7266, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1693.7344, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1496.9766, -1686.8516, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 641, 1494.1406, -1689.2344, 11.1016, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1488.7656, -1682.6719, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1480.6094, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1488.2266, -1666.1797, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1486.4063, -1651.3906, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1491.3672, -1646.3828, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1493.1328, -1639.4531, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1486.1797, -1627.7656, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, 1491.2188, -1632.6797, 13.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1494.4141, -1629.9766, 15.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, 1494.3594, -1608.3750, 15.3750, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1488.5313, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1498.0547, -1598.0938, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1288, 1504.7500, -1705.4063, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1287, 1504.7500, -1704.4688, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1286, 1504.7500, -1695.0547, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 1285, 1504.7500, -1694.0391, 13.5938, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1498.9609, -1684.6094, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1504.1641, -1662.0156, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1504.7188, -1670.9219, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 620, 1503.1875, -1621.1250, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1501.2813, -1624.5781, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 673, 1498.3594, -1616.9688, 12.3984, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1504.8906, -1596.7031, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 712, 1508.4453, -1668.7422, 22.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1505.6953, -1654.8359, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1508.5156, -1647.8594, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 625, 1513.2734, -1642.4922, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1258, 1510.8906, -1607.3125, 13.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1721.6328, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1705.2734, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1524.2188, -1693.9688, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1688.0859, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1229, 1524.2188, -1673.7109, 14.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1668.0781, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1647.6406, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1524.8281, -1621.9609, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1226, 1525.3828, -1611.1563, 16.4219, 0.25);
	RemoveBuildingForPlayer(playerid, 1283, 1528.9531, -1605.8594, 15.6250, 0.25);

	Attach3DTextLabelToPlayer(PlayerLabel[playerid], playerid, 0.0, 0.0, 1.0);

	PlayerSetColor(playerid);

	// announce
	AnnTD[playerid] = CreatePlayerTextDraw(playerid, 320.000000, 240.000000, "_");
	PlayerTextDrawAlignment(playerid, AnnTD[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, AnnTD[playerid], 48);
	PlayerTextDrawFont(playerid, AnnTD[playerid], 1);
	PlayerTextDrawLetterSize(playerid, AnnTD[playerid], 0.389999, 1.400000);
	PlayerTextDrawColor(playerid, AnnTD[playerid], -1);
	PlayerTextDrawSetOutline(playerid, AnnTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, AnnTD[playerid], 1);
	
	// speedometer: car name, speed, hp
	playerTd_carname[playerid] = CreatePlayerTextDraw(playerid, 476.000000, 382.000000, "~r~~h~~h~~h~Null");
	PlayerTextDrawBackgroundColor(playerid, playerTd_carname[playerid], 20);
	PlayerTextDrawFont(playerid, playerTd_carname[playerid], 2);
	PlayerTextDrawLetterSize(playerid, playerTd_carname[playerid], 0.219999, 1.000000);
	PlayerTextDrawColor(playerid, playerTd_carname[playerid], -1);
	PlayerTextDrawSetOutline(playerid, playerTd_carname[playerid], 1);
	PlayerTextDrawSetProportional(playerid, playerTd_carname[playerid], 1);

	playerTd_carspeed[playerid] = CreatePlayerTextDraw(playerid, 488.000000, 398.000000, "0 ~h~km/h");
	PlayerTextDrawBackgroundColor(playerid, playerTd_carspeed[playerid], 20);
	PlayerTextDrawFont(playerid, playerTd_carspeed[playerid], 2);
	PlayerTextDrawLetterSize(playerid, playerTd_carspeed[playerid], 0.219999, 1.000000);
	PlayerTextDrawColor(playerid, playerTd_carspeed[playerid], 7143423);
	PlayerTextDrawSetOutline(playerid, playerTd_carspeed[playerid], 1);
	PlayerTextDrawSetProportional(playerid, playerTd_carspeed[playerid], 1);

	playerTd_carhealth[playerid] = CreatePlayerTextDraw(playerid, 585.000000, 398.000000, "HP: ~h~0");
	PlayerTextDrawBackgroundColor(playerid, playerTd_carhealth[playerid], 20);
	PlayerTextDrawFont(playerid, playerTd_carhealth[playerid], 2);
	PlayerTextDrawLetterSize(playerid, playerTd_carhealth[playerid], 0.219999, 1.000000);
	PlayerTextDrawColor(playerid, playerTd_carhealth[playerid], 866792447);
	PlayerTextDrawSetOutline(playerid, playerTd_carhealth[playerid], 1);
	PlayerTextDrawSetProportional(playerid, playerTd_carhealth[playerid], 1);
	
	// player data: xp, level, timeplay, wallet
	playerTd_exp[playerid] = CreatePlayerTextDraw(playerid, 355.000000, 434.000000, "100000/424224");
	PlayerTextDrawAlignment(playerid, playerTd_exp[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, playerTd_exp[playerid], 51);
	PlayerTextDrawFont(playerid, playerTd_exp[playerid], 1);
	PlayerTextDrawLetterSize(playerid, playerTd_exp[playerid], 0.209999, 1.100000);
	PlayerTextDrawColor(playerid, playerTd_exp[playerid], -1);
	PlayerTextDrawSetOutline(playerid, playerTd_exp[playerid], 1);
	PlayerTextDrawSetProportional(playerid, playerTd_exp[playerid], 1);

	playerTd_level[playerid] = CreatePlayerTextDraw(playerid, 429.000000, 434.000000, "1");
	PlayerTextDrawAlignment(playerid, playerTd_level[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, playerTd_level[playerid], 51);
	PlayerTextDrawFont(playerid, playerTd_level[playerid], 1);
	PlayerTextDrawLetterSize(playerid, playerTd_level[playerid], 0.209999, 1.100000);
	PlayerTextDrawColor(playerid, playerTd_level[playerid], -1);
	PlayerTextDrawSetOutline(playerid, playerTd_level[playerid], 1);
	PlayerTextDrawSetProportional(playerid, playerTd_level[playerid], 1);

	playerTd_timeplay[playerid] = CreatePlayerTextDraw(playerid, 502.000000, 434.000000, "00h00min");
	PlayerTextDrawAlignment(playerid, playerTd_timeplay[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, playerTd_timeplay[playerid], 51);
	PlayerTextDrawFont(playerid, playerTd_timeplay[playerid], 1);
	PlayerTextDrawLetterSize(playerid, playerTd_timeplay[playerid], 0.209999, 1.100000);
	PlayerTextDrawColor(playerid, playerTd_timeplay[playerid], -1);
	PlayerTextDrawSetOutline(playerid, playerTd_timeplay[playerid], 1);
	PlayerTextDrawSetProportional(playerid, playerTd_timeplay[playerid], 1);

	playerTd_portfel[playerid] = CreatePlayerTextDraw(playerid, 573.500000, 434.000000, "00 zl");
	PlayerTextDrawAlignment(playerid, playerTd_portfel[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, playerTd_portfel[playerid], 51);
	PlayerTextDrawFont(playerid, playerTd_portfel[playerid], 1);
	PlayerTextDrawLetterSize(playerid, playerTd_portfel[playerid], 0.209999, 1.100000);
	PlayerTextDrawColor(playerid, playerTd_portfel[playerid], -1);
	PlayerTextDrawSetOutline(playerid, playerTd_portfel[playerid], 1);
	PlayerTextDrawSetProportional(playerid, playerTd_portfel[playerid], 1);
	
	SendClientMessage(playerid, COLOR_INFO, " Witaj na serwerze FullGaming");
	mysql_query_format ("SELECT `id` FROM `fg_Players` WHERE `Nick` = '%s' limit 1;", PlayerName(playerid));
    mysql_store_result();
    if(mysql_num_rows()) {
		new buf[255];
		format(buf, sizeof(buf)-1, "Witaj, %s!\nKonto pod tym nickiem jest zarejestrowane\nWpisz swoje haslo, w przeciwnym wypadku opusc serwer", PlayerName(playerid));
		ShowPlayerDialog(playerid, 7, DIALOG_STYLE_PASSWORD, " Witamy na FullGaming!", buf, "Zaloguj", "Wyjdz");
		MozeMowic[playerid] = false;
		Registered[playerid] = true;
	}
	else
	{
		SendClientMessage(playerid, COLOR_GREEN, " Zostañ naszym sta³ym graczem - dopisz do swojego nicku tag [FG] np. [FG]Moj_Nick! ;-)");
		SendClientMessage(playerid, COLOR_YELLOW, " Nie jestes jeszcze u nas zarejestrowany. Aby to zrobic uzyj /rejestracja");
		SendClientMessage(playerid, COLOR_YELLOW, " Po zarejestrowaniu konta wszelkie statystyki beda zapisane. Na FullGaming.pl mozesz wygenerowac sobie wlasna sygnature.");
		Respekt[playerid] = 0;
		MozeMowic[playerid] = true;
		Registered[playerid] = false;
		
		SendClientMessage(playerid, COLOR_INFO, " Za do³¹czenie na serwer dostajesz 1 exp.");
		Respekt[playerid] += 1;
	}
	mysql_free_result();
	return 1;
}

ControlLevelUp(PlayerId)
{
    if(Player[PlayerId][Level] < GetPlayerLevel(PlayerId))
  	{
		LevelUp(PlayerId);
	}
}

//------------------------------------------------------------------------------------------------------
public OnPlayerDisconnect(playerid, reason)
{
	for (new i=serverHighestID; i>=0; i--)
		if ((IsPlayerConnected(i) && i!=playerid) || i==0) {
			serverHighestID=i; break;
		}
	
	if (DEBUG_MODE) printf ("OPD: ServerHighestID: %d, playerid: %d", serverHighestID, playerid);
	
	SendDeathMessage(255,playerid,201);
    if(Player[playerid][RampCreated])
	{
		DestroyPlayerObject(playerid, Player[playerid][Ramp]);
		Player[playerid][RampCreated] = false;
	}
	
	if(GameCreate == playerid)
	{
	    GameCreate = INVALID_PLAYER_ID;
	}

	PlayerTextDrawDestroy(playerid, AnnTD[playerid]);
	PlayerTextDrawDestroy(playerid, playerTd_exp[playerid]);
	PlayerTextDrawDestroy(playerid, playerTd_level[playerid]);
	PlayerTextDrawDestroy(playerid, playerTd_timeplay[playerid]);
	PlayerTextDrawDestroy(playerid, playerTd_portfel[playerid]);
	PlayerTextDrawDestroy(playerid, playerTd_carname[playerid]);
	PlayerTextDrawDestroy(playerid, playerTd_carspeed[playerid]);
	PlayerTextDrawDestroy(playerid, playerTd_carhealth[playerid]);
    
	KillTimer(GetPVarInt(playerid, "TIMER"));
    KillTimer(GetPVarInt(playerid, "TIMER2"));

//	new playername[MAX_PLAYER_NAME];
//	GetPlayerName(playerid, playername, sizeof(playername));

	if(VoteON){
		TextDrawHideForPlayer(playerid,Glosowanie);
	}
	if(logged[playerid]) 
	{
		SaveData(playerid);
		mysql_query_format("UPDATE `fg_Players` SET `Online`='0' WHERE `Nick`='%s'",PlayerName(playerid));
	}
	mysql_query_format("UPDATE `OnLine`SET `samp_Name` = NULL WHERE `samp_ID` = %d", playerid);
	
	new tmp[128];
	format(tmp, sizeof(tmp), "UPDATE `Kody` SET Ilosc='%d' WHERE `Nick` = '%s'", WygraneKod[playerid], PlayerName(playerid));
	mysql_query(tmp);
	

	Player[playerid][RampEnabled] = 0;
	Player[playerid][RampPers] = 0;
	gSpectateID[playerid] = -1;
	IsInShml[playerid] = 0;
	PlayerLeaveGang(playerid);
	for(new x=0;x<10;x++)
	{
		if(RaportID[x] == playerid)
		{
			RaportID[x] = -1;
			break;
		}
	}
	
	if(MaDom[playerid]){
		new x=HouseID[playerid];
		new budgetstr[12];
		valstr(budgetstr,HouseInfo[x][hBudget]);
		house_Update(x,8,budgetstr);
	}

	if(SoloPlayer[0] == playerid){

		foreachPly (x) {
			if(PlayerToPoint(100,x,1939.2324,-2499.2456,43.5088)){
				new string2[256];
				format(string2,sizeof(string2),"Solo wygrywa: ~r~%s~n~~w~(przeciwnik wyszedl z gry)",PlayerName(SoloPlayer[1]));
				SoundForAll(1150);
				AnnForPlayer(x,5000,string2);
			}
		}
		SoloEnd(playerid);
	}else if(SoloPlayer[1] == playerid){

		foreachPly (x) {
			if(PlayerToPoint(100,x,1939.2324,-2499.2456,43.5088)){
			    new string2[80];
				format(string2,sizeof(string2),"Solo wygrywa: ~r~%s~n~~w~(przeciwnik wyszedl z gry)",PlayerName(SoloPlayer[0]));
                SoundForAll(1150);
				AnnForPlayer(x,5000,string2);
			}
		}
		SoloEnd(playerid);
	}

	logged[playerid] = false;
	strdel(LoginNick[playerid],0,MAX_PLAYER_NAME);

	KillTimer(JailTimer[playerid]);

	switch(reason)
	{
		case 0:
		{
			new string[120];
			if(joininfoadmin == 1){
				format(string, sizeof(string), "{a0a0a0} * {707070}%s (%d) {a0a0a0}opuœci³(a) serwer (crash) (IP: %s)", PlayerName(playerid),playerid,PlayerIP(playerid));
				SendClientMessageToAdmins(0x0, string);
			}

			if (joininfo == 1) {

				format(string, sizeof(string), "{a0a0a0} * {707070}%s (%d) {a0a0a0}opuœci³(a) serwer", PlayerName(playerid),playerid);
				SendClientMessageToPlayers(0x0, string);
			}

		}
		case 1:
		{
			new string[120];
			if(joininfoadmin == 1){
				format(string, sizeof(string), "{a0a0a0} * {707070}%s (%d) {a0a0a0}opuœci³(a) serwer (IP: %s)", PlayerName(playerid),playerid,PlayerIP(playerid));
				SendClientMessageToAdmins(0x0, string);
			}


			if (joininfo == 1) {
				format(string, sizeof(string), "{a0a0a0} * {707070}%s (%d) {a0a0a0}opuœci³(a) serwer", PlayerName(playerid),playerid);
				SendClientMessageToPlayers(0x0, string);
			}
		}
	}
	
	KillTimer(GetPVarInt(playerid, "SpawnTimer"));
	return 1;
}
//------------------------------------------------------------------------------------------------------

//public OnPlayerCommandPerformed(success, playerid, cmdtext[])
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	if(!success)
	{
		SendClientMessage(playerid,COLOR_RED2,"Serwer nie moze odnalezc takiej komendy. Sprawdz liste komend: /cmd lub /help");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(!MozeMowic[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Komendy zablokowane! Wype³nij najpierw Panel Logowania!");
		new buffff[255];
		format(buffff, sizeof(buffff)-1, "Witaj, %s!\nKonto pod tym nickiem jest zarejestrowane\nWpisz swoje haslo, w przeciwnym wypadku opusc serwer", PlayerName(playerid));
		ShowPlayerDialog(playerid, 7, DIALOG_STYLE_PASSWORD, " Witamy na FullGaming!", buffff, "Zaloguj", "Wyjdz");
		return 0;
	}
	if(!IsAdmin(playerid,1)){
		if(CMDspam[playerid] >= 10) {
			SendClientMessage(playerid,COLOR_RED," * Zosta³eœ wyrzucony z serwera za spam!");
			KickEx(playerid);
			return 0;
		}
		CMDspam[playerid] ++;
		if(CMDspam[playerid] >= 4) {
			SendClientMessage(playerid,COLOR_RED,"Komendy zosta³y chwilowo zablokowane!");
			return 0;
		}
		if(Cenzor[playerid] || Wiezien[playerid]){
			SendClientMessage(playerid, COLOR_RED, "Masz zablokowan¹ mo¿liwoœæ wpisywania komend!");
			return 0;
		}

		if(strfind(cmdtext,"/rsp",true) == 0) return 1;
		if(strfind(cmdtext,"/flo",true) == 0) return 1;
		if(strfind(cmdtext,"/pm",true) == 0) return 1;
		if(strfind(cmdtext,"/raport",true) == 0) return 1;
		if(strfind(cmdtext,"/toadmin",true) == 0) return 1;
	

	    if(SoloPlayer[0] == playerid || SoloPlayer[1] == playerid){
			if(strfind(cmdtext,"/soloexit",true) == 0) return 1;
			SendClientMessage(playerid, COLOR_RED2, "Podczas solówki nie mo¿na u¿ywaæ komend, wyj¹tek: {FFFFFF}/SoloExit");
            PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
			return 0;
		}

	}
	if(pData[playerid][de] == 1 && !MyStrCmp(cmdtext, StrToLower("/deexit")))
	{
		ShowPlayerDialog(playerid, DIALOG_EXITARENA, DIALOG_STYLE_MSGBOX, "Arena", ""iFGS"\n{FFFFFF}Jesteœ na arene Desert Deagle!\n{FFFFFF}Aby wyjœæ z areny wpisz: /deexit albo kliknij TAK", "Tak", "Nie");
		return 0;
	}
	else if(pData[playerid][minigun] == 1 && !MyStrCmp(cmdtext, StrToLower("/minigunexit")))
	{
		ShowPlayerDialog(playerid, DIALOG_EXITARENA, DIALOG_STYLE_MSGBOX, "Arena", ""iFGS"\n{FFFFFF}Jesteœ na arene Minigun!\n{FFFFFF}Aby wyjœæ z areny wpisz: /minigunexit albo kliknij TAK", "Tak", "Nie");
		return 0;
	}	
	else if(pData[playerid][sniper] == 1 && !MyStrCmp(cmdtext, StrToLower("/sniperexit")))
	{
		ShowPlayerDialog(playerid, DIALOG_EXITARENA, DIALOG_STYLE_MSGBOX, " Arena", ""iFGS"\n{FFFFFF}Jesteœ na arene Sniper!\n{FFFFFF}Aby wyjœæ z areny wpisz: /sniperexit albo kliknij TAK", "Tak", "Nie");
		return 0;
	}			
	else if(pData[playerid][chainsawn] == 1 && !MyStrCmp(cmdtext, StrToLower("/chainsawexit")))
	{
		ShowPlayerDialog(playerid, DIALOG_EXITARENA, DIALOG_STYLE_MSGBOX, "Arena", ""iFGS"\n{FFFFFF}Jesteœ na arene Chainsaw!\n{FFFFFF}Aby wyjœæ z areny wpisz: /chainsawexit albo kliknij TAK", "Tak", "Nie");
		return 0;
	}	
	return 1;
}

//------------------------------------------------------------------------------------------------------

stock ContainsIP(const string[])
{
	static RegEx:rCIP;                                                                          
	if (!rCIP) rCIP = regex_build(".*[0-9]{1,3}[^0-9]{1,3}[0-9]{1,3}[^0-9]{1,3}[0-9]{1,3}[^0-9]{1,3}[0-9]{1,3}[^0-9]{1,7}[0-9]{3,5}.*");
	return regex_match_exid(string, rCIP);
}

public OnPlayerText(playerid, text[])
{
	if(!MozeMowic[playerid])
	{
		SendClientMessage(playerid,COLOR_RED2,"Ten nick jest zarejestrowany, zaloguj siê aby pisaæ na czacie");
		new buffff[255];
		format(buffff, sizeof(buffff)-1, "Witaj, %s!\nKonto pod tym nickiem jest zarejestrowane\nWpisz swoje haslo, w przeciwnym wypadku opusc serwer", PlayerName(playerid));
		ShowPlayerDialog(playerid, 7, DIALOG_STYLE_PASSWORD, " Witamy na FullGaming!", buffff, "Zaloguj", "Wyjdz");
		return 0;
	}
	
	if(!ChatON && !IsAdmin(playerid,1))
	{
		SendClientMessage(playerid, COLOR_RED2, "Chat jest wy³¹czony przez admina!");
		return 0;
	}

	if(playermuted[playerid] && !IsAdmin(playerid,2) || Wiezien[playerid])
	{
		SendClientMessage(playerid, COLOR_RED2, "Masz zablokowan¹ mo¿liwoœæ pisania!");
		return 0;
	}

	if(SpamStrings[playerid] >= 10) 
	{
		SendClientMessage(playerid,COLOR_RED," * Zosta³eœ wyrzucony z serwera za spam.");
		KickEx(playerid);
		return 0;
	}

	if(SpamStrings[playerid]++ >= 3 && !IsAdmin(playerid,1)) 
	{
		SendClientMessage(playerid,COLOR_RED,"Nie spamuj na serwerze! Kolejne ostrze¿enia mog¹ siê skoñczyæ kickiem!");
		return 0;
	}
	
	// 
	new buf[160];
	//
	if(TestReaction == 1 && !strcmp(text, gStringReaction))
	{
		format(buf, sizeof(buf), "%s (%d) przepisa³(a) jako pierwszy(a) Test Reakcji!", PlayerName(playerid), playerid);
		SendClientMessageToAll(COLOR_INFO, buf);
		
		format(buf, sizeof(buf), "Otrzymuje on(a) 15 exp i $5000 - przepisa³(a) ju¿ %d %s reakcji.", WygraneKod[playerid], dli(WygraneKod[playerid], "test", "testów", "testów"));
		SendClientMessageToAll(COLOR_INFO, buf);
		
		ReactionTimeout();
		WygraneKod[playerid]++;
		Respekt[playerid] += 15;
		Money[playerid] += 5000;
		return 0;
	}
	
	if(ContainsIP(text)) 
	{
		format(buf, sizeof(buf), "{666666}%d {%06x}%s:{FFFFFF} %s", playerid, GetPlayerColor(playerid) >>> 8, PlayerName(playerid), text);
		SendClientMessage(playerid, 0, buf);
		
		SendClientMessageToAdmins(0, buf);
		
		format(buf, sizeof(buf), "Ninjabanowana próba reklamy przez %s (%d)",PlayerName(playerid), playerid);
		SendClientMessageToAdmins(GetPlayerColor(playerid), buf);
		return 0;
	}

	if(text[0] == '!' && Player[playerid][MGang])
	{
		format(buf, sizeof(buf), " [Gang] %s: %s", PlayerName(playerid), text[1]);
		SendClientMessageToGang(MGANG, buf);
		return 0;
	}

	if(text[0] == '!' && Player[playerid][NGang])
	{
		format(buf, sizeof(buf), " [Gang] %s: %s", PlayerName(playerid), text[1]);
		SendClientMessageToGang(NGANG, buf);
		return 0;
	}
	
	if(text[0] == '@' && IsAdmin(playerid, 2))
	{
		format(buf, sizeof(buf), "{D50101}[AC] {970000}%s{FFFF11}: %s", PlayerName(playerid), text[1]);
		SendClientMessageToAdmins(0, buf);
		WriteLogFormat("[AC]%s(%d): %s", PlayerName(playerid), playerid, text[1]);
		return 0;
	}

	if(text[0] == '!'){

	    if(PlayerGangInfo[playerid][gID] == -1)
		{
	        SendClientMessage(playerid,COLOR_RED2,"Nie masz gangu!");
	    	return 0;
	    }
		
		format(buf, sizeof(buf), "[Gang] %s (%d): %s", PlayerName(playerid), playerid, text[1]);
	    foreachPly(x) 
		{
			if(PlayerGangInfo[x][gID] == PlayerGangInfo[playerid][gID])
			{
			    SendClientMessage(x, COLOR_LIGHTBLUE, buf);
			}
	    }
		return 0;
	}

 	format(buf, sizeof(buf), "%d {%06x}%s:{FFFFFF} %s", playerid, GetPlayerColor(playerid) >>> 8, PlayerName(playerid), text);
    SendClientMessageToAll((Player[playerid][Admin] >= 4)? 0xB00000ff: (Player[playerid][Admin] > 2)? 0xC20000ff: (Player[playerid][Admin] == 1)? 0x2C9629ff: (Respekt[playerid] >= 10000)? 0x75A8FFFF: 0x666666ff, buf);
	return 0;
}

//------------------------------------------------------------------------------------------------------

SendClientMessageToGang(GangId, Text[])
{
	new MColor;
	if(GangId == MGANG)
		MColor = COLOR_RASPBERRY;
	else if(GangId == NGANG)
	    MColor = COLOR_NGANG;
	else
	    MColor = COLOR_GANG;
	foreachPly (PlayerId)
	    if(IsPlayerConnected(PlayerId) && (Player[PlayerId][Gangster] == GangId || (GangId == MGANG && Player[PlayerId][MGang]) || (GangId == NGANG && Player[PlayerId][NGang])))
	        SendClientMessage(PlayerId, MColor, Text);
}

forward FloaterOff(playerid);
public FloaterOff(playerid)
{
	Floater[playerid] = false;
	return 1;
}

public OnPlayerSpawn(playerid)
{

	FloatDeath[playerid] = false;

	if(pData[playerid][de] == 1)
	{
	    ArenaDe(playerid);
	    return 1;
	}
	if(pData[playerid][minigun] == 1)
	{
	    ArenaMinigun(playerid);
	    return 1;
	}
	if(pData[playerid][sniper] == 1)
	{
	    ArenaSniper(playerid);
	    return 1;
	}
	if(pData[playerid][chainsawn] == 1)
	{
	    ArenaChainsawn(playerid);
	    return 1;
	}


	if(Floater[playerid])
	{
		SetPlayerInterior(playerid, inter);
		SetPlayerVirtualWorld(playerid,RspWorld);
		SetPlayerHealth(playerid, healthrsp);
		SetPlayerArmour(playerid, armourrsp);
		GivePlayerWeapon(playerid, bron1, ammorsp);
		GivePlayerWeapon(playerid, bron2, ammo2);
		GivePlayerWeapon(playerid, bron3, ammo3);
		GivePlayerWeapon(playerid, bron4, ammo4);
		GivePlayerWeapon(playerid, bron5, ammo5);
		GivePlayerWeapon(playerid, bron6, ammo6);
		GivePlayerWeapon(playerid, bron7, ammo7);
		GivePlayerWeapon(playerid, bron8, ammo8);
		GivePlayerWeapon(playerid, bron9, ammo9);
		GivePlayerWeapon(playerid, bron10, ammo10);
		GivePlayerWeapon(playerid, bron11, ammo11);
		GivePlayerWeapon(playerid, bron12, ammo12);
		GivePlayerWeapon(playerid, bron13, ammo13);
		SetCameraBehindPlayer(playerid);
		SetTimerEx("FloaterOff",5000,0,"i",playerid);
		return 1;
	}

	if(SpecOff[playerid])
	{
		SetPlayerVirtualWorld(playerid,SpecVW[playerid]);
		SetPlayerInterior(playerid,SpecInt[playerid]);
		SetPlayerPos(playerid,SpecPosX[playerid],SpecPosY[playerid],SpecPosZ[playerid]);
		SpecVW[playerid] = 0;
		SpecInt[playerid] = 0;
		SpecOff[playerid] = false;
		return 1;
	}
	
	SetPlayerHealth(playerid, 100.0);
    GiveStandardWeapon(playerid);
	SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
	SetPlayerVirtualWorld(playerid,0);
	SpecOff[playerid] = false;
	PlayerTut[playerid] = false;
	Wybieralka[playerid] = false;
	KillBug[playerid] = false;

    GivePlayerMoney(playerid, 15000);
	Money[playerid] += 15000;

	if(!FirstSpawn[playerid])
	{
	    SetCameraBehindPlayer(playerid);
        for(new x=0;x<HOUSES_LOOP;x++)
		{
			if(strlen(HouseInfo[x][hOwner]) >= 3)
			{
				RemovePlayerMapIcon(playerid, x);
				SetPlayerMapIcon(playerid, x, HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z], 32,0);
			}
			else
			{
				RemovePlayerMapIcon(playerid, x);
				SetPlayerMapIcon(playerid, x, HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z], 31,0);
			}

	        if(HouseID[playerid] == x)
			{
					RemovePlayerMapIcon(playerid, x);
					SetPlayerMapIcon(playerid, x, HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z], 35,0);
			}
		}

		PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
        PlayerPlaySound(playerid, 1149, 0.0, 0.0, 0.0);

		SetPlayerRandomSpawn(playerid);

        PlayerSetColor(playerid);

		UnPanorama (playerid);
		TextDrawShowForPlayer(playerid, Czas);
       
		TextDrawShowForPlayer(playerid,logoFullGaming);
		TextDrawShowForPlayer(playerid,urlFullGaming);

		TextDrawShowForPlayer(playerid,tabelka_zapisow_box);
		TextDrawShowForPlayer(playerid,tabelka_zapisow_label[0]);
		TextDrawShowForPlayer(playerid,tabelka_zapisow_label[1]);
		
		TextDrawShowForPlayer(playerid, OnlineUsers);
        PlayerLabelOff(playerid);
        ShowPlayerPasek(playerid);

		SetTimerEx("UpdateNextLevel", 1000, false,"d",playerid);

		if(TimePlay[playerid] < 5)
		{
            SendClientMessage(playerid,COLOR_ORANGE,"");
  			SendClientMessage(playerid,COLOR_ORANGE," Je¿eli jesteœ nowy(a) na serwerze zalecamy zapoznaæ siê z {FFFF00}/tutorial{FF9900}.");
		}
	}

	SetPlayerRandomSpawn(playerid);
	Freeze[playerid] = false;
	FirstSpawn[playerid] = true;

	return 1;
}

//------------------------------------------------------------------------------------------------------



//------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
	globdeaths++;
	FloatDeath[playerid] = true;
	IsInShml[playerid] = 0;
  //  IsInJetArena[playerid] = -1;
	Money[playerid] = 0;
	deaths[playerid] ++;

	ZabitychPodRzad[playerid] = 0;
    SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000); //Reset world to player
	
	if(killerid == INVALID_PLAYER_ID)
	{
		SendDeathMessage(INVALID_PLAYER_ID,playerid,reason);
		suicides[playerid] ++;
		globsuicides++;
		if(logged[playerid])
		{
			if(IsVIP(playerid))
			{
            	SendClientMessage(playerid,COLOR_RED2,"Nie straci³eœ(aœ) exp poniewa¿ jesteœ VIP'em.");
			}
			else
			{
	            SendClientMessage(playerid, COLOR_RED2,"Straci³eœ(aœ) 1 pkt exp za pope³nienie samobójstwa!");
				Respekt[playerid] -= 1;
			}
		}
	}
	else
	{
		Respekt[playerid] -= 1;

		kills[killerid] ++;
		globkills++;
		globdeaths++;
		ZabitychPodRzad[killerid] ++;
		if(ZabitychPodRzad[killerid] > killsinarow[killerid]){
			killsinarow[killerid] ++;
		}
		
		new kasagracza = GetPlayerMoney(playerid)/2;
		
		if(kasagracza > 0)
		{
			GivePlayerMoney(killerid, kasagracza);
			Money[killerid] += kasagracza;
		}
		
		if(logged[killerid])
		{
            ControlLevelUp(killerid);
			Respekt[killerid] ++;
		}
		SendDeathMessage(killerid,playerid,reason);
		if(bounty[playerid] > 0) {
		    new name[MAX_PLAYER_NAME];
		    new stringX[200];
		    GetPlayerName(playerid, name, sizeof(name));
			format(stringX, sizeof(stringX), "Dosta³eœ nagrode pieniê¿n¹: $%d za zabicie %s", bounty[playerid],name);
			SendClientMessage(killerid, COLOR_GREEN, stringX);
            format(stringX, sizeof(stringX), "{28730A} * {3BAD00}Gracz {28730A}%s {3BAD00}zdoby³ g³owê gracza {28730A}%s{3BAD00}. Nagroda: {28730A}$%d{3BAD00}.", PlayerName(killerid), PlayerName(playerid), bounty[killerid]);
			SendClientMessage(killerid, COLOR_GREEN, stringX);
			GivePlayerMoney(killerid, bounty[playerid]);
			Money[killerid] += bounty[playerid];
			bounty[playerid] = 0;
		}
			
		if(pData[playerid][de] == 1)
		{
			Player[killerid][deagle] +=2;
			Player[playerid][deagle]--;
		}
		else if(pData[playerid][minigun] == 1)
		{
			Player[killerid][minigun] +=2;
			Player[playerid][minigun]--;
		}
		else if(pData[playerid][sniper] == 1)
		{
			Player[killerid][sniper] +=2;
				Player[playerid][sniper]--;
		}
		else if(pData[playerid][chainsawn] == 1)
		{
			Player[killerid][chainsawn] +=2;
			Player[playerid][chainsawn]--;
		}
	}
	
	if(IsAdmin(killerid,2)) return 1;
	if(Immunitet[killerid]) return 1;
	if(KillBug[playerid]) return 1;

	if(PlayerToPoint(15,killerid,-27.2098,-52.6179,1003.5469))
	{
		JailPlayer(killerid,"Zabijanie w banku",5);
		return 1;
	}

	if(Wiezien[killerid] || Wiezien[playerid])
	{
		JailPlayer(killerid,"Zabijanie w wiêzieniu",5);
		return 1;
	}

	if(IsPlayerInArea(killerid,605.5474,1390.8591,-1423.9529,-1328.6188))
	{
		JailPlayer(killerid,"Zabijanie na Dragu",3);
		return 1;
	}

	if(PlayerToPoint(100,killerid,1939.2324,-2499.2456,43.5088) && SoloPlayer[0] != killerid && SoloPlayer[1] != killerid)
	{
		JailPlayer(killerid,"Zabijanie w poczekalni solowek",2);
		return 1;
	}

	if(GetPlayerState(killerid) != PLAYER_STATE_DRIVER) return 1;
	if(IsPlayerInFreeZone(killerid)) return 1;

	JailPlayer(killerid,"Zabijanie z u¿yciem pojazdu",3);
	if(IsPlayerInBezDmZone(playerid))
    {
        JailPlayer(killerid,"Zabijanie w strefie bez DM! (1 Minuta)",1);
	}

    DropWeapons(playerid);


	if(SoloPlayer[0] == playerid)
	{
		foreachPly (x) 
		{
			if(PlayerToPoint(100,x,1939.2324,-2499.2456,43.5088))
			{
			    new stringX[50];
				format(stringX,sizeof(stringX),"Solo wygrywa: ~r~%s",PlayerName(SoloPlayer[1]));
				AnnForPlayer(x,5000,stringX);
			}
		}
		SetTimerEx("SoloEnd",1000,0,"i",playerid);
		return 1;
	}
	else if(SoloPlayer[1] == playerid)
	{

		foreachPly (x) 
		{
			if(PlayerToPoint(100,x,1939.2324,-2499.2456,43.5088))
			{
			    new stringX[50];
				format(stringX,sizeof(stringX),"Solo wygrywa: ~r~%s",PlayerName(SoloPlayer[0]));
				AnnForPlayer(x,5000,stringX);
			}
		}
		SetTimerEx("SoloEnd",1000,0,"i",playerid);
		return 1;
	}
	return 1;
}

//------------------------------------------------------------------------------------------------------
public OnPlayerEnterRaceCheckpoint(playerid)
{

	if(Drager[playerid]){
		DragCheck[playerid] ++;
		PlayerPlaySound(playerid,1057,0,0,0);

		if(DragCheck[playerid] == 1){
			if(Drager1[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,848.0184,-1392.2720,13.1114,966.4977,-1392.7513,12.8072,5);

			}else if(Drager2[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,848.2114,-1397.7303,12.7792,966.8767,-1398.0573,12.7047,5);

			}else if(Drager3[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,848.5390,-1402.8962,13.1847,967.2685,-1402.6027,13.0538,5);

			}else if(Drager4[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,848.4573,-1408.2458,12.9308,965.1777,-1408.0708,12.8785,5);

			}
		}

		if(DragCheck[playerid] == 2){
			if(Drager1[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,966.4977,-1392.7513,12.8072,1091.8967,-1392.9240,13.2658,5);
			}else if(Drager2[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,966.8767,-1398.0573,12.7047,1092.4669,-1398.4116,13.0968,5);

			}else if(Drager3[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,967.2685,-1402.6027,13.0538,1093.7964,-1402.9365,13.3639,5);

			}else if(Drager4[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,965.1777,-1408.0708,12.8785,1093.6565,-1407.8411,13.1829,5);

			}

		}

		if(DragCheck[playerid] == 3){
			if(Drager1[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1091.8967,-1392.9240,13.2658,1225.4003,-1392.8851,12.9379,5);
			}else if(Drager2[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1092.4669,-1398.4116,13.0968,1225.0206,-1397.9462,12.7785,5);

			}else if(Drager3[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1093.7964,-1402.9365,13.3639,1224.3564,-1403.2108,13.0298,5);

			}else if(Drager4[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1093.6565,-1407.8411,13.1829,1226.7388,-1407.6307,12.8202,5);

			}

		}


		if(DragCheck[playerid] == 4){
			if(Drager1[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1225.4003,-1392.8851,12.9379,1335.0629,-1393.2385,13.1205,5);

			}else if(Drager2[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1225.0206,-1397.9462,12.7785,1335.0239,-1398.0027,12.9679,5);

			}else if(Drager3[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1224.3564,-1403.2108,13.0298,1335.1765,-1403.1411,13.2389,5);

			}else if(Drager4[playerid]){
				SetPlayerRaceCheckpoint(playerid,0,1226.7388,-1407.6307,12.8202,1335.2096,-1407.9459,13.0682,5);

			}

		}


		if(DragCheck[playerid] == 5){
			if(Drager1[playerid]){
				SetPlayerRaceCheckpoint(playerid,1,1335.0629,-1393.2385,13.1205,1335.0629,-1393.2385,13.1205,5);

			}else if(Drager2[playerid]){
				SetPlayerRaceCheckpoint(playerid,1,1335.0239,-1398.0027,12.9679,1335.0239,-1398.0027,12.9679,5);

			}else if(Drager3[playerid]){
				SetPlayerRaceCheckpoint(playerid,1,1335.1765,-1403.1411,13.2389,1335.1765,-1403.1411,13.2389,5);

			}else if(Drager4[playerid]){
				SetPlayerRaceCheckpoint(playerid,1,1335.2096,-1407.9459,13.0682,1335.2096,-1407.9459,13.0682,5);

			}

		}

		if(DragCheck[playerid] == 6){
			DragMiejsce ++;

			new Bla = GetTickCount();
			new Bla2 = Bla-DragTick[playerid];
			new string[512];
			format(string, sizeof(string), "[Drag] {00EEAD}%s {0080FF}Dojecha³/a na metê!  {0080FF}> {00EEAD}%d {0080FF}miejsce < {00EEAD}(%d:%03d)",PlayerName(playerid),DragMiejsce,Bla2/1000,Bla2-((Bla2/1000)*1000));
			SendClientMessageToAllDrag(0x0080FFFF,string);
            SoundForAll(1050);
			Drager[playerid] = false;
			DragCheck[playerid] = 0;
			Drager1[playerid] = false;
			Drager2[playerid] = false;
			Drager3[playerid] = false;
			Drager4[playerid] = false;
			DisablePlayerRaceCheckpoint(playerid);

			if(Bla2 >= 12500){

				if(DragTime[playerid] > Bla2){
					DragTime[playerid] = Bla2;
					SendClientMessage(playerid,COLOR_GREEN,"Poprawi³eœ(aœ) swój rekordowy czas na Dragu!");
				}

			}else{
				SendClientMessage(playerid,COLOR_RED2,"Twój czas wydaje siê nieosi¹galny i nie jest brany pod uwagê!");
			}

			SetTimerEx("DragTeleport",3000,0,"i",playerid);

			if(DragMiejsce == 1){
			    WinSound(playerid);
				GivePlayerMoney(playerid,10000);
				Money[playerid] += 10000;
				if(logged[playerid]){
					GameTextForPlayer(playerid,"~w~EXP ~g~~h~+2", 2500, 3);
                    ControlLevelUp(playerid);
					Respekt[playerid] += 2;
                    PlayerPlaySound(playerid,1149,0.0,0.0,0.0);
				}

			}

			if(DragMiejsce == 2){
				GivePlayerMoney(playerid,5000);
				Money[playerid] += 5000;
			}

			if(DragMiejsce == 3){
				GivePlayerMoney(playerid,2500);
				Money[playerid] += 2500;
			}

			if(DragMiejsce == 4){
				GivePlayerMoney(playerid,1000);
				Money[playerid] += 1000;
			}
			if(DragMiejsce >= 4 || DragMiejsce >= Dragliczba){

				DragON = false;
				DragMiejsce = 0;
				Dragliczba = 0;
				KillTimer(DragTimer);
				foreachPly (x) {
					if(Drager[x]){
						DisablePlayerCheckpoint(x);
						DisablePlayerRaceCheckpoint(x);
						Drager[x] = false;
						Drager1[x] = false;
						Drager2[x] = false;
						Drager3[x] = false;
						Drager4[x] = false;
						DragCheck[x] = 0;
					}
				}

			}
		}
		return 1;
	}


	if(IsPlayerInArea(playerid,2891.5725,3291.5725,-1718.9702,-1318.9702)){
		new str[30];
		if(RuraCD[playerid] == 0){
			SetPlayerRaceCheckpoint(playerid,3,3094.2212, -1536.1183, 1205.6886,3096.5774, -1518.2262, 1002.3639,2);
			MaRure[playerid] ++;
			RuraCD[playerid] ++;
			PlayerPlaySound(playerid, 1057, 0, 0, 0);
	
			format(str,sizeof(str),"~n~~n~~n~~n~~n~~n~~n~%d/8",RuraCD[playerid]);
			GameTextForPlayer(playerid,str,3000,3);
		}else if(RuraCD[playerid] == 1){
			SetPlayerRaceCheckpoint(playerid,3,3096.5774, -1518.2262, 1002.3639,3097.6829, -1537.4142, 889.6663,2);
			MaRure[playerid] ++;
			RuraCD[playerid] ++;
			PlayerPlaySound(playerid, 1057, 0, 0, 0);
		
			format(str,sizeof(str),"~n~~n~~n~~n~~n~~n~~n~%d/8",RuraCD[playerid]);
			GameTextForPlayer(playerid,str,3000,3);
		}else if(RuraCD[playerid] == 2){
			SetPlayerRaceCheckpoint(playerid,3,3097.6829, -1537.4142, 889.6663,3100.4736, -1518.8101, 700.3438,2);
			MaRure[playerid] ++;
			RuraCD[playerid] ++;
			PlayerPlaySound(playerid, 1057, 0, 0, 0);
			
			format(str,sizeof(str),"~n~~n~~n~~n~~n~~n~~n~%d/8",RuraCD[playerid]);
			GameTextForPlayer(playerid,str,3000,3);
		}else if(RuraCD[playerid] == 3){
			SetPlayerRaceCheckpoint(playerid,3,3100.4736, -1518.8101, 700.3438,3100.4031, -1538.8583, 517.2215,2);
			MaRure[playerid] ++;
			RuraCD[playerid] ++;
			PlayerPlaySound(playerid, 1057, 0, 0, 0);
		
			format(str,sizeof(str),"~n~~n~~n~~n~~n~~n~~n~%d/8",RuraCD[playerid]);
			GameTextForPlayer(playerid,str,3000,3);
		}else if(RuraCD[playerid] == 4){
			SetPlayerRaceCheckpoint(playerid,3,3100.4031, -1538.8583, 517.2215,3104.9785, -1520.5675, 212.7438,2);
			MaRure[playerid] ++;
			RuraCD[playerid] ++;
			PlayerPlaySound(playerid, 1057, 0, 0, 0);
		
			format(str,sizeof(str),"~n~~n~~n~~n~~n~~n~~n~%d/8",RuraCD[playerid]);
			GameTextForPlayer(playerid,str,3000,3);
		}else if(RuraCD[playerid] == 5){
			SetPlayerRaceCheckpoint(playerid,3,3104.9785, -1520.5675, 212.7438,3105.5059, -1526.2288, 1.8939,2);
			MaRure[playerid] ++;
			RuraCD[playerid] ++;
			PlayerPlaySound(playerid, 1057, 0, 0, 0);
		
			format(str,sizeof(str),"~n~~n~~n~~n~~n~~n~~n~%d/8",RuraCD[playerid]);
			GameTextForPlayer(playerid,str,3000,3);
		}else if(RuraCD[playerid] == 6){
			SetPlayerRaceCheckpoint(playerid,4,3105.5059, -1526.2288, 1.8939,3105.5059, -1526.2288, 0.8939,2);
			MaRure[playerid] ++;
			RuraCD[playerid] ++;
			PlayerPlaySound(playerid, 1057, 0, 0, 0);
			
			format(str,sizeof(str),"~n~~n~~n~~n~~n~~n~~n~%d/8",RuraCD[playerid]);
			GameTextForPlayer(playerid,str,3000,3);
		}else if(RuraCD[playerid] == 7){

			if(MaRure[playerid] >= 7){
				GameTextForPlayer(playerid,"~w~EXP ~g~~h~+10", 2500, 3);
                ControlLevelUp(playerid);
				Respekt[playerid] += 10;
                PlayerPlaySound(playerid,1149,0.0,0.0,0.0);
				PlayerPlaySound(playerid, 1057, 0, 0, 0);
				WinSound(playerid);
			}
			MaRure[playerid] = 0;
			RuraCD[playerid] = 0;
			DisablePlayerRaceCheckpoint(playerid);
		}

		return 1;
	}

	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{

	/*new string[256];
	new ownplayer[MAX_PLAYER_NAME];

	switch(getCheckpointType(playerid))
	{

		case CP_WOJSKO: {
			SendClientMessage(playerid, COLOR_ORANGE, "Jesteœ w Wojsku!");
			SendClientMessage(playerid, COLOR_ORANGE, "Aby Kupiæ Bron Specjaln¹ wpisz /BronieS");
		}

		case CP_WIELKABAZA: {
			SendClientMessage(playerid, COLOR_RED2, "[-- Komendy Bazy Graczy nr.4 ---]");
			SendClientMessage(playerid, COLOR_LIST, "/wup  - winda jedzie w górê!");
			SendClientMessage(playerid, COLOR_LIST, "/wdown  - winda jedzie w dó³!");
			SendClientMessage(playerid, COLOR_LIST, "/baza4  - Teleport do bazy!");
			SendClientMessage(playerid, COLOR_LIST, "/baza4info - pokazuje t¹ liste komend w dowolnym miejscu");

		}

		case CP_BAZATDC: {
			SendClientMessage(playerid, COLOR_RED2, "[-- Komendy Bazy Graczy nr.2 ---]");
			SendClientMessage(playerid, COLOR_LIST, "/windaup - winda jedzie w górê");
			SendClientMessage(playerid, COLOR_LIST, "/windadown - winda jedzie w dó³");
			SendClientMessage(playerid, COLOR_LIST, "/klatkaopen - otwierasz klatkê");
			SendClientMessage(playerid, COLOR_LIST, "/klatkaclose - zamykasz klatkê");
			SendClientMessage(playerid, COLOR_LIST, "/baza2info - pokazuje t¹ liste komend w dowolnym miejscu");
			SendClientMessage(playerid, COLOR_LIST, "/baza2 - teleportujesz siê do Bazy");

		}
		case CP_BANK: {
		
			SendClientMessage(playerid, COLOR_RED2, "Jesteœ w Banku: Mo¿esz zrobiæ nastêpuj¹ce rzeczy!");
			SendClientMessage(playerid, COLOR_LIST, "/wplac [kwota] - wp³acasz pieni¹dze do banku");
			SendClientMessage(playerid, COLOR_LIST, "/wyplac [kwota] - pobierasz pieni¹dze z konta");
			SendClientMessage(playerid, COLOR_LIST, "/przelew [ID_gracza] [kwota] - przelewasz graczowi pieni¹dze na konto");
			SendClientMessage(playerid, COLOR_LIST, "/stan - sprawdzasz stan konta");
			SendClientMessage(playerid, COLOR_LIST, "/przelew [id_gracza] [kwota]- Przelewa graczowi pieni¹dze do banku");

			if(!logged[playerid])return SendClientMessage(playerid, COLOR_RED, "{FF732F}»»»{CC0000} Nie jesteœ zarejestrowany  /register aby siê zarejestrowaæ!");
			ShowPlayerDialog(playerid, GUI_BANK, 2, "{EAB171}Bank", "{AC3E00}Wp³aæ\n{EAB171}Wyp³aæ\n{AC3E00}Stan konta\n{EAB171}Przelew", "Wybierz", "Wyjdz");

		}
		case CP_PIRATE: {
			SendClientMessage(playerid, COLOR_YELLOW, "Przebywaj¹c na statku dostajesz pieni¹dze...");
		}
		case CP_AMMU: {
			SendClientMessage(playerid, COLOR_GREEN, "Kupuj¹c tutaj broñ bêdziesz j¹ mia³ nawet po œmierci!");
			SendClientMessage(playerid, COLOR_GREEN, "Aby kupiæ broñ wpisz:");
			SendClientMessage(playerid, COLOR_YELLOW, "/buyweapon [idbroni] - kupuje wybran¹ broñ ");
			SendClientMessage(playerid, COLOR_YELLOW, "/weapons - pokazuje bronie które mo¿na kupiæ ");
		}
		case CP_FORTECA: {
			SendClientMessage(playerid, COLOR_RED2, "Witaj w fortecy!");
			SendClientMessage(playerid, COLOR_LIST, "/Fopen - aby otworzyæ fortecê");
			SendClientMessage(playerid, COLOR_LIST, "/Fclose - aby zamkn¹æ fortecê");
		}
        
	}*/

	return 1;
}

//------------------------------------------------------------------------------------------------------

public OnPlayerRequestSpawn(playerid)
{
	if(!logged[playerid] && Registered[playerid]){

		SendClientMessage(playerid,COLOR_RED2,"Musisz siê najpierw zalogowaæ aby rozpocz¹æ grê na tym nicku!");
		ShowPlayerDialog(playerid, 7, DIALOG_STYLE_PASSWORD, "{FFFFFF}Panel Logowania", "{FFFF00}Witamy na FullGaming! [FREEROAM]\n{FFFFFF}Je¿eli widzisz ten komunikat poraz pierwszy oznacza to \n¿e inna osoba gra ju¿ na tym nicku i jest zarejestrowana.\n{FFFF00}Je¿eli jest to twoje konto wpisz has³o:", "Loguj", "Anuluj");

		return 0;
	}
	if(Player[playerid][First] == 1)
	{
		new string[200];
		if(joininfoadmin == 1){
			format(string, sizeof(string), "{a0a0a0} * {707070}%s (%d) {a0a0a0}wszed³ na serwer. IP: {707070}%s{a0a0a0}.",PlayerName(playerid),playerid,PlayerIP(playerid));
			UziSkill[playerid] = 999;
			SetPlayerSkillLevel(playerid,6,999);
			SOSkill[playerid] = 999;
			SetPlayerSkillLevel(playerid,4,999);
			SendClientMessageToAdmins(0xC0C0C0FF,string);
			SoundForAll(1056);
		}

		if(Player[playerid][Admin] == 1)
		{
			format(string, sizeof(string), "{a0a0a0} * {707070}Moderator %s (%d) {a0a0a0}wszed³ na serwer.",PlayerName(playerid),playerid);
			SendClientMessageToPlayers(-1,string);
		}
		else if(Player[playerid][Admin] == 2)
		{
			format(string, sizeof(string), "{a0a0a0} * {707070}Administrator rekrut %s (%d) {a0a0a0}wszed³ na serwer.",PlayerName(playerid),playerid);
			SendClientMessageToPlayers(-1,string);
		}
		else if(Player[playerid][Admin] == 3)
		{
			format(string, sizeof(string), "{a0a0a0} * {707070}Administrator %s (%d) {a0a0a0}wszed³ na serwer.",PlayerName(playerid),playerid);
			SendClientMessageToPlayers(-1,string);
		}
		else if(Player[playerid][Admin] == 4 || Player[playerid][Admin] == 5)
		{
			format(string, sizeof(string), "{a0a0a0} * {707070}Administrator RCON %s (%d) {a0a0a0}wszed³ na serwer.",PlayerName(playerid),playerid);
			SendClientMessageToPlayers(-1,string);
		}
		else if(IsVIP(playerid))
		{
			format(string, sizeof(string), "{a0a0a0} * {707070}VIP %s (%d) {a0a0a0}wszed³ na serwer.",PlayerName(playerid),playerid);
			SendClientMessageToPlayers(-1,string);
		}
		else
		{
			format(string, sizeof(string), "{a0a0a0} * {707070}Gracz %s (%d) {a0a0a0}wszed³ na serwer.",PlayerName(playerid),playerid);
			SendClientMessageToPlayers(-1,string);
		}
		Player[playerid][First]--;
		SoundForAll(1056);
		StopAudioStreamForPlayer(playerid);
		return 1;
	}
	
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerTime(playerid, 18, 0);
	Wybieralka[playerid] = true;
   	new str[128];
	format(str,sizeof str,"~n~~n~~n~~n~~n~~n~~n~~n~%d",GetPlayerSkin(playerid));
	GameTextForPlayer(playerid,str, 2500, 3);
	if(classid == 0) 
	{
		if(Player[playerid][Skin] > 1 && Player[playerid][Skin] < 299)
		{
			SetPlayerSkin(playerid,Player[playerid][Skin]);
			GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~n~Zapisany skin gracza", 2500, 3);
		}
	}

	SetPlayerPos(playerid, 711.0259,-1634.0861,3.4241);
	SetPlayerCameraPos(playerid, 705.9871,-1634.1145,4.5508);
	SetPlayerCameraLookAt(playerid, 711.0259+random(3-1),-1634.0861+random(3-1),3.4241, CAMERA_MOVE);
	
	new Float:angleclass = 90.0+classid;
	if(angleclass>=120.0) angleclass=90.0;
	SetPlayerFacingAngle(playerid, angleclass);//90.0+classid);	
	

	switch(random(5))
	{
		case 0: ApplyAnimation(playerid, "GYMNASIUM", "GYMshadowbox", 4.000000, 1, 1, 1, 1, 0); //Trening Boksu
		case 1: ApplyAnimation(playerid, "GYMNASIUM", "GYMshadowbox", 4.000000, 1, 1, 1, 1, 0); //Trening Boksu
		case 2: ApplyAnimation(playerid, "GYMNASIUM", "GYMshadowbox", 4.000000, 1, 1, 1, 1, 0); //Trening Boksu
		case 3: ApplyAnimation(playerid, "GYMNASIUM", "GYMshadowbox", 4.000000, 1, 1, 1, 1, 0); //Trening Boksu
		case 4: ApplyAnimation(playerid, "GYMNASIUM", "GYMshadowbox", 4.000000, 1, 1, 1, 1, 0); //Trening Boksu
	}

	return 1;
}

forward DomyCzynsz();
public DomyCzynsz()
{

	new str[128];
	for(new x=0;x<HOUSES_LOOP;x++){

		if(strlen(HouseInfo[x][hOwner]) < 3) continue;

		HouseInfo[x][hBudget] -= HouseInfo[x][hCost];
		if(HouseInfo[x][hBudget] < 0){

			HouseInfo[x][hBudget] = 0;
			HouseInfo[x][hOpen] = false;

			format(str,sizeof(str),"Dom na sprzeda¿\n%d Exp na dzieñ\nID: %d",HouseInfo[x][hCost], x);
			Update3DTextLabelText(HouseInfo[x][hLabel],0xFFB400FF, str);

			house_Update(x,2," ");
			house_Update(x,8,"0");

			new name[MAX_PLAYER_NAME];
			foreachPly (i) {

                RemovePlayerMapIcon(i, x);
				SetPlayerMapIcon(i, x, HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z], 31,0);
				GetPlayerName(i,name,sizeof(name));
				if(strfind(LoginNick[i],HouseInfo[x][hOwner],false)==0){
					MaDom[i] = false;
					HouseID[i] = -1;
					SendClientMessage(i,COLOR_RED2,"Zosta³eœ wyrzucony/a z domu z powodu nie p³acenia czynszu!");
					break;
				}
			}

			strdel(HouseInfo[x][hOwner],0,MAX_PLAYER_NAME);
			SetVehicleToRespawn(HouseInfo[x][hCarid]);

		}else{
			new budgetstr[12];
			valstr(budgetstr,HouseInfo[x][hBudget]);
			house_Update(x,8,budgetstr);
		}
	}


	return 1;
}


forward LoadHouses();
public LoadHouses()
{

	new tmp[256];
	new dest[256];

	new File:domy = fopen("/GoldMap/Domy.txt",io_read);
	while(fread(domy,tmp)){
	    HOUSES_LOOP ++;
	}
	fclose(domy);

	if(HOUSES_LOOP >= MAX_HOUSES){
		HOUSES_LOOP = MAX_HOUSES;
	}

	print("-----------------------------------");
	print("Trwa wczytywanie domow...");
	WriteLog("-----------------------------------");
	WriteLog("Trwa wczytywanie domow...");

    domy = fopen("/GoldMap/Domy.txt",io_read);
    new x = 0;
	while(fread(domy,tmp)){

		if(x >= HOUSES_LOOP) break;

		dest = dbstrtok(tmp,2);
		format(HouseInfo[x][hOwner],MAX_PLAYER_NAME,"%s",dest);

		dest = dbstrtok(tmp,7);
		HouseInfo[x][hCost] = strval(dest);

		dest = dbstrtok(tmp,3);
		sscanf (dest, "p<,>fff", HouseInfo[x][henter_x], HouseInfo[x][henter_y],HouseInfo[x][henter_z]);

		dest = dbstrtok(tmp,4);
		sscanf (dest, "p<,>fff", HouseInfo[x][hexit_x], HouseInfo[x][hexit_y],HouseInfo[x][hexit_z]);

		new Float:Cx,Float:Cy,Float:Cz,Float:Ca,Model;

		dest = dbstrtok(tmp,6);
		sscanf (dest, "p<,>ffff", Cx, Cy, Cz, Ca);

		dest = dbstrtok(tmp,5);
		Model = strval(dest);

		dest = dbstrtok(tmp,8);
		HouseInfo[x][hBudget] = strval(dest);

		dest = dbstrtok(tmp,9);
		HouseInfo[x][hInterior] = strval(dest);

		dest = dbstrtok(tmp,10);
		HouseInfo[x][hWorld] = strval(dest);

		HouseInfo[x][hCarid] = CreateVehicle(Model,Cx,Cy,Cz,Ca,-1,-1,600000);
		HouseInfo[x][hOpen] = false;

		if(strlen(HouseInfo[x][hOwner]) >= 3){
			format(tmp,sizeof(tmp),"Dom gracza: \n%s\nID: %d",HouseInfo[x][hOwner],x);
			HouseInfo[x][hLabel] = Create3DTextLabel(tmp, 0xFF8040FF, HouseInfo[x][henter_x], HouseInfo[x][henter_y], HouseInfo[x][henter_z]+0.75, 30.0, 0, 1);
            HouseInfo[x][hPick] = CreatePickup(1272,2,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
		}else{
			format(tmp,sizeof(tmp),"Dom na sprzeda¿\n%d Exp na dzieñ\nID: %d",HouseInfo[x][hCost],x);
			HouseInfo[x][hLabel] = Create3DTextLabel(tmp, 0xFFB400FF, HouseInfo[x][henter_x], HouseInfo[x][henter_y], HouseInfo[x][henter_z]+0.75, 30.0, 0, 1);
            HouseInfo[x][hPick] = CreatePickup(1273,2,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
		}

		printf("%d > %s",x,HouseInfo[x][hOwner]);
		WriteLogFormat("%d > %s",x,HouseInfo[x][hOwner]);
		x ++;

	}

	print("-----------------------------------");

	return 1;
}

public OnGameModeExit() {
	StatRefresh();
	mysql_close (MySQLcon);
	dmap_GameModeExit();
	return 1;
}

stock OnLineZerowanie()
{
	WriteLogFormat("TABELE `online` zerowanie Slotów: %d",GetMaxPlayers());  
	new Ticks;  
	Ticks = tickcount();   
	new query_online[3500] = "INSERT INTO`OnLine`(`samp_ID`) VALUES";  
	mysql_query("TRUNCATE TABLE `OnLine`");  
	for (new i; i != GetMaxPlayers(); i++){   
		format(query_online, sizeof query_online, "%s(%i),", query_online, i);  
	}  
	query_online[strlen(query_online) - 1] = EOS;  
	mysql_query(query_online);  
	WriteLogFormat("TABELE `online` wyzerowa³o w : %.4fs.", float(tickcount()-Ticks)/1000.0);
}

public OnGameModeInit()
{
	WriteLog("Trwa wlaczanie serwera!");
	//new tmp[256];
	dmap_GameModeInit();
    TimersInit();
    SetTeamCount(MAX_GRACZY+20);
	
	new tmp[64];
	new user[64];
	new database[64];
	new password[64];
	// new tmp2[64], user2[64], database2[64], password2[64];

		// DANE MYSQL LOGOWANIE SIe DO PHP MY ADMIN PHPMYADMIN SQL DATABASE BAZA DANYCH

	/*
		Baza na Pawno.PL:
			tmp = "192.166.219.226";
			user = "oreivo";
			database = "oreivo";
			password = "oskaritos";
		
		Baza na xaa.pl
			tmp = "i128.xaa.pl";
			user = "p282689_hesse";
			database = "p282689_fullgaming";
			password = "12qwerty";
	*/
	tmp = "localhost";
	user = "testowy";
	database = "test";
	password = "qwerty";
	
	/*tmp2 = "sql2.freesqldatabase.com";//"127.0.0.1";
	user2 = "sql26286";//"root";
	database2 = "sql26286";//"test";
	password2 = "vB3%kY6*";//"vertrigo";*/

	print("(MySQL): Na serwerze znajduje sie baza danych SQL!");
	print("\n========================================");
	printf("Host: %s",tmp);
	printf("User: %s",user);
	printf("Database: %s",database);
	printf("Password: %s",password);
	/*printf("Host zapasowy: %s", tmp2);
	printf("U¿ytkownik zapasowy: %s", user2);
	printf("Baza zapasowa: %s", database2);
	printf("Has³o (zapasowe): %s", password2);*/
	print("==========================================\n");
	
	new stan;
	MySQLcon = mysql_init ();
	stan = mysql_connect(tmp,user,password,database,MySQLcon,1);
	if(!stan)
	{
		print("(MySQL): Po³¹czenie z pierwsz¹ baz¹ MySQL nie powiod³o siê!\nPróba po³¹czenia z drug¹ baz¹...");
		SendRconCommand("hostname [FullGaming.PL] Brak ³¹cznoœci z baz¹ danych!");
		SendRconCommand("password fullgaming");
	}
	
	new string[256];
	mysql_query("SELECT `variable`, `value` FROM `config` WHERE `RCON` = 1");
	mysql_store_result();
	while(mysql_fetch_row(string, " ")){
		SendRconCommand(string);
		print(string);
		WriteLog(string);
	}
	mysql_free_result();

	//loadPrivVehicles();
	Streamer_TickRate(35);
	
	ShowPlayerMarkers(1);
	
	ShowNameTags(1);
	
	Streamer_VisibleItems(STREAMER_TYPE_OBJECT, 750);
	
	UsePlayerPedAnims();
	
	AllowInteriorWeapons(1);
	
	EnableStuntBonusForAll(0);
	
	OnLineZerowanie();
	
	ReactionTest();
	
	loadVehicles();
	
	loadPrivateVehicles();
	
	new fLoader[2];
   	LoadFromFile(file, fLoader[0], fLoader[1]);
	
	for (new i; i < MAX_GRACZY; i++) {
		HouseID[i] = -1;
		Bombus[i] = -1;
	}

	for (new i; i < MAX_GRACZY; i++) {
	    gSpectateID[i] = -1;
	}

	VisualTextDraw();
	Visual3DText();
	
	CreateMapIcons();
	
	for(new x=0;x<MAX_GANGS;x++)
	    GangInfo[x][gLeader] = -1;
 	
	CreateDynamicObject(18766,   238.87297000,139.59490900,1003.77380300,0.00000000,0.00000000,0.00000000,150,-1,-1,100); //DE
	CreateDynamicObject(18766,288.63357500,169.21549900,1007.60980200,0.00000000,0.00000000,0.00000000,150,-1,-1,100); //DE
	CreateDynamicObject(18765, 969.575988, 2163.261230, 1010.393310, 0.000000, 0.000000, 0.000000,153,-1,-1,100);//CHINASAWN
	
	for(new vw = 10000; vw != 10500; vw++)
		CreateDynamicObject(19272, -3007.419433, 131.482864, 7.786579, 0.000000, 0.000000, 0.000000,vw,-1,-1,150);//DUEL/SOLO
		
	for( new o; o != sizeof gRandomPlayerSpawns; o ++ )
	{
	    new
		Float:change = 2.5,
		model = 1239,
		type = 1;

		CreatePickup(model, type, gRandomPlayerSpawns[ o ][ 0 ]+change,gRandomPlayerSpawns[ o ][ 1 ],gRandomPlayerSpawns[ o ][ 2 ]);
		CreatePickup(model, type, gRandomPlayerSpawns[ o ][ 0 ]-change,gRandomPlayerSpawns[ o ][ 1 ],gRandomPlayerSpawns[ o ][ 2 ]);
		CreatePickup(model, type, gRandomPlayerSpawns[ o ][ 0 ],gRandomPlayerSpawns[ o ][ 1 ]+change,gRandomPlayerSpawns[ o ][ 2 ]);
		CreatePickup(model, type, gRandomPlayerSpawns[ o ][ 0 ],gRandomPlayerSpawns[ o ][ 1 ]-change,gRandomPlayerSpawns[ o ][ 2 ]);

		Create3DTextLabel("{28DC28}Administracja ¿yczy mi³ej zabawy :)",0x000000FF, gRandomPlayerSpawns[ o ][ 0 ]+change,gRandomPlayerSpawns[ o ][ 1 ],gRandomPlayerSpawns[ o ][ 2 ],35.0,0);
	    Create3DTextLabel("{FF0000}Nie znasz komend? Zapoznaj siê z /cmd",0x000000FF, gRandomPlayerSpawns[ o ][ 0 ]-change,gRandomPlayerSpawns[ o ][ 1 ],gRandomPlayerSpawns[ o ][ 2 ],35.0,0);
	    Create3DTextLabel("{FF9900}Nie wiesz o co chodzi? Wszystko jest opisane w /help",0x000000FF, gRandomPlayerSpawns[ o ][ 0 ],gRandomPlayerSpawns[ o ][ 1 ]+change,gRandomPlayerSpawns[ o ][ 2 ],35.0,0);
	    Create3DTextLabel("{0071FF}Witamy na FullGaming",0x000000FF, gRandomPlayerSpawns[ o ][ 0 ],gRandomPlayerSpawns[ o ][ 1 ]-change,gRandomPlayerSpawns[ o ][ 2 ],35.0,0);
	}

//-------------------------------------------------------------------------------------------------------------------------------------------------|

    PickupID[0] = CreatePickup(1274, 14, -1692.6345,-1895.6777,104.6306);
	PickupID[1] = CreatePickup(1274, 14, -1691.1769,-1895.6812,104.6306);
	PickupID[2] = CreatePickup(1274, 14, -1693.8132,-1895.7855,104.6306);

    DragZone = GangZoneCreate(617.0020, -1420.1302, 647.4794, -1339.6910);
    GangZoneShowForAll(DragZone,0x0261FA44);
	GangZoneFlashForAll(DragZone,0xC2C2C244);

	FortecaBrama = CreateObject(980, -1176.4272, -939.781, 124.9171, 0, 0, 90);
	TDCWinda = CreateObject(980, 2416.103027, 1156.031372, 9.855947, 89.3814, 0.0000, 270.0000);
    bramapd = CreateObject(972, 1598.68, -1641.32, 11.00,   0.00, 0.00, 90.00);
    rakieta = CreateObject(8131, 53.33, 1559.77, 22.00,   0.00, 0.00, 0.00);
    szlaban = CreateObject(974, 96.68, 1920.52, 19.00,   0.00, 0.00, 90.00);
 	TDCPick = CreatePickup(354,2,2372.256104, 1111.005371, 35.312813);
	WindaWB = CreateObject(5837, 1861.5742, 1371.254, 56.0905, 0.0, 0.0, 0.0);
    CreateObject(13607, -157.544403, -610.249146, 57.731945, 0.0000, 14.6104, 0.0000); //DB
 	CreatePickup(324, 2, 2518.654296875, -1666.9093017578, 14.365335464478, 0);
    CreatePickup(324, 2, 1574.4697265625, -1692.4304199219, 6.21875, 0);

    lift1 = CreateObject(974, 948.788574, 2439.683350, 9.874555, 90.2409, 0.0000, 0.0000);
    lift2 = CreateObject(974, 957.282593, 2432.806641, 42.432281, 90.2409, 0.0000, 0.0000);
    lift3 = CreateObject(974, 957.160950, 2442.099365, 81.161102, 90.2409, 0.0000, 0.0000);

	TDCKlatka = CreateObject(980, 2370.977783, 1108.294312, 35.956200, 0.0000, 0.0000, 157.5000);

    loteria = CreatePickup(1239, 2, -2147.4644,-424.3189,35.3359);
	loteriavip = CreatePickup(1239, 2, -2152.5469,-434.6609,35.3359);
 	BocianieGniazdo = CreatePickup(1318, 1, 2000.6077,1548.0173,13.5859);
    CPNEnter = CreatePickup(1318, 1, 661.3630,-573.4383,16.3359);
    CPNExit = CreatePickup(1318, 1, 1941.0302,2376.2964,23.8516);
    RestaEnter = CreatePickup(1318, 1, -179.7175,1087.4827,19.7422);
    RestaExit = CreatePickup(1318, 1, -794.9501,489.2800,1376.1953);
	BarEnter = CreatePickup(1318, 1, 681.6534,-473.3463,16.5363);
    BarExit = CreatePickup(1318, 1, 681.5109,-450.2535,-25.8203);
	ObokBazyEnter = CreatePickup(1318, 1, 1939.4501,2381.9612,10.8203);
    ObokBazyExit = CreatePickup(1318, 1, 662.6385,-573.3898,16.3359);
	Burdelik = CreatePickup(1314, 1, 2014.7905,1106.9966,10.8203);
    BurdelikExit = CreatePickup(1318, 1, 744.3810,1436.3389,1102.7031);
	BurdelikAction = CreatePickup(1314, 2, 740.8909,1434.9891,1102.7031);


	FivePickupOne = CreatePickup(1239, 2, 2678.4294,656.6891,10.8203);
	FivePickupTwo = CreatePickup(1239, 2, 2684.8232,641.1839,10.8203);
	FivePickupThree = CreatePickup(1239, 2, 2729.3865,663.6330,10.8678);
	FivePickupFour = CreatePickup(1239, 2, 2744.5356,670.0325,10.8984);

    WindaLVGora = CreatePickup(1239, 2,2179.8147,1030.4746,79.5703);
    WindaLVDol = CreatePickup(1239, 2, 2179.2903,1032.2856,10.8703);

 	FiveOne = CreateObject(3095, 2681.86, 644.39, 10.45,   0.00, 90.00, 0.00);
	FiveTwo = CreateObject(3095, 2681.87, 653.39, 10.45,   0.00, 90.00, 0.00);

    FiveOneTwo = CreateObject(3095, 2733.03, 665.64, 10.41,   0.00, 90.00, 90.00);
	FiveTwoTwo = CreateObject(3095, 2741.97, 665.65, 10.41,   0.00, 90.00, 90.00);


    MGangPickup = CreatePickup(1314, 1, 2165.8647,-1675.8043,15.0859);
    NGangPickup = CreatePickup(1314, 1, -2131.4045,-221.6496,35.3203);

    sflotw = CreatePickup(1318, 1, -1543.9745,-441.2479,6.0000);
    sflotd = CreatePickup(1318, 1, -1543.3138,-441.8797,6.1000);
	strefasniper2 = CreatePickup(1318, 1, 2092.5767,1015.7982,10.8203);
    strefasniper3 = CreatePickup(1318, 1, 2106.0784,1001.3774,45.6641);
	windamost = CreatePickup(1318, 1, -2662.2371,1587.1407,64.0699);
    strefasniper = CreatePickup(1318, 1, 2088.2832,1507.0862,10.8203);
    dowodzenie = CreatePickup(1318, 1, 27.1061,1824.8994,17.6406);
    dowodzeniewnetrze = CreatePickup(1318, 1, 214.3610,1829.2782,6.4141);
    PickupBasen = CreatePickup(1318, 1, 2177.6094,961.0953,10.8203);
    latarniaplaza = CreatePickup(1318, 1, 154.2368,-1946.6213,5.3894);
	infotrening = CreatePickup(1239, 1, 30.7894,1791.0179,17.6406);
	infobramapd1 = CreatePickup(1239, 2, 1591.8716,-1639.7703,13.2770);
    infobramapd2 = CreatePickup(1239, 2, 1594.3318,-1633.8633,13.5123);
	strazak = CreatePickup(1314, 2, -2026.9386,67.1318,28.6916);
    wojskowy = CreatePickup(1314, 2, 17.9362,1865.9121,19.9329);
    autokomis = CreatePickup(1314, 2, -1967.1989,291.7525,35.2572);
	bronieb = CreatePickup(1239, 2, 2009.5186,-25.0034,3.0000);
	grove = CreatePickup(1314, 2, 2502.0198,-1686.8647,13.5174);

 	WindaLV = CreateObject(5837, 2180.48, 1029.68, 11.30,   0.00, 0.00, 110.00);

	//BalonLV = CreateObject(19336, 2199.99, 921.36, 40.00,   0.00, 0.00, 0.00);

//-------------[ Wybiera³ka (Wszystkie skiny) ]-------------------------//

	AddPlayerClass(8,320.1322,1123.0422,1083.8828,181.3320,4,1,24,3000,29,3000);
	for(new i = 1; i < 300; i++)  if(i !=74) AddPlayerClass(i,320.1322,1123.0422,1083.8828,181.3320,4,1,24,3000,29,3000);
//	AddAllClass(320.1322,1123.0422,1083.8828,181.3320,4,1,24,3000,29,3000);

//---- miejsca do pickupów na kana³y

	CreateDynamicObject(12986, 2178.80, 909.46, 11.30,   0.00, 0.00, 90.00);
	CreateDynamicObject(12986, 997.18, 1071.71, 11.20,   0.00, 0.00, 90.00);
	CreateDynamicObject(12986, 1265.02, -1797.55, 13.70,   0.00, 0.00, 270.00);
	CreateDynamicObject(12986, -314.89, 1569.40, 76.00,   0.00, 0.00, -43.00);
	CreateDynamicObject(12986, -1977.61, 103.84, 28.10,   0.00, 0.00, 180.00);
	CreateDynamicObject(12986, -1980.74, 954.13, 45.90,   0.00, 0.00, 270.00);
	CreateDynamicObject(12986, -930.84, 2034.47, 61.30,   0.00, 0.00, -44.00);
	CreateDynamicObject(12986, 2223.43, -2674.77, 14.00,   0.00, 0.00, 0.00);
	CreateDynamicObject(12986, 2427.13, -1636.98, 13.90,   0.00, 0.00, 0.00);


    CreatePickup(346, 2, 2443.6606,-1978.1716,13.5469, 0); //Emmet Gun

 	AddStaticPickup(371, 15, 1710.3359,1614.3585,10.1191); //para
	AddStaticPickup(371, 15, 1964.4523,1917.0341,130.9375); //para
	AddStaticPickup(371, 15, 2055.7258,2395.8589,150.4766); //para
	AddStaticPickup(371, 15, 2265.0120,1672.3837,94.9219); //para
	AddStaticPickup(371, 15, 2265.9739,1623.4060,94.9219); //para
	AddStaticPickup(355, 2 ,1902.3596,2394.9758,27.0913);//7
	AddStaticPickup(355, 2 ,1932.1766,2413.7251,27.1092);//8
	AddStaticPickup(355, 2 ,1960.2399,2414.7898,27.1327);//9
	AddStaticPickup(353, 2 ,1939.3683,2414.6892,27.9829);//10
	AddStaticPickup(353, 2 ,1950.4786,2414.8025,27.9829);//11
	AddStaticPickup(353, 2 ,1955.1713,2414.4929,27.9829);//12
	AddStaticPickup(353, 2 ,1937.7759,2414.5823,27.9829);//13
	AddStaticPickup(351, 2 ,1954.9823,2445.1311,0.5776);//16
	AddStaticPickup(350, 2 ,1954.5398,2447.2690,0.5776);//17
	AddStaticPickup(333, 2 ,1952.0977,2447.1980,0.5776);//18
	AddStaticPickup(334, 2 ,1951.4250,2445.2771,0.5776);//19
	AddStaticPickup(351, 2 ,1945.2506,2445.3020,0.5776);//22
	AddStaticPickup(350, 2 ,1942.5996,2445.0254,0.5776);//23
	AddStaticPickup(333, 2 ,1942.1249,2447.4934,0.5776);//24
	AddStaticPickup(334, 2 ,1939.8148,2447.4695,0.5776);//25
	AddStaticPickup(363, 2 ,1948.8950,2445.6150,0.5776);//26
	AddStaticPickup(363, 2 ,1939.8373,2445.2981,0.5776);//27

	for(new v=0; v<MAX_VEHICLES; v++)
	{
		SetVehicleNumberPlate(v, "{000000}FullGaming");
	}

	UpdateAttractionTD();
	mysql_query("select count(*) from fg_Players");		
	mysql_store_result();
	users = mysql_fetch_int();
	mysql_free_result();
	
	//format (AdminPass,sizeof (AdminPass),"%s",GetServerData ("admin_pass"));
	registerr = strval (GetServerData ("register"));
	maxusers = strval (GetServerData ("maxusers"));
	joininfo = strval (GetServerData ("joininfo"));
	format (ServerTag,sizeof (ServerTag),"%s", GetServerData ("server_tag"));
	joininfoadmin = strval (GetServerData ("joininfoadmin"));

	rekordgraczy = strval (GetServerData ("mostonlineply"));
	joins = strval (GetServerData ("joincount"));
	globkills = strval (GetServerData ("killcount"));
	kicks = strval (GetServerData ("kickcount"));
	globdeaths = strval (GetServerData ("deathcount"));
	globsuicides = strval (GetServerData ("globsuicides"));
	bans = strval (GetServerData ("bancount"));
	
	Bombs = true;

	MaxPojazdow = CreateVehicle(411, 0, 0, 0, 0, 0, 0, 1000); DestroyVehicle(MaxPojazdow);
	printf("%d",MaxPojazdow);
	LoadHouses();
	return 1;
}


public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

forward Dragcd();
public Dragcd(){


	if (Count1 > 0){
		foreachPly (x) {
			if(PlayerToPoint(3.0,x,664.1330,-1392.5837,13.1778) ||
			PlayerToPoint(3.0,x,664.3258,-1397.8151,13.1221) ||
			PlayerToPoint(3.0,x,663.8873,-1402.8795,13.0817) ||
			PlayerToPoint(3.0,x,663.6431,-1408.2515,13.0918))
			{
				GameTextForPlayer(x,CountText[Count1-1], 2500, 6);
				PlayerPlaySound(x,1056,0,0,0);
			}
		}
		Count1--;
		SetTimer("Dragcd", 1000, 0);
	}
	else{
		foreachPly (x) {
			if(GetPlayerState(x) == PLAYER_STATE_DRIVER){
				if(PlayerToPoint(3.0,x,664.1330,-1392.5837,13.1778) ||
				PlayerToPoint(3.0,x,664.3258,-1397.8151,13.1221) ||
				PlayerToPoint(3.0,x,663.8873,-1402.8795,13.0817) ||
				PlayerToPoint(3.0,x,663.6431,-1408.2515,13.0918))
				{
					GameTextForPlayer(x,"~y~START", 2500, 3);
					PlayerPlaySound(x,1056,0,0,0);
					SetPlayerVirtualWorld(x,100);
					Drager[x] = true;
					DisablePlayerCheckpoint(x);
					DisablePlayerRaceCheckpoint(x);
					SetDragCheckpoints(x);
					TogglePlayerControllable(x,1);
					DragTick[x] = GetTickCount();
					new veh = GetPlayerVehicleID(x);
					SetVehicleVirtualWorld(veh,100);

				}
			}
		}
		Count1 = 3;
	}
	return 1;
}

forward CountDown();
public CountDown(){
	if (Count1 > 0){
		GameTextForAll( CountText[Count1-1], 2500, 3);
		Count1--;
		SoundForAll(1056);
		SetTimer("CountDown", 900, 0);
	}
	else{
		GameTextForAll("~y~START", 2500, 3);
		Count1 = 3;
		SoundForAll(1057);
	}
	return 1;
}


stock IsVehicleInUse(vehicleid)
{
	new bool:temp = false;
	foreachPly (i) {
		if(GetPlayerVehicleID(i) == vehicleid)
		{
			temp = true;
			break;
		}
	}

	return temp;
}


stock HexToString (hex)
{
	hex >>= 8;
	new divider=1048576, digit, idx, output[7];

	for (new i; i < 6; i++)
	{
		digit=hex/divider;
	 	hex -= digit * divider;
		divider /= 16;

		if (digit < 0)
			digit += 16;

		if (digit < 10)
			output [idx++] = '0' + digit;
		else
			output [idx++] = 'A' + digit - 10;
	}
	return output;
}

////////////// [ Funkcje Komend ZCMD ] /////////////////////////////////////
CMD:przyczep(playerid, params[])
	return ShowPlayerDialog(playerid, DIALOG_ZALOZ, DIALOG_STYLE_LIST, "Przedmioty", "Boombox\nMikolaj\nMlotek\nSrubokret\nSpoiler\nAfro\nGrabie\nKurczak\nTelefon\nCygaro\nKapelusz\nKatana\nPacholek\nRycerz\nSiano\nSwietlik\nTelefon\nTorba\nZolwik\nTarcza\nWedka\nZdejmij", "Anuluj", "Ok");

CMD:newhouse(playerid, cmdtext[])
{
	if(!IsAdmin(playerid,5)) return 0;
	ShowPlayerDialog(playerid, DIALOG_HOUSE1,DIALOG_STYLE_INPUT,"WprowadŸ ID Domu","Tutaj wpisz ID Domu:","OK","Anuluj");
	return 1;
}

CMD:dalej(playerid, cmdtext[])
{
	if(!IsAdmin(playerid,5)) return 0;
    if(OneHouse)
	{
		GetPlayerPos(playerid, HousePos[0], HousePos[1], HousePos[2]);
        SendClientMessage(playerid, COLOR_GREEN, "  * Teraz idŸ tam gdzie ma byæ wnêtrze domu i wpisz /Dalej2.");
		TwoHouse = true;
		OneHouse = false;
	}
	return 1;
}

CMD:dalej2(playerid, cmdtext[])
{
	if(!IsAdmin(playerid,5)) return 0;
	if(TwoHouse)
	{
 		GetPlayerPos(playerid, HousePosIn[0], HousePosIn[1], HousePosIn[2]);
		InteriorHouse = GetPlayerInterior(playerid);
		SendClientMessage(playerid, COLOR_GREEN, "  * Pozycja wnêtrza zapisana!");
        ShowPlayerDialog(playerid, DIALOG_HOUSE2,DIALOG_STYLE_INPUT,"Prywatny Pojazd","WprowadŸ ID prywatnego pojazdu:","OK","Anuluj");
	}
	return 1;
}

CMD:dalej3(playerid, cmdtext[])
{
	if(!IsAdmin(playerid,5)) return 0;
	if(ThriHouse)
	{
	    new vehicleid;
        vehicleid = GetPlayerVehicleID(playerid);
		GetVehiclePos(vehicleid, VehHousePos[0],VehHousePos[1],VehHousePos[2]);
		GetVehicleZAngle(vehicleid, z_rot);
        SendClientMessage(playerid, COLOR_GREEN, "  * Pozycja pojazdu zapisana!");
		SendClientMessage(playerid, COLOR_GREEN, "  * Teraz wpisz koszt domu co 1 godzinê.");
        ShowPlayerDialog(playerid, DIALOG_HOUSE3,DIALOG_STYLE_INPUT,"Koszt","WprowadŸ czynsz exp:","OK","Anuluj");
        ThriHouse = false;
	}
	return 1;
}





CMD:kolor(playerid, cmdtext[])
{
	if(Player[playerid][NGang])
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Jesteœ w gangu GoD. By go opuœciæ wpisz /gquit.");
		return 1;
	}

	if(Player[playerid][MGang])
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Jesteœ w gangu malinowych ziomków. By go opuœciæ wpisz /mquit.");
		return 1;
	}

	Player[playerid][Color] = SelectPlayerColor(random(100));
	SetPlayerColor(playerid, Player[playerid][Color]);
	SendClientMessage(playerid, COLOR_GREEN, "  * Zmieni³eœ(aœ) kolor!");
	return 1;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////FRAKCJE by Oreivo////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////

//---------------------------------OGÓLNE----------------------------------------------------------//
CMD:frakcje(playerid, cmdtext[]){

	new string[555];

	strcat(string,"{129357}Policja (/policjadolacz)\n");
	strcat(string,"{129357}Wojsko (/wojskodolacz\n");
	strcat(string,"{CCDB25}Pogotowie(/pogotowiedolacz\n");
    strcat(string,"{129357}Taxi(/taxidolacz)\n");


	ShowPlayerDialog(playerid,22,0,"Frakcje",string,"OK","OK");

	return 1;
	
}
CMD:policjadolacz(playerid, cmdtext[]){

    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s do³¹czy³ do policji wezwij go za pomoc¹ /wezwijpolicja", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
    SetPlayerSkin(playerid,267);
    CarTeleport(playerid,0,1552.155761,-1626.306030,13.382812);
	GameTextForPlayer(playerid,"~g~~h~DOLACZYLES DO POLICJI", 2500, 3);

	return 1;
	
}

CMD:wojskodolacz(playerid, cmdtext[]){
    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s do³¹czy³ do wojska aby go wezwaæ /wezwijwojsko", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
    SetPlayerSkin(playerid,258);
    CarTeleport(playerid,0,351.3806,1786.0936,17.9556);
	GameTextForPlayer(playerid,"~g~~h~DOLACZYLES DO WOJSKA", 2500, 3);

	return 1;
	
}

CMD:pogotowiedolacz(playerid, cmdtext[]){
    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s do³¹czy³ do pogotowia aby go wezwaæ /wezwijpogotowie", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
    SetPlayerSkin(playerid,274);
    CarTeleport(playerid,0,1184.192749,-1323.714477,13.575104);
	GameTextForPlayer(playerid,"~g~~h~DOLACZYLES DO POGOTOWIA", 2500, 3);

	return 1;
	
}
CMD:taxidolacz(playerid, cmdtext[]){
    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s do³¹czy³ do TAXI aby go wezwaæ /wezwijtaxi", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
    SetPlayerSkin(playerid,124);
    CarTeleport(playerid,0,1771.246215,-1856.266845,13.414062);
	GameTextForPlayer(playerid,"~g~~h~DOLACZYLES DO TAXI", 2500, 3);

	return 1;
	
}

CMD:wezwijpolicja(playerid, cmdtext[]){

    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s wzywa policje", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
	GameTextForPlayer(playerid,"~g~~h~Wezwales policje", 2500, 3);

	return 1;
	
}
CMD:wezwijwojsko(playerid, cmdtext[]){

    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s wzywa wojsko", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
	GameTextForPlayer(playerid,"~g~~h~Wezwales wojsko", 2500, 3);

	return 1;
	
}
CMD:wezwijpogotowie(playerid, cmdtext[]){

    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s wzywa pogotowie", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
	GameTextForPlayer(playerid,"~g~~h~Wezwales pogotowie", 2500, 3);

	return 1;
	
}
CMD:wezwijtaxi(playerid, cmdtext[]){

    new pName[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	format(string, 128, "Gracz %s wzywa policje", pName);
	SendClientMessageToAll(0xFFFFFFFF, string);
	GameTextForPlayer(playerid,"~g~~h~Wezwales Taxi", 2500, 3);

	return 1;
	
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
CMD:cheatsihuj2(playerid, cmdtext[])
{
	new str[200];
	strcat(str, "Przyszpieszenie\n");
	strcat(str, "Flip\n");
	strcat(str, "Zmiana Koloru\n");
	strcat(str, "Podskakiwanie\n");
    strcat(str, "Katapulta\n");
    strcat(str, "Niszcz Pojazd\n");
	strcat(str, "Wy³¹cz cheaty\n");
	ShowPlayerDialog(playerid, DIALOG_CHEATS, DIALOG_STYLE_LIST, "Rozrywkowe Legalne Cheaty", str, "Wybierz", "Anuluj");
	return 1;
}
*/


CMD:gang(playerid, cmdtext[]){

	ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");

	return 1;
}

CMD:gangdolacz(playerid, cmdtext[]){

	if(PlayerGangInfo[playerid][gID] != -1){
		ShowPlayerDialog(playerid,37,2,"Zarzadzanie Gangiem","Stworz Gang\nUsun Gang\nZapros Gracza\nWywal Gracza\nSpawn Gangu\nKolor Gangu\nDolacz do gangu\nOdejdz z gangu\nInfo o Gangu\nInfo o Gangach","Wybierz","Wyjdz");
		SendClientMessage(playerid,COLOR_RED2,"Masz ju¿ gang!");
		return 1;
	}
	new bool:first = true;
	new string[512];
	for(new x=0;x<MAX_GANGS;x++){
		if(PlayerGangInfo[playerid][gInvites][x]){
			if(first){
   				format(string,sizeof(string),"%s",GangInfo[x][gName]);
				first = false;
			}else{
				format(string,sizeof(string),"%s\n%s",string,GangInfo[x][gName]);
			}
		}
	}
	if(strlen(string) < 2){
		PlayerGangInfo[playerid][gDialog] = 0;
		ShowPlayerDialog(playerid,38,0,"Dolacz do Gangu","Brak zaproszen do gangu","OK","OK");

	}else{
		PlayerGangInfo[playerid][gDialog] = 4;
		ShowPlayerDialog(playerid,38,2,"Dolacz do Gangu",string,"Dolacz","Cofnij");

	}

	return 1;
}

CMD:ngang(playerid, cmdtext[])
{
	if(GetPlayerMoney(playerid) < 50000)
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Nie masz kasy, by wst¹piæ do gangu (50000$).");
		return 1;
	}

	if(Player[playerid][NGang])
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Jesteœ ju¿ w gangu niebieskich.");
		return 1;
	}

	if(Player[playerid][Gangster] != -1)
	{
		SendClientMessage(playerid, COLOR_ERROR, " * Jesteœ ju¿ w innym gangu!");
		return 1;
	}

	if(Player[playerid][MGang])
	    MGangQuit(playerid);

    new String[255];
	format(String, sizeof(String), "  * %s (id %d) do³¹czy³ do gangu niebieskich (/ngang).", PlayerName(playerid), playerid);
	SendClientMessageToAll(0x33CCFFFF, String);
	SetPlayerColor(playerid, 0x33CCFFFF);
    SetPlayerInterior(playerid,8);
	SetPlayerFacingAngle(playerid,2.2168);
	SetPlayerPos(playerid,2807.1050,-1171.4563,1025.5703);
	GivePlayerWeapon(playerid, 24, 100);
	GivePlayerWeapon(playerid, 34, 100);
	Player[playerid][NGang] = true;
	SendClientMessage(playerid, COLOR_NGANG, " * Do³¹czy³eœ do gangu niebieskich.");
	SendClientMessage(playerid, COLOR_NGANG, " * Komendy niebieskich znajdziesz pod /ncmd");

	return 1;
}

CMD:nquit(playerid, cmdtext[])
{
	if(!Player[playerid][NGang])
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Nie jesteœ w gangu niebieskich!");
		return 1;
	}

	NGangQuit(playerid);
    PlayerLabelOff(playerid);
	SendClientMessage(playerid, COLOR_NGANG, "  * Opuœci³eœ(aœ) gang niebieskich.");
	return 1;
}

CMD:nexit(playerid, cmdtext[])
{
	return cmd_nquit(playerid, cmdtext);
}
CMD:mgang(playerid, cmdtext[])
{
	if(GetPlayerMoney(playerid) < 2000)
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Nie masz kasy, by wst¹piæ do gangu (2000$).");
		return 1;
	}

	if(Player[playerid][MGang])
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Jesteœ ju¿ w gangu malinowych ziomków.");
		return 1;
	}

	if(Player[playerid][Gangster] != -1)
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Jesteœ ju¿ w  innym gangu!");
		return 1;
	}

	if(Player[playerid][NGang])
	    NGangQuit(playerid);

    new String[255];
	format(String, sizeof(String), "  * %s (id %d) do³¹czy³ do gangu malinowych ziomków (/mgang).", PlayerName(playerid), playerid);
	SendClientMessageToAll(COLOR_RASPBERRY, String);
	SetPlayerColor(playerid, COLOR_RASPBERRY);
    SetPlayerInterior(playerid,5);
	SetPlayerFacingAngle(playerid,237.1721);
	SetPlayerPos(playerid,316.6441,1122.1029,1083.8828);
	GivePlayerWeapon(playerid, 24, 100);
	GivePlayerWeapon(playerid, 34, 100);
	Player[playerid][MGang] = true;
	SendClientMessage(playerid, COLOR_RASPBERRY, "  * Do³¹czy³eœ do gangu maliny. Ziomków z Twojego gangu poznasz po malinowym kolorze.");
	SendClientMessage(playerid, COLOR_RASPBERRY, "  * Komendy malinowego gangu znajdziesz pod /mcmd");

	return 1;
}

CMD:mquit(playerid, cmdtext[])
{
	if(!Player[playerid][MGang])
	{
		SendClientMessage(playerid, COLOR_ERROR, "  * Nie jesteœ w gangu malinowych ziomków.");
		return 1;
	}

	MGangQuit(playerid);
    PlayerLabelOff(playerid);
	SendClientMessage(playerid, COLOR_RASPBERRY, "  * Opuœci³eœ(aœ) gang malinowych ziomków.");
	return 1;
}

CMD:mexit(playerid, cmdtext[])
{
	return cmd_mquit(playerid, cmdtext);
}

CMD:exphelp(playerid, cmdtext[]){
    new string[512];
	strcat(string,"Exp to inaczej experience, czyli doœwiaczenie.\n");
	strcat(string,"Im wiêkszy Exp tym wiêkszy level (na dole ekranu napisane jest ile exp potrzeba do kolejnego levelu).\n\n");
	strcat(string,"Level to inaczej poziom. Czym wiêkszy level tym lepsze bronie\n");
    strcat(string,"dostajesz na pocz¹tek, a od 8 levelu dostajesz kamizelkê. \n\n");
    strcat(string,"Za co dostaje siê Exp: \n\n");
	strcat(string,"+3 Exp za zabicie gracza\n");
	strcat(string,"-1 Exp za zginiêcie\n");
    strcat(string,"+100 Exp za pe³n¹ godzine gry OnLine\n");
    strcat(string,"Exp otrzymujesz równierz za zabawy i eventy\n");
    strcat(string,"Co 5 minut otrzymujesz 3 Exp\n");
	ShowPlayerDialog(playerid,DIALOG_NONE,0,"Informacje o Exp i Level",string,"OK","OK");
	return 1;
}

CMD:rsp(playerid, cmdtext[]){
	if(Freeze[playerid]) return 1;
	if(Floater[playerid])return SendClientMessage(playerid,COLOR_RED2," * Za szybko!");
	if(FloatDeath[playerid])return SendClientMessage(playerid,COLOR_RED2," * Nie mo¿na u¿ywaæ bezpoœrednio po œmierci!");
	if(IsPlayerInAnyVehicle(playerid))return SendClientMessage(playerid,COLOR_RED2," * Nie mo¿na u¿ywaæ w pojazdach!");
	if(floatround(GetPlayerFallSpeed(playerid)) > 3)return SendClientMessage(playerid,COLOR_RED2," * Nie mo¿na u¿ywaæ podczas spadania!");
	new Float:Angle;
	new Float:x,Float:y,Float:z;
	new Team,getskins;
	Floater[playerid] = true;
	GetPlayerFacingAngle(playerid, Angle);
	GetPlayerPos(playerid, x, y, z);
	inter = GetPlayerInterior(playerid);
	getskins = GetPlayerSkin(playerid);
	Team = GetPlayerTeam(playerid);
	RspWorld = GetPlayerVirtualWorld(playerid);
	GetPlayerWeaponData(playerid, 0, bron1, ammorsp);
	GetPlayerWeaponData(playerid, 1, bron2, ammo2);
	GetPlayerWeaponData(playerid, 2, bron3, ammo3);
	GetPlayerWeaponData(playerid, 3, bron4, ammo4);
	GetPlayerWeaponData(playerid, 4, bron5, ammo5);
	GetPlayerWeaponData(playerid, 5, bron6, ammo6);
	GetPlayerWeaponData(playerid, 6, bron7, ammo7);
	GetPlayerWeaponData(playerid, 7, bron8, ammo8);
	GetPlayerWeaponData(playerid, 8, bron9, ammo9);
	GetPlayerWeaponData(playerid, 9, bron10, ammo10);
	GetPlayerWeaponData(playerid, 10, bron11, ammo11);
	GetPlayerWeaponData(playerid, 11, bron12, ammo12);
	GetPlayerWeaponData(playerid, 12, bron13, ammo13);
	PlayerPlaySound(playerid, 1083,0,0,0);
	GetPlayerHealth(playerid, healthrsp);
	GetPlayerArmour(playerid, armourrsp);
	SetSpawnInfo(playerid,Team,getskins ,x,y,z-0.5,Angle,0,0,0,0,0,0);
	SpawnPlayer(playerid);
	return 1;
}
CMD:flo(playerid, cmdtext[]){
	return cmd_rsp(playerid,cmdtext);
}
CMD:stunt(playerid, cmdtext[]){
	return cmd_stuntcity(playerid,cmdtext);
}

CMD:moviemode(playerid, cmdtext[]){
    SendClientMessage(playerid, COLOR_GREEN, "Wszystkie TextDrawy wy³¹czone! Aby wróciæ wpisz /MovieOff");
	HidePlayerPasek(playerid);
	TextDrawHideForPlayer(playerid, Czas);
	TextDrawHideForPlayer(playerid, tabelka_zapisow_box);
	TextDrawHideForPlayer(playerid, tabelka_zapisow_label[0]);
	TextDrawHideForPlayer(playerid, tabelka_zapisow_label[1]);
	
	PlayerTextDrawHide(playerid, playerTd_carname[playerid]);
	PlayerTextDrawHide(playerid, playerTd_carspeed[playerid]);
	PlayerTextDrawHide(playerid, playerTd_carhealth[playerid]);
	TextDrawHideForPlayer(playerid, car_box);
	
	CarInfoChce[playerid] = false;
	ChceAnn[playerid] = false;
	VoteChce[playerid] = false;
	if(VoteON){
		TextDrawHideForPlayer(playerid,Glosowanie);
	}
	
	return 1;
}
CMD:movieoff(playerid, cmdtext[])
{
	SendClientMessage(playerid, COLOR_GREEN, "Wszystkie TextDrawy w³¹czone!");
	ShowPlayerPasek(playerid);
	TextDrawShowForPlayer(playerid, Czas);
	TextDrawShowForPlayer(playerid, tabelka_zapisow_box);
	TextDrawShowForPlayer(playerid, tabelka_zapisow_label[0]);
	TextDrawShowForPlayer(playerid, tabelka_zapisow_label[1]);

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		PlayerTextDrawShow(playerid, playerTd_carname[playerid]);
		PlayerTextDrawShow(playerid, playerTd_carspeed[playerid]);
		PlayerTextDrawShow(playerid, playerTd_carhealth[playerid]);
		TextDrawShowForPlayer(playerid, car_box);
	}
	CarInfoChce[playerid] = true;
	ChceAnn[playerid] = true;
	VoteChce[playerid] = true;
	if(VoteON){
		TextDrawShowForPlayer(playerid, Glosowanie);
	}
	return 1;
}


CMD:soloexit(playerid, cmdtext[]){

	if(SoloPlayer[0] == playerid || SoloPlayer[1] == playerid){

		new string2[100];
		if(SoloPlayer[0] == playerid){

			foreachPly (x) {
				if(PlayerToPoint(100,x,1939.2324,-2499.2456,43.5088)){
					format(string2,sizeof(string2),"Solo wygrywa: ~r~%s~n~~w~(przeciwnik zrezygnowal)",PlayerName(SoloPlayer[1]));
                    SoundForAll(1150);
					AnnForPlayer(x,5000,string2);
				}
			}
			SoloEnd(-1);
		}else if(SoloPlayer[1] == playerid){

			foreachPly (x) {
				if(PlayerToPoint(100,x,1939.2324,-2499.2456,43.5088)){
					format(string2,sizeof(string2),"Solo wygrywa: ~r~%s~n~~w~(przeciwnik zrezygnowal)",PlayerName(SoloPlayer[0]));
                    SoundForAll(1150);
					AnnForPlayer(x,5000,string2);
				}
			}
			SoloEnd(-1);
		}


	}else{
		SendClientMessage(playerid,COLOR_RED2,"Nie uczestniczysz w solowce!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}

	return 1;
	
}

CMD:soloend(playerid, cmdtext[]){

	if(!IsAdmin(playerid,2)) return 0;

	foreachPly (x) {
		if(PlayerToPoint(100,x,1963.0099,-2503.1980,43.5088)){
			SendClientMessage(x,COLOR_RED2,"(solo) Admin zakoñczy³ rozgrywkê na solo!");
            SoundForAll(1150);
		}
	}

	SoloEnd(-1);

	return 1;
	
	#pragma unused playerid
}

CMD:arenasolo(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1966.0569,-2497.5547,43.5088);

	SendClientMessage(playerid,COLOR_RED2,"Aby kogoœ wyzwaæ na solo wpisz /SoloWyzwij");
	return 1;
}

CMD:solowyzwij(playerid, cmdtext[]){

	if(!PlayerToPoint(100,playerid,1939.2324,-2499.2456,43.5088)){
		SendClientMessage(playerid, COLOR_WHITE, "Nie jesteœ na arenie solowek (/ArenaSolo)!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	if(SoloON){
		SendClientMessage(playerid,COLOR_RED2,"Ju¿ trwa jakaœ solowka!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	new gracz,bron;
	if(sscanf(cmdtext,"ud",gracz,bron)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /SoloWyzwij [ID_gracza] [ID_broni]");
		return 1;
	}

	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, " * Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	if(gracz == playerid){
		SendClientMessage(playerid, COLOR_WHITE, "Nie mo¿esz sam siebie wyzwaæ na solo!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	if(bron < 0 || bron > 46){
		SendClientMessage(playerid, COLOR_WHITE, "Wybierz broñ o id  (0-46)");
		return 1;
	}

	if(!PlayerToPoint(100,gracz,1939.2324,-2499.2456,43.5088)){
		SendClientMessage(playerid, COLOR_WHITE, "Ten gracz nie jest na arenie solowek!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	new bool:Moze = true;
	for(new b=0; b<sizeof(Abronie); b++){
		if(Abronie[b]==bron){
			SendClientMessage(playerid,COLOR_RED2," * Ta broñ jest niedozwolona!");
            PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
			Moze = false;
			break;
		}
	}

	if(!Moze) return 1;

	SoloWyzywa[gracz] = playerid;
	SoloBron[playerid] = bron;

	if(Player[gracz][RconAkcja] == 1)return SendClientMessage(playerid, COLOR_GREEN, " * W tej chwili nie mo¿na wyzwaæ tego gracza.");

	new tmp[128];
	format(tmp,sizeof(tmp),"Gracz: %s wyzywa cie na solowke! (%s)\n\nAkceptujesz jego wyzwanie?",PlayerName(playerid),ReturnWeaponName(bron));
	ShowPlayerDialog(gracz,24,0,"Arena Solowek",tmp,"Tak","Nie");

	format(tmp, sizeof(tmp), "Wyzwa³eœ(aœ) gracza %s na solowke broni¹ %s", PlayerName(gracz),ReturnWeaponName(bron));
	SendClientMessage(playerid,COLOR_GREEN, tmp);

	return 1;
}

CMD:fix(playerid, cmdtext[])
{
	RepairVehicle(GetPlayerVehicleID(playerid));
	SendClientMessage(playerid,COLOR_GREEN," * Naprawi³eœ(aœ) swój pojazd ! Szybsza naprawa klawisz 2");
	return 1;
}

CMD:nos(playerid, cmdtext[])
{
	AddVehicleComponent(GetPlayerVehicleID(playerid),1010);//NOS
	SendClientMessage(playerid,COLOR_GREEN," * Doda³eœ(aœ) sobie nitro !");
	return 1;
}

CMD:tutorial(playerid, cmdtext[])
{
	PlayerTut[playerid] = true;
	Tutor(playerid);
	return 1;
}

CMD:tutend(playerid, cmdtext[])
{
	if(PlayerTut[playerid])
	{
	    SetCameraBehindPlayer(playerid);
	    TogglePlayerControllable(playerid,1);
	    SetPlayerRandomSpawn(playerid);
	    for(new x=0;x<13;x++)
		{
	        TextDrawHideForPlayer(playerid,Tut[x]);
	    }
	}
	PlayerTut[playerid] = false;
	return 1;
}


CMD:nitro(playerid, cmdtext[])
{
	return cmd_nos(playerid, cmdtext);
}

CMD:help(playerid, cmdtext[])
{
	ShowPlayerDialog(playerid,30,2,"-=| FullGaming |=-  POMOC","CMD> Gracz \nCMD> VIP\nCMD> Admin \nCMD> Konto \nCMD> Dom \nCMD> Gang \nCMD> Respekt \nCMD> Animacje \nCMD> Teleporty \nCMD> Atrakcje \nPANEL> Gangi\nPANEL> TextDrawy\nINFO> Regulamin\nINFO> Respekt\nINFO> Gwiazdki\nINFO> Konto VIP\nINFO> Nowosci\nINFO> Autor","Dalej","Wyjdz");
	return 1;
}

CMD:kamizelka(playerid, cmdtext[])
{
	return cmd_armour(playerid,cmdtext);
}

CMD:spadochron(playerid, cmdtext[])
{
	return cmd_parachute(playerid,cmdtext);
}

CMD:c4(playerid, cmdtext[])
{
	return cmd_podloz(playerid,cmdtext);
}

CMD:n(playerid, cmdtext[])
{
	return cmd_napraw(playerid,cmdtext);
}

CMD:pomoc(playerid, cmdtext[])
{
	cmd_help(playerid,cmdtext);
	return 1;
}

CMD:rozrywka(playerid, cmdtext[])
{
	cmd_atrakcje(playerid,cmdtext);
	return 1;
}

CMD:kasa(playerid, cmdtext[])
{
	cmd_dotacja(playerid,cmdtext);
	return 1;
}

CMD:b(playerid, cmdtext[])
{
	cmd_ban(playerid,cmdtext);
	return 1;
}

CMD:k(playerid, cmdtext[])
{
	cmd_kick(playerid,cmdtext);
	return 1;
}

CMD:cmd(playerid, cmdtext[])
{
	cmd_komendy(playerid,cmdtext);
	return 1;
}

CMD:tokyodrift(playerid, cmdtext[])
{
	cmd_tokiodrift(playerid,cmdtext);
	return 1;
}

CMD:commands(playerid, cmdtext[])
{
	cmd_komendy(playerid,cmdtext);
	return 1;
}

CMD:komendy(playerid, cmdtext[])
{
   	new StrinG[2400];
	StrinG = "{717C89}/CarDive {FFFFFF}- wystrzeliwujesz w gore pojazd i spadasz\n";
	strcat(StrinG,"{717C89}/100hp {FFFFFF}- uleczasz sie\n");
	strcat(StrinG,"{717C89}/BuyWeapon [ID] [Ammo] {FFFFFF}- Kupujesz broñ na spawn\n");
	strcat(StrinG,"{717C89}/CB {FFFFFF}- CB-Radio w pojeŸdzie!\n");
    strcat(StrinG,"{FF0000}/Cars {FFFFFF}- Pojazdy do spawnu\n");
	strcat(StrinG,"{717C89}/CCB {FFFFFF}- Wybór kana³u do CB-Radia!\n");
	strcat(StrinG,"{717C89}/Armour {FFFFFF}- dostajesz kamizelkê kuloodporn¹\n");
    strcat(StrinG,"{717C89}/Lotto {FFFFFF}- Losowanie lotto\n");
	strcat(StrinG,"{717C89}/Dotacja {FFFFFF}- dostajesz kasê\n");
	strcat(StrinG,"{717C89}/Pojazdy {FFFFFF}- lista pojazdow do kupienia\n");
	strcat(StrinG,"{717C89}/Posiadlosci /Posiadlosci2 {FFFFFF}- pokazuje liste i wlascicieli biznesow\n");
	strcat(StrinG,"{717C89}/NRG {FFFFFF}- dostajesz motor NRG-500\n");
	strcat(StrinG,"{717C89}/Kill {FFFFFF}- popelniasz samobojstwo\n");
	strcat(StrinG,"{717C89}/Tune {FFFFFF}- tuningujesz swój pojazd\n");
	strcat(StrinG,"{717C89}/TuneMenu {FFFFFF}- otwiera menu z opcjami tuningu pojazdu\n");
	strcat(StrinG,"{717C89}/Flip {FFFFFF}- stawiasz swój pojazd na kola\n");
	strcat(StrinG,"{717C89}/NOS {FFFFFF}- wstawiasz do pojazdu nitro\n");
	strcat(StrinG,"{717C89}/ZW /JJ /Siema /Nara /Witam /Pa {FFFFFF}- wiadomo o co chodzi...\n");
	strcat(StrinG,"{717C89}/Napraw {FFFFFF}- naprawiasz swój pojazd\n");
	strcat(StrinG,"{717C89}/SavePos {FFFFFF}- ustawiasz chwilowy teleport dla wszystkich\n");
	strcat(StrinG,"{717C89}/TelPos {FFFFFF}- teleportujesz sie do chwilowego teleportu\n");
	strcat(StrinG,"{717C89}/SP {FFFFFF}- zapisujesz swój prywatny teleport\n");
	strcat(StrinG,"{717C89}/LP {FFFFFF}- teleportujesz sie to swojego teleportu\n");
	strcat(StrinG,"{717C89}/Raport [ID_gracza] [powod] {FFFFFF}- wysylasz raport adminowi na gracza \n");
	strcat(StrinG,"{717C89}/Odlicz {FFFFFF}- wlaczasz odliczanie\n");
	strcat(StrinG,"{717C89}/StylWalki {FFFFFF}- wybierasz swój styl walki\n");
	strcat(StrinG,"{717C89}/Rozbroj {FFFFFF}- rozbrajasz siebie\n");
	strcat(StrinG,"{717C89}/RespektHelp {FFFFFF}- informacja co to jest respekt\n");
	strcat(StrinG,"{717C89}/VipInfo {FFFFFF}- poznaj mo¿liwoœæi vipa\n ");
	strcat(StrinG,"{717C89}/ModInfo {FFFFFF}- sprawdzasz mo¿liwoœæi moderatora\n");
	strcat(StrinG,"{717C89}/Autor {FFFFFF}- pokazuje autora tego gamemoda\n");
	strcat(StrinG,"{717C89}/Skin [id] {FFFFFF}- zmieniasz sobie skina podajac jego ID\n");
	strcat(StrinG,"{FF0000}/Komendy2 {FFFFFF}- Dalsza lista komend...");

	ShowPlayerDialog(playerid,DIALOG_UNKNOWN_COMMAND,0,"Komendy na serwerze",StrinG,"DALEJ","OK");
	return 1;
}

CMD:gangi(playerid, cmdtext[])
{
   	new StrinG[500];
	StrinG = "{717C89}/MGang {FFFFFF}- Gang malinowych ziomków\n";
	strcat(StrinG,"{FF2263}/NGang {FFFFFF}- Gang niebieskich\n");
	strcat(StrinG,"Aby za³o¿yæ w³asny gang wpisz tylko {FFFFFF}/gang");
	ShowPlayerDialog(playerid,1054,0,"Gangi",StrinG,"OK","OK");
	return 1;
}

CMD:mcmd(playerid, cmdtext[])
{
	if(Player[playerid][MGang])
	{
		new StrinG[2400];
		StrinG = "{FF2263}/mBaza {FFFFFF}- Teleport do siedziby gangu maliny.\n";
		strcat(StrinG,"{FF2263}/mQuit {FFFFFF}- Opuszczenie gangu.\n");
		strcat(StrinG,"{FF2263}! [tekst] {FFFFFF}- Napisz '!' [tekst] i rozmawiaj z gangiem!");
            
		ShowPlayerDialog(playerid,1054,0,"Komendy Maliny",StrinG,"OK","OK");
	} else return SendClientMessage(playerid, COLOR_RED2,"Nie jesteœ cz³onkiem gangu maliny!");
	return 1;
}

CMD:ncmd(playerid, cmdtext[])
{
	if(Player[playerid][NGang])
	{
		new StrinG[2400];
		StrinG = "{717C89}/nBaza {FFFFFF}- Teleport do siedziby gangu GoD.\n";
		strcat(StrinG,"{717C89}/nQuit {FFFFFF}- Opuszczenie gangu.\n");
		strcat(StrinG,"{717C89}! [tekst] {FFFFFF}- Napisz '!' [tekst] i rozmawiaj z gangiem!");

		ShowPlayerDialog(playerid,1054,0,"Komendy GoD",StrinG,"OK","OK");
	} else return SendClientMessage(playerid, COLOR_RED2,"Nie jesteœ cz³onkiem gangu GoD!");
	return 1;
}

CMD:komendy2(playerid, cmdtext[])
{
	
	new StrinG[2400];
	StrinG = "{717C89}/KolorAuto {FFFFFF}- zmieniasz sobie losowo kolor pojazdu\n";
	strcat(StrinG,"{717C89}/HUD {FFFFFF}- Zmieniasz kolor szaty graficznej.\n");
	strcat(StrinG,"{717C89}/Randka [ID] - Idziesz na randkê\n");
	strcat(StrinG,"{717C89}/TDPanel - Panel Text Draw'ów\n");
	strcat(StrinG,"{717C89}/Losowanie {FFFFFF}- moze cos wygrasz...\n");
	strcat(StrinG,"{717C89}/Staty {FFFFFF}- panel roznych statystyk i TOP-list\n");
	strcat(StrinG,"{717C89}/Podloz {FFFFFF}- podkladasz bombe \n");
	strcat(StrinG,"{717C89}/GiveCash [ID_gracza] [kwota] {FFFFFF}- dajesz graczowi podana ilosc pieniedzy\n");
	strcat(StrinG,"{717C89}/Hitman [ID_gracza] [kwota] {FFFFFF}- wyznaczasz nagrode za zabicie gracza\n");
	strcat(StrinG,"{717C89}/Bounty [ID_gracza] {FFFFFF}- sprawdzasz nagrode jaka jest za zabicie gracza\n");
	strcat(StrinG,"{717C89}/Kup {FFFFFF}- kupujesz wybran¹ posiad³oœæ\n");
	strcat(StrinG,"{717C89}/KupDom {FFFFFF}- kupujesz wybrany dom\n");
	strcat(StrinG,"{717C89}/Admins {FFFFFF}- pokazuje obecnych administratorow\n");
	strcat(StrinG,"{717C89}/Vips {FFFFFF}- pokazuje obecnych Vipow\n");
	strcat(StrinG,"{717C89}/Mods {FFFFFF}- lista moderatorow\n");
	strcat(StrinG,"{717C89}/Fopen {FFFFFF}- otwierasz fortece (Farma na wsi) \n");
	strcat(StrinG,"{717C89}/Fclose {FFFFFF}- zamykasz fotrece (Farma na wsi)\n");
	strcat(StrinG,"{717C89}/Bronie {FFFFFF}- lista broni do kupienia\n");
	strcat(StrinG,"{717C89}/PM [ID_gracza] [tekst] {FFFFFF}- wysylasz prywatna wiadomosc do gracza\n");
	strcat(StrinG,"{717C89}/BuyWeapon [ID_broni] {FFFFFF}- kupujesz bron na stale (Ammunation)\n");
	strcat(StrinG,"{717C89}/DelWeapons {FFFFFF}- usuwasz swoje stale bronie\n");
	strcat(StrinG,"{717C89}/Weapons {FFFFFF}- lista broni do kupienia na stale\n");
	strcat(StrinG,"{717C89}/Lock {FFFFFF}- zamykasz pojazd\n");
	strcat(StrinG,"{717C89}/UnLock {FFFFFF}- otwierasz pojazd\n");
	strcat(StrinG,"{717C89}/Odleglosc [ID_gracza] {FFFFFF}- pojazuje odleglosc od gracza\n");
	strcat(StrinG,"{717C89}/Skok [500-20000] {FFFFFF}- wykonujesz skok spadochronowy z okreslonej wysokosci\n");
	
	ShowPlayerDialog(playerid,1054,0,"Komendy na serwerze",StrinG,"OK","OK");
	
	return 1;
}

CMD:atrakcje(playerid, cmdtext[])
{
	
	new StrinG[2400];
	StrinG = "{717C89}/MiniPort {FFFFFF}- Ma³e doki portowe z statkiem i skrytk¹\n";
	strcat(StrinG,"{FF0000}/Wieza {FFFFFF}- Wie¿a Eiffla.\n");
	strcat(StrinG,"{FF0000}/JetArena {FFFFFF}- Arena Jetpack\n");
	strcat(StrinG,"{FF0000}/AmfiTeatr {FFFFFF}- Atrakcyjny Amfi Teatr\n");
	strcat(StrinG,"{FF0000}/nBronie {FFFFFF}- Nowe modele broni\n");
	strcat(StrinG,"{717C89}/Lowisko {FFFFFF}- Chcesz lowic ryby? Wejdz tutaj!\n");
	strcat(StrinG,"{717C89}/ArenaDD {FFFFFF}- Demolotion Derby!\n");
	strcat(StrinG,"{717C89}/mGang {FFFFFF}- Gang malinowych ziomków!\n");
	strcat(StrinG,"{717C89}/nGang {FFFFFF}- Gang niebieskich\n");
	strcat(StrinG,"{717C89}/WaterLand {FFFFFF}- Wodny Park dla samochodów\n");
	strcat(StrinG,"{717C89}/Park {FFFFFF}- Park wypoczynkowy z ma³ym basenem i dodatkami...\n");
	strcat(StrinG,"{717C89}/Lotto {FFFFFF}- Losowanie lotto\n");
	strcat(StrinG,"{717C89}/Skocznia {FFFFFF}- Skocznia narciarska dla pojazdów\n");
	strcat(StrinG,"{717C89}/CityDrift {FFFFFF}- Tor wyœcigowo driftowy dla pojazdów\n");
	strcat(StrinG,"{717C89}/Tor {FFFFFF}- Tor wyœcigowy\n");
	strcat(StrinG,"{717C89}/Wjazd {FFFFFF}- Drewniany œwiat wjazdów\n");
	strcat(StrinG,"{717C89}/Skok2-9 {FFFFFF}- Skok spadochronowy z du¿ej odleg³oœci\n");
	strcat(StrinG,"{717C89}/Warsztat {FFFFFF}- Warsztat samochodowy\n");
	strcat(StrinG,"{717C89}/Warsztat2 {FFFFFF}- Warsztat samochodowy lvlot\n");
	strcat(StrinG,"{717C89}/Wyskok {FFFFFF}- Wyskok dla pojazdów\n");
	strcat(StrinG,"{717C89}/Zjazd {FFFFFF}- Zjazd samochodem z ogromnej wysokoœci\n");
	strcat(StrinG,"{717C89}/Zjazd2 {FFFFFF}- Zjazd samochodem z bardzo ogromnej wysokoœci\n");
	strcat(StrinG,"{717C89}/Kart {FFFFFF}- Tor gokartowy na Pla¿y w LS\n");
	strcat(StrinG,"{717C89}/Rury {FFFFFF}- Dynamiczne 3D Rury\n");
	strcat(StrinG,"{717C89}/Stunt {FFFFFF}- Park wyczynowy dla zawodowców\n");
	strcat(StrinG,"{717C89}/Afganistan {FFFFFF}- Wojsko Afganistañskie\n");
	strcat(StrinG,"{717C89}/Wietnam {FFFFFF}- Wietnam wojskowy\n");
	strcat(StrinG,"{717C89}/Minigun {FFFFFF}- Arena minigunowa \n");
	strcat(StrinG,"{717C89}/RPG {FFFFFF}- Arena RPG\n");
	strcat(StrinG,"{717C89}/Arena {FFFFFF}- Arena walk w ciekawym otoczeniu\n");
	strcat(StrinG,"{717C89}/DD {FFFFFF}- Arena Destruction Derby\n");
	strcat(StrinG,"{717C89}/KSS {FFFFFF}- Zawodowy stunt Vice-Stadium\n");
	strcat(StrinG,"{717C89}/Liberty {FFFFFF}- Liberty City w GTA SA\n ");
	strcat(StrinG,"{717C89}/G1-5 {FFFFFF}- Parkingi samochodowe\n");
	strcat(StrinG,"{717C89}/Forteca {FFFFFF}- Forteca ufortyfikowana otwierana od wewn¹trz\n");
	strcat(StrinG,"{717C89}/Baza1-5 {FFFFFF}- Ufortyfikowane bazy graczy z wieloma mo¿liwoœciami\n");
	strcat(StrinG,"{717C89}/Atrakcje2 {FFFFFF}- Tutaj znajdziesz dalsz¹ listê atrakcji serwera");
	
	ShowPlayerDialog(playerid,DIALOG_ATRAKCJE,0,"{717C89}Atrakcje",StrinG,"Dalej","OK");
	
	return 1;
}

CMD:atrakcje2(playerid, cmdtext[])
{
	
	new StrinG[2400];
	StrinG = "{717C89}/Willa {FFFFFF}- Ogromna Willa Madd Dogga\n";
	strcat(StrinG,"{717C89}/Drift1-5 {FFFFFF}- Tory wyczynowe do driftingu\n");
	strcat(StrinG,"{717C89}/ArenaSolo {FFFFFF}- Walki 1 vs 1 na Ciekawej Arenie za nagrodê\n");
	strcat(StrinG,"{717C89}/Solo1-5 {FFFFFF}- Tutaj odbywaj¹ siê solówki graczy\n");
	strcat(StrinG,"{717C89}/Port {FFFFFF}- Doki portowe w Los Santos\n");
	strcat(StrinG,"{717C89}/Bagno {FFFFFF}- Ciekawe otoczenie obiektów na bagnie SF-LS\n");
	strcat(StrinG,"{717C89}/Statek {FFFFFF}- Atrakcyjny statek w LV z bocianim gniazdem itp\n");
	strcat(StrinG,"{717C89}/Impra {FFFFFF}- Impreza dyskotekowa\n");
	strcat(StrinG,"{717C89}/Gora {FFFFFF}- Ogromna Góra Chilliad w ciekawym otoczeniu obiektów\n");
	strcat(StrinG,"{717C89}/Miasteczko {FFFFFF}- Ma³e miasteczko\n");
	strcat(StrinG,"{717C89}/ME {FFFFFF}- Piszesz na czacie (me)\n");
	strcat(StrinG,"{717C89}/Piramida {FFFFFF}- Piramida w LV z wjazdem na 3D rury\n");
	strcat(StrinG,"{717C89}/Tereno2 {FFFFFF}- Jazda w Technicznym Terenie.\n");
	strcat(StrinG,"{717C89}/Pustynia {FFFFFF}- Pustynia na starym lotnisku LV\n");
	strcat(StrinG,"{717C89}/WG {FFFFFF}- Wojna Gangów \n");
	strcat(StrinG,"{717C89}/CF {FFFFFF}- Capture The Flag - Walka o Flagê\n");
	strcat(StrinG,"{717C89}/DB {FFFFFF}- Destruction Derby na arenie\n");
	strcat(StrinG,"{717C89}/SS {FFFFFF}- Skoki spadochronowe w grupie\n");
	strcat(StrinG,"{717C89}/WS {FFFFFF}- Wyœcig samochodowy za nagrody\n");
	strcat(StrinG,"{717C89}/CH {FFFFFF}- Zabawa w chowanego na serwerze\n ");
	strcat(StrinG,"{717C89}/LB {FFFFFF}- Labirynt ten kto 1 znajdzie wyjœcie wygrywa\n");
	strcat(StrinG,"{717C89}/AmmuNation {FFFFFF}- Teleport do AmmuNation\n");
	strcat(StrinG,"{717C89}/Drag {FFFFFF}- Wyœcig Drag na 1/4 Mili z przeciwnikami\n");
	strcat(StrinG,"\n");
	strcat(StrinG,"{717C89}/Komendy {FFFFFF}- Tutaj znajdziesz listê podstawowych komend serwera");
	
	ShowPlayerDialog(playerid,1054,0,"{717C89}Atrakcje",StrinG,"OK","OK");
	
	return 1;
}

CMD:informacje(playerid, cmdtext[])
{
	
	new StrinG[2400];
	StrinG = "{717C89}/Komendy {FFFFFF}- Komendy lista 1\n";
	strcat(StrinG,"{717C89}/Komendy2 {FFFFFF}- Komendy lista 2\n");
	strcat(StrinG,"{717C89}/Atrakcje {FFFFFF}- Atrakcje serwerowe lista 1\n");
	strcat(StrinG,"{717C89}/Atrakcje2 {FFFFFF}- Atrakcje serwerowe lista 2\n");
	strcat(StrinG,"{717C89}/Teles {FFFFFF}- Teleporty serwera\n");
	strcat(StrinG,"{717C89}/Pomoc {FFFFFF}- Szczegó³owa pomoc\n");
	strcat(StrinG,"{717C89}/Tutorial {FFFFFF}- Poradnik o serwerze\n");
	
	ShowPlayerDialog(playerid,1054,0,"{717C89}Informacje",StrinG,"OK","OK");
	
	return 1;
}

CMD:zabawy(playerid, cmdtext[]){
	cmd_atrakcje(playerid,cmdtext);
	return 1;
}

CMD:nowosci(playerid, cmdtext[]){
	

	new string[512];

	strcat(string,"-Dodano konto Moderator\n");
    strcat(string,"-Dodano OGROMN¥!!! liczbê atrakcji /Atrakcje\n");
	strcat(string,"- Poprawiono znaczna ilosc bledow mapy\n");
	strcat(string,"- Dodano nowe bronie do (/Bronie)\n");
	strcat(string,"- Status wyscigu wstawiono do paska stanu pojazdu\n");
	strcat(string,"- Dodano pasek podpowiedzi na dole ekranu\n");
	strcat(string,"- Dodano nowe areny do (/CF)\n");
	strcat(string,"- Ulepszono liste obecnych adminow (/Admins)\n");
	strcat(string,"- Dodano nowy system gangow (/Gang)\n");
	strcat(string,"- Dodano nowy system nitro (na trzymanie klawisza)\n");
	strcat(string,"- Dodano pasek stanu pojazdu (licznik itd.)\n");
	strcat(string,"- Czesciowo zmieniono szate graficzna");

	ShowPlayerDialog(playerid,22,0,"Lista 10 ostatnich zmian na serwerze:",string,"OK","OK");


	return 1;
}

CMD:super(playerid, cmdtext[]){
	cmd_atrakcje(playerid,cmdtext);
	return 1;
}

CMD:tdpanel(playerid, cmdtext[]){
	

	ShowPlayerDialog(playerid, 28, DIALOG_STYLE_LIST, "Zarzadzanie TextDrawami!", "Wszystkie \nZegar \nPasek Stanu \nNazwa Serwa\nTabelka Chowanego \nOgloszenia \nGlosowanie \nTabelka Zapisow \nStatus pojazdu\nPodpowiedzi\nLevel", "OK", "Anuluj");

	return 1;
}

CMD:respekt(playerid, cmdtext[]){
	

	new string[800];

	strcat(string,"Dzieki punktom exp zdobywasz nowe poziomy (levele),(Gwiazdki)\n");
    strcat(string,"Respekt to twoj szacunek wobec innych graczy\n");
	strcat(string,"Im wiêkszy masz level tym lepsze rzeczy dostajesz na spawnie\n");
	strcat(string,"Jeœli chcesz zobaczyc jakie to sa rzeczy wpisz:  /gwiazdki\n");
	strcat(string,"Respekt mozesz wykorzystac na specjalne komendy:  /Rcmd\n");
	strcat(string,"Punktami exp mozesz oplacac wynajmowany dom\n\n");
	strcat(string,"JAK ZDOBYWAC RESPEKT?\n\n");
	strcat(string,"- Za zabijanie innych graczy (pamietajac o tym ze nie wszedzie mozna to robic)\n");
	strcat(string,"- Za wygrywanie na atrakcjach, np. /WG /CF /DB  (zobacz /Atrakcje)\n");
	strcat(string,"- Respekt otrzymujesz dodatkowo po prostu za to ze grasz u nas!\n");
	strcat(string,"- Za godzine grania wychodzi 50 exp\n");
	strcat(string,"- Za pelna godzine grania (bez wychodzenia) jest premia dodatkowo 100 exp!\n");
	strcat(string,"- Jesli twoj nick rozpoczyna sie tagiem [FGS] otrzymujesz 100 procent wiecej pkt exp za czas grania (150)!");

	ShowPlayerDialog(playerid,22,0,"INFO> Respekt",string,"OK","OK");

	return 1;
}

CMD:powody(playerid, cmdtext[]){
    

	new string[2000];

	strcat(string,"{FF0000}1. God Mode {FFFFFF}- czyli gracza nie mo¿na zabiæ nawet po wpisaniu /flo\n");
	strcat(string,"{FF0000}2. Air Break {FFFFFF}- gracz unosi siê w powietrzu\n");
	strcat(string,"{FF0000}3. No Reload {FFFFFF}- gracz strzela ci¹gle bez prze³adowania\n");
	strcat(string,"{FF0000}4. Speed Hack {FFFFFF}- gracz porusza siê szybciej ni¿ normalnie\n");
	strcat(string,"{FF0000}5. Obraza {FFFFFF}- jeœli gracz wyzywa ciê na czacie lub PM a admin nie reaguje\n");
	strcat(string,"Oczywiœcie jeœli nie ma czegoœ na liœcie a s¹dzicie ¿e trzeba to zg³osiæ\n");
	strcat(string,"To mo¿na wysy³aæ raport,  Fa³szywe lub Bezsensowne raporty nagradzanie {FF0000}Warnem {FFFFFF}!");
	
	return 1;
}

CMD:teles(playerid, cmdtext[])
{
	

	new string[1200];

    strcat(string,"/Island   /StuntZone   /pub   /pustynia   /gora   /City2   /Wiezowiec\n");
	strcat(string,"/Sfinks   /WaterLand   /MiniPort   /Skocznia   /Ziolo   /Stadion\n");
	strcat(string,"/Party   /NRGPark   /Stunt   /Wyskok   /Puszcza   /TSDin\n");
    strcat(string,"/LV   /LS   /SF   /LVlot   /Grecja   /Lot(1-2)   /DilliMore\n");
	strcat(string,"/SFlot   /LSlot   /Impra   /Kosciol   /House   /Castle   /BlueBerry\n");
	strcat(string,"/4smoki   /TuneLV   /TuneSF   /TuneLS   /Stunt   /FlintCounty\n");
	strcat(string,"/PlazaSF  /Plaza   /Molo   /DB   /Lost   /Bogowie   /TierraRobada\n");
	strcat(string,"/VC   /Tama   /Zadupie   /Kart   /PodWoda   /Labirynt2   /EQ\n");
	strcat(string,"/Drag   /Zjazd   /Zjazd2   /PGR   /Kosmos   /Nascar\n");
	strcat(string,"/DD   /g1   /g2   /g3   /HappyLand\n");
	strcat(string,"/g4   /Salon   /Osiedle(1-5)   /F1\n");
	strcat(string,"/Stunt   /StuntCity   /Baza(1-4)   /Tortury\n");
	strcat(string,"/KSS   /Drift(1-7)   /Zakochani   /Miasteczko   /Kanaly\n");
	strcat(string,"/Wiezowiec   /SkatePark   /Lot   /Lot2   /Przyszlosc   /City   /Party\n");
	strcat(string,"/Ammo   /RCshop   /CPN   /CJgarage /tokiodrift\n");
	strcat(string,"/Calligula   /Andromeda   /Wooziebed   /Jaysdin\n");
	strcat(string,"/WOC   /TDdin   /Brothel   /Brothel2   /Rats\n");
    strcat(string,"/kart2   /citydrift   /Baza5   /Domek\n");
	strcat(string,"/MiniPort   /Afganistan   /Wietnam\n");
	strcat(string,"/Warsztat   /Warsztat2   /Bar\n");
	strcat(string,"/Lot   /Dirt   /Wjazd   /PodWoda   /PeronLS   /PeronLV   /PeronSF\n");
	strcat(string,"Pamietaj to nie wszystkie teleporty! Wiecej pod /Atrakcje");

	ShowPlayerDialog(playerid,22,0,"CMD> Teleporty",string,"OK","OK");

	return 1;
}

CMD:teleporty(playerid, cmdtext[]){
	cmd_teles(playerid,cmdtext);
	return 1;
}


CMD:www(playerid, cmdtext[]){
	
	SendClientMessage(playerid, COLOR_RED2," ");
	SendClientMessage(playerid, COLOR_RED2,"__________________________________________________________________");
	SendClientMessage(playerid, 0xB0D827FF,"www.FullGaming.pl");
    SendClientMessage(playerid, COLOR_YELLOW,"Zapraszamy w odwiedziny na forum!");
	SendClientMessage(playerid, COLOR_RED2,"__________________________________________________________________");
	return 1;
}

CMD:vipinfo(playerid, cmdtext[])
{
	

    ShowPlayerDialog(playerid,DIALOG_VIP,DIALOG_STYLE_LIST,"Konto premium (VIP)","Informacje\nMo¿liwoœci konta premium\nKomendy konta premium","Wybierz","Anuluj");

	return 1;
}

CMD:modinfo(playerid, cmdtext[]){
	

	new string[1000];

	strcat(string,"__________[Mozliwosci Konta MODERATOR]__________\n\n");
	strcat(string,"* Kickowanie Graczy\n");
	strcat(string,"* Wstawianie pojazdów w mapê\n");
	strcat(string,"* Ranga na chacie (MOD)\n");
	strcat(string,"* Dodawanie sobie dowolnej broni wraz z amunicja\n");
	strcat(string,"* Dodawanie sobie nielimitowanej ilosci pieniedzy\n");
	strcat(string,"* Dodawanie innym ograniczana ilosc pieniedzy\n");
	strcat(string,"* Ustawianie dowolnej godziny na serwerze\n");
	strcat(string,"* Szacunek\n");
	strcat(string,"* Pisanie na prywatnym czacie Modow i Adminow\n");
	strcat(string,"* Naprawianie pojazdu dowolnemu graczowi za darmo\n");
	strcat(string,"* Posiadanie wyrozniajacego sie koloru zielonego\n");
	strcat(string,"* Posiadanie napisu MODERATOR nad nickiem\n");
	strcat(string,"* Uzdrawianie dowolnego gracza za darmo\n");
	strcat(string,"* Dodawanie sobie kamizelki kuloodpornej za darmo\n");
	strcat(string,"* Teleportowanie jednego gracza do drugiego\n\n\n");
	strcat(string,"______________________________________________\n");
	strcat(string,"Jesli jestes zainteresowany posiadaniem konta MODERATOR\n");
	strcat(string,"Odwiedzaj nasza strone: ");
	strcat(string,ServerUrl);

	ShowPlayerDialog(playerid,1212,0,"INFO> Konto Moderator",string,"OK","OK");

	return 1;
}

CMD:sky(playerid, cmdtext[]){
	
	GameTextForPlayer(playerid,"~g~~h~SKY", 2500, 3);
	PlayerTeleport(playerid,0, 3073.2490,-1514.9739,1412.6638);
	ResetPlayerWeapons(playerid);
	SetPlayerArmour(playerid,100);
	SetPlayerHealth(playerid,100);
	GivePlayerWeapon(playerid, 46, 3000);
	RuraCD[playerid] = 0;
	MaRure[playerid] = 0;
	SetPlayerRaceCheckpoint(playerid,3,3091.5725, -1518.9702, 1324.4307 ,3094.2212, -1536.1183, 1205.6886,2);
	return 1;
}

CMD:wyspa(playerid, cmdtext[]){
	
	PlayerTeleport(playerid,0,1503,6342,5);
	GameTextForPlayer(playerid,"~g~~h~WYSPA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
}

CMD:osiedle1(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1431.2542,2590.4102,10.6719);
	GameTextForPlayer(playerid,"~g~~h~OSIEDLE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:osiedle2(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1602.2233,2733.3799,10.6719);
	GameTextForPlayer(playerid,"~g~~h~OSIEDLE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:osiedle3(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1993.9541,2743.2903,10.6719);
	GameTextForPlayer(playerid,"~g~~h~OSIEDLE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:osiedle4(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1946.4294,939.1719,10.3921);
	GameTextForPlayer(playerid,"~g~~h~OSIEDLE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:osiedle5(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2149.3955,715.5646,10.8304);
	GameTextForPlayer(playerid,"~g~~h~OSIEDLE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:g1(playerid, cmdtext[]){
	CarTeleport(playerid,0,2264.2097,1398.7369,42.5925);
	GameTextForPlayer(playerid,"~g~~h~PARKING G1", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:g2(playerid, cmdtext[]){
	CarTeleport(playerid,0,2008.1486,1732.1975,18.9339);
	GameTextForPlayer(playerid,"~g~~h~PARKING G2", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:g3(playerid, cmdtext[]){
	CarTeleport(playerid,0,2074.0437,2416.8750,49.5234);
	GameTextForPlayer(playerid,"~g~~h~PARKING G3", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:g4(playerid, cmdtext[]){
	CarTeleport(playerid,0,1700.6284,1194.1071,34.7891);
	GameTextForPlayer(playerid,"~g~~h~PARKING G4", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wojsko(playerid, cmdtext[]){
	CarTeleport(playerid,0,351.3806,1786.0936,17.9556);
	GameTextForPlayer(playerid,"~g~~h~WOJSKO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:afganistan(playerid, cmdtext[]){
	CarTeleport(playerid,0,-24.7265,1838.4039,17.1216);
	GameTextForPlayer(playerid,"~g~~h~AFGANISTAN", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wojsko2(playerid, cmdtext[]){
	CarTeleport(playerid,0,72.7191,1917.2032,17.8172);
	GameTextForPlayer(playerid,"~g~~h~WOJSKO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tama(playerid, cmdtext[]){
	CarTeleport(playerid,0,-912.1113,2005.2953,60.4852);
	GameTextForPlayer(playerid,"~g~~h~TAMA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:pub(playerid, cmdtext[]){
	CarTeleport(playerid,0,-510.4305,2597.9048,53.4154);
	GameTextForPlayer(playerid,"~g~~h~TAMA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:miasteczko(playerid, cmdtext[]){
	CarTeleport(playerid,0,-393.5246,2280.4822,40.7083);
	GameTextForPlayer(playerid,"~g~~h~MIASTECZKO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:impra(playerid, cmdtext[]){

	PlayerTeleport(playerid,0,1238.6094, -1161.2808, 38.0243);
    SetPlayerFacingAngle(playerid, 20.0);
	ResetPlayerWeapons(playerid);
	GameTextForPlayer(playerid,"~g~~h~IMPREZA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tunelv(playerid, cmdtext[]){
	CarTeleport(playerid,0,2387.0808,1016.9999,10.5459);
	GameTextForPlayer(playerid,"~g~~h~TUNING LV", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:molo(playerid, cmdtext[]){
	CarTeleport(playerid,0,834.5790,-1858.1664,12.8672);
	GameTextForPlayer(playerid,"~g~~h~MOLO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:warsztat2(playerid, cmdtext[]){
	CarTeleport(playerid,0,1363.6827,1823.6841,10.8203);
	GameTextForPlayer(playerid,"~g~~h~WARSZTAT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:kart2(playerid, cmdtext[]){
	CarTeleport(playerid,0,2359.1953,589.8013,7.7813);
	GameTextForPlayer(playerid,"~g~~h~GOKARTY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:gokarty(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-168.1910,-1719.2704,1.7388);
	GameTextForPlayer(playerid,"~g~~h~GOKARTY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:zadupie(playerid, cmdtext[]){
	CarTeleport(playerid,0,-1383.3280,-1507.3010,102.2328);
	GameTextForPlayer(playerid,"~g~~h~ZADUPIE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:sflot(playerid, cmdtext[]){
	CarTeleport(playerid,0,-1538.8635,-422.9142,5.8516);
	GameTextForPlayer(playerid,"~g~~h~LOTNISKO SF", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:salon(playerid, cmdtext[]){
	CarTeleport(playerid,0,-1987.7372,288.7828,34.5681);
	GameTextForPlayer(playerid,"~g~~h~SALON", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:kosciol(playerid, cmdtext[]){
	CarTeleport(playerid,0,2495.2578,936.2213,10.8280);
	GameTextForPlayer(playerid,"~g~~h~KOSCIOL", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:drift3(playerid, cmdtext[]){
	CarTeleport(playerid,0,-339.9138, 1527.2550, 74.9999);
    SetPlayerFacingAngle(playerid,4.9646);
	GameTextForPlayer(playerid,"~g~~h~DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tunesf(playerid, cmdtext[]){
	CarTeleport(playerid,0,-2694.8188,216.2327,4.3564);
	GameTextForPlayer(playerid,"~g~~h~TUNING SF", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:gora(playerid, cmdtext[]){
	CarTeleport(playerid,0,-2321.1321,-1634.2689,483.8788);
	GameTextForPlayer(playerid,"~g~~h~GORA CHILLIAD", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:zakochani(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-2642.6162,1362.1647,7.1540);
	GameTextForPlayer(playerid,"~g~~h~NIGHT CLUB", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:plazasf(playerid, cmdtext[]){
	CarTeleport(playerid,0,-2896.8655,144.7969,4.9552);
	GameTextForPlayer(playerid,"~g~~h~PLAZA SF", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wiezowiec(playerid, cmdtext[]){
	CarTeleport(playerid,0,1545.9459,-1353.5649,329.6513);
	GameTextForPlayer(playerid,"~g~~h~WIEZOWIEC", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skatepark(playerid, cmdtext[]){
	CarTeleport(playerid,0,1874.0300,-1386.2402,13.7218);
	GameTextForPlayer(playerid,"~g~~h~SKATE PARK", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tunels(playerid, cmdtext[]){
	CarTeleport(playerid,0,2660.1042,-2002.1769,13.5595);
	GameTextForPlayer(playerid,"~g~~h~TUNING LS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tor(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,3976.5640,-1893.8546,3.7667);
	GameTextForPlayer(playerid,"~g~~h~TOR", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:citydrift(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,26.9495,4973.7954,12.8986);
	GameTextForPlayer(playerid,"~g~~h~CITY DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:city(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2585.36596680,-3780.53417969,12.14526510);
	GameTextForPlayer(playerid,"~g~~h~CITY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:party(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,3928.7375,54.7928,17.8382);
	GameTextForPlayer(playerid,"~g~~h~PARTY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:impreza(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,249.490509,-1805.462402,4.462310);
	ResetPlayerWeapons(playerid);
	GameTextForPlayer(playerid,"~g~~h~Impreza by OreiVo", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
    SetPlayerTime(playerid,23,0); //pó³noc
	return 1;
	
}




CMD:nbronie(playerid, cmdtext[])
{//Na Dole Mapy!
	ShowPlayerDialog(playerid, weaponmodels, DIALOG_STYLE_LIST, "Modele Broni", "Nowy MP5\nNowy Kij Basketballowy\nNowy AK-47\nLaser", "Ok", "Anuluj");
	return 1;
	
}

CMD:nrgpark(playerid, cmdtext[]){
	CarTeleport(playerid,0,1374.8914,-334.4879,2.9721);
	GameTextForPlayer(playerid,"~g~~h~NRG PARK", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:ziolo(playerid, cmdtext[]){
	CarTeleport(playerid,0,714.9463,-108.8855,21.0000);
	GameTextForPlayer(playerid,"~g~~h~ZIOLO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lslot(playerid, cmdtext[]){
	CarTeleport(playerid,0,1953.5204,-2290.1130,13.5469);
	GameTextForPlayer(playerid,"~g~~h~LOTNISKO LS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:dillimore(playerid, cmdtext[]){
	CarTeleport(playerid,0,632.8700,-598.4791,16.3359);
	GameTextForPlayer(playerid,"~g~~h~DILLI MORE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:blueberry(playerid, cmdtext[]){
	CarTeleport(playerid,0,171.5260,-22.1227,1.5781);
	GameTextForPlayer(playerid,"~g~~h~BLUE BERRY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:flintcounty(playerid, cmdtext[]){
	CarTeleport(playerid,0,-71.1836,-1117.7645,1.0781);
	GameTextForPlayer(playerid,"~g~~h~FLINT COUNTY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:eq(playerid, cmdtext[]){
	CarTeleport(playerid,0,-1411.0052,2637.6731,55.6875);
	GameTextForPlayer(playerid,"~g~~h~EL QUELBRADOS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}


CMD:nascar(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1982.3100,-6631.4500,23.7500);
	GameTextForPlayer(playerid,"~g~~h~NASCAR", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:happyland(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2085.4998,529.0166,10.5629);
	GameTextForPlayer(playerid,"~g~~h~HAPPY LAND", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:castle(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-5319.1987,-1864.4968,19.5363);
	GameTextForPlayer(playerid,"~g~~h~CASTLE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:stadion(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,3355.2117,-4887.5977,6.7977);
	GameTextForPlayer(playerid,"~g~~h~STADION", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:house(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-2495.9053,2882.4988,72.5840);
	GameTextForPlayer(playerid,"~g~~h~HOUSE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:city2(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,7950.5890,-1396.3820,7.4900);
	GameTextForPlayer(playerid,"~g~~h~CITY 2", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tortury(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2446.79101562,5556.63867188,13.56938934);
	GameTextForPlayer(playerid,"~g~~h~SALA TORTUR", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:puszcza(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-227.8089,4300.1089,85.1468);
	GameTextForPlayer(playerid,"~g~~h~PUSZCZA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:kanaly(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-5906.8789,-2154.0754,69.2307);
	GameTextForPlayer(playerid,"~g~~h~KANALY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:rats(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,4504.8799,-1772.3210,15.0002);
	GameTextForPlayer(playerid,"~g~~h~DE RATS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:warsztat(playerid, cmdtext[]){
	CarTeleport(playerid,0,-1547.1345,-2739.2080,48.5407);
	SetPlayerFacingAngle(playerid,146.3788);
	SetCameraBehindPlayer(playerid);
	GameTextForPlayer(playerid,"~g~~h~WARSZTAT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wieza(playerid, cmdtext[]){
	CarTeleport(playerid,0,948.788574, 2439.683350, 10.874555);
	GameTextForPlayer(playerid,"~g~~h~WIEZA EIFFLA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:basen(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-2943.3792,-203.6268,10.6883);
	SetPlayerFacingAngle(playerid,89.0869);
	GameTextForPlayer(playerid,"~g~~h~BASEN", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:bazadm(playerid, cmdtext[]){
	CarTeleport(playerid,0,677.8779,-2385.4543,15.3191);
	GameTextForPlayer(playerid,"~g~~h~BAZA DM", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:dm(playerid, cmdtext[]){
	CarTeleport(playerid,0,710.5223,-2311.9719,107.7797);
	GameTextForPlayer(playerid,"~g~~h~DM", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:island(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2287.5652,6331.8511,5.6407);
	GameTextForPlayer(playerid,"~g~~h~ISLAND", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:stuntzone(playerid, cmdtext[]){
	CarTeleport(playerid,0,1021.661010, -3127.541992, 13.979999);
	GameTextForPlayer(playerid,"~g~~h~STUNT ZONE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:basejump1(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-2815.2400, 2811.4736, 348.9138);
	GameTextForPlayer(playerid,"~g~~h~BASE JUMP", 2500, 3);
	PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:basejump2(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-439.0849, -2710.1228, 278.3809);
	GameTextForPlayer(playerid,"~g~~h~BASE JUMP", 2500, 3);
	PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:basejump3(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-2508.9343, -698.2396, 910.0764);
	GameTextForPlayer(playerid,"~g~~h~BASE JUMP", 2500, 3);
	PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:basejump4(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-2262.0518, -1674.7251, 569.6106);
	GameTextForPlayer(playerid,"~g~~h~BASE JUMP", 2500, 3);
	PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:rakieta(playerid, cmdtext[]){
	CarTeleport(playerid,0,53.2031,1559.4495,12.8125);
	GameTextForPlayer(playerid,"~g~~h~RAKIETA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:partyland(playerid, cmdtext[]){
	CarTeleport(playerid,0,1953.5204,-2290.1130,13.5469);
    SetPlayerPos(playerid, 836.3963,-2048.5437,12.8672);
	GameTextForPlayer(playerid,"~g~~h~PARTY LAND", 2500, 3);
	PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:dirt(playerid, cmdtext[]){
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, 2360.7957,-647.9197,128.1740);
	GameTextForPlayer(playerid,"~g~~h~RALLY DIRT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:park(playerid, cmdtext[]){
	CarTeleport(playerid,0,1953.5204,-2290.1130,13.5469);
	GameTextForPlayer(playerid,"~g~~h~PARK", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:snarena(playerid, cmdtext[]){
	CarTeleport(playerid,0,1097.8386,1524.1473,107.1953);
	GameTextForPlayer(playerid,"~g~~h~Siano", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:bmx(playerid, cmdtext[]){
	CarTeleport(playerid,0,2862.6895,-1871.9785,11.1110);
	GameTextForPlayer(playerid,"~g~~h~BMX", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:remiza(playerid, cmdtext[]){
	CarTeleport(playerid,0,2764.7873, 2679.6130, 9.8203);
	GameTextForPlayer(playerid,"~g~~h~REMIZA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);  
	return 1;
	
}

CMD:quady(playerid, cmdtext[]){
	CarTeleport(playerid,0,1873.8043, -1666.3293, 1269.7954);
	GameTextForPlayer(playerid,"~g~~h~QUADY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:pustynia(playerid, cmdtext[]){
	CarTeleport(playerid,0,428.4866,2533.7695,16.5045);
	GameTextForPlayer(playerid,"~g~~h~PUSTYNIA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wyskok(playerid, cmdtext[]){
    SetPlayerPos(playerid,-2253.9043,-1716.8960,479.9253);
	SendClientMessage(playerid, COLOR_ORANGE," * Witaj na wyskoku.");
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok(playerid, cmdtext[]){
	SendClientMessage(playerid, 0xFFFF00AA, "  * Dostêpne skoki spadochronowe:");
	SendClientMessage(playerid, 0xFFFFFFAA, "/skok2 /skok3 /skok4 /skok5 itp. a¿ do /skok9");
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok2(playerid, cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA, "  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, -1791.0409, 567.7134, 332.8019);
	GameTextForPlayer(playerid,"Milego lotu :D", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok3(playerid, cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA, "  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, 1452.4982, -1072.8849, 213.3828);
	GameTextForPlayer(playerid, "Milego lotu :D", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok4(playerid, cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA, "  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, 1481.1073, -1790.5154, 156.7533);
	GameTextForPlayer(playerid, "Milego lotu :D", 2500,3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok5(playerid, cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA,"  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerPos(playerid,-1753.6823,885.5562,295.8750);
	GameTextForPlayer(playerid,"Milego lotu :D",2500,3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok6(playerid, cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA,"  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerInterior(playerid,0);
	SetPlayerPos(playerid,-1278.9236,976.3959,139.2734);
	GameTextForPlayer(playerid,"Milego lotu :D",2500,3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok7(playerid, cmdtext[]){
 	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA,"  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerInterior(playerid,0);
	SetPlayerPos(playerid,1966.3888,1912.6749,130.9375);
	GameTextForPlayer(playerid,"Milego lotu :D",2500,3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok8(playerid, cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA,"  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerInterior(playerid,0);
	SetPlayerPos(playerid,2054.8530,2428.6870,165.6172);
	GameTextForPlayer(playerid,"Milego lotu :D",2500,3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:skok9(playerid, cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, 0x33AA33AA,"  * Dosta³eœ spadochron, mi³ego lotu ziomku :D");
	SetPlayerInterior(playerid,0);
	SetPlayerPos(playerid,-2873.0127,2718.6343,275.6272);
	GameTextForPlayer(playerid,"Milego lotu! :D",2500,3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:willa(playerid, cmdtext[]){
	CarTeleport(playerid,0,1260.4903, -804.1359, 88.3125);
	GameTextForPlayer(playerid,"~g~~h~MADD DOG", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:podwoda(playerid, cmdtext[]){
	CarTeleport(playerid,0,5840.928711, -4529.442871, -60);
	GameTextForPlayer(playerid,"~g~~h~PODWODA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:miasto(playerid, cmdtext[])
{
    PlayerTeleport(playerid, 0,2493,-1682,30460);
    return 1;
}

CMD:piramida(playerid, cmdtext[]){
	CarTeleport(playerid,0,2323.7397, 1283.1893, 97.6086);
	GameTextForPlayer(playerid,"~g~~h~PIRAMIDA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:stairs(playerid, cmdtext[]){
	CarTeleport(playerid,0,308.7821,672.2302,10.1305);
	GameTextForPlayer(playerid,"~g~~h~STAIRS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:bagno(playerid, cmdtext[]){
	CarTeleport(playerid,0,-858.9744,-1941.0603,15.1729);
	GameTextForPlayer(playerid,"~g~~h~BAGNO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:peronlv(playerid, cmdtext[])
{
	PlayerTeleport(playerid, 0,2850.3589, 1291.7593, 11.3906);
	GameTextForPlayer(playerid, "~y~Peron ~g~LV", 1200, 1);
	return 1;
}
CMD:peronls(playerid, cmdtext[])
{
	PlayerTeleport(playerid, 0,1738.9878, -1948.4301, 14.1172);
	GameTextForPlayer(playerid, "~y~Peron ~b~LS", 1200, 1);
	return 1;
}
CMD:peronsf(playerid, cmdtext[])
{
	PlayerTeleport(playerid, 0,-1938.1156, 143.1689, 26.2813);
	GameTextForPlayer(playerid, "~y~Peron ~r~SF", 1200, 1);
	return 1;
}

CMD:waterland(playerid, cmdtext[]){
	CarTeleport(playerid,0,2571.8450,-2941.2422,205.2634);
	GameTextForPlayer(playerid,"~g~~h~PARK WODNY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:miniport(playerid, cmdtext[]){
	CarTeleport(playerid,0,1071.7703,-2697.8354,11.2657);
	GameTextForPlayer(playerid,"~g~~h~MINI PORT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tereno2(playerid, cmdtext[]){
	CarTeleport(playerid,0,2938.0244,-744.8797,7.4766);
	GameTextForPlayer(playerid,"~g~~h~TERENO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:amfiteatr(playerid, cmdtext[]){
	CarTeleport(playerid,0,1046.6985,-2470.4265,3.0708);
	GameTextForPlayer(playerid,"~g~~h~AMFI TEATR", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lv2(playerid, cmdtext[]){
	CarTeleport(playerid,0,2144.6506,2371.6367,23.4891);
	GameTextForPlayer(playerid,"~g~~h~CENTRUM LV", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:ls2(playerid, cmdtext[]){
	CarTeleport(playerid,0,484.0972,-1503.8721,19.9600);
	GameTextForPlayer(playerid,"~g~~h~CENTRUM LS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:plaza(playerid, cmdtext[]){
	CarTeleport(playerid,0,330.1647,-1798.5216,4.7001);
	GameTextForPlayer(playerid,"~g~~h~PLAZA LS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:pgr(playerid, cmdtext[]){
	CarTeleport(playerid,0,66.4972,-224.9516,1.7548);
	GameTextForPlayer(playerid,"~g~~h~PGR DOKI", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:arena_derby(playerid, cmdtext[]){
	PlayerTeleport(playerid,15,-1405.4443,946.1092,1030.0840);
	GameTextForPlayer(playerid,"~g~~h~DERBY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:arenadd(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2107.5571, -3257.4402, 5.0000);
	GameTextForPlayer(playerid,"~g~~h~ARENA~n~DERBY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tor2(playerid, cmdtext[]){
	PlayerTeleport(playerid,15,-1537.0796,979.3055,1039.6846);
	GameTextForPlayer(playerid,"~g~~h~TOR", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:kart(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,917.6343, -1945.317, 2.8884);
	GameTextForPlayer(playerid,"~g~~h~GOKARTY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:dirtbike(playerid, cmdtext[]){
	PlayerTeleport(playerid,4,-1433.8196,-653.9620,1051.5610);
	GameTextForPlayer(playerid,"~g~~h~DIRT BIKE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:kss(playerid, cmdtext[]){
	PlayerTeleport(playerid,14,-1475.9512,1640.5054,1052.5313);
	GameTextForPlayer(playerid,"~g~~h~KS STADION", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:vc(playerid, cmdtext[]){
	PlayerTeleport(playerid,1,-1396.3193,86.3535,1032.4810);
	GameTextForPlayer(playerid,"~g~~h~VICE STADIUM", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:statek(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2001.6912,1544.4111,13.5859);
	GameTextForPlayer(playerid,"~g~~h~STATEK", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:rury(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1045.0673,-347.7749,73.9922);
	GameTextForPlayer(playerid,"~g~~h~RURY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:baza3(playerid, cmdtext[]){
	CarTeleport(playerid,0,1933.4719,2392.1357,10.6719);
	GameTextForPlayer(playerid,"~g~~h~BAZA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lost(playerid, cmdtext[])
{

	PlayerTeleport(playerid, 0,1503,6342,5);
    GameTextForPlayer(playerid,"~g~~h~LOST ZAGUBIENI", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
    return 1;
}

CMD:labirynt2(playerid, cmdtext[])
{
	PlayerTeleport(playerid, 0,2323.9233,968.5460,501.6730);
    GameTextForPlayer(playerid,"~g~~h~LABIRYNT DROGOWY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
    return 1;
}

CMD:kosmos(playerid, cmdtext[])
{

	PlayerTeleport(playerid, 0,-1879.5569,-72.1220,693.2439);
    GameTextForPlayer(playerid,"~g~~h~KOS~b~~h~~h~MOS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
    return 1;
}

CMD:stuntcity(playerid, cmdtext[])
{
	SetPlayerPos(playerid,1067.0068,1319.8843,247.3987);
	SetPlayerInterior(playerid, 0);
	SetTimerEx("StuntVeh",1500,0,"i",playerid);
	//TogglePlayerControllable(playerid,0);
	//SetTimerEx("JailUnfreeze",1500,0,"i",playerid);
	GameTextForPlayer(playerid,"~g~~h~STUNT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:4smoki(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2023.6055,1008.2421,10.3642);
	GameTextForPlayer(playerid,"~g~~h~4 DRAGONS", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:f1(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,3976.5640,-1893.8546,3.7667);
	GameTextForPlayer(playerid,"~g~~h~F1 GP", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tokiodrift(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,3280.3330,-1646.8104,26.4978);
	GameTextForPlayer(playerid,"~g~~h~TOKYO DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:przyszlosc(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-2247.6628,394.7376,916.5031);
	GameTextForPlayer(playerid,"~g~~h~PRZYSZLOSC", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:bogowie(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1214.8420,2205.0249,511.9854);
	GameTextForPlayer(playerid,"~g~~h~BOGOWIE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:zjazd(playerid, cmdtext[])
{
	SetPlayerPos(playerid,273.3236,-934.7064,470.9164);
	SetPlayerInterior(playerid, 0);
	SetTimerEx("ZjazdVeh",1500,0,"i",playerid);
	//TogglePlayerControllable(playerid,0);
	//SetTimerEx("JailUnfreeze",1500,0,"i",playerid);
	GameTextForPlayer(playerid,"~g~~h~ZJAZD", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:zjazd2(playerid, cmdtext[]){
	SetPlayerPos(playerid,775.5983, 2493.1392, 489.5291);
	SetPlayerInterior(playerid, 0);
	SetTimerEx("Zjazd2Veh",1500,0,"i",playerid);
	//TogglePlayerControllable(playerid,0);
	//SetTimerEx("JailUnfreeze",1500,0,"i",playerid);
	GameTextForPlayer(playerid,"~g~~h~ZJAZD", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tereno(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,1966.3884,-268.5019,2.8714);
	GameTextForPlayer(playerid,"~g~~h~TERENO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:bank(playerid, cmdtext[]){
	CarTeleport(playerid,0,2187.1436,1991.9537,10.8203);
	GameTextForPlayer(playerid,"~g~~h~BANK", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:forteca(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-1208.8398,-1102.9312,128.2656);
	GameTextForPlayer(playerid,"~g~~h~FORTECA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lvlot(playerid, cmdtext[]){
	CarTeleport(playerid,0,1319.5250,1259.7314,10.8203);
	GameTextForPlayer(playerid,"~g~~h~LOTNISKO LV", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lv(playerid, cmdtext[]){
	CarTeleport(playerid,0,2140.6675,993.1867,10.5248);
	GameTextForPlayer(playerid,"~g~~h~LAS VENTURAS", 2500, 3);
	PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:ls(playerid, cmdtext[]){
	CarTeleport(playerid,0,2496.7500,-1665.6234,13.0083);
	GameTextForPlayer(playerid,"~g~~h~LOS SANTOS", 2500, 3);
	PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wjazd(playerid, cmdtext[]){
	CarTeleport(playerid,0,2154.6067,1419.6191,10.8203);
	GameTextForPlayer(playerid,"~g~~h~WJAZD", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:sf(playerid, cmdtext[]){
	CarTeleport(playerid,0,-2036.8722,133.9763,28.8359);

	GameTextForPlayer(playerid,"~g~~h~SAN FIERRO", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:sf2(playerid, cmdtext[]){
	CarTeleport(playerid,0,-2315.8572,189.5229,34.8848);
	GameTextForPlayer(playerid,"~g~~h~SF CENTRUM", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:drift(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,2341.5869, 1389.7277, 42.4453);
	GameTextForPlayer(playerid,"~g~~h~DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:drift2(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-1359.2048,2176.5120,48.8984);
	GameTextForPlayer(playerid,"~g~~h~DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:drift4(playerid, cmdtext[]){
	CarTeleport(playerid,0,1637.7367, -1160.3418, 23.4198);
	GameTextForPlayer(playerid, "~y~Drift",1000,1);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:drift5(playerid, cmdtext[]){
	CarTeleport(playerid,0,-1251.5940, -37.0473, 14.4846);
	GameTextForPlayer(playerid,"~g~~h~DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:drift6(playerid, cmdtext[]){
	CarTeleport(playerid,0,-2421.6106, -609.2891, 132.1705);
	GameTextForPlayer(playerid,"~g~~h~DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:drift7(playerid, cmdtext[]){
	CarTeleport(playerid,0,2071.9150,2434.2551,49.5234);
	GameTextForPlayer(playerid,"~g~~h~DRIFT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lot(playerid, cmdtext[]){
	PlayerTeleport(playerid,14,-1827.1473,7.2074,1061.1436);
	GameTextForPlayer(playerid,"~g~~h~AIR PORT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lot2(playerid, cmdtext[]){
	PlayerTeleport(playerid,14,-1855.5687,41.2632,1061.1436);
	GameTextForPlayer(playerid,"~g~~h~AIR PORT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:ammo(playerid, cmdtext[]){
	PlayerTeleport(playerid,7,302.2929,-143.1391,1004.0625);
	GameTextForPlayer(playerid,"~g~~h~AMMUNATION", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}


CMD:rcshop(playerid, cmdtext[]){
	PlayerTeleport(playerid,6,-2239.5710,130.0224,1035.4141);
	GameTextForPlayer(playerid,"~g~~h~RC SHOP", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:cpn(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,666.2331,-572.6985,16.3359);
	GameTextForPlayer(playerid,"~g~~h~CPN", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:cjgarage(playerid, cmdtext[]){
	PlayerTeleport(playerid,1,-2048.6060,162.0934,28.8359);
	GameTextForPlayer(playerid,"~g~~h~CJ GARAGE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:calligula(playerid, cmdtext[]){
	PlayerTeleport(playerid,1,2172.0037,1620.7543,999.9792);
	GameTextForPlayer(playerid,"~g~~h~CALLIGULA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wooziebed(playerid, cmdtext[]){
	PlayerTeleport(playerid,1,-2158.7200,641.2880,1052.3817);
	GameTextForPlayer(playerid,"~g~~h~WOOZIE BED", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:jaysdin(playerid, cmdtext[]){
	PlayerTeleport(playerid,4,460.1000,-88.4285,999.5547);
	GameTextForPlayer(playerid,"~g~~h~BAR", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:woc(playerid, cmdtext[]){
	PlayerTeleport(playerid,1,451.6645,-18.1390,1001.1328);
	GameTextForPlayer(playerid,"~g~~h~RESTAURACJA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:tsdin(playerid, cmdtext[]){
	PlayerTeleport(playerid,1,681.4750,-451.1510,-25.6172);
	GameTextForPlayer(playerid,"~g~~h~BAR", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wh(playerid, cmdtext[]){
	PlayerTeleport(playerid,1,1412.6399,-1.7875,1000.9244);
	GameTextForPlayer(playerid,"~g~~h~WARE HOUSE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:wh2(playerid, cmdtext[]){
	PlayerTeleport(playerid,18,1302.5199,-1.7875,1001.0283);
	GameTextForPlayer(playerid,"~g~~h~WARE HOUSE", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:resta(playerid, cmdtext[]){
	PlayerTeleport(playerid,12,2324.4199,-1147.5400,1050.7101);
	GameTextForPlayer(playerid,"~g~~h~RESTAURACJA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:brothel(playerid, cmdtext[]){
	PlayerTeleport(playerid,6,747.6089,1438.7130,1102.9531);
	GameTextForPlayer(playerid,"~g~~h~SEX SHOP", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:brothel2(playerid, cmdtext[]){
	PlayerTeleport(playerid,3,942.1720,-17.0070,1000.9297);
	GameTextForPlayer(playerid,"~g~~h~SEX SHOP", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:port(playerid, cmdtext[]){
	SetPlayerPos(playerid, 2294.0693,558.9081,7.7813);
	GameTextForPlayer(playerid,"~g~~h~PORT", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:lc(playerid, cmdtext[]){
	SetPlayerInterior(playerid,1);
	SetPlayerFacingAngle(playerid,1);
	SetPlayerPos(playerid,-785.0116,506.4748,1381.6016);
	GameTextForPlayer(playerid,"~g~~h~LIBERTY CITY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:bar(playerid, cmdtext[]){
	SetPlayerInterior(playerid,1);
	SetPlayerFacingAngle(playerid,1);
	SetPlayerPos(playerid,-794.9943,492.0277,1376.1953);
	GameTextForPlayer(playerid,"~g~~h~BAR LC", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:mbaza(playerid, cmdtext[]){
	if(Player[playerid][MGang])
	{
    SetPlayerInterior(playerid,5);
	SetPlayerFacingAngle(playerid,237.1721);
	SetPlayerPos(playerid,316.6441,1122.1029,1083.8828);
	GameTextForPlayer(playerid,"~r~~h~SIEDZIBA MALINY", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	}
    SendClientMessage(playerid, COLOR_ERROR, "  * Nie jesteœ cz³onkiem gangu maliny!");
	return 1;
	
}

CMD:nbaza(playerid, cmdtext[]){
    if(Player[playerid][NGang])
	{
	SetPlayerInterior(playerid,8);
	SetPlayerFacingAngle(playerid,2.2168);
	SetPlayerPos(playerid,2807.1050,-1171.4563,1025.5703);
	GameTextForPlayer(playerid,"~b~~h~Siedziba Niebieskich", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	}
    SendClientMessage(playerid, COLOR_ERROR, "  * Nie jesteœ cz³onkiem gangu niebieskich!");
	return 1;
	
}

CMD:andromeda(playerid, cmdtext[]){
	PlayerTeleport(playerid,9,315.8185,984.2496,1959.0851);
	GameTextForPlayer(playerid,"~g~~h~ANDROMEDA", 2500, 3);
    PlayerPlaySound(playerid, 1039, 0, 0, 0);
	return 1;
	
}

CMD:autor(playerid, cmdtext[]){

	new String[512];
	String = "FullGaming "OBECNA_WERSJA"\n"KOMPILACJA"\n\nKod: Mlody626, Xerxes, B.A Baracus, Oreivo kontynuacja _AXV_, Shiny, CeKa.\nMapperzy: Oreivo, Serek\nTesterzy: Shiny, FG.Vito.RSK, Oreivo, CeKa, _AXV_\n\nSzczegolne podziekowania dla:\n\tSA-MP Team, Y_Less, Strickenkid, xeeZ, Ryder, Incognito\n\n\nFullGaming © 2013";
				
	ShowPlayerDialog(playerid, 22, DIALOG_STYLE_MSGBOX, "Autorzy skryptu",String,"Wyjdz ", "");
	

	return 1;
	
}

CMD:strefasmierci(playerid, cmdtext[]){

	new string[128];

	strcat(string,"Strefa Smierci - Miejsce gdzie mo¿na robiæ wszystko np CK,DB,HK itd :)\n");
	ShowPlayerDialog(playerid,936,0,"Strefa Œmierci",string,"OK","OK");

	return 1;
	
}

CMD:strefabezdm(playerid, cmdtext[]){

	new string[128];

	strcat(string,"Strefa Bez DM - Miejsce gdzie NIE mo¿na zabijaæ!\n");
	ShowPlayerDialog(playerid,936,0,"Strefa Bez DM",string,"OK","OK");

	return 1;
	
}

CMD:lowisko(playerid, cmdtext[]){

	new string[1000];

	strcat(string,"{FF9900}[£owisko] - {FFFFFF}Na mapie rozmieszczono 7 miejsc do ³owienia ryb.\n");
	strcat(string,"{FFFFFF}Aby teleportowaæ siê do dowolnego z nich wpisz {FF9900}/lowiska.\n");
    strcat(string,"\n");
	strcat(string,"{FFFFFF}£owiska oznaczone s¹ czarn¹ kotwic¹ na mapie gry.\n");
	strcat(string,"{FFFFFF}Za ka¿d¹ z³owion¹ rybê otrzymujesz nagrodê w postaci kasy i exp.\n");
    strcat(string,"\n");
    strcat(string,"{FF0000}¯yczymy mi³ego wêdkowania!");
	
	ShowPlayerDialog(playerid,22,0,"£owisko",string,"OK","OK");

	return 1;
	
}

CMD:regulamin(playerid, cmdtext[]){

	new string[512];
	format(string,sizeof(string),"1. Zakaz u¿ywania cheatów/spamerów/trainerow etc.\n2. Zakaz podszywania siê pod graczy/administracjê.\n3. Nie zabijaj w strefie 'Bez DM'\n4. Bronie specjalne u¿ywaj tylko w 'Strefie Œmierci'\n5. Nie dokuczaj innym graczom.\n6. Nie buguj serwera!");
	ShowPlayerDialog(playerid,22,0,"Regulamin Serwera",string,"OK","OK");

	return 1;
	
}

CMD:zestaw(playerid, cmdtext[])
{
	GivePlayerWeapon(playerid, 24, 100);
	GivePlayerWeapon(playerid, 27, 100);
	GivePlayerWeapon(playerid, 9, 1);
	SendClientMessage(playerid, COLOR_LIGHT_ORANGE, "  * Zestaw broni, za darmo.");
	return 1;
}



CMD:odlicz(playerid, cmdtext[]){
	
	new string[64];
	if(CDText){
		SendClientMessage(playerid,COLOR_RED2,"Czekaj 10 sek. na zrobienie kolejnego odliczania!");
		return 1;
	}

	if(Count1 >= 3)
	{
		new name[16];
		GetPlayerName(playerid, name, sizeof(name));

		format(string, sizeof(string), "Gracz %s id(%d) Wlaczyl/a Odliczanie",name,playerid);
		SendClientMessageToAll(COLOR_GREEN,string);
        SoundForAll(1150);

		SendClientMessage(playerid, 0xFF0000FF, "Odliczanie 3 sek rozpoczête!");
		CDText = true;
		SetTimer("CDTextUnlock",10000,0);
		CountDown();
		return 1;
	}
	else
	{
		SendClientMessage(playerid,0xFF0000FF , "Poczekaj az skonczy sie to odliczanie!!!");
	}
	return 1;
	
}

/*
CMD:rpg(playerid, cmdtext[]){

	new string[254];
	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid,35,1000);
	GameTextForPlayer(playerid, "~w~Arena RPG",800,1);

	if(!RPGText){
		new name[16];
		GetPlayerName(playerid, name, sizeof(name));
		format(string, sizeof(string), "{FFFF00}%s {0071FF}, dolaczyl/a do >> {FFFF00}/RPG {0071FF}<<  Dolacz sie!",name);
		SendClientMessageToAll(COLOR_BLUEX,string);
        SoundForAll(1150);
		RPGText = true;
		SetTimer("RPGTextUnlock",10000,0);
	}

	new Arenarand = random(sizeof(ArenaSpawn));

	PlayerTeleport(playerid,0,RPGSpawn[Arenarand][0], RPGSpawn[Arenarand][1], RPGSpawn[Arenarand][2]);

	return 1;
	
}


CMD:jetarena(playerid, cmdtext[]){
	new string[128];
	GameTextForPlayer(playerid, "~w~Arena JETPACK",800,1);
    LadowanieJetArena(playerid);
	IsInJetArena[playerid] = 1;

    SetPlayerWorldBounds(playerid, 3507.0305, 3057.0020, 1066.1284, 474.0075);

	if(!JetArenaText){
		new name[16];
		GetPlayerName(playerid, name, sizeof(name));
		format(string, sizeof(string), "{FFFF00}%s {0071FF}, dolaczyl/a do >> {FFFF00}/JetArena {0071FF}<<  Dolacz sie!",name);
		SendClientMessageToAll(COLOR_BLUEX,string);
		JetArenaText = true;
        SoundForAll(1150);
		SetTimer("JetArenaTextUnlock",10000,0);
	}

	new Arenarand = random(sizeof(JetArenaSpawn));
	SetPlayerPos(playerid ,JetArenaSpawn[Arenarand][0], JetArenaSpawn[Arenarand][1], JetArenaSpawn[Arenarand][2]);

	return 1;
	
}

CMD:arena(playerid, cmdtext[]){
	new string[128];

	ResetPlayerWeapons(playerid);
	SetPlayerArmour(playerid, 0);
	GivePlayerWeapon(playerid,29,1000);//weapon mp5
	GivePlayerWeapon(playerid,31,350);//weapon m4
	GivePlayerWeapon(playerid,24,50);//weapon de

	SendClientMessage(playerid, COLOR_GREEN, "Witaj na Arenie!");
	GameTextForPlayer(playerid, "~w~Arena",800,1);


	if(!ArenaText){
		new name[16];
		GetPlayerName(playerid, name, sizeof(name));
		format(string, sizeof(string), "{FFFF00}%s {0071FF}, dolaczyl/a do >> {FFFF00}/Arena {0071FF}<<  Dolacz sie!",name);
		SendClientMessageToAll(COLOR_BLUEX,string);
        SoundForAll(1150);
		ArenaText = true;
		SetTimer("ArenaTextUnlock",10000,0);
	}


	new Arenarand = random(sizeof(ArenaSpawn));
	PlayerTeleport(playerid,0,ArenaSpawn[Arenarand][0], ArenaSpawn[Arenarand][1], ArenaSpawn[Arenarand][2]);

	return 1;
	
}
*/
CMD:nrg(playerid, cmdtext[]){//Na Dole Mapy!

	if(PlayerToPoint(100,playerid,1939.2324,-2499.2456,43.5088)){
		SendClientMessage(playerid, COLOR_WHITE, "Tutaj nie wolno spawnowaæ pojazdów!");
		return 1;
	}

	if(GetPlayerInterior(playerid) != 0){
		SendClientMessage(playerid,COLOR_RED2,"Nrg mo¿na spawnowaæ tylko na dworze!");
		return 1;
	}

	if(Nrgs[playerid] < 6){

		new Float:s[3];
		new Float:Angle;
		GetPlayerFacingAngle(playerid,Angle);
		GetPlayerPos(playerid,s[0],s[1],s[2]);
		if(!IsVehicleInUse(Nrg500[playerid])){
			DestroyVehicle(Nrg500[playerid]);
		}else{
			Nrgs[playerid] ++;
		}
		Nrg500[playerid] = CreateVehicle(522,s[0],s[1],s[2],Angle,2,2,10000);
		PutPlayerInVehicle(playerid, Nrg500[playerid],0);
		SendClientMessage(playerid, COLOR_ORANGE,"Przywo³ano NRG-500!");
	}else{
		SendClientMessage(playerid,COLOR_RED,"Niestety zbyt duzo twoich NRG jezdzi po miescie, Popros admina o pomoc");
	}
	return 1;
	
}

CMD:auta(playerid, cmdtext[]){
	cmd_pojazdy(playerid,cmdtext);
	return 1;
}

CMD:cars(playerid, cmdtext[]){
	cmd_pojazdy(playerid,cmdtext);
	return 1;
}

CMD:v(playerid, cmdtext[]){
	cmd_pojazdy(playerid,cmdtext);
	return 1;
}

CMD:pojazdy(playerid, cmdtext[]){
	if(pAttraction[playerid] == 1)
	{
		SendClientMessage(playerid,COLOR_RED2,"Jesteœ zapisany na atrakcji, nie mo¿esz uruchomiæ okna z pojazdami!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	ZmieniaAuto[playerid] = false;
	ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery \n> Lodzie \n> Samoloty/Helikoptery \n> Zabawki RC", "Dalej", "Anuluj");

	return 1;
	
}

CMD:savepos(playerid, cmdtext[]){

	GetPlayerPos(playerid,LocX, LocY, LocZ);
	SendClientMessage(playerid,COLOR_GREEN,"Utworzyles(as) chwilowy teleport dla wszystkich! (/telpos)");
	return 1;
	
}

CMD:sp(playerid, cmdtext[]){

	GetPlayerPos(playerid,pLocX[playerid], pLocY[playerid], pLocZ[playerid]);
	SendClientMessage(playerid,COLOR_GREEN,"Utworzyles(as) prywatny teleport dla siebie! (/lp)");
	return 1;
	
}

CMD:sv(playerid, cmdtext[]){
	if(!Registered[playerid]){
		SendClientMessage(playerid,COLOR_RED2," * Jeœli chcesz zapisaæ statystyki musisz siê zarejerstrowaæ!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
    SaveData(playerid);
    SendClientMessage(playerid,COLOR_GREEN,"Zapisa³eœ(aœ) swoje statystyki!");
	return 1;
}


CMD:lp(playerid, cmdtext[]){

	if(!SavePos){
		SendClientMessage(playerid,COLOR_RED2,"Prywatne Teleporty wy³¹czone");
		return 1;
	}
	if(pLocX[playerid] == 0.0 && pLocY[playerid] == 0.0 && pLocZ[playerid] == 0.0) {
		SendClientMessage(playerid,COLOR_RED2,"Brak zapisanego teleportu!");
	} else {
		if(IsPlayerInAnyVehicle(playerid)) {
			new VehicleID = GetPlayerVehicleID(playerid);
			SetVehiclePos(VehicleID, pLocX[playerid], pLocY[playerid], pLocZ[playerid]);
		} else {
			SetPlayerPos(playerid,pLocX[playerid], pLocY[playerid], pLocZ[playerid]);
		}
		SendClientMessage(playerid,COLOR_GREEN,"Teleportowa³eœ(aœ) sie do prywatnego teleportu");
	}
	return 1;
	
}

CMD:telpos(playerid, cmdtext[]){

	if(!SavePos){
		SendClientMessage(playerid,COLOR_RED2,"Chwilowy Teleporty wy³¹czony");
		return 1;
	}

	if(LocX == 0.0 && LocY == 0.0 && LocZ == 0.0) {
		SendClientMessage(playerid,COLOR_RED2,"Brak zapisanego teleportu!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	} else {
		if(IsPlayerInAnyVehicle(playerid)) {
			new VehicleID = GetPlayerVehicleID(playerid);
			SetVehiclePos(VehicleID, LocX, LocY, LocZ);
		} else {
			SetPlayerPos(playerid,LocX, LocY, LocZ);
		}
		SendClientMessage(playerid,COLOR_GREEN,"Teleportowa³eœ(aœ) sie do chwilowego teleportu");
	}
	return 1;
	
}

CMD:napraw(playerid, cmdtext[]){
	if (GetPlayerMoney(playerid) >= 3000) {

		RepairVehicle(GetPlayerVehicleID(playerid));
		GivePlayerMoney(playerid, -3000);
		Money[playerid] -= 3000;

		SendClientMessage(playerid,COLOR_GREEN,"Naprawiles(as) swój pojazd! Szybsza naprawa klawisz 2");

	} else { SendClientMessage(playerid, COLOR_RED2, "Nie stac cie na naprawe pojazdu! Szybsza naprawa klawisz 2");
             PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}

	return 1;
}
CMD:zw(playerid, cmdtext[]){
	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}zaraz wraca.",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
	
}

CMD:gg(playerid, cmdtext[]){
	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}Idzie na Gadu-Gadu",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
	
}

CMD:aqq(playerid, cmdtext[]){
	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}Idzie na AQQ",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
	
}

CMD:jj(playerid, cmdtext[]){
	

	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}ju¿ jest!",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
	
}

CMD:fg(playerid, cmdtext[]){
	

	if(!SiemaBlock[playerid])
	{
        new string[256];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
        format(string, sizeof(string), "{28730A}%s {3BAD00}odda³ ¿ycie za {28730A}FullGaming{3BAD00}!",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
		SetPlayerHealth(playerid, 0);
	}
	return 1;
	
}

CMD:siema(playerid, cmdtext[]){
	

	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}mówi siema!",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
	
}

CMD:nara(playerid, cmdtext[]){
	

	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}mówi nara!",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
	
}

CMD:czesc(playerid, cmdtext[]){
	

	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}mówi czeœæ!",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
}

CMD:pa(playerid, cmdtext[]){
	if(!SiemaBlock[playerid]){
		new string[64];
		SiemaBlock[playerid] = true;
		SetTimerEx("SiemaUnlock", 5000, 0,"i",playerid);
		format(string, sizeof(string), "{28730A}%s {3BAD00}mówi Pa Pa",PlayerName(playerid));
		SendClientMessageToAll(COLOR_YELLOW,string);
        SoundForAll(1150);
	}
	return 1;
}

CMD:kolorauto(playerid, cmdtext[]){
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER){
		SendClientMessage(playerid,COLOR_RED2,"Musisz byæ kierowc¹ pojazdu!");
		return 1;
	}
	new rand1 = random(405);
	new rand2 = random(405);
	ChangeVehicleColor(GetPlayerVehicleID(playerid),rand1,rand2);
	SendClientMessage(playerid, COLOR_GREEN, "Kolor twojego pojazdu zostal losowo zmieniony");

	return 1;
	
}

CMD:tir(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-544.5546,-480.4810,25.5178);
	SendClientMessage(playerid, 0xFFFF00AA, ">>> Bierz tira podczep naczepê i jazda! ! ! :D");
	return 1;
	
}

CMD:solo(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-1256.1279, 457.6326, 7.1875);
	SendClientMessage(playerid, 0xFFFF00AA, ">>> Miejsce do Solowek");
	return 1;
	
}

CMD:solo2(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-1260.9821, -158.6957, 14.1484);
	SendClientMessage(playerid, 0xFFFF00AA, ">>> Miejsce do Solowek");
	return 1;
	
}

CMD:solo3(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,-1240.4301, 181.4299, 14.14);
	SendClientMessage(playerid, 0xFFFF00AA, ">>> Miejsce do Solowek");
	return 1;
	
}

CMD:solo4(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,351.35, 2502.9499, 16.4799);
	SendClientMessage(playerid, 0xFFFF00AA, ">>> Miejsce do Solowek");
	return 1;
	
}

CMD:wave(playerid, cmdtext[]){
	OnePlayAnim(playerid, "ON_LOOKERS", "wave_loop", 4.0999, 1, 1, 1, 1, 1);
	return 1;
	
}

CMD:toadmin(playerid, cmdtext[]){

	new wiadomosc[128];
	if(sscanf(cmdtext,"s[128]",wiadomosc)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /toadmin [text]");
		return 1;
	}

	new tmp[128];
	format(tmp, sizeof(tmp), "{ffe5a1}Wys³a³eœ(aœ) wiadomoœæ do administracji. Treœæ: {eab171}%s",wiadomosc);
	SendClientMessage(playerid, 0xAA3333AA, tmp);

	format(tmp, sizeof(tmp), "{ffe5a1}Wiadomoœæ dla administracji od {eab171}%s{ffe5a1}: {eab171}%s",PlayerName(playerid), wiadomosc);
	SendClientMessageToAdmins(0xAA3333AA, tmp);

	return 1;
}

CMD:bug(playerid, cmdtext[]){

	new wiadomosc[128];
	if(sscanf(cmdtext,"s[128]",wiadomosc)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /bug [text]");
		return 1;
	}

	new tmp[128];
	format(tmp, sizeof(tmp), "{ffe5a1}Wys³ano raport o b³êdzie: {eab171}%s ",wiadomosc);
	SendClientMessage(playerid, 0xAA3333AA, tmp);

	format(tmp, sizeof(tmp), "(bug) Gracz %s zg³asza bug na serwerze: %s",PlayerName(playerid), wiadomosc);
	SendClientMessageToAdmins(COLOR_LIGHTGREEN, tmp);

	if(IsAdmin(playerid,2)){
		PlayerPlaySound(playerid, 1147, 0, 0, 0);
		GameTextForPlayer(playerid, "~r~~h~BUG!", 2000, 3);
	}
	return 1;
}
CMD:baza1(playerid, cmdtext[]){

	PlayerTeleport(playerid,0,2190.3643,953.3751,15.7516);
	SendClientMessage(playerid, COLOR_GREEN,"Steleportowales sie do bazy Graczy nr.1");
	return 1;
	
}

CMD:baza5(playerid, cmdtext[]){

	PlayerTeleport(playerid,0,2663.7100,665.5128,10.8203);
	SetPlayerFacingAngle(playerid,239.1025);
	SetCameraBehindPlayer(playerid);
	SendClientMessage(playerid, COLOR_GREEN,"Steleportowales sie do bazy Graczy nr.5");
	return 1;
	
}

CMD:baza4(playerid, cmdtext[]){

	PlayerTeleport(playerid,0,1867.1118,1323.6609,55.3731);
	SendClientMessage(playerid, COLOR_GREEN,"Steleportowales sie do bazy Graczy nr.4    /baza4info");
	return 1;
	
}

CMD:baza2(playerid, cmdtext[]){
	CarTeleport(playerid,0,2407.2317,1168.0560,34.2529);
	SendClientMessage(playerid, COLOR_GREEN,"Steleportowales sie do bazy Graczy nr.2    /baza2info");
	return 1;
	
}

CMD:baza4info(playerid, cmdtext[]){
	SendClientMessage(playerid, COLOR_RED2, "[-- Komendy Bazy Graczy nr.4 ---]");
	SendClientMessage(playerid, COLOR_LIST, "/wup  - winda jedzie w gore!");
	SendClientMessage(playerid, COLOR_LIST, "/wdown  - winda jedzie w dol!");
	SendClientMessage(playerid, COLOR_LIST, "/baza4  - Teleport do bazy!");
	SendClientMessage(playerid, COLOR_LIST, "/baza4info - pokazuje ta liste komend w dowolnym miejscu");
	return 1;
	
}

CMD:windaup(playerid, cmdtext[]){
	if(PlayerToPoint(10,playerid,2416.2512,1155.7294,10.8998) ||
	PlayerToPoint(10,playerid,2413.0183,1157.1639,34.2578)){
		MoveObject(TDCWinda, 2416.103027, 1156.031372, 33.180954,3);
		SendClientMessage(playerid,COLOR_PINK,"Winda Jedzie w Gore!");
	}else{
		SendClientMessage(playerid,COLOR_RED,"Musisz byc obok windy zeby tego uzyc!");
PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
	
}

CMD:windadown(playerid, cmdtext[]){
	if(PlayerToPoint(10,playerid,2416.2512,1155.7294,10.8998) ||
	PlayerToPoint(10,playerid,2413.0183,1157.1639,34.2578)){
		MoveObject(TDCWinda, 2416.103027, 1156.031372, 9.855947,2);
		SendClientMessage(playerid,COLOR_PINK,"Winda Jedzie w Dol!");
        new string[64];
		format(string, sizeof(string), "Gracz %s jedzie wind¹ w dó³! {FF0000}(/Baza2)",PlayerName(playerid));
		SendClientMessageToAll(COLOR_LIGHTGREEN,string);
        SoundForAll(1050);
	}else{
		SendClientMessage(playerid,COLOR_RED,"Musisz byc obok windy zeby tego uzyc!");
PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;

}

CMD:bramaopen(playerid, cmdtext[]){
		MoveObject(szlaban, 96.68, 1920.52, 24.50,4);
        SendClientMessage(playerid,COLOR_PINK,"Brama Otwarta!");
        new string[64];
		format(string, sizeof(string), "Gracz %s otworzy³ bramê! {FF0000}(/Afganistan)",PlayerName(playerid));
		SendClientMessageToAll(COLOR_LIGHTGREEN,string);
        SoundForAll(1050);

	return 1;
	
}

CMD:bopen(playerid, cmdtext[]){
		MoveObject(bramapd, 1607.68, -1641.32, 11.00,4);
        SendClientMessage(playerid,COLOR_PINK,"Brama Otwarta!");
        new string[64];
		format(string, sizeof(string), " * Gracz %s otworzy³ bramê! {FF0000}(Police LS)",PlayerName(playerid));
		SendClientMessageToAll(COLOR_LIGHTGREEN,string);
        SoundForAll(1050);

	return 1;
	
}

CMD:rakietastart(playerid, cmdtext[]){
		MoveObject(rakieta, 153.33, 1559.77, 5000.00,600);
        SendClientMessage(playerid,COLOR_PINK,"Rakieta leci do kosmosu!!!");
        SoundForAll(1050);

	return 1;
	
}

CMD:rakietasflot(playerid, cmdtext[]){
		MoveObject(rakieta, -1538.8635,-422.9142,5.8516,40);
        SendClientMessage(playerid,COLOR_PINK,"Rakieta leci do lotniska w sf!!!");
        SoundForAll(1050);

	return 1;
	
}

CMD:rakietastop(playerid, cmdtext[]){
		MoveObject(rakieta, 53.33, 1559.77, 22.00, 22.00);
        SendClientMessage(playerid,COLOR_PINK,"Rakieta powraca!!!");
        SoundForAll(1050);

	return 1;
	
}

CMD:bclose(playerid, cmdtext[]){
		MoveObject(bramapd, 1598.68, -1641.32, 11.00,4);
        SendClientMessage(playerid,COLOR_PINK,"Brama Zamkniêta!");
        new string[64];
		format(string, sizeof(string), " * Gracz %s zamkn¹³ bramê! {FF0000}(Police LS)",PlayerName(playerid));
		SendClientMessageToAll(COLOR_LIGHTGREEN,string);
        SoundForAll(1050);

	return 1;
	
}

CMD:bramaclose(playerid, cmdtext[]){
		MoveObject(szlaban, 96.68, 1920.52, 19.00,4);
		SendClientMessage(playerid,COLOR_PINK,"Brama Zamknieta!");
        new string[64];
		format(string, sizeof(string), " * Gracz %s zamkn¹³ bramê! {FF0000}(/Afganistan)",PlayerName(playerid));
		SendClientMessageToAll(COLOR_LIGHTGREEN,string);
        SoundForAll(1050);

	return 1;
	
}

CMD:klatkaopen(playerid, cmdtext[]){
	if(PlayerToPoint(15,playerid,2370.2964,1107.0946,34.2578)){
		MoveObject(TDCKlatka, 2370.977783, 1108.294312, 30.499437,4);
	}else{
		SendClientMessage(playerid,COLOR_RED,"Musisz byc obok klatki zeby tego uzyc!");
	}					SendClientMessage(playerid,COLOR_PINK,"Klatka Otwarta!");

	return 1;
	
}

CMD:klatkaclose(playerid, cmdtext[]){
	if(PlayerToPoint(15,playerid,2370.2964,1107.0946,34.2578)){
		MoveObject(TDCKlatka, 2370.977783, 1108.294312, 35.956200,4);
		SendClientMessage(playerid,COLOR_PINK,"Klatka Zamknieta!");
	}else{
		SendClientMessage(playerid,COLOR_RED,"Musisz byc obok klatki zeby tego uzyc!");
	}
	return 1;
	
}

CMD:baza2info(playerid, cmdtext[]){
	SendClientMessage(playerid, COLOR_RED2, "[-- Komendy Bazy Graczy nr.2 ---]");
	SendClientMessage(playerid, COLOR_LIST, "/windaup - winda jedzie w gore");
	SendClientMessage(playerid, COLOR_LIST, "/windadown - winda jedzie w dol");
	SendClientMessage(playerid, COLOR_LIST, "/klatkaopen - otwierasz klatke");
	SendClientMessage(playerid, COLOR_LIST, "/klatkaclose - zamykasz klatke");
	SendClientMessage(playerid, COLOR_LIST, "/baza2info - pokazuje ta liste komend w dowolnym miejscu");
	SendClientMessage(playerid, COLOR_LIST, "/baza2 - teleportujesz sie do Bazy");
	return 1;
	
}

CMD:wdown(playerid, cmdtext[]){
	
	if(PlayerToPoint(15,playerid,1861.5742, 1371.254, 56.0905) ||
	PlayerToPoint(15,playerid,1861.5435, 1371.1971, 17.6581)){
		MoveObject(WindaWB, 1861.5435, 1371.1971, 17.6581, 2.0);
		SendClientMessage(playerid, 0x00FF00FF, "Winda jedzie w dol");
        new string[64];
		format(string, sizeof(string), "Gracz %s jedzie wind¹ w dó³! {FF0000}(/Baza4)",PlayerName(playerid));
		SendClientMessageToAll(COLOR_LIGHTGREEN,string);
        SoundForAll(1050);
	}else{
		SendClientMessage(playerid,COLOR_RED,"Musisz byc obok windy zeby tego uzyc!");
PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
	
}

CMD:wup(playerid, cmdtext[]){
	
	if(PlayerToPoint(15,playerid,1861.5742, 1371.254, 56.0905) ||
	PlayerToPoint(15,playerid,1861.5435, 1371.1971, 17.6581)){
		MoveObject(WindaWB, 1861.5742, 1371.254, 56.0905, 2.0);
		SendClientMessage(playerid, 0x00FF00FF, "Winda jedzie w gore");
	}else{
		SendClientMessage(playerid,COLOR_RED,"Musisz byc obok windy zeby tego uzyc!");
		PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
	
}
//if(!IsAdmin(playerid,2)) return 0;
/*
CMD:admins(playerid, cmdtext[]){
print("1");
	new string[1024];
print("2");
	string = " ";
	if(OnlAD == 0)
	{
		SendClientMessage(playerid,COLOR_WHITE,"Na serwerze nie ma obecnie ¿adnego Administratora!");
		PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	print("3");
	for(new x=0;x != OnlPl;x++)
	{
		if(IsPlayerConnected(x) && Player[x][Admin] < 1)
		{
			format(string,sizeof(string),"%s\n(id: %d) %s Poziom: %d",string,x,PlayerName(x),Player[x][Admin]-1);        
	    }
	}
	print("4");
	ShowPlayerDialog(playerid,905,0,"Admini obecni na serwerze:",string,"OK","OK");
	print("6");
	return 1;
}
*/
CMD:admins(playerid,params[]) {
    #pragma unused params
    new buf[1500] = "ID:\tNick:\n";
	
	if(OnlAD == 0) {
		SendClientMessage(playerid,COLOR_WHITE,"Na serwerze nie ma obecnie ¿adnego Administratora!");
		PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	foreachPly (x) {
		if (Player[x][Admin] > 2) {
			format (buf, sizeof (buf), "%s\n%i\t%s (%s)", buf, x, PlayerName (x), (Player[x][Admin] >= 4)? ("Administrator RCON"): (Player[x][Admin]==3)? ("Administrator"): ("Administrator rekrut"));
		}
	}

	ShowPlayerDialog(playerid,905,DIALOG_STYLE_MSGBOX," Lista administracji",buf,"OK","");
	return 1;
}

CMD:vips(playerid, cmdtext[]){

	new string[256];

	if(OnlVIP == 0) {
		SendClientMessage(playerid,COLOR_WHITE,"Na serwerze nie ma obecnie ¿adnego VIP'a!");
		PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	SendClientMessage(playerid,COLOR_ORANGE," ");
	SendClientMessage(playerid,COLOR_ORANGE,"VIP'y Obecni na Serwerze:");

	new bool:first = true;
	foreachPly (x) {
		if(Player[x][VIP])
		{
	        if(first)
			{
	        	format(string,sizeof(string),"%s",PlayerName(x));
	        	first = false;
	        }
			else
			{
	            format(string,sizeof(string),"%s, %s",string,PlayerName(x));
	        }

	        if(strlen(string) >= 64)
			{
	            SendClientMessage(playerid,COLOR_WHITE,string);
	            strdel(string,0,sizeof(string));
				first = true;
	        }
		}
	}

	if(strlen(string) >= 3)
	{
	    SendClientMessage(playerid,COLOR_WHITE,string);
	}

	SendClientMessage(playerid,COLOR_ORANGE,"_______________________");

	return 1;
	
}

CMD:mods(playerid, cmdtext[]){

	new string[256];

	if(OnlMOD == 0)
	{
		SendClientMessage(playerid,COLOR_WHITE,"Na serwerze nie ma ¿adnego moderatora");
		PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	SendClientMessage(playerid,COLOR_ORANGE," ");
	SendClientMessage(playerid,COLOR_ORANGE,"Moderatorzy online:");

	new bool:first = true;
	foreachPly (x) {
		if(Player[x][Admin] == 1)
		{
	        if(first){
	        	format(string,sizeof(string),"%s",PlayerName(x));
	        	first = false;
	        }
			else
			{
	            format(string,sizeof(string),"%s, %s",string,PlayerName(x));
	        }

	        if(strlen(string) >= 64){
	            SendClientMessage(playerid,COLOR_WHITE,string);
	            strdel(string,0,sizeof(string));
				first = true;
	        }
		}
	}

	if(strlen(string) >= 3)
	{
	    SendClientMessage(playerid,COLOR_WHITE,string);
	}

	SendClientMessage(playerid,COLOR_GREEN,"_______________________");

	return 1;
	
}
CMD:kill(playerid, cmdtext[]){
	KillBug[playerid] = true;
	SetPlayerHealth(playerid, -100.0);
    SetPlayerWorldBounds(playerid,20000.0000,-20000.0000,20000.0000,-20000.0000); //Reset world to player
	return 1;
	
}
CMD:podloz(playerid, cmdtext[]){

	if(!Bombs){
		SendClientMessage(playerid,COLOR_RED2," * Admin wy³¹czy³ chwilwo mo¿liwoœæ podkladania bomb");
		return 1;
	}

	if(!IsPlayerInArea(playerid,605.5474,1390.8591,-1423.9529,-1328.6188)){
		if (!Bomber[playerid]){
			MozeDetonowac[playerid] = false;
			SetTimerEx("DetonUnlock", 10000,0,"i",playerid);
			KillTimer(Detonacjaa[playerid]);
			Detonacjaa[playerid] = SetTimerEx("Detonacja", 120000, 0, "i", playerid);
			Bomber[playerid] = true;
			GetPlayerPos(playerid, BombX[playerid], BombY[playerid], BombZ[playerid]);
			Bombus[playerid] = CreatePickup(1252,1,BombX[playerid],BombY[playerid],BombZ[playerid]);
			SendClientMessage(playerid, COLOR_GRAD1, "Wpisz /zdetonuj aby wysadzic Bombe!");
            SoundForAll(1050);
		}else{
			SendClientMessage(playerid, COLOR_RED, " * Juz podlozyles jedna bombe!");
			PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		}
	}else{
		SendClientMessage(playerid, COLOR_RED, " * Nie wolno podk³adaæ bomb na dragu!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
	
}

CMD:zdetonuj(playerid, cmdtext[]){
	if(MozeDetonowac[playerid]){
		if (Bomber[playerid]){
			MozeDetonowac[playerid] = true;
			KillTimer(Detonacjaa[playerid]);
			Bomber[playerid] = false;
			SendClientMessage(playerid, COLOR_GRAD1, "BoooooM!!!");
			CreateExplosion(BombX[playerid], BombY[playerid], BombZ[playerid], 6, 20.0);
			PickDestroy(Bombus[playerid]);

		}else{
			SendClientMessage(playerid, COLOR_RED, " * Nie podlozyles zadnej Bomby!");
			PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		}			}else{
		SendClientMessage(playerid, COLOR_RED, " * Musisz odczekaæ 10 sek. aby zdetonowac");
	}
	return 1;
	
}

CMD:drag(playerid, cmdtext[]){
	PlayerTeleport(playerid,0,623.1945,-1391.3428,13.0539);
	SendClientMessage(playerid, COLOR_GREEN,"(drag) Ustaw sie na starcie i gdy wszyscy beda gotowi wpisz  {FF0000}/DragStart");
	return 1;
	
}

CMD:dragstart(playerid, cmdtext[]){

	if(PlayerToPoint(3.0,playerid,664.1330,-1392.5837,13.1778) ||
	PlayerToPoint(3.0,playerid,664.3258,-1397.8151,13.1221) ||
	PlayerToPoint(3.0,playerid,663.8873,-1402.8795,13.0817) ||
	PlayerToPoint(3.0,playerid,663.6431,-1408.2515,13.0918))
	{
		if(!DragON){
			Dragliczba = 0;
			foreachPly (x) {
				if(PlayerToPoint(3.0,x,664.1330,-1392.5837,13.1778) ||
				PlayerToPoint(3.0,x,664.3258,-1397.8151,13.1221) ||
				PlayerToPoint(3.0,x,663.8873,-1402.8795,13.0817) ||
				PlayerToPoint(3.0,x,663.6431,-1408.2515,13.0918))
				{
					TogglePlayerControllable(x,0);
					Dragliczba ++;
				}
			}

			if(Dragliczba < 2){
				SendClientMessage(playerid,COLOR_RED2," * Sam/a nie mozesz jechac na dragu!");
				TogglePlayerControllable(playerid,1);
                PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
				return 1;
			}

			DragON = true;
			SendClientMessageToAllDrag(0x0080FFFF,"(drag) Wyscig DRAG wystartuje za 3 sek.");
			KillTimer(DragTimer);
			DragTimer = SetTimer("DragTimerr",45000,0);
			Dragcd();


		}else{
			SendClientMessage(playerid,COLOR_RED," * Juz trwa jakis Drag! Czekaj na zakonczenie");
            PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		}
	}

	return 1;
	
}


//CMD:ms(playerid, cmdtext[]){
	//cmd_mojskin(playerid,cmdtext);
//	return 1;
//}
/*
CMD:mojskin(playerid, cmdtext[]){

	if(!Registered[playerid]){
		SendClientMessage(playerid,COLOR_RED2," * Jeœli chcesz aby twój skin sie zapisywa³ musisz siê zarejerstrowaæ!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	new tmp[256];
	tmp = mysql_get("Nick",PlayerName(playerid),"Skin","Players");

	if(strval(tmp) == 0){
		SendClientMessage(playerid,COLOR_RED2," * Nie masz zapisanego Skina!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	SetSpawnInfo(playerid,0,strval(tmp),0,0,0,0,4,1,24,3000,29,3000);
	SpawnPlayer(playerid);

	return 1;
	
}*/

CMD:stylwalki(playerid, cmdtext[]){
	ShowPlayerDialog(playerid, DIALOG_WALKA, DIALOG_STYLE_LIST, "Wybierz swój styl walki!", "Normalalny Styl Walki\nBoxerski Styl Walki\nKarate\nSkin Head\nKick Boxing\nCzarnuch", "Wybieram", "Anuluj");
	return 1;
	
}
CMD:bronie(playerid, cmdtext[]){
	
	new string[2000];
	strcat(string,"{FFFF00}Kastet {FFFFFF}- $100\n{FFFF00}Kij Golfowy {FFFFFF}- $100\n{FFFF00}Palka Policyjna {FFFFFF}- $100\n{FFFF00}Noz {FFFFFF}- $100\n{FFFF00}Baseball {FFFFFF}- $100\nLopata {FFFFFF}- $100\n{FFFF00}Kij Bilardowy {FFFFFF}- $100\n{FFFF00}Katana {FFFFFF}- $100\n{FFFF00}Pila Lancuchowa {FFFFFF}- $1500\n{FFFF00}Dildo {FFFFFF}- $100\n{FFFF00}Kwiaty {FFFFFF}- $100\n{FFFF00}Gaz Lzawiacy {FFFFFF}- $5000\n{FFFF00}9mm {FFFFFF}- $3000\n{FFFF00}Silencer {FFFFFF}- $4000\n");
	strcat(string,"{FFFF00}Desert Eagle {FFFFFF}- $5000\n{FFFF00}Shotgun {FFFFFF}- $5000\n{FFFF00}Sawn-off {FFFFFF}- $8000\n{FFFF00}Combat Shotgun {FFFFFF}- $25000\n{FFFF00}Micro SMG {FFFFFF}- $10000\n{FFFF00}MP5 {FFFFFF}- $12000\n{FFFF00}AK-47 {FFFFFF}- $13000\n{FFFF00}M4 {FFFFFF}- $15000\n{FFFF00}Tec9 {FFFFFF}- $10000\n{FFFF00}Country Rifle {FFFFFF}- $5000\n{FFFF00}Sniper Rifle {FFFFFF}- $20000\n{FFFF00}Spray {FFFFFF}- $100\n{FFFF00}Gasnica {FFFFFF}- $500\n{FFFF00}Spadochron {FFFFFF}- $100");
	ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST,"Bronie do kupienia:", string, "Kup", "Wyjdz");
	return 1;
	
}
/*
CMD:hud(playerid, cmdtext[]){
	
	new string[128];
	strcat(string,"Domyœlny (Szary)\n¯ó³ty\nCzerwony\nZielony\nPomarañczowy\nRó¿owy\nBr¹zowy");

	ShowPlayerDialog(playerid, DIALOG_HUD, DIALOG_STYLE_LIST,"Wybierz HUD (Szata Graficzna)", string, "Wybierz", "Wyjdz");

	return 1;
	
}
*/
CMD:klany(playerid, cmdtext[]){
	new string[256];
	strcat(string,"[BBT] Bad Boys Team\nGangsta Of Friends\nLos Santos Aztecas\nDrift Team\nGuard Of Light");
	ShowPlayerDialog(playerid, 1020, DIALOG_STYLE_LIST,"Klany na serwerze:", string, "Wybierz", "Wyjdz");
	return 1;
}

/*
CMD:bronies(playerid, cmdtext[]){
	if(WGKandydat[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Jesteœ zapisany na WG i nie mo¿esz uruchomiæ okna z broñmi");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(CTFKandydat[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Jesteœ zapisany na WG i nie mo¿esz uruchomiæ okna z broñmi");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(IsPlayerInArea(playerid, -102.0093,488.8185, 1661.8014, 2204.8889)){
		ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Bronie Specjalne ( Tylko na Terenie Wojska!!! )", "Minigun   $1 000 000\nRPG   $500 000\nRPG Auto   $750 000\nMiotacz ognia   $400 000\nLadunki wybuchowe   $200 000\nGranaty   $150 000", "Kupuje", "Anuluj");
	}else{
		SendClientMessage(playerid,COLOR_RED2," * Nie jestes na terenie wojska!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;	
}
*/
CMD:tune(playerid, cmdtext[]){
	if(IsPlayerInAnyVehicle(playerid)){
		PlayerPlaySound(playerid, 1134, 0, 0, 0);
		TuneCar(GetPlayerVehicleID(playerid));
		GivePlayerMoney(playerid, -5000);
		Money[playerid] -= 5000;
		SendClientMessage(playerid, COLOR_LIGHTRED, "Twoj pojazd zostal ztuningowany!");
	} else {
		SendClientMessage(playerid, COLOR_ADMIN, " * Musisz byc w pojezdzie aby go ztuningowac!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;	
}
CMD:losowanie(playerid, cmdtext[]){
	CarTeleport(playerid,0,-2157.8281,-425.8768,35.3359);
	return 1;
}
CMD:cardive(playerid, cmdtext[]){

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;

	if(GetPlayerMoney(playerid) < 1500)
	{
		SendClientMessage(playerid, COLOR_YELLOW, " * Nie masz tyle kasy!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(IsPlayerInAnyVehicle(playerid))
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		new VehicleID;
		GetPlayerPos(playerid, X, Y, Z);
		VehicleID = GetPlayerVehicleID(playerid);
		GivePlayerMoney(playerid, - 1500);
		Money[playerid] -= 1500;
		SetVehiclePos(VehicleID, X, Y, Z + 900.00);
		GivePlayerWeapon(playerid,46,1);
	}
	else
	{
		SendClientMessage(playerid, COLOR_RED, " * Nie jestes w pojezdzie.");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
}
CMD:flip(playerid, cmdtext[]){

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;

	new VehicleID, Float:X, Float:Y, Float:Z, Float:Angle;
	GetPlayerPos(playerid, X, Y, Z);
	VehicleID = GetPlayerVehicleID(playerid);
	GetVehicleZAngle(VehicleID,Angle);
	SetVehiclePos(VehicleID, X, Y, Z);
	SetVehicleZAngle(VehicleID,Angle);
	return 1;
	
}
CMD:givecash(playerid, cmdtext[]){
	new gracz,kasa;
	if(sscanf(cmdtext,"ud",gracz,kasa)){
	    SendClientMessage(playerid, COLOR_WHITE, "WPISZ: /Givecash [id_gracza] [kwota]");
		return 1;
	}

	if(kasa < 0){
	    SendClientMessage(playerid,COLOR_RED2," * Z³a kwota!");
		return 1;
	}

	if(Money[playerid] < kasa && !IsAdmin(playerid,2)){
	    SendClientMessage(playerid,COLOR_RED2," * Nie masz tyle pieniêdzy!");
		return 1;
	}

	if(!IsPlayerConnected(gracz)){
	    SendClientMessage(playerid,COLOR_RED2," * Nie ma takiego gracza!");
		return 1;
	}

	if(!IsAdmin(playerid,2)){
		GivePlayerMoney(playerid, (0 - kasa));
		Money[playerid] -= kasa;
	}

	GivePlayerMoney(gracz, kasa);
	Money[gracz] += kasa;

	new tmp[80];

	if(!IsAdmin(playerid,2)){
		format(tmp, sizeof(tmp), " * Odda³eœ(aœ) graczowi: %s (id: %d), $%d pieniedzy.",PlayerName(gracz),gracz,kasa);
		SendClientMessage(playerid, COLOR_YELLOW, tmp);
		format(tmp, sizeof(tmp), " * Otrzymales $%d pieniedzy od gracza %s (id: %d).", kasa, PlayerName(playerid), playerid);
		SendClientMessage(gracz, COLOR_YELLOW, tmp);
	}else{
		format(tmp, sizeof(tmp), " * Da³eœ(aœ) graczowi: %s (id: %d), $%d pieniedzy.",PlayerName(gracz),gracz,kasa);
		SendClientMessage(playerid, COLOR_YELLOW, tmp);
		format(tmp, sizeof(tmp), " * Otrzymales $%d pieniedzy od admina %s (id: %d).", kasa, PlayerName(playerid), playerid);
		SendClientMessage(gracz, COLOR_YELLOW, tmp);
	}

	return 1;
}

CMD:hitman(playerid, cmdtext[]){

	new gracz,kasa;
	if(sscanf(cmdtext,"ud",gracz,kasa)){
	    SendClientMessage(playerid, COLOR_WHITE, "WPISZ: /hitman [idgracza] [kwota]");
		return 1;
	}

	if(kasa > Money[playerid]) {
		SendClientMessage(playerid, COLOR_RED2, "Nie masz tyle pieniêdzy!");
		return 1;
	}
	if(kasa < 100000) {
		SendClientMessage(playerid, COLOR_RED2, "Zbyt ma³a kwota! (co najmniej $100 000)");
		return 1;
	}

	if(!IsPlayerConnected(gracz)) {
		SendClientMessage(playerid, COLOR_RED2, "Nie ma takiego gracza!");
		return 1;
	}

	if(!HitmanBlock[playerid]){

		HitmanBlock[playerid] = true;
		SetTimerEx("HitmanUnlock", 10000, 0,"i",playerid);

		if(bounty[gracz]+kasa <= 2147483647){
			bounty[gracz]+=kasa;
			GivePlayerMoney(playerid, 0-kasa);
			Money[playerid] -= kasa;
		}else{
			bounty[gracz] = 2147483647;
			GivePlayerMoney(playerid, 0-kasa);
			Money[playerid] -= kasa;
		}

		new giveplayer[25];
		new sendername[25];
		GetPlayerName(gracz, giveplayer, sizeof(giveplayer));
		GetPlayerName(playerid, sendername, sizeof(sendername));

		new tmp[128];
		format(tmp, sizeof(tmp), "%s id:(%d) Wyznacza nagrode [$%d] za zabicie gracza: %s , Razem: $%d ", sendername,playerid, kasa, giveplayer, bounty[gracz]);
		SendClientMessageToAll(COLOR_ORANGE, tmp);

		format(tmp, sizeof(tmp), "Nagroda za twoja smierc - $%d od gracza: %s (id: %d).", kasa, sendername, playerid);
		SendClientMessage(gracz, COLOR_RED, tmp);
	}

	return 1;
}

CMD:bounty(playerid, cmdtext[]){

	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, COLOR_WHITE, "WPISZ: /bounty [idgracza]");
		return 1;
	}

	if(IsPlayerConnected(gracz)) {
		new tmp[80];
		format(tmp, sizeof(tmp), "%s (id: %d) - nagroda za g³owê tego gracza to $%d ", PlayerName(gracz),gracz,bounty[gracz]);
		SendClientMessage(playerid, COLOR_YELLOW, tmp);
	} else {
		SendClientMessage(playerid, COLOR_RED2, " * Nie ma takiego gracza!");
	}

	return 1;
}

CMD:bounties(playerid, cmdtext[]){

	new string[512];
	new cd;
	foreachPly (x) {
	    if(bounty[x] > 0){
	        new name[21];
	        GetPlayerName(x,name,sizeof(name));
	        format(string,sizeof(string),"%s\n%s ($%d)",string,name,bounty[x]);
	        cd ++;
	        if(cd >= 10) break;
	    }
	}

	ShowPlayerDialog(playerid,22,0,"Nagrody za g³owy graczy!",string,"OK","OK");

	return 1;
	
}

CMD:zamknijdom(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	new x=HouseID[playerid];
	HouseInfo[x][hOpen] = false;
	SendClientMessage(playerid,COLOR_GREEN,"Dom zamkniêty!");

	return 1;
	
}

CMD:otworzdom(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	new x=HouseID[playerid];
	HouseInfo[x][hOpen] = true;
	SendClientMessage(playerid,COLOR_GREEN,"Dom otwarty!");

	return 1;
	
}

CMD:oplacdom(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	new oplata;
	if(sscanf(cmdtext,"d",oplata)){
	    SendClientMessage(playerid, COLOR_WHITE, "/OplacDom [kwota]");
		return 1;
	}

	if(oplata > Respekt[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz tyle exp!");
		return 1;
	}

	if(oplata <= 0){
		SendClientMessage(playerid,COLOR_RED2,"Nieprawid³owa iloœæ exp!");
		return 1;
	}

	new x=HouseID[playerid];

	HouseInfo[x][hBudget] += oplata;
	Respekt[playerid] -= oplata;
	wykorzystanyrespekt[playerid] += oplata;

	
	MSGF(playerid,COLOR_GREEN, "Wplaci³eœ(aœ) na konto domowe %d exp | Aktualny stan konta: (%d)", oplata,HouseInfo[x][hBudget]);

	return 1;
}

CMD:wyplacdom(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	new wyplata;
	if(sscanf(cmdtext,"d",wyplata)){
	    SendClientMessage(playerid, COLOR_WHITE, "/WyplacDom [kwota]");
		return 1;
	}

	if(wyplata <= 0){
		SendClientMessage(playerid,COLOR_RED2,"Nieprawid³owa iloœæ exp!");
		return 1;
	}

	new x=HouseID[playerid];

	if(wyplata > HouseInfo[x][hBudget]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz tyle na swoim koncie");
		return 1;
	}

	HouseInfo[x][hBudget] -= wyplata;
	Respekt[playerid] += wyplata;
	wykorzystanyrespekt[playerid] -= wyplata;

	new tmp[128];
	format(tmp, sizeof(tmp), "Wyp³aci³eœ(aœ) z konta domowego %d exp | Aktualny stan konta: (%d)", wyplata,HouseInfo[x][hBudget]);
	SendClientMessage(playerid,COLOR_GREEN, tmp);

	return 1;
}

CMD:stankonta(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	new x=HouseID[playerid];

	new string2[128];
	format(string2, sizeof(string2), "Stan twojego konta wynosi %d exp (wystarczy na %d godz.)", HouseInfo[x][hBudget],HouseInfo[x][hBudget]/HouseInfo[x][hCost]);
	SendClientMessage(playerid,COLOR_GREEN, string2);

	return 1;
}

CMD:autodom(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	new x=HouseID[playerid];

	SetVehicleToRespawn(HouseInfo[x][hCarid]);
	SendClientMessage(playerid,COLOR_GREEN,"Pojazd przywo³any przed dom");

	return 1;
}

CMD:zmienauto(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	ZmieniaAuto[playerid] = true;
	ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Wybierz typ pojazdu", "> Samochody \n> Motory/Rowery ", "Dalej", "Anuluj");

	return 1;
}

CMD:tpdom(playerid, cmdtext[]){

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}

	new x=HouseID[playerid];

	SetPlayerPos(playerid,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
	SetPlayerInterior(playerid,0);

	return 1;
	
}

CMD:wejdz(playerid, cmdtext[]){

	new bool:bla;

	for(new x=0;x<HOUSES_LOOP;x++){
		if(IsPlayerInRangeOfPoint(playerid,5,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z])){

			if(!HouseInfo[x][hOpen] && strfind(PlayerName(playerid),HouseInfo[x][hOwner],true) == -1){
				SendClientMessage(playerid,COLOR_RED2,"Ten dom jest zamkniêty!");
				return 1;
			}

			SetPlayerInterior(playerid,HouseInfo[x][hInterior]);
			SetPlayerVirtualWorld(playerid,HouseInfo[x][hWorld]);
			SetPlayerPos(playerid,HouseInfo[x][hexit_x],HouseInfo[x][hexit_y],HouseInfo[x][hexit_z]);
			bla = false;

			SendClientMessage(playerid,COLOR_ORANGE,"Aby wyjœæ wpisz: /Wyjdz");

			break;
		}else{
			bla = true;
		}
	}

	if(bla) SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ przy wejœciu do ¿adnego domu!");

	return 1;
}

CMD:zobaczdom(playerid, cmdtext[]){

	new bool:bla;

	for(new x=0;x<HOUSES_LOOP;x++){
		if(IsPlayerInRangeOfPoint(playerid,5,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z])){

			if(strlen(HouseInfo[x][hOwner]) >= 3){
				SendClientMessage(playerid,COLOR_RED2,"Ten dom jest zajêty i nie mo¿na go ogl¹daæ!");
				return 1;
			}

			SetPlayerInterior(playerid,HouseInfo[x][hInterior]);
			SetPlayerVirtualWorld(playerid,HouseInfo[x][hWorld]);
			SetPlayerPos(playerid,HouseInfo[x][hexit_x],HouseInfo[x][hexit_y],HouseInfo[x][hexit_z]);
			bla = false;

			SendClientMessage(playerid,COLOR_ORANGE,"Masz 15 sek. no obejrzenie domu!");
			KillTimer(DomTimer[playerid]);
			DomTimer[playerid] = SetTimerEx("DomKoniecOgladania",15000,0,"ii",playerid,x);

			break;
		}else{
			bla = true;
		}
	}

	if(bla) SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ przy wejœciu do ¿adnego domu!");

	return 1;
}

CMD:wyjdz(playerid, cmdtext[]){

	new bool:bla;

	for(new x=0;x<HOUSES_LOOP;x++){
		if(IsPlayerInRangeOfPoint(playerid,5,HouseInfo[x][hexit_x],HouseInfo[x][hexit_y],HouseInfo[x][hexit_z]) && GetPlayerVirtualWorld(playerid) == HouseInfo[x][hWorld]){

			SetPlayerPos(playerid,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
			SetPlayerInterior(playerid,0);
			SetTimerEx("HouseWorld",2000,0,"i",playerid);
			bla = false;
			break;
		}else{
			bla = true;
		}
	}

	if(bla) SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ przy wyjœciu z domu!");

	return 1;

}

CMD:dompomoc(playerid, cmdtext[]){

	new string[500];

	strcat(string,"* /KupDom  - kupujesz dom \n");
	strcat(string,"* /ZobaczDom  - ogladasz dom od srodka przed kupnem \n");
	strcat(string,"* /SprzedajDom  - sprzedajesz swój dom \n");
	strcat(string,"* /ZamknijDom  - zamykasz dom \n");
	strcat(string,"* /OtworzDom  - otwierasz dom \n");
	strcat(string,"* /AutoDom  - przywolujesz swoje auto przed dom \n");
	strcat(string,"* /ZmienAuto  - zmieniasz auto domowe \n");
	strcat(string,"* /TPdom  - teleport do domu\n");
	strcat(string,"* /Wejdz  - wchodzisz do domu\n");
	strcat(string,"* /Wyjdz - wychodzisz z domu\n\n\n");
	strcat(string,"__[ZARZADZANIE KONTEM DOMOWYM]__\n\n");
	strcat(string,"* /OplacDom [kwota]  - wplacasz na konto domowe respekt do oplacania czynszu\n");
	strcat(string,"* /WyplacDom [kwota]  - wyplacasz z konta domowego respekt\n");
	strcat(string,"* /StanKonta  - sprawdzasz stan konta domowego \n\n");
	strcat(string,"Czynsz jest pobierany nawet gdy nie grasz na serwerze!");

	ShowPlayerDialog(playerid,32,0,"Komendy zarzadzania domem",string,"Cofnij","Wyjdz");

	return 1;
	
}

CMD:kupdom(playerid, cmdtext[]){

	new bool:bla;

	if(MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Masz ju¿ jeden dom! Sprzedaj go jeœli chcesz kupiæ nowy");
		return 1;
	}

    if(TimePlay[playerid]<30)
	{
		SendClientMessage(playerid,COLOR_WHITE,"Aby kupiæ swój dom musisz graæ na serwerze conajmniej 30 minut! (Musisz byæ zarejestrowany)");
		return 1;
	}

	for(new x=0;x<HOUSES_LOOP;x++){
		if(IsPlayerInRangeOfPoint(playerid,5,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z])){

			if(strlen(HouseInfo[x][hOwner]) >= 3){
				SendClientMessage(playerid,COLOR_RED2,"Ten dom jest ju¿ zajêty przez kogoœ!");
				return 1;
			}

			if(Respekt[playerid] >= HouseInfo[x][hCost]){
				new str[128];
				SendClientMessage(playerid,COLOR_LIST,"");
				SendClientMessage(playerid,COLOR_LIST,"___________________________________________________________");
				format(str,sizeof(str),"Gratulacje kupi³eœ(aœ) swój w³asny dom (czynsz: %d Exp na dzieñ)",HouseInfo[x][hCost]);
				SendClientMessage(playerid,COLOR_GREEN,str);
				SendClientMessage(playerid,COLOR_GREEN,"Aby zobaczyæ komendy do twojego domu wpisz: /DomPomoc");
				SendClientMessage(playerid,COLOR_LIST,"___________________________________________________________");


				foreachPly (i) {
					RemovePlayerMapIcon(i, x);
					SetPlayerMapIcon(i, x, HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z], 32,0);
				}

				RemovePlayerMapIcon(playerid, x);
				SetPlayerMapIcon(playerid, x, HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z], 35,0);
				DestroyPickup(HouseInfo[x][hPick]);
				HouseInfo[x][hPick] = CreatePickup(1272,2,HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z]);
				PlayerPlaySound(playerid, 1183, 0, 0, 0);
				SetTimerEx("SoundOff",5500,0,"i",playerid);

				MaDom[playerid] = true;
				format(HouseInfo[x][hOwner],MAX_PLAYER_NAME,"%s",PlayerName(playerid));
				wykorzystanyrespekt[playerid] += HouseInfo[x][hCost];
				Respekt[playerid] -= HouseInfo[x][hCost];
				HouseInfo[x][hOpen] = false;
				HouseID[playerid] = x;

				format(str,sizeof(str),"Dom gracza: \n%s\nID: %d",HouseInfo[x][hOwner],x);
				Update3DTextLabelText(HouseInfo[x][hLabel],0xFF8040FF, str);
				bla = false;

				PlayerPlaySound(playerid, 1057, 0, 0, 0);

				house_Update(x,2,HouseInfo[x][hOwner]);

			}else{
				SendClientMessage(playerid,COLOR_RED2,"Nie masz tyle exp!");
				bla = false;
			}

			break;
		}else{
			bla = true;
		}
	}

	if(bla){
		SendClientMessage(playerid,COLOR_RED2,"Nie stoisz przy ¿adnym domu do kupienia!");
		SendClientMessage(playerid,COLOR_ORANGE,"Jeœli nie wiesz gdzie mo¿na kupiæ dom, teleportuj sie: /Osiedle(1-5)");
	}

	return 1;
	
}

CMD:sprzedajdom(playerid, cmdtext[]){

	if(!logged[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Najpierw zaloguj siê na swoje konto!");
		return 1;
	}

	if(!MaDom[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Nie masz w³asnego domu!");
		return 1;
	}
	new bool:bla;

	for(new x=0;x<HOUSES_LOOP;x++){
		if(strfind(PlayerName(playerid),HouseInfo[x][hOwner],true)==0){

			new str[128];
			format(str,sizeof(str),"Sprzeda³eœ(aœ) swój dom i odzyska³eœ(aœ) 1 dzienny czynsz domowy (%d pkt. exp)",HouseInfo[x][hCost]);
			SendClientMessage(playerid,COLOR_GREEN,str);

			Respekt[playerid] += HouseInfo[playerid][hCost];
			HouseInfo[x][hBudget] = 0;
			wykorzystanyrespekt[playerid] -= HouseInfo[x][hBudget];

			format(str,sizeof(str),"Dom na sprzeda¿\n%d Exp na dzieñ\nID: %d",HouseInfo[x][hCost], x);
			Update3DTextLabelText(HouseInfo[x][hLabel],0xFFB400FF, str);

			foreachPly (i) {

            RemovePlayerMapIcon(i, x);
			SetPlayerMapIcon(i, x, HouseInfo[x][henter_x],HouseInfo[x][henter_y],HouseInfo[x][henter_z], 31,0);

			house_Update(x,2," ");
			house_Update(x,8,"0");

			PlayerPlaySound(playerid, 1057, 0, 0, 0);

			HouseInfo[x][hOpen] = false;
			HouseID[playerid] = -1;
			bla = true;

			strdel(HouseInfo[x][hOwner],0,MAX_PLAYER_NAME);
			MaDom[playerid] = false;
			break;
		}
	}

	}
	if(!bla) SendClientMessage(playerid,COLOR_RED2,"Twój nick nie pasuje do ¿adnego domu!");

	return 1;
	
}

CMD:delweapons(playerid, cmdtext[]){

	PlayerWeapon[playerid][0] = 0;
	PlayerWeapon[playerid][1] = 0;
	PlayerWeapon[playerid][2] = 0;
	PlayerWeaponAmmo[playerid][0] = 0;
	PlayerWeaponAmmo[playerid][1] = 0;
	PlayerWeaponAmmo[playerid][2] = 0;

	SendClientMessage(playerid,COLOR_GREEN,"Twoje stale bronie zostaly usuniete!");
	return 1;
	
}

CMD:buyweapon(playerid, cmdtext[]){

	new bron;
	if(sscanf(cmdtext,"u",bron)){
	    SendClientMessage(playerid, COLOR_WHITE, "WPISZ /BuyWeapon [idbroni]");
		return 1;
	}

	if(GetPlayerMoney(playerid) < weaponCost[bron]) {
		SendClientMessage(playerid, COLOR_RED, "Nie masz wystarczajacych pieniedzy!");
		return 1;
	}
	if(bron < 0 || bron > 6){
		SendClientMessage(playerid, COLOR_RED, "Zle ID broni!");
        SendClientMessage(playerid, COLOR_RED, "1 - Kastet");
        SendClientMessage(playerid, COLOR_RED, "2 - Kij Golfowy");
        SendClientMessage(playerid, COLOR_RED, "3 - Pa³ka Policyjna");
        SendClientMessage(playerid, COLOR_RED, "4 - Nó¿");
        SendClientMessage(playerid, COLOR_RED, "5 - BasketBall");
        SendClientMessage(playerid, COLOR_RED, "6 - £opata");
		return 1;
	}

	new tmp[128];
	format (tmp, sizeof(tmp), "Kupiles(as) %s bron, ktora bedzie dostepna przez caly czas gry, nawet po smierci...",weaponNames[bron]);
	SendClientMessage(playerid, COLOR_GREEN, tmp);

	GivePlayerWeapon(playerid, weaponIDs[bron], weaponAmmo[bron]);

	if(bron == 0 || bron == 1){
		PlayerWeapon[playerid][0] = weaponIDs[bron];
		PlayerWeaponAmmo[playerid][0] += weaponAmmo[bron];
	}

	if(bron == 2 || bron == 3 || bron == 4){
		PlayerWeapon[playerid][1] = weaponIDs[bron];
		PlayerWeaponAmmo[playerid][1] += weaponAmmo[bron];
	}

	if(bron == 5 || bron == 6){
		PlayerWeapon[playerid][2] = weaponIDs[bron];
		PlayerWeaponAmmo[playerid][2] += weaponAmmo[bron];
	}

	GivePlayerMoney(playerid, 0-weaponCost[bron]);
	Money[playerid] -= weaponCost[bron];

	return 1;
}

CMD:weapons(playerid, cmdtext[]){
	new string[64];
	SendClientMessage(playerid, COLOR_GREEN, "Lista broni do kupienia na stale:");
	for(new i = 0; i < MAX_WEAPONS; i++) {
		format (string, sizeof(string), "%d. %s - $%d",i,weaponNames[i],weaponCost[i]);
		SendClientMessage(playerid, COLOR_YELLOW, string);
	}
	return 1;
	
}

CMD:rcmd(playerid, cmdtext[]){

	new string[256];

	strcat(string,"/rKasa - dostajesz $500 000  (20 exp)\n");
	strcat(string,"/rZabojstwa - dostajesz 10 zabojstwa (30 exp)\n");
	strcat(string,"/rZestaw - dostajesz MEGA zestaw broni (50 exp)\n");
	strcat(string,"/rInvisible - niewidzialnosc na mapie (15 exp)\n");
	strcat(string,"/rMiotacz - Miotacz ognia (100 exp)\n");

	ShowPlayerDialog(playerid,22,0,"CMD> Respekt",string,"OK","OK");

	return 1;
	
}

CMD:rkasa(playerid, cmdtext[]){
	if (Respekt[playerid] >= 20) {

		Respekt[playerid] -= 20;
		wykorzystanyrespekt[playerid] += 20;
		GivePlayerMoney(playerid,50000);
		Money[playerid] += 5000000;
		SendClientMessage(playerid,COLOR_ORANGE,"Dodales(as) sobie $50 00000 kosztem 20 exp");

	} else { SendClientMessage(playerid, COLOR_RED, "Nie masz tyle exp!");
	}
	return 1;
	
}

CMD:rmiotacz(playerid, cmdtext[]){
	if (Respekt[playerid] >= 100) {

		Respekt[playerid] -= 100;
		wykorzystanyrespekt[playerid] += 100;
			GivePlayerWeapon(playerid,37,2000);
		SendClientMessage(playerid,COLOR_ORANGE,"Doda³eœ(aœ) sobie miotacz ognia za 100 exp");

	} else { SendClientMessage(playerid, COLOR_RED, "Nie masz tyle exp!");
	}
	return 1;
	
}

CMD:rzabojstwa(playerid, cmdtext[]){
	if (Respekt[playerid] >= 30) {
		Respekt[playerid] -= 30;
		kills[playerid] += 10;
		SendClientMessage(playerid,COLOR_GREEN,"Kupiles(as) 10 zabojstw!");

		wykorzystanyrespekt[playerid] += 30;
	} else {
	SendClientMessage(playerid, COLOR_RED, "Nie masz tyle exp!"); }

	return 1;
}

CMD:rzestaw(playerid, cmdtext[]){
	if (Respekt[playerid] >= 50) {
		SetPlayerArmour(playerid, 100);
		SetPlayerHealth(playerid, 100);
		GivePlayerWeapon(playerid, 4, 1);
		GivePlayerWeapon(playerid, 29, 1000);
		GivePlayerWeapon(playerid, 27, 1000);
		GivePlayerWeapon(playerid, 24, 9999);
		GivePlayerWeapon(playerid, 31, 9999);
		GivePlayerWeapon(playerid, 34, 9999);
		Respekt[playerid] -= 50;
		SendClientMessage(playerid,COLOR_GREEN,"Kupiles(as) MEGA zestaw broni!");

		wykorzystanyrespekt[playerid] += 50;
	}else{
	SendClientMessage(playerid, COLOR_RED, "Nie masz tyle exp!"); }
	return 1;
	
}

CMD:rinvisible(playerid, cmdtext[]){
	if (Respekt[playerid] >= 15) {

		SetPlayerColor(playerid,0xFFFFFF00);
		Invisible[playerid] = true;
		Respekt[playerid] -= 15;
		SendClientMessage(playerid,COLOR_GREEN,"Kupiles(as) niewidzialnosc na mapie!");
		SendClientMessage(playerid,COLOR_GREEN,"Aby wy³¹czyæ niewidzialnoœæ wpisz: /visible");

		wykorzystanyrespekt[playerid] += 15;
	}else{
	SendClientMessage(playerid, COLOR_RED, "Nie masz tyle exp!"); }
	return 1;
	
}


CMD:fopen(playerid, cmdtext[]){

	if(GetPlayerVirtualWorld(playerid) != 0){
	    SendClientMessage(playerid,COLOR_RED2,"Nie mo¿esz teraz otwieraæ fortecy!");
		return 1;
	}

	//if(IsPlayerInCheckpoint(playerid) == 0 || getCheckpointType(playerid) != CP_FORTECA) {
	//	SendClientMessage(playerid, COLOR_RED2, "Musisz byæ w czerwonym punkcie aby otwieraæ bramê!");
	//	return 1;
	//}

	MoveObject(FortecaBrama,-1176.4272, -939.781, 124.9171, 3);
	SendClientMessage(playerid,COLOR_GREEN,"Forteca otwarta!");

	return 1;
	
}

CMD:fclose(playerid, cmdtext[]){

	if(GetPlayerVirtualWorld(playerid) != 0){
	    SendClientMessage(playerid,COLOR_RED2,"Nie mo¿esz teraz zamykaæ fortecy!");
		return 1;
	}

	//if(IsPlayerInCheckpoint(playerid) == 0 || getCheckpointType(playerid) != CP_FORTECA) {
	//	SendClientMessage(playerid, COLOR_RED2, "Musisz byæ w czerwonym punkcie aby zamykaæ bramê!");
	//	return 1;
	//}

	MoveObject(FortecaBrama,-1176.4401, -939.7877, 130.3673, 3);
	SendClientMessage(playerid,COLOR_GREEN,"Forteca zamkniêta!");

	return 1;
}

SetServerDataInt (field[], value) {
	new buffer[80];
	format (buffer, sizeof (buffer), "update fg_stats set ovalue = %d where name = '%s';", value, field);
	mysql_query (buffer);
}
	

GetServerData (field[]) {
	new buffer[80], result[32];
	format (buffer, sizeof (buffer), "select ovalue from fg_stats where name = '%s' limit 1;", field);
	mysql_query (buffer);
	mysql_store_result ();
	mysql_fetch_row (result);
	mysql_free_result ();
	return result;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(IsAdmin(playerid,2))
		return SetPlayerPosFindZ(playerid, fX, fY, fZ+10);
	return 1;
}