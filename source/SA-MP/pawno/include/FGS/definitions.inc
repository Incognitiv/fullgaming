#define MAX_GRACZY 101 //Gracze
#undef MAX_PLAYERS
#define MAX_PLAYERS MAX_GRACZY
#define MAX_GANGS 20 //Limit gangów
#define MAX_GANG_MEMBERS 15 //Limit graczy w jednym gangu
#define MAX_HOUSES 150 //Limit prywatnych domów (nie zaleca siê zmieniania chyba ¿e wiesz co robisz)
#define MAX_RACE_CHECK 50 //Limit checkpointów podczas wyœcigu (nie zaleca siê zmieniania chyba ¿e wiesz co robisz)

#define CP_BANK 	0
#define CP_PIRATE 	1
#define CP_AMMU     2
#define CP_WOJSKO 3
#define CP_WIELKABAZA 4
#define CP_BAZATDC 5
#define CP_FORTECA 6

#define CP_DRAGON   6
#define CP_SEXSHOP  7
#define CP_BAR      8
#define CP_CALIGULA 9
#define CP_ZIP      10
#define CP_BINCO    11
#define CP_TATOO    12
#define CP_BOTIQUE  13
#define CP_STARFISH 14
#define CP_DYSKOTEKA 15
#define CP_BUDOWA 16
#define CP_HOTELROCK 17
#define CP_PARKING 18
#define CP_LVLOT 19
#define CP_BAZAWOJSKOWA 20
#define CP_STARELOTNISKO 21

#define P_DRAGON    0
#define P_SEXSHOP   1
#define P_BAR       2
#define P_CALIGULA  3
#define P_ZIP       4
#define P_BINCO     5
#define P_TATOO     6
#define P_BOTIQUE   7
#define P_STARFISH  8
#define P_DYSKOTEKA  9
#define P_BUDOWA  10
#define P_HOTELROCK  11
#define P_PARKING  12
#define P_LVLOT  13
#define P_BAZAWOJSKOWA  14
#define P_STARELOTNISKO  15

#define AUTO_REOPEN_DIALOG
#define MAX_DESC 32
#define LOTTO_PRICE 1000
#define PROP_INDEX 7
#define TEXT_NULL _
#define MAX_WEAPONS 7
#define MAX_PROPERTIES	16
#define ANTY_SPAWN_KILL_TIME 4
#define KEY_HORN 2

#define UpperToLower(%1) for ( new ToLowerChar; ToLowerChar < strlen( %1 ); ToLowerChar ++ ) if ( %1[ ToLowerChar ]> 64 && %1[ ToLowerChar ] < 91 ) %1[ ToLowerChar ] += 32
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define POS_X 	640.0/2
#define POS_Y 	480.0/2
#define H_OFF 	115
#define SUB 	{
#define END 	}

#define ANN_COLOR 	0xFFFFFFFF
#define BACK_COLOR 	0x00000040
#define ALPHA_C 	(ANN_COLOR&0xFF)
#define ALPHA_B 	(BACK_COLOR&0xFF)
#define COLOR_STEP  ALPHA_C/0x12
#define BACK_STEP  ALPHA_B/0x12
#define DELAY 50
#define TXT_SIZE 1.2

#define LABIRYNT_MAPICON 552
#define LEVEL_UP_TIME 10
#define WEAPON_AMMO 60

#define VIP_ANN_TIME 4000

#define C_INFO "{e53e44}" //Infos colour

#define weaponmodels 4670

#define DIALOG_RADIO 300
#define DIALOG_WINDALV 301
#define DIALOG_UNKNOWN_COMMAND 302
#define DIALOG_WALKA 303
#define DIALOG_UNKNOWN_COMMAND2 304
#define DIALOG_PLAYER 305
#define DIALOG_EV 306
#define DIALOG_CHEATS 307
#define DIALOG_REPORT 308
#define DIALOG_RCON 309
#define DIALOG_HUD 310
#define DIALOG_VANN 311
#define DIALOG_ATRAKCJE 312
#define DIALOG_LOTERIA 313
#define DIALOG_LOTERIA_VIP 314
#define DIALOG_LOWISKO 315
#define DIALOG_TP 316
#define VEHICLE_CONTROL_DIALOG 317
#define DIALOG_FIVE_ONE 318
#define DIALOG_FIVE_TWO 319
#define DIALOG_VIP 320
#define DIALOG_VIP2 321
#define DIALOG_NONE 322
#define DIALOG_ACMD 323
#define DIALOG_ACMD2 324
#define DIALOG_MOD 325
#define DIALOG_MOD2 326
#define DIALOG_HOUSE1 327
#define DIALOG_HOUSE2 328
#define DIALOG_HOUSE3 329
#define DIALOG_HOUSE4 330
#define MGANG 666
#define NGANG 667
#define DIALOG_VGRANATY 1001
#define DIALOG_KUPNO 1002
#define DIALOG_MOD_KUPNO 1003
#define DIALOG_MOD_KUPNO2 1004
#define DIALOG_ADMIN_KUPNO 1005
#define DIALOG_MODER 1006
#define DIALOG_ADMIN_KUPNO2 1007
#define DIALOG_ADMINER 1008
#define DIALOG_VEHICLE_HAVE 18842
#define DIALOG_VEHICLE_NOT_HAVE 1534
#define DIALOG_VEHICLES 1535
#define DIALOG_DESCRIPTION 1537
#define DIALOG_MPLAYER 15312
#define DIALOG_MPLAYER2 15313
#define DIALOG_RADIO2 568
#define DIALOG_NUTA 502
#define DIALOG_NUTA1 503
#define DIALOG_NEWNICK 504
#define DIALOG_EXITARENA 505
#define GUI_BANK 52
#define GUI_BANK_WPLAC 53
#define GUI_BANK_WYPLAC 54
#define GUI_BANK_STAN 55
#define GUI_BANK_PRZELEW 56
#define GUI_BANK_PRZELEW2 57
#define GUI_EXP_PRZELEW 58
#define GUI_EXP_PRZELEW2 59
#define GUI_KASA_PRZELEW 60
#define GUI_KASA_PRZELEW2 61
#define DIALOG_ZALOZ 62