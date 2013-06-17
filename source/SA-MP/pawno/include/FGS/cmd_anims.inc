CMD:anims(playerid,cmdtext[]){
	new string[800];
	strcat(string,"/Rece     /Rece2    /Rece3    /Rece4  /PSY /RozmowaAuto\n");
	strcat(string,"/Rece5    /Rece6    /Bar2     /Bar3 /Zegarek\n");
	strcat(string,"/Szafka   /Zegarek  /Lez      /Hide\n");
	strcat(string,"/Rzygaj   /Grubas   /Grubas2  /Taichi\n");
	strcat(string,"/Siadaj   /Chat     /Ratunku  /Kopniak\n");
	strcat(string,"/Dance    /Fucku    /Cellin   /Cellout\n");
	strcat(string,"/Pij      /Smoke    /Fsmoke   /Krzeslo\n");
	strcat(string,"/Krzeslo2 /Calus    /Trup     /Trup2\n");
	strcat(string,"/Wankin   /Wankout  /Deal     /Boks\n");
	strcat(string,"/Lol      /Bomba    /Aresztuj /Opalaj\n");
	strcat(string,"/Opalaj2  /Opalaj3  /Turlaj   /Klaps\n");
	strcat(string,"/Kradnij  /Kaleka   /Swat     /Swat2\n");
	strcat(string,"/Swat3    /Piwo     /Drunk    /Rap\n");
	strcat(string,"/Lookout  /Napad    /Papieros /Cpun\n");
	strcat(string,"/Cpun2    /Cpun3    /Cpun4    /Cpun5\n");
	strcat(string,"/Skok2    /Skok3    /Jedz     /Jedz2\n");
	strcat(string,"/Jedz3    /Wino     /Taniec   /Taniec2\n");
	strcat(string,"/Taniec3  /Taniec4  /Taniec5  /Taniec6\n");
	strcat(string,"/Taniec7  /Rolki    /Sprunk   /Inbedleft\n");
	strcat(string,"/Inbedright /Poddajsie  /Aresztowany  /Aresztuj2");
	ShowPlayerDialog(playerid,22,0,"CMD> Animacje",string,"OK","OK");
	return 1;
}
CMD:bar2(playerid,cmdtext[]){
	LoopingAnim(playerid, "BAR", "Barserve_bottle", 4.000000, 0, 1, 1, 1, -1);
	SendClientMessage(playerid, COLOR_ANIM, "Podajesz zimne piwko");
	return 1;
}
CMD:bar3(playerid,cmdtext[]){
	LoopingAnim(playerid, "BAR", "Barserve_give", 4.000000, 0, 1, 1, 1, -1);
	SendClientMessage(playerid, COLOR_ANIM, "Podajesz zimne piwko");
	return 1;
}
CMD:opalaj(playerid,cmdtext[]){
	LoopingAnim(playerid, "BEACH", "ParkSit_W_loop", 4.000000, 0, 1, 1, 1, -1);
	SendClientMessage(playerid, COLOR_ANIM, "Opalasz sie");
	return 1;
}
CMD:opalaj2(playerid,cmdtext[]){
	LoopingAnim(playerid, "BEACH", "SitnWait_loop_W", 4.000000, 0, 1, 1, 1, -1);
	SendClientMessage(playerid, COLOR_ANIM, "Opalasz sie");
	return 1;
}
CMD:rozmowaauto(playerid,cmdtext[]){
	LoopingAnim(playerid, "CAR_CHAT", "car_talkm_loop", 4.000000, 0, 1, 1, 1, -1);
	SendClientMessage(playerid, COLOR_ANIM, "Rozmawiasz z kims w aucie");
	return 1;
}
CMD:szafka(playerid,cmdtext[]){
	LoopingAnim(playerid, "COP_AMBIENT", "Copbrowse_nod", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Bierzesz cos z szafki");
	return 1;
}
CMD:zegarek(playerid,cmdtext[]){
	LoopingAnim(playerid, "COP_AMBIENT", "Coplook_nod", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Patrzysz na zegarek");
	return 1;
}
CMD:cpun2(playerid,cmdtext[]){
	LoopingAnim(playerid, "CRACK", "crckdeth1", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Lezysz jak cpun");
	return 1;
}
CMD:cpun3(playerid,cmdtext[]){
	LoopingAnim(playerid, "CRACK", "crckdeth3", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Lezysz jak cpun");
	return 1;
}
CMD:cpun4(playerid,cmdtext[]){
	LoopingAnim(playerid, "CRACK", "crckdeth4", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Lezysz jak cpun");
	return 1;
}
CMD:cpun5(playerid,cmdtext[]){
	LoopingAnim(playerid, "CRACK", "crckidle4", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Lezysz jak cpun");
	return 1;
}
CMD:rolki(playerid,cmdtext[]){
	LoopingAnim(playerid, "SKATE", "skate_sprint", 4.0999, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Jedziesz na rolkach");
	return 1;
}
CMD:wyskok3(playerid,cmdtext[]){
	LoopingAnim(playerid, "DAM_JUMP", "Jump_Roll", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Probujesz wykonac skok");
	return 1;
}
CMD:taniec(playerid,cmdtext[]){
	LoopingAnim(playerid, "DANCING", "bd_clap", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Tanczysz");
	return 1;
}
CMD:taniec2(playerid,cmdtext[]){
	LoopingAnim(playerid, "DANCING", "bd_clap1", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Tanczysz");
	return 1;
}
CMD:taniec3(playerid,cmdtext[]){
	LoopingAnim(playerid, "DANCING", "DAN_Down_A", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Tanczysz");
	return 1;
}
CMD:taniec4(playerid,cmdtext[]){
	LoopingAnim(playerid, "DANCING", "DAN_Left_A", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Tanczysz");
	return 1;
}
CMD:taniec5(playerid,cmdtext[]){
	LoopingAnim(playerid, "DANCING", "DAN_Right_A", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Tanczysz");
	return 1;
}
CMD:taniec6(playerid,cmdtext[]){
	LoopingAnim(playerid, "DANCING", "DAN_Up_A", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Tanczysz");
	return 1;
}
CMD:taniec7(playerid,cmdtext[]){
	LoopingAnim(playerid, "DANCING", "dnce_M_a", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Tanczysz");
	return 1;
}
CMD:grubas(playerid,cmdtext[]){
	LoopingAnim(playerid, "FAT", "FatWalk", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Idziesz jak grubas");
	return 1;
}
CMD:grubas2(playerid,cmdtext[]){
	LoopingAnim(playerid, "FAT", "FatRun", 4.000000, 1, 1, 1, 1, 1);
	SendClientMessage(playerid, COLOR_ANIM, "Biegniesz jak grubas");
	return 1;
}
CMD:jedz2(playerid,cmdtext[]){
	LoopingAnim(playerid, "FOOD", "FF_Die_Bkw", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Jesz cos");
	return 1;	
}
CMD:jedz3(playerid,cmdtext[]){
	LoopingAnim(playerid, "FOOD", "FF_Sit_Eat1", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Jesz cos");
	return 1;	
}
CMD:rece4(playerid,cmdtext[]){
	LoopingAnim(playerid, "GANGS", "hndshkfa", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Wymachyjesz Rekami");
	return 1;	
}
CMD:rece5(playerid,cmdtext[]){
	LoopingAnim(playerid, "GHANDS", "gsign1", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Wymachyjesz Rekami");
	return 1;	
}
CMD:rece6(playerid,cmdtext[]){
	LoopingAnim(playerid, "GHANDS", "gsign1LH", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Wymachyjesz Rekami");
	return 1;
}
CMD:krzeslo2(playerid,cmdtext[]){
	LoopingAnim(playerid, "JST_BUISNESS", "girl_02", 4.000000, 1, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Siadasz na krzesle jak kobieta");
	return 1;
}
CMD:turlaj(playerid,cmdtext[]){
	LoopingAnim(playerid, "MD_CHASE", "MD_BIKE_Lnd_Roll_F", 4.000000, 1, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Turlasz sie xD");
	return 1;
}
CMD:boks(playerid,cmdtext[]){
	LoopingAnim(playerid, "GYMNASIUM", "GYMshadowbox", 4.000000, 1, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Trenujesz boks");
	return 1;
}
CMD:kopniak(playerid,cmdtext[]){
	LoopingAnim(playerid, "POLICE", "Door_Kick", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Kopiesz :P");
	return 1;
	
}
CMD:opalaj3(playerid,cmdtext[]){
	LoopingAnim(playerid, "SUNBATHE", "ParkSit_W_idleA", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Opalasz sie");
	return 1;
}
CMD:swat(playerid,cmdtext[]){
	LoopingAnim(playerid, "SWAT", "swt_breach_01", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Biegasz jak SWAT");
	return 1;
}
CMD:swat2(playerid,cmdtext[]){
	LoopingAnim(playerid, "SWAT", "swt_breach_02", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Biegasz jak SWAT");
	return 1;
}
CMD:swat3(playerid,cmdtext[]){
	LoopingAnim(playerid, "SWAT", "swt_breach_03", 4.000000, 0, 1, 1, 1, 0);
	SendClientMessage(playerid, COLOR_ANIM, "Biegasz jak SWAT");
	return 1;
}
CMD:wyskok2(playerid,cmdtext[]){
	LoopingAnim(playerid, "DAM_JUMP","DAM_Launch",4.1,0,1,1,1,1); // Umierasz
	SendClientMessage(playerid, COLOR_ANIM, "Robisz efektowny skok");
	return 1;
}
CMD:trup2(playerid,cmdtext[]){
	LoopingAnim(playerid, "SWAT","gnstwall_injurd",4.0,1,0,0,0,0); // Umierasz
	SendClientMessage(playerid, COLOR_ANIM, "Udajesz trupa");
	return 1;
}
CMD:ratunku(playerid,cmdtext[]){
	LoopingAnim(playerid,"BD_FIRE","BD_Panic_03",4.0,1,0,0,0,0); // Ratunku
	SendClientMessage(playerid, COLOR_ANIM, "Machasz o pomoc!");
	return 1;
}
CMD:trup(playerid,cmdtext[]){
	LoopingAnim(playerid, "WUZI", "CS_Dead_Guy", 4.1,0,1,1,1,1); // Umierasz
	SendClientMessage(playerid, COLOR_ANIM, "Udajesz trupa");
	return 1;
}
CMD:calus(playerid,cmdtext[]){
	LoopingAnim(playerid, "KISSING", "Playa_Kiss_02", 4.0,0,0,0,0,0); // CAlOWANIE
	SendClientMessage(playerid, COLOR_ANIM, "Calujesz kogos");
	return 1;
}
CMD:sikaj(playerid,cmdtext[]){
	SetPlayerSpecialAction(playerid,68);
	SendClientMessage(playerid, COLOR_ANIM, "Odlewasz sie");
	return 1;
}
CMD:krzeslo(playerid,cmdtext[]){
	LoopingAnim(playerid,"INT_OFFICE","OFF_Sit_Idle_Loop",4.0,1,0,0,0,0); // Krzeslo
	SendClientMessage(playerid, COLOR_ANIM, "Siadasz na krzesle");
	return 1;
}
CMD:rece(playerid,cmdtext[]){
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
	SendClientMessage(playerid, COLOR_ANIM, "Poddajesz sie");
	return 1;
	
}
CMD:wankin(playerid,cmdtext[]){
	LoopingAnim(playerid, "PAULNMAC", "wank_loop", 4.0,1,0,0,0,0); // Walenie konia
	SendClientMessage(playerid, COLOR_ANIM, "Walisz konia");
	return 1;
}
CMD:psy(playerid,cmdtext[]){
 	ApplyAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 1, 0, 0, 0, 0); //Za³o¿enie r¹k
	SendClientMessage(playerid, COLOR_ANIM, "Pokazujesz swoje! :X!");
	return 1;
}
CMD:wal(playerid,cmdtext[]){
	return cmd_wankin(playerid,cmdtext);
}
CMD:kiss(playerid,cmdtext[]){
	LoopingAnim(playerid, "KISSING", "Playa_Kiss_02", 3.0, 0, 0, 0, 0, 0); // Kiss
	SendClientMessage(playerid, COLOR_ANIM, "Ca³ujesz siê :)");
	return 1;
}
CMD:caluj(playerid,cmdtext[]){
	return cmd_kiss(playerid,cmdtext);
}
CMD:pocaluj(playerid,cmdtext[]){
	return cmd_kiss(playerid,cmdtext);
}
CMD:pocalunek(playerid,cmdtext[]){
	return cmd_kiss(playerid,cmdtext);
}
CMD:wankout(playerid,cmdtext[]){
	LoopingAnim(playerid, "PAULNMAC", "wank_out", 4.0, 0, 0, 0, 0, 0); // Wytrysk
	SendClientMessage(playerid, COLOR_ANIM, "Robisz wytrysk :D");
	return 1;
}
CMD:cellin(playerid,cmdtext[]){
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
	SendClientMessage(playerid, COLOR_ANIM, "Dzwonisz do mamy");
	return 1;
}
CMD:piwo(playerid,cmdtext[]){
	KillTimer(DrunkTimer[playerid]);
	DrunkTimer[playerid] = SetTimerEx("NotDrunk",30000,0,"i",playerid);
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DRINK_BEER);
	SendClientMessage(playerid, COLOR_ANIM, "Pijesz Piwo!");
	return 1;
}
CMD:browar(playerid,cmdtext[]){
	return cmd_piwo(playerid,cmdtext);
}
CMD:telefon(playerid,cmdtext[]){
	return cmd_cellin(playerid,cmdtext);
}
CMD:pijak(playerid,cmdtext[]){
	return cmd_drunk(playerid,cmdtext);
}
CMD:telefonoff(playerid,cmdtext[]){
	cmd_cellout(playerid,cmdtext);
	return 1;
}
CMD:wino(playerid,cmdtext[]){
	KillTimer(DrunkTimer[playerid]);
	DrunkTimer[playerid] = SetTimerEx("NotDrunk",60000,0,"i",playerid);
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DRINK_WINE);
	SendClientMessage(playerid, COLOR_ANIM, "Pijesz Wino!");
	return 1;
}
CMD:joint(playerid,cmdtext[]){
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
	SendClientMessage(playerid, COLOR_ANIM, "Aby sie zbakaæ klikaj!");
	return 1;
}
CMD:papieros(playerid,cmdtext[]){
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_SMOKE_CIGGY);
	SendClientMessage(playerid, COLOR_ANIM, "Palisz Papierosa!");
	return 1;
}
CMD:sprunk(playerid,cmdtext[]){
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DRINK_SPRUNK);
	SendClientMessage(playerid, COLOR_ANIM, "Pijesz Sprunka!");
	return 1;
}
CMD:cellout(playerid,cmdtext[]){
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
	SendClientMessage(playerid, COLOR_ANIM, "Odkladasz telefon ");
	return 1;
}
CMD:drunk(playerid,cmdtext[]){
	LoopingAnim(playerid,"PED","WALK_DRUNK",4.0,1,1,1,1,1);
	SendClientMessage(playerid, COLOR_ANIM, "Chodzisz jak pijany/a");
	return 1;
}
CMD:bomb(playerid,cmdtext[]){
	ClearAnimations(playerid);
	OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0); // Podkladasz bombe.
	SendClientMessage(playerid, COLOR_ANIM, "Podkladasz bombe");
	return 1;
}
CMD:aresztuj(playerid,cmdtext[]){
	LoopingAnim(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1); // aresztujesz kogos.
	SendClientMessage(playerid, COLOR_ANIM, "Aresztujesz kogos");
	return 1;
}
CMD:rap(playerid,cmdtext[]){
	LoopingAnim(playerid, "RAPPING", "RAP_B_Loop", 4.0,1,0,0,0,0); // Rapujesz
	SendClientMessage(playerid, COLOR_ANIM, "Rapujesz ");
	return 1;
}
CMD:lookout(playerid,cmdtext[]){
	OnePlayAnim(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0); // Patrzysz czy nie ma policji.
	SendClientMessage(playerid, COLOR_ANIM, "Rozgladasz sie");
	return 1;
}
CMD:napad(playerid,cmdtext[]){
	LoopingAnim(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0); // Napad
	SendClientMessage(playerid, COLOR_ANIM, "Robisz napad");
	return 1;
}
CMD:rece2(playerid,cmdtext[]){
	LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1); // Rece
	SendClientMessage(playerid, COLOR_ANIM, "Zakladasz rece");
	return 1;
}
CMD:lez(playerid,cmdtext[]){
	LoopingAnim(playerid,"SUNBATHE","batherdown",4.1,0,1,1,1,1); // Lez
	SendClientMessage(playerid, COLOR_ANIM, "Lezysz ");
	return 1;
}
CMD:hide(playerid,cmdtext[]){
	LoopingAnim(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0); // Oslaniasz sie.
	SendClientMessage(playerid, COLOR_ANIM, "Oslaniasz sie. ");
	return 1;	
}
CMD:rzygaj(playerid,cmdtext[]){
	OnePlayAnim(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0); // Rzygasz
	SendClientMessage(playerid, COLOR_ANIM, "Blee! ");
	return 1;	
}
CMD:jedz(playerid,cmdtext[]){
	OnePlayAnim(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0); // jesz buregera
	SendClientMessage(playerid, COLOR_ANIM, "Jesz cos ");
	return 1;	
}
CMD:deal(playerid,cmdtext[]){
	OnePlayAnim(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0); // Dilujesz
	SendClientMessage(playerid, COLOR_ANIM, "Dealujesz z kims ");
	return 1;	
}
CMD:cpun(playerid,cmdtext[]){
	LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0); // Cpun
	SendClientMessage(playerid, COLOR_ANIM, "Lezysz jak cpun");
	return 1;	
}
CMD:smoke(playerid,cmdtext[]){
	LoopingAnim(playerid,"SMOKING","M_smklean_loop",4.0, 1, 0, 0, 0, 0); // Palisz
	SendClientMessage(playerid, COLOR_ANIM, "Palisz papierosa");
	return 1;	
}
CMD:fsmoke(playerid,cmdtext[]){
	LoopingAnim(playerid,"SMOKING","F_smklean_loop",4.0, 1, 0, 0, 0, 0); // Palisz
	SendClientMessage(playerid, COLOR_ANIM, "Palisz papierosa jak kobieta ");
	return 1;	
}
CMD:smoke2(playerid,cmdtext[]){
	LoopingAnim(playerid,"SMOKING","M_smkstnd_loop",4.0, 1, 0, 0, 0, 0); // Palisz
	SendClientMessage(playerid, COLOR_ANIM, "Palisz papierosa");
	return 1;	
}
CMD:rece3(playerid,cmdtext[]){
	LoopingAnim(playerid,"DAM_JUMP","DAM_Dive_Loop",4.0, 1, 0, 0, 0, 0); // Palisz
	SendClientMessage(playerid, COLOR_ANIM, "Stoisz na rekach");
	return 1;
}
CMD:siadaj(playerid,cmdtext[]){
	LoopingAnim(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0); // Siadasz
	SendClientMessage(playerid, COLOR_ANIM, "Siadasz");
	return 1;
}
CMD:usiadz(playerid,cmdtext[]){
	return cmd_siadaj(playerid,cmdtext);
}
CMD:chat(playerid,cmdtext[]){
	LoopingAnim(playerid,"PED","IDLE_CHAT", 4.0,1,0,0,0,0);
	SendClientMessage(playerid, COLOR_ANIM, "Rozmawiasz z kims");
	return 1;	
}
CMD:talk(playerid,cmdtext[]){
	return cmd_chat(playerid,cmdtext);
}
CMD:pal(playerid,cmdtext[]){
	return cmd_papieros(playerid,cmdtext);
}
CMD:fucku(playerid,cmdtext[]){
	OnePlayAnim(playerid,"PED","fucku",4.0,0,0,0,0,0);
	SendClientMessage(playerid, COLOR_ANIM, "Pokazujesz Fuck You!!! ");
	return 1;	
}
CMD:taichi(playerid,cmdtext[]){
	LoopingAnim(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
	SendClientMessage(playerid, COLOR_ANIM, "Umiesz takewondo ");
	return 1;
}
CMD:pij(playerid,cmdtext[]){
	LoopingAnim(playerid,"BAR","dnk_stndF_loop",4.0,1,0,0,0,0);
	SendClientMessage(playerid, COLOR_ANIM, "Pijesz cos ");
	return 1;	
}
CMD:inbedright(playerid,cmdtext[]){
	LoopingAnim(playerid,"INT_HOUSE","BED_In_R",4.1,0,1,1,1,1);
	SendClientMessage(playerid, COLOR_ANIM, "Idzisz spac");
	return 1;	
}
CMD:inbedleft(playerid,cmdtext[]){
	LoopingAnim(playerid,"INT_HOUSE","BED_In_L",4.1,0,1,1,1,1);
	SendClientMessage(playerid, COLOR_ANIM, "Idzisz spac");
	return 1;	
}
CMD:dance(playerid,cmdtext[]){
	new dance;
	if(sscanf(cmdtext,"d",dance))return SendClientMessage(playerid,COLOR_LIGHTRED,"U¿yj: /dance [1-4]");
	if(dance < 1 || dance > 4) return SendClientMessage(playerid,COLOR_LIGHTRED,"U¿yj: /dance [1-4]");
	if(dance == 1) {
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
	} else if(dance == 2) {
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE2);
	} else if(dance == 3) {
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE3);
	} else if(dance == 4) {
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE4);
	}
	return 1;
}
CMD:lol(playerid,cmdtext[]){
	LoopingAnim(playerid, "RAPPING", "Laugh_01", 4.0, 1, 0, 0, 0, 0); // Laugh
	SendClientMessage(playerid,COLOR_ANIM,"smiejesz sie");
	return 1;
}
CMD:aresztuj2(playerid,cmdtext[]){
	ApplyAnimation(playerid, "POLICE", "plc_drgbst_01", 4.0, 0, 0, 0, 0, 0); // Arrest
	SendClientMessage(playerid,COLOR_ANIM,"Aresztujesz kogos");
	return 1;
}
CMD:aresztowany(playerid,cmdtext[]){
	ApplyAnimation(playerid, "POLICE", "crm_drgbst_01", 4.0, 0, 0, 0, 0, 0); // Arrested
	SendClientMessage(playerid,COLOR_ANIM,"Zostajesz aresztowany/a");
	return 1;
}
CMD:kaleka(playerid,cmdtext[]){
	LoopingAnim(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0); // Injured
	SendClientMessage(playerid,COLOR_ANIM,"Kleczysz jak kaleka");
	return 1;
}
CMD:klaps(playerid,cmdtext[]){
	ApplyAnimation(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0); // Ass Slapping
	SendClientMessage(playerid,COLOR_ANIM,"Dajesz klapsa komus");
	return 1;	
}
CMD:astop(playerid,cmdtext[]){
	ClearAnimations(playerid);
	return 1;
}
CMD:animstop(playerid,cmdtext[]){
	return cmd_astop(playerid,cmdtext);
}