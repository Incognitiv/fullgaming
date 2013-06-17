CMD:startvote(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	
	if (VoteON)  return SCM(playerid,COLOR_RED2,"Poczekaj a¿ skoñczy siê aktualne g³osowanie!");
	
	new pytanie[80];
	if (sscanf (cmdtext,"s[80]", pytanie)) return SCM(playerid, COLOR_WHITE, "U¿yj: /startvote [Pytanie do G³osowania]");
	if (!(5 <= strlen (pytanie) < 80)) return SCM(playerid,COLOR_WHITE,"Max. 50 znaków w pytaniu!");
	
	VoteWylacz();
	VoteON = true;
	
	new buf[160];
	MSGFA(COLOR_SEAGREEN, "››› %s rozpocz¹³ g³osowanie! Pytanie: %s", PlayerName(playerid), pytanie);
	foreachPly (x) {
		Zaglosowal[x] = false;
		if(VoteChce[x]){
			TextDrawShowForPlayer(x,Glosowanie);
		}
	}
	LiczbaTak = 0;
	LiczbaNie = 0;
	VotePozostalo = 20;
	SetTimer ("Odliczanka",1000,0);
	
	format (VoteQuest, sizeof (VoteQuest), "%s", pytanie);
	format (buf, sizeof (buf), "%s %s ~n~~y~%d       ~w~/TAK   ~g~%d   ~w~/NIE   ~r~%d", VoteQuest, (strlen (VoteQuest)>=35)? ("~n~"): (""), VotePozostalo, LiczbaTak, LiczbaNie);
	TextDrawSetString (Glosowanie,buf);
	return 1;
}
CMD:invisible(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	SetPlayerColor(playerid,0xFFFFFF00);
	Invisible[playerid] = true;
	SendClientMessage(playerid, COLOR_ORANGE, "Jestes niewidoczny/a na mapie!");
	SendClientMessage(playerid,	COLOR_ORANGE,"Aby wy³¹czyæ niewidzialnoœæ wpisz: {FF0000}/visible");
	return 1;
}
CMD:playsound(playerid,cmdtext[]){
	if (!IsAdmin(playerid,1)) return 0;
    
	new 
		url[160], 
		Float:radius, 
		Float:vpos[3],
		countplayers = 0
	;
	
	if (sscanf (cmdtext, "s[160]F(0)", url, radius)) return SendClientMessage (playerid, -1, "Uzyj: /playsound <url> <promien (opcjonalne)>");
	if (isnull (url)) return SendClientMessage (playerid, -1, "Nie wpisa³eœ url!");
	
	if (radius > 0) {
		GetPlayerPos (playerid, vpos[0], vpos[1], vpos[2]);
		foreachPly (x) {
			StopAudioStreamForPlayer (x);
			PlayAudioStreamForPlayer (x, url, vpos[0], vpos[1], vpos[2], radius, true);
			countplayers++;
		}
		format (url, sizeof (url), "Odtworzono dzwiêk u %i %s", countplayers, dli(countplayers, "gracza", "graczy", "graczy"));
		SendClientMessage (playerid, -1, url);
	} else {
		foreachPly (x) {
			StopAudioStreamForPlayer (x);
			PlayAudioStreamForPlayer (x, url);
		}
	}
	SendClientMessage (playerid, -1, "Done.");
	return 1;
}

CMD:stopsound (playerid, params[]) {
	if (!IsAdmin(playerid,1)) return 0;
	
	foreachPly (x) {
		StopAudioStreamForPlayer (x);
	}
	return 1;
}

CMD:givegun(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz,bron,modammo;
	if(sscanf(cmdtext,"udd",gracz,bron,modammo))return SendClientMessage(playerid,COLOR_WHITE,"AS: /givegun [ID] [ID broni] [Amunicja]");
	if(gracz < 0 || gracz >= MAX_GRACZY || !IsPlayerConnected(gracz)){
	    SendClientMessage(playerid,COLOR_RED2,"››› Nie ma takiego gracza!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(bron < 0 || bron > 46)return  SendClientMessage(playerid,COLOR_RED2,"››› Z³e ID Broni!");
	if(modammo < 1 || modammo > 9999)return SendClientMessage(playerid,COLOR_RED2,"››› Z³a iloœæ amunicji!");
	GivePlayerWeapon(gracz,bron,modammo);
	MSGF(playerid,COLOR_GREEN, "Da³eœ/aœ broñ %s i %d amunicji graczowi %s",ReturnWeaponName(bron),modammo,PlayerName(gracz));
	MSGF(gracz,COLOR_GREEN, "%s da³/a ci broñ %s i %d amunicji",PlayerName(playerid),ReturnWeaponName(bron),modammo);
	return 1;
}
CMD:id(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new tmp[25];
	if(sscanf(cmdtext,"s[25]",tmp))return SendClientMessage(playerid, COLOR_WHITE, ": /ID [Nick]");
	new name[MAX_PLAYER_NAME];
	new bool:done = false;
	foreachPly (x) {
		GetPlayerName(x,name,sizeof(name));
		if(strfind(name,tmp,true) > -1){
			MSGF(playerid,COLOR_RED,"[%s] - ID: %d",name,x);
			done = true;
			break;
		}
	}
	if(!done){
		MSGF(playerid,COLOR_RED2,"Wyra¿enie %s nie pasuje do ¿adnego nicku.",tmp);
	}
	return 1;
}
CMD:cd(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new czas,zamro;
	if(sscanf(cmdtext,"dd",czas,zamro))return SendClientMessage(playerid, COLOR_WHITE, "AS: /cd [czas] [zamrozenie(0/1)]");
	if(czas > 1000 || czas < 0)return SendClientMessage(playerid, COLOR_WHITE, "Czas od 0 do 1000 sek.");
	if(zamro > 1 || zamro < 0)return SendClientMessage(playerid, COLOR_WHITE, "Zamro¿enie  1 - tak  0 - nie");
	if(CountDowning == 1)return SendClientMessage(playerid, COLOR_WHITE, "Ju¿ trwa jakieœ odliczanie !");
	CountDowning = 1;
	if(zamro == 1){
		foreachPly (x) {
			if(GetDistanceBetweenPlayers(playerid,x) <= 50){
				TogglePlayerControllable(x,0);
			}
		}
	}
	Count2 = czas;
	CountDownAS();
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}w³¹czy³/a odliczanie {eab171}%d{ffe5a1} sekund.", PlayerName(playerid),czas);
    SoundForAll(1150);
	return 1;
}
CMD:stopcd(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	MSGFA(COLOR_GREEN, "{ffe5a1}››› {eab171}%s {ffe5a1}pomyœlnie zakoñczy³/a odliczanie.", PlayerName(playerid));
	Count2 = -1;
	CountDowning = 0;
	return 1;
}
CMD:ann(playerid,cmdtext[]) {
	if(!IsAdmin(playerid,1)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new text[128], seconds;
	if(sscanf(cmdtext, "ds[128]", seconds, text)) return SCM(playerid, COLOR_WHITE, "AS: /ann [czas] [text]");

	new nieparzyste = 0;
	new i = 0;
	while (text[i]) {
		if (text[i++] == '~') nieparzyste++;
	}
	nieparzyste %= 2;
	
	
	if (nieparzyste) return SendClientMessage(playerid, -1, "Iloœæ takich \"~\" znaków musi byæ parzysta!");
	FadeForPlayer(seconds, text);
	
	new buf[160];
	format (buf, sizeof (buf), "[/Ann] %s: %s", PlayerName(playerid), text);
	foreachPly(x) {
		if (x != playerid && IsAdmin (x, 1)) {
			SendClientMessage (x, -1, buf);
		}
	}
	return 1;
}
CMD:stopvote(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	VoteWylacz();
	MSGA(COLOR_RED2,"Admin wy³¹czy³ g³osowanie!");
	return 1;
}

CMD:weaponlist(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
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
CMD:msay(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new wiadomosc[128];
	if(sscanf(cmdtext,"s[128]",wiadomosc))return SCM(playerid, COLOR_WHITE, "U¿yj: /Msay [text]");
	MSGFA(0x33AA33AA, "{4491FF}({75E43C}Moderator{4491FF}) {75E43C}%s {4491FF}%s",PlayerName(playerid), wiadomosc);
	return 1;
}
CMD:disarm50(playerid,cmdtext[]){
	return cmd_disarmall50(playerid,cmdtext);
}
CMD:disarmall50(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return SendClientMessage(playerid,COLOR_RED2,"››› Nie posiadasz uprawnieñ do u¿ywania tej komendy!");
	new string2[80];
	format(string2, sizeof(string2), "››› Zosta³eœ/aœ rozbrojony/a przez admina: {FF0000}%s", PlayerName(playerid));
	foreachPly (x) {
		if(GetDistanceBetweenPlayers(playerid,x) <= 50){
			ResetPlayerWeapons(x);
			SendClientMessage(x,COLOR_RED, string2);
		}
	}
	SendClientMessage(playerid,COLOR_GREEN,"››› Rozbroi³eœ/aœ wszystkich graczy w zasiêgu 50 m.");
	return 1;
}
CMD:heal(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz))return SendClientMessage(playerid, COLOR_WHITE, "AS : /Heal [ID]");
	SetPlayerHealth(gracz,100);
	MSGF(gracz,COLOR_GREEN, "{3BAD00}››› {28730A}%s {3BAD00}uzdrowi³/a ciê!", PlayerName(playerid));
	MSGF(playerid,COLOR_GREEN, "{28730A}››› {3BAD00}Uleczy³eœ/aœ gracza {28730A}%s{3BAD00}.", PlayerName(gracz));
	return 1;
}
CMD:mcolor(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new colorplayer,color;
	if(sscanf(cmdtext,"ud",colorplayer,color)){
	    SendClientMessage(playerid,COLOR_WHITE, "AS: /Mcolor [ID] [ID koloru]");
		return 1;
	}

	if(color == 1){
		SetPlayerColor(colorplayer, COLOR_GREY);
	} else if(color == 2){
		SetPlayerColor(colorplayer, COLOR_LIGHTGREEN);
	} else if(color == 3){
		SetPlayerColor(colorplayer, COLOR_RED);
	} else if(color == 4){
		SetPlayerColor(colorplayer, COLOR_YELLOW);
	} else if(color == 5){
		SetPlayerColor(colorplayer, COLOR_WHITE);
	} else if(color == 6){
		SetPlayerColor(colorplayer, COLOR_BLUEX);
	} else if(color == 7){
		SetPlayerColor(colorplayer, COLOR_ORANGE);
	} else if(color == 8){
		SetPlayerColor(colorplayer, COLOR_PINK);
	} else if(color == 9){
		SetPlayerColor(colorplayer, 0xFFFFFF00);
	} else if(color == 10){
		SetPlayerColor(colorplayer, COLOR_VIOLET);
	} else if(color == 11){
		SetPlayerColor(colorplayer, COLOR_BLACK);
	} else if(color == 12){
		SetPlayerColor(colorplayer, COLOR_BROWN);
	} else if(color == 13){
		SetPlayerColor(colorplayer, COLOR_LIGHTBLUE);
	} else if(color == 14){
		SetPlayerColor(colorplayer, COLOR_GREEN);
	} else if(color == 15){
		SetPlayerColor(colorplayer, COLOR_KREM);
	} else if(color == 16){
		SetPlayerColor(colorplayer, COLOR_ADMIN);
	} else {
		SendClientMessage(playerid, COLOR_ADMIN, "Z³y ID koloru: ID (od 1 do 16)");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	}
	new tmp[64];
	format(tmp, sizeof(tmp), "Zmieni³eœ/aœ kolor graczowi %s na %d",PlayerName(colorplayer), color);
	SendClientMessage(playerid,COLOR_GREEN,tmp);
	format(tmp, sizeof(tmp), "Moderator %s zmieni³/a ci kolor nicku",PlayerName(playerid));
	SendClientMessage(colorplayer,COLOR_GREEN,tmp);
	return 1;
}
CMD:repair(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /Repair [ID]");
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new veh = GetPlayerVehicleID(gracz);
	RepairVehicle(veh);
	new tmp[64];
	format(tmp, sizeof(tmp), "››› Admin %s naprawi³/a twój pojzad", PlayerName(playerid));
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "››› Naprawi³eœ/aœ pojazd graczowi %s", PlayerName(gracz));
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}
CMD:jetpack(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
        SendClientMessage(playerid, COLOR_WHITE, "AS : /Jetpack [ID]");
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	SetPlayerSpecialAction(gracz, 2);
	new tmp[64];
	format(tmp, sizeof(tmp), "››› Admin %s da³/a ci Jetpacka.", PlayerName(playerid));
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "››› Da³eœ/aœ Jetpacka graczowi %s.", PlayerName(gracz));
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	
	format(tmp, sizeof(tmp), "> %s da³ %s jetpacka", PlayerName(playerid), PlayerName(gracz));
	SendClientMessageToAdmins(COLOR_INFO, tmp);
	
	return 1;
}
CMD:acolorveh(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz,kolor1,kolor2;
	if(sscanf(cmdtext,"udd",gracz,kolor1,kolor2)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS: /AcolorVeh [ID] [kolor 1] [kolor 2]");
		return 1;
	}
	if(kolor1 < 0 || kolor1 > 500){
		SendClientMessage(playerid, COLOR_WHITE, "Z³e ID koloru 1 !");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(kolor2 < 0 || kolor2 > 500){
		SendClientMessage(playerid, COLOR_WHITE, "Z³e ID koloru 2 !");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new veh = GetPlayerVehicleID(gracz);
	ChangeVehicleColor(veh,kolor1,kolor2);
	new tmp[80];
	format(tmp, sizeof(tmp), "››› %s zmieni³/a ci kolor auta", PlayerName(playerid));
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "››› Zmieni³eœ/aœ graczowi %s kolor auta na %d , %d", PlayerName(gracz),kolor1,kolor2);
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}
CMD:rsptrailers(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	if(IsPlayerConnected(playerid))
	{
		for(new v=0; v<MAX_VEHICLES; v++){
			if(!IsTrailer(v)){
				SetVehicleToRespawn(v);
			}
		}
		SendClientMessageToAll(COLOR_BLUEX, "Wszystkie naczepy wrocily na miejsce spawnu!");
        SoundForAll(1150);
	}
	return 1;
}
CMD:tt(playerid,cmdtext[]){

	if(!IsAdmin(playerid,1)) return 0;

	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, 0x00FFFFAA, "Uzyj : /tt [ID]");
		return 1;
	}

	new Float:pX, Float:pY, Float:pZ;
	GetPlayerPos(gracz, pX,pY,pZ);
	new inte,world;
	inte = GetPlayerInterior(gracz);
	world = GetPlayerVirtualWorld(gracz);
	SetPlayerPos(playerid, pX,pY,pZ);
	SetPlayerInterior(playerid, inte);
	SetPlayerVirtualWorld(playerid,world);

	new tmp[64];
	format(tmp, sizeof(tmp), "Teleportowales sie do %s", PlayerName(gracz));
	SendClientMessage(playerid, COLOR_RED, tmp);

	return 1;
}

CMD:th(playerid,cmdtext[]){

	if(!IsAdmin(playerid,1)) return 0;

	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
        SendClientMessage(playerid, 0x00FFFFAA, "Uzyj : /th [ID]");
		return 1;
	}

	new Float:pX, Float:pY, Float:pZ;
	new inte,world;
	GetPlayerPos(playerid, pX,pY,pZ);
	inte = GetPlayerInterior(playerid);
	world = GetPlayerVirtualWorld(playerid);
	SetPlayerPos(gracz, pX,pY,pZ);
	SetPlayerInterior(gracz, inte);
	SetPlayerVirtualWorld(gracz,world);

	new tmp[64];
	format(tmp, sizeof(tmp), "Teleportowales do siebie %s", PlayerName(gracz));
	SendClientMessage(playerid, COLOR_RED, tmp);
	format(tmp, sizeof(tmp), "Admin: %s, teleportowal cie do siebie", PlayerName(playerid));
	SendClientMessage(gracz, COLOR_RED, tmp);

	return 1;
}

CMD:rspauta(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	if(IsPlayerConnected(playerid))
	{
		respawnVehicles(true);
		SendClientMessageToAll(COLOR_BLUEX, "Nieuzywane pojazdy zrespawni³y siê na spawn!");
        SoundForAll(1150);
	}
	return 1;
}
CMD:armor(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	SetPlayerArmour(playerid,100);
	SendClientMessage(playerid,COLOR_GREEN,"Da³eœ/aœ sobie pancerz");
	return 1;
}
CMD:remove(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz;
	if(sscanf(cmdtext,"u",gracz)){
	    SendClientMessage(playerid, COLOR_WHITE, "AS : /Remove [ID]");
		return 1;
	}
	if(!IsPlayerConnected(gracz)){
		SendClientMessage(playerid, COLOR_WHITE, "››› Ten gracz nie jest po³¹czony z serwerem!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	RemovePlayerFromVehicle(gracz);
	new tmp[80];
	format(tmp, sizeof(tmp), "%s wyrzuci³/a ciê z pojazdu!", PlayerName(playerid));
	SendClientMessage(gracz,COLOR_GREEN, tmp);
	format(tmp, sizeof(tmp), "Wyrzuci³eœ/aœ z pojazdu gracza %s", PlayerName(gracz));
	SendClientMessage(playerid,COLOR_GREEN, tmp);
	return 1;
}

CMD:removeall(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new string2[80];
	for(new x=0;x<MAX_GRACZY;x++){
		if(IsPlayerConnected(x)){
			RemovePlayerFromVehicle(x);
		}
	}
	format(string2, sizeof(string2), "{ffe5a1}››› {eab171}%s {ffe5a1}wyrzuci³/a wszystkich z pojazdów.", PlayerName(playerid));
	SendClientMessageToAll(COLOR_GREEN, string2);
    SoundForAll(1150);
	return 1;
}
CMD:settime(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new godzina;
	if(sscanf(cmdtext,"d",godzina))return SendClientMessage(playerid, COLOR_WHITE, "/SetTime [godzina]");
	if(godzina > 24 || godzina < 0)return SendClientMessage(playerid,COLOR_WHITE,"››› Z³a godzina! ( 0 - 24 )");
	SetWorldTime(godzina);
	MSGFA(COLOR_RED, "{ffe5a1}››› {eab171}%s {ffe5a1}ustawi³ godzinê {eab171}%d{ffe5a1}.", PlayerName(playerid),godzina);
    SoundForAll(1150);
	return 1;
}
CMD:tp(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new gracz1,gracz2;
	if(sscanf(cmdtext,"uu",gracz1,gracz2))return SendClientMessage(playerid, COLOR_WHITE, "AS: /tp [ID] do [ID]");
	if(!IsPlayerConnected(gracz1))return SendClientMessage(playerid, COLOR_WHITE, "››› Gracz nr.1 Nie jest Online!");
	if(!IsPlayerConnected(gracz2))return SendClientMessage(playerid, COLOR_WHITE, "››› Gracz nr.2 Nie jest Online!");
	new Float:x,Float:y,Float:z;
	new interior,world;
	GetPlayerPos(gracz2,x,y,z);
	interior = GetPlayerInterior(gracz2);
	world = GetPlayerVirtualWorld(gracz2);
	if(!IsPlayerInAnyVehicle(gracz1)){
		SetPlayerPos(gracz1,x+2.5,y,z+1);
		SetPlayerInterior(gracz1,interior);
		SetPlayerVirtualWorld(gracz1,world);
	}else{
		SetVehiclePos(GetPlayerVehicleID(gracz1),x+2.5,y,z+1);
		LinkVehicleToInterior(GetPlayerVehicleID(gracz1),interior);
		SetVehicleVirtualWorld(GetPlayerVehicleID(gracz1),world);
	}
/*
	if(IsInJetArena[gracz2] == 1)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "››› Gracz nr 2 jest na JetArenie!");
		return 1;
	}

    if(IsInJetArena[gracz1] == 1)
	{
	    SendClientMessage(playerid, COLOR_GREEN, "››› Gracz nr 1 jest na JetArenie!");
		return 1;
	}
*/
	MSGF(gracz1,COLOR_ORANGE, "{3BAD00}(TP) {28730A}%s {3BAD00}teleportowa³ ciê do gracza {28730A}%s {3BAD00}.", PlayerName(playerid),PlayerName(gracz2));
	MSGF(gracz2,COLOR_ORANGE, "{3BAD00}(TP) {28730A}%s {3BAD00}teleportowa³ do ciebie gracza {28730A}%s {3BAD00}.", PlayerName(playerid),PlayerName(gracz1));
	MSGF(playerid,COLOR_ORANGE, "{3BAD00}(TP) {28730A}Teleportowa³eœ gracza {3BAD00}%s {28730A}do gracza {3BAD00}%s{28730A}.", PlayerName(gracz1),PlayerName(gracz2));
	return 1;
}

CMD:mcmds(playerid, params[]) return cmd_mpomoc(playerid,params);
CMD:mcmds1(playerid, params[]) return cmd_mpomoc2(playerid,params);

CMD:mpomoc(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new string[1500];
	strcat(string,"{28DC28}/podkowa {FFFFFF}- Gubisz gdzieœ podkowê.\n");
	strcat(string,"{28DC28}/Skinp {FFFFFF}- Zmieniasz graczowi skina.\n");
	strcat(string,"{28DC28}/jetpack {FFFFFF}- Dajesz wybranemu graczu plecak odrzutowy (Jetpack).\n");
    strcat(string,"{28DC28}/anncolor {FFFFFF}- Lista dostêpnych kolorów tekstu /ann.\n");
    //strcat(string,"{28DC28}/StartEv {FFFFFF}- Start Zabawy.\n");
	strcat(string,"{28DC28}/startvote {FFFFFF}- G³osowanie.\n");
    strcat(string,"{28DC28}/respawn ID {FFFFFF}- Respawnujesz gracza.\n");
	strcat(string,"{28DC28}/stopvote {FFFFFF}- Stop glosowania.\n");
	strcat(string,"{28DC28}/rspauta {FFFFFF}- Respawnujesz pojazdy.\n");
    strcat(string,"{28DC28}/cd [sekundy] {FFFFFF}- Odliczanie.\n");
	strcat(string,"{28DC28}/delauta {FFFFFF}- Usuwasz pojazdy stworzone z /p.\n");
	strcat(string,"{28DC28}/invisible {FFFFFF}- Jesteœ niewidzialny na mapie.\n");
	strcat(string,"{28DC28}/ann {FFFFFF}- Piszesz na œrodku ekranu.\n");
	//strcat(string,"{28DC28}/Mpozostalo {FFFFFF}- Wa¿noœæ konta premium [Moderator].\n");
	strcat(string,"{28DC28}/Cars {FFFFFF}- Lista pojazdow do spawnowania.\n");
	strcat(string,"{28DC28}/P [nazwa] {FFFFFF}- Spawnujesz dowolny pojazd podajac jego nazwe.\n");
	strcat(string,"{28DC28}/Mzestaw  {FFFFFF}- Dostajesz zestaw broni Mod'a.\n");
	strcat(string,"{28DC28}/givecash [id] [kwota] {FFFFFF}- Dajesz wybranemu graczowi kase.\n");
	strcat(string,"{28DC28}/settime [godzina] {FFFFFF}- Ustawiasz godzine na serwerze.\n");
	strcat(string,"{28DC28}/givegun {FFFFFF}- Dajesz broñ graczom.\n");
	strcat(string,"{28DC28}/weaponlist {FFFFFF}- Lista broni.\n");
	strcat(string,"{28DC28}/Msay [tekst] {FFFFFF}- Piszesz na czacie jako MOD-MSG.\n");
	strcat(string,"{28DC28}/Pmv [tskst] {FFFFFF}- Piszesz na prywatnym czacie Adminow Vipow i Moderatorow.\n");
	strcat(string,"{28DC28}/repair [id]  {FFFFFF}- Naprawiasz graczowi pojazd.\n");
	strcat(string,"{28DC28}/Mcolor {FFFFFF}- Dajesz sobie zielony kolor moderatora.\n");
	strcat(string,"{28DC28}/heal [id] {FFFFFF}- Uzdrawiasz gracza.\n");
	strcat(string,"{28DC28}/armorid {FFFFFF}- Dajesz kamizelke.\n");
    strcat(string,"{28DC28}/tp {FFFFFF}- Teleportujesz.\n");
    strcat(string,"{28DC28}/AsWeapons {FFFFFF}- Dostajesz zestaw specjalnych broni.\n");
	strcat(string,"* Wiêcej komend moderatora pod /Mpomoc2 lub /mcmds1\n\n");
	strcat(string,"___________________________________\n");
	strcat(string,"Pamietaj jednak ze naduzycia zwiazane z tymi komendami\n");
	strcat(string,"moga sie wiazac z odebraniem ci rangi MODERATOR!");
	ShowPlayerDialog(playerid,DIALOG_MOD,0,"Komendy Moderatora",string,"Dalej","Wyjdz");
	return 1;
}
CMD:mpomoc2(playerid,cmdtext[]){
	if(!IsAdmin(playerid,1)) return 0;
	new string[512];
	strcat(string,"{28DC28}/Armorall {FFFFFF}- Dajesz armor wszystkim.\n");
    strcat(string,"{28DC28}/Mgod {FFFFFF}- Dajesz sobie goda.\n");
	strcat(string,"{28DC28}/Jail {FFFFFF}- wiêzisz gracza.\n");
    strcat(string,"{28DC28}/DelPodkowa {FFFFFF}- usuwasz podkowê.\n");
	strcat(string,"{28DC28}/UnJail {FFFFFF}- wiêzisz gracza.\n");
	strcat(string,"{28DC28}/Killp {FFFFFF}- zabijasz gracza.\n");
	strcat(string,"{28DC28}/AcolorVeh {FFFFFF}- zmieniasz kolor pojazdu.\n");
    strcat(string,"{28DC28}/Kick {FFFFFF}- KickEx(ujesz gracza.\n");
	strcat(string,"To dopiero pocz¹tek mo¿liwoœci moderatora.\n\n");
	strcat(string,"___________________________________\n");
	strcat(string,"Pamietaj jednak ze naduzycia zwiazane z tymi komendami\n");
	strcat(string,"moga sie wiazac z odebraniem ci rangi MODERATOR!");
	ShowPlayerDialog(playerid,DIALOG_MOD2,0,"Komendy Moderatora",string,"Cofnij","Wyjdz");
	return 1;
}