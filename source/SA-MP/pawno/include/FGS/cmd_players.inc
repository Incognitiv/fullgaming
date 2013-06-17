CMD:tak(playerid,cmdtext[]){

	if(!VoteON)return SCM(playerid,COLOR_RED2,"››› Aktualnie nie ma g³osowania!");
	
	if(Zaglosowal[playerid])return SCM(playerid,COLOR_RED2,"››› Ju¿ odda³eœ/aœ swój g³os!");	
	Zaglosowal[playerid] = true;
	LiczbaTak ++;
	return 1;
}

CMD:nie(playerid,cmdtext[]){

	if(!VoteON) return SCM(playerid,COLOR_RED2,"››› Aktualnie nie ma g³osowania!");
	if(Zaglosowal[playerid])return SCM(playerid,COLOR_RED2,"››› Ju¿ odda³eœ/aœ swój g³os!");	
	Zaglosowal[playerid] = true;
	LiczbaNie ++;
	return 1;
}
CMD:tunemenu(playerid, cmdtext[])
{
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SCM(playerid, COLOR_RED2, "Nie jesteœ kierowc¹ lub nie jesteœ w pojeŸdzie!");
	ShowPlayerDialog(playerid, 14, DIALOG_STYLE_LIST, "Tuning Menu", "Felgi\nKolory\nHydraulika\nNitro\nStereo\nPaint Job", "Wybierz", "Anuluj");
	return 1;
}
CMD:ustawka(playerid,cmdtext[]){
	if(!UstawkaON)return SCM(playerid,COLOR_RED2,"Admin nie w³¹czy³ USTAWKI!");
	ResetPlayerWeapons(playerid);
	SetPlayerHealth(playerid,100);
	SetPlayerArmour(playerid,0);
	SetPlayerInterior(playerid,UstawkaInt);
	if(UstawkaCount){
		SetPlayerPos(playerid,UstawkaX[0],UstawkaY[0],UstawkaZ[0]);
		SetPlayerColor(playerid,0x00FFFFFF);
		SCM(playerid,0x00FFFFFF,"Zosta³eœ/aœ przydzielony/a do Varrio Los Aztecas");
        SetPlayerSkin(playerid, 115);
		UstawkaCount = false;
	}else{
		SetPlayerPos(playerid,UstawkaX[1],UstawkaY[1],UstawkaZ[1]);
		SetPlayerColor(playerid,0xFF00FFFF);
		SCM(playerid,0xFF00FFFF,"Zosta³eœ/aœ przydzielony/a do Vagos Los Santos");
		SetPlayerSkin(playerid, 118);
		UstawkaCount = true;
	}
	return 1;
}
CMD:pos(playerid,cmdtext[])
{
    new Float:posX,Float:posY,Float:posZ;
	GetPlayerPos(playerid,posX,posY,posZ);
	MSGF(playerid,COLOR_GREEN, "X: %f | Y: %f | Z: %f | Interior: %d | Virtual World: %d", posX,posY,posZ, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
	return 1;
}
CMD:radio(playerid, params[])
{
	ShowPlayerDialog(playerid, DIALOG_RADIO, DIALOG_STYLE_LIST, "{18339E} Radio", "{FF8000}Radio\n{FF8000}Player\n{FF8000}Wy³¹cz", "Wybierz", "Anuluj");
	return 1;
}
CMD:portfel(playerid,params[])
{
	if(!Registered[playerid]){
		SCM(playerid,COLOR_RED2,"››› Nie jesteœ zarejestrowany!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	ShowPlayerDialog(playerid,DIALOG_PORTFEL_CMD, DIALOG_STYLE_LIST,"{EAB171}Portfel gracza","{EAB171}Doladuj portfel\n{EAB171}Stan portfela\n{EAB171}Kupno\n{EAB171}Regulamin\n{EAB171}Przelew srodkow","Ok","Anuluj");
	return 1;
}
CMD:skin(playerid,cmdtext[]){

	new skinx;
	if(sscanf(cmdtext,"d",skinx)){
	    SCM(playerid, COLOR_WHITE, "»» /Skin [ID skina]");
		return 1;
	}

	if(!IsValidSkin(skinx) || skinx == 0){
		SCM(playerid, COLOR_WHITE, "»» Niepoprawne ID Skina.");
		return 1;
	}
	SetPlayerSkin(playerid,skinx);
	PlayerPlaySound(playerid, 1159,0.0,0.0,0.0);
	new tmp[64];
	format(tmp, sizeof(tmp), "»» Zmieni³eœ sobie skina na: %d",skinx);
	SCM(playerid,COLOR_GREEN, tmp);

	return 1;
}

CMD:pojazd(playerid,cmdtext[])
{
	ShowVehicleControlDialog(playerid);
	return 1;
}

CMD:auto(playerid, cmdtext[]){

	ShowVehicleControlDialog(playerid);
	return 1;
    #pragma unused cmdtext
}

CMD:dzien(playerid,cmdtext[])
{
	SetPlayerTime(playerid,12,0); //pó³noc
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swój czas gry na dzieñ!");
	return 1;
}

CMD:pogoda(playerid, cmdtext[])
{
	SCM(playerid, JasnoNiebieski, " ››› FullGaming - dostêpne dla Ciebie pogody w San Andreas!");
	SCM(playerid, COLOR_NORMAL_PLAYER, " * /deszcz /matrix /czarnobyl /salato /mgla /pogodanormalna");
	SCM(playerid, COLOR_WHITE," Aby powróciæ do standardowej pogody wpisz /normalnapogoda. ");
	return 1;
}

CMD:deszcz(playerid, cmdtext[])
{
	SetPlayerWeather(playerid, 16); //deszcz
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swoj¹ pogodê w San Andreas na: deszcz ");
	return 1;
}

CMD:matrix(playerid, cmdtext[])
{
	SetPlayerWeather(playerid, 44);
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swoj¹ pogodê w San Andreas na: matrix ");
	return 1;
}

CMD:czarnobyl(playerid, cmdtext[])
{
	SetPlayerWeather(playerid, 43);
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swoj¹ pogodê w San Andreas na: czarnobyl ");
	return 1;
}

CMD:salato(playerid, cmdtext[])
{
	SetPlayerWeather(playerid, 11);
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swoj¹ pogodê w San Andreas na: lato ");
	return 1;
}

CMD:lato(playerid, cmdtext[])
{
	SetPlayerWeather(playerid, 11);
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swoj¹ pogodê w San Andreas na: lato ");
	return 1;
}

CMD:mgla(playerid, cmdtext[])
{
	SetPlayerWeather(playerid, 9);
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swoj¹ pogodê w San Andreas na: mg³a ");
	return 1;
}

CMD:normalnapogoda(playerid, cmdtext[])
{
	SetPlayerWeather(playerid, 1);
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swoj¹ pogodê w San Andreas na: normalna ");
	return 1;
}

CMD:dotacja(playerid, cmdtext[])
{
	if(Player[playerid][Dotacja][0])
	{
		SCM(playerid, COLOR_ERROR, " ››› Ju¿ raz u¿y³eœ/aœ tej komendy!");
		return 1;
	}

	Player[playerid][Dotacja][0] = true;
	GivePlayerMoney(playerid,250000);
	Money[playerid] += 250000;
	SCM(playerid, COLOR_GREEN, " ››› Dostajesz 250 000$.");
	return 1;
}

CMD:noc(playerid, cmdtext[])
{
	SetPlayerTime(playerid,0,0); //pó³noc
	SCM(playerid, COLOR_CB, " ››› Zmieni³eœ swój czas gry na noc!");
	return 1;
}

CMD:idzdo(playerid, cmdtext[]) {
	new target;
	if (sscanf(cmdtext, "u", target))
		return SCM(playerid, COLOR_ERROR, " ››› U¿yj: /idzdo [id gracza]");
	
	if(target == INVALID_PLAYER_ID)
		return SCM(playerid, COLOR_ERROR, " ››› Nie ma gracza o podanym ID.");
	
	if (Player[target][deagle] == 1 && Player[target][minigun] == 1 && Player[target][sniper] == 1 && Player[target][chainsawn])
		return SCM(playerid, COLOR_ERROR, " ››› Ten gracz jest na arenie");
	
	if(playerid == target)
		return SCM(playerid, COLOR_ERROR, " ››› Poda³eœ/aœ swoje id!");
	
	if (IdzdoBlock[playerid])
		return SCM(playerid,COLOR_RED2,"Mo¿esz tego u¿ywaæ co 10 sek!");
	
	SendPlayerRequestToTeleport (playerid, target);
	return 1;
}

CMD:neony(playerid,cmdtext[]){
	ShowPlayerDialog(playerid,878,DIALOG_STYLE_LIST,"Wybierz Kolor Neonu","Czerwony\nNiebieski\nZielony\n¯ó³ty\nRó¿owy\nBia³y\nUsuñ Neon","Wybierz","Anuluj");
	return 1;
	#pragma unused cmdtext
}

CMD:wysoko(playerid,cmdtext[]){
	new wysokosc;
	if(sscanf(cmdtext,"d",wysokosc))return SendClientMessage(playerid, COLOR_GREEN, "WPISZ: /wysoko [wysokosc w metrach]");
	if(wysokosc > 20000 || wysokosc < 500) {
		SendClientMessage(playerid, COLOR_RED, "Podaj wysokosc z zakresu od 500 do 20000 m!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	MSGF(playerid, COLOR_GREEN, "Wykonujesz skok spadochronowy z wysokosci %d m!", wysokosc);
	new Float:x;
	new Float:y;
	new Float:z;
	GivePlayerWeapon(playerid,46,1);
	GetPlayerPos(playerid,x,y,z);
	SetPlayerPos(playerid,x,y,z+wysokosc);
	GameTextForPlayer(playerid,"No to HOOOOP!!!",2000,5);
	return 1;
}
CMD:lock(playerid,cmdtext[]){
	if(IsPlayerInAnyVehicle(playerid)) {
		if(vehicleDoorState[GetPlayerVehicleID(playerid)] == 1) return SCM(playerid, COLOR_ERROR, "Pojazd jest ju¿ zamkniêty.");
	
		PlayerPlaySound(playerid,1147,LocX, LocY, LocZ);
		AnnForPlayer(playerid, 2500, "~r~~h~Pojazd zamkniety");
		new vid = GetPlayerVehicleID(playerid);
			
		new cengine, clights, calarm, cdoors, cbonnet, cboot, cobjective;
		GetVehicleParamsEx(vid, cengine, clights, calarm, cdoors, cbonnet, cboot, cobjective);
		SetVehicleParamsEx(vid, cengine, clights, calarm, 1, cbonnet, cboot, cobjective);

		SetVehicleParamsForPlayer(vid, playerid, 0, 0);

		vehicleDoorState[vid] = 1;
		vehicleDoorOwner[vid] = playerid;

		SendClientMessage(playerid,COLOR_WHITE,"Pojazd zamkniety!");
	}
	else {
		SendClientMessage(playerid,COLOR_WHITE,"››› Nie jestes w pojezdzie!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
	
}
CMD:unlock(playerid,cmdtext[]){
	if(IsPlayerInAnyVehicle(playerid)) {
		if(vehicleDoorState[GetPlayerVehicleID(playerid)] == 0) return SCM(playerid, COLOR_ERROR, "Pojazd jest ju¿ otwarty.");
		
		PlayerPlaySound(playerid,1147,LocX, LocY, LocZ);
		AnnForPlayer(playerid, 2500, "~g~~h~Pojazd otwarty");
		new vid = GetPlayerVehicleID(playerid);
		
		new cengine, clights, calarm, cdoors, cbonnet, cboot, cobjective;
		GetVehicleParamsEx(vid, cengine, clights, calarm, cdoors, cbonnet, cboot, cobjective);
		SetVehicleParamsEx(vid, cengine, clights, calarm, 0, cbonnet, cboot, cobjective);

		SetVehicleParamsForPlayer(vid, playerid, 0, 0);

		vehicleDoorState[vid] = 0;
		vehicleDoorOwner[vid] = playerid;
		
		SendClientMessage(playerid,COLOR_RED,"Pojazd otwarty!");
	}
	else {
		SendClientMessage(playerid,COLOR_LIGHTORANGE,"››› Nie jestes w pojezdzie!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	return 1;
}
CMD:odleglosc(playerid,cmdtext[]){
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid,COLOR_WHITE,"Uzyj: /odleglosc [idgracza]");
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid,COLOR_RED,"››› Nie ma takiego gracza!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new dis = GetDistanceBetweenPlayers(playerid,gracz);
	MSGF(playerid,COLOR_LIGHTYELLOW,"%s jest odlegly od Ciebie o %d m ",PlayerName(gracz),dis);
	return 1;
}
CMD:parachute(playerid,cmdtext[]){
	GivePlayerWeapon(playerid, 46, 1);
	SendClientMessage(playerid, COLOR_YELLOW, "Otrzyma³eœ/aœ spadochron");
	return 1;
}

CMD:100hp(playerid,cmdtext[]){
	if (GetPlayerMoney(playerid) >= 3000) {
		GivePlayerMoney(playerid, -3000);
		Money[playerid] -= 3000;
		SetPlayerHealth (playerid, float(100));
		SendClientMessage(playerid, COLOR_LIGHTGREEN, "Zosta³eœ(aœ) uleczony(a).");
		MSGFA(COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}uzupe³ni³/a ¿ycie. ({28730A}/100hp{3BAD00}).", PlayerName(playerid));
        SoundForAll(1050);

	} else {
	SendClientMessage(playerid, COLOR_RED, "¯ycie kosztuje 3000$!"); }
	PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	return 1;
}
CMD:armour(playerid,cmdtext[]){
	if (GetPlayerMoney(playerid) >= 5000) {
		GivePlayerMoney(playerid, -5000);
		Money[playerid] -= 5000;
		SetTimerEx("Armorx", 5000, 0, "i" ,playerid);
		SendClientMessage(playerid, COLOR_LIGHTGREEN, "Trwa zak³adanie kamizelki.");
		MSGFA(COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}uzupe³ni³/a armour. ({28730A}/Armour{3BAD00}).", PlayerName(playerid));
        SoundForAll(1050);
	} else {
	SendClientMessage(playerid, COLOR_RED, "Kamizelka kosztuje 5000$!"); }
	PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	return 1;
}
CMD:rozbroj(playerid,cmdtext[]){
	ResetPlayerWeapons(playerid);
	SendClientMessage(playerid,COLOR_GREEN,"Rozbroiles(as) sie");
	return 1;
	
}
CMD:visible(playerid,cmdtext[]){
	PlayerSetColor(playerid);
	SendClientMessage(playerid, COLOR_ORANGE, "Jestes widoczny.");
	return 1;
}
CMD:ramp(playerid, cmdtext[]){
	new RampId;
	if(sscanf(cmdtext, "d", RampId))return SendClientMessage(playerid, COLOR_ERROR, " ››› Wpisz: /ramp [1-5]");
	if(RampId < 0 || RampId > 5)return  SendClientMessage(playerid, COLOR_ERROR, " ››› Wpisz: /ramp [0-5]");

	if(RampId == 0) {
	    SendClientMessage(playerid, COLOR_GREEN, " ››› Rampy zosta³y wy³¹czone.");
		Player[playerid][RampEnabled] = 0;
	    return 1;
	}
	if(RampId == 1)
		Player[playerid][RampPers] = 1655;
	else if(RampId == 2)
		Player[playerid][RampPers] = 1632;
	else if(RampId == 3)
		Player[playerid][RampPers] = 1631;
	else if(RampId == 4)
		Player[playerid][RampPers] = 8302;
	else if(RampId == 5)
		Player[playerid][RampPers] = 1503;

	Player[playerid][RampEnabled] = 1;
	SendClientMessage(playerid, COLOR_GREEN, " ››› Typ ramp zosta³ zmieniony.");
	return 1;
}
CMD:lotto(playerid, cmdtext[]){
	if(Player[playerid][LottoNumber] > 0)return  SendClientMessage(playerid, COLOR_ERROR, " ››› Bra³eœ/aœ ju¿ udzia³ w losowaniu.");
	if(GetPlayerMoney(playerid) < LOTTO_PRICE)return SendClientMessage(playerid, COLOR_ERROR, " ››› Los kosztuje 1000$. Nie masz tyle kasy!");
	if(strlen(cmdtext) < 1 || !isNumeric(cmdtext))return SendClientMessage(playerid, COLOR_ERROR, " ››› Wpisz: /lotto [1-46]");
	new Number = strval(cmdtext);
	if(Number < 1 || Number > 46)return SendClientMessage(playerid, COLOR_ERROR, " ››› Niepoprawna liczba. Dozwolone: 1-46.");
	Player[playerid][LottoNumber] = Number;
	LottoMoney += LOTTO_PRICE*10;
	GivePlayerMoney(playerid, -LOTTO_PRICE);
    Money[playerid] -= LOTTO_PRICE;
	SendClientMessage(playerid, COLOR_GREEN, " ››› Kupi³eœ/aœ los. Teraz czekaj na losowanie.");
	return 1;
}
CMD:randka(playerid, cmdtext[]){
	new PlayerId;
	if(sscanf(cmdtext, "u", PlayerId))return  SCM(playerid, COLOR_ERROR, " ››› U¿yj: /randka [id gracza]");
	if(PlayerId == INVALID_PLAYER_ID)return SCM(playerid, COLOR_ERROR, " ››› Nie ma gracza o podanym ID.");
	if(playerid == PlayerId)return SCM(playerid, COLOR_ERROR, " ››› Poda³eœ/aœ swoje id!");
	if(Player[PlayerId][TPRefused][playerid])return SCM(playerid, COLOR_ERROR, " ››› Ten gracz odrzuci³ zaproszenie na randkê.");
	
	SetPVarInt (playerid, #teleport.tpto, PlayerId);
	GivePlayerWeapon(playerid, 14, 1);
	new String[255];
	format(String, sizeof(String), "Gracz %s (%d) chce siê umowic sie z Toba na randke w ciemno.\nWyra¿asz na to zgodê?\n\nA kwiaty dostaniecie gratis od Administracji FullGaming ;).", PlayerName(playerid), playerid);
	ShowPlayerDialog(PlayerId, DIALOG_TP, DIALOG_STYLE_MSGBOX, "Randka", String, "Akceptuj", "Odrzuæ");
	SCM(playerid, COLOR_GREEN, " ››› Zaproszenie zosta³o wys³ane, powodzenia. ;)");
	return 1;
}
CMD:me(playerid,cmdtext[]){
    if(playermuted[playerid] && !IsVIP(playerid) && !IsAdmin(playerid,2) || Wiezien[playerid] && !IsAdmin(playerid,2)){
		SendClientMessage(playerid, COLOR_RED2, "Masz zablokowan¹ mo¿liwoœæ pisania!");
		return false;
	}
	if(isnull(cmdtext))return SCM(playerid, -1, "U¿yj: /me [text]");
	MSGFA(COLOR_ORANGE, "{ffe5a1}(me) {eab171}%s: {ffe5a1}%s",PlayerName(playerid),cmdtext);
	return 1;
}
CMD:pmon(playerid,cmdtext[]){	
	SendClientMessage(playerid,COLOR_GREEN,"Odblokowa³eœ/aœ prywatne wiadomoœci do ciebie");
	ChcePM[playerid] = true;
	return 1;
}
CMD:report(playerid, cmdtext[])
{
	return cmd_raport(playerid,cmdtext);
}
CMD:reports(playerid, cmdtext[])
{
	return cmd_raports(playerid,cmdtext);
}
CMD:raport(playerid,cmdtext[]){
	if(RaportBlock[playerid])return SendClientMessage(playerid,COLOR_RED2,"Mo¿esz wysy³aæ raport co 1 min.");
	new gracz,powod[32];
	if(sscanf(cmdtext,"us[32]",gracz,powod))return SendClientMessage(playerid, COLOR_RED, "Wpisz: /Raport [ID] [Powód]");
	if(gracz < 0 || gracz >= MAX_GRACZY) return SendClientMessage(playerid, COLOR_RED, "Zle ID gracza");
	if(!IsPlayerConnected(gracz)) return SendClientMessage(playerid, COLOR_RED, "Nie ma takiego gracza");
	if(strlen(powod) >= 32){
	    SendClientMessage(playerid,COLOR_RED2,"Powód mo¿e mieæ max. 30 znaków!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new bool:ret;
	for(new x=0;x<10;x++){
		if(RaportID[x] == gracz){
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
	format(Raport[RaportCD],32,"%s",powod);
	RaportID[RaportCD] = gracz;
	foreachPly (x) {
		if(Player[x][Admin] > 2){
			PlayerPlaySound(x, 1147, 0, 0, 0);
			SendClientMessage(x,COLOR_LIGHTRED,tmp);
			GameTextForPlayer(x, "~g~~h~RAPORT", 2000, 3);
		}
	}
	return 1;
}

CMD:stat(playerid,cmdtext[]){
	ShowPlayerDialog(playerid,17,2,"Panel Statystyk","Twoje Statystyki \nStatystyki Serwa \nRespekt TOP-10 \nKillers TOP-10 \nDrag TOP-10 \nArena Solo TOP-10 \nCzas Grania TOP-10\nTest Reakcji TOP-10","Dalej","Wyjdz");
	return 1;
	
}
CMD:staty(playerid,cmdtext[]){

	cmd_stat(playerid,cmdtext);
	return 1;
}
CMD:statystyki(playerid,cmdtext[]){

	cmd_stat(playerid,cmdtext);
	return 1;
}

CMD:top(playerid, params[]) return cmd_stat(playerid, params);

CMD:pmoff(playerid,cmdtext[]){

	SendClientMessage(playerid,COLOR_GREEN,"Zablokowa³eœ/aœ prywatne wiadomoœci do ciebie");
	ChcePM[playerid] = false;
	return 1;
}

CMD:pm(playerid,cmdtext[]){

	new Wiadomosc[128];
	new string[128];
	new gracz;
	if(sscanf(cmdtext,"us[128]",gracz,Wiadomosc))return SCM(playerid, COLOR_RED, "/pm [ID_gracza] [Wiadomoœæ]");
	if(gracz < 0 || gracz >= MAX_GRACZY || !IsPlayerConnected(gracz)) return SendClientMessage(playerid, COLOR_RED, "››› Nie ma takiego gracza!");
	if(!ChcePM[gracz]) return SendClientMessage(playerid, COLOR_RED, "Ten gracz nie przyjmuje PM!");
	pmid1 = playerid;
	pmid2 = gracz;
	new wysylacz[MAX_PLAYER_NAME];
	new adresat[MAX_PLAYER_NAME];
	GetPlayerName(playerid, wysylacz, sizeof(wysylacz));
	GetPlayerName(gracz, adresat, sizeof(adresat));
	format(string, sizeof(string), "PM od %s(%d): %s", wysylacz,playerid,Wiadomosc);
	SendClientMessage(gracz,0xFFFF00AA, string);
	TextDrawShowForPlayer(gracz,PM1);
	KillTimer(PMTimer[gracz]);
	PMTimer[gracz] = SetTimerEx("PMOff",5000,0,"i",gracz);
	format(string, sizeof(string), "PM do %s(%d): %s", adresat,gracz,Wiadomosc);
	SendClientMessage(playerid,0xFFFF00AA, string);
	if(podgladPM == 1){
		format(string, sizeof(string), "%s(%d) -> %s(%d): %s", wysylacz,playerid,adresat,gracz,Wiadomosc);
		SendClientMessageToAdminsPM(COLOR_ORANGE,string);
	}

	PlayerPlaySound(gracz, 1057, 0, 0, 0);
	if(ChceAnn[gracz]){
	}

	return 1;
}

bool:skinWomen (skinid) {
	static s_skinWomen[] = { 
		9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 55, 56, 63, 64, 69, 75, 76, 77, 85, 87, 88, 89, 
		91, 92, 93, 129, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 
		193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 216, 219, 224, 225, 226, 231, 232, 233, 237, 
		238, 244, 245, 246, 251, 256, 257, 263, 298 
	};
	
	for (new i = 0; i < sizeof (s_skinWomen); i++) {
		if (skinid == s_skinWomen[i]) return true;
	}
	return false;
}