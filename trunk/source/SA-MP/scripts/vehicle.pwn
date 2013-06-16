/**
 * Atekbyte\Vehicles.inc
 **/

#if defined _atkbyte_vehicles
	#endinput
#else 
	#define _atkbyte_vehicles
#endif

#define VEHICLE_INDEX_FILE 		"AtekByte/vehicles/index.ini"
#define VEHICLE_DATA_FILE 		"AtekByte/vehicles/%s.dat"
#define PERSONAL_VEHICLE_FILE	"AtekByte/vehicles/special/player.dat"

#define MAX_PERSONAL_VEHICLE 	32

enum
{
	VEHICLE_GROUP_NONE = -1,
	VEHICLE_GROUP_CASUAL,
	VEHICLE_GROUP_CASUAL_DESERT,
	VEHICLE_GROUP_CASUAL_COUNTRY,
	VEHICLE_GROUP_SPORT,
	VEHICLE_GROUP_OFFROAD,
	VEHICLE_GROUP_BIKE,
	VEHICLE_GROUP_FASTBIKE,
	VEHICLE_GROUP_MILITARY,
	VEHICLE_GROUP_POLICE,
	VEHICLE_GROUP_BIGPLANE,
	VEHICLE_GROUP_SMALLPLANE,
	VEHICLE_GROUP_HELICOPTER,
	VEHICLE_GROUP_BOAT
};

enum e_VEHICLE_DATA
{
	vd_Vehicleid,
	vd_Owner[MAX_PLAYER_NAME+1],
	vd_Command[16],
	vd_Model,
	Float:vd_Pos[4],
	vd_Colour[2],
	vd_Playte[12]
};

enum (<<=1)
{
	VEHICLE_USED,
	VEHICLE_OCCUPIED
};

new 
	TotalVehicles,
	TotalPersonalVehicles,
	gVehicleSettings[MAX_VEHICLES],
	gVehicleContainer[MAX_VEHICLES],
	gCurModelGroup,
	
	VehicleData[MAX_PERSONAL_VEHICLE][e_VEHICLE_DATA],
	Vehicle_custom_hydra,
	Vehicle_custom_invis;
	
new gModelGroup[13][68]=
{
	// VEHICLE_GROUP_CASUAL
	{
		404,442,479,549,600,496,496,401,
		410,419,436,439,517,518,401,410,
		419,436,439,474,491,496,517,518,
		526,527,533,545,549,580,589,600,
		602,400,404,442,458,479,489,505,
		579,405,421,426,445,466,467,492,
		507,516,529,540,546,547,550,551,
		566,585,587,412,534,535,536,567,
		575,576, 0, ...
	},
	// VEHICLE_GROUP_CASUAL_DESERT,
	{
	    404,479,445,542,466,467,549,540,
		424,400,500,505,489,499,422,600,
		515,543,554,443,508,525, 0, ...
	},
	// VEHICLE_GROUP_CASUAL_COUNTRY,
	{
	    499,422,498,609,455,403,414,514,
		600,413,515,440,543,531,478,456,
		554,445,518,401,527,542,546,410,
		549,508,525, 0, ...
	},
	// VEHICLE_GROUP_SPORT,
	{
		558,559,560,561,562,565,411,451,
		477,480,494,502,503,506,541, 0, ...
	},
	// VEHICLE_GROUP_OFFROAD,
	{
		400,505,579,422,478,543,554, 0, ...
	},
	// VEHICLE_GROUP_BIKE,
	{
	    509,481,510,462,448,463,586,468,
		471, 0, ...
	},
	// VEHICLE_GROUP_FASTBIKE,
	{
	    581,522,461,521, 0, ...
	},
	// VEHICLE_GROUP_MILITARY,
	{
	    433,432,601,470, 0, ...
	},
	// VEHICLE_GROUP_POLICE,
	{
	    523,596,598,597,599,490,528,427
	},
	// VEHICLE_GROUP_BIGPLANE,
	{
	    519,553,577,592, 0, ...
	},
	// VEHICLE_GROUP_SMALLPLANE,
	{
	    460,476,511,512,513,593, 0, ...
	},
	// VEHICLE_GROUP_HELICOPTER,
	{
	    548,487,417,487,488,487,497,487,
		563,477,469,487, 0, ...
	},
	// VEHICLE_GROUP_BOAT,
	{
	    472,473,493,595,484,430,453,452,
		446,454, 0, ...
	}
};
