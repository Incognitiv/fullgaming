new Text:PM1;
//new Text:BialyEkran;
new Text:VannBox;
new Text:logoFullGaming;
new Text:urlFullGaming;
new Text:Kod;
new Text:TextDrawLogoGra1;
new Text:TextDrawLogoGra2;
new Text:TextDrawLogoGra3;

new Text:OnlineUsers;
new Text:AnnFade;

new Text:playerHudBoxMain;
new Text:playerHudPaski[6];
new Text:playerHudLabele[4];

// tabelka zapisow
new Text:tabelka_zapisow_box;
new Text:tabelka_zapisow_label[2];

new Text:car_box;
new PlayerText:AnnTD[MAX_GRACZY];
new Text:Glosowanie;

	
new Text3D:PlayerLabel[MAX_GRACZY];
new Text:tdVipAnn[2];
//new Text:tdVip;
new Text:Tut[14];
new Text:FreeZone;
new Text:BezDmZone;
new Text:Czas;
new Text:Panorama[2];
new Text:attraction_ctf;
new Text:attraction_race[MAX_GRACZY];
new Text:attraction_chowany;
new 
	// pasek
	PlayerText:playerTd_exp[MAX_GRACZY],
	PlayerText:playerTd_level[MAX_GRACZY],
	PlayerText:playerTd_timeplay[MAX_GRACZY],
	PlayerText:playerTd_portfel[MAX_GRACZY],
	// car
	PlayerText:playerTd_carname[MAX_GRACZY],
	PlayerText:playerTd_carspeed[MAX_GRACZY],
	PlayerText:playerTd_carhealth[MAX_GRACZY]
;	

VisualTextDraw()
{
	Kod = TextDrawCreate(320.000000, 1.000000, "Test reakcji: 2m502n3Ni");
	TextDrawAlignment(Kod, 2);
	TextDrawBackgroundColor(Kod, 40);
	TextDrawFont(Kod, 1);
	TextDrawLetterSize(Kod, 0.239999, 1.000000);
	TextDrawColor(Kod, -2134311169);
	TextDrawSetOutline(Kod, 1);
	TextDrawSetProportional(Kod, 1);
	TextDrawUseBox(Kod, 1);
	TextDrawBoxColor(Kod, 50);
	TextDrawTextSize(Kod, 0.000000, 150.000000);

	// glowny box stat
	playerHudBoxMain = TextDrawCreate(320.000000, 425.000000, "box_pasek");
	TextDrawBackgroundColor(playerHudBoxMain, 255);
	TextDrawFont(playerHudBoxMain, 1);
	TextDrawLetterSize(playerHudBoxMain, 0.000000, 2.899998);
	TextDrawColor(playerHudBoxMain, -1);
	TextDrawSetOutline(playerHudBoxMain, 0);
	TextDrawSetProportional(playerHudBoxMain, 1);
	TextDrawSetShadow(playerHudBoxMain, 1);
	TextDrawUseBox(playerHudBoxMain, 1);
	TextDrawBoxColor(playerHudBoxMain, 85);
	TextDrawTextSize(playerHudBoxMain, 607.000000, 0.000000);

	playerHudLabele[0] = TextDrawCreate(321.000000, 424.000000, "EXP");
	TextDrawBackgroundColor(playerHudLabele[0], 20);
	TextDrawFont(playerHudLabele[0], 2);
	TextDrawLetterSize(playerHudLabele[0], 0.219999, 1.000000);
	TextDrawColor(playerHudLabele[0], -1);
	TextDrawSetOutline(playerHudLabele[0], 1);
	TextDrawSetProportional(playerHudLabele[0], 1);

	playerHudLabele[1] = TextDrawCreate(394.000000, 424.000000, "Poziom");
	TextDrawBackgroundColor(playerHudLabele[1], 20);
	TextDrawFont(playerHudLabele[1], 2);
	TextDrawLetterSize(playerHudLabele[1], 0.219999, 1.000000);
	TextDrawColor(playerHudLabele[1], -1);
	TextDrawSetOutline(playerHudLabele[1], 1);
	TextDrawSetProportional(playerHudLabele[1], 1);

	playerHudLabele[2] = TextDrawCreate(467.000000, 424.000000, "Czas gry");
	TextDrawBackgroundColor(playerHudLabele[2], 20);
	TextDrawFont(playerHudLabele[2], 2);
	TextDrawLetterSize(playerHudLabele[2], 0.219999, 1.000000);
	TextDrawColor(playerHudLabele[2], -1);
	TextDrawSetOutline(playerHudLabele[2], 1);
	TextDrawSetProportional(playerHudLabele[2], 1);

	playerHudLabele[3] = TextDrawCreate(540.000000, 424.000000, "Portfel");
	TextDrawBackgroundColor(playerHudLabele[3], 20);
	TextDrawFont(playerHudLabele[3], 2);
	TextDrawLetterSize(playerHudLabele[3], 0.219999, 1.000000);
	TextDrawColor(playerHudLabele[3], -1);
	TextDrawSetOutline(playerHudLabele[3], 1);
	TextDrawSetProportional(playerHudLabele[3], 1);

	// paseczki
	playerHudPaski[0] = TextDrawCreate(391.000000, 404.000000, "I");
	TextDrawAlignment(playerHudPaski[0], 2);
	TextDrawBackgroundColor(playerHudPaski[0], 51);
	TextDrawFont(playerHudPaski[0], 2);
	TextDrawLetterSize(playerHudPaski[0], 0.140000, 7.500000);
	TextDrawColor(playerHudPaski[0], -1075577089);
	TextDrawSetOutline(playerHudPaski[0], 1);
	TextDrawSetProportional(playerHudPaski[0], 1);

	playerHudPaski[1] = TextDrawCreate(464.000000, 404.000000, "I");
	TextDrawAlignment(playerHudPaski[1], 2);
	TextDrawBackgroundColor(playerHudPaski[1], 51);
	TextDrawFont(playerHudPaski[1], 2);
	TextDrawLetterSize(playerHudPaski[1], 0.140000, 7.500000);
	TextDrawColor(playerHudPaski[1], -1075577089);
	TextDrawSetOutline(playerHudPaski[1], 1);
	TextDrawSetProportional(playerHudPaski[1], 1);

	playerHudPaski[2] = TextDrawCreate(537.000000, 404.000000, "I");
	TextDrawAlignment(playerHudPaski[2], 2);
	TextDrawBackgroundColor(playerHudPaski[2], 51);
	TextDrawFont(playerHudPaski[2], 2);
	TextDrawLetterSize(playerHudPaski[2], 0.140000, 7.500000);
	TextDrawColor(playerHudPaski[2], -1075577089);
	TextDrawSetOutline(playerHudPaski[2], 1);
	TextDrawSetProportional(playerHudPaski[2], 1);

	playerHudPaski[3] = TextDrawCreate(610.000000, 404.000000, "I");
	TextDrawAlignment(playerHudPaski[3], 2);
	TextDrawBackgroundColor(playerHudPaski[3], 51);
	TextDrawFont(playerHudPaski[3], 2);
	TextDrawLetterSize(playerHudPaski[3], 0.140000, 7.500000);
	TextDrawColor(playerHudPaski[3], -1075577089);
	TextDrawSetOutline(playerHudPaski[3], 1);
	TextDrawSetProportional(playerHudPaski[3], 1);

	playerHudPaski[4] = TextDrawCreate(318.000000, 404.000000, "I");
	TextDrawAlignment(playerHudPaski[4], 2);
	TextDrawBackgroundColor(playerHudPaski[4], 51);
	TextDrawFont(playerHudPaski[4], 2);
	TextDrawLetterSize(playerHudPaski[4], 0.140000, 7.500000);
	TextDrawColor(playerHudPaski[4], -1075577089);
	TextDrawSetOutline(playerHudPaski[4], 1);
	TextDrawSetProportional(playerHudPaski[4], 1);

	playerHudPaski[5] = TextDrawCreate(477.000000, 421.000000, "-");
	TextDrawAlignment(playerHudPaski[5], 2);
	TextDrawBackgroundColor(playerHudPaski[5], 51);
	TextDrawFont(playerHudPaski[5], 2);
	TextDrawLetterSize(playerHudPaski[5], 27.859991, 0.499998);
	TextDrawColor(playerHudPaski[5], -1075577089);
	TextDrawSetOutline(playerHudPaski[5], 1);
	TextDrawSetProportional(playerHudPaski[5], 1);
	// end paski

	OnlineUsers = TextDrawCreate(568.000000, 1.000000, "1 gracz (~y~0 ~w~|~g~0 ~w~|~r~0~w~)");
	TextDrawAlignment(OnlineUsers, 2);
	TextDrawBackgroundColor(OnlineUsers, 16);
	TextDrawFont(OnlineUsers, 1);
	TextDrawLetterSize(OnlineUsers, 0.239999, 0.799998);
	TextDrawColor(OnlineUsers, -1);
	TextDrawSetOutline(OnlineUsers, 1);
	TextDrawSetProportional(OnlineUsers, 1);
	TextDrawUseBox(OnlineUsers, 1);
	TextDrawBoxColor(OnlineUsers, 48);
	TextDrawTextSize(OnlineUsers, 0.000000, 110.000000);

	Tut[0] = TextDrawCreate(320.0, 200.0,"~w~Przewodnik po FullGaming.~n~Tutaj dowiesz sie troszke o serwerze.~n~Aby przerwac przewodnik: ~y~/TutEnd~w~.~n~~b~~h~1/14");
	Tut[1] = TextDrawCreate(320.0, 200.0,"~w~To jest Grecja! Wiecej takich atrakcjii znajdziesz pod komenda /Atrakcje :)~n~Pamietaj aby zapisywaly ci sie statystyki~n~Wpisz /Rejestracja~n~~b~~h~2/14");
	Tut[2] = TextDrawCreate(320.0, 200.0,"~w~To jest ~r~/Party ~w~mozna tutaj organizowac imprezy~n~Mozesz tez zaprosic partnera na randke uzywajac komendy /Randka!~n~~b~~h~3/14");
	Tut[3] = TextDrawCreate(320.0, 200.0,"~w~To jest ~r~/Statek ~w~za przebywanie na nim dostajesz pieniadze~n~~n~(na statku jest zakaz zabijania!) ~n~~b~~h~4/14");
	Tut[4] = TextDrawCreate(320.0, 200.0,"~w~Jesli chcesz miec wiecej kasy wpisz ~r~/Posiadlosci~n~~n~~w~(im wiecej ich posiadasz tym wiecej zarabiasz) ~n~~b~~h~5/14");
	Tut[5] = TextDrawCreate(320.0, 200.0,"~w~Tutaj mozesz tuningowac swój pojazd~n~mozesz to robic takze wszedzie~n~za pomoca komend: ~r~/tune  /tunemenu ~n~~b~~h~6/14");
	Tut[6] = TextDrawCreate(320.0, 200.0,"~w~To jest ~r~/Wojsko ~w~tutaj mozna robic CK,DB,HK~n~ oraz posiadac bronie specjalne~n~~n~(aby kupic taka bron uzyj ~r~/BronieS~w~) ~n~~b~~h~7/14");
	Tut[7] = TextDrawCreate(320.0, 200.0,"~w~To jest jedno z ~r~Osiedli mieszkalnych~n~~w~mozna tutaj kupowac swój prywatny dom~n~~n~(aby kupic taki dom wpisz ~r~/DomPomoc~w~) ~n~~b~~h~8/14");
	Tut[8] = TextDrawCreate(320.0, 200.0,"~w~To jest ~r~/JetArena~n~~w~Tutaj mozesz polatac jetpackiem. ~n~Dostepne areny: ~r~/RPG /Minigun /Arena~n~~b~~h~9/14");
	Tut[9] = TextDrawCreate(320.0, 200.0,"~w~To jest ~r~/Arena~w~~n~Tutaj mozesz walczyc z innymi graczami w ciekawym otoczeniu obiektow ~n~~b~~h~10/14");
	Tut[10] = TextDrawCreate(320.0, 200.0,"~w~To jest ~r~/Trzepak~w~~n~Mozna tutaj posiedziec z kumplami~n~~n~Wiecej info: ~r~/Smietnik~n~~b~~h~11/14");
	Tut[11] = TextDrawCreate(320.0, 200.0,"~w~Aby dobrze bawic sie na serwerze koniecznie zajzyj pod~n~~r~/Atrakcje~n~~b~~h~12/14");
	Tut[12] = TextDrawCreate(320.0, 200.0,"~w~To jest ~r~/Baza4~n~~w~komendy do zarzadzania baza znajdziesz pod: ~r~/Baza4Info ~n~~b~~h~13/14");
	Tut[13] = TextDrawCreate(320.0, 200.0,"~w~To wszystko to tylko podstawowe mo¿liwoœæi naszego serwera!~n~Z czasem poznasz jeszcze wiecej ciekawych rzeczy~n~~n~(aby dowiedziec sie wiecej sprawdz: ~r~/pomoc~w~) ~n~~b~~h~14/14");

	for(new x=0;x<14;x++){
		TextDrawUseBox(Tut[x], 0);
		TextDrawFont(Tut[x], 1);
		TextDrawTextSize(Tut[x],320,320);
		TextDrawSetShadow(Tut[x],0);
		TextDrawSetOutline(Tut[x],1);
		TextDrawBackgroundColor(Tut[x],0x000000FF);
		TextDrawAlignment(Tut[x],2);
		TextDrawUseBox(Tut[x],1);
		TextDrawBoxColor(Tut[x],0x00000050);
	}

	attraction_ctf = TextDrawCreate(561.000000, 325.000000, "Pozycja: 1/4~n~Checkpoint: 4/15");
	TextDrawAlignment(attraction_ctf, 2);
	TextDrawBackgroundColor(attraction_ctf, 255);
	TextDrawFont(attraction_ctf, 1);
	TextDrawLetterSize(attraction_ctf, 0.270000, 0.899999);
	TextDrawColor(attraction_ctf, -1);
	TextDrawSetOutline(attraction_ctf, 0);
	TextDrawSetProportional(attraction_ctf, 1);
	TextDrawSetShadow(attraction_ctf, 1);
	TextDrawUseBox(attraction_ctf, 1);
	TextDrawBoxColor(attraction_ctf, 85);
	TextDrawTextSize(attraction_ctf, 10.000000, 170.000000);

	for (new i; i < MAX_GRACZY; i++ ) {
		attraction_race[i] = TextDrawCreate(561.000000, 325.000000, "Pozycja: 1/4~n~Checkpoint: 4/15");
		TextDrawAlignment(attraction_race[i], 2);
		TextDrawBackgroundColor(attraction_race[i], 255);
		TextDrawFont(attraction_race[i], 1);
		TextDrawLetterSize(attraction_race[i], 0.270000, 0.899999);
		TextDrawColor(attraction_race[i], -1);
		TextDrawSetOutline(attraction_race[i], 0);
		TextDrawSetProportional(attraction_race[i], 1);
		TextDrawSetShadow(attraction_race[i], 1);
		TextDrawUseBox(attraction_race[i], 1);
		TextDrawBoxColor(attraction_race[i], 85);
		TextDrawTextSize(attraction_race[i], 10.000000, 170.000000);
	}
	

	attraction_chowany = TextDrawCreate(561.000000, 325.000000, "Pozycja: 1/4~n~Checkpoint: 4/15");
	TextDrawAlignment(attraction_chowany, 2);
	TextDrawBackgroundColor(attraction_chowany, 255);
	TextDrawFont(attraction_chowany, 1);
	TextDrawLetterSize(attraction_chowany, 0.270000, 0.899999);
	TextDrawColor(attraction_chowany, -1);
	TextDrawSetOutline(attraction_chowany, 0);
	TextDrawSetProportional(attraction_chowany, 1);
	TextDrawSetShadow(attraction_chowany, 1);
	TextDrawUseBox(attraction_chowany, 1);
	TextDrawBoxColor(attraction_chowany, 85);
	TextDrawTextSize(attraction_chowany, 10.000000, 170.000000);

	car_box = TextDrawCreate(561.000000, 384.000000, "car_box");
	TextDrawAlignment(car_box, 2);
	TextDrawBackgroundColor(car_box, 255);
	TextDrawFont(car_box, 1);
	TextDrawLetterSize(car_box, 0.000000, 4.000000);
	TextDrawColor(car_box, -1);
	TextDrawSetOutline(car_box, 0);
	TextDrawSetProportional(car_box, 1);
	TextDrawSetShadow(car_box, 1);
	TextDrawUseBox(car_box, 1);
	TextDrawBoxColor(car_box, 85);
	TextDrawTextSize(car_box, 10.000000, 170.000000);



	// "%s %s~n~~y~%d       ~w~/TAK   ~g~%d   ~w~/NIE   ~r~%d"
	// "Czy twoja stara jest chuda? ~n~ ~n~~y~TAK!    ~w~Glosow: 30"

	Glosowanie = TextDrawCreate(225.000000, 220.000000, "Czy jestes glupi? ~n~~y~25       ~w~/TAK   ~g~100   ~w~/NIE   ~r~50");
	TextDrawAlignment(Glosowanie, 3);
	TextDrawBackgroundColor(Glosowanie, 16);
	TextDrawFont(Glosowanie, 1);
	TextDrawLetterSize(Glosowanie, 0.259999, 1.099998);
	TextDrawColor(Glosowanie, -1);
	TextDrawSetOutline(Glosowanie, 1);
	TextDrawSetProportional(Glosowanie, 1);
	TextDrawUseBox(Glosowanie, 1);
	TextDrawBoxColor(Glosowanie, 1584725);
	TextDrawTextSize(Glosowanie, 340.000000, 160.000000);

	FreeZone = TextDrawCreate(553.000000, 100.000000, "STREFA ~r~SMIERCI");
	TextDrawAlignment(FreeZone, 2);
	TextDrawBackgroundColor(FreeZone, 34);
	TextDrawFont(FreeZone, 3);
	TextDrawLetterSize(FreeZone, 0.360000, 1.200000);
	TextDrawColor(FreeZone, -1);
	TextDrawSetOutline(FreeZone, 1);
	TextDrawSetProportional(FreeZone, 1);
	
	BezDmZone = TextDrawCreate(553.000000, 100.000000, "STREFA ~b~~h~BEZ DM");
	TextDrawAlignment(BezDmZone, 2);
	TextDrawBackgroundColor(BezDmZone, 34);
	TextDrawFont(BezDmZone, 3);
	TextDrawLetterSize(BezDmZone, 0.360000, 1.200000);
	TextDrawColor(BezDmZone, -1);
	TextDrawSetOutline(BezDmZone, 1);
	TextDrawSetProportional(BezDmZone, 1);
	
	// tabelka zapisow - boxy
	tabelka_zapisow_box = TextDrawCreate(295.000000, 384.000000, "event_box");
	TextDrawBackgroundColor(tabelka_zapisow_box, 255);
	TextDrawFont(tabelka_zapisow_box, 3);
	TextDrawLetterSize(tabelka_zapisow_box, 0.000000, 6.199995);
	TextDrawColor(tabelka_zapisow_box, -1);
	TextDrawSetOutline(tabelka_zapisow_box, 0);
	TextDrawSetProportional(tabelka_zapisow_box, 1);
	TextDrawSetShadow(tabelka_zapisow_box, 1);
	TextDrawUseBox(tabelka_zapisow_box, 1);
	TextDrawBoxColor(tabelka_zapisow_box, 85);
	TextDrawTextSize(tabelka_zapisow_box, 170.000000, -15.000000);


	// tabelka zapisy - labele
	tabelka_zapisow_label[0] = TextDrawCreate(174.000000, 366.000000, "~n~~n~~g~~h~/Chowany~n~~g~~h~/Skoki~n~~g~~h~/Tower~n~~g~~h~/WG~n~~g~~h~/Hay~n~~g~~h~/Derby");
	TextDrawBackgroundColor(tabelka_zapisow_label[0], 32);
	TextDrawFont(tabelka_zapisow_label[0], 2);
	TextDrawLetterSize(tabelka_zapisow_label[0], 0.180000, 1.000000);
	TextDrawColor(tabelka_zapisow_label[0], -1);
	TextDrawSetOutline(tabelka_zapisow_label[0], 1);
	TextDrawSetProportional(tabelka_zapisow_label[0], 1);

	tabelka_zapisow_label[1] = TextDrawCreate(278.000000, 366.000000, "~n~~n~~w~0/4~n~~w~0/2~n~~w~0/3~n~~w~0/2~n~~w~0/3~n~~w~0/4");
	TextDrawAlignment(tabelka_zapisow_label[1], 2);
	TextDrawBackgroundColor(tabelka_zapisow_label[1], 32);
	TextDrawFont(tabelka_zapisow_label[1], 2);
	TextDrawLetterSize(tabelka_zapisow_label[1], 0.180000, 1.000000);
	TextDrawColor(tabelka_zapisow_label[1], -1);
	TextDrawSetOutline(tabelka_zapisow_label[1], 1);
	TextDrawSetProportional(tabelka_zapisow_label[1], 1);

	// end tabelka zapisy
	// ------------------

	logoFullGaming = TextDrawCreate(48.000000, 424.000000, "FullGaming");
	TextDrawBackgroundColor(logoFullGaming, 34);
	TextDrawFont(logoFullGaming, 3);
	TextDrawLetterSize(logoFullGaming, 0.419999, 1.399999);
	TextDrawColor(logoFullGaming, 495316223);
	TextDrawSetOutline(logoFullGaming, 1);
	TextDrawSetProportional(logoFullGaming, 1);

	urlFullGaming = TextDrawCreate(30.000000, 438.000000, "WWW.FULLGAMING.PL");
	TextDrawBackgroundColor(urlFullGaming, 34);
	TextDrawFont(urlFullGaming, 1);
	TextDrawLetterSize(urlFullGaming, 0.300000, 1.000000);
	TextDrawColor(urlFullGaming, -926365441);
	TextDrawSetOutline(urlFullGaming, 1);
	TextDrawSetProportional(urlFullGaming, 1);

	// wybieralka td
	Panorama[0] = TextDrawCreate(320.0, 347.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawAlignment(Panorama[0], 2);
	TextDrawBackgroundColor(Panorama[0], 0x000000FF);
	TextDrawFont(Panorama[0], 1);
	TextDrawLetterSize(Panorama[0], 0.5, 1.0);
	TextDrawColor(Panorama[0], 0xFFFFFFFF);
	TextDrawSetOutline(Panorama[0], 0);
	TextDrawSetProportional(Panorama[0], true);
	TextDrawSetShadow(Panorama[0], 1);
	TextDrawUseBox(Panorama[0], true);
	TextDrawBoxColor(Panorama[0], 0x00000070);
	TextDrawTextSize(Panorama[0], -43.0, -644.0);
	 
	Panorama[1] = TextDrawCreate(320.0, 1.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawAlignment(Panorama[1], 2);
	TextDrawBackgroundColor(Panorama[1], 0x000000FF);
	TextDrawFont(Panorama[1], 1);
	TextDrawLetterSize(Panorama[1], 0.5, 1.0);
	TextDrawColor(Panorama[1], 0xFFFFFFFF);
	TextDrawSetOutline(Panorama[1], 0);
	TextDrawSetProportional(Panorama[1], true);
	TextDrawSetShadow(Panorama[1], 1);
	TextDrawUseBox(Panorama[1], true);
	TextDrawBoxColor(Panorama[1], 0x00000070);
	TextDrawTextSize(Panorama[1], -43.0, -644.0);
	
	/*Panorama[1] = TextDrawCreate(320.0, 347.0, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawAlignment(Panorama[1], 2);
	TextDrawBackgroundColor(Panorama[1], 255);
	TextDrawFont(Panorama[1], 1);
	TextDrawLetterSize(Panorama[1], 0.500000, 1.000000);
	TextDrawColor(Panorama[1], -1);
	TextDrawSetOutline(Panorama[1], 0);
	TextDrawSetProportional(Panorama[1], 1);
	TextDrawSetShadow(Panorama[1], 1);
	TextDrawUseBox(Panorama[1], 1);
	TextDrawBoxColor(Panorama[1], 85);
	TextDrawTextSize(Panorama[1], 0.000000, -644.000000);*/


	TextDrawLogoGra1 = TextDrawCreate(50.000000, 375.000000, "FullGaming");
	TextDrawBackgroundColor(TextDrawLogoGra1, 50);
	TextDrawFont(TextDrawLogoGra1, 0);
	TextDrawLetterSize(TextDrawLogoGra1, 0.539999, 1.700000);
	TextDrawColor(TextDrawLogoGra1, -1);
	TextDrawSetOutline(TextDrawLogoGra1, 1);
	TextDrawSetProportional(TextDrawLogoGra1, 1);

	TextDrawLogoGra2 = TextDrawCreate(92.000000, 388.000000, "~g~~h~~h~~h~Jestesmy dla Ciebie...");
	TextDrawAlignment(TextDrawLogoGra2, 2);
	TextDrawBackgroundColor(TextDrawLogoGra2, 50);
	TextDrawFont(TextDrawLogoGra2, 0);
	TextDrawLetterSize(TextDrawLogoGra2, 0.410000, 1.400000);
	TextDrawColor(TextDrawLogoGra2, -1);
	TextDrawSetOutline(TextDrawLogoGra2, 1);
	TextDrawSetProportional(TextDrawLogoGra2, 1);

	TextDrawLogoGra3 = TextDrawCreate(605.000000, 439.000000, WERSJA_TD);
	TextDrawAlignment(TextDrawLogoGra3, 2);
	TextDrawBackgroundColor(TextDrawLogoGra3, 50);
	TextDrawFont(TextDrawLogoGra3, 2);
	TextDrawLetterSize(TextDrawLogoGra3, 0.260000, 0.799999);
	TextDrawColor(TextDrawLogoGra3, -1);
	TextDrawSetOutline(TextDrawLogoGra3, 0);
	TextDrawSetProportional(TextDrawLogoGra3, 1);
	TextDrawSetShadow(TextDrawLogoGra3, 1);

	// koniec - wybieralka td

	PM1 = TextDrawCreate(340.000000, 320.000000, "~y~~h~Nowa wiadomosc prywatna!");
	TextDrawAlignment(PM1, 2);
	TextDrawBackgroundColor(PM1, 32);
	TextDrawFont(PM1, 2);
	TextDrawLetterSize(PM1, 0.280000, 1.200000);
	TextDrawColor(PM1, -1);
	TextDrawSetOutline(PM1, 1);
	TextDrawSetProportional(PM1, 1);
	
	VannBox = TextDrawCreate(7.000, 163.000, "TEST");
    TextDrawFont(VannBox, 4);
    TextDrawTextSize(VannBox, 164.500, 58.000);
    TextDrawColor(VannBox, 51);
	tdVipAnn[0] = TextDrawCreate(24.000000, 170.000000, "        Ogloszenie");
	TextDrawAlignment(tdVipAnn[0], 0);
	TextDrawBackgroundColor(tdVipAnn[0], 0x00000033);
	TextDrawFont(tdVipAnn[0], 1);
	TextDrawLetterSize(tdVipAnn[0], 0.299999, 1.200000);
	TextDrawColor(tdVipAnn[0], 0x0080C0FF);
	TextDrawSetOutline(tdVipAnn[0], 1);
	TextDrawSetProportional(tdVipAnn[0], 1);
	TextDrawSetShadow(tdVipAnn[0], 1);

	tdVipAnn[1] = TextDrawCreate(21.000000, 177.000000, "~n~~y~Gracz ~r~(12)~h~~h~: ~w~text");
	TextDrawUseBox(tdVipAnn[1], 0);
	TextDrawBoxColor(tdVipAnn[1], 0x00000099);
	TextDrawTextSize(tdVipAnn[1], 166.000000, 0.000000);
	TextDrawAlignment(tdVipAnn[1], 0);
	TextDrawBackgroundColor(tdVipAnn[1], 0x000000ff);
	TextDrawFont(tdVipAnn[1], 1);
	TextDrawLetterSize(tdVipAnn[1], 0.199999, 0.899999);
	TextDrawColor(tdVipAnn[1], 0xffffffff);
	TextDrawSetOutline(tdVipAnn[1], 1);
	TextDrawSetShadow(tdVipAnn[1], 1);
	TextDrawSetProportional(tdVipAnn[1], 1);

	AnnFade = TextDrawCreate(POS_X, POS_Y - H_OFF, "_");
	TextDrawColor(AnnFade, ANN_COLOR);
	TextDrawBackgroundColor(AnnFade, BACK_COLOR);
	TextDrawFont(AnnFade, 1);
	TextDrawTextSize(AnnFade, 300, 300);
	TextDrawLetterSize(AnnFade, 0.36*TXT_SIZE, 1.8*TXT_SIZE);
	TextDrawSetProportional(AnnFade, 1);
	TextDrawAlignment(AnnFade, 2);
    TextDrawSetOutline(AnnFade, 1);
	
	Czas = TextDrawCreate(548.000000, 22.000000, "_");
	TextDrawBackgroundColor(Czas, 51);
	TextDrawFont(Czas, 3);
	TextDrawLetterSize(Czas, 0.559998, 1.700000);
	TextDrawColor(Czas, -1);
	TextDrawSetOutline(Czas, 1);
	TextDrawSetProportional(Czas, 0);
	
	return 1;
}

Visual3DText() {
	/*
		usunieto #2.9.0.900
	for( new o; o != sizeof fishR_pos; o ++ )
	{
		Create3DTextLabel("£owisko\nWciœnij spacjê", 0xe53e00FF,fishR_pos[ o ][ 0 ], fishR_pos[ o ][ 1 ], fishR_pos[ o ][ 2 ], 30.0, 0);
	}*/
	
	Create3DTextLabel("Restauracja",0xe53e00FF, -179.7175,1087.4827,19.7422,20.0,0);
	Create3DTextLabel("Bar",0xe53e00FF, 681.6534,-473.3463,16.5363,20.0,0);
	Create3DTextLabel("Sklep",0xe53e00FF, 661.3630,-573.4383,16.3359,20.0,0);
	Create3DTextLabel("Burdelik",0xe53e00FF, 2014.7905,1106.9966,10.8203,20.0,0);
    Create3DTextLabel("Schody",0xe53e00FF, 1939.4501,2381.9612,10.8203,20.0,0);
	
	Create3DTextLabel("Loteria dla VIP'ow",0xe53e00FF, -2152.5469,-434.6609,35.3359,40.0,0);
    Create3DTextLabel("Loteria",0xe53e00FF, -2147.4644,-424.3189,35.3359,40.0,0);

	Create3DTextLabel("Turbo",0xe53e00FF, -804.5335,2307.9099,143.4184,70.0,0);
    Create3DTextLabel("Turbo",0xe53e00FF, 2461.6086,-2592.9619,13.6756,70.0,0);

	Create3DTextLabel("Wyrzutnia",0xFFFFFFFF, 2461.8247,-2633.3154,17.7449,70.0,0);

	Create3DTextLabel("{24FF0A}Rakieta",0x000000FF, 53.2031,1559.4495,12.8125,35.0,0);
	Create3DTextLabel("{24FF0A}Do skoku wymagane {FF0000}110km/h",0x000000FF, 2559.4966,-2959.7524,201.0000,35.0,0);
	Create3DTextLabel("{24FF0A}Do skoku wymagane {FF0000}110km/h",0x000000FF, 2549.5051,-2960.1570,201.0000,35.0,0);
    Create3DTextLabel("{24FF0A}Do skoku wymagane {FF0000}110km/h",0x000000FF, 2539.2317,-2960.7332,201.0000,35.0,0);
    Create3DTextLabel("{24FF0A}Do skoku wymagane {FF0000}110km/h",0x000000FF, 2529.2988,-2961.2881,201.0000,35.0,0);

    Create3DTextLabel("Kasa Lotniskowa",0xe53e00FF, -1543.9745,-441.2479,6.0000,40.0,0);

	Create3DTextLabel("{BEBEBE}Przebywaj¹c w tym miejscu dostajesz pieni¹dze.",0x0, 2000.3132,1538.6012,13.5859,20.0,0);
    Create3DTextLabel("Bocianie Gniazdo",0xe53e00FF, 2000.6077,1548.0173,13.5859,100.0,0);

    Create3DTextLabel("Gang Niebieskich",0xe53e00FF, -2131.4045,-221.6496,35.3203,100.0,0);

    Create3DTextLabel("Gang Niebieskich",0xe53e00FF, 2804.9958,-1177.9910,25.4695,100.0,0);
    Create3DTextLabel("Gang Maliny",0xe53e00FF, 2165.8647,-1675.8043,15.0859,100.0,0);

//	Create3DTextLabel("Strefa Snajperska",0xe53e00FF, 2088.2832,1507.0862,10.8203,100.0,0);
    Create3DTextLabel("Centrum Dowodzenia",0xe53e00FF, 27.1061,1824.8994,17.6406,100.0,0);
    Create3DTextLabel("{9955DE}Wst¹p do wojska",0x0, 17.9362,1865.9121,19.9329,100.0,0);
	Create3DTextLabel("Grove Street",0xe53e00FF, 2502.0198,-1686.8647,13.5174,100.0,0);
	Create3DTextLabel("Remiza",0xe53e00FF, -2026.9386,67.1318,28.6916,100.0,0);
    Create3DTextLabel("Plac Treningowy",0xe53e00FF, 30.7894,1791.0179,17.6406,100.0,0);
 /*   Create3DTextLabel("Brama",0xe53e00FF, 95.0809,1924.8264,18.0993,100.0,0);
    Create3DTextLabel("Brama",0xe53e00FF, 98.5427,1917.1901,18.2160,100.0,0);
    Create3DTextLabel("Brama",0xe53e00FF, 1591.8716,-1639.7703,13.2770,100.0,0);
    Create3DTextLabel("Brama",0xe53e00FF, 1594.3318,-1633.8633,13.5123,100.0,0);
	Create3DTextLabel("Winda",0xe53e00FF, -2662.2371,1587.1407,64.0699,100.0,0);
*/
    Create3DTextLabel("Aqua Park",0xe53e00FF, 2177.6094,961.0953,10.8203,100.0,0);
    Create3DTextLabel("Latarnia",0xe53e00FF, 154.2368,-1946.6213,5.3894,150.0,0);
 /*   Create3DTextLabel("Brama",0xe53e00FF, 2321.4504,981.0200,10.8203,100.0,0);
    Create3DTextLabel("Brama",0xe53e00FF, 98.5427,1917.1901,18.2160,100.0,0);
    Create3DTextLabel("Winda",0xe53e00FF, 2288.8958,1013.0519,10.8203,100.0,0);
    Create3DTextLabel("Winda",0xe53e00FF, 2290.1150,1013.3820,40.257,100.0,0);*/
    Create3DTextLabel("Gun-Automat",0xe53e00FF, 2009.5186,-25.0034,3.0000,100.0,0);

	Create3DTextLabel("Salon Samochodowy",0xe53e00FF, -1967.1989,291.7525,35.2572,100.0,0);
	
	return 1;
}