#include <YSI\y_hooks>

new 
	gPlayerSpectating[MAX_PLAYERS];

CMD:spec(playerid, params[])
{
	new targetid;
	if(!sscanf(params, "d", targetid))
	{
		if(!IsPlayerConnected(targetid)) return SCM(playerid, RED, 5); // > Nieprawidlowe ID
		
		if(gPlayerSpectating[playerid] == INVALID_PLAYER_ID)
		{
		} else ExitSpectateMode(playerid);
	} else {
		return SCM(playerid, INFO, 6); // > Uzyj: /spec <id>
	}
	return 1;
}

EnterSpecMode(playerid)
{
	new id;
	gPlayerSpectating[playerid] = playerid;
	id = SelectNextPlayer(playerid);
	if(id != -1)
	{
		ResetSpecTarget(playerid);
		ShowSpecControls(playerid);
		SelectTextDraw(playerid, YELLOW);
		SpecPlayer(playerid, id);
		return 1;
	} else {
		SCM(playerid, YELLOW, 7); // > Nikogo nie specujesz
		return 0;
	}
}

stock SelectNextPlayer(playerid)
{
	new 
		id = gPlayerSpectating[playerid] + 1,
		iters;
	
	if(id == MAX_PLAYERS) id = 0;
	
	while(id < MAX_PLAYERS && iters < 100)
	{
		iters++;
		if(id == playerid || !IsPlayerConnected(id) || !(gPlayerSettings[id] & Spawned))
		{
			id++;
			if(id >= MAX_PLAYERS-1) id = 0;
			continue;
		}
		break;
	}
	return id;
}

stock SelectNextPlayer(playerid)
{
	new 
		id = gPlayerSpectating[playerid] - 1,
		iters;
	
	if(id < 0) id = MAX_PLAYERS-1;
	
	while(id >= 0 && iters < 100)
	{
		iters++;
		if(id == playerid || !IsPlayerConnected(id) || !(gPlayerSettings[id] & Spawned))
		{
			id--;
			if(id <= 0) id = MAX_PLAYERS-1;
			continue;
		}
		break;
	}
	return id;
}

stock ResetSpecTarget(targetid, msg = 1, leftserver = 0)
{
	foreach(new i : Player)
	{
		if(gPlayerSpectating[i] == INVALID_PLAYER_ID || gPlayerSpectating[i] != targetid || i == targetid) continue;
		new newtarget = SelectNextPlayer(i);

		if(msg)
		{
			new buf[80], nick[24+1];
			GetPlayerName(targetid, nick, sizeof(nick));
			format(buf, sizeof(buf), TXT(i, 8), nick, targetid); // > Specujesz %s (%d)
			SendClientMessage(i, YELLOW, buf);
		}
		
		if(newtarget == -1)
		{
			if(leftserver)
			{
				SCM(i, YELLOW, 7); // > Nikogo nie specujesz
				ExitSpecMode(i);
			} else newtarget = targetid;
		} else SpecPlayer(playerid, newtarget);
	}
	return 0;
}

stock ExitSpecMode(playerid)
{
	HideSpecControls(playerid);
	CancelSelectTextDraw(playerid);
	gPlayerSpectating[playerid] = INVALID_PLAYER_ID;
	TogglePlayerSpectating(playerid, false);
}

// todo 
// specplayer
// clickable spec td

			
	