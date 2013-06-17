#define DIALOG_PORTFEL_SHOP_CAPTCHA	8880
#define DIALOG_PORTFEL_SHOP_LIST 8881
#define DIALOG_PORTFEL_SHOP_CODE 8882
#define DIALOG_PORTFEL_CMD 8883
#define DIALOG_PORTFEL_STAN 8884
#define DIALOG_PORTFEL_REGULAMIN 8885
#define DIALOG_PORTFEL_KUPNO 8886
#define DIALOG_PORTFEL_VIP 8887
#define DIALOG_PORTFEL_SCORE 8888
#define DIALOG_PORTFEL_WYBOR 8889
#define DIALOG_PORTFEL_PRZESLIJ 8890
#define DIALOG_PORTFEL_PRZELEW 8891
#define DIALOG_PORTFEL_PRZELEW_TYPE1 8892 // 8893 zajete
#define DIALOG_PORTFEL_PRZELEW_TYPE2 8894 // 8895 zajete
#define DIALOG_PORTFEL_PRZELEW_SELECT 8896

#define getPlayerOnlineTime(%0)   	(gettime() - gPlayerTime[(%0)]) 
#define getPlayerOnlineHours(%1) 	(getPlayerOnlineTime((%1))/3600)
#define getPlayerOnlineMinutes(%1) 	(getPlayerOnlineTime((%1))/60%60)

new CarList[212][20] = {
{"Landstalker"},{"Bravura"},{"Buffalo"},{"Linerunner"},{"Perrenial"},{"Sentinel"},{"Dumper"},{"Fire Truck"},{"Trashmaster"},
{"Stretch"},{"Manana"},{"Infernus"},{"Voodoo"},{"Pony"},{"Mule"},{"Cheetah"},{"Ambulance"},{"Leviathan"},{"Moonbeam"},{"Esperanto"},
{"Taxi"},{"Washington"},{"Bobcat"},{"Mr Whoopee"},{"BF Injection"},{"Hunter"},{"Premier"},{"Enforcer"},{"Securicar"},{"Banshee"},
{"Predator"},{"Bus"},{"Rhino"},{"Barracks"},{"Hotknife"},{"Trailer 1"},{"Previon"},{"Coach"},{"Cabbie"},{"Stallion"},{"Rumpo"},{"RC Bandit"},
{"Romero"},{"Packer"},{"Monster"},{"Admiral"},{"Squalo"},{"Seaspar"},{"Pizzaboy"},{"Tram"},{"Trailer 2"},{"Turismo"},{"Speeder"},{"Reefer"},
{"Tropic"},{"Flatbed"},{"Yankee"},{"Caddy"},{"Solair"},{"Berkley's RC Van"},{"Skimmer"},{"PCJ-600"},{"Faggio"},{"Freeway"},{"RC Baron"},{"RC Raider"},
{"Glendale"},{"Oceanic"},{"Sanchez"},{"Sparroww"},{"Patriot"},{"Quad"},{"Coastguard"},{"Dinghy"},{"Hermes"},{"Sabre"},{"Rustler"},{"ZR-350"},
{"Walton"},{"Regina"},{"Comet"},{"BMX"},{"Burrito"},{"Camper"},{"Marquis"},{"Baggage"},{"Dozer"},{"Maverick"},{"VCNMaverick"},{"Rancher"},{"FBI Rancher"},
{"Virgo"},{"Greenwood"},{"Jetmax"},{"Hotring"},{"Sandking"},{"Blista Compact"},{"Police Maverick"},{"Boxville"},{"Benson"},{"Mesa"},{"RC Goblin"},
{"Hotring A"},{"Hotring B"},{"Bloodring Banger"},{"Rancher"},{"Super GT"},{"Elegant"},{"Journey"},{"Bike"},{"Mountain Bike"},{"Beagle"},{"Cropdust"},
{"Stunt"},{"Tanker"},{"Roadtrain"},{"Nebula"},{"Majestic"},{"Buccaneer"},{"Shamal"},{"Hydra"},{"FCR-900"},{"NRG-500"},{"HPV1000"},{"Cement Truck"},
{"Tow Truck"},{"Fortune"},{"Cadrona"},{"FBI Truck"},{"Willard"},{"Forklift"},{"Tractor"},{"Combine"},{"Feltzer"},{"Remington"},{"Slamvan"},{"Blade"},
{"Freight"},{"Streak"},{"Vortex"},{"Vincent"},{"Bullet"},{"Clover"},{"Sadler"},{"Firetruck LA"},{"Hustler"},{"Intruder"},{"Primo"},{"Cargobob"},{"Tampa"},
{"Sunrise"},{"Merit"},{"Utility"},{"Nevada"},{"Yosemite"},{"Windsor"},{"Monster A"},{"Monster B"},{"Uranus"},{"Jester"},{"Sultan"},{"Stratum"},{"Elegy"},
{"Raindance"},{"RC Tiger"},{"Flash"},{"Tahoma"},{"Savanna"},{"Bandito"},{"Freight Flat"},{"Streak Carriage"},{"Kart"},{"Mower"},{"Duneride"},{"Sweeper"},
{"Broadway"},{"Tornado"},{"AT-400"},{"DFT-30"},{"Huntley"},{"Stafford"},{"BF-400"},{"Newsvan"},{"Tug"},{"Trailer 3"},{"Emperor"},{"Wayfarer"},{"Euros"},{"Hotdog"},
{"Club"},{"Freight Carriage"},{"Trailer 3"},{"Andromada"},{"Dodo"},{"RC Cam"},{"Launch"},{"LSPD"},{"SFPD"},{"LVPD"},{"Police Ranger"},{"Picador"},{"SWAT Van"},
{"Alpha"},{"Phoenix"},{"Glendale"},{"Sadler"},{"Luggage Trailer A"},{"Luggage Trailer B"},{"Stair Trailer"},{"Boxville"},{"Farm Plow"},{"Utility Trailer"}
};

//new Text3D:nickname_labels[MAX_GRACZY];
new bool:Registered[MAX_PLAYERS];
new bool:logged[MAX_PLAYERS];
new Hudded[MAX_PLAYERS];
new Locked[MAX_PLAYERS], IsLocked[MAX_VEHICLES];
new engine, lights, alarm, doors, bonnet, boot, objective;
new InAir[MAX_PLAYERS];
new PickupID[3];
new DomTimer[MAX_GRACZY];
new bool:Freeze[MAX_GRACZY];
new SoloPlayer[2] = {-1,-1};
new SoloWyzywa[MAX_GRACZY];
new bool:SoloON;
new SoloCD = 3;
new SoloBron[MAX_GRACZY];
new bool:SavePos = true;
new WorldChange;
new RuraCD[MAX_GRACZY];
new MaRure[MAX_GRACZY];
new AnnTimer[MAX_GRACZY];
new BadPasCount[MAX_GRACZY];
new bool:ChceAnn[MAX_GRACZY];
new bool:ChatON = true;
new bool:MozeMowic[MAX_GRACZY];
new bool:AFKMeter[MAX_GRACZY];
new bool:AFK[MAX_GRACZY];
new RespektPremia[MAX_GRACZY];
new Crate[MAX_GRACZY][4];
new TPcar[MAX_GRACZY];

new Count2 = 0;
new CountDowning = 0;
new bool:VipMozeLogowac[MAX_GRACZY];
new bron1,bron2,bron3,bron4,bron5,bron6,bron7,bron8,bron9,bron10,bron11,bron12,bron13;
new ammorsp,ammo2,ammo3,ammo4,ammo5,ammo6,ammo7,ammo8,ammo9,ammo10,ammo11,ammo12,ammo13;
new Float:healthrsp;
new Float:armourrsp;
new inter;
new RspWorld;
new bool:Floater[MAX_GRACZY];
new bool:FloatDeath[MAX_GRACZY];
new bool:Bombs = true;
new bool:Wybieralka[MAX_GRACZY];
new FortecaBrama;
new lift1;
new lift2;
new lift3;

//new LabiryntPickup;
new bool:CanNitro[MAX_GRACZY];
new bool:KillBug[MAX_GRACZY];
new SOSkill[MAX_GRACZY];
new UziSkill[MAX_GRACZY];

new bool:GSTag[MAX_GRACZY];
new Top10Text[6][512];
new bool:Top10Block[6];
new bool:AutoBlock[MAX_GRACZY];
new bool:VpozostaloBlock[MAX_GRACZY];
new bool:MpozostaloBlock[MAX_GRACZY];
new DragTime[MAX_GRACZY];
new DragZone;

new PMTimer[MAX_GRACZY];
enum pGangInfo
{
	gID,
	gRank,
	gDialog,
	bool:gInvites[MAX_GANGS],
};

enum gGangInfo
{
	Float:gSpawnX,
	Float:gSpawnY,
	Float:gSpawnZ,
	gLeader,
	gName[21],
	gColor,
};
new pmid1;
new pmid2;
new PlayerGangInfo[MAX_GRACZY][pGangInfo];
new GangInfo[MAX_GANGS][gGangInfo];
new neon[MAX_VEHICLES][2];
new Float:pLocX[MAX_PLAYERS],Float:pLocY[MAX_PLAYERS],Float:pLocZ[MAX_PLAYERS];
new Float:AfkPosX[MAX_PLAYERS],Float:AfkPosY[MAX_PLAYERS],Float:AfkPosZ[MAX_PLAYERS];
new Float:SpecPosX[MAX_PLAYERS],Float:SpecPosY[MAX_PLAYERS],Float:SpecPosZ[MAX_PLAYERS],SpecInt[MAX_PLAYERS],SpecVW[MAX_PLAYERS];
new bool:SpecOff[MAX_PLAYERS];
new gSpectateID[MAX_PLAYERS];
new gSpectateType[MAX_PLAYERS];
new Float:UstawkaX[2],Float:UstawkaY[2],Float:UstawkaZ[2],UstawkaInt;
new bool:UstawkaCount;
new bool:UstawkaON;
new registerr;
new maxusers;
new users;
new joins;
new kicks;
new bans;
new globkills;
new globdeaths;
new globsuicides;
new rekordgraczy;
new joininfo;
new joininfoadmin = 1;
new podgladPM = 1;
new kills[MAX_PLAYERS];
new deaths[MAX_PLAYERS];
new suicides[MAX_PLAYERS];
new wykorzystanyrespekt[MAX_PLAYERS];
new Respekt[MAX_PLAYERS];
new Money[MAX_PLAYERS];
new SoloScore[MAX_PLAYERS];
new Pass[MAX_PLAYERS][21];
new LoginNick[MAX_PLAYERS][MAX_PLAYER_NAME];
new ServerTag[11];
new ServerUrl[36];
new LiczbaTak;
new LiczbaNie;
new VotePozostalo;
new OnlAD;
new OnlMOD;
new OnlVIP;
new Abronie[4]={35,36,37,38};
new VipAnnTime;
new BagPickup;
new BagCash;
new bool:BagEnabled;

/**
 * Test reakcji
 */

new gReactionLetters[61] = {'q','w','e','r','t','y','u','i','o','p','a','s','d','f','g','h','j','k','l','z','x','c',
	'v','b','n','m','Q','W','E','R','T','Y','U','I','O','P','A','S','D','F','G','J','K','L','Z','X','C','V','B','N','M','1','2','3','4','5','6','7','8','9','0'};
	
new TestReaction;
new TimerReaction;
new gStringReaction[10];
new WygraneKod[MAX_GRACZY];
// end reaction test

new bool:playermuted[MAX_GRACZY];
new PodkowaPickup;
new PodkowaCash;
new bool:PodkowaEnabled;
new MuteTimer[MAX_GRACZY];
new JailTimer[MAX_GRACZY];
new bool:Wiezien[MAX_GRACZY];
new CountArenaKills[MAX_GRACZY];

new bool:CDText;
new bool:JailText[MAX_GRACZY];
new MaxPojazdow;
new DragTimer;
new Dragliczba;
new bool:DragON;
new bool:Drager[MAX_GRACZY];
new DragMiejsce;
new bool:Drager1[MAX_GRACZY];
new bool:Drager2[MAX_GRACZY];
new bool:Drager3[MAX_GRACZY];
new bool:Drager4[MAX_GRACZY];
new DragCheck[MAX_GRACZY];
new DragTick[MAX_GRACZY];
new gPlayerTime[MAX_GRACZY];
new TimePlay[MAX_GRACZY];
new Pinger[MAX_GRACZY];
new SpamStrings[MAX_GRACZY];
new CMDspam[MAX_GRACZY];
new Nrgs[MAX_GRACZY];
new bool:Immunitet[MAX_GRACZY];
new IsInShml[MAX_GRACZY];
new bool:FirstSpawn[MAX_GRACZY];
new Nrg500[MAX_GRACZY];
new bool:SiemaBlock[MAX_GRACZY];
new bool:HitmanBlock[MAX_GRACZY];
new szlaban;
new bramapd;
new rakieta;
new TDCWinda;
new TDCKlatka;
new TDCPick;
new WindaWB;
new bool:Cenzor[MAX_GRACZY];
new bool:MozeDetonowac[MAX_GRACZY];
new bool:Bomber[MAX_GRACZY];
new Float:BombX[MAX_GRACZY],Float:BombY[MAX_GRACZY],Float:BombZ[MAX_GRACZY];
new Bombus[MAX_GRACZY];
new Detonacjaa[MAX_GRACZY];
new Hours;
new Minutes;
new bool:gPlayerUsingAnim[MAX_GRACZY];
new bank[MAX_GRACZY];
new bounty[MAX_GRACZY];
new Float:LocX = 0.0;
new Float:LocY = 0.0;
new Float:LocZ = 0.0;
new killsinarow[MAX_GRACZY];
new IDHouse;
new IDVehicleHouse;
new InteriorHouse;
new RespektHouse;
new Float:VehHousePos[3];
new Float:HousePos[3];
new Float:HousePosIn[3];
new OneHouse;
new TwoHouse;
new ThriHouse;
new Float:z_rot;
new Count1 = 3;
new CountText[3][5] ={
	"~w~1",
	"~w~2",
	"~w~3"
};
new WindaLV;
new FiveOne;
new FiveTwo;
new FiveOneTwo;
new FiveTwoTwo;
new FivePickupOne;
new FivePickupTwo;
new FivePickupThree;
new FivePickupFour;

new LottoMoney;
new bool:ChcePM[MAX_GRACZY];
new Raport[10][32];
new RaportCD = -1;
new RaportID[10] = {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};
new bool:RaportBlock[MAX_GRACZY];
new bool:IdzdoBlock[MAX_GRACZY];
new bool:VannBlock[MAX_GRACZY];
new bool:Zaglosowal[MAX_PLAYERS];
new bool:VoteON;
new bool:VoteChce[MAX_PLAYERS];
enum hInfo
{
	hOwner[MAX_PLAYER_NAME],
	Text3D:hLabel,
	Float:henter_x,
	Float:henter_y,
	Float:henter_z,
	Float:hexit_x,
	Float:hexit_y,
	Float:hexit_z,
	hPick,
	hCost,
	hBudget,
	hInterior,
	hWorld,
	hCarid,
	houseid,
	bool:hOpen,
};
new HOUSES_LOOP;
new HouseInfo[MAX_HOUSES][hInfo];
new HouseID[MAX_GRACZY];
new bool:MaDom[MAX_GRACZY];
new bool:ZmieniaAuto[MAX_GRACZY];
new bool:Invisible[MAX_GRACZY];