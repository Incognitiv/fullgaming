// atrakcje serwera

/*------------------*/
/*		 WG			*/
/*------------------*/
new WG_Off, WG_Zapisanych, WG_Trwa, WG_Team[2], WG_Timer, WG_Odliczanie = -1;
new Float:PozycjeWG[6], Float:WG_Dystans[3];
new IntWG;
/*------------------*/
/*		SIANO		*/
/*------------------*/
new HAY_Off, HAY_Trwa, HAY_Timer, HAY_Zapisanych, HAY_Odliczanie = -1, Iterator:HAY_Array<25>;

/*------------------*/
/*		CHOWANY		*/
/*------------------*/
new CH_Off, CH_Trwa, CH_Timer, CH_Zapisanych, CH_Szukajacy, CH_Odliczanie = -1;
new Float:PozycjeCH[6];
new IntCH;
/*------------------*/
/*		TOWER		*/
/*------------------*/
new TW_Off, TW_Trwa, TW_Timer, TW_Zapisanych, TW_Odliczanie = -1, TW_Checkpoint, TW_Tick;
/*------------------*/
/*		SKOKI		*/
/*------------------*/
new SS_Off, SS_Trwa, SS_Timer, SS_Zapisanych, SS_Odliczanie = -1;
new Float:PozycjeSS[6] = {0.0, ...}, SS_CP;
/*------------------*/
/*		Wyœcigi		*/
/*------------------*/

#define DIALOG_RACE_SELECT 15560
#define DIALOG_RACE_INFO 15561
#define DIALOG_RACE_MAIN 15562

#define MAX_RACE 20
enum RaceEnum
{
	Rname[40],
	Rid,
	Rall_cp,
    Rcp,
	Rmodelid,
	Float:Rx,
	Float:Ry,
	Float:Rz,
	Float:Rr
}
new RaceInfo[MAX_RACE][RaceEnum];
new RacesCount = 0;

/*------------------*/
/*		Truck		*/
/*------------------*/

#define DIALOG_INFO 15500
#define DIALOG_TRUCK_WPROWADZENIE 15550
#define DIALOG_TRUCK_NOWEZLECENIE 15551
#define DIALOG_TRUCK_ZALADUNEK 15552

new TruckItems[25][] = {
	"Owoce", "Alkohol", "Narkotyki", "Gruz", "Odpady", "Kartony", "Sprzêt RTV", "Art. Spo¿ywcze", "Sprzêt AGB",
	"Sprzêt sportowy", "Waciki", "Kosmetyki", "Odzie¿", "Zwierzêta", "S³odycze", "Meble", "Szk³o", "Art. Budowlane",
	"Dostawê TESCO", "Dostawê Bierdonki", "Zabawki dzieciêce", "Art. Tytoniowe", "Murzynów", "Art. Medyczne", "Art. Szkolne"
};
#define MAX_TRUCK 20
enum TruckEnum
{
	Tid,
	Tcp,
	Float:Tx,
	Float:Ty,
	Float:Tz
}
new TruckInfo[MAX_TRUCK][TruckEnum];
new TrucksCount;
new Text3D:truckLabel[MAX_GRACZY];

/*------------------*/
/*		Derby		*/
/*------------------*/
new DD_Off, DD_InCar, DD_Trwa, DD_Timer, DD_Zapisanych, DD_Odliczanie = -1, DD_Vehicles[14] = {-1, ...};

// koniec atrakcji serwera
new pAttraction[MAX_GRACZY];

/*-------------
	   WG
 *-------------*/

CMD:wg(playerid, params[]) 
{
	if(WG_Trwa == 1) return SendClientMessage(playerid, -1, " *** WG ju¿ wystartowa³o!");
	if(WG_Off == 1) return SendClientMessage(playerid, -1, " *** Ta atrakcja jest tymczasowo wy³¹czona.");
	
	if(GetPVarInt(playerid, "pZapisanyWG") == 1) 
	{
		SetPVarInt(playerid, "pZapisanyWG", 0);
		SendClientMessage(playerid, -1, " {7FC7AF}Wypisa³eœ siê z {3FB8AF}WG{7FC7AF}.");
		WG_Zapisanych--;
	}
	else
	{
		SetPVarInt(playerid, "pZapisanyWG", 1);
		SendClientMessage(playerid, -1, " {3FB8AF}Zapisa³eœ siê na {7FC7AF}WG{3FB8AF}!");
		WG_Zapisanych++;
	}
	UpdateAttractionTD();
	
	if(WG_Odliczanie == -1 && WG_Zapisanych >= 2) 
	{
		SendClientMessageToAll(-1, " {7FC7AF}Wojna Gangów {3FB8AF}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		//SendClientMessageToAll(-1, " Wojna Gangów {FF0000}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		WG_Odliczanie = SetTimer("WG_Start", 20*1000, 0);
	}
	return 1;
}

stock WG_ClearVars(playerid)
{
	SetPVarInt(playerid, "pZapisanyHAY", 0);
	SetPVarInt(playerid, "pZapisanyCH", 0);
	SetPVarInt(playerid, "pZapisanySS", 0);
	SetPVarInt(playerid, "pZapisanyDD", 0);
	SetPVarInt(playerid, "pZapisanyTW", 0);
	return 1;
}

forward WG_Start();
public WG_Start() 
{
	WG_Timer = SetTimer("WG_End", 240000, 0);
	mysql_query("SELECT bx, bpy, bz, rx, ry, rz, interior FROM wg_areny ORDER BY RAND() LIMIT 1;");
	mysql_store_result();
	new buffer[200];
	mysql_fetch_row(buffer, "|");
	sscanf(buffer, "p<|>ffffffi", PozycjeWG[0],PozycjeWG[1],PozycjeWG[2],PozycjeWG[3],PozycjeWG[4],PozycjeWG[5], IntWG);
	mysql_free_result();
	WG_Zapisanych = 0;
	WG_Odliczanie = -1;
	WG_Team[0] = 0;
	WG_Team[1] = 0;
	
	WG_Dystans[1] = (PozycjeWG[0] + PozycjeWG[3]) / 2;
	WG_Dystans[2] = (PozycjeWG[1] + PozycjeWG[4]) / 2;
	WG_Dystans[0] = PointToPoint(WG_Dystans[1],WG_Dystans[2], PozycjeWG[0],PozycjeWG[1]) + 150;
	
	new team;
	foreachPly(i) 
	{
		if(pAttraction[i] == 1 || IsPlayerAFK(i) == 1) 
		{
			SetPVarInt(i, "pZapisanyWG", 0);
			continue;
		}
		if(GetPVarInt(i, "pZapisanyWG") == 1 && pAttraction[i] == 0) 
		{
			WG_ClearVars(i);
			
			new Float:flopos[3];
			GetPlayerPos(i, flopos[0], flopos[1], flopos[2]);
			SetPVarFloat(i, "floX", flopos[0]);
			SetPVarFloat(i, "floY", flopos[1]);
			SetPVarFloat(i, "floZ", flopos[2]);
			
			SetPVarInt(i, "floInt", GetPlayerInterior(i));
			SetPVarInt(i, "floVW", GetPlayerVirtualWorld(i));
			if(!team) 
			{
				SetPlayerPos(i, PozycjeWG[0]+random(3-1),PozycjeWG[1]+random(3-1),PozycjeWG[2]);
				SetPlayerTeam(i, 10);
				SetPlayerColor(i, 0xDD0000FF);
				WG_Team[team]++;
				team = 1;
			} 
			else 
			{
				SetPlayerPos(i, PozycjeWG[3]+random(3-1),PozycjeWG[4]+random(3-1),PozycjeWG[5]);
				SetPlayerTeam(i, 11);
				SetPlayerColor(i, 0x0000DDFF);
				WG_Team[team]++;
				team = 0;
			}

			SetPlayerInterior(i, IntWG);
			SetPlayerHealth(i, 100.0);
			SetPlayerArmour(i, 100.0);
			TogglePlayerControllable(i, true);
			ResetPlayerWeapons(i);
			SetPlayerVirtualWorld(i, VW_WG);
			pAttraction[i] = 1;
			GivePlayerWeapon(i, 16, 1);
			GivePlayerWeapon(i, 24, 200);
			GivePlayerWeapon(i, 27, 200);
			GivePlayerWeapon(i, 29, 200);
			GivePlayerWeapon(i, 31, 200);
			GivePlayerWeapon(i, 34, 200);
			WG_Zapisanych++;

		} else SetPVarInt(i, "pZapisanyWG", 0);

	}
    WG_Trwa = 1;
	if(WG_Zapisanych < 2)
	{
	    KillTimer(WG_Timer);
	    WG_End();
		return 1;
	}
	
	UpdateAttractionTD();
	return 1;
}

forward WG_End();
public WG_End()
{
	if(WG_Zapisanych >= 3)
	{
		if(WG_Team[0] < WG_Team[1])
		{
			SendClientMessageToAll(-1,"{7FC7AF}Wojna Gangów {3FB8AF}zakoñczona. Wygra³a dru¿yna {7FC7AF}czerwonych.");
			foreachPly(i)
			{
				if(GetPlayerTeam(i) == 11)
				{
					//SendClientMessageToAll(-1,"{7FC7AF}Wojna Gangów {3FB8AF}zakoñczona.");
					SendClientMessage(i, 0xDD0000FF, " Twoja dru¿yna wygra³a WG! Otrzymujesz {23A7FF}15 exp i $15000");
					Money[i] += 15000;
					Respekt[i] += 15;
				}
			}
		}
		else
		{
			SendClientMessageToAll(-1,"{7FC7AF}Wojna Gangów {3FB8AF}zakoñczona. Wygra³a dru¿yna {7FC7AF}niebieskich.");
			foreachPly(i)
			{
				if(GetPlayerTeam(i) == 10)
				{	 
					SendClientMessage(i, 0xDD0000FF, " Twoja dru¿yna wygra³a WG! Otrzymujesz {23A7FF}15 exp i $15000");
					Respekt[i] += 15;
					Money[i] += 15000;
				}
			}
		}
	}

	foreachPly(i)
	{
		if(GetPVarInt(i, "pZapisanyWG") == 1 && pAttraction[i] == 1)
		{
			SetPVarInt(i, "pZapisanyWG", 0);
			ResetPlayerWeapons(i);
			OdstawGracza(i);
			pAttraction[i] = 0;
		}
	}


	WG_Trwa = 0;
	WG_Zapisanych = 0;
	WG_Team[0] = 0;
	WG_Team[1] = 0;
	WG_Timer = -1;
	WG_Odliczanie = -1;

	UpdateAttractionTD();
	return 1;
}

/*-------------
	 CHOWANY
 *-------------*/
 
CMD:ch(playerid, params[]) return cmd_chowany(playerid, params);
CMD:chowany(playerid, params[])
{
	if(CH_Trwa == 1)
	    return SCM(playerid, -1, " *** Chowany juz wystartowa³!");

	if(CH_Off == 1)
		return SCM(playerid, -1, " *** Ta zabawa jest tymczasowo wy³¹czona.");


	if(GetPVarInt(playerid, "pZapisanyCH") == 1)
	{
		SetPVarInt(playerid, "pZapisanyCH", 0);
		SCM(playerid, -1," {7FC7AF}Wypisa³eœ siê z {3FB8AF}Chowanego{7FC7AF}!");
		CH_Zapisanych--;
	}else{
		SetPVarInt(playerid, "pZapisanyCH", 1);
		CH_Zapisanych++;
		SCM(playerid, -1," {3FB8AF}Zapisa³eœ siê na {7FC7AF}Chowanego{3FB8AF}!");
	}
	UpdateAttractionTD();

	if(CH_Odliczanie == -1 && CH_Zapisanych >= 4)
	{
		SendClientMessageToAll(-1, " {7FC7AF}Chowany {3FB8AF}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		CH_Odliczanie = SetTimer("CH_Start", 20000, 0);
	}
	return 1;
}

stock CH_ClearVars(playerid)
{
	SetPVarInt(playerid, "pZapisanyHAY", 0);
	SetPVarInt(playerid, "pZapisanySS", 0);
	SetPVarInt(playerid, "pZapisanyWG", 0);
	SetPVarInt(playerid, "pZapisanyDD", 0);
	SetPVarInt(playerid, "pZapisanyTW", 0);
	return 1;
}

new Iterator:CH_Array<MAX_GRACZY>;

forward CH_Start();
public CH_Start()
{
	CH_Trwa = 1;
	CH_Timer = SetTimer("CH_End", 120000, 0);
	mysql_query("SELECT x, y, z, sx, sy, sz, interior FROM ch_areny ORDER BY RAND() LIMIT 1;");
	mysql_store_result();
	new buffer[200];
	mysql_fetch_row(buffer, "|");
	sscanf(buffer, "p<|>ffffffi", PozycjeCH[0],PozycjeCH[1],PozycjeCH[2],PozycjeCH[3],PozycjeCH[4],PozycjeCH[5], IntCH);
	mysql_free_result();
	CH_Odliczanie = -1;
	CH_Zapisanych = 0;

	Iter_Clear(CH_Array);

	foreachPly(i)
	{
		if(IsPlayerAFK(i) == 0 && pAttraction[i] == 0 && GetPVarInt(i, "pZapisanyCH") == 1)
	    {
	        Iter_Add(CH_Array, i);
		}
	}
	CH_Szukajacy = Iter_Random(CH_Array);

	foreachPly(i)
	{
	    if(pAttraction[i] == 1 || IsPlayerAFK(i) == 1) SetPVarInt(i, "pZapisanyCH", 0);

	    if(GetPVarInt(i, "pZapisanyCH") == 1)
	    {
			new Float:flo[3];
			GetPlayerPos(i, flo[0],flo[1],flo[2]);
			SetPVarFloat(i, "floX", flo[0]);
			SetPVarFloat(i, "floY", flo[1]);
			SetPVarFloat(i, "floZ", flo[2]);
			SetPVarInt(i, "floInt", GetPlayerInterior(i));
			SetPVarInt(i, "floVW", GetPlayerVirtualWorld(i));

			SetPlayerArmedWeapon(i, 0);
	        ResetPlayerWeapons(i);
	        TogglePlayerControllable(i, 1);
	        SetPlayerVirtualWorld(i, VW_CHOWANY);
	        CH_ClearVars(i);
	        SetPlayerTeam(i, NO_TEAM);
	        pAttraction[i] = 1;
			SetPlayerInterior(i, IntCH);
 			if(CH_Szukajacy == i)
			{
			    SetPlayerColor(i, 0x00000000);
			    SetPlayerArmour(i, 100.0);
			    SetPlayerPos(i, PozycjeCH[3],PozycjeCH[4],PozycjeCH[5]);
				GivePlayerWeapon(i, 38, 0xffff);
				SetPlayerHealth(i, 10000.0);
				TogglePlayerControllable(i, 0);
				SendClientMessage(i, -1, " *** {FF00FF}Za 20 sekund mo¿esz zacz¹æ szukaæ!");
				SetTimerEx("ControlOn", 20000, 0, !"i", i);
			}else{
			    SetPlayerPos(i, PozycjeCH[0],PozycjeCH[1],PozycjeCH[2]);
				SetPlayerColor(i, 0x77777700);
				SetPlayerArmour(i, 0.0);
				SetPlayerHealth(i, 100.0);
			}
			CH_Zapisanych++;
		}
	}

	if(CH_Zapisanych < 2)
	{
	    KillTimer(CH_Timer);
	    CH_End();
		return 1;
	}
	UpdateAttractionTD();
	return 1;
}

forward CH_End();
public CH_End()
{
	CH_Trwa = 0;
	CH_Timer = -1;
	CH_Odliczanie = -1;

	foreachPly(i)
	{
		if(GetPVarInt(i, "pZapisanyCH") == 1)
		{
			SetPVarInt(i, "pZapisanyCH", 0);
			pAttraction[i] = 0;
			ResetPlayerWeapons(i);
			OdstawGracza(i);
			SetPlayerVirtualWorld(i, 0);
			SetPlayerInterior(i, 0);
			Respekt[i] += 20;
			Money[i] += 15000;
			if(CH_Szukajacy != i)
			{
				//SendClientMessageToAll(-1,"{7FC7AF}Chowany {3FB8AF}zakoñczony - szukaj¹cy poniós³ klêskê.");
				SendClientMessage(i, 0xDD0000FF, " {3FB8AF}Prze¿y³eœ na chowanym! Dostajesz {7FC7AF}20 exp i $15000{3FB8AF}!");
			}
			SetPlayerInterior(i, 0);
		}
	}
	if(CH_Zapisanych <= 1)
	{
		//SendClientMessageToAll(-1,"{7FC7AF}Chowany {3FB8AF}zakoñczony - nikt nie prze¿y³.");
		Respekt[CH_Szukajacy] += 25;
	    Money[CH_Szukajacy] += 15000;
	    SendClientMessage(CH_Szukajacy, 0xDD0000FF, " {3FB8AF}Zabi³eœ wszystkich na chowanym! Dostajesz {7FC7AF}25 exp i $15000{3FB8AF}!");
	}
	CH_Zapisanych = 0;
	CH_Szukajacy = -1;
	UpdateAttractionTD();
	return 1;
}

/*-------------
	 DERBY
 *-------------*/
 
CMD:dd(playerid, params[]) return cmd_derby(playerid, params);
CMD:derby(playerid, params[]) 
{
	if(DD_Trwa == 1) return SendClientMessage(playerid, -1, " *** Derby ju¿ wystartowa³y!");
	if(DD_Off == 1) return SendClientMessage(playerid, -1, " *** Ta atrakcja jest tymczasowo wy³¹czona.");
	
	if(GetPVarInt(playerid, "pZapisanyDD") == 1) 
	{
		SetPVarInt(playerid, "pZapisanyDD", 0);
		SendClientMessage(playerid, -1, " {7FC7AF}Wypisa³eœ siê z {3FB8AF}Derby{7FC7AF}.");
		DD_Zapisanych--;
	}
	else
	{
		SetPVarInt(playerid, "pZapisanyDD", 1);
		SendClientMessage(playerid, -1, " {3FB8AF}Zapisa³eœ siê na {7FC7AF}Derby{3FB8AF}!");
		DD_Zapisanych++;
	}
	UpdateAttractionTD();
	
	if(DD_Odliczanie == -1 && DD_Zapisanych >= 4) 
	{
		SendClientMessageToAll(-1, " {7FC7AF}Derby {3FB8AF}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		//SendClientMessageToAll(-1, " Derby {FF0000}wystartuj¹ za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		DD_Odliczanie = SetTimer("DD_Start", 20*1000, 0);
	}
	
	if(DD_Zapisanych >= 14 && DD_Odliczanie != -1) 
	{
		KillTimer(DD_Zapisanych);
		DD_Start();
	}
	return 1;
}

stock DD_ClearVars(playerid)
{
	SetPVarInt(playerid, "pZapisanyHAY", 0);
	SetPVarInt(playerid, "pZapisanyCH", 0);
	SetPVarInt(playerid, "pZapisanySS", 0);
	SetPVarInt(playerid, "pZapisanyWG", 0);
	SetPVarInt(playerid, "pZapisanyTW", 0);
	//SetPVarInt(playerid, "pZapisanyHAY", 0);
	return 1;
}

forward DD_Start();
public DD_Start() 
{
	DD_Odliczanie = -1;
	DD_Timer = SetTimer("DD_End", 360000, 0);
	DD_Zapisanych = 0;
	DD_InCar = 0;
	
	foreachPly(i) 
	{
		if(pAttraction[i] == 1 || IsPlayerAFK(i) == 1) SetPVarInt(i, "pZapisanyDD", 0);
		if(GetPVarInt(i, "pZapisanyDD") && pAttraction[i] == 0) 
		{
			new Float:flo[3];
			GetPlayerPos(i, flo[0],flo[1],flo[2]);
			SetPVarFloat(i, "floX", flo[0]);
			SetPVarFloat(i, "floY", flo[1]);
			SetPVarFloat(i, "floZ", flo[2]);
			SetPVarInt(i, "floInt", GetPlayerInterior(i));
			SetPVarInt(i, "floVW", GetPlayerVirtualWorld(i));

	        pAttraction[i] = 1;
	        DD_ClearVars(i);
	        SetPlayerVirtualWorld(i, VW_DERBY);
			SetPlayerInterior(i, 0);
			SetPlayerDrunkLevel(i, 0);
			SetPlayerHealth(i, 100.0);
			ResetPlayerWeapons(i);
			SetPlayerPos(i, -1041.93, 614.23, 140.48);
			TogglePlayerControllable(i, false);

			DD_Zapisanych++;
			AnnForPlayer(i, 3500, "~g~Wczytywanie...");
		}
	}
	DD_Trwa = 1;
	if(DD_Zapisanych <= 1)
	{
	    KillTimer(DD_Timer);
	    DD_End();
	    return 1;
	}
	UpdateAttractionTD();
	SetTimer("DD_Teleport", 4000, 0);
	return 1;
}

forward DD_Teleport();
public DD_Teleport()
{
    for(new x; x < sizeof(DD_Vehicles); x++)
	{
	    SetVehicleToRespawn(DD_Vehicles[x]);
	}
	new spawn;
	foreachPly(i)
	{
		if(pAttraction[i] == 1 && GetPVarInt(i, "pZapisanyDD") == 1)
		{
			AnnForPlayer(i, 2000, "~g~~h~GO!");
			TogglePlayerControllable(i, true);
			SetVehicleParamsEx(DD_Vehicles[spawn], 1, 1, 0, 1, 0, 0, 1);
			PutPlayerInVehicle(i, DD_Vehicles[spawn], 0);
			SetVehicleHealth(DD_Vehicles[spawn], 99999.0);
			spawn++;
		}
	}
	DD_InCar = 1;
	return 1;
}
forward DD_End();
public DD_End()
{
	if(DD_Zapisanych==0)
	{
		SendClientMessageToAll(-1,"{7FC7AF}Derby {3FB8AF}zakoñczone - brak zwyciê¿cy.");
	}
    DD_Trwa = 0;
	DD_Timer = -1;
	DD_Zapisanych = 0;
	DD_Odliczanie = -1;

    foreachPly(i)
	{
		if(GetPVarInt(i, "pZapisanyDD") == 1 && pAttraction[i] == 1)
		{
			SetPVarInt(i, "pZapisanyDD", 0);
			pAttraction[i] = 0;
			OdstawGracza(i);
			//SendClientMessage(i, -1, " *** {3FB8AF}Nikt nie wygra³ {7FC7AF}Derby{3FB8AF}! Czas min¹³!");
		}
	}

	UpdateAttractionTD();
	return 1;
}
				
/*-------------
	 SKOKI
 *-------------*/

CMD:ss(playerid, params[]) return cmd_skoki(playerid, params);
CMD:skoki(playerid, params[])
{
	if(SS_Trwa == 1)
	    return SCM(playerid, -1, " *** Skoki spadochronowe juz wystartowa³y");

	if(SS_Off == 1)
		return SCM(playerid, -1, " *** Ta atrakcja jest tymczasowo wy³¹czona.");


	if(GetPVarInt(playerid, "pZapisanySS") == 1)
	{
		SetPVarInt(playerid, "pZapisanySS", 0);
		SCM(playerid, -1," {7FC7AF}Wypisa³eœ siê z {3FB8AF}Skoków Spadochronowych{7FC7AF}!");
		SS_Zapisanych--;
	}else{
		SetPVarInt(playerid, "pZapisanySS", 1);
		SS_Zapisanych++;
		SCM(playerid, -1,"{3FB8AF}Zapisa³eœ siê na {7FC7AF}Skoki Spadochronowe{3FB8AF}!");
	}
	UpdateAttractionTD();

	if(SS_Odliczanie == -1 && SS_Zapisanych >= 2)
	{
		SendClientMessageToAll(-1, " {7FC7AF}Skoki Spadochronowe {3FB8AF}wystartuj¹ za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		//SendClientMessageToAll(-1, " !");
		SS_Odliczanie = SetTimer("SS_Start", 20000, 0);
	}

	return 1;
}

CMD:c_ss(playerid,params[])
{
	if(!IsAdmin(playerid,3)) return 0;
	
	new type = strval(params);
	if(params[0] != '0' && params[0] != '1') {
		SCM(playerid, -1, "/c_ss 0 - zapisujesz pozycje graczy | /c_ss 1 zapisujesz pozycje mety");
		return SCM(playerid, -1, "U¿yj: /c_ss <val (0 - tp / 1 - tp)>");
	}
	if(type == 0)
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPVarFloat(playerid, "ss_x", x);
		SetPVarFloat(playerid, "ss_y", y);
		SetPVarFloat(playerid, "ss_z", z);
	}
	else {
		new buf[200];
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		format(buf, sizeof(buf), "INSERT INTO ss_aren (x,y,z,cpx,cpy,cpz) VALUES ('%.3f', '%.3f', '%.3f', '%.3f', '%.3f', '%.3f');", GetPVarFloat(playerid, "ss_x"), GetPVarFloat(playerid, "ss_y"), GetPVarFloat(playerid, "ss_z"), x, y, z);
		mysql_query(buf);
	}
	SCM(playerid, -1, "Doda³eœ arene.");
	return 1;
}

stock SS_ClearVars(playerid)
{
	SetPVarInt(playerid, "pZapisanyHAY", 0);
	SetPVarInt(playerid, "pZapisanyCH", 0);
	SetPVarInt(playerid, "pZapisanyWG", 0);
	SetPVarInt(playerid, "pZapisanyDD", 0);
	SetPVarInt(playerid, "pZapisanyTW", 0);
	return 1;
}

forward SS_Start();
public SS_Start()
{
	SS_Trwa = 1;
	SS_Timer = SetTimer("SS_End", 120000, 0);
	SS_Zapisanych = 0;

	mysql_query("SELECT x, y, z, cpx, cpy, cpz FROM ss_aren ORDER BY RAND() LIMIT 1;");
	mysql_store_result();
	new buffer[200];
	mysql_fetch_row(buffer, "|");
	sscanf(buffer, "p<|>ffffff", PozycjeSS[0],PozycjeSS[1],PozycjeSS[2],PozycjeSS[3],PozycjeSS[4],PozycjeSS[5]);
	mysql_free_result();
	
	SS_CP = CreateDynamicCP(PozycjeSS[3],PozycjeSS[4],PozycjeSS[5], 30.0, 22, -1, -1, 5000.0);

	foreachPly(i)
	{
	    if(pAttraction[i] == 1 || IsPlayerAFK(i) == 1) SetPVarInt(i, "pZapisanySS", 0);

	    if(GetPVarInt(i, "pZapisanySS") == 1 && pAttraction[i] == 0)
	    {
			new Float:flo[3];
			GetPlayerPos(i, flo[0],flo[1],flo[2]);
			SetPVarFloat(i, "floX", flo[0]);
			SetPVarFloat(i, "floY", flo[1]);
			SetPVarFloat(i, "floZ", flo[2]);
			SetPVarInt(i, "floInt", GetPlayerInterior(i));
			SetPVarInt(i, "floVW", GetPlayerVirtualWorld(i));

	        ResetPlayerWeapons(i);
	        SetPlayerVirtualWorld(i, VW_SS);
	        SetPlayerInterior(i, 0);
	        SetPlayerDrunkLevel(i, 0);
			pAttraction[i] = 1;
			SS_ClearVars(i);
			TogglePlayerControllable(i, 1);
		    SetPlayerPos(i, PozycjeSS[0] + random(2) - random(2),PozycjeSS[1] + random(2) - random(2), PozycjeSS[2]);

            TogglePlayerDynamicCP(i, SS_CP, 1);
			GivePlayerWeapon(i, 46, 1);
			SS_Zapisanych++;
		}
	}
	if(SS_Zapisanych <= 1)
	{
	    KillTimer(SS_Timer);
	    SS_End();
	    return 1;
	}

	UpdateAttractionTD();
	return 1;
}

forward SS_End();
public SS_End()
{
	if(SS_Zapisanych==0)
	{
		SendClientMessageToAll(-1,"{7FC7AF}Skoki spadochronowe {3FB8AF}zakoñczone - brak zwyciê¿cy.");
	}
	SS_Trwa = 0;
	SS_Timer = -1;
	SS_Zapisanych = 0;
	SS_Odliczanie = -1;
	
	DestroyDynamicCP(SS_CP);
	foreachPly(i)
	{
		if(GetPVarInt(i, "pZapisanySS") == 1 && pAttraction[i] == 1)
		{
			SetPVarInt(i, "pZapisanySS", 0);
			pAttraction[i] = 0;
			OdstawGracza(i);
			DisablePlayerCheckpoint(i);
			//SendClientMessage(i, -1, " ***{00AAFF}Nikt nie wygra³ Skoków! Czas min¹³!");
		}
	}

	UpdateAttractionTD();
	return 1;
}

/*-------------
	 TOWER
 *-------------*/

CMD:tw(playerid, params[]) return cmd_tower(playerid, params);
CMD:tower(playerid, params[])
{
	if(TW_Trwa == 1)
	    return SCM(playerid, -1, " *** Tower juz wystartowa³");

	if(TW_Off == 1)
		return SCM(playerid, -1, " *** Ta atrakcja jest tymczasowo wy³¹czona.");

	if(GetPVarInt(playerid, "pZapisanyTW") == 1)
	{
		SetPVarInt(playerid, "pZapisanyTW", 0);
		SCM(playerid, 0x00AAFFFF," {7FC7AF}Wypisa³eœ siê z {3FB8AF}Tower{7FC7AF}!");
		TW_Zapisanych--;
	}else{
		SetPVarInt(playerid, "pZapisanyTW", 1);
		TW_Zapisanych++;
		SCM(playerid, 0xDD0000FF," {3FB8AF}Zapisa³eœ siê na {7FC7AF}Tower{3FB8AF}!");
	}
	UpdateAttractionTD();

	if(TW_Odliczanie == -1 && TW_Zapisanych >= 2)
	{
		SendClientMessageToAll(-1, " {7FC7AF}Tower {3FB8AF}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		//SendClientMessageToAll(-1, " Tower {FF0000}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywac!");
		TW_Odliczanie = SetTimer("TW_Start", 20000, 0);
	}

	return 1;
}

stock TW_ClearVars(i)
{
	SetPVarInt(i, "pZapisanyHAY", 0);
	SetPVarInt(i, "pZapisanyCH", 0);
	SetPVarInt(i, "pZapisanyWG", 0);
	SetPVarInt(i, "pZapisanyDD", 0);
	SetPVarInt(i, "pZapisanySS", 0);
	return 1;
}

forward TW_Start();
public TW_Start()
{
	TW_Trwa = 1;
	TW_Timer = SetTimer("TW_End", 360000, 0);
	TW_Tick = GetTickCount();
	new count;
	foreachPly(i)
	{
	    if(pAttraction[i] == 1 || IsPlayerAFK(i) == 1) SetPVarInt(i, "pZapisanyTW", 0);

	    if(GetPVarInt(i, "pZapisanyTW") == 1 && pAttraction[i] == 0)
	    {
			new Float:flo[3];
			GetPlayerPos(i, flo[0],flo[1],flo[2]);
			SetPVarFloat(i, "floX", flo[0]);
			SetPVarFloat(i, "floY", flo[1]);
			SetPVarFloat(i, "floZ", flo[2]);
			SetPVarInt(i, "floInt", GetPlayerInterior(i));
			SetPVarInt(i, "floVW", GetPlayerVirtualWorld(i));

	        ResetPlayerWeapons(i);
	        SetPlayerVirtualWorld(i, VW_TOWER);
	        SetPlayerInterior(i, 0);
			pAttraction[i] = 1;
			TW_ClearVars(i);
		    SetPlayerPos(i, -3096.76 + random(2) - random(2), 78.76 + random(2) - random(2), 17.56);
            TogglePlayerControllable(i, 0);
			TogglePlayerDynamicCP(i, TW_Checkpoint, 1);
			count++;
			
			AnnForPlayer(i, 2000, "~g~Wczytywanie...");
		}
	}
	TW_Zapisanych = count;
	
	if(TW_Zapisanych == 0)
	{
	    KillTimer(TW_Timer);
	    TW_End();
	    return 1;
	}
	SetTimer("TW_Tele", 3000, 0);
	UpdateAttractionTD();
	return 1;
}

forward TW_Tele();
public TW_Tele()
{
	foreachPly(i)
	{
	    if(GetPVarInt(i, "pZapisanyTW") == 1 && pAttraction[i] == 1)
	    {
			AnnForPlayer(i, 2000, "~g~~h~GO!");
	        TogglePlayerControllable(i, 1);
	        SendClientMessage(i, -1, "{00CC00}Aby wygraæ, musisz wejœæ na szczyt!");
	    }
	}
	return 1;
}

forward TW_End();
public TW_End()
{
	if(TW_Zapisanych==0)
	{
		SendClientMessageToAll(-1,"{7FC7AF}Tower {3FB8AF}zakoñczone - brak zwyciê¿cy.");
	}
	TW_Trwa = 0;
	TW_Timer = -1;
	TW_Zapisanych = 0;
	TW_Odliczanie = -1;

	foreachPly(i)
	{
		if(GetPVarInt(i, "pZapisanyTW") == 1 && pAttraction[i] == 1)
		{
			SetPVarInt(i, "pZapisanyTW", 0);
			pAttraction[i] = 0;
			OdstawGracza(i);
			DisablePlayerCheckpoint(i);
			//SendClientMessage(i, -1, " *** {3FB8AF}Nikt nie wygra³ {7FC7AF}Tower{3FB8AF}! Czas min¹³!");
		}
	}

	UpdateAttractionTD();
	return 1;
}

/*-------------
	 HAY
 *-------------*/

CMD:hy(playerid, params[]) return cmd_hay(playerid, params);
CMD:hay(playerid, params[])
{
	if(HAY_Trwa == 1)
	    return SCM(playerid, -1, " *** Hay juz wystartowa³!");

	if(HAY_Off == 1)
		return SCM(playerid, -1, " *** Ta atrakcja jest tymczasowo wy³¹czona.");

	if(GetPVarInt(playerid, "pZapisanyHay") == 1)
	{
		SetPVarInt(playerid, "pZapisanyHay", 0);
		SCM(playerid, 0x00AAFFFF," {7FC7AF}Wypisa³eœ siê z {3FB8AF}Hay{7FC7AF}!");
		HAY_Zapisanych--;
	}else{
		SetPVarInt(playerid, "pZapisanyHay", 1);
		HAY_Zapisanych++;
		SCM(playerid, 0xDD0000FF," {3FB8AF}Zapisa³eœ siê na {7FC7AF}Hay{3FB8AF}!");
	}
	UpdateAttractionTD();

	if(HAY_Odliczanie == -1 && HAY_Zapisanych >= 3)
	{
		SendClientMessageToAll(-1, " {7FC7AF}Hay {3FB8AF}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		//SendClientMessageToAll(-1, "Hay {FF0000}wystartuje za 20 sekund. Mo¿na jeszcze siê zapisywaæ!");
		HAY_Odliczanie = SetTimer("HAY_Start", 20000, 0);
	}
	if(HAY_Zapisanych >= 14 && HAY_Odliczanie != -1)
	{
	    KillTimer(HAY_Odliczanie);
	    HAY_Start();
	}
	return 1;
}

enum e_HayPiece 
{
	ehy_object,
	bool:ehy_active
};

new gHayArray[10][10][e_HayPiece],
	gLeftHayCount;

new Float:HAY_POSX;
new Float:HAY_POSY;
new Float:HAY_POSZ;
new gHayArenaSelected;
	
stock HAY_ObjCleanup()
{
	for(new x; x < 10; x++)
	{
		for(new y; y < 10; y++)
		{
			if(gHayArray[x][y][ehy_active])
			{
				DestroyDynamicObject(gHayArray[x][y][ehy_object]);
			}
		}
	}
	gLeftHayCount = 0;
}

stock HAY_CreatePieces()
{
	for(new x; x < 10; x++)
	{
		for(new y; y < 10; y++)
		{
			gHayArray[x][y][ehy_active]=true;
			//CreateDynamicObject(modelid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = 200.0);
			gHayArray[x][y][ehy_object]=CreateDynamicObject(3374,HAY_POSX+(x*4),HAY_POSY+(y*4),HAY_POSZ,floatsin(y)*5,0,(floatsin(y)*floatcos(x)*90),VW_HAY,0,-1,150);
			//gHayArray[x][y][ehy_object]=CreateDynamicObject(3374, HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ, floatsin(y)*5, 0, (floatsin(y)*floatcos(x)*90), 24, 0, -1, 150.0);
		}
	}
	gLeftHayCount = 100;
}

stock HAY_ClearVars(i)
{
	SetPVarInt(i, "pZapisanyCH", 0);
	SetPVarInt(i, "pZapisanySS", 0);
	SetPVarInt(i, "pZapisanyWG", 0);
	SetPVarInt(i, "pZapisanyDD", 0);
	SetPVarInt(i, "pZapisanyTW", 0);
	return 1;
}

forward HAY_Start();
public HAY_Start()
{
	HAY_Trwa = 1;
	HAY_Timer = SetTimer("HAY_End", 480000, 0);
	HAY_Zapisanych = 0;

    Iter_Clear(HAY_Array);
	
	gHayArenaSelected = random(2);
	if(gHayArenaSelected==0)
	{
		HAY_POSX = -1333.0;
		HAY_POSY = 1200.0;
		HAY_POSZ = 550.0;
	} else if(gHayArenaSelected==1)
	{
		HAY_POSX = 1880.0;
		HAY_POSY = -1390.0;
		HAY_POSZ = 550.0;
	}

	HAY_ObjCleanup();
	HAY_CreatePieces();
	
	new pos;
	foreachPly(i)
	{
	    if(GetPVarInt(i, "pZapisanyHay") == 1 && IsPlayerAFK(i) == 0 && pAttraction[i] == 0)
	    {
   			new Float:flo[3], x = random(10), y = random(10);
			GetPlayerPos(i, flo[0],flo[1],flo[2]);
			SetPVarFloat(i, "floX", flo[0]);
			SetPVarFloat(i, "floY", flo[1]);
			SetPVarFloat(i, "floZ", flo[2]);
			SetPVarInt(i, "floInt", GetPlayerInterior(i));
			SetPVarInt(i, "floVW", GetPlayerVirtualWorld(i));

	        ResetPlayerWeapons(i);
			GivePlayerWeapon(i, 46, 1);
			SetPlayerVirtualWorld(i, VW_HAY);
	        SetPlayerInterior(i, 0);
	        pAttraction[i] = 1;
	        HAY_ClearVars(i);
	        SetPlayerHealth(i, 100.0);
			
			Streamer_UpdateEx(i, HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+2.0);
	        SetPlayerPos(i, HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+2.0);
			SetPlayerFacingAngle(i, (floatsin(y)*floatcos(x)*90));
	        Streamer_Update(i);
			TogglePlayerControllable(i, false);
	        Iter_Add(HAY_Array, i);
	        pos++;
	        HAY_Zapisanych++;
			AnnForPlayer(i, 3000, "~g~Wczytywanie...");
	    }
	}
	if(HAY_Zapisanych <= 1) // <= 1
	{
	    KillTimer(HAY_Timer);
	    HAY_End();
		//HAY_Cleanup();
	    return 1;
	}
	SetTimer("HAY_Tele", 5000, 0);
	UpdateAttractionTD();
	return 1;
}

forward HAY_Tele();
public HAY_Tele()
{
	foreachPly(i)
	{
	    if(pAttraction[i] == 1 && GetPVarInt(i, "pZapisanyHay") == 1)
	    {
			AnnForPlayer(i, 2000, "~g~~h~GO!");
	        TogglePlayerControllable(i, true);
	    }
	}
	SetTimer("HAY_MoveBlocks", 2000, 0);
	return 1;
}

forward HAY_MoveBlocks();
public HAY_MoveBlocks()
{
	if(HAY_Trwa == 0) return;
	
	new mtime,
		ttime,
		rh,
		rh2,
		hm,
		hi;
	
	rh = random(gLeftHayCount);
	rh2 = random(gLeftHayCount);
	gLeftHayCount = 0;
	hm = random(6);
	
	for(new x = 0; x < 10; x++)
	{
		for(new y = 0; y < 10; y++)
		{
			if(gHayArray[x][y][ehy_active])
			{
				if(rh==hi++ || rh2==hi)
				{
					gHayArray[x][y][ehy_active] = false;
					SetTimerEx("HAY_DestroyBlock", MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ-100, 5), false, "dd", x, y);
				} else {
					gLeftHayCount++;
					switch(hm)
					{
						case 0: {
							ttime = MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ, 0.5);
							//MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ, 0.5);
							//ttime = 2000;
						}
						case 1: {
							ttime = MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatsin(y)+floatcos(x), 0.5);
							//MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatsin(y)+floatcos(x), 0.5);
							//ttime = 900;
						}
						case 2: {
							ttime = MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatcos(y)+floatsin(x), 0.5);
							//MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatcos(y)+floatsin(x), 0.5);
							//ttime = 1400;
						}
						case 3: {
							ttime = MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatsin(y), 0.5);
							//MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatsin(y), 0.5);
							//ttime = 1900;
						}
						case 4: {
							ttime = MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatcos(x), 0.5);
							//MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+floatcos(x), 0.5);
							//ttime = 1100;
						}
						case 5: {
							ttime = MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+(floatcos(x)*floatsin(y)), 0.5);
							//MoveDynamicObject(gHayArray[x][y][ehy_object], HAY_POSX+(x*4), HAY_POSY+(y*4), HAY_POSZ+(floatcos(x)*floatsin(y)), 0.5);
							//ttime = 1600;
						}
					}
					//printf("ttime= %d, hm = %d", ttime, hm);
					if(mtime<ttime) mtime=ttime;
				}
			}
		}
	}
	//printf("gLeftHayCount: %d", gLeftHayCount);
	if(mtime==0) mtime=random(500)+700;
	if(gLeftHayCount>0)
	{
		SetTimer("HAY_MoveBlocks", mtime, false);
	}
}

forward HAY_DestroyBlock(x, y);
public HAY_DestroyBlock(x, y)
{
	DestroyDynamicObject(gHayArray[x][y][ehy_object]);
}

forward HAY_End();
public HAY_End()
{
	if(HAY_Zapisanych==0)
	{
		SendClientMessageToAll(-1,"{7FC7AF}Hay {3FB8AF}zakoñczone - brak zwyciê¿cy.");
	}
	
	HAY_Trwa = 0;
	HAY_Odliczanie = -1;
	HAY_Zapisanych = 0;
	HAY_Timer = -1;

	Iter_Clear(HAY_Array);
	
	foreachPly(i)
	{
		if(GetPVarInt(i, "pZapisanyHay") == 1 && pAttraction[i] == 1)
		{
			SetPVarInt(i, "pZapisanyHay", 0);
			pAttraction[i] = 0;
			OdstawGracza(i);
			//SendClientMessage(i, -1, " ***{3FB8AF}Nikt nie wygra³ {7FC7AF}Hay{3FB8AF}! Czas min¹³!");
		}
	}
	
	UpdateAttractionTD();
	return 1;
}

/*-------------
	 Labirynt
 *-------------*/
 
new labiryntObjects[197];

stock createLabirynt()
{
	new Float:angles[4] = {0.0, 90.0, -90.0, 180.0},
		Float:x = 2230.0,
		Float:y = 2874.0,
		obj;
		
	for(new i; i < 14; i++) 
	{
		x = 2230.0;
		for(new o; o < 14; o++) 
		{
			labiryntObjects[obj] = CreateDynamicObject(3095, x,y, 1241.90, 0.00, 90.00, angles[random(sizeof(angles))]);
			obj++;
			x = x - 9;
		}
		y = y - 9;
	}
	return 1;
}

forward Labirynt();
public Labirynt() 
{
	new Float:angles[4] = {0.0, 90.0, -90.0, 180.0};
	for(new i; i <= sizeof(labiryntObjects); i++)
	{
	    SetDynamicObjectRot(labiryntObjects[i], 0.0, 90.0, angles[random(sizeof(angles))]);
	}
	return 1;
}

/*---------
	race
 *---------*/

CMD:c_race(playerid, params[])
{
	if(!IsAdmin(playerid,3)) return 0;
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,-1,"Pojazd!!!");
	if(isnull(params)) return SendClientMessage(playerid, -1, "/c_race <nazwa>");
	
	new Float:x, Float:y, Float:z, modelid, Float:r, buffer[200];
	new v = GetPlayerVehicleID(playerid);
	GetVehiclePos(v, x, y, z);
	GetVehicleZAngle(v, r);
	modelid = GetVehicleModel(v);
	new i = RacesCount, raceid;
	
	if(i>=MAX_RACE) return SendClientMessage(playerid,-1,"max_race error");
	
	format(buffer,sizeof(buffer),"INSERT INTO race_id (racename,rx,ry,rz,rr,modelid) VALUES ('%s','%.3f','%.3f','%.3f','%.3f', '%d');", params, x, y, z, r, modelid);
	mysql_query(buffer);
	format(buffer,sizeof(buffer),"SELECT id FROM race_id WHERE racename = '%s' AND modelid = '%d'", params, modelid);
	mysql_query(buffer);
	mysql_store_result();
	raceid = mysql_fetch_int();
	mysql_free_result();
	
	format(buffer, sizeof(buffer), "Raceid: %d", raceid);
	SendClientMessage(playerid,-1,buffer);
	
	format(RaceInfo[i][Rname],40, "%s", params);
	RaceInfo[i][Rx] = x;
	RaceInfo[i][Ry] = y;
	RaceInfo[i][Rz] = z;
	RaceInfo[i][Rr] = r;
	RaceInfo[i][Rmodelid] = modelid;
	RaceInfo[i][Rid] = raceid;

	RaceInfo[i][Rcp] = CreateDynamicCP(x,y,z, 3.5, 0, 0, -1, 40.0);
	format(buffer, sizeof(buffer), "{EAEAEA}* {F2D399}Wyœcig{EAEAEA} *\n\n{006CFF}%s", params);
	Create3DTextLabel(buffer, -1, x,y,z + 1, 25.0, 0, 1);
	CreateDynamicMapIcon(x,y,z, 55, -1, 0, 0);
	RacesCount++;
	return 1;
}

CMD:p_race(playerid, params[]) 
{
	if(!IsAdmin(playerid,3)) return 0;
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,-1,"Pojazd!!!");
	
	new size, type, raceid;
	if(sscanf(params,"ddd",raceid, size, type)) return SendClientMessage(playerid, -1, "/p_race <raceid> <size> <type>");
	
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	if(type == 0 || type == 1) z = z - 1.5;
	if(type == 3 || type == 4) z = z - 2.5;
	
	new buffer[150];
	format(buffer,sizeof(buffer), "INSERT INTO race_cp (raceid, cpx, cpy, cpz, cptype, cpsize) VALUES ('%d', '%.3f', '%.3f', '%.3f', '%d', '%d');", raceid, x, y, z, type, size);
	mysql_query(buffer);
	format(buffer,sizeof(buffer),"CP dla %d dodano.", raceid);
	SendClientMessage(playerid,-1,buffer);
	
	for(new race; race < MAX_RACE; race++)
	{
		if(RaceInfo[race][Rid]== raceid)
		{
			RaceInfo[race][Rall_cp]++;
			break;
		}
	}
	return 1;
}


CMD:exitrace(playerid, params[]) 
{
	if(GetPlayerVirtualWorld(playerid) != 555) return SendClientMessage(playerid, -1, " * {00aaff}Nie jesteœ teraz na wyœcigu.");
	
	KillTimer(GetPVarInt(playerid, "RaceTimer"));
	ExitRace(playerid, 2);
	SendClientMessage(playerid, -1, " Zrezygnowa³eœ z wyœcigu.");
	return 1;
}

CMD:restartrace(playerid, params[]) return cmd_resrace(playerid, params);
CMD:resrace(playerid, params[])
{
	if(GetPVarInt(playerid, "LastRace") == 0 && GetPVarInt(playerid, "RacePlayer") == 0) return SendClientMessage(playerid, -1, " Nie jesteœ na ¿adnym wyœcigu.");
	if(IsPlayerInAnyVehicle(playerid)) SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	
	KillTimer(GetPVarInt(playerid, "RaceTimer"));
	SetPVarInt(playerid, "eRaceID", GetPVarInt(playerid, "LastRace")-1);
	cmd_race(playerid,"restart");
	return 1;
}

CMD:race(playerid, params[])
{
	if(strcmp(params, "restart") != 0 && IsPlayerInCheckpoint(playerid) == 0
		|| GetPVarInt(playerid, "eRaceID") == -1
		|| GetPVarInt(playerid, "eRaceID") >= MAX_RACE) return SendClientMessage(playerid, -1, " * {FF0000}Musisz byæ w punkcie startowym!");
		
	new i = GetPVarInt(playerid, "eRaceID");
	if(IsPlayerInAnyVehicle(playerid)) SetVehicleToRespawn(GetPlayerVehicleID(playerid));
	
	new vehicleid = CreateVehicle(RaceInfo[i][Rmodelid], RaceInfo[i][Rx], RaceInfo[i][Ry], RaceInfo[i][Rz] + 1, RaceInfo[i][Rr], random(255), random(255), 10);
	SetPlayerVirtualWorld(playerid, 555);
	SetVehicleVirtualWorld(vehicleid, 555);
	PutPlayerInVehicle(playerid, vehicleid, 0);
	SetVehicleHealth(vehicleid, 9999.0);
	DisablePlayerRaceCheckpoint(playerid);
	TogglePlayerControllable(playerid, 0);
	
	SetPVarInt(playerid, "LastRace", i+1);
	SetPVarInt(playerid, "RacePlayer", 1);
	SetPVarInt(playerid, "RaceCP", 1);
	SetPVarInt(playerid, "RaceTick", GetTickCount());
	SetPVarInt(playerid, "RaceTimer", SetTimerEx("ExitRace", 30000, false, !"ii", playerid, 0));
	CountdownRace(playerid, 5);
	
	new row1[120],row2[120];
	format(row1, 120, "SELECT * FROM race_cp WHERE raceid = '%d' ORDER BY id ASC LIMIT 2;", RaceInfo[i][Rid]);
	mysql_query(row1);
	mysql_store_result();
	mysql_fetch_row(row1, "|");
	mysql_fetch_row(row2, "|");
	mysql_free_result();

	new idt,race_id, Float:x,Float:y,Float:z,size,typ, Float:x2,Float:y2,Float:z2;
    sscanf(row2, "p<|>iifffii", idt,race_id, x2,y2,z2,size,typ);
	sscanf(row1, "p<|>iifffii", idt,race_id, x,y,z,size,typ);
	SetPlayerRaceCheckpoint(playerid, typ, x,y,z,x2,y2,z2, size);
	
	//new idt, race_id, Float:rowtype1_float[3], Float:size, type, Float:rowtype2_float[3];
	//sscanf(row1, "p<|>iifffii", idt, race_id, rowtype2_float[0], rowtype2_float[1], rowtype2_float[2], size, type);
	//sscanf(row2, "p<|>iiffffi", idt, race_id, rowtype1_float[0], rowtype1_float[1], rowtype1_float[2], size, type);
	//SetPlayerRaceCheckpoint(playerid, type, rowtype1_float[0], rowtype1_float[1], rowtype1_float[2], rowtype2_float[0], rowtype2_float[1], rowtype2_float[2], size);
	SendClientMessage(playerid,-1," *** {F2D399}Odliczanie rozpoczête. Wpisz {eeeeee}/exitrace{F2D399} aby zrezygnowaæ z wyœcigu.");
	pAttraction[playerid] = 1;
	ClearAllFunVars(playerid);
	return 1;
}

forward ExitRace(playerid, reason);
public ExitRace(playerid, reason) 
{
	if(GetPVarInt(playerid, "RacePlayer") == 0) return 1;
	
	if (IsPlayerInAnyVehicle(playerid)) DestroyVehicle(GetPlayerVehicleID(playerid));
	SetPlayerVirtualWorld(playerid, 0);
	DisablePlayerRaceCheckpoint(playerid);
	SetPVarInt(playerid, "LastRace", GetPVarInt(playerid, "eRaceID")+1);
	SetPVarInt(playerid, "RacePlayer", 0);
	
	if(reason == 2) SetPVarInt(playerid, "LastRace", 0);
	if(reason == 1) 
	{
		SetPVarInt(playerid, "LastRace", 0);
		new mstr[200];
		Respekt[playerid] += 10;
		Money[playerid] += 10000;
		new time = floatround((GetTickCount() - GetPVarInt(playerid, "RaceTick"))/1000), h, m, pos;
		m = time;
		while(m>=60)
		{
			h++;
			m -= 60;
		}
		
		new time_rekord;
		format(mstr,sizeof(mstr), "SELECT time FROM race_record WHERE raceid = '%d' AND nick = '%s' LIMIT 1;", RaceInfo[GetPVarInt(playerid, "eRaceID")][Rid], PlayerName(playerid));
		mysql_query(mstr);
		mysql_store_result();
		time_rekord = mysql_fetch_int();
		mysql_free_result();
		
		if (time < time_rekord || time_rekord == 0)
		{
			format(mstr,sizeof(mstr), "DELETE FROM race_record WHERE raceid = '%d' AND nick = '%s'", RaceInfo[GetPVarInt(playerid, "eRaceID")][Rid], PlayerName(playerid));
			mysql_query(mstr);
			format(mstr,sizeof(mstr), "INSERT INTO race_record (nick, raceid, time) VALUES ('%s', '%d', '%d');", PlayerName(playerid), RaceInfo[GetPVarInt(playerid, "eRaceID")][Rid], time);
			mysql_query(mstr);
		}
		format(mstr,sizeof(mstr), "SELECT nick FROM race_record WHERE raceid = '%d'", RaceInfo[GetPVarInt(playerid, "eRaceID")][Rid]);
		mysql_query(mstr);
		mysql_store_result();
		while(mysql_fetch_row(mstr)) 
		{
			pos++;
			if(!strcmp(mstr,PlayerName(playerid))) break;
		}
		mysql_free_result();
		
		if (time < time_rekord || time_rekord == 0)
		{
			format(mstr,sizeof(mstr), "Wygra³eœ wyœcig \"%s\"\nPobi³eœ swój rekord tej trasy!\n\nTwoja nagroda: $10.000 i 10 exp\nTwój czas to: %d:%02d\n\n", RaceInfo[GetPVarInt(playerid, "eRaceID")][Rname],h,m);
			format(mstr,sizeof(mstr), "%sTwoja pozycja na tej trasie: %d", mstr, pos);
		}
		else {
			new rh, rm;
			rm = time_rekord;
			while(rm>=60)
			{
				rh++;
				rh -= 60;
			}
			format(mstr,sizeof(mstr), "Wygra³eœ wyœcig \"%s\"\nNiestety, nie pobi³eœ swojego rekordu!\n\nTwoja nagroda: $10.000 i 10 exp\nTwój rekord: %d:%02d\nTwój czas to: %d:%02d\n\n", RaceInfo[GetPVarInt(playerid, "eRaceID")][Rname],rh,rm,h,m);
			format(mstr,sizeof(mstr), "%sTwoja pozycja na tej trasie: %d", mstr, pos);
		}
		ShowPlayerDialog(playerid,14000, DIALOG_STYLE_MSGBOX, "Wyœcig", mstr, "Ok", "");
	} else if(reason == 0) {
		ShowPlayerDialog(playerid,14001, DIALOG_STYLE_MSGBOX, "Wyœcig", "Przegraleœ!!!\n\nCzas na dojechanie do kolejnego punktu kontrolnego min¹³ lub zniszczy³eœ pojazd!", "Powtórz", "WyjdŸ");
	}
	pAttraction[playerid]=0;
	return 1;
}

forward CountdownRace(playerid, time);
public CountdownRace(playerid, time)
{
	if(time != -1)
	{
    	TogglePlayerControllable(playerid, 0);
    	if(time == 0) TogglePlayerControllable(playerid, 1);
    }
    
	if(time >= 0)
	{
		new buf[40];
		format(buf,sizeof(buf),"_~n~_~n~_~n~_~n~%s%d", time, (time==1)?("~r~"): (time==2)?("~r~~h~~h~"): (time==3)? ("~r~~h~~h~~h~"): ("~r~~h~~h~~h~~h~"));
		AnnForPlayer(playerid, 900, buf);
	} else AnnForPlayer(playerid, 900, "_~n~_~n~_~n~_~n~~g~!!!~r~GO ~h~GO ~h~GO~g~!!!");
		
	if(time > 0)
	{
		PlayerPlaySound(playerid,1056,0.0,0.0,0.0);
	} else if(time != -1) PlayerPlaySound(playerid,1057,0.0,0.0,0.0);
	
	if(time > -1) SetTimerEx("CountdownRace", 900, 0, "dd", playerid, time - 1);
	return 1;
}

stock loadRaces()
{
	new buffer[200];
	format(buffer,sizeof(buffer),"SELECT * FROM race_id LIMIT %d", MAX_RACE);
	mysql_query(buffer);
	mysql_store_result();
	
	new raceid, racename[90];
	while(mysql_fetch_row(buffer, "|"))
	{
		sscanf(buffer, "p<|>is[40]ffffi", RaceInfo[raceid][Rid], RaceInfo[raceid][Rname], RaceInfo[raceid][Rx], RaceInfo[raceid][Ry], RaceInfo[raceid][Rz], RaceInfo[raceid][Rr], RaceInfo[raceid][Rmodelid]);
		RaceInfo[raceid][Rcp] = CreateDynamicCP(RaceInfo[raceid][Rx], RaceInfo[raceid][Ry], RaceInfo[raceid][Rz], 3.5, 0, 0, -1, 40.0);
		
		format(racename,sizeof(racename), "{EAEAEA}* {00AAFF}Wyœcig{EAEAEA} *\n\n{006CFF}%s", RaceInfo[raceid][Rname]);
		Create3DTextLabel(racename, -1, RaceInfo[raceid][Rx], RaceInfo[raceid][Ry], RaceInfo[raceid][Rz]+1, 25.0, 0, 1);
		
		CreateDynamicMapIcon(RaceInfo[raceid][Rx], RaceInfo[raceid][Ry], RaceInfo[raceid][Rz], 55, -1, 0, 0);
		raceid++;
		RacesCount++;
	}
	mysql_free_result();
	
	new allcp;
	for(new i; i < MAX_RACE; i++) 
	{
		if(isnull(RaceInfo[raceid][Rname])) break;
		format(buffer,sizeof(buffer), "SELECT COUNT(*) AS liczba_cp FROM race_cp WHERE raceid = '%d'", RaceInfo[raceid][Rid]);
		mysql_query(buffer);
		mysql_store_result();
		allcp = mysql_fetch_int();
		RaceInfo[i][Rall_cp] = allcp;
	}
	printf(" Loaded %d races", raceid);
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) 
{
	switch(dialogid)
	{
		case DIALOG_RACE_SELECT:
	    {
			if(!response) return 1;
	        
			for(new i; i < RacesCount; i++)
			{
	            if(!strcmp(RaceInfo[i][Rname], inputtext))
	            {
	                SetPVarInt(playerid, "guiRaceID", i);
					break;
				}
	        }
			ShowPlayerDialog(playerid, DIALOG_RACE_MAIN, DIALOG_STYLE_LIST, "Wyœcigi > Opcje", "Najlepsze czasy\nTwój rekord\nWeŸ udzia³", "Wybierz", "Powrót");
	    }
	    case DIALOG_RACE_INFO:
	    {
	        if(!response) return cmd_wyscigi(playerid, " ");
	    }
	    case DIALOG_RACE_MAIN:
	    {
	        if(!response) return cmd_wyscigi(playerid, " ");
	        
	        new i = GetPVarInt(playerid, "guiRaceID");
	        
			switch(listitem)
			{
			    case 0:
			    {
			        new buffer[160], bufrace[1024];
			    	format(buffer, 160, "SELECT `nick`,`time` FROM `race_record` WHERE `raceid` = '%d' ORDER BY `time` ASC LIMIT 10", RaceInfo[i][Rid]);
					mysql_query(buffer);
					mysql_store_result();
					format(bufrace, sizeof bufrace, "{22A8FF}%s\n\n{D4F1FF}", RaceInfo[i][Rname]);

					new nick[30], value, pos = 1;
					while(mysql_fetch_row(buffer, "|"))
					{
					    sscanf(buffer, "p<|>s[30]d", nick, value);
						format(bufrace, sizeof bufrace, "%s%d - %s - %s\n", bufrace, pos, nick, ToTime(value));
						pos++;
					}
					mysql_free_result();
					//Dialog(playerid, DIALOG_RACE_INFO, DIALOG_BOX, bufrace, "Zamknij", "Powrót");
					ShowPlayerDialog(playerid, DIALOG_RACE_INFO, DIALOG_STYLE_MSGBOX, "Wyœcigi > Opcje > Rekordy", bufrace, "Wybierz", "Powrót");
			    }
			    case 1:
			    {
			    	new buffer[160];
			    	format(buffer, 160, "SELECT `time` FROM `race_record` WHERE `raceid` = '%d' AND `nick` = '%s' LIMIT 1", RaceInfo[i][Rid], PlayerName(playerid));
					mysql_query(buffer);
					mysql_store_result();
                    new param[32];
                    mysql_fetch_row(param);
                    
					if(strval(param) == 0)
					{
						ShowPlayerDialog(playerid, DIALOG_RACE_INFO, DIALOG_STYLE_MSGBOX, "Wyœcigi > Opcje > Mój rekord", "\nNie przejecha³eœ tej trasy!\nAby sprawdziæ rekord musisz przejechaæ tê trasê przynajmniej raz.\n\n", "Zamknij", "Wróæ");
					}else{
						new time = strval(param);
						format(buffer, 160, "Twój rekord: %s\nTrasa: %s", ToTime(time), RaceInfo[i][Rname]);
						ShowPlayerDialog(playerid, DIALOG_RACE_INFO, DIALOG_STYLE_MSGBOX, "Wyœcigi > Opcje > Mój rekord", buffer, "Zamknij", "Wróæ");
					}
					mysql_free_result();
			    }
			    case 2:
			    {
					SetPlayerVirtualWorld(playerid, 0);
					SetPlayerInterior(playerid, 0);
					SetPlayerPos(playerid, RaceInfo[i][Rx],RaceInfo[i][Ry],RaceInfo[i][Rz]);
					SCM(playerid, -1, "* {F2D399}Wpisz {EAEAEA}/race{F2D399} aby wzi¹æ udzia³ w wyœcigu!");
			    }
			}
	    }
		case DIALOG_INFO: return 1;
		case DIALOG_TRUCK_WPROWADZENIE: {
			if(!response) return 1;
			
			new rand = random(TrucksCount);
			SetPlayerVirtualWorld(playerid, 0);
			SetPlayerInterior(playerid, 0);
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
				SetVehiclePos(GetPlayerVehicleID(playerid), TruckInfo[rand][Tx],TruckInfo[rand][Ty],TruckInfo[rand][Tz]);
			} 
			else {
				SetPlayerPos(playerid, TruckInfo[rand][Tx],TruckInfo[rand][Ty],TruckInfo[rand][Tz]);
				
			}
		}
		case DIALOG_TRUCK_ZALADUNEK: {
			if(!response) return ShowPlayerDialog(playerid, DIALOG_TRUCK_NOWEZLECENIE, DIALOG_STYLE_MSGBOX, "Truck > Za³adunek", "Czy chcesz inne zlecenie?", "Tak", "Nie");
			
			new timezaladuj;
			
			if(IsTir(GetVehicleModel(GetPlayerVehicleID(playerid)))) 
			{
				if(!IsTrailerAttachedToVehicle(GetPlayerVehicleID(playerid))) return SCM(playerid, COLOR_ERROR, " Musisz mieæ naczepê!");
				
				SetPVarInt(playerid, "CarLadunek", GetVehicleTrailer(GetPlayerVehicleID(playerid)));
				timezaladuj = 30;
			} 
			else {
				SetPVarInt(playerid, "CarLadunek", GetPlayerVehicleID(playerid));
				timezaladuj = 20;
			}
			
			new id = GetPVarInt(playerid, "Ladunek");
			SetIcon(playerid, TruckInfo[id][Tx],TruckInfo[id][Ty] - 1,TruckInfo[id][Tz], 56, 1);
			SetPVarInt(playerid, "Zaladowany", 1);
			pAttraction[playerid] = 1;
			ClearAllFunVars(playerid);
			
			new buf[64];
			format(buf, sizeof(buf), "{2599FF}Spedycja - %s", PlayerName(playerid));
			
			if(IsValidDynamic3DTextLabel(truckLabel[playerid])) DestroyDynamic3DTextLabel(truckLabel[playerid]);
			truckLabel[playerid] = CreateDynamic3DTextLabel(buf, 0xffffffff, 0.0, 0.0, 1.0, 25.0, INVALID_PLAYER_ID, GetPVarInt(playerid, "CarLadunek"), 1, 0, 0, -1, 25.0);
			
			SetPlayerColor(playerid, 0x00FF0000);
			
			SCM(playerid, COLOR_INFO, " Poczekaj do za³adowania ³adunku.");
		    TogglePlayerControllable(playerid, 0);
			LadunekTimer(playerid, timezaladuj, 0);
		}
		case DIALOG_TRUCK_NOWEZLECENIE: {
			if(!response) return TogglePlayerControllable(playerid, 1);
		    
		    cmd_zaladuj(playerid, " ");
		}
		
	}
	return 1;
}

CMD:wyscigi(playerid, params[])
{
	mysql_query("SELECT `racename` FROM `race_id` ORDER BY `racename` ASC");
	mysql_store_result();
	
	new buffer[128], bufrace[1024];
	while(mysql_fetch_row(buffer))
	{
	    format(bufrace, sizeof bufrace, "%s%s\n", bufrace, buffer);
	}
	mysql_free_result();
	
	if(strlen(bufrace) == 0) return SCM(playerid, -1, "{00FF00}B³¹d po³¹czenia z baza danych!");
	
	ShowPlayerDialog(playerid, DIALOG_RACE_SELECT, DIALOG_STYLE_LIST, "Wyscigi", bufrace, "Wybierz", "Anuluj");
	return 1;
}

stock ToTime(val)
{
	new h, m = val;
	while(m >= 60)
	{
		h++;
		m -= 60;
	}
	
	new buffer[16];
	format(buffer, sizeof(buffer), "%d:%02d", h, m);
	return buffer;
}
	
/*------------------*/
/*		Truck		*/
/*------------------*/

CMD:c_ladunek(playerid, params[])
{
	if(!IsAdmin(playerid, 3)) return 0;

	new Float:x, Float:y, Float:z, buf[150];
	GetPlayerPos(playerid, x,y,z);
	new i = TrucksCount, rid;

	if(i >= MAX_TRUCK) return SCM(playerid, -1, "MAX_TRUCK error");

	format(buf, sizeof(buf), "INSERT INTO `trucks` (`tx`,`ty`,`tz`) VALUES ('%.3f','%.3f','%.3f');", x, y, z);
	mysql_query(buf);
	format(buf, sizeof(buf), "SELECT `id` FROM `trucks` WHERE `tx` = '%.3f' AND `ty` = '%.3f'", x, y);
	mysql_query(buf);
	mysql_store_result();
	rid = mysql_fetch_int();
	mysql_free_result();
	TruckInfo[i][Tx] = x;
	TruckInfo[i][Ty] = y;
	TruckInfo[i][Tz] = z;
	RaceInfo[i][Rid] = rid;

	TruckInfo[i][Tcp] = CreateDynamicCP(x, y, z, 5.5, 0, 0, -1, 40.0);
	CreateDynamic3DTextLabel("{F2D399}Punkt Logistyczny", 0xffffffff, x, y, z+1.0, 40.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1);
	CreateDynamicMapIcon(x,y,z, 51, -1, 0, 0);
	TrucksCount++;
	SCM(playerid, -1, "DONE.");
	return 1;
}

CMD:zaladuj(playerid, params[]) 
{
	if(GetPVarInt(playerid, "eTruckID") == -1 || !IsPlayerInCheckpoint(playerid)) return SCM(playerid, -1, " *** {ff0000}Musisz byæ w punkcie za³adunkowym!");
	if(!IsTir(GetVehicleModel(GetPlayerVehicleID(playerid))) && !IsCiezarowka(GetVehicleModel(GetPlayerVehicleID(playerid)))) return SCM(playerid, -1, " *** {ff0000}ZnajdŸ pojazd zdolny do przewozu towaru.");
	
	new Float:hp, vehicleid = GetPlayerVehicleID(playerid);
	GetVehicleHealth(vehicleid, hp);
	if(hp > 3000)
	{
		SetVehicleHealth(vehicleid,  1000.0);
		hp = 1000.0;
	}
	
	if(hp < 550) return SCM(playerid, -1, " *** {ff0000}Twój pojazd jest zbyt uszkodzony, aby przewoziæ towar!");
	if(IsTir(GetVehicleModel(vehicleid)) && !IsTrailerAttachedToVehicle(vehicleid)) return SCM(playerid, -1, " *** {ff0000}Musisz podjechaæ z naczep¹!");
	
	TogglePlayerControllable(playerid, 0);
	new ladunek = RandomLadunek(GetPVarInt(playerid, "eTruckID"));
	new kurs = floatround(GetPlayerDistanceFromPoint(playerid, TruckInfo[ladunek][Tx], TruckInfo[ladunek][Ty], TruckInfo[ladunek][Tz]));
	new kurskasa = kurs+500*4+random(500);
	if(IsTrailerAttachedToVehicle(vehicleid))
	{
		kurskasa = kurskasa * 4;
	}
	
	new item = random(sizeof(TruckItems)), buf[290];
	format(buf, sizeof(buf), "\nWylosowano dla Ciebie kurs, którego roz³adunek jest oddalony o %d mil\nOznacza to, ¿e zarobisz $%d + 30 exp za ten kurs\n\nBêdziesz transportowa³: %s\n", kurs, kurskasa, TruckItems[item]);
	strcat(buf, "Pamiêtaj, ¿e za niedowiezienie towaru otrzymasz grzywn¹ równowartoœci kursu.\n\nCzy przyjmujesz zlecenie?");
	ShowPlayerDialog(playerid, DIALOG_TRUCK_ZALADUNEK, DIALOG_STYLE_MSGBOX, "Truck > Za³adunek", buf, "Tak", "Nie");
	SetPVarInt(playerid, "Ladunek", ladunek);
	SetPVarInt(playerid, "Kurs", kurskasa);
	return 1;
}

CMD:truck(playerid, params[])
{
	if(GetPlayerVirtualWorld(playerid) != 0) return SCM(playerid, COLOR_ERROR, " Nie mo¿esz teraz transportowaæ towarów!");
	ShowPlayerDialog(playerid, DIALOG_TRUCK_WPROWADZENIE, DIALOG_STYLE_MSGBOX, "Truck > Wprowadzenie", "Truck to system przewozu towarów pojazdami do tego przeznaczonymi.\nAby rozpocz¹æ rozrywkê w trybie truck naciœnij OK.\nZostaniesz wtedy przeniesiony do jednej z baz.\nPo za³adowaniu towaru w punkcie logistycznym musisz zawieŸæ towar w odpowiednie miejsce.", "Zlecenie", "Zamknij");
	return 1;
}

CMD:cb(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SCM(playerid, COLOR_ERROR, " Musisz byæ w pojeŸdzie!");
	if(isnull(params)) return SCM(playerid, COLOR_INFO, "U¿yj: /cb <text>");
	
	new buffer[128+16+MAX_PLAYER_NAME];
	format(buffer, sizeof(buffer), "{F2D399}[CB] %s{eaeaea}: %s", PlayerName(playerid), params);
	foreachPly(i) 
	{
		if(IsPlayerInAnyVehicle(i)) 
		{
			SCM(i, -1, buffer);
		}
	}
	return 1;
}

	
CMD:exittruck(playerid, params[]) 
{
	if(GetPVarInt(playerid, "Zaladowany") == 1)
	{
		Money[playerid] += GetPVarInt(playerid, "Kurs") * -1;
		SetPVarInt(playerid, "Kurs", 0);
		SetPVarInt(playerid, "Ladunek", 0);
		SetPVarInt(playerid, "Zaladowany", 0);
		DestroyDynamic3DTextLabel(truckLabel[playerid]);
		RemovePlayerMapIcon(playerid, 99);
		pAttraction[playerid] = 0;
		Player[playerid][Color] = SelectPlayerColor(random(100));
		SetPlayerColor(playerid, Player[playerid][Color]);
		SCM(playerid, COLOR_INFO, " *** Zosta³eœ ukarany grzywn¹ za niedowiezienie towaru! ");
	} else SCM(playerid, COLOR_ERROR, " *** Musisz przewoziæ towar, aby u¿yæ tej komendy! ");
	return 1;
}

CMD:rozladuj(playerid, params[])
{
	if(GetPVarInt(playerid, "Zaladowany") == 0) return SCM(playerid, COLOR_ERROR, " Nie przewozisz ¿adnego towaru.");
	if(IsPlayerInDynamicCP(playerid, TruckInfo[GetPVarInt(playerid, "Ladunek")][Tcp]) == 0) return SCM(playerid, COLOR_ERROR, " JedŸ do w³aœciwego punktu roz³adunkowego!");
	if(GetPVarInt(playerid, "CarLadunek") != GetPlayerVehicleID(playerid) && !IsTir(GetVehicleModel(GetPlayerVehicleID(playerid)))) return SCM(playerid, COLOR_ERROR, " Musisz dojechaæ pojazdem, który byl za³adowany!");
	if(GetPVarInt(playerid, "CarLadunek") != GetVehicleTrailer(GetPlayerVehicleID(playerid)) && IsTir(GetVehicleModel(GetPlayerVehicleID(playerid)))) return SCM(playerid, COLOR_ERROR, " Musisz dojechaæ naczêpa, która by³a za³adowana!");

	TogglePlayerControllable(playerid, false);
	RemovePlayerMapIcon(playerid, 99);
	SCM(playerid, COLOR_INFO, " Poczekaj do rozladowania ³adunku.");
	if(IsTir(GetVehicleModel(GetPlayerVehicleID(playerid))))
	{
		LadunekTimer(playerid, 30, 1);
	} else LadunekTimer(playerid, 20, 1);
	
	DestroyDynamic3DTextLabel(truckLabel[playerid]);
	Player[playerid][Color] = SelectPlayerColor(random(100));
	SetPlayerColor(playerid, Player[playerid][Color]);
	
	new Float:hp, buffer[160], kurskasa = GetPVarInt(playerid, "Kurs");
	GetVehicleHealth(GetPlayerVehicleID(playerid), hp);
	if(hp < 550)
	{
		format(buffer,sizeof(buffer), "Towar uleg³ du¿emu zniszczeniu, za zniszcenia otrzymasz tylko po³owê nale¿noœci - $%d + 5 exp", floatround(kurskasa/2));
		Money[playerid] += floatround(kurskasa/2);
		Respekt[playerid] += 5;
	} else if(hp < 750)
	{
		format(buffer,sizeof(buffer), "Towar jest w dostatecznym stanie, otrzymujesz 2/3 nale¿noœci - $%d + 20 exp", floatround(kurskasa/1.5));
		Money[playerid] += floatround(kurskasa/1.5);
		Respekt[playerid] += 20;
	} 
	else {
		format(buffer,sizeof(buffer), "Towar jest w dobrym stanie, otrzymujesz swoj¹ nale¿noœci - $%d + 30 exp", floatround(kurskasa));
		Money[playerid] += floatround(kurskasa);
		Respekt[playerid] += 30;
	}
	SCM(playerid, COLOR_INFO, buffer);
	
	format(buffer, sizeof(buffer),"UPDATE fg_Players SET truck = truck + 1 WHERE Nick = '%s'", PlayerName(playerid));
	mysql_query(buffer);
	return 1;
}

stock IsTir(model)
{
	switch(model)
	{
	    case 403: return 1;
	    case 514: return 1;
	    case 515: return 1;
	}
	return 0;
}

stock IsCiezarowka(model)
{
	switch(model)
	{
	    case 499: return 1;
	    case 422: return 1;
	    case 482: return 1;
	    case 498: return 1;
	    case 609: return 1;
	    case 524: return 1;
	    case 455: return 1;
	    case 414: return 1;
	    case 600: return 1;
	    case 413: return 1;
	    case 440: return 1;
	    case 543: return 1;
	    case 459: return 1;
	    case 478: return 1;
	    case 456: return 1;
	    case 433: return 1;
	}
	return 0;
}

stock RandomLadunek(id)
{
	new rand = id;
	while(rand == id)
	{
		rand = random(TrucksCount);
	}
	return rand;
}

stock SetIcon(playerid, Float:x, Float:y, Float:z, iconid, type, color = 0x00000000)
{
	RemovePlayerMapIcon(playerid, 99);
	SetPlayerMapIcon(playerid, 99, x, y, z, iconid, color, type);
	return 1;
}

forward LadunekTimer(playerid, sec, type);
public LadunekTimer(playerid, sec, type)
{
	if(GetPVarInt(playerid, "Zaladowany") == 0) return TogglePlayerControllable(playerid, 0);

	new buffer[50];
	format(buffer, sizeof(buffer), "~n~~n~~n~~n~Wczytywanie...~n~00:%02d", sec);
	AnnForPlayer(playerid, 1000, buffer);

	if(sec > 1) return SetTimerEx("LadunekTimer", 1000, 0, "ddd", playerid, (sec-1), type);

    TogglePlayerControllable(playerid, 1);
    if(type == 1)
	{
	    new Float:hp;
	    GetVehicleHealth(GetPlayerVehicleID(playerid), hp);
		if(hp > 550)
		{
			ShowPlayerDialog(playerid, DIALOG_TRUCK_NOWEZLECENIE, DIALOG_STYLE_MSGBOX, "Truck > Roz³adunek", "\nRoz³adunek zakoñczony\n\nCzy chcesz nowe zlecenie?", "Tak", "Nie");
		}else
		{
			ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "Truck > Roz³adunek", "\nRoz³adunek zakoñczony\n\nTwój pojazd jest zbyt uszkodzony, aby kontynuowaæ dostawy", "Ok", "");
		}
	    pAttraction[playerid] = 0;
		SetPVarInt(playerid, "Zaladowany", 0);
	}else
	{
		ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_MSGBOX, "Truck > Ukoñczenie za³adunku", "\nZa³adunek zakoñczony\n\nJedŸ w kierunku zó³tej ikony na mapie, aby dojechaæ do punktu roz³adunku.\n\nAby zrezygnowaæ wpisz: /exittruck", "Ok", "");
    }
	return 1;
}
	
stock loadTrucks()
{
	new buf[127];
	format(buf, sizeof(buf), "SELECT * FROM trucks LIMIT %d", MAX_TRUCK);
	mysql_query(buf);
	mysql_store_result();
	
	new truckid;
	while(mysql_fetch_row(buf, "|")) 
	{
		sscanf(buf, "p<|>ifff", TruckInfo[truckid][Tid], TruckInfo[truckid][Tx], TruckInfo[truckid][Ty], TruckInfo[truckid][Tz]);
	    TruckInfo[truckid][Tcp] = CreateDynamicCP(TruckInfo[truckid][Tx], TruckInfo[truckid][Ty], TruckInfo[truckid][Tz], 5.5, 0, 0, -1, 40.0); 
		CreateDynamic3DTextLabel("{F2D399}Punkt Logistyczny", 0xffffffff, TruckInfo[truckid][Tx], TruckInfo[truckid][Ty], TruckInfo[truckid][Tz]+1.0, 40.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, 0, 0, -1);
        CreateDynamicMapIcon(TruckInfo[truckid][Tx], TruckInfo[truckid][Ty], TruckInfo[truckid][Tz], 51, -1, 0, 0, -1, 8000.0);

		truckid++;
		TrucksCount++;
	}
	mysql_free_result();
	printf(" Loaded %d trucks", truckid);
	return 1;
}
		
// ----------

stock ClearAllFunVars(i) {
	SetPVarInt(i, "pZapisanyHAY", 0);
	SetPVarInt(i, "pZapisanyCH", 0);
	SetPVarInt(i, "pZapisanySS", 0);
	SetPVarInt(i, "pZapisanyDD", 0);
	SetPVarInt(i, "pZapisanyTW", 0);
    SetPVarInt(i, "pZapisanyWG", 0);
    UpdateAttractionTD();
	return 1;
}

forward UpdateAttractionTD();
public UpdateAttractionTD() {

	new WG, CH, SS, DD, HAY, TW;
	foreachPly(i)
	{
		if(GetPVarInt(i, "pZapisanyWG") == 1) WG++;
		if(GetPVarInt(i, "pZapisanyCH") == 1) CH++;
		if(GetPVarInt(i, "pZapisanySS") == 1) SS++;
		if(GetPVarInt(i, "pZapisanyDD") == 1) DD++;
		if(GetPVarInt(i, "pZapisanyHAY") == 1) HAY++;
		if(GetPVarInt(i, "pZapisanyTW") == 1) TW++;
	}
	
	WG_Zapisanych = WG;
	CH_Zapisanych = CH;
	SS_Zapisanych = SS;
	DD_Zapisanych = DD;
	HAY_Zapisanych = HAY;
	TW_Zapisanych = TW;

	new str[7][16], strr[7][12];
	
	if(!CH_Trwa) 
	{
		if(CH<4) {
			format(str[0],16,"~g~~h~/Chowany");
			format(strr[0],12,"~w~%d/4",CH);
			//TextDrawBoxColor(tabelka_zapisow_boxy[3], 0x00000055);
		} 
		else {
			format(str[0],16,"~y~/Chowany");
			format(strr[0],12,"~y~%d",CH);
			//TextDrawBoxColor(tabelka_zapisow_boxy[3], 0x88880055);
		}
	} 
	else {
		format(str[0],16,"~r~~h~/Chowany");
		format(strr[0],12,"~r~~h~trwa");
		//TextDrawBoxColor(tabelka_zapisow_boxy[3], 0x88000055);
	}
	
	if(!SS_Trwa) 
	{
		if(SS<2) {
			format(str[1],16,"~g~~h~/Skoki");
			format(strr[1],12,"~w~%d/2",SS);
			//TextDrawBoxColor(tabelka_zapisow_boxy[4], 0x00000055);
		} 
		else {
			format(str[1],16,"~y~/Skoki");
			format(strr[1],12,"~y~%d",SS);
			//TextDrawBoxColor(tabelka_zapisow_boxy[4], 0x88880055);
		}
	} 
	else {
		format(str[1],16,"~r~~h~/Skoki");
		format(strr[1],12,"~r~~h~trwa");
		//TextDrawBoxColor(tabelka_zapisow_boxy[4], 0x88000055);
	}
	
	if(!TW_Trwa) 
	{
		if(TW<3) {
			format(str[2],16,"~g~~h~/Tower");
			format(strr[2],12,"~w~%d/3",TW);
			//TextDrawBoxColor(tabelka_zapisow_boxy[5], 0x00000055);
		} 
		else {
			format(str[2],16,"~y~/Tower");
			format(strr[2],12,"~y~%d",TW);
			//TextDrawBoxColor(tabelka_zapisow_boxy[5], 0x88880055);
		}
	} 
	else {
		format(str[2],16,"~r~~h~/Tower");
		format(strr[2],12,"~r~~h~trwa");
		//TextDrawBoxColor(tabelka_zapisow_boxy[5], 0x88000055);
	}
	
	if(!WG_Trwa) 
	{
		if(WG<2) {
			format(str[3],16,"~g~~h~/WG");
			format(strr[3],12,"~w~%d/2",WG);
			//TextDrawBoxColor(tabelka_zapisow_boxy[6], 0x00000055);
		} 
		else {
			format(str[3],16,"~y~/WG");
			format(strr[3],12,"~y~%d",WG);
			//TextDrawBoxColor(tabelka_zapisow_boxy[6], 0x88880055);
		}
	} 
	else {
		format(str[3],16,"~r~~h~/WG");
		format(strr[3],12,"~r~~h~trwa");
		//TextDrawBoxColor(tabelka_zapisow_boxy[6], 0x88000055);
	}
	
	if(!HAY_Trwa) 
	{
		if(HAY<3) {
			format(str[4],16,"~g~~h~/Hay");
			format(strr[4],12,"~w~%d/3",HAY);
			//TextDrawBoxColor(tabelka_zapisow_boxy[7], 0x00000055);
		} 
		else {
			format(str[4],16,"~y~/Hay");
			format(strr[4],12,"~y~%d",HAY);
			//TextDrawBoxColor(tabelka_zapisow_boxy[7], 0x88880055);
		}
	} 
	else {
		format(str[4],16,"~r~~h~/Hay");
		format(strr[4],12,"~r~~h~trwa");
		//TextDrawBoxColor(tabelka_zapisow_boxy[7], 0x88000055);
	}
	
	
	
	if(!DD_Trwa) 
	{
		if(DD<4) {
			format(str[5],16,"~g~~h~/Derby");
			format(strr[5],12,"~w~%d/4",DD);
			//TextDrawBoxColor(tabelka_zapisow_boxy[8], 0x00000055);
		} 
		else {
			format(str[5],16,"~y~/Derby");
			format(strr[5],12,"~y~%d",DD);
			//TextDrawBoxColor(tabelka_zapisow_boxy[8], 0x88880055);
		}
	} 
	else {
		format(str[5],16,"~r~~h~/Derby");
		format(strr[5],12,"~r~~h~trwa");
		//TextDrawBoxColor(tabelka_zapisow_boxy[8], 0x88000055);
	}

	new string[160];
	format(string,sizeof(string),"~n~~n~%s~n~%s~n~%s~n~%s~n~%s~n~%s",str[0],str[1],str[2],str[3],str[4],str[5]);
	TextDrawSetString(tabelka_zapisow_label[0],string);
	
	format(string,sizeof(string),"~n~~n~%s~n~%s~n~%s~n~%s~n~%s~n~%s",strr[0],strr[1],strr[2],strr[3],strr[4],strr[5]);
	TextDrawSetString(tabelka_zapisow_label[1],string);

	return 1;
}


forward UpdateSec();
public UpdateSec()
{
	foreachPly(i) 
	{
		if(GetPVarInt(i, "pZapisanyHay") == 1 && HAY_Trwa )
		{
			if(!IsPlayerConnected(i) || GetPlayerVirtualWorld(i) != 24)
			{
				SetPlayerVirtualWorld(i, 0);
				pAttraction[i] = 0;
				SetPVarInt(i, "pZapisanyHay", 0);
				HAY_Zapisanych--;
				pAttraction[i] = 0;
				Iter_Remove(HAY_Array, i);
				continue;
			}
			new Float:PP[3];
			GetPlayerPos(i, PP[0], PP[1], PP[2]);
			if(floatabs(PP[2]-HAY_POSZ)>50)
			{
				SetPlayerVirtualWorld(i, 0);
				SCM(i, COLOR_INFO, " Opuszczasz Hay");
				HAY_Zapisanych--;
				pAttraction[i] = 0;
				Iter_Remove(HAY_Array, i);
				SetPVarInt(i, "pZapisanyHay", 0);
				//OdstawGracza(i);
				continue;
			}
			if(HAY_Zapisanych <= 1) // <= 1
			{
				KillTimer(HAY_Timer);
				HAY_Trwa = 0;
				HAY_Timer = -1;
				HAY_Zapisanych = 0;
				HAY_Odliczanie = -1;
				Iter_Clear(HAY_Array);
					
				new hay_nagroda = 15 + random(9)-1;
				new buffer[160];
				format(buffer, sizeof buffer, "{7FC7AF}%s (%d){3FB8AF} wygra³ Hay! Otrzymuje on {7FC7AF}%d exp i $15000", PlayerName(i), i, hay_nagroda);
				SendClientMessageToAll(-1, buffer);
				foreachPly(a)
				{
					if(pAttraction[a] == 1 && GetPVarInt(a, "pZapisanyHay"))
					{
						Respekt[a] += hay_nagroda;
						GivePlayerMoney(a, 15000);
						Money[a] += 15000;
						pAttraction[a] = 0;
						SetPVarInt(a, "pZapisanyHay", 0);
						OdstawGracza(a);
						format(buffer, sizeof(buffer), "{3FB8AF}Wygra³eœ {7FC7AF}Hay{3FB8AF}! Otrzymujesz {7FC7AF}%d exp i $15000", hay_nagroda);
						SCM(a, -1, buffer);
						break;
					}
				}
			}
			UpdateAttractionTD();
		} else if(GetPVarInt(i, "pZapisanyCH") == 1 && CH_Trwa)
		{
			if(IsPlayerAFK(i) == 1)
			{
				CH_Zapisanych--;
				pAttraction[i] = 0;
				SetPVarInt(i, "pZapisanyCH", 0);
				OdstawGracza(i);
				if(CH_Zapisanych <= 1 && CH_Trwa == 1)
				{
					KillTimer(CH_Timer);
					CH_End();
				}
			}
		} else if(GetPVarInt(i, "pZapisanyWG") == 1 && WG_Trwa)
		{
			if(IsPlayerAFK(i) == 1 || IsPlayerInRangeOfPoint(i, WG_Dystans[0],WG_Dystans[1],WG_Dystans[2],PozycjeWG[2]) == 0)
			{
				new Float:HP;
				GetPlayerHealth(i, HP);
				SetPlayerHealth(i, HP - 5.0);
				AnnForPlayer(i, 500, "Opuszczasz arene Wojny Gangow!");
			}
		} else if(GetPVarInt(i, "pZapisanyDD") == 1 && DD_Trwa)
		{
			if(GetPlayerPosZ(i) < 60 || GetPlayerState(i) != PLAYER_STATE_DRIVER && DD_InCar == 1)
			{
				DD_Zapisanych--;
				pAttraction[i] = 0;
				SetPVarInt(i, "pZapisanyDD", 0);
				SetVehicleParamsEx(GetPlayerVehicleID(i), 1,1,1,1,1,1,0);
				OdstawGracza(i);
				if(DD_Zapisanych <= 1)
				{
					KillTimer(DD_Timer);
					DD_Trwa = 0;
					DD_Timer = -1;
					DD_Zapisanych = 0;
					DD_Odliczanie = -1;
					
					new buffer[160];
					format(buffer, sizeof buffer, "{7FC7AF}%s (%d){3FB8AF} wygra³(a) Derby! Otrzymuje on(a) {7FC7AF}15 exp i $15000", PlayerName(i), i);
					SendClientMessageToAll(-1, buffer);
					
					foreachPly(x)
					{
						if(pAttraction[x] == 1 && GetPVarInt(x, "pZapisanyDD"))
						{
							OdstawGracza(x);
							Respekt[x] += 15;
							pAttraction[x] = 0;
							SetPVarInt(x, "pZapisanyDD", 0);
							GivePlayerMoney(x, 15000);
							Money[x] += 15000;
							SCM(x, -1, " {3FB8AF}Wygra³eœ(aœ) {7FC7AF}Derby{3FB8AF}! Otrzymujesz {7FC7AF}15 exp i $15000");
							break;
						}
					}
				}
				UpdateAttractionTD();
			}
		}
	}
	return 1;
}

forward Float:GetPlayerPosZ(playerid);
Float:GetPlayerPosZ(playerid)
{
	new Float:f, Float:x, Float:y;
	GetPlayerPos(playerid, x,y,f);
	return f;
}

stock GiveStandardWeapon(i)
{
	GivePlayerWeapon(i, 8, 1);
	GivePlayerWeapon(i, 24, 180);

	GivePlayerWeapon(i, 27, 300);
	GivePlayerWeapon(i, 29, 2000);

	GivePlayerWeapon(i, 30, 4000);
	GivePlayerWeapon(i, 33, 4000);

	
	new PLVL = Player[i][Level];
	if(PLVL >= 8)
	{
		new Float:suma = 50+PLVL+random(10)/2;
		if(suma>100) 
			suma=100.0;
		else 
			suma = 0.0;
		SetPlayerArmour(i, suma);
	}
	GivePlayerWeapon(i, 43, 100);
	
	for(new Order = 0; Order < sizeof(WeapId); Order++)
	    if(Player[i][SpawnWeapons][Order] > 0)
	        GivePlayerWeapon(i, WeapId[Order][0], Player[i][SpawnWeapons][Order]*WEAPON_AMMO);
			
	return 1;
}

stock OdstawGracza(playerid)
{
    SetPlayerPos(playerid,GetPVarFloat(playerid, "floX"),GetPVarFloat(playerid, "floY"),GetPVarFloat(playerid, "floZ"));
    SetPlayerVirtualWorld(playerid, GetPVarInt(playerid, "floVW"));
    SetPlayerInterior(playerid, GetPVarInt(playerid, "floInt"));

	SetPlayerColor(playerid, playerColors[playerid]);
	SetPlayerTeam(playerid, NO_TEAM);

    ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid, 100.0);

    if(GetPVarInt(playerid, "floVW") != 26)
	{
		GiveStandardWeapon(playerid);
	} else GivePlayerWeapon(playerid, 24, 999);

	Player[playerid][Color] = SelectPlayerColor(random(100));
	SetPlayerColor(playerid, Player[playerid][Color]);
	
	SetPVarInt(playerid, "floInt", 0);
	SetPVarInt(playerid, "floVW", 0);
	return 1;
}

stock IsPlayerAFK(playerid) 
{
	if(!IsPlayerConnected(playerid)) return 1;
	if(GetPlayerState(playerid) == 0 || GetPlayerState(playerid) > 7) return 1;
	return AFK[playerid];
}

forward Float:PointToPoint(Float:x, Float:y, Float:x2, Float:y2);
stock Float:PointToPoint(Float:x, Float:y, Float:x2, Float:y2) return floatsqroot((x2-x)*(x2-x)+(y2-y)*(y2-y));

stock allowCommand(cmd[])
{
	if(!strcmp(cmd, "/ban", true, 4)) return 1;
	if(!strcmp(cmd, "/killp", true, 6)) return 1;
	if(!strcmp(cmd, "/kill", true, 5)) return 1;
	if(!strcmp(cmd, "/mute", true, 5)) return 1;
	if(!strcmp(cmd, "/jail", true, 5)) return 1;
	if(!strcmp(cmd, "/unfreeze", true, 9)) return 1;
	if(!strcmp(cmd, "/freeze", true, 7)) return 1;
	if(!strcmp(cmd, "/pm", true, 3)) return 1;
	if(!strcmp(cmd, "/resrace", true, 8)) return 1;
	if(!strcmp(cmd, "/exitrace", true, 9)) return 1;
	if(!strcmp(cmd, "/pmoff", true, 6)) return 1;
	if(!strcmp(cmd, "/pmon", true, 5)) return 1;
	if(!strcmp(cmd, "/skin", true, 5)) return 1;
	if(!strcmp(cmd, "/lock", true, 5)) return 1;
	if(!strcmp(cmd, "/unlock", true, 7)) return 1;
	if(!strcmp(cmd, "/dzien", true, 6)) return 1;
	if(!strcmp(cmd, "/noc", true, 4)) return 1;
	if(!strcmp(cmd, "/tune", true, 5)) return 1;
	if(!strcmp(cmd, "/raport", true, 7)) return 1;
	if(!strcmp(cmd, "/report", true, 7)) return 1;
	if(!strcmp(cmd, "/pw", true, 3)) return 1;
	if(!strcmp(cmd, "/me", true, 3)) return 1;
	if(!strcmp(cmd, "/flip", true, 5)) return 1;
	if(!strcmp(cmd, "/napraw", true, 7)) return 1;
	if(strfind(cmd,"/rsp",true) == 0) return 1;
	if(strfind(cmd,"/flo",true) == 0) return 1;
	//if(strfind(cmd,"/pm",true) == 0) return 1;
	//if(strfind(cmd,"/raport",true) == 0) return 1;
	if(strfind(cmd,"/toadmin",true) == 0) return 1;
	return 0;
}

stock CreateStreamObject(modelid,Float:X,Float:Y,Float:Z,Float:rX,Float:rY,Float:rZ)
	return CreateDynamicObjectEx(modelid,X,Y,Z,rX,rY,rZ,200.0,350.0, {0,1}, {0});

CMD:offwg(playerid, params[])
{
    if(IsAdmin(playerid, 1) == 0) return 0;

	if(WG_Off == 0)
	{
	    WG_Off = 1;
	    SCM(playerid, -1, "OFF");
	}else{
	    WG_Off = 0;
	    SCM(playerid, -1, "ON");
	}
	return 1;
}

CMD:offhay(playerid, params[])
{
    if(IsAdmin(playerid, 1) == 0) return 0;

	if(HAY_Off == 0)
	{
	    HAY_Off = 1;
	    SCM(playerid, -1, "OFF");
	}else{
	    HAY_Off = 0;
	    SCM(playerid, -1, "ON");
	}
	return 1;
}

CMD:offch(playerid, params[])
{
	if(IsAdmin(playerid, 1) == 0) return 0;

	if(CH_Off == 0)
	{
	    CH_Off = 1;
	    SCM(playerid, -1, "OFF");
	}else{
	    CH_Off = 0;
	    SCM(playerid, -1, "ON");
	}
	return 1;
}

CMD:offss(playerid, params[])
{
    if(IsAdmin(playerid, 1) == 0) return 0;

	if(SS_Off == 0)
	{
	    SS_Off = 1;
	    SCM(playerid, -1, "OFF");
	}else{
	    SS_Off = 0;
	    SCM(playerid, -1, "ON");
	}
	return 1;
}

CMD:offtw(playerid, params[])
{
    if(IsAdmin(playerid, 1) == 0) return 0;

	if(TW_Off == 0)
	{
	    TW_Off = 1;
	    SCM(playerid, -1, "OFF");
	}else{
	    TW_Off = 0;
	    SCM(playerid, -1, "ON");
	}
	return 1;
}

CMD:offdd(playerid, params[])
{
    if(IsAdmin(playerid, 1) == 0) return 0;

	if(DD_Off == 0)
	{
	    DD_Off = 1;
	    SCM(playerid, -1, "OFF");
	}else{
	    DD_Off = 0;
	    SCM(playerid, -1, "ON");
	}
	return 1;
}

/*
	CREATE TABLE race_id (
		id INT(11) NOT NULL AUTO_INCREMENT,
		racename VARCHAR(40) NOT NULL,
		rx VARCHAR(14) NOT NULL DEFAULT '0.0',
		ry VARCHAR(14) NOT NULL DEFAULT '0.0',
		rz VARCHAR(14) NOT NULL DEFAULT '0.0',
		rr VARCHAR(8) NOT NULL DEFAULT '90.0',
		modelid INT(11) NOT NULL DEFAULT '400',
		PRIMARY KEY (`id`)
	) ENGINE = MyISAM;
	INSERT INTO (racename, rx, ry, rz, rr, modelid) VALUES ('Wyscig na pustyni, Rancher', '1199.8636','2685.8145','46.0118', '-127.24', 489);
	
	CREATE TABLE race_cp (
		id INT(11) NOT NULL AUTO_INCREMENT,
		raceid INT(11) NOT NULL,
		cpx VARCHAR(14) NOT NULL DEFAULT '0.0',
		cpy VARCHAR(14) NOT NULL DEFAULT '0.0',
		cpz VARCHAR(14) NOT NULL DEFAULT '0.0',
		cpsize DOUBLE NOT NULL DEFAULT '3.5',
		cptype TINYINT(1) NOT NULL DEFAULT '0',
		PRIMARY KEY (`id`),
		FOREIGN KEY (raceid) REFERENCES race_id(id)
	) ENGINE = MyISAM;
	INSERT INTO race_cp (raceid,cpx,cpy,cpz,cpsize,cptype) VALUES (1,'1224.9153','2683.9460','46.5368', 3.5, 0),
	(1,'-1224.9153','2683.9460','46.5368', 3.5, 0),
	(1,'-1379.1201', '2597.7910', '55.5048', 3.5, 0),
	(1,'-1440.3073', '2370.1321', '53.2331', 3.5, 0),
	(1,'-1528.4592', '2362.9968', '46.7244', 3.5, 0),
	(1,'-1479.0613', '2111.4155', '45.6613', 3.5, 0),
	(1,'-1355.7784', '2172.2126', '48.6469', 3.5, 0),
	(1,'-1242.6707', '1921.2308', '43.0445', 3.5, 0),
	(1,'-1057.7505', '2142.8457', '87.5362', 3.5, 0),
	(1,'-1112.5997', '2367.0562', '85.2033', 3.5, 0),
	(1,'-1214.1082', '2219.0828', '105.8066', 3.5, 0),
	(1,'-1297.2722', '2498.7354', '87.1053', 3.5, 0);

	CREATE TABLE wg_areny (
		id INT(11) NOT NULL AUTO_INCREMENT,
		bx VARCHAR(14) NOT NULL,
		bpy VARCHAR(14) NOT NULL,
		bz VARCHAR(14) NOT NULL,
		rx VARCHAR(14) NOT NULL,
		ry VARCHAR(14) NOT NULL,
		rz VARCHAR(14) NOT NULL,
		interior SMALLINT(2) NOT NULL DEFAULT '0',
		PRIMARY KEY (`id`)
	) ENGINE = MyISAM;
	INSERT INTO wg_areny (bx, bpy, bz, rx, ry, rz, interior) VALUES 
	('2222.8511', '-1148.3708', '1025.7969','2194.8455', '-1142.9419', '1029.7969', '15'),
	('-1025.2351', '-1038.6492', '129.2188', '-1165.3801', '-1026.2427', '129.2188' , '0'),
	('2039.3240','-1198.1703','22.8839', '1887.6874','-1208.3300','18.9426', '0'),
	('-1356.3533', '1647.8347', '1052.5313', '-1484.6409', '1569.4066', '1052.5313', '14'),
	('-1129.890','1057.542','1346.414', '-975.756','1062.571','1345.671', '10');

	CREATE TABLE ch_areny (
		id INT(11) NOT NULL AUTO_INCREMENT,
		x VARCHAR(14) NOT NULL,
		y VARCHAR(14) NOT NULL,
		z VARCHAR(14) NOT NULL,
		sx VARCHAR(14) NOT NULL,
		sy VARCHAR(14) NOT NULL,
		sz VARCHAR(14) NOT NULL,
		interior SMALLINT(2) NOT NULL DEFAULT '0',
		PRIMARY KEY (`id`)
	) ENGINE = MyISAM;
	INSERT INTO ch_areny (x, y, z, sx, sy, sz, interior) VALUES 
	('2221.5715', '2505.2830', '10.8125', '2172.2463', '2470.9368', '10.8203', '0'),
	('1567.6080', '-1704.7671', '5.8906', '1574.4773', '-1627.9047', '13.3828', '0'),
	('1319.3440', '-645.3470', '109.1349', '1332.5609', '-622.5519', '109.1328', '0'),
	('1282.4991', '-832.7242', '1089.9375', '1266.3979', '-775.5005', '1091.9063', '5'),
	('2244.0471', '-1191.6045', '1029.7969', '2218.8215', '-1151.1470', '1025.7969', '10'),
	('1992.8850','1017.6964', '994.8906', '2005.9080', '1017.5101', '994.4688', '10');

	CREATE TABLE ss_aren (
		id INT(11) NOT NULL AUTO_INCREMENT,
		x VARCHAR(14) NOT NULL,
		y VARCHAR(14) NOT NULL,
		z VARCHAR(14) NOT NULL,
		cpx VARCHAR(14) NOT NULL,
		cpy VARCHAR(14) NOT NULL,
		cpz VARCHAR(14) NOT NULL,
		PRIMARY KEY (`id`)
	) ENGINE = MyISAM;
	
	CREATE TABLE race_record (
		id INT(11) NOT NULL AUTO_INCREMENT,
		raceid INT(11) NOT NULL,
		time INT(11) NOT NULL DEFAULT '0',
		nick VARCHAR(24) NOT NULL,
		PRIMARY KEY (`id`)
	) ENGINE = MyISAM;
		
*/

// eof