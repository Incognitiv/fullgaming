/**
 * Atekbyte\Header.inc
 **/

#if defined _atkbyte_header
	#endinput
#else 
	#define _atkbyte_header
#endif

native IsValidVehicle(vehicleid);

/**
 * Definitions
 **/
 
#undef MAX_PLAYERS
#define MAX_PLAYERS					(32+1)
 
#define MAX_ADMINS					(MAX_PLAYERS / 10)

#define MAX_RENDER_DISTANCE 		(300.0)
#define MAX_IP_LENGTH 				(16)
#define MAX_PASSWORD_LEN 			(18)
#define MAX_SALT_CHARS 				(8)

// functions on define
#define PlayerLoop(%0) 				foreach(new %0 : Player)

#define bitTrue(%1,%2) 				((%1)|=(%2))
#define bitFalse(%1,%2)	 			((%1)&=~(%2))

#define t:%1<%2> 					((%1)|=(%2))
#define f:%1<%2> 					((%1)&=~(%2))

#define strcpy(%0,%1)				strcat((%0[0] = '\0', %0), %1)
#define RandomBounds(%1,%2) 		(random((%2)-(%1))+(%1))
#define RandomCondition(%1)			(random(100)<(%1))

// Keys
#define KEY_RELEASED(%0)			(((newkeys&(%0))!=(%0))&&((oldkeys&(%0))==(%0)))
#define KEY_PRESSING(%0)			(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define KEY_HOLDING(%0)				((newkeys & (%0)) == (%0))
#define KEY_AIMFIRE					(132)

// Path
#define PATH_LANGUAGES 				"/AtekByte/languages/core_"

// Commands
#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)
									
#define ACMD:%1[%2](%3)				forward cmd_%1_%2(%3);\
									public cmd_%1_%2(%3)
																	
// Colors
#define YELLOW						0xffff00aa
#define RED							0xE85454AA
#define GREEN						0x33AA33AA
#define BLUE						0x33CCFFAA

#define ORANGE						0xFFAA00AA
#define GREY						0xAFAFAFAA
#define PINK						0xFFC0CBAA
#define NAVY						0x000080AA
#define GOLD						0xB8860BAA
#define LGREEN						0x00FD4DAA
#define TEAL						0x008080AA
#define BROWN						0xA52A2AAA
#define AQUA						0xF0F8FFAA

#define BLACK						0x000000AA
#define WHITE						0xFFFFFFAA

// Embedding Colours
#define C_YELLOW					"{FFFF00}"

#define C_RED						"{E85454}"
#define C_GREEN						"{33AA33}"
#define C_BLUE						"{33CCFF}"

#define C_ORANGE					"{FFAA00}"
#define C_GREY						"{AFAFAF}"
#define C_PINK						"{FFC0CB}"
#define C_NAVY						"{000080}"
#define C_GOLD						"{B8860B}"
#define C_LGREEN					"{00FD4D}"
#define C_TEAL						"{008080}"
#define C_BROWN						"{A52A2A}"
#define C_AQUA						"{F0F8FF}"

#define C_BLACK						"{000000}"
#define C_WHITE						"{FFFFFF}"


#define C_SPECIAL					"{0025AA}"

// Languages
#define MAX_LANGUAGES (2)
#define MAX_LANGUAGES_TXT (128)

#define LANGUAGE_PL (0)
#define LANGUAGE_ENG (1)

/**
 * Variables, enums
 **/

enum (<<=1)
{
	// Player status
	HasAccount = 1,
	LoggedIn,
	Spawned,
	FirstSpawn,
	
	LoopingAnimation,
	AfkCheck,
	IsAfk,
	DebugMode,
	
	Invisible,
	Frozen,
	Muted
};

enum (<<=1)
{
	// Server status
	ChatLocked = 1,
	ServerLocked,
	Restarting,
	ScheduledRestart,
	RealTime,
	ServerTimeFlow
};

enum
{
	// Dialog ids
	d_Null = 0,
	d_Login,
	d_Register
};

enum 
{
	// Virtual Worlds
	VW_DEFAULT, // 0
};
	
enum
{
	// Admin level
	ADMIN_LEVEL_NONE = 0,
	ADMIN_LEVEL_GM, // gamemaster - moderator
	ADMIN_LEVEL_1,
	ADMIN_LEVEL_2,
	ADMIN_LEVEL_3,
	ADMIN_LEVEL_4,
	
	MAX_ADMIN_LEVEL
};
	
enum e_ADMINS_DATA
{
	ad_Name[MAX_PLAYER_NAME+1],
	ad_Level
};

enum e_SERVER_DATA
{
	// Server data
	sd_TimeMinute,
	sd_TimeHour,

	// MySQL
	MySQL:sd_Mysql,
	sd_MysqlHost[32],
	sd_MysqlUser[16],
	sd_MysqlPass[24],
	sd_MysqlDB[12]
	
};

enum e_PLAYER_VECTOR
{
	// Player vector
	Float:pv_X,
	Float:pv_Y,
	Float:pv_Z,
	Float:pv_Rot,
	pv_Interior,
	pv_World
};

enum e_PLAYER_DATA
{
	// Player data
	pd_Nickname[MAX_PLAYER_NAME+1],
	pd_Password[MAX_PASSWORD_LEN],
	pd_Admin,
	pd_Skin,
	pd_Money,
	pd_Score,
	pd_IP,
	pd_TimePlayed,
	pd_TimeInVeh,
	pd_TimeOnFoot,
	pd_IncorrectPass,
	pd_Warnings,
	
	pd_TickLastDmg, 
	pd_TickStartRegenHP,
	pd_TickStartRegenAP,
	
	pd_WeaponHitTick,
	pd_DeathTick,
	
	pd_EnterVehTick,
	pd_EnterFootTick,
	
	Float:pd_Velocity,
	Float:pd_HP,
	Float:pd_AP,
	
	Text3D:pd_AfkStatus,
	Text3D:pd_Status
};

// Vars
new
	// Server
	bServerSettings,
	gServerData[e_SERVER_DATA],
	// Player
	bPlayerSettings[MAX_PLAYERS],
	gPlayerData[MAX_PLAYERS][e_PLAYER_DATA],
	// Admins
	AdminData[MAX_ADMINS][e_ADMINS_DATA],
	gTotalAdmins,
	// Languages
	gServerLang[MAX_LANGUAGES][MAX_LANGUAGES_TXT][128]
;

enum (<<=1)
{
	// Weapon type
	WEAPON_TYPE_MELEE=1, // dildo, knife, flowers, baseball, etc.
	WEAPON_TYPE_GRENADES, // grenade
	WEAPON_TYPE_SHOTGUNS, // shotguns
	WEAPON_TYPE_PISTOLS, // de, 9mm
	WEAPON_TYPE_ASSAULT, // m4, ak
	WEAPON_TYPE_RIFLES, // sniper rifle
	WEAPON_TYPE_SUBMACHINE, // submachine guns (smg, uzi, tec)
	WEAPON_TYPE_ROCKETS // rockets
};

enum e_WEAPONS_DATA
{
	// Weapon data
	wd_Type,
	wd_Name[40],
	wd_Weaponid,
	wd_Ammo,
	wd_Price
};
	
// Constants vars and arrays
stock const 
	adminRankName_PL[MAX_ADMIN_LEVEL-1][16] =
	{
		"Gracz",
		"Moderator",
		"Administator #1",
		"Administator #2",
		"Administator #3",
		"Administator #4",
	},
	adminRankName_ENG[MAX_ADMIN_LEVEL-1][16] =
	{
		"Player",
		"Game-Master",
		"Administator #1",
		"Administator #2",
		"Administator #3",
		"Administator #4",
	},
	weapons_PL[][e_WEAPONS_DATA] =
	{
		{0, "", 0, 0, 0}, // piesci
		{WEAPON_TYPE_MELEE, "Kastet", 1, 1, 20}, 
		{WEAPON_TYPE_MELEE, "Kij golfowy", 2, 1, 80},
		{WEAPON_TYPE_MELEE, "Pa³ka policyjna", 3, 1, 130},
		{WEAPON_TYPE_MELEE, "Nó¿", 4, 1, 160},
		{WEAPON_TYPE_MELEE, "Kij bejsbolowy", 5, 1, 200},
		{WEAPON_TYPE_MELEE, "£opata", 6, 1, 50},
		{WEAPON_TYPE_MELEE, "Kij bilardowy", 7, 1, 40},
		{WEAPON_TYPE_MELEE, "Katana", 8, 1, 300},
		{WEAPON_TYPE_MELEE, "Pi³a ³añcuchowa", 9, 1, 1},
		{WEAPON_TYPE_MELEE, "Podwójne dildo", 10, 1, 30},
		{WEAPON_TYPE_MELEE, "Dildo", 11, 1, 35},
		{WEAPON_TYPE_MELEE, "Wibrator", 12, 1, 40},
		{WEAPON_TYPE_MELEE, "Srebny wibrator", 13, 1, 45},
		{WEAPON_TYPE_MELEE, "Kwiaty", 14, 1, 25},
		{WEAPON_TYPE_MELEE, "Laska", 15, 1, 99},
		{WEAPON_TYPE_GRENADES, "Granat", 16, 1, 500},
		{WEAPON_TYPE_GRENADES, "Granat dymny", 17, 1, 300},
		{WEAPON_TYPE_GRENADES, "Kokjalt mo³otowa", 18, 1, 400},
		{WEAPON_TYPE_PISTOLS, "Pistolet 9mm", 22, 99, 200},
		{WEAPON_TYPE_PISTOLS, "Pistolet 9mm z t³umikiem", 23, 99, 250},
		{WEAPON_TYPE_PISTOLS, "Desert Eagle", 24, 99, 300},
		{WEAPON_TYPE_SHOTGUNS, "Shotgun", 25, 10, 350},
		{WEAPON_TYPE_SHOTGUNS, "Sawnoff Shotgun", 26, 10, 500},
		{WEAPON_TYPE_SHOTGUNS, "Combat Shotgun", 27, 10, 600},
		{WEAPON_TYPE_SUBMACHINE, "Micro SMG/UZI", 28, 50, 300},
		{WEAPON_TYPE_SUBMACHINE, "MP5", 29, 30, 300},
		{WEAPON_TYPE_ASSAULT, "AK-47", 30, 30, 800},
		{WEAPON_TYPE_ASSAULT, "M4", 31, 30, 1000},
		{WEAPON_TYPE_SUBMACHINE, "TEC-9", 32, 50, 350},
		{WEAPON_TYPE_RIFLES, "Dubeltówka", 33, 10, 1400},
		{WEAPON_TYPE_RIFLES, "Snajperka", 34, 10, 1800},
		{WEAPON_TYPE_ROCKETS, "RPG", 35, 1, 10000},
		{WEAPON_TYPE_ROCKETS, "HS RPG", 36, 1, 13000},
		{WEAPON_TYPE_ROCKETS, "Miotacz ognia", 37, 60, 2000},
		{WEAPON_TYPE_MELEE, "Spray", 41, 400, 100},
		{WEAPON_TYPE_MELEE, "Gaœnica", 42, 400, 100},
		{WEAPON_TYPE_MELEE, "Aparat", 43, 99, 80},
		{WEAPON_TYPE_MELEE, "Spadochron", 46, 1, 50}
	},
	privilagesVIP_PL[][] =
	{
		"Przywileje konta premium:\n\n",
		"\t- Darmowe tankowanie pojazdu\n",
		"\t- Darmowe naprawianie pojazdu\n",
		"\t- Wyró¿niaj¹cy ¿ó³ty nick na czacie\n",
		"\t- Mo¿liwoœæ dania sobie jetpack-a\n",
		"\t- Pieni¹dze i EP nie s¹ zabieranie przy œmierci\n",
		"\t- Mo¿liwoœæ pisania specjalnych og³oszeñ\n",
		"\t- Pisanie na prywatnym czacie VIP-ów\n",
		"\t- Cena broni w sklepie o pó³owê mniejsza\n",
		"\t- Koszt pojazdów tañszy o 25 procent\n", // 2013-06-16 21:00:14 :: MalinowyKox XD
		"\t- Dwa razy wiêksza kasa za biznes\n",
		"\t- Dwa razy wiêcej EP za atrakcje/eventy\n",
		"\t- Reszta w trakcie pisania...\n"
	},
	RadioStations[][2][64] =
	{
		{"http://url.domain", "Station Name"}
	}
;
		