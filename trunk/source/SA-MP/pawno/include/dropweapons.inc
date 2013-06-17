#define MAX_DROP_AMOUNT -1
#define MAX_DROP_LIFETIME 30
#define WEAPON_SLOTS 13
#define INVALID_PICKUP -1
#define PICKUP_TYPE 23

enum pickup
{
	creation_time,
	weapon,
	amunicja,
	timer
}
new pickups [MAX_PICKUPS][pickup];

new PickWeapons[] =
{
	-1, // no fists
	331, // - Brass Knuckles
	333, // Golf Club
	334, // Night Stick
	335, // Knife
	336, // baseball bat
	337, // shovel
	338, // pool cue
	339, // katama
	341, // chainsaw
	321, // regular dildo
	322, // white dildo
	323, // Medium, white vibrator
	324, // smaill, silver vibrator
	325, // flowers
	326, // cane
	342, // grendade
	343, // tear gas
	344, // molotov
	-1, // RPG rocket - we can't pick up those, do we oO
	-1, // Heat-Seeking Rocket
	-1, // Hydra rocket
	346, // colt 45
	347, // colt 45 + silencer
	348, // deagle
	349, // shotgun
	350, // sawn-off
	351, // spaz
	352, // micro-uzi
	353, // mp5
	355, // ak47
	356, // m4
	372, // tec9
	357, // country rifle
	358, // sniper rifle
	-1, // rocket launcher
	-1, // heat-seeking rocket launcher
	-1, // flamethrower
	-1, // minigun
	-1, // sachtel charges
	-1, // detonator
	365, // spray can
	366, // fire extinguisher
	367, // camera
	-1, // night-vision goggles
	-1, // heat-vision goggles
	371 // parachute
};

DropWeapons(playerid)
{
	new Float: px, Float: py, Float: pz;
	new hour,minute,second;
	new year, month,day;
	gettime(hour, minute, second);
	getdate(year, month, day);

	GetPlayerPos( playerid, px, py, pz );

	new weapon_slots[WEAPON_SLOTS + 1][2];
	new used_weapon_slots;

	for( new i = 0; i < WEAPON_SLOTS; i ++ )
	{
		GetPlayerWeaponData( playerid, i, weapon_slots[ i ][ 0 ], weapon_slots[ i ][ 1 ]);
		if( i == 0 && weapon_slots[ i ][ 0 ] == 0 ) weapon_slots[ i ][ 1 ] = 0; // no fist...

		if( weapon_slots[ i ][ 1 ] > 0 && weapon_slots[ i ][ 0 ] < sizeof( PickWeapons ) && PickWeapons[ weapon_slots[ i ][ 0 ] ] != -1 )
		{
			used_weapon_slots ++;
		}
		else
		{
		    weapon_slots[ i ][ 0 ] = 0;
		    weapon_slots[ i ][ 1 ] = 0;
		}
	}

	new used_weapon_slots2 = used_weapon_slots;
	for( new i = 0; i < WEAPON_SLOTS; i ++ )
	{
	    if( weapon_slots[ i ][ 1 ] > 0 )
	    {
			new Float:angle = 360.0 - float(used_weapon_slots--) * ( 360.0 / float(used_weapon_slots2) );

			new p = CreatePickup( PickWeapons[ weapon_slots[ i ][ 0 ] ], PICKUP_TYPE, px + floatsin(angle,degrees) * (used_weapon_slots2/2 + 1.0), py + floatcos(angle,degrees) * (used_weapon_slots2/2 + 1.0), pz );
			if( p == INVALID_PICKUP )
			{
				new lowest_time;
				new _id;
				for( new j = 0; j < MAX_PICKUPS; j ++ )
				{
					if( pickups[ j ][ creation_time ] < lowest_time )
					{
					    lowest_time = pickups[ j ][ creation_time ];
					    _id = j;
					}
				}

				DestroyPickupEx( _id );
				KillTimer( pickups[ _id ][ timer ] );

				p = CreatePickup( PickWeapons[ weapon_slots[ i ][ 0 ] ], PICKUP_TYPE, px + floatsin(angle,degrees) * (used_weapon_slots2/2 + 1.0), py + floatcos(angle,degrees) * (used_weapon_slots2/2 + 1.0), pz );
			}
			pickups[ p ][ creation_time ] = mktime(hour,minute,second,day,month,year);
			pickups[ p ][ weapon ] = weapon_slots[ i ][ 0 ];
			pickups[ p ][ amunicja ] = weapon_slots[ i ][ 1 ];
			#if MAX_DROP_AMOUNT != -1
		    if( pickups[ p ][ amunicja ] > MAX_DROP_AMOUNT )
		    {
		        pickups[ p ][ amunicja ] = MAX_DROP_AMOUNT;
		    }
		    #endif
			pickups[ p ][ timer ] = SetTimerEx("DestroyPickupEx", MAX_DROP_LIFETIME * 1000, 0, "i", p);
		}
	}
}

forward DestroyPickupEx(p);
public DestroyPickupEx(p)
{
	DestroyPickup( p );
	pickups[ p ][ creation_time ] = 0;
	pickups[ p ][ weapon ] = 0;
	pickups[ p ][ amunicja ] = 0;
}