/**
 * Atekbyte\Scripting_functions.inc
 **/

#if defined _atkbyte_script_func
	#endinput
#else 
	#define _atkbyte_script_func
#endif

stock GetOffsetDegrees(Float:a, Float:b)
{
	new Float:C;
	C = (b > a)? b - a: 0.0 - (a - b);
	if(C > 180.0) c = 0.0 - (360.0 - c);
	else if(C <= -180.0) C = (360 + C);
	return C;
}

stock GetDistanceBetweenPoints2D(Float:x, Float:y, Float:xx, Float:yy)
{
    new Float:newx = (xx - x);
    new Float:newy = (yy - y);
    return floatsqroot((newx * newx) + (newy * newy));
}

stock GetDistanceBetweenPoints3D(Float:x, Float:y, Float:z, Float:xx, Float:yy, Float:zz)
{
    new Float:newx = (xx - x);
    new Float:newy = (yy - y);
    new Float:newz = (zz - z);
    return floatsqroot((newx * newx) + (newy * newy) + (newz * newz));
}

stock PlayStream(playerid, url[], volume = 100)
{
	new Float:PP[3];
	GetPlayerPos(playerid, PP[0], PP[1], PP[2]);
	PlayAudioStreamForPlayer(playerid, url, PP[0], PP[1], PP[2] + volume, volume + 10, 1);
	return 1;
}

stock SCM(playerid, colour, message[])
{
	if(strlen(message) > 127)
	{
		new 
			buffer[128],
			splitpos;
		
		for(new c = 128; c > 0; c--)
		{
			if(message[c] == ' ' || message[c] == ',' || message[c] == '.')
			{
				splitpos = c;
				break;
			}
		}
		
		strcat(buffer, message[splitpos]);
		message[splitpos] = EOS;
		
		SendClientMessage(playerid, colour, message);
		SendClientMessage(playerid, colour, buffer);
		
	} SendClientMessage(playerid, colour, message);
	return 1;
}

stock DriverTickStart(playerid)
{
	gPlayerData[playerid][pd_EnterVehTick] = tickcount();
}

stock DriverTickEnd(playerid)
{
	if(gPlayerData[playerid][pd_EnterVehTick] == 0) return 0xff;
	gPlayerData[playerid][pd_TimeInVeh] += (tickcount() - gPlayerData[playerid][pd_EnterVehTick]);
	gPlayerData[playerid][pd_EnterVehTick] = 0;
	return 1;
}

stock WalkerTickStart(playerid)
{
	gPlayerData[playerid][pd_EnterFootTick] = tickcount();
}

stock WalkerTickEnd(playerid)
{
	if(gPlayerData[playerid][pd_EnterFootTick] == 0) return 0xff;
	gPlayerData[playerid][pd_TimeOnFoot] += (tickcount() - gPlayerData[playerid][pd_EnterFootTick]);
	gPlayerData[playerid][pd_EnterFootTick] = 0;
	return 1;
}
