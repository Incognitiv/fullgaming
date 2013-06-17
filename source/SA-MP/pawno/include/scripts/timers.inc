/**
 * Atekbyte\Timers.inc
 **/

#if defined _atkbyte_timers
	#endinput
#else 
	#define _atkbyte_timers
#endif

task GameUpdate[1000]()
{
	if(bServerSettings & ServerTimeFlow)
	{
		new 
			szClockText[6],
			szMinute[3],
			szHour[3],
			hour,
			minute,
			second
		;
		
		gettime(hour, minute, second);
		
		if(hour == 0 && minute == 0 && second < 6)
		{
			if(Iter_Count(Player) == 0)
			{
				RestartGamemode();
			} else {
				t:bServerSettings<ScheduledRestart>;
			}
		}
		
		if(bServerSettings & RealTime)
		{
			gServerData[sd_TimeHour] = hour;
			gServerData[sd_TimeMinute] = minute;
		} else {
			gServerData[sd_TimeMinute]++;
			if(gServerData[sd_TimeMinute] == 60)
			{
				gServerData[sd_TimeMinute] = 0;
				if(gServerData[sd_TimeHour] == 24)
				{
					gServerData[sd_TimeHour] = 0;
				}
				gServerData[sd_TimeHour]++;
			}
		}
		format(szMinute, 5, "%02d", gServerData[sd_TimeMinute]);
		format(szHour, 5, "%02d", gServerData[sd_TimeHour]);
		format(szClockText, 6, "%s:%s", szHour, szMinute);
		//TextDrawSetString(gTextDraws[CLOCK_TEXT], szClockText);
		
	}
}

ptask PlayerUpdate[100](playerid)
{
	if(bPlayerSettings[playerid] & RegenHP)
	{
		if(tickcount() - gPlayerData[playerid][pd_TickStartRegenHP] > REGEN_HP_TIME)
		{
			f:bPlayerSettings[playerid]<RegenHP>;
		}
		if(tickcount() - gPlayerData[playerid][pd_TickLastDmg] > 6000)
		{
			gPlayerData[playerid][pd_HP] += 0.1;
		}
	}
	if(bPlayerSettings[playerid] & RegenAP)
	{
		if(tickcount() - gPlayerData[playerid][pd_TickStartRegenAP] > REGEN_AP_TIME)
		{
			f:bPlayerSettings[playerid]<RegenAP>;
		}
		if(tickcount() - gPlayerData[playerid][pd_TickLastDmg] > 6000)
		{
			gPlayerData[playerid][pd_AP] += 0.1;
		}
	}
	if(IsPlayerInAnyVehicle(playerid))
	{
		new 
			vehicleid = GetPlayerVehicleID(playerid),
			Float:health
		;
		
		GetVehicleHealth(vehicleid, health);
		if(health < 400.0)
		{
			SetVehicleEngine(vehicleid, false);
		}
		if(tickcount() - gPlayerData[playerid][pd_TickExitVehicle] > 3000 && GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
		{
			SetPlayerArmedWeapon(playerid, 0);
		}
	}
	SetPlayerTime(playerid, gServerData[sd_TimeHour], gServerData[sd_TimeMinute]);
}

		