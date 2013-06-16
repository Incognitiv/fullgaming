/**
 *
 **/
 
stock AddVehicleComponentEx(vehicleid, ...)
{
	new 
		i, 
		component_id,
		num = numargs();
	
	if(num > 11) num = 11;
	for(i = 1; i < num; i++)
	{
		component_id = getarg(i, 0);
		AddVehicleComponent(vehicleid, component_id);
	}
	return i-1;
}

stock GetNearestVehicle(playerid, Float:distance = 1000.0)
{
	distance = floatabs(distance);
	if(!distance) distance = 1000.0;
	
	new 
		Float:pX, 
		Float:pY,
		Float:pZ,
		Float:nearestPos = distance,
		Float:nearestDist,
		nearestVeh = INVALID_VEHICLE_ID;
	
	GetPlayerPos(playerid, pX, pY, pZ);
	for(new i; i < MAX_VEHICLES; i++)
	{
		if(!IsVehicleStreamedIn(i, playerid)) continue;
		nearestDist = GetVehicleDistanceFromPoint(i, pX, pY, pZ);
		if(nearestPos > nearestDist)
		{
			nearestPos = nearestDist;
			nearestVeh = i;
		}
	}
	return nearestVeh;
}

stock GetPlayerInVehicle(vehicleid)
{
	new amount;
	foreach(new i : Player)
	{
		if(!IsPlayerConnected(i) || !IsPlayerInVehicle(i, vehicleid)) amount++;
	}
	return amount;
}

// todo