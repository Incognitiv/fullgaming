

enum game
{
	de,
	minigun,
	sniper,
	chainsawn
}
new pData[MAX_PLAYERS][game];
enum _spawns
{
	Float: XX,
	Float: YY,
	Float: ZZ,
	Float: anglee
}
new Float:ArenaSpawns[12][_spawns] = {
	{2517.3167, 2838.6799, 10.8203, 272.9753},
	{2502.2822, 2786.8135, 10.8203, 267.1298},
	{2539.9280, 2800.7002, 10.8203, 88.0866},
	{2620.5256, 2835.4883, 10.8203, 179.2784},
	{2591.4297, 2809.1672, 10.8203, 86.9422},
	{2545.2986, 2808.4534, 10.8203, 358.5623},
	{2610.9585, 2800.3762, 10.8203, 263.3692},
	{2660.3516, 2722.0112, 10.8203, 359.7800},
	{2601.1892, 2756.2429, 23.8222, 267.2904},
	{2618.3406, 2768.0979, 23.8222, 176.2979},
	{2633.3074, 2729.2073, 23.8222, 2.3902},
	{2617.5503, 2721.7529, 36.5386, 0.4585}
};

new Float:spawns_arena_sniper[8][_spawns] ={
	{-969.4065,1033.1636,1345.0685},
	{-1131.9219,1028.9187,1345.7321},
	{-1127.9688,1092.3306,1345.7650},
	{-1101.6678,1019.4661,1342.0938},
	{-1057.9979,1070.3015,1341.3516},
	{-974.3973,1089.0225,1344.9792},
	{-972.9406,1041.4862,1352.7015},
	{-1132.9979,1078.3234,1353.4465}
};
new Float:spawns_arena_chinasawn[][_spawns] ={
	{962.9533,2164.9194,1011.0234},
	{958.7234,2154.4739,1011.0234},
	{951.2156,2172.7886,1011.0234},
	{933.3184,2173.4980,1011.0234},
	{960.6320,2097.1455,1011.0225},
	{959.1338,2125.3589,1011.0234},
	{933.5980,2139.5713,1011.0234},
	{954.5153,2158.0693,1011.0234}
};

new Float:spawns_arena_de[][_spawns] = {
	{248.16,141.66,1003.02,35.50},
	{229.43,140.94,1003.02,324.99},
	{210.52,150.67,1003.02,182.11},
	{215.64,149.96,1003.81,179.92},
	{221.00,149.62,1003.02,178.67},
	{189.44,158.16,1003.02,269.53},
	{197.90,167.98,1003.02,267.34},
	{190.11,178.76,1003.02,269.56},
	{211.15,187.56,1003.02,174.30},
	{218.43,187.13,1003.03,179.9},
	{223.43,187.97,1003.03,176.81},
	{230.52,183.70,1003.03,134.85},
	{245.75,185.59,1008.17,313.16},
	{262.82,185.93,1008.17,30.22},
	{299.58,190.53,1007.17,84.09},
	{300.52,187.28,1007.17,118.26},
	{301.09,171.03,1007.17,48.39}
};

CMD:de(playerid, params[]){
	if (GetPlayerPing (playerid) > 100) return SendClientMessage (playerid, -1, "Niestety! Twój ping nie pozwala Ci na do³¹czenie do areny.");
	
	if(pData[playerid][de] == 1)
		return SendClientMessage(playerid,0x00FF00FF,"Jesteœ ju¿ na areni Deagle!");
	if (IsPlayerInAnyVehicle(playerid)) {
		RemovePlayerFromVehicle(playerid);
		new Float:PP[3];
		GetPlayerPos(playerid,PP[0],PP[1],PP[2]);
		SetPlayerPos(playerid,PP[0],PP[1],PP[2]);
	}
	MSGFA(-1,""iFGS"Gracz %s do³¹czy³ do /de Do³¹cz i ty!",PlayerName(playerid));
	ResetPlayerWeapons(playerid);
	
	new r=random(sizeof spawns_arena_de);
	SetPlayerPos(playerid, spawns_arena_de[r][XX], spawns_arena_de[r][YY], spawns_arena_de[r][ZZ]);
	SetPlayerFacingAngle(playerid, spawns_arena_de[r][anglee]);
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid, 3);
	SetPlayerArmour(playerid, 0.0);
	SetPlayerHealth(playerid, 10.0);
	ResetPlayerWeapons(playerid);
	SetPlayerVirtualWorld(playerid, VW_ONEDE);
	GivePlayerWeapon(playerid, 24,	0xffff);
	
	pData[playerid][de] = 1;
	return 1;
}

CMD:deexit(playerid, params[]){
	if(pData[playerid][de] == 0)
		return SendClientMessage(playerid,0x00FF00FF,"Nie jesteœ na arene Deagle!");
	pData[playerid][de] = 0;
	SetPlayerRandomSpawn(playerid);
	SetPlayerVirtualWorld(playerid,0);
	SetPlayerInterior(playerid,0);
	SetPlayerHealth(playerid, float(100));
	return 1;
}

stock ArenaDe(playerid) {
	if (GetPlayerPing (playerid) > 100) {
		SendClientMessage (playerid, -1, "Niestety! Twój ping nie pozwala Ci na do³¹czenie do areny DE.");
		SpawnPlayer (playerid);
		return 0;
	}
	return 1;
}

CMD:minigun(playerid, params[])
{
	if(pData[playerid][minigun] == 1)
		return SendClientMessage(playerid,0x00FF00FF,"Jesteœ ju¿ na arenie Minigun!");
	if (IsPlayerInAnyVehicle(playerid)) {
		RemovePlayerFromVehicle(playerid);
		new Float:PP[3];
		GetPlayerPos(playerid,PP[0],PP[1],PP[2]);
		SetPlayerPos(playerid,PP[0],PP[1],PP[2]);
	}
	MSGFA(-1,""iFGS"Gracz %s do³¹czy³ do /minigun Do³¹cz i ty!",PlayerName(playerid));
	ResetPlayerWeapons(playerid);
	ArenaMinigun(playerid);
	pData[playerid][minigun] = 1;
	return 1;
}

CMD:minigunexit(playerid, params[]){
	if(pData[playerid][minigun] == 0)
		return SendClientMessage(playerid,0x00FF00FF,"Nie jesteœ na arene Minigun!");
	pData[playerid][minigun] = 0;
	SetPlayerRandomSpawn(playerid);
	SetPlayerVirtualWorld(playerid,0);
	SetPlayerInterior(playerid,0);
	SetPlayerHealth(playerid,100.00);
	return 1;
}
stock ArenaMinigun(playerid)
{

	ResetPlayerWeapons(playerid);
	new RandSpawn = random(sizeof(ArenaSpawns));
	SetPlayerPos(playerid, ArenaSpawns[RandSpawn][XX], ArenaSpawns[RandSpawn][YY], ArenaSpawns[RandSpawn][ZZ]);
	SetPlayerFacingAngle(playerid, ArenaSpawns[RandSpawn][ZZ]);
	SetCameraBehindPlayer(playerid);
	SetPlayerColor(playerid,COLOR_INVISIBLE);
	SetPlayerInterior(playerid,0);
	SetPlayerVirtualWorld(playerid,VW_MINIGUN);
	GivePlayerWeapon(playerid,38,900);
	SetPlayerArmour(playerid,0.0);
	SetPlayerHealth(playerid,100.0);
}

CMD:sniper(playerid,params[])
{
	if(pData[playerid][sniper] == 1)
		return SendClientMessage(playerid,0x00FF00FF,"Jesteœ ju¿ na arenie sniper!");
	if (IsPlayerInAnyVehicle(playerid)) {
		RemovePlayerFromVehicle(playerid);
		new Float:PP[3];
		GetPlayerPos(playerid,PP[0],PP[1],PP[2]);
		SetPlayerPos(playerid,PP[0],PP[1],PP[2]);
	}
	MSGFA(-1,""iFGS"Gracz %s do³¹czy³ do /sniper Do³¹cz i ty!",PlayerName(playerid));
	ResetPlayerWeapons(playerid);
	ArenaSniper(playerid);
	pData[playerid][sniper] = 1;
	return 1;
}

CMD:sniperexit(playerid, params[])
{
	if(pData[playerid][sniper] == 0)
		return SendClientMessage(playerid,0x00FF00FF,"Nie jesteœ na arene sniper!");
	pData[playerid][sniper] = 0;
	SetPlayerRandomSpawn(playerid);
	SetPlayerVirtualWorld(playerid,0);
	SetPlayerInterior(playerid,0);
	SetPlayerHealth(playerid,100.00);
	return 1;
}

stock ArenaSniper(playerid)
{
	new r=random(sizeof spawns_arena_sniper);
	SetPlayerPos(playerid, spawns_arena_sniper[r][XX], spawns_arena_sniper[r][YY], spawns_arena_sniper[r][ZZ]);
	SetPlayerFacingAngle(playerid, spawns_arena_sniper[r][anglee]);
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid, 10);
	SetPlayerArmour(playerid,0.0);
	SetPlayerHealth(playerid,20.0);
	ResetPlayerWeapons(playerid);
	SetPlayerVirtualWorld(playerid,VW_SNIPER);
	GivePlayerWeapon(playerid, 34,900);
	SetPlayerColor(playerid,COLOR_INVISIBLE);
}

CMD:chainsaw(playerid,params[])
{
	if(pData[playerid][chainsawn] == 1)
		return SendClientMessage(playerid,0x00FF00FF,"Jesteœ ju¿ na arenie chainsaw!");
	if (IsPlayerInAnyVehicle(playerid)) {
		RemovePlayerFromVehicle(playerid);
		new Float:PP[3];
		GetPlayerPos(playerid,PP[0],PP[1],PP[2]);
		SetPlayerPos(playerid,PP[0],PP[1],PP[2]);
	}
	MSGFA(-1,""iFGS"Gracz %s do³¹czy³ do /chainsaw Do³¹cz i ty!",PlayerName(playerid));
	ResetPlayerWeapons(playerid);
	ArenaChainsawn(playerid);
	pData[playerid][chainsawn] = 1;
	return 1;
}

CMD:chainsawexit(playerid, params[])
{
	if(pData[playerid][chainsawn] == 0)
		return SendClientMessage(playerid,0x00FF00FF,"Nie jesteœ na arene Chainsaw!");
	pData[playerid][chainsawn] = 0;
	SetPlayerRandomSpawn(playerid);
	SetPlayerVirtualWorld(playerid,0);
	SetPlayerInterior(playerid,0);
	SetPlayerHealth(playerid,100.00);
	return 1;
}

stock ArenaChainsawn(playerid)
{
	new r=random(sizeof spawns_arena_chinasawn);
	SetPlayerPos(playerid, spawns_arena_chinasawn[r][XX], spawns_arena_chinasawn[r][YY], spawns_arena_chinasawn[r][ZZ]);
	SetPlayerFacingAngle(playerid, spawns_arena_chinasawn[r][anglee]);
	SetCameraBehindPlayer(playerid);
	SetPlayerInterior(playerid, 1);
	SetPlayerArmour(playerid,0.0);
	SetPlayerHealth(playerid,100.0);
	ResetPlayerWeapons(playerid);
	SetPlayerVirtualWorld(playerid,VW_CHAINSAWN);
	GivePlayerWeapon(playerid, 9,1);
}