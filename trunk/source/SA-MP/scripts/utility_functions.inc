/**
 * Atekbyte\Utility_function.inc
 **/

#if defined _atkbyte_utility_func
	#endinput
#else 
	#define _atkbyte_utility_func
#endif

stock RemovePlayerWeapon(playerid, weaponid)
{
	new weapondata[12][2];

	for(new i = 0; i < 12; i++)
	{
		GetPlayerWeaponData(playerid, i, weapondata[i][0], weapondata[i][1]);
		if(weapondata[i][0] == weaponid)weapondata[i][0] = 0;
	}

	ResetPlayerWeapons(playerid);

	for(new i = 0; i != 12; i++)
		GivePlayerWeapon(playerid, weapondata[i][0], weapondata[i][1]);
}

stock IsPlayerSpawned(playerid)
{
	new pState = GetPlayerState(playerid);
	return (pState != PLAYER_STATE_NONE && pState != PLAYER_STATE_WASTED && pState != PLAYER_STATE_SPECTATING);
}

// geo
forward Float:GetPlayerDist3D(player1, player2);
stock Float:GetPlayerDist3D(player1, player2)
{
	new
		Float:x1, Float:y1, Float:z1,
		Float:x2, Float:y2, Float:z2;
	GetPlayerPos(player1, x1, y1, z1);
	GetPlayerPos(player2, x2, y2, z2);
	return floatsqroot((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2));
}

forward Float:GetPlayerDist2D(player1, player2);
stock Float:GetPlayerDist2D(player1, player2)
{
	new
		x1, y1, z1,
		x2, y2, z2;

	GetPlayerPos(player1, Float:x1, Float:y1, Float:z1);
	GetPlayerPos(player2, Float:x2, Float:y2, Float:z2);
	return floatsqroot((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
}

forward Float:GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance);
stock Float:GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
    new Float:a;
    GetPlayerPos(playerid, x, y, a);
    if (IsPlayerInAnyVehicle(playerid))
        GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    else
        GetPlayerFacingAngle(playerid, a);
	
    x += (distance * floatsin(-a, degrees));
    y += (distance * floatcos(-a, degrees));
    return a;
}

// others

stock IsNumeric(const string[])
{
	for(new i, j = strlen(string); i < j; i++)
		if(string[i] > '9' || string[i] < '0') 
			return 0;
	return 1;
}

stock IsCharNumeric(c)
{
	if(c >= '0' && c<= '9') return 1;
	return 0;
}

stock IsCharAlphabetic(c)
{
	if((c>='a'&&c<='z')||(c>='A'&&c<='Z'))return 1;
	return 0;
}

#define chrtolower(%1) (((%1) > 0x40 && (%1) <= 0x5A) ? ((%1) | 0x20) : (%1))
		
stock strtolower(string[])
{
	new 
		buffer[128], 
		i, 
		j;
		
	while ((j = buffer[i])) 
	{
		buffer[i++] = chrtolower(j);
	}
	buffer[i] = '\0';
	return buffer;
}

stock UnderscoreToSpace(name[])
{
	new pos = strfind(name,"_", true);
	if(pos != -1)name[pos] = ' ';
}

stock MsToString(ms, mode = 0)
{
	new
		tmpStr[20],
		h,
		m,
		s;

	h = (ms / (1000 * 60 * 60));
	m = (ms % (1000 * 60 * 60)) / (1000 * 60);
	s = ((ms % (1000 * 60 * 60)) % (1000 * 60)) / 1000;
	ms = ms - (h * 60 * 60 * 1000) - (m * 60 * 1000) - (s * 1000);

	if(mode == 0) format(tmpStr, 20, "%d:%02d:%02d.%03d", h, m, s, ms);	// HMS
	if(mode == 1) format(tmpStr, 20, "%02d:%02d.%03d", m, s, ms);		// MS
	if(mode == 2) format(tmpStr, 20, "%02d.%03d", s, ms);				// S
	return tmpStr;
}

stock catstr(pointer[][], delimiter, ...)
{
    new
        arg
    ;
    #emit load.s.pri    8
    #emit stor.s.pri    arg

    if(8 < arg) 
	{
        if(12 < arg) 
		{ 
			// alt = arg
            new
                first;
            #emit addr.pri      8
            #emit add
            #emit stor.s.pri    arg

            #emit addr.pri      20
            #emit stor.s.pri    first

            while(arg != first) 
			{
                #emit lref.s.pri    arg
                #emit add.c         0xFFFFFFFC // -4
                #emit move.alt
                #emit load.s.pri    delimiter
                #emit stor.i

                arg -= 4;
            }
        }
        // @ PointerByAddress by Slice
        #emit load.s.alt    pointer
        #emit load.s.pri    20
        #emit sub
        #emit stor.i
    }
}

stock RGBAToHex(r, g, b, a)
{
	return (r << 24 | g << 16 | b << 8 | a);
}

stock HexToRGBA(colour, &r, &g, &b, &a)
{
	r = (colour >> 24) & 0xFF;
	g = (colour >> 16) & 0xFF;
	b = (colour >> 8) & 0xFF;
	a = colour & 0xFF;
}

stock IpIntToStr(ip)
{
	new str[17];
	format(str, 17, "%d.%d.%d.%d", ((ip >> 24) & 0xFF), ((ip >> 16) & 0xFF), ((ip >> 8) & 0xFF), (ip & 0xFF));
	return str;
}

stock IsKeyJustDown(key, newkeys, oldkeys)
{
	if((newkeys & key) && !(oldkeys & key)) return 1;
	return 0;
}

stock IsDateReached(day, month, year)
{
	new myday,mymonth,myyear;
	getdate(myyear,mymonth,myday);
	if(myday >= day) return 1;
	if(mymonth > month) return 1;
	if(myyear > year) return 1;
	return 0;
}

stock setstring(source[], dest[], slen = sizeof(source))
{
	for(new i; i < slen; i++)
	{
		dest[i] = source[i];
	}
	dest[strlen(source)-1] = EOS;
}

// lang
stock LoadLanguages()
{
	new
		File:f,
		fname[32],
		buffer[128],
		startIdx,
		langIdx;
	
	// PL
	format(fname, 32, "%s%s.txt", PATH_LANGUAGES, "PL");
	f = fopen(fname, io_read);
	
	while(fread(f, buffer))
	{
		if(-1 != strfind(buffer, ";")) continue;
		for(new i; i < 5; i++)
		{
			if(buffer[i] == ':')
			{
				startIdx = i + 1;
				break;
			}
		}

		setstring(buffer[startIdx], gServerLang[LANGUAGE_PL][langIdx]);
		strdel(gServerLang[LANGUAGE_PL][langIdx], strlen(gServerLang[LANGUAGE_PL][langIdx]) - 2, strlen(gServerLang[LANGUAGE_PL][langIdx]));
		langIdx++;
		buffer[0] = {0};
	}
	
	fclose(f);
	
	// ENG
	format(fname, 32, "%s%s.txt", PATH_LANGUAGES, "ENG");
	f = fopen(fname, io_read);
	
	while(fread(f, buffer))
	{
		if(-1 != strfind(buffer, ";")) continue;
		for(new i; i < 5; i++)
		{
			if(buffer[i] == ':')
			{
				startIdx = i + 1;
				break;
			}
		}

		setstring(buffer[startIdx], gServerLang[LANGUAGE_ENG][langIdx]);
		strdel(gServerLang[LANGUAGE_ENG][langIdx], strlen(gServerLang[LANGUAGE_ENG][langIdx]) - 2, strlen(gServerLang[LANGUAGE_ENG][langIdx]));
		langIdx++;
		buffer[0] = {0};
	}
	
	// przewidziane inne jezyki?
	fclose(f);
}

stock TXT(playerid, textid) 
{
	return (gServerLang[gPlayerData[playerid][pd_Language]][textid]);
}
