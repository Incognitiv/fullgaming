CMD:vip(playerid,cmdtext[]){
	new string[512];
	strcat(string,"__________[Konto VIP]__________\n\n");
	strcat(string,"Chcesz byæ kimœ wiêcej ni¿ zwyk³ym graczem?\n");
	strcat(string,"Zakup Konto {#FFFF00}VIP!\n");
	strcat(string,"Da ci mo¿liwoœæ przewage nad innymi graczami oraz wszelki szacunek na serwerze.\n");
	strcat(string,"-Pisanie na czacie jako {#FFFF00}VIP\n");
	strcat(string,"-Zmiana pogody\n\n");
	strcat(string,"-Pisanie og³oszeñ\n\n");
	strcat(string,"-Brak odejmowanych punktów exp za œmieræ.\n");
	strcat(string,"-Teleportowanie sie\n");
	strcat(string,"-Dodawanie sobie dowolnej broni wraz z amunicja\n");
	strcat(string,"-Naprawianie pojazdu dowolnemu graczowi za darmo\n");
	strcat(string,"-Posiadanie wyrozniajacego sie koloru ¿ó³tego\n");
	strcat(string,"-I wiele innych!\n");
	ShowPlayerDialog(playerid,995,0,"INFO> Konto VIP",string,"OK","OK");
	return 1;
}
CMD:vbron(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new bron,vipammo;
	if(sscanf(cmdtext,"dd",bron,vipammo))return SCM(playerid,COLOR_WHITE,"U¿yj: /vbron [ID broni] [Amunicja]");
	if(bron > 46 || bron < 0)return SCM(playerid,COLOR_RED2,"››› Z³e ID Broni!");
	if(vipammo > 9999)return SCM(playerid,COLOR_RED2,"››› Z³a iloœæ amunicji");
	new bool:Moze = true;
	for(new b=0; b<sizeof(Abronie); b++){
		if(Abronie[b]==bron){
			SCM(playerid,COLOR_RED2,"››› Ta broñ jest niedozwolona!");
			Moze = false;
			break;
		}
	}
	if(!Moze) return 1;
	GivePlayerWeapon(playerid,bron,vipammo);
	MSGF(playerid,COLOR_GREEN, "Da³eœ/aœ sobie broñ: %s i %d amunicji",ReturnWeaponName(bron),vipammo);
	return 1;
}
CMD:vjetpack(playerid,cmdtext[]){

	if(!IsVIP(playerid)) return SendClientMessage(playerid,COLOR_RED2,"Nie jesteœ vip'em!");

	SetPlayerSpecialAction(playerid, 2);
    SendClientMessage(playerid,COLOR_RED2,"Otrzyma³eœ/aœ jetpacka!");

	return 1;
}
CMD:vinvisible(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	SetPlayerColor(playerid,0xFFFFFF00);
	Invisible[playerid] = true;
	SendClientMessage(playerid, COLOR_ORANGE, "Jestes niewidoczny/a na mapie!");
	SendClientMessage(playerid,	COLOR_ORANGE,"Aby wy³¹czyæ niewidzialnoœæ wpisz: {FF0000}/visible");
	return 1;
}

CMD:vtp(playerid,cmdtext[]) {
	if(!IsVIP(playerid) && !IsAdmin(playerid,1)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz1;
	if(sscanf(cmdtext,"u",gracz1))return SendClientMessage(playerid, COLOR_WHITE, "U¿yj: /vtp  <id>");
	if(!IsPlayerConnected(gracz1))return SendClientMessage(playerid, COLOR_WHITE, " *** Gracz nie jest Online!");
	if (pData[gracz1][chainsawn] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (pData[gracz1][de] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (pData[gracz1][sniper] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (pData[gracz1][minigun] == 1) return SCM(playerid, COLOR_GREEN, " * Gracz jest na arenie!");
	if (Wiezien[gracz1]) return SCM(playerid, COLOR_GREEN, " * Gracz jest na wiêzieniu!");
	if (pAttraction[gracz1]==1) return SCM(playerid, COLOR_GREEN, " * Gracz aktualnie jest na atrakcji. Nie mo¿esz mu przeszkadzaæ.");
	
	new Float:x,Float:y,Float:z;
	new interior,world;
	GetPlayerPos(gracz1,x,y,z);
	interior = GetPlayerInterior(gracz1);
	world = GetPlayerVirtualWorld(gracz1);
	if(!IsPlayerInAnyVehicle(gracz1)){
		SetPlayerPos(playerid,x,y,z);
		SetPlayerInterior(playerid,interior);
		SetPlayerVirtualWorld(playerid,world);
	}else{
		SetVehiclePos(GetPlayerVehicleID(playerid),x,y,z);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid),interior);
		SetVehicleVirtualWorld(GetPlayerVehicleID(playerid),world);
	}
	MSGF(playerid,COLOR_ORANGE, "[VTP] Teleportowa³eœ siê do gracza %s (%d)", PlayerName(gracz1), gracz1);
	MSGF(gracz1,COLOR_ORANGE, "[VTP] VIP %s (%d) teleportowa³ siê do Ciebie.", PlayerName(playerid), playerid);
	return 1;
}
	
CMD:p(playerid,cmdtext[]){
	if(!IsVIP(playerid) && !IsAdmin(playerid,1)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new tmp[90];
	if(sscanf(cmdtext,"s[48]",tmp))return SendClientMessage(playerid, 0xFF0000FF, "Wpisz: /p [Nazwa]");
	new pojazdx;
	pojazdx = GetVehicleModelIDFromName(tmp);
	if(pojazdx < 400 || pojazdx > 611)return SendClientMessage(playerid, 0xFF0000FF, "››› Nie znaleziono takiego pojazdu!");
	new Float:x,Float:y,Float:z;
	new Float:Angle;
	GetPlayerPos(playerid,x,y,z);
	GetPlayerFacingAngle(playerid,Angle);
	GetXYInFrontOfPlayer(playerid, x, y, 5);
	CreateVehicle(pojazdx,x,y,z+2,Angle+89,-1,-1,1000);
	format(tmp,sizeof(tmp),"››› Utworzono pojazd o nazwie: {FF9900}%s", CarList[pojazdx-400]);
	SendClientMessage(playerid,COLOR_LIGHTGREEN,tmp);
	return 1;
}
CMD:ogloszenie(playerid, cmdtext[])
{
	if(!IsVIP(playerid) && !IsAdmin(playerid,1))return SCM(playerid, COLOR_ERROR, " ››› Nie jesteœ Vipem.");
	if(Player[playerid][VAnn] > 0){
	    new String[255];
	    format(String, sizeof(String), " ››› Musisz poczekaæ jeszcze %d sekund zanim dodasz kolejne og³oszenie.", Player[playerid][VAnn]);
	    SendClientMessage(playerid, COLOR_ERROR, String);
	    return 1;
	}
	if(VipAnnTime > 0)return SCM(playerid, COLOR_ERROR, " ››› Poczekaj chwile, a¿ aktualne og³oszenie zniknie.");
	ShowPlayerDialog(playerid, DIALOG_VANN, DIALOG_STYLE_INPUT, "Og³oszenie", "Og³oszenie nic nie kosztuje. Mo¿esz je wyœwietliæ co 5 minut.\nJest wyœwietlane wszystkim graczom przez 7 sekund.\nWpisz treœæ og³oszenia (max. 80 znaków):", "Wyœlij", "Anuluj");
	return 1;
}

CMD:vlistabroni(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	SCM(playerid, 0xFFFF00AA, "* Lista Broni:");
	SCM(playerid, 0xFFFFFFAA, "* 1-Kastet | 2-Kij golfowy | 3-Palka policyjna | 4-Noz | 5-Bassketball | 6-lopata");
	SCM(playerid, 0xFFFFFFAA, "* 7-Kij bilardowy | 8-Katana | 9-Pila lantuchowa | 10-Gumowiec1 | 11- Gumowiec2");
	SCM(playerid, 0xFFFFFFAA, "* 12- Gumowiec3 | 13-Gumowiec4 | 14-Kwiaty | 15-Laska | 16-Granat | 17-Gaz dymny");
	SCM(playerid, 0xFFFFFFAA, "* 18-Koktail molotowa | 22-Pistolet | 23-Pistolet z tlumikiem | 24-Desert Eagle");
	SCM(playerid, 0xFFFFFFAA, "* 25-Shoutgun | 26-SawnOfShoutgun | 27-Combat Shoutgun | 28-UZI | 29-MP5 | 30-Ak47");
	SCM(playerid, 0xFFFFFFAA, "* 31-M4 | 32-TEC9 | 33-Strzelba | 34-Sniperka | 35-Wyrzutnia Rakiet | 36-BazookaRPG");
	SCM(playerid, 0xFFFFFFAA, "* 37-Miotacz ognia | 38-Minigun | 39-C4 | 40-Detonator | 41-Spray | 42-Gasnica");
	SCM(playerid, 0xFFFFFFAA, "* 43-Aparat | 44-Google podczerwieni | 45-Google termowizyjne | 46-Spadochron");
	return 1;
}
CMD:pmv(playerid,cmdtext[]){
	if(!IsVIP(playerid) && !IsAdmin(playerid,1)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new wiadomosc[128];
	if(sscanf(cmdtext,"s[128]",wiadomosc))return SCM(playerid, COLOR_WHITE, "/Pmv [text]");
	new tmp[128];
	format(tmp, sizeof(tmp), "%s: %s",PlayerName(playerid), wiadomosc);
	SendClientMessageToVip(0x33AA33AA, tmp);
	return 1;
}
CMD:vrepair(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SCM(playerid, COLOR_WHITE, "U¿yj: /Vrepair [id gracza]");
	if(!IsPlayerConnected(gracz))return SCM(playerid,COLOR_RED2,"››› Nie ma takiego gracza!");
	SetVehicleHealth(GetPlayerVehicleID(gracz), 1000.0);
	MSGF(playerid,COLOR_GREEN, "AS: Naprawiles pojazd graczowi %s.", PlayerName(gracz));
	MSGF(gracz,COLOR_GREEN, "ViP %s (id: %d) naprawil ci pojazd.", PlayerName(playerid),playerid);
	return 1;
}
CMD:varmor(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SCM(playerid, COLOR_WHITE, "U¿yj: /Varmor [id gracza]");
	if(!IsPlayerConnected(gracz))return SCM(playerid,COLOR_RED2,"››› Nie ma takiego gracza!");
	SetPlayerArmour(gracz, 100.0);
	MSGF(playerid,COLOR_GREEN, "AS: Dales pancerz graczowi %s.", PlayerName(gracz));
	MSGF(gracz,COLOR_GREEN, "Dostales pancerz od ViP'a %s (id: %d).", PlayerName(playerid),playerid);
	return 1;
}
CMD:vzestaw(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	GivePlayerWeapon(playerid, 24, 100);
	GivePlayerWeapon(playerid, 31, 100);
	GivePlayerWeapon(playerid, 34, 100);
	GivePlayerWeapon(playerid, 9, 100);
	GivePlayerWeapon(playerid, 28, 100);
	return 1;
}
CMD:vcolor(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	SetPlayerColor(playerid,COLOR_VIP);
	SCM(playerid,COLOR_VIP,"Da³eœ/aœ sobie kolor Vipa!");
	//new buf[80];
	//format (buf, sizeof (buf), "%s {%06x}%s (%d)", (Player[playerid][Admin]==5)? ("{FF0000}Admin RCON {aaaaaa}|"): (Player[playerid][Admin]>=2)? ("{FF0000}Admin {aaaaaa}|"): (Player[playerid][Admin]==1)? ("{006600}Moderator {aaaaaa}|"): (Player[playerid][VIP])? ("{F2EC91}VIP {aaaaaa}|"): (""), (GetPlayerColor (playerid) >>> 8), PlayerName(playerid),playerid);
	//UpdateDynamic3DTextLabelText (nickname_labels[playerid], -1,  buf);
	return 1;
}
CMD:vcar(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1) && !IsVIP(playerid)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new nazwa[32];
	if(sscanf(cmdtext,"s[32]",nazwa))return SCM(playerid, 0xFF0000FF, "Wpisz: /Vcar [Nazwa]");
	new pojazd = GetVehicleModelIDFromName(nazwa);
	if(pojazd < 400 || pojazd > 611)return SCM(playerid, 0xFF0000FF, "Nie znaleziono takiego pojazdu!");
	new Float:x,Float:y,Float:z;
	new Float:Angle;
	GetPlayerPos(playerid,x,y,z);
	GetPlayerFacingAngle(playerid,Angle);
	GetXYInFrontOfPlayer(playerid, x, y, 5);
	CreateVehicle(pojazd,x,y,z+2,Angle+90,-1,-1,1000);
	MSGF(playerid,COLOR_LIGHTGREEN,"Pojazd Utworzony: %s", CarList[pojazd-400]);
	return 1;
}
CMD:vgivecash(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1) && !IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz,kasa;
	if(sscanf(cmdtext,"ud",gracz,kasa)) return SCM(playerid, 0x00FFFFAA, "Uzyj : /vGivecash [ID] [kwota]");
	if(kasa > 100000 || kasa < 0) return SCM(playerid,COLOR_RED2,"Jednorazowo mo¿esz dawaæ max. po {FF9900}$100 000");
	if(Money[gracz] > 100000 && !IsVIP(gracz)) return SCM(playerid,COLOR_RED2,"Ten gracz ma ju¿ ponad $100 000");
	MSGF(playerid, COLOR_GREEN, "AS: Dales $%d graczowi %s",kasa, PlayerName(gracz));
	MSGF(gracz, COLOR_GREEN, "ViP %s dal ci $%d",PlayerName(playerid),kasa);
	GivePlayerMoney(gracz, kasa);
	Money[gracz] += kasa;
	return 1;
}
CMD:vheal(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SCM(playerid, COLOR_WHITE, "U¿yj: /Vheal [id gracza]");
	if(!IsPlayerConnected(gracz))return SCM(playerid, COLOR_RED2, "››› Nie ma takiego gracza!");
	SetPlayerHealth(gracz, 100.0);
	MSGF(playerid, COLOR_GREEN, "Uzdrowiles garcza %s.", PlayerName(gracz));
	MSGF(gracz, COLOR_GREEN, "Zostales uzdrowiony przez ViP'a %s (id: %d).", PlayerName(playerid),playerid);
	return 1;
}

CMD:vsay(playerid,cmdtext[]){
	if(!IsVIP(playerid)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new wiadomosc[128];
	if(sscanf(cmdtext,"s[128]",wiadomosc))return SCM(playerid, COLOR_WHITE, "U¿yj: /Vsay [text]");
	MSGFA(0x33AA33AA, "{4491FF}({C6E43C}VIP{4491FF}) {C6E43C}%s {4491FF}%s",PlayerName(playerid), wiadomosc);
	return 1;
}
CMD:vpozostalo(playerid, params[]){
	if(!IsVIP(playerid) && !IsAdmin(playerid,1))return SCM(playerid, COLOR_ERROR, "{FF732F}›››{F01414}Nie jesteœ Vipem.");
	new buff[128],_buff[64];
	mysql_query_format("SELECT `VIPCZAS` FROM `Players` WHERE `id`='%d'",Player[playerid][uID]);
	mysql_store_result();
	mysql_fetch_row(_buff);
	mysql_free_result();
	format(buff,sizeof buff,"{FFE5A1}Twoje konto VIP wa¿ne jest do\t {DEAF21}%s",_buff);
	ShowPlayerDialog(playerid,680,0,"{FFE5A1}VPozostalo",buff,"OK", "");
	return 1;
}
CMD:vgranaty(playerid, cmdtext[]){
	if(!IsVIP(playerid) && !IsAdmin(playerid,1))return SCM(playerid, COLOR_ERROR, " ››› Nie jesteœ Vipem.");
	if(Respekt[playerid] < 20) return SCM(playerid, COLOR_ERROR, " ››› Granaty kosztuj¹ 20 exp.");
	ShowPlayerDialog(playerid, DIALOG_VGRANATY, DIALOG_STYLE_MSGBOX, "Potwierdzenie", "Czy na pewno chcesz kupiæ 30 granatów za 20 Exp?", "Tak", "Anuluj");
	return 1;
}
CMD:vdotacja(playerid, cmdtext[]){
	if(!IsVIP(playerid) && !IsAdmin(playerid,1))return SCM(playerid, COLOR_ERROR, "››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	if(Player[playerid][Dotacja][1])return SCM(playerid, COLOR_ERROR, " ››› U¿y³eœ/aœ juz raz tej komendy.");
	Player[playerid][Dotacja][1] = true;
	GivePlayerMoney(playerid,1000000);
	Money[playerid] += 1000000;
	SendClientMessage(playerid, COLOR_GREEN, "Otrzymujesz 1 mln $ z dotacji dla vip-a.");
	return 1;
}
CMD:vcmd(playerid,cmdtext[]) return cmd_vipinfo(playerid, cmdtext);
CMD:vpomoc(playerid,cmdtext[])
{
	new string[1300];
    strcat(string,"{FFFF00}/vGranaty {FFFFFF}- Granaty specjalnie dla VIP.\n");
	strcat(string,"{FFFF00}/Vjetpack {FFFFFF}- Dostajesz plecak odrzutowy (Jetpack).\n");
    strcat(string,"{FFFF00}/Vdotacja {FFFFFF}- Dotacja w wysokoœci 1 miliona $.\n");
	strcat(string,"{FFFF00}/Vinvisible {FFFFFF}- Niewidzialnoœæ na mapie.\n");
	strcat(string,"{FFFF00}/Ogloszenie {FFFFFF}- Og³oszenie na œrodku ekranu.\n");
	strcat(string,"{FFFF00}/Vpozostalo {FFFFFF}- Wa¿noœæ konta [VIP].\n");
	strcat(string,"{FFFF00}/Vcar [nazwa] {FFFFFF}- Spawnowanie pojazdu poprzez nazwê.\n");
	strcat(string,"{FFFF00}/Vzestaw  {FFFFFF}- Zestaw broni [VIP].\n");
	strcat(string,"{FFFF00}/Vgivecash [id] [kwota] {FFFFFF}- Dodawanie pieniêdzy graczowi.\n");
	strcat(string,"{FFFF00}/Vbron [id_broni] [ammo]  {FFFFFF}- Dodawanie dowolnej broni.\n");
	strcat(string,"{FFFF00}/Vlistabroni {FFFFFF}- Lista ID broni.\n");
	strcat(string,"{FFFF00}/Vsay [tekst] {FFFFFF}- Czat [VIP-MSG].\n");
	strcat(string,"{FFFF00}/Pmv [tskst] {FFFFFF}- Prywatny czat Administracji i VIP'ów.\n");
	strcat(string,"{FFFF00}/Vrepair [id]  {FFFFFF}- Naprawa pojazdu dowolnemu graczowi.\n");
	strcat(string,"{FFFF00}/Vcolor {FFFFFF}- Zmiana koloru nicku na ¿ó³ty.\n");
	strcat(string,"{FFFF00}/Vheal [id] {FFFFFF}- Uzdrowienie dowolnego gracza.\n");
	strcat(string,"{FFFF00}/Varmor {FFFFFF}- Natychmiastowa kamizelka.\n");
	strcat(string,"{FFFFFF}________________________________________________________________________\n");
	strcat(string,"{FFFFFF}Zapamiêtaj gdy bêd¹ nadu¿ywane te komendy mo¿e to siê wi¹zaæ z utrat¹ [VIP].");
	ShowPlayerDialog(playerid,31,0,"{FFFF00}Lista komend [VIP]",string,"Cofnij","Wyjdz");
	return 1;
}