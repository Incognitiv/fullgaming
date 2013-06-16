/*										 										*
	---------------------------------------------------------------------------
				   FullGaming-AtekByte

		FullGaming-AtekByte - GameMode dla serwera SA-MP.
		Copyright (C) 2013
			Patryk "Shiny" N <Shiny@FullGaming.pl>,
			Wojciech "MSI" Pampuch <MSI@FullGaming.pl>,
			Kamil "AXV" Jarząbek <AXV@FullGaming.pl>
		
		Niniejszy program jest wolnym oprogramowaniem; możesz go 
		rozprowadzać dalej i/lub modyfikować na warunkach Powszechnej
		Licencji Publicznej GNU, wydanej przez Fundację Wolnego
		Oprogramowania - według wersji 2-giej tej Licencji lub którejś
		z późniejszych wersji. 
		Niniejszy program rozpowszechniany jest z nadzieją, iż będzie on 
		użyteczny - jednak BEZ JAKIEJKOLWIEK GWARANCJI, nawet domyślnej 
		gwarancji PRZYDATNOŚCI HANDLOWEJ albo PRZYDATNOŚCI DO OKREŚLONYCH 
		ZASTOSOWAŃ. W celu uzyskania bliższych informacji - Powszechna 
		Licencja Publiczna GNU. 
		Z pewnością wraz z niniejszym programem otrzymałeś też egzemplarz 
		Powszechnej Licencji Publicznej GNU (GNU General Public License);
		jeśli nie - napisz do Free Software Foundation, Inc., 675 Mass Ave,
		Cambridge, MA 02139, USA.	
	---------------------------------------------------------------------------
 *									 											*/

/**
 * Includes
 */
 
#include <a_samp>
#tryinclude <a_http>
#include <sscanf2> 	// Y_Less 2.8.1
#include <mysql> 	// Strickenkid 2.1.1
#include <regex> 	// Fro1sha
#include <audio> 	// Incognito
#include <dir> 		// Terminator3
#include <streamer> // Incognito 2.6.1 
#include <dns> //

// YSI
#include <YSI\y_iterate>
#include <YSI\y_timers> 

/**
 * Scripts, resources, modules
 */

#include "scripts\header"

main();

/**
 * Callbacks
 */
 
public OnGameModeInit()
{
	print("Wczytywanie konfiguracji danych...");
	LoadConfiguration();
	print("Próba połączenia z bazą danych...");
	if(!(ConnectToMySQL())) return print("Nie można nawiązać połączenia!\nSprawdź dane konfiguracyjne."), SendRconCommand("exit"), 0;
	print("Pomyślnie połączono.");
	
	print("Konfigurowanie ustawien glownych");
	EnableStuntBonusForAll(false);
	ManualVehicleEngineAndLights();
	ShowNameTags(false);
	UsePlayerPedAnims();
	
	SetGameModeText("Blank Script");
	
	t:bServerSettings<ServerTimeFlow>;
	
	gServerData[sd_TimeMinute] 	= random(60);
	gServerData[sd_TimeHour] 	= random(24);
	
	print("Tworzenie klas graczy...");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	for(new skinid = 0; skinid <= 299; skinid++)
	{
		AddPlayerClass(skinid, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	}
	
	print("Tworzenie pojazdow...");
	LoadVehicles();
	
	print("Tworzenie elementow wizualnych...");
	LoadTextDraws();
	
	return 1;
}

public OnGameModeExit()
{
	RestartGamemode();
	return 1;
}

stock RestartGamemode()
{
	PlayerLoop(i)
	{
		SavePlayerData(i);
		ResetVariables(i);
		UnloadPlayerTextDraws(i);
	}
	
	UnloadVehicles();
	mysql_close(gServerData[sd_Mysql]);
	for(new itd; itd <= MAX_TEXT_DRAWS; itd++)
	{
		TextDrawDestroy(Text:itd);
	}
	t:bServerSettings<Restarting>;
	SendRconCommand("gmx");
}
	
public OnPlayerRequestClass(playerid, classid)
{
	
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	return 1;
}

public OnPlayerSpawn(playerid)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
