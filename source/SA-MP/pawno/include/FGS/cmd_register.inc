
CMD:login(playerid,cmdtext[]){
	cmd_logowanie(playerid,cmdtext);
	return 1;
}

CMD:logowanie(playerid,cmdtext[]){

	if(!Registered[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"››› Nie jesteœ zarejestrowany/a!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	if(logged[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"››› Jesteœ ju¿ zalogowany/a!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	ShowPlayerDialog(playerid, 7, DIALOG_STYLE_PASSWORD, "{FFFFFF}Panel Logowania", "{FF5500}Witamy na FullGaming\n{FFFFFF}Je¿eli widzisz ten komunikat poraz pierwszy oznacza to \n¿e inna osoba gra ju¿ na tym nicku i jest zarejestrowana.\n{FF5500}Je¿eli jest to twoje konto wpisz has³o:", "Loguj", "Anuluj");

	return 1;
	#pragma unused cmdtext
}

CMD:register(playerid,cmdtext[]){
	cmd_rejestracja(playerid,cmdtext);
	return 1;
}

CMD:rejestracja(playerid,cmdtext[]){

	if (registerr == 0) {
		SendClientMessage(playerid, COLOR_RED, "››› Rejestracja jest wy³¹czona!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if (users >= maxusers) {
		SendClientMessage(playerid, COLOR_RED, "››› Przekroczono maksymalna liczbe zarejestrowanych!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	if(Registered[playerid]) {
		SendClientMessage(playerid, COLOR_RED2, "Jesteœ ju¿ zarejestrowany/a");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}

	ShowPlayerDialog(playerid,8,DIALOG_STYLE_PASSWORD,"{FFFFFF}Panel Rejestracji","{FFFF00}Dziêkujemy za poddanie konta rejestracji!\nAby siê zarejestrowaæ wymyœl has³o które\nbêdziesz musia³ wpisywaæ przy ka¿dym ponownym wejœciu na serwer\n\n{FFFFFF}Poni¿ej podaj wymyœlone has³o:","Rejestruj","Anuluj");

	return 1;
	#pragma unused cmdtext
}

CMD:setpass(playerid,cmdtext[]){
	cmd_zmienhaslo(playerid,cmdtext);
	return 1;
}

CMD:zmienhaslo(playerid,cmdtext[]){

	if(!logged[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"Aby zmieniac haslo musisz sie najpierw zalogowac  (/logowanie)");
		return 1;
	}

	ShowPlayerDialog(playerid,9,DIALOG_STYLE_PASSWORD,"Zmiana Hasla","{FFFF00}Podaj nowe haslo do tego konta","Zmieniam","Anuluj");

	return 1;
	#pragma unused cmdtext
}
/*
CMD:nowynick(playerid,cmdtext[]){
	if(NowyNickInUse > -1){
		SendClientMessage(playerid,COLOR_RED2,"››› Juz ktos przenosi swoje statystyki! sprobuj pózniej");
		return 1;
	}
	if(!logged[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"››› Nie jestes zalogowany/a!");
		return 1;
	}
	NowyNickInUse = playerid;
	ShowPlayerDialog(playerid,5,1,"Przenoszenie Statystyk","Podaj Nick na ktory chcesz przeniesc swoje statystyki","Dalej","Anuluj");
	return 1;
	#pragma unused cmdtext
}
*/
CMD:nowynick(playerid,params[]){
	if(!logged[playerid])
		return SendClientMessage(playerid,COLOR_RED2,"››› Nie jestes zalogowany/a!");		
	if(isnull(params)) 
		return SendClientMessage(playerid,COLOR_RED2,"Podaj /nowynick <nick>");
	if(strlen(params) < 3 || strlen(params) > 24 ) 
		return SendClientMessage(playerid,COLOR_RED2,"Podaj /nowynick <nick>");

	new new_nick[MAX_PLAYER_NAME];
	mysql_real_escape_string(params,new_nick);
	mysql_query_format("SELECT `Nick` FROM `fg_Players` WHERE `Nick`='%s'",new_nick);
	mysql_store_result();
	if(mysql_num_rows()) return SendClientMessage(playerid,COLOR_RED2,"››› Ktoœ ju¿ gra pod takim nickiem! 2");
	mysql_free_result();
	mysql_query_format("SELECT UNIX_TIMESTAMP(`Next_Nick`), `Next_Nick` FROM `fg_Players` WHERE `id`='%d' ",Player[playerid][uID]);
	new dest[128],buff[32], time;
	mysql_store_result();
	mysql_fetch_row(dest);
	mysql_free_result();
	sscanf(dest, "p<|>ds[32]",time,buff);
	if(time > gettime())return MSGF(playerid,COLOR_RED2,"››› Kolejna zmiana nicku mo¿liwa: %s",buff);
	
	new validchar[] = {';', ':',  '"', '{', '}', '!','#','%','^','&','*','(',')','~','`','/','\\','?','+'};
    for(new i; i < sizeof validchar; i++)
    {
        if(strfind(params, validchar[i], true) != -1) return SCM(playerid, -1, "Nick zawiera nieprawid³owe znaki!");
    }	
	format(Player[playerid][NewNick],24,"%s",new_nick);
	ShowPlayerDialog(playerid,DIALOG_NEWNICK,DIALOG_STYLE_PASSWORD,"Przenoszenie Statystyk","Podaj has³o do konta w celu bezpieczeñstwa!","Dalej","Anuluj");
	return 1;
}