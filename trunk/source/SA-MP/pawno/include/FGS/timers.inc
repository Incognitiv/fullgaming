stock TimersInit() {
	SetTimer ("PlayerUpdate",8000,true);
	SetTimer ("Staty",10000,true);
	SetTimer ("SekundaFunc",2000,true);
	SetTimer ("MinutaFunc",59500,true);
	SetTimer ("SendRandomInfo",300000,true);
	SetTimer ("Min10Func",600000,true);
	SetTimer ("GodzinaFunc",3600000,true);
	SetTimer ("RespawnVehicles", 1800000, true);
	
	SetTimer("UpdateSec", 600, true);
	TimerReaction = SetTimer("ReactionTest", 5*60*1000, true);
	SetTimer( "timerAnimateLogo", 2*60*999, true );
}

forward RespawnVehicles (); public RespawnVehicles () {
	respawnVehicles();
}

stock respawnVehicles(force=false)
{
	new bool:UsedVeh[MAX_VEHICLES] = {false, ...};
	foreachPly(i)
	{
		new vid = GetPlayerVehicleID(i);
		if(vid == 0 || vid == INVALID_VEHICLE_ID) continue;
		UsedVeh[vid] = true;
		tVehicles[vid][vo_occupied] = true;
		new vmodel = GetVehicleModel(vid);
		if(vmodel == 525 || vmodel == 403 || vmodel == 514 || vmodel == 515)
		{
			new tvid = GetVehicleTrailer(vid);
			if(tvid>0 && tvid != INVALID_VEHICLE_ID)
			{
				UsedVeh[tvid] = true;
				tVehicles[tvid][vo_occupied]=true;
			}
		}
	}
	
	// statyczne
	for(new vehicleid = random(3)+1; vehicleid<staticVehicleCount; vehicleid+=3)
	{
		if(!UsedVeh[vehicleid] && tVehicleUsed[vehicleid])
		{
			SetVehicleToRespawn(vehicleid);
		}
	}
	
	// dynamiczne
	for(new vehicleid = staticVehicleCount+1; vehicleid != MAX_VEHICLES; vehicleid += (force? 1: (random(2)+1)))
	{
		if(!UsedVeh[vehicleid])
		{
			new bool:block;
		    for(new i=0;i<HOUSES_LOOP;i++){
		    	if(HouseInfo[i][hCarid] == vehicleid){
					block = true;
					break;
				}
			}
			if(block) continue;
			
			if(tVehicles[vehicleid][vo_private] && tVehicles[vehicleid][vo_owningPlayerId] != INVALID_PLAYER_ID)
			{
			} else if(tVehicles[vehicleid][vo_destroyIfEmpty])
			{
				DestroyVehicle(vehicleid);
				tVehicles[vehicleid][vo_destroyIfEmpty] = false;
				tVehicleUsed[vehicleid] = false;
			} else {
				if(tVehicleUsed[vehicleid] && !force)
					tVehicleUsed[vehicleid] = false;
				else if(tVehicleSpawned[vehicleid]) {
					DestroyVehicle(vehicleid); tVehicleSpawned[vehicleid]=false;
				} else 
					SetVehicleToRespawn(vehicleid);
			}
		}
	}
	return 1;
}

forward RespawnVehicle(vid);
public RespawnVehicle(vid)
{
	if (IsTrailerAttachedToVehicle(vid))
		DetachTrailerFromVehicle(vid);

	if (tVehicles[vid][vo_static])
		SetVehicleToRespawn(vid);
	else
		DestroyVehicle(vid);
	tVehicleSpawned[vid]=false;

} 
			
		
			