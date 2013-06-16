/*										 										*
	---------------------------------------------------------------------------
				   FullGaming-AtekByte

Description:
	
Legal:
	Version: MPL 1.1
	
	The contents of this file are subject to the Mozilla Public License Version 
	1.1 (the "License"); you may not use this file except in compliance with 
	the License. You may obtain a copy of the License at 
	http://www.mozilla.org/MPL/
	
	Software distributed under the License is distributed on an "AS IS" basis,
	WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
	for the specific language governing rights and limitations under the
	License.
	
	The Original Code is the FullGaming-AtekByte script.
	
	The Initial Developer of the Original Code is
		Patryk "Shiny" Niedzielski <Shiny@FullGaming.pl>
		Wojciech "MSI" Pampuch <MSI@FullGaming.pl>		
		Kamil "AXV" Jarzabek <AXV@FullGaming.pl>
		
	Portions created by the Initial Developer are Copyright (C) 2013
	the Initial Developer. All Rights Reserved.
		
	Very special thanks to:
		Thiadmer - PAWN, whose limits continue to amaze me!
		Kye/Kalcor - SA:MP.
		SA:MP Team past, present and future - SA:MP.
		
Version:
	0.1
	
	---------------------------------------------------------------------------
 *									 											*/

/**
 * Includes
 */
 
#include <a_samp>
#tryinclude <a_http>
#include <sscanf> 	// Y_Less 2.8.1
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

main()
{
}

/**
 * Callbacks
 */
 
public OnGameModeInit()
{
	print("Wczytywanie konfiguracji danych...");
	LoadConfiguration();
	print("Laczenie z baza danych...");
	if(ConnectToMySQL())
	{
		print(" Polaczono z baza danych!");
	} else {
		print(" Nie mozna nawiazac polaczenia!\n Sprawdz dane konfiguracyjne!!!");
		SendRconCommand("exit");
		return 0;
	}
	
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
	for(new skinid = 1; skinid <= 298; skinid++)
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
