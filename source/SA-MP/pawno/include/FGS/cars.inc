
enum e_vehOptions {
	bool:vo_static,
	bool:vo_destroyIfEmpty,
	bool:vo_licensePlateSet,
	bool:vo_licensePlate[30],
	bool:vo_private,
	vo_pvid,
	vo_owningPlayerId,
	bool:vo_used,
	bool:vo_occupied,
	vo_color[2],
	vo_paintjob,
	vo_driver,
}

new bool:tVehicles[MAX_VEHICLES][e_vehOptions],
	vehicleDoorState[MAX_VEHICLES],
	vehicleDoorOwner[MAX_VEHICLES],
	bool:tVehicleUsed[MAX_VEHICLES] = {false, ...},
	bool:tVehicleSpawned[MAX_VEHICLES] = {false, ...}
;

new staticVehicleCount=0;

stock loadVehicles()
{
	new File:olist = fopen("vehicles.txt", io_read);
	new cnt = 0, lnum = 0, line[255], v = 0;
	while(fread(olist, line)) 
	{ 
		lnum++;
		if (line[0] != '/' && strfind(line, "AddStaticVehicle", true) != -1) 
		{
			new modelid, Float:vX,Float:vY,Float:vZ,	Float:vA, color1, color2;
			if (sscanf(line, "p<,>'('iffffdp<)>d", modelid, vX, vY, vZ, vA, color1, color2)) 
			{
				continue;
			}
			if (color1 < 0) color1 = random(127);
			if (color2 < 0) color2 = random(127);

			if (modelid<400 || (vX==0 && vY==0 && vZ==0)) continue;
			v = AddStaticVehicle(modelid,vX,vY,vZ,vA,color1,color2);
			tVehicles[v][vo_static]=true;
			tVehicles[v][vo_color][0]=color1;
			tVehicles[v][vo_color][1]=color2;
			SetVehicleHealth(v, 1000.0);
			cnt++;
		}
	}
	fclose(olist);
	staticVehicleCount += cnt;
	if (v>staticVehicleCount) staticVehicleCount = v;
	printf(" Loaded %d static vehicles", staticVehicleCount);
	return 1;
}