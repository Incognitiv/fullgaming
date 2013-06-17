CMD:skocznia(playerid, cmdtext[])
{
	if(isnull(cmdtext))
	    return SendClientMessage(playerid, 0xff0000ff, "››› Wpisz /Skocznia [1 - 4]");

	new prog = strval(cmdtext);
	switch(prog)
	{
	    case 1: SetPlayerPos(playerid, -1701.19995117,-2076.10009766,211.80000305);
	    case 2: SetPlayerPos(playerid, -1665.69995117,-2047.69995117,192.00000000);
	    case 3: SetPlayerPos(playerid, -1661.69995117,-2006.00000000,166.80000305);
	    case 4: SetPlayerPos(playerid, -1659.50000000,-1971.90002441,141.10000610);
	}
	SetPVarInt(playerid, "NaSkoczni", 1);
	SetPVarInt(playerid, "Skoczyl", 0);
	SetPVarInt(playerid, "pickup", 0);
	return 1;
}