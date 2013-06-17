//Junior Admin
CMD:tune50(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	foreachPly (j) {
		if(GetDistanceBetweenPlayers(playerid,j) <= 50){
			if(IsPlayerInAnyVehicle(j)){
				PlayerPlaySound(j, 1134, 0, 0, 0);
				TuneCar(GetPlayerVehicleID(j));
				SendClientMessage(j, COLOR_LIGHTRED, "Twoj pojazd zostal ztuningowany przez administratora!");
			}
			MSGF(j,COLOR_RED,  "››› Admin %s stuningowa³ ci pojazd!", PlayerName(playerid));
		}
	}
	SendClientMessage(playerid,COLOR_GREEN,"››› Stuningowa³eœ pojazdy graczom w promieniu 50 metrów.");
	return 1;
}
CMD:freeze50(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	foreachPly (j) {
		if(GetDistanceBetweenPlayers(playerid,j) <= 50){
			TogglePlayerControllable(j, 0);
			MSGF(j,COLOR_RED,"››› Zosta³eœ/aœ zamro¿ony/a przez admina: {FF0000}%s", PlayerName(playerid));
		}
	}
	SendClientMessage(playerid,COLOR_GREEN,"››› Zamrozi³eœ/aœ wszystkich graczy w zasiêgu 50 m.");
	return 1;
}
CMD:unfreeze50(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	foreachPly (j) {
		if(GetDistanceBetweenPlayers(playerid,j) <= 50){
			TogglePlayerControllable(j, 1);
			MSGF(j,COLOR_RED, "››› Odmrozi³eœ/aœ zamro¿ony/a przez admina: {FF0000}%s", PlayerName(playerid));
		}
	}
	SendClientMessage(playerid,COLOR_GREEN,"››› Zamrozi³eœ/aœ wszystkich graczy w zasiêgu 50 m.");
	return 1;
}
CMD:heal50(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	foreachPly (j) {
		if(GetDistanceBetweenPlayers(playerid,j) <= 50){
			SetPlayerHealth(j,100);
			MSGF(j,COLOR_GREEN,  "››› Zosta³eœ/aœ uleczony/a przez admina %s",PlayerName(playerid));
		}
	}
	SendClientMessage(playerid,COLOR_GREEN,"››› Uleczy³eœ/aœ wszystkich graczy w zasiêgu 50m.");
	return 1;
}
CMD:armor50(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new string2[80];
	format(string2, sizeof(string2), "››› Dosta³eœ/aœ pancerz od admina %s", PlayerName(playerid));
	foreachPly (j) {
		if(GetDistanceBetweenPlayers(playerid,j) <= 50){
			SetPlayerArmour(j,100);
			SendClientMessage(j,COLOR_RED, string2);
		}
	}
	SendClientMessage(playerid,COLOR_GREEN,"››› Da³eœ/aœ pancerz wszystkim graczom w zasiêgu {FF0000}50m.");
	return 1;
}
CMD:a(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new buffer_to_admin[160];
	format (buffer_to_admin, sizeof (buffer_to_admin), "{D50101}[@C] {%06x}%s: {FFFF11}%s", (GetPlayerColor (playerid) >>> 8), PlayerName (playerid), cmdtext);
	SendClientMessageToAdmins (-1, buffer_to_admin);
	printf ("[ADMIN-CHAT] %s (%d): %s", PlayerName(playerid), playerid, cmdtext);
	return 1;
}
CMD:warn(playerid, params[]){
	if(!IsAdmin(playerid,2)) return 0;
	new PlayerId, Reason[255],ip[16],reason[256],_reason[162],msg[256];
	if(sscanf(params, "us[255]", PlayerId, Reason))return SCM(playerid, COLOR_ERROR, "{FF732F}»»»{F01414}Wpisz: /warn [id gracza] [powód]");
	if(PlayerId == INVALID_PLAYER_ID)return SCM(playerid, COLOR_ERROR, "{FF732F}»»»{F01414}Nie ma takiego gracza.");
	if(!Registered[PlayerId])return SCM(playerid, COLOR_ERROR, "{FF732F}»»»{F01414}Gracz nie jest zarejestrowany.");
	if(Player[playerid][Admin] < Player[PlayerId][Admin])return SCM(playerid, COLOR_ERROR, "{FF732F}»»»{F01414}Nie mo¿esz u¿yæ tej komeny na administrato¿e o wy¿szym poziomie");
	GetPlayerIp(PlayerId, ip, 16);
	Player[PlayerId][Warns]++;
	if(Player[PlayerId][Warns] == MAX_WARNS){
		mysql_real_escape_string(Reason, reason);
		format(_reason, sizeof _reason,"%s | MAX OSTRZEZEN",reason);
		mysql_query_format("SELECT `name` FROM `ban` WHERE `name` = '%s'", PlayerName(PlayerId));
		mysql_store_result();
		if(mysql_num_rows()){
			mysql_query_format("UPDATE `ban` SET `name`='%s', IP='%s', `type`='0', `date_end`=DATE_ADD(NOW(), INTERVAL 14*86400 SECOND), `date_created`=NOW(),`admin`='%d',`reason`='%s' WHERE `name`='%s' OR `IP`='%d'", PlayerName(PlayerId), ip,Player[playerid][uID], _reason,PlayerName(PlayerId), ip);
		}else{
			mysql_query_format("INSERT INTO `ban` (`name`, `IP`, `type`, `date_end`, `date_created`, `admin`, `reason`) VALUES ('%s', '%s', '0', DATE_ADD(NOW(), INTERVAL 2*86400 SECOND), NOW(), '%d', '%s')", PlayerName(PlayerId), ip, Player[playerid][uID],_reason);
		}
		mysql_query_format("UPDATE `Players` SET `Warn`='0' WHERE `Nick`='%s'",PlayerName(PlayerId));
		format(msg, sizeof msg, "{AC3E00}Zosta³eœ zbanowany!\n\n{EAB171}Powód:\t{AC3E00}%s\n{EAB171}Administator:\t{AC3E00}%s\n{EAB171}Typ:\t{AC3E00}Czasowy (na 2 dni)", _reason,PlayerName(playerid));
		ShowPlayerDialog(PlayerId, 13124, DIALOG_STYLE_MSGBOX, "{EAB171}ZOSTA£EŒ ZBANOWANY", msg, "WyjdŸ", "");
		new name[32];
		name = PlayerName(PlayerId);
		new id = PlayerId;
		KickEx(PlayerId);
		MSGFA(COLOR_ERROR, "{FF732F}»»»{F01414}Gracz %s (%d) zosta³ zbanowany na 3 dni przez administratora %s (%d) Powód: %s | Maksymalna iloœæ Warnów", name,id, Player[playerid][Name], playerid,_reason);
		kicks++;
	}else{
		mysql_query_format("UPDATE `fg_Players` SET `Warn`=Warn+1 WHERE `Nick`='%s'",PlayerName(PlayerId));
		MSGFA(COLOR_ORANGE, "{FF732F}»»»{FFB400} Gracz %s (%d) dosta³ ostrze¿enie od administratora %s (%d).", PlayerName(PlayerId), PlayerId, PlayerName(playerid), playerid);
		MSGFA(COLOR_ORANGE, "{FF732F}»»»{FFB400} Powód: %s. Ostrze¿eñ: %d/%d", Reason, Player[PlayerId][Warns], MAX_WARNS);
		KickEx(PlayerId);
		kicks++;
	}
	return 1;
}

CMD:cz(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	for(new i=0; i<101; i++)
		SendClientMessageToAll(0x000000AA, " ");
	
	MSGA(COLOR_LIGHTGREEN,"››› Ca³y czat zosta³ ocenzurowany przez administracjê.");
	GameTextForAll("~g~~h~Cenzura", 1000, 1);
	return 1;
}
CMD:cenz(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SCM(playerid, 0x00FFFFAA, "U¿yj : /cenz [ID]");
	playermuted[gracz] = true ;
	Cenzor[gracz] = true;
	MSGFA(COLOR_RED2, "{AA3333}Gracz {FF0000}%s {AA3333}zosta³ ocenzurowany przez Admina: {AA3333}%s", PlayerName(gracz),PlayerName(gracz));
	return 1;
}
CMD:freeze(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "/Freeze [ID]");
	TogglePlayerControllable(gracz,0);
	Freeze[gracz] = true;
	MSGF(gracz,COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}zamrozi³/a ciê.", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "{3BAD00}››› {28730A}Zaprozi³eœ/aœ gracza {3BAD00}%s{28730A}.", PlayerName(gracz));
	return 1;
}
CMD:unfreeze(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /UnFreeze [ID]");
	TogglePlayerControllable(gracz,1);
	Freeze[gracz] = false;
	MSGF(gracz,COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}odmrozi³/a ciê.", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "{3BAD00}››› {28730A}Odmrozi³eœ/aœ gracza {3BAD00}%s{28730A}.", PlayerName(gracz));
	return 1;
}
CMD:weather(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new pogoda;
	if(sscanf(cmdtext,"d",pogoda))return SendClientMessage(playerid, COLOR_WHITE, "AS : /Weather [pogoda]");
	SetWeather(pogoda);
	MSGFA(COLOR_RED, "{ffe5a1}››› {eab171}%s {ffe5a1}ustawi³ pogodê {eab171}%d{ffe5a1}.", PlayerName(playerid),pogoda);
    SoundForAll(1150);
	return 1;
}
CMD:uncenz(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SCM(playerid, 0x00FFFFAA, "U¿yj : /uncenz [ID]");
	playermuted[gracz] = false ;
	Cenzor[gracz] = false;
	MSGFA(COLOR_RED, "Gracz {FF0000}%s {AA3333}- Cenzura zosta³a wy³¹czona!", PlayerName(gracz));
	return 1;
}
CMD:anncolor(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new string[500];
    strcat(string,"* ~b~ - NIEBIESKI\n");
    strcat(string,"* ~r~ - CZERWONY\n");
	strcat(string,"* ~g~ - ZIELONY\n");
	strcat(string,"* ~y~ - ZOLTY\n");
	strcat(string,"* ~l~ - CZARNY\n");
	strcat(string,"* ~p~ - ROZOWY\n");
	strcat(string,"* ~h~ - ROZJASNIA DANY KOLOR\n");
	strcat(string,"* ~n~ - OBNIZA LINIJKE\n");
	strcat(string,"* _______________PRZYKLADY_______________\n");
	strcat(string,"* ~b~~h~ - Kolor Jasno niebieski\n");
	strcat(string,"* ~b~~n~ - Kolor niebieski linijka na dole\n");
	strcat(string,"* ~b~~h~~n~ Kolor Jasno niebieski z linijka na dole\n");
    strcat(string,"_________________________________________\n");
	strcat(string,"Pamietaj jednak ze naduzycia zwiazane z tymi komendami\n");
	strcat(string,"lub przeklinanie moze sie wiazac z odebraniem ci rangi ADMIN i VIP!");
	ShowPlayerDialog(playerid,31,0,"Komendy Vipa",string,"Cofnij","Wyjdz");
	return 1;
}
CMD:killp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return  SCM(playerid, COLOR_WHITE, "AS : /Killp [ID]");
	if(!IsPlayerConnected(gracz))return SCM(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	SetPlayerHealth(gracz,0);
	MSGF(gracz,COLOR_GREEN, "››› Zosta³eœ/aœ zabity/a przez admina: %s", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "››› Zabito gracza %s", PlayerName(gracz));
	return 1;
}
CMD:raports(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new str[700];
		new name[25];
	for(new x=0;x<10;x++){
		if(RaportID[x] < 0){
			format(str,sizeof(str),"%s\nBrak Raportu",str);
		}else{
			GetPlayerName(RaportID[x],name,sizeof(name));
			format(str,sizeof(str),"%s\n%s(%d) >> %s",str,name,RaportID[x],Raport[x]);
		}
	}
	strins(str,"\nWyjdz",strlen(str),sizeof(str));
	ShowPlayerDialog(playerid,35,2,"Lista Raportow",str,"Spec","Usun");
	return 1;
}
CMD:delauta(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
    for(new x=0;x<MAX_GRACZY;x++){
		Nrgs[x] = 0;
	}
	respawnVehicles(true);
	return 1;
}

CMD:deltrailers(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	DelTrailers();
	return 1;
}
CMD:tpoff(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	SavePos = false;
	SendClientMessage(playerid,COLOR_GREEN,"Prywatne i chwilowe teleportowanie wy³¹czone!");
	return 1;
}

CMD:tpon(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	SavePos = true;
	SendClientMessage(playerid,COLOR_GREEN,"Prywatne i chwilowe teleportowanie w³¹czone!");
	return 1;
}

CMD:explode(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_LIGHTBLUE, "* Wpisz: /explode [ID gracza]");
	new Float:x,Float:y,Float:z;
	if(IsPlayerConnected(gracz)) {
		GetPlayerPos(gracz,x,y,z);
		CreateExplosion(x,y,z,2,50);
		MSGF(gracz,COLOR_GREEN, "Zosta³eœ/aœ wysadzony przez admina: %s", PlayerName(playerid));
		MSGF(playerid,COLOR_GREEN,  "Wysadzi³eœ/aœ gracza %s", PlayerName(gracz));
	}else{
		MSGF(playerid, COLOR_PINK,"-= ID %d nie jest aktywnym graczem !!!", gracz);
	}
	return 1;
}
CMD:asweapons(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	SetPlayerHealth(playerid, 100);
	GivePlayerWeapon(playerid, 24, 10000);
	GivePlayerWeapon(playerid, 27, 10000);
	GivePlayerWeapon(playerid, 31, 10000);
	GivePlayerWeapon(playerid, 38, 10000);
	GivePlayerWeapon(playerid, 39, 10000);
	GivePlayerWeapon(playerid, 42, 10000);
    SendClientMessage(playerid, COLOR_YELLOW, "Otrzyma³eœ/aœ zestaw broni dla admina. ");
	return 1;
}
CMD:ustawkatp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	return SCM(playerid,COLOR_WHITE,"Stwórz 2 spawny aren do ustawki, /ustawkatp1 /ustawkaTP2");	
}
CMD:ustawkatp1(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	GetPlayerPos(playerid,UstawkaX[0],UstawkaY[0],UstawkaZ[0]);
	UstawkaInt = GetPlayerInterior(playerid);
	SCM(playerid,COLOR_GREEN,"Teleport nr.1 do areny zosta³ zapisany!");
	return 1;
}
CMD:ustawkatp2(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	GetPlayerPos(playerid,UstawkaX[1],UstawkaY[1],UstawkaZ[1]);
	UstawkaInt = GetPlayerInterior(playerid);
	SCM(playerid,COLOR_GREEN,"Teleport nr.2 do areny zosta³ zapisany!");
	return 1;
}
CMD:ustawkaon(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	UstawkaON = true;
	MSGA(COLOR_GREEN,"Admin w³¹czy³ grê USTAWKA aby do³¹czyæ wpisz /Ustawka");
    SoundForAll(1050);
	return 1;
}
CMD:ustawkaoff(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	UstawkaON = false;
	MSGA(COLOR_GREEN,"Admin wy³¹czy³ grê USTAWKA");
	return 1;
}
CMD:spec(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SCM(playerid, COLOR_WHITE, "Wpisz: /Spec [playerid]");
	if(!IsPlayerConnected(gracz))return  SCM(playerid, COLOR_RED, "SPEC: Ten gracz nie jest aktywny!");
	
	GetPlayerPos(playerid,SpecPosX[playerid],SpecPosY[playerid],SpecPosZ[playerid]);
	SpecInt[playerid] = GetPlayerInterior(playerid);
	SpecVW[playerid] = GetPlayerVirtualWorld(playerid);
	StartSpec(playerid, gracz);
	gSpectateType[playerid] = 1;
	return 1;
}
CMD:specoff(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	SpecOff[playerid] = true;
	
	StopSpec(playerid);
	gSpectateID[playerid] = -1;
	TogglePlayerSpectating(playerid, 0);
	gSpectateType[playerid] = 0;
	return 1;
}
CMD:delwalizka(playerid, cmdtext[]){
    if(!IsAdmin(playerid,1))return 0;
    DestroyDynamicPickup(BagPickup);
    BagCash = 0;
    BagEnabled = false;
	MSGFA(COLOR_ERROR, "››› %s usun¹³ walizkê!", PlayerName(playerid));
	return 1;
}

CMD:delpodkowa(playerid, cmdtext[]){
    if(!IsAdmin(playerid,1))return 0;
    if (!BagEnabled) return SendClientMessage (playerid, -1, "Podkowa nie zostala jeszcze stworzona.");
	
	DestroyDynamicPickup(PodkowaPickup);
    PodkowaEnabled = false;
	PodkowaCash = 0;
	MSGFA(COLOR_ERROR, "››› %s usun¹³ podkowê!", PlayerName(playerid));
	return 1;
}

CMD:walizka(playerid, cmdtext[]){
	if (!IsAdmin(playerid,2))return 0;
	
	new Cash, Hint[128];
	if (sscanf(cmdtext, "ds[128]", Cash, Hint)) return SCM(playerid, COLOR_ERROR, "››› Wpisz: /walizka [kasa] [podpowiedŸ]");
	if (Cash < 1 || Cash > 99999) return SCM(playerid, COLOR_ERROR, "››› Niepoprawna suma.");
	if (BagEnabled) DestroyDynamicPickup(BagPickup);

	new Float:PlayerPos[3];
	GetPlayerPos(playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);
	
	BagPickup = CreateDynamicPickup(1210, 23, PlayerPos[0] + 2.0,PlayerPos[1] + 1.0, PlayerPos[2]);
	BagEnabled = true;
	BagCash = Cash;
	new STring[160];
	
	format(STring, sizeof(STring), "››› Administrator %s (%d) zgubi³ walizkê pe³n¹ forsy. PodpowiedŸ: %s.", PlayerName(playerid), playerid, Hint);
	SendClientMessageToAll(COLOR_ERROR, STring);
    SoundForAll(1057);
	format(STring, sizeof(STring), "Admin zgubil walizke.~n~Podpowiedz: ~r~~h~%s.", Hint);
	FadeForPlayer(7,STring);
	return 1;
}

CMD:say(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new tmp[128];
	if(sscanf(cmdtext,"s[128]",tmp))return SCM(playerid, COLOR_WHITE, "AS: /say [text]");
	format(tmp, sizeof(tmp), "{ffe5a1}››› {eab171}%s {ffe5a1}.",tmp);
	SendClientMessageToAll(0x0, tmp);
	return 1;
}
CMD:ashelp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new StrinG[2900];
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
	strcat(StrinG,"{FF0000}/RspAuta {FFFFFF}- respawn wszystkich pojazdow\n");
	strcat(StrinG,"{FF0000}/RspTrailers {FFFFFF}- respawn wszystkich przyczep\n");
	strcat(StrinG,"{FF0000}/DelAuta {FFFFFF}- usuwasz swtorzone pojazdy\n");
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
	return 1;
}
CMD:ashelp2(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
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
	ShowPlayerDialog(playerid,DIALOG_ACMD2,0,"Komendy administracji",StrinG,"OK","Cofnij");
	return 1;
}
CMD:acmd(playerid,cmdtext[]){
	return cmd_ashelp(playerid,cmdtext);
}
CMD:acmd2(playerid,cmdtext[]){
	return cmd_ashelp2(playerid,cmdtext);
}
CMD:disarm(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /Disarm [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	ResetPlayerWeapons(gracz);
	MSGF(gracz,COLOR_GREEN, "{AA3333}Zosta³eœ/aœ rozbrojony/a przez admina: {FF0000}%s", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "{AA3333}Rozbroi³eœ/aœ gracza {FF0000}%s", PlayerName(gracz));
	return 1;
}
CMD:podkowa(playerid, cmdtext[]){
	if(!IsAdmin(playerid,1))return 0;
	new Cash, Hint[128];
	if(sscanf(cmdtext, "ds[255]", Cash, Hint))return SCM(playerid, COLOR_ERROR, "››› Wpisz: /podkowa [kasa] [podpowiedŸ]");
	if(Cash < 1 || Cash > 10000000)return SCM(playerid, COLOR_ERROR, "››› Niepoprawna suma.");
	if(PodkowaEnabled) DestroyDynamicPickup(PodkowaPickup);

	new Float:PlayerPos[3];
	GetPlayerPos(playerid, PlayerPos[0], PlayerPos[1], PlayerPos[2]);
	PodkowaPickup = CreateDynamicPickup(954, 23, PlayerPos[0] + 2.0,PlayerPos[1] + 1.0, PlayerPos[2]);
	PodkowaEnabled = true;
	PodkowaCash = Cash;
	new STring[100];
	MSGFA(COLOR_ERROR, "››› %s (%d) zgubi³ podkowê! PodpowiedŸ: %s.", PlayerName(playerid), playerid, Hint);
    SoundForAll(1057);
	format(STring, sizeof(STring), "%s zgubil podkowe.~n~Podpowiedz: ~b~~h~%s.", PlayerName(playerid), Hint);
	FadeForPlayer(7,STring);
	return 1;
}
CMD:kick(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz,powod[64];
	if(sscanf(cmdtext,"us[64]",gracz,powod))return SCM(playerid, COLOR_RED, "Wpisz: /kick [ID] [powód]");
	if(gracz < 0 || gracz >= MAX_GRACZY) return SCM(playerid, COLOR_RED, "Zle ID gracza");
	if(!IsPlayerConnected(gracz)) return SCM(playerid, COLOR_RED, "Nie ma takiego gracza");
	new playername[MAX_PLAYER_NAME];
	new kickname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, playername, sizeof(playername));
	GetPlayerName(gracz, kickname, sizeof(kickname));
	new tmp[162];
	format(tmp, sizeof(tmp), "››› {970000}%s {D50101}zosta³/a wyrzucony/a z serwera przez {970000}%s {D50101}za {970000}%s{D50101}.", kickname, playername, powod);
	WriteLogFormat("[KICK] %s admin %s powod %s",kickname, playername, powod);
	SendClientMessageToAll(0xD50101FF, tmp);
	KickEx(gracz);
	kicks++;
	return 1;
}
CMD:ban(playerid, params[]) {
    if(!IsAdmin(playerid,2)) return 0;
	
	
	new ID, type, time, input_reason[64], reason[64], ip[16],msg[256], _str[64];
	if(sscanf(params, "dcds[64]", ID, type, time, input_reason)) {
		if(sscanf(params, "ds[64]", ID, input_reason)) 
			return SCM(playerid, -1, "{AC3E00}/ban (czasowy) [id] [typ] [czas] [powód] | /ban (permanentny) [id] [powód]");		
	}
	
	if (!IsPlayerConnected(ID)) return SCM(playerid, -1, "Nie ma gracza z tym ID");
	if (Player[playerid][Admin] < Player[ID][Admin])return SCM(playerid, -1, "{AC3E00}Nie mo¿esz u¿yæ tej komeny na innym administrato¿e");
	
	GetPlayerIp(ID, ip, 16);
	switch(tolower(type)) {
		case 'd': {
			format(_str, sizeof _str, "%i dni", time);
			time = time * 86400;
		} case 'g', 'h': {
			format(_str, sizeof _str, "%i godzin", time);
			time = time * 3600;
		} case 'm': {
			format(_str, sizeof _str, "%i minut", time);
			time = time * 60;
		} 
		case 0: {
			mysql_real_escape_string(input_reason, reason);
			mysql_query_format("SELECT `name` FROM `ban` WHERE `name` = '%s'", PlayerName(ID));
			mysql_store_result();
			if(mysql_num_rows()){
				mysql_query_format("DELETE FROM `ban` WHERE `name`='%s'",PlayerName(ID));
				mysql_query_format("INSERT INTO `ban` (`name`, `IP`, `type`, `date_created`, `date_end`, `admin`, `reason`) VALUES ('%s', '%s', '0', NOW(), NULL, '%d', '%s')", PlayerName(ID), ip, Player[playerid][uID], reason);
			}else{
				mysql_query_format("INSERT INTO `ban` (`name`, `IP`, `type`, `date_created`, `date_end`, `admin`, `reason`) VALUES ('%s', '%s', '0', NOW(), NULL, '%d', '%s')", PlayerName(ID), ip, Player[playerid][uID], reason);
			}
			mysql_free_result();
			format(msg, sizeof msg, "\n{EAB171}Powód:\t{AC3E00}%s\n{EAB171}Administator:\t{AC3E00}%s\n{EAB171}Typ:\t{AC3E00}Permanentny", reason,PlayerName(playerid));
			ShowPlayerDialog(ID, 13124, DIALOG_STYLE_MSGBOX, "{EAB171}ZOSTA£EŒ ZBANOWANY", msg, "WyjdŸ", "");
			new name[32];
			name = PlayerName(ID);
			new id = ID;
			KickEx(ID);
			MSGFA(COLOR_ERROR,"{F01414}Administrator %s Zbanowa³ %s(%i) powód: %s ",PlayerName(playerid), name,id,reason);
			WriteLogFormat("[BAN] %s admin %s powod %s",name, PlayerName(playerid), reason);
			bans++;
			kicks++;
			return 1;
		}
		default: {
			return SCM(playerid, -1, "{FFE5A1}Typy banów: {EAB171}d - dni {FFE5A1}| {EAB171}h - godziny {FFE5A1}| {EAB171}m - minuty");
		}
	}
	mysql_real_escape_string(input_reason, reason);
	mysql_query_format("SELECT 1 FROM `ban` WHERE `name` = '%s'", PlayerName(ID));
	mysql_store_result();
	if(mysql_num_rows()){
		mysql_query_format("UPDATE `ban` SET `name`='%s', IP='%s', `type`='0', `date_end`=DATE_ADD(NOW(), INTERVAL %d SECOND), `date_created`=NOW(),`admin`='%d',`reason`='%s' WHERE `name`='%s' OR `IP`='%s'", PlayerName(ID), ip,  time,Player[playerid][uID], reason,PlayerName(ID), ip);
	}else{
		mysql_query_format("INSERT INTO `ban` (`name`, `IP`, `type`, `date_created`, `date_end`, `admin`, `reason`) VALUES ('%s', '%s', '0', NOW(), DATE_ADD(NOW(), INTERVAL %d SECOND), '%d', '%s')", PlayerName(ID), ip, time, Player[playerid][uID], reason);
	}
	format(msg, sizeof msg, "{AC3E00}Zosta³eœ zbanowany!\n\n{EAB171}Powód:\t{AC3E00}%s\n{EAB171}Administator:\t{AC3E00}%s\n{EAB171}Typ:\t{AC3E00}Czasowy (na %s)", reason,PlayerName(playerid),_str);
	ShowPlayerDialog(ID, 13124, DIALOG_STYLE_MSGBOX, "{EAB171}ZOSTA£EŒ ZBANOWANY", msg, "WyjdŸ", "");
	KickEx(ID);
	MSGFA(COLOR_ERROR,"{F01414}Administrator %s Zbanowa³ %s(%i) na %s powód: %s.",PlayerName(playerid),PlayerName(ID),ID,_str,reason);
	WriteLogFormat("[BAN] %s admin %s powod %s na %s",PlayerName(ID), PlayerName(playerid), reason,_str);
	bans++;
	return 1;
}
CMD:crate(playerid,cmdtext[])
{
	if(!IsAdmin(playerid,1)) return 0;
	
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /Crate [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	
	new Float:x,
		Float:y,
		Float:z,
		Float:dist = 4.0;

	GetPlayerPos(gracz, x, y, z);
	
	for(new cage=0; cage < 4; cage++)
	{
		DestroyObject(Crate[gracz][cage]);
	}
	 
	Crate[gracz][0] = CreateObject(971, x, y+dist, z, 0.0, 0.0, 0.0);
	Crate[gracz][1] = CreateObject(971, x+dist, y, z, 0.0, 0.0, 90.0);
	Crate[gracz][2] = CreateObject(971, x-dist, y, z, 0.0, 0.0, 270.0);
	Crate[gracz][3] = CreateObject(971, x, y-dist, z, 0.0, 0.0, 180.0);
	
	MSGF(gracz,COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}zakratowa³/a ciê!", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "{3BAD00}››› {28730A}Zakratowa³eœ/aœ gracza {3BAD00}%s{28730A}!", PlayerName(gracz));
	return 1;
}

CMD:uncrate(playerid,cmdtext[])
{
	if(!IsAdmin(playerid,2)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return  SendClientMessage(playerid, COLOR_WHITE, "AS : /Uncrate [ID]");	
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	for(new x=0;x<4;x++)
	{
		DestroyObject(Crate[gracz][x]);
	}
	MSGF(gracz,COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}odkratowa³/a ciê!", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "{3BAD00}››› {28730A}Odkratowa³eœ/aœ gracza {3BAD00}%s{28730A}!", PlayerName(gracz));
	return 1;
}
CMD:setip(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new gracz,interior;
	if(sscanf(cmdtext,"ud",gracz,interior))return  SendClientMessage(playerid, COLOR_WHITE, "AS: /setip [ID] [ID interioru]");
	if(interior < 0){
		SendClientMessage(playerid, COLOR_WHITE, "Z³e ID interioru !");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	SetPlayerInterior(gracz,interior);
	MSGF(gracz,COLOR_GREEN,  "››› Admin %s przerzuci³/a ciê do interioru %d.", PlayerName(playerid),interior);
	MSGF(playerid,COLOR_GREEN,"››› Przerzuci³eœ/aœ gracza %s do interioru %d.", PlayerName(gracz),interior);
	return 1;
}
CMD:mute(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz,czas;
	if(sscanf(cmdtext,"ud",gracz,czas))return SendClientMessage(playerid, 0x00FFFFAA, "Uzyj : /mute [ID] [Czas(min)]");
	playermuted[gracz] = true ;
	new tmp[128];
	format(tmp, sizeof(tmp), "%s zostal/a uciszony/a przez Admina: %s na %d min.", PlayerName(gracz),PlayerName(playerid),czas);
	SendClientMessageToAll(COLOR_RED2, tmp);
	KillTimer(MuteTimer[gracz]);
	MuteTimer[gracz] = SetTimerEx("UnmutePlayer",czas*60000,0,"i",gracz);
	return 1;
}
CMD:unmute(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, 0x00FFFFAA, "Uzyj : /unmute [ID]");
		return 1;
	}
	playermuted[gracz] = false ;
	new tmp[80];
	format(tmp, sizeof(tmp), "%s zostal/a odciszony/a przez Admina: %s", PlayerName(gracz),PlayerName(playerid));
	SendClientMessageToAll(COLOR_GREEN, tmp);
    SoundForAll(1050);
	KillTimer(MuteTimer[gracz]);
	return 1;
}
CMD:jail(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz,czas;
	if(sscanf(cmdtext,"ud",gracz,czas)){
	    SendClientMessage(playerid, 0x00FFFFAA, "Uzyj : /jail [ID] [Czas(min)]");
		return 1;
	}
	if(!IsPlayerConnected(gracz) || gracz < 0 || gracz >= MAX_GRACZY) return SendClientMessage(playerid, COLOR_RED2, "Nie ma takiego gracza!");
	if(czas < 1 || czas > 60) return SendClientMessage(playerid, COLOR_RED2, "Czas mo¿e byæ od 1-60 min.");
	Wiezien[gracz] = true;
	new tmp[512];
	format(tmp, sizeof(tmp), "{D50101}››› {970000}%s {D50101}zostal/a uwiêziony/a przez {970000}%s{D50101} na {970000}%d min{D50101}.", PlayerName(gracz),PlayerName(playerid),czas);
	SendClientMessageToAll(COLOR_RED2, tmp);
	new rand = random(sizeof(CelaSpawn));
	SetPlayerPos(gracz, CelaSpawn[rand][0], CelaSpawn[rand][1], CelaSpawn[rand][2]);
	SetPlayerInterior(gracz,0);
	TogglePlayerControllable(gracz,0);
	ResetPlayerWeapons(gracz);
	KillTimer(JailTimer[gracz]);
	JailTimer[gracz] = SetTimerEx("UnjailPlayer",czas*60000,0,"i",gracz);
	return 1;
}
CMD:unjail(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, 0x00FFFFAA, "Uzyj : /unjail [ID]");
		return 1;
	}
	Wiezien[gracz] = false;
	SetPlayerRandomSpawn(gracz);
	new tmp[150];
	format(tmp, sizeof(tmp), "{D50101}››› {970000}%s {D50101}zostal/a wypuszczony/a z wiêzienia przez {970000}%s{D50101}.", PlayerName(gracz),PlayerName(playerid));
	SendClientMessageToAll(COLOR_RED, tmp);
    SoundForAll(1150);
	KillTimer(JailTimer[gracz]);
	return 1;
}
CMD:armorid(playerid,cmdtext[]){

	if(!IsAdmin(playerid,2)) return 0;

	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /Armorid [ID]");
		return 1;
	}

	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	SetPlayerArmour(gracz,100);

	new tmp[64];
	format(tmp, sizeof(tmp), "››› %s da³/a ci pancerz", PlayerName(playerid));
	SendClientMessage(gracz,COLOR_GREEN, tmp);

	format(tmp, sizeof(tmp), "››› Da³eœ/aœ pancerz graczowi %s", PlayerName(gracz));
	SendClientMessage(playerid,COLOR_GREEN, tmp);

	return 1;
}
CMD:setworld(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new gracz,world;
	if(sscanf(cmdtext,"ud",gracz,world))return  SendClientMessage(playerid, COLOR_WHITE, "AS: /SetWorld [ID] [ID Virtual World'a]");
	if(world < 0){
		SendClientMessage(playerid, COLOR_WHITE, "Z³e ID Virtual World'a");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	SetPlayerVirtualWorld(gracz,world);
	new tmp[80];
	format(tmp, sizeof(tmp), "››› Admin %s zmieni³/a ci Virtual Worlda na %d.", PlayerName(playerid),world);
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "››› Zmieni³eœ/aœ Vitrual World graczowi %s na %d.", PlayerName(gracz),world);
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}
CMD:bombyoff(playerid,cmdtext[]){

	if(!IsAdmin(playerid,2)) return 0;

	SendClientMessage(playerid,COLOR_GREEN,"››› Wylaczyles(as) mo¿liwoœæ podkladania bomb!");
	Bombs = false;

	foreachPly (j) {
		PickDestroy(Bombus[j]);
		Bomber[j] = false;
	}

	return 1;
	
}
CMD:bombyon(playerid,cmdtext[]){

	if(!IsAdmin(playerid,2)) return 0;

	SendClientMessage(playerid,COLOR_GREEN,"››› W³¹czy³eœ(as) mo¿liwoœæ podkladania bomb!");
	Bombs = true;
	return 1;
	
}
CMD:delcar(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new vehid;
	new bool:block;
	vehid = GetPlayerVehicleID(playerid);
	for(new x=0;x<HOUSES_LOOP;x++){
		if(HouseInfo[x][hCarid] == vehid){
			SendClientMessage(playerid,COLOR_RED2,"››› Prywatnego pojazdu nie mozna usunac!");
            PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
			block = true;
			break;
		}
	}
	if(block) return 1;
	if(vehid < MaxPojazdow){
		SendClientMessage(playerid,COLOR_RED2,"››› Tego pojazdu nie mozna usunac!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	DestroyVehicle(vehid);
	SendClientMessage(playerid,COLOR_GREEN,"››› Pojazd usuniety!");
	return 1;	
}

CMD:m(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	SetPlayerHealth(playerid, 100);
	SendClientMessage(playerid, COLOR_GREEN, "Uzdrowiles sie");
	return 1;
	
}
CMD:skinp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz,skin;
	if(sscanf(cmdtext,"ud",gracz,skin)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /SkinP [ID] [ID skina]");
		return 1;}
	if(!IsValidSkin(skin)){
		SendClientMessage(playerid, COLOR_WHITE, "Z³e ID skina !");
		return 1;}
	if(!IsPlayerConnected(gracz)){SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");return 1;}
	SetPlayerSkin(gracz,skin);
	new tmp[80];
	format(tmp, sizeof(tmp), "››› Admin %s zmieni³/a ci skina.", PlayerName(playerid));
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "››› Zmieni³eœ/aœ graczowi %s skina na %d.", PlayerName(gracz),skin);
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}
CMD:respawn(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "/Respawn [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	SpawnPlayer(gracz);
	MSGF(gracz,COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}zrespawnowa³/a ciê!", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "{3BAD00}››› {28730A}Zrespawnowa³eœ/aœ gracza {3BAD00}%s{28730A}!", PlayerName(gracz));
	return 1;
}
CMD:setbounty(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new gracz,bountyy;
	if(sscanf(cmdtext,"ud",gracz,bountyy)){
	    SendClientMessage(playerid, COLOR_WHITE, "* Uzyj: /setbounty [id_gracza] [suma]");
		return 1;
	}

	if(!IsPlayerConnected(gracz)){
	    SendClientMessage(playerid, COLOR_RED2,"››› Nie ma takiego gracza!");
		return 1;
	}

	bounty[gracz] = bountyy;

	new tmp[128];
	format(tmp, sizeof(tmp), "* Zaplaciles nagrode za %s (id: %d) wysokosci $%d.", PlayerName(gracz),gracz,bountyy);
	SendClientMessage(playerid, COLOR_YELLOW, tmp);
	format(tmp, sizeof(tmp), "* Twoja glowa jest warta teraz $%d, podziekuj adminowi: %s (id: %d).", bountyy,PlayerName(playerid),playerid);
	SendClientMessage(gracz, COLOR_YELLOW, tmp);

	return 1;
}
CMD:acolor(playerid,cmdtext[]){
	if(!IsAdmin(playerid,2)) return 0;
	new colorplayer,color;
	if(sscanf(cmdtext,"ud",colorplayer,color)){
	    SendClientMessage(playerid,COLOR_WHITE, " /Acolor [ID] [ID koloru]");
		return 1;
	}
	if(color == 1){SetPlayerColor(colorplayer, COLOR_GREY);
	} else if(color == 2){SetPlayerColor(colorplayer, COLOR_LIGHTGREEN);
	} else if(color == 3){SetPlayerColor(colorplayer, COLOR_RED);
	} else if(color == 4){SetPlayerColor(colorplayer, COLOR_YELLOW);
	} else if(color == 5){SetPlayerColor(colorplayer, COLOR_WHITE);
	} else if(color == 6){SetPlayerColor(colorplayer, COLOR_BLUEX);
	} else if(color == 7){SetPlayerColor(colorplayer, COLOR_ORANGE);
	} else if(color == 8){SetPlayerColor(colorplayer, COLOR_PINK);
	} else if(color == 9){SetPlayerColor(colorplayer, 0xFFFFFF00);
	} else if(color == 10){SetPlayerColor(colorplayer, COLOR_VIOLET);
	} else if(color == 11){SetPlayerColor(colorplayer, COLOR_BLACK);
	} else if(color == 12){SetPlayerColor(colorplayer, COLOR_BROWN);
	} else if(color == 13){SetPlayerColor(colorplayer, COLOR_LIGHTBLUE);
	} else if(color == 14){SetPlayerColor(colorplayer, COLOR_GREEN);
	} else if(color == 15){SetPlayerColor(colorplayer, COLOR_KREM);
	} else if(color == 16){SetPlayerColor(colorplayer, COLOR_ADMIN);
	} else {
		SendClientMessage(playerid, COLOR_ADMIN, "Z³y ID koloru: ID (od 1 do 16)");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	new tmp[64];
	format(tmp, sizeof(tmp), "››› Zmieni³eœ/aœ kolor graczowi %s na %d",PlayerName(colorplayer), color);
	SendClientMessage(playerid,COLOR_GREEN,tmp);
	format(tmp, sizeof(tmp), "››› Admin %s zmieni³/a ci kolor nicku",PlayerName(playerid));
	SendClientMessage(colorplayer,COLOR_GREEN,tmp);
	
	//new buf[80];
	//format (buf, sizeof (buf), "%s {%06x}%s (%d)", (Player[colorplayer][Admin]==5)? ("{FF0000}Admin RCON {aaaaaa}|"): (Player[colorplayer][Admin]>=2)? ("{FF0000}Admin {aaaaaa}|"): (Player[colorplayer][Admin]==1)? ("{006600}Moderator {aaaaaa}|"): (Player[colorplayer][VIP])? ("{F2EC91}VIP {aaaaaa}|"): (""), (GetPlayerColor (colorplayer) >>> 8), PlayerName(colorplayer),colorplayer);
	//UpdateDynamic3DTextLabelText (nickname_labels[colorplayer], -1,  buf);
	return 1;
}

//Admin
CMD:uncrateall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	foreachPly (i) 
	{
		for(new j=0;j<4;j++)
		{
			DestroyObject(Crate[i][j]);
		}
	}
	MSGFA(COLOR_GREEN, "%s  odkratowa³/a wszystkich graczy!", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}

CMD:joininfoon(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	joininfo = 1;
	SendClientMessageToAll(COLOR_GREEN, "Informacje o wchodzeniu graczy na serwer w³¹czone");
    SoundForAll(1150);
	return 1;
}
CMD:joininfooff(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	joininfo = 0;
	SendClientMessageToAll(COLOR_GREEN, "Informacje o wchodzeniu graczy na serwer wylaczone");
    SoundForAll(1150);
	return 1;
}
CMD:podgladpmon(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	podgladPM = 1;
	SendClientMessageToAdmins(COLOR_BLUE2,"Prywatne wiadomoœci innych graczy na czacie w³¹czone!");
	return 1;
}
CMD:podgladpmoff(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	podgladPM = 0;
	SendClientMessageToAdmins(COLOR_BLUE2,"Prywatne wiadomoœci innych graczy na czacie wy³¹czone!");
	return 1;
}

CMD:joininfoadminon(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	joininfoadmin = 1;
	SendClientMessageToAdmins(COLOR_GREEN, "Informacje dla adminow o wchodzeniu graczy na serwer wlaczone");
	return 1;
}
CMD:dragend(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	DragON = false;
	DragMiejsce = 0;
	Dragliczba = 0;
	KillTimer(DragTimer);

	SendClientMessageToAllDrag(COLOR_RED2,"››› Wyscig [Drag] zakoñczony przez Admina!");
	foreachPly (i) {
		if(Drager[i]){
			DisablePlayerCheckpoint(i);
			DisablePlayerRaceCheckpoint(i);
			Drager[i] = false;
			SetPlayerVirtualWorld(i,0);
		}
	}
	return 1;
}
CMD:joininfoadminoff(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	joininfoadmin = 0;
	SendClientMessageToAdmins(COLOR_GREEN, "Informacje dla adminow o wchodzeniu graczy na serwer wylaczone");
	return 1;
}
CMD:chaton(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	ChatON = true;
	SendClientMessageToAll(COLOR_LIGHTBLUE, "Czat zosta³ w³¹czony przez admina!");
    SoundForAll(1050);
	return 1;
}
CMD:chatoff(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	ChatON = false;
	SendClientMessageToAll(COLOR_RED2, "Czat zosta³ wy³¹czony przez admina!");
    SoundForAll(1050);
	return 1;
}
CMD:prot(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return  SendClientMessage(playerid, 0x00FFFFAA, "U¿yj : /prot [ID]");
	Immunitet[gracz] = true;
	MSGFA(COLOR_RED, "{D50101}››› {970000}%s {D50101}otrzyma³ Immunitet od admina {970000}%s{D50101}.", PlayerName(gracz),PlayerName(playerid));
	return 1;
}
CMD:muteall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new tmp[128];
	format(tmp, sizeof(tmp), "{ffe5a1}››› {eab171}%s {ffe5a1}uciszy³/a wszystkich graczy!", PlayerName(playerid));
	SendClientMessageToAll(0x0, tmp);
    SoundForAll(1050);

	foreachPly (i) {
		playermuted[i] = true ;
		KillTimer(MuteTimer[i]);
	}
	return 1;
}
CMD:unmuteal(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new tmp[128];
	format(tmp, sizeof(tmp), "{ffe5a1}››› {eab171}%s {ffe5a1}odciszy³/a wszystkich graczy!", PlayerName(playerid));
	SendClientMessageToAll(0x0, tmp);
    SoundForAll(1050);
	foreachPly (i) {
		playermuted[i] = false ;
		KillTimer(MuteTimer[i]);
	}
	return 1;
}
CMD:unprot(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, 0x00FFFFAA, "U¿yj : /unprot [ID]");
	Immunitet[gracz] = false;
	MSGFA(COLOR_RED2, "{D50101}››› {970000}%s {D50101}zosta³ pozbawiony Immunitetu przez {970000}%s{D50101}.", PlayerName(gracz), PlayerName(playerid));
	return 1;
}
CMD:unwarn(playerid, params[]){
	if(!IsAdmin(playerid,3)) return 0;
	new PlayerId;
	if(sscanf(params, "u", PlayerId))return SCM(playerid, COLOR_ERROR, "{FF732F}»»»{F01414}Wpisz: /unwarn [id gracza]");
    if(PlayerId == INVALID_PLAYER_ID)return SCM(playerid, COLOR_ERROR, "{FF732F}»»»{F01414}Nie ma gracza o podanym id.");
	if(Player[PlayerId][Warns] == 0)return SCM(playerid, COLOR_ERROR, "{FF732F}»»»{F01414}Gracz nie ma ostrze¿eñ.");
	if(Player[playerid][Admin] < Player[PlayerId][Admin])return SCM(playerid, COLOR_ERROR, "Nie mo¿esz u¿yæ tej komeny na administrato¿e o wy¿szym poziomie");
	Player[PlayerId][Warns]--;
	mysql_query_format("UPDATE `Players` SET `Warn`=Warn -1 WHERE `Nick`='%s'",PlayerName(PlayerId));
	new String[255];
	format(String, sizeof(String), "{FF732F}»»»{F01414}Administrator %s (%d) zdj¹³ ci ostrze¿enie. Pozosta³o ostrze¿eñ: %d/%d.", PlayerName(playerid), playerid, Player[PlayerId][Warns], MAX_WARNS);
	SCM(PlayerId, COLOR_ORANGE, String);
	format(String, sizeof(String), "{FF732F}»»»{F01414}Zdj¹³eœ/aœ ostrze¿enie graczowi %s (%d). Pozosta³o ostrze¿eñ: %d/%d.", PlayerName(PlayerId), PlayerId, Player[PlayerId][Warns], MAX_WARNS);
	SCM(playerid, COLOR_GREEN, String);
	return 1;
}

CMD:wgend(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	SendClientMessageToAll(COLOR_RED2," *** WG zosta³o przerwane przez admina.");
    SoundForAll(1150);
	WG_End();
	//ChowanyEnd();
	return 1;
}

CMD:chend(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	SendClientMessageToAll(COLOR_RED2," *** Chowany zosta³ przerwany przez admina.");
    SoundForAll(1150);
	CH_End();
	//ChowanyEnd();
	return 1;
}

CMD:hayend(playerid,cmdtext[]) {
	if(!IsAdmin(playerid,3)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	HAY_End();
	SendClientMessageToAll(COLOR_RED2," *** Hay zosta³ przerwany przez admina.");
	return 1;
}
CMD:ssend(playerid,cmdtext[]) {
	if(!IsAdmin(playerid,3)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	SS_End();
	SendClientMessageToAll(COLOR_RED2," *** Skoki spadochronowe zosta³y przerwane przez admina.");
	return 1;
}
CMD:twend(playerid,cmdtext[]) {
	if(!IsAdmin(playerid,3)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	TW_End();
	SendClientMessageToAll(COLOR_RED2," *** Tower zosta³ przerwany przez admina.");
	return 1;
}

CMD:gun50(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new waeponcmd,ammocmd;
	if(sscanf(cmdtext,"dd",waeponcmd,ammocmd)){
	    SendClientMessage(playerid,COLOR_WHITE,"AS: /givegun [ID broni] [Amunicja]");
		return 1;
	}
	if(waeponcmd < 0 || waeponcmd > 46){
	    SendClientMessage(playerid,COLOR_RED2,"››› Z³e ID Broni!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(ammocmd < 1 || ammocmd > 9999){
	    SendClientMessage(playerid,COLOR_RED2,"››› Z³a iloœæ amunicji!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new Float:px,Float:py,Float:pz;
	GetPlayerPos(playerid,px,py,pz);
	new tmp[128];
	foreachPly (i) {
		if(PlayerToPoint(50,i,px,py,pz)){
			GivePlayerWeapon(i,waeponcmd,ammocmd);
			format(tmp, sizeof(tmp), "%s da³/a ci broñ: %s i %d amunicji",PlayerName(playerid),ReturnWeaponName(waeponcmd),ammocmd);
			SendClientMessage(i,COLOR_GREEN,tmp);
		}
	}
	format(tmp, sizeof(tmp), "Da³eœ/aœ wszystkim w zasiêgu 50m. broñ: %s i %d amunicji",ReturnWeaponName(waeponcmd),ammocmd);
	SendClientMessage(playerid,COLOR_GREEN,tmp);

	return 1;
}
CMD:slap(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /Slap [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	new Float:zycie;
	GetPlayerHealth(gracz,zycie);
	SetPlayerHealth(gracz,floatround(zycie)-10);
	MSGF(gracz,COLOR_GREEN, "››› Admin %s zabra³/a ci 10 pkt. ¿ycia!", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "››› Zabra³eœ/aœ 10 pkt. ¿ycia graczowi %s", PlayerName(gracz));
	return 1;
}
CMD:repairall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new veh;
	foreachPly (i) {
		if(IsPlayerInAnyVehicle(i)){
			veh = GetPlayerVehicleID(i);
			RepairVehicle(veh);
		}
	}
	new tmp[125];
	format(tmp, sizeof(tmp), "{ffe5a1}››› {eab171}%s {ffe5a1}naprawi³/a wszystkim pojazdy!", PlayerName(playerid));
	SendClientMessageToAll(COLOR_GREEN, tmp);
    SoundForAll(1150);
	return 1;
}
CMD:vehgod(playerid,cmdtext[]){

	if(!IsAdmin(playerid,3)) return 0;

	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /VehGod [ID]");
		return 1;
	}

	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new veh = GetPlayerVehicleID(gracz);
	RepairVehicle(veh);
	SetVehicleHealth(veh,999999);
	new tmp[80];
	format(tmp, sizeof(tmp), "››› %s zrobi³/a twój pojazd niezniszczalnym", PlayerName(playerid));
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "››› Zrobi³eœ/aœ pojazd gracza %s niezniszczalnym", PlayerName(gracz));
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}
CMD:givegunall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new weaponcomd,ammocmdw;
	if(sscanf(cmdtext,"dd",weaponcomd,ammocmdw))return SendClientMessage(playerid,COLOR_WHITE,"/givegun [ID broni] [Amunicja]");
	if(weaponcomd < 0 || weaponcomd > 46){
	    SendClientMessage(playerid,COLOR_RED2,"››› Z³e ID Broni!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(ammocmdw < 1 || ammocmdw > 9999999){
	    SendClientMessage(playerid,COLOR_RED2,"››› Z³a iloœæ amunicji!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	foreachPly (i) {
		GivePlayerWeapon(i,weaponcomd,ammocmdw);
	}
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}da³/a wszystkim broñ {eab171}%s{ffe5a1} i {eab171}%d {ffe5a1}amunicji.",PlayerName(playerid),ReturnWeaponName(weaponcomd),ammocmdw);
    SoundForAll(1150);
	return 1;
}
CMD:armourgod(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "/ArmourGod [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	SetPlayerArmour(gracz,9999999999);
	MSGF(gracz,COLOR_GREEN, "{FF0000}%s {FFFF00}da³/a ci nieskoñczon¹ kamizelkê!", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "Da³eœ/aœ nieskoñczon¹ kamizelkê graczowi {FF0000}%s", PlayerName(gracz));
	return 1;
}
CMD:givecashall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new kasa;
	if(sscanf(cmdtext,"d",kasa))return SendClientMessage(playerid, COLOR_WHITE, "AS : /GiveCashAll [kwota]");
	foreachPly (i) {
		GivePlayerMoney(i,kasa);
		Money[playerid] += kasa;
	}
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}da³/a wszystkim {eab171}$%d{ffe5a1}.", PlayerName(playerid),kasa);
    SoundForAll(1150);
	return 1;
}
CMD:vehgodall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	foreachPly (i) {
		if(IsPlayerInAnyVehicle(i)){
			SetVehicleHealth(GetPlayerVehicleID(i),999999);
		}
	}
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}zrobi³/a wszystkim niezniszczalne pojazdy!", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}
CMD:god(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /God [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	SetPlayerHealth(gracz,9999999);
	MSGF(gracz,COLOR_GREEN, "{FF0000}%s {FFFF00}da³/a ci nieœmiertelnoœæ", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "Da³eœ/aœ nieœmiertelnoœæ graczowi {FF0000}%s", PlayerName(gracz));
	return 1;
}

new bool:gEventPortfelowy;

CMD:evportfel(playerid,params[])
{
	if(!IsAdmin(playerid,4)) return 0;
	if(gEventPortfelowy) gEventPortfelowy = false;
	else gEventPortfelowy = true;
	
	SCM(playerid,-1,"DONE.");
	return 1;
}

CMD:dajportfel(playerid, params[])
{
	if(!gEventPortfelowy) return 0;
	if(!IsAdmin(playerid,1)) return 0;
	
	new player, kasa, buf[127];
	if(sscanf(params, "dd", player, kasa)) return SCM(playerid, 0xFFFFFFFF, "U¿yj /emulate <id> <ilosc>");
	if(!IsPlayerConnected(player)) return SCM(playerid, 0xEE0000FF, "Ten gracz nie jest po³¹czony!");
	
	if(player==playerid) return SCM(playerid, -1, "Nie mozesz sobie dac kasy.");
	
	if(kasa==0||kasa>4) return SCM(playerid, -1, "Niepoprawna kwota.");
	
	Player[player][Portfel] += kasa;
	
	format(buf,sizeof(buf)," %s (%d) doda³ do Twojego portfela %d z³.", PlayerName(playerid), playerid, kasa);
	SCM(player, COLOR_INFO, buf);
	
	format(buf, sizeof(buf), " Zaktualizowa³eœ portfel gracza %s (%d). Jego stan wynosi: %d(%d) z³. ", PlayerName(player), player, Player[player][Portfel], kasa);
	SCM(playerid, COLOR_INFO, buf);
	
	printf("[/dajportfel]: %s > %s kwota %d", PlayerName(playerid), PlayerName(player), kasa);
	return 1;
}

CMD:emulate(playerid, params[])
{
	if(!IsAdmin(playerid,4)) return 0;

	new player, text[120];
	if(sscanf(params, "ds[120]", player, text)) return SCM(playerid, 0xFFFFFFFF, "U¿yj /emulate <id> <czynnosc>");

    if(!IsPlayerConnected(player)) return SCM(playerid, 0xEE0000FF, "Ten gracz nie jest po³¹czony!");

	if(text[0] == '/')
	{
	    CallLocalFunction("OnPlayerCommandText", "is", player, text);
	}else{
	    CallLocalFunction("OnPlayerText", "is", player, text);
	}
	return 1;
}

CMD:healall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	foreachPly (x) {
		SetPlayerHealth(x,100);
	}
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}uzdrowi³/a wszystkich graczy!", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}
CMD:tpallhere(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new interior = GetPlayerInterior(playerid);
	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	foreachPly (i) {
		SetPlayerInterior(i,interior);
		SetPlayerPos(i,x,y,z);
	}
	new tmp[128];
	format(tmp, sizeof(tmp), "{ffe5a1}››› {eab171}%s {ffe5a1}teleportowa³/a wszystkich graczy do siebie!", PlayerName(playerid));
	SendClientMessageToAll(COLOR_GREEN, tmp);
    SoundForAll(1150);
	return 1;
}
CMD:upingp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new gracz,wysokosc;
	if(sscanf(cmdtext,"ud",gracz,wysokosc)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /UpingP [ID] [wysokosc]");
		return 1;
	}
	if(wysokosc < 0 || wysokosc > 20000){
		SendClientMessage(playerid, COLOR_WHITE, "Podaj wysokoœæ z zakresu ( 0 - 20000 )");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new Float:x,Float:y,Float:z;
	GetPlayerPos(gracz,x,y,z);
	if(!IsPlayerInAnyVehicle(gracz)){
		SetPlayerPos(gracz,x,y,z+wysokosc);
	}else{
		SetVehiclePos(GetPlayerVehicleID(gracz),x,y,z+wysokosc);
	}

	new tmp[80];
	format(tmp, sizeof(tmp), "%s zwiêkszy³/a twoj¹ wysokoœæ o %d m.", PlayerName(playerid),wysokosc);
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "Zwiêkszy³eœ/aœ graczowi %s wysokoœæ o %d m.", PlayerName(gracz),wysokosc);
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}
CMD:downingp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;

	new gracz,wysokosc;
	if(sscanf(cmdtext,"ud",gracz,wysokosc)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /DowningP [ID] [wysokosc]");
		return 1;
	}

	if(wysokosc < 0 || wysokosc > 20000){
		SendClientMessage(playerid, COLOR_WHITE, "Podaj wysokoœæ z zakresu ( 0 - 20000 )");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	new Float:x,Float:y,Float:z;
	GetPlayerPos(gracz,x,y,z);
	if(!IsPlayerInAnyVehicle(gracz)){
		SetPlayerPos(gracz,x,y,z-wysokosc);
	}else{
		SetVehiclePos(GetPlayerVehicleID(gracz),x,y,z-wysokosc);
	}

	new tmp[80];
	format(tmp, sizeof(tmp), "%s zmniejszy³/a twoj¹ wysokoœæ o %d m.", PlayerName(playerid),wysokosc);
	SendClientMessage(gracz,COLOR_GREEN, tmp);

	format(tmp, sizeof(tmp), "Zmniejszy³eœ/aœ graczowi %s wysokoœæ o %d m.", PlayerName(gracz),wysokosc);
	SendClientMessage(playerid,COLOR_GREEN, tmp);

	return 1;
}

CMD:uping(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new wysokosc;
	if(sscanf(cmdtext,"d",wysokosc)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /Uping [wysokosc]");
		return 1;
	}

	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	if(!IsPlayerInAnyVehicle(playerid)){
		SetPlayerPos(playerid,x,y,z+wysokosc);
	}else{
		SetVehiclePos(GetPlayerVehicleID(playerid),x,y,z+wysokosc);
	}

	new tmp[64];
	format(tmp, sizeof(tmp), "Zwiêkszy³eœ/aœ sobie wysokoœæ o %d m.", wysokosc);
	SendClientMessage(playerid,COLOR_GREEN, tmp);

	return 1;
}

CMD:downing(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;

	new wysokosc;
	if(sscanf(cmdtext,"d",wysokosc)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /Downing [wysokosc]");
		return 1;
	}

	new Float:x,Float:y,Float:z;
	GetPlayerPos(playerid,x,y,z);
	if(!IsPlayerInAnyVehicle(playerid)){
		SetPlayerPos(playerid,x,y,z-wysokosc);
	}else{
		SetVehiclePos(GetPlayerVehicleID(playerid),x,y,z-wysokosc);
	}

	new tmp[64];
	format(tmp, sizeof(tmp), "Zmniejszy³eœ/aœ sobie wysokoœæ o %d m.", wysokosc);
	SendClientMessage(playerid,COLOR_GREEN, tmp);

	return 1;
}

CMD:info(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /info [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	MSGF(playerid,COLOR_RED,"(%s) ID: %d , IP: %s, Host: %s",PlayerName(gracz),gracz,PlayerIP(gracz));
	return 1;
}
//Vice
CMD:unprotall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	new tmp[256];
	format(tmp, sizeof(tmp), "››› Odebra³eœ wszystkim Immunitet");
	SendClientMessage(playerid, COLOR_RED2, tmp);
	format(tmp, sizeof(tmp), "{D50101}››› {970000}%s {D50101}pozbawi³ wszystkich graczy Immunitetu!", PlayerName(playerid));
	SendClientMessageToAll(COLOR_RED2, tmp);
    SoundForAll(1150);
	foreachPly (i) {
		Immunitet[i] = false;
	}

	return 1;
}
CMD:armorall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	foreachPly (i) {
		SetPlayerArmour(i,100);
	}
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}da³/a pancerz wszystkim graczom.", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}
CMD:godall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	foreachPly (i) {
		SetPlayerHealth(i,999999);
	}
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}zrobi³ wszystkich graczy nieœmiertelnymi.", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}
CMD:protall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	SCM(playerid, COLOR_GREEN, "Da³eœ wszystkim Immunitet");
	MSGFA(COLOR_LIGHTGREEN, "{D50101}››› {970000}%s {D50101}da³ wszystkim Immunitet!", PlayerName(playerid));
    SoundForAll(1150);
	foreachPly (i) {
		Immunitet[i] = true;
	}
	return 1;
}
CMD:setcash(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new gracz,kasa;
	if(sscanf(cmdtext,"ud",gracz,kasa))return SendClientMessage(playerid, COLOR_WHITE, "AS: /SetCash [ID] [kwota]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	new kasagracza;
	kasagracza = GetPlayerMoney(gracz);
	GivePlayerMoney(gracz,0-kasagracza);
	GivePlayerMoney(gracz,kasa);
	Money[gracz] = kasa;
	MSGF(gracz,COLOR_GREEN, "››› Admin {FF0000}%s Ustawi³/a twoje pieni¹dze na {FF0000}$%d", PlayerName(playerid),kasa);
	MSGF(playerid,COLOR_GREEN, "››› Ustawi³eœ/aœ graczowi {FF0000}%s pieni¹dze na {FF0000}$%d", PlayerName(gracz),kasa);
	return 1;
}
CMD:uncenzall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	MSGFA(COLOR_LIGHTGREEN, "{D50101}››› {970000}%s {D50101}odcenzurowa³/a wszystkich graczy!", PlayerName(playerid));
	foreachPly (i) {
		playermuted[i] = false ;
		Cenzor[i] = false;
	}
	return 1;
}
CMD:setworldall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;

	new world;
	if(sscanf(cmdtext,"d",world)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /SetWorldAll [ID Virtual Worlda]");
		return 1;
	}

	if(CH_Trwa || WG_Trwa || HAY_Trwa || TW_Trwa || SS_Trwa){
		WorldChange = world;
		ShowPlayerDialog(playerid,23,0,"Uwaga!","Uwaga! Trwaj¹ atrakcje rozgrywane na ró¿nych Virtual Worldach \nZmieniaj¹c go wszystkim mo¿esz popsuæ aktywne atrakcje \na gracze posiadajacy domy beda mieli z nimi chwilowe problemy \n\nCzy na pewno chcesz kontynuowaæ?","Tak","Nie");
		return 1;
	}

	foreachPly (i) {
		SetPlayerVirtualWorld(i,world);
	}

	new tmp[256];
	format(tmp, sizeof(tmp), "{ffe5a1}››› {eab171}%s {ffe5a1}zmieni³ wszystkim œwiat(VW) na {eab171}%d{ffe5a1}.", PlayerName(playerid),world);
	SendClientMessageToAll(COLOR_GREEN, tmp);
    SoundForAll(1150);
	return 1;
}

CMD:givescore (playerid, params[]) return cmd_giveexp(playerid, params);

CMD:giveexp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,3))
	{
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 0;
	}
	new gracz,score;
	if(sscanf(cmdtext,"ud",gracz,score)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /GiveScore [ID] [ilosc]");
		return 1;
	}
	if(gracz == playerid)
	{
	    SendClientMessage(playerid, COLOR_WHITE, "››› Nie mo¿esz dawaæ sobie exp!");
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	Respekt[gracz] += score;
    Player[gracz][Level] = GetPlayerLevel(gracz);

	new tmp[80];
	format(tmp, sizeof(tmp), "%s da³/a ci %d exp", PlayerName(playerid),score);
	SendClientMessage(gracz,COLOR_GREEN, tmp);

	format(tmp, sizeof(tmp), "Da³eœ/aœ graczowi %s  %d exp", PlayerName(gracz),score);
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}
CMD:giveexpall(playerid,cmdtext[]){

	if(!IsAdmin(playerid,3)){
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new score,reason[32];
	if(sscanf(cmdtext,"ds[32]",score,reason)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /GiveExpAll [ilosc] [powód]");
		return 1; 
	}
	foreachPly (i) {
		Respekt[i] += score;
		Player[i][Level] = GetPlayerLevel(i);
	}
	MSGFA(0xffe5a1FF, "{ffe5a1}››› {eab171}%s {ffe5a1}da³/a wszystkim graczom {eab171}%d{ffe5a1} exp z powodu: {eab171}%s", PlayerName(playerid),score,reason);
    SoundForAll(1150);
	return 1;
}
CMD:cenzall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return SCM(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	MSGFA(COLOR_RED2, "{D50101}››› {970000}%s {D50101}ocenzurowa³/a wszystkich graczy!", PlayerName(playerid));
	foreachPly (i) {
		playermuted[i] = true ;
		Cenzor[i] = true;
	}
	return 1;
}
CMD:reloadobjects(playerid,params[]){
    if(!IsAdmin(playerid,4)) return 0;
	SendClientMessageToAll(-1,"Trwa prze³adowywanie obiektów...");
	DestroyAllDynamicObjects();
	new Loader;
   	LoadFromFileObject(file, Loader);
	FormatObjectLog("Trwa przeladowywanie..\nWczytano:\n* Obiekty:\t%6d", Loader+502);
	MSGF(playerid,-1,"Za³adowano:  %d Obiektów ",Loader);
	CreateDynamicObject(18766,   238.87297000,139.59490900,1003.77380300,0.00000000,0.00000000,0.00000000,150,-1,-1);
	CreateDynamicObject(18766,288.63357500,169.21549900,1007.60980200,0.00000000,0.00000000,0.00000000,150,-1,-1);
	CreateDynamicObject(18765, 969.575988, 2163.261230, 1010.393310, 0.000000, 0.000000, 0.000000,153,-1,-1);	
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
	for(new vw = 10000; vw != 10500; vw++)
		CreateDynamicObject(19272, -3007.419433, 131.482864, 7.786579, 0.000000, 0.000000, 0.000000,vw,-1,-1);
	return 1;
}

CMD:unban(playerid, params[]) {
    if(Player[playerid][uID] !=12357 && !IsAdmin(playerid,4)) return 0;
	new data_kurwa[MAX_PLAYER_NAME];
	if(isnull(params))	return SCM(playerid, -1, "/unban [nick/ip]");
	mysql_real_escape_string(params, data_kurwa);
	mysql_query_format("SELECT 1 FROM `ban` WHERE `name` = '%s' OR `IP` = '%s'", data_kurwa, data_kurwa);
	mysql_store_result();
	if(mysql_num_rows()) {
		mysql_free_result();
		mysql_query_format("DELETE FROM `ban` WHERE `name` = '%s' OR `IP` = '%s'", data_kurwa, data_kurwa);
		MSGF(playerid,-1,"{AC3E00}***{AC3E00}IP/Nick {AC3E00}%s {AC3E00} odbanowane!",data_kurwa);
		WriteLogFormat("[UNBAN]admi %s unban ip/nick %s",PlayerName(playerid),data_kurwa);
	} else {
		mysql_free_result();
		MSGF(playerid, -1, "{AC3E00}***{AC3E00}IP/Nick {AC3E00}%s {AC3E00} nie jest zbanowane!",data_kurwa);
	}
	return 1;
}
CMD:setbank(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	new gracz,kasa;
	if(sscanf(cmdtext,"ud",gracz,kasa))return SendClientMessage(playerid, COLOR_WHITE, "* Uzyj: /setbank [id_gracza] [suma]");
	if(!IsPlayerConnected(gracz)){
	    SendClientMessage(playerid,COLOR_RED2,"››› Nie ma takiego gracza!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	bank[gracz] = kasa;
	MSGF(playerid, COLOR_YELLOW, "* Dales graczowi: %s (id: %d) na konto bankowe $%d.", PlayerName(gracz),gracz,kasa);
	MSGF(gracz, COLOR_YELLOW, "* Twoj stan konta wyniosi teraz: $%d, dzieki pomocy: %s (id: %d).", kasa,PlayerName(playerid),playerid);
	return 1;
}
CMD:disarmall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	foreachPly (x) {
		ResetPlayerWeapons(x);
	}
	MSGFA(COLOR_RED, "››› Admin {FF0000}%s  {AA3333}rozbroi³/a wszystkich graczy!", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}
CMD:unfreezeall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,4)) return 0;
	foreachPly (x) {
		TogglePlayerControllable(x, 1);
	}
	SendClientMessage(playerid,COLOR_GREEN,"››› Admin odmrozi³ wszystkich!");
	return 1;
}
//head 

CMD:setcashall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,5)) return 0;
	new kasa;
	if(sscanf(cmdtext,"d",kasa))return SendClientMessage(playerid, COLOR_WHITE, "AS : /SetCashAll [kwota]");
	foreachPly (x) {
		new kasagracza;
		kasagracza = GetPlayerMoney(x);
		GivePlayerMoney(x,0-kasagracza);
		GivePlayerMoney(x,kasa);
		Money[x] = kasa;
	}
	MSGFA(0x0, "{ffe5a1}››› {eab171}%s {ffe5a1}ustawi³/a wszystkim pieni¹dze na {eab171}$%d{ffe5a1}.", PlayerName(playerid),kasa);
    SoundForAll(1150);

	return 1;
}
CMD:svall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,5)) return 0;
	foreachPly (x) {
		if(logged[x]){
			SaveData(x);
			MSGF(x,COLOR_GREEN,"{eab171}››› {ffe5a1}Statysyki zapisane na nick: {eab171}%s{ffe5a1}.",PlayerName(x));
		}
	}
	SendClientMessage(playerid, COLOR_GREEN, "Zapisales(as) statystyki wszystkim graczom!");
	return 1;
}
CMD:resetcash(playerid,cmdtext[]){
	if(Player[playerid][uID] !=11781 && !IsAdmin(playerid,5)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /ResetCash [ID]");
	if(!IsPlayerConnected(gracz))return SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
	new kasagracza = GetPlayerMoney(gracz);
	GivePlayerMoney(gracz,0-kasagracza);
	Money[gracz] = 0;
	MSGF(gracz,0x0, "{3BAD00}››› {28730A}%s {3BAD00}zresetowa³/a ci pieni¹dze.", PlayerName(playerid));
	MSGF(playerid,COLOR_RED, "{3BAD00}››› {28730A}zresetowa³eœ/a pieniadze graczowi {3BAD00}%s.", PlayerName(gracz));
	return 1;
}
CMD:killall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,5)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	foreachPly (x) {
		SetPlayerHealth(x,0);
	}
	globdeaths++;
	globsuicides++;
 	MSGFA(COLOR_GREEN, "{D50101}››› {970000}%s {D50101}zabi³/a wszystkich graczy!", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}
CMD:reset(playerid, params[]) {
    if(!IsAdmin(playerid,5))return 0;
	for(new x = 0; x!=10;x++) MSGA(-1,"Restart serwera! Zapraszamy ponownie. Pozdrawiamy Ekipa FullGaming!");
	foreachPly (i) {
		MSG(i,-1,"Restart serwera! Zapraszamy ponownie. Pozdrawiamy Ekipa FullGaming!");
		SaveData(i);
		KickEx(i);
		kicks++;
	}
	SendRconCommand("gmx");	
	return 1;
}
CMD:reloadcfg(playerid,params[])
{
    if(!IsAdmin(playerid,5)) return 0;
	new string[256];
	mysql_query("SELECT `variable`, `value` FROM `config` WHERE `RCON` = 1");
	mysql_store_result();
	while (mysql_fetch_row(string, " ")){
		SendRconCommand(string);
		print(string);
		SCM(playerid, -1,string);
	}
	SCM(playerid, -1, "{AC3E00}Ustawienia prze³adowane!");
	return 1;
}
CMD:resetcashall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,5)) return 0;
	foreachPly (x) {
		new kasagracza = GetPlayerMoney(x);
		GivePlayerMoney(x,0-kasagracza);
		Money[x] = 0;
	}
	MSGFA(COLOR_RED, "{ffe5a1}››› {eab171}%s {ffe5a1}zresetowa³ pieni¹dze wszystkim graczom.", PlayerName(playerid));
    SoundForAll(1150);
	return 1;
}