#include maps/mp/zombies/_zm_zonemgr;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps/mp/zombies/_zm_zonemgr::manage_zones, ::manage_zones);
}

manage_zones( initial_zone ) //checked changed to match cerberus output
{

	deactivate_initial_barrier_goals();
	zone_choke = 0;
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for ( i = 0; i < spawn_points.size; i++ )
	{
		spawn_points[ i ].locked = 1;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}
	if ( isDefined( level.customMap ) && level.customMap == "redroom" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_orange_level3b";
	}
	if ( isDefined( level.customMap ) && level.customMap == "rooftop" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_roof";
		initial_zone[ 1 ] = "zone_roof_infirmary";
		initial_zone[ 2 ] = "zone_infirmary";
	}
	if ( isDefined( level.customMap ) && level.customMap == "showers" )
	{
		initial_zone = [];
		initial_zone[ 1 ] = "zone_citadel";
		initial_zone[ 0 ] = "zone_citadel_shower";
		initial_zone[ 2 ] = "cellblock_shower";
	}
	else if ( isDefined( level.customMap ) && level.customMap == "docks" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_dock";
		initial_zone[ 1 ] = "zone_dock_puzzle";
		initial_zone[ 2 ] = "zone_dock_gondola";	
	}
	else if ( isDefined( level.customMap ) && level.customMap == "excavation" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_nml_2a";
		initial_zone[ 1 ] = "zone_nml_2";
		initial_zone[ 2 ] = "zone_bunker_tank_e";
		initial_zone[ 3 ] = "zone_bunker_tank_e1";
		initial_zone[ 4 ] = "zone_bunker_tank_e2";
		initial_zone[ 5 ] = "zone_bunker_tank_f";
		initial_zone[ 6 ] = "zone_nml_1";
		initial_zone[ 7 ] = "zone_nml_4";
		initial_zone[ 8 ] = "zone_nml_0";
		initial_zone[ 9 ] = "zone_nml_5";
		initial_zone[ 10 ] = "zone_nml_celllar";
		initial_zone[ 11 ] = "zone_bolt_stairs";
		initial_zone[ 12 ] = "zone_nml_3";
		initial_zone[ 13 ] = "zone_nml_2b";
		initial_zone[ 14 ] = "zone_nml_6";
		initial_zone[ 15 ] = "zone_nml_8";
		initial_zone[ 16 ] = "zone_nml_10a";
		initial_zone[ 17 ] = "zone_nml_10";
		initial_zone[ 18 ] = "zone_nml_7";
		initial_zone[ 19 ] = "zone_bunker_tank_a";
		initial_zone[ 20 ] = "zone_bunker_tank_a1";
		initial_zone[ 21 ] = "zone_bunker_tank_a2";
		initial_zone[ 22 ] = "zone_bunker_tank_b";
		initial_zone[ 23 ] = "zone_nml_9";
		initial_zone[ 24 ] = "zone_air_stairs";
		initial_zone[ 25 ] = "zone_nml_11";
		initial_zone[ 26 ] = "zone_nml_12";
		initial_zone[ 27 ] = "zone_nml_16";
		initial_zone[ 28 ] = "zone_nml_17";
		initial_zone[ 29 ] = "zone_nml_18";
		initial_zone[ 30 ] = "zone_nml_19";
		initial_zone[ 31 ] = "ug_bottom_zone";
		initial_zone[ 32 ] = "zone_nml_13";
		initial_zone[ 33 ] = "zone_nml_14";
		initial_zone[ 34 ] = "zone_nml_15";
	}
	else if ( isDefined( level.customMap ) && level.customMap == "tank" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_village_0";
		initial_zone[ 1 ] = "zone_village_5";
		initial_zone[ 2 ] = "zone_village_5a";
		initial_zone[ 3 ] = "zone_village_5b";
		initial_zone[ 4 ] = "zone_village_1";
		initial_zone[ 5 ] = "zone_village_4b";
		initial_zone[ 6 ] = "zone_village_4a";
		initial_zone[ 7 ] = "zone_village_4";
	}
	else if ( isDefined( level.customMap ) && level.customMap == "crazyplace" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_chamber_0";
		initial_zone[ 1 ] = "zone_chamber_1";
		initial_zone[ 2 ] = "zone_chamber_2";
		initial_zone[ 3 ] = "zone_chamber_3";
		initial_zone[ 4 ] = "zone_chamber_4";
		initial_zone[ 5 ] = "zone_chamber_5";
		initial_zone[ 6 ] = "zone_chamber_6";
		initial_zone[ 7 ] = "zone_chamber_7";
		initial_zone[ 8 ] = "zone_chamber_8";
	}
	else if (isdefined(level.customMap) && level.customMap == "maze")
	{
		initial_zone[initial_zone.size] = "zone_maze";
		initial_zone[initial_zone.size] = "zone_mansion_backyard";
		initial_zone[initial_zone.size] = "zone_maze_staircase";
		initial_zone[initial_zone.size] = "zone_start";
		initial_zone[initial_zone.size] = "zone_mansion";
		initial_zone[initial_zone.size] = "zone_mansion_lawn";
	}
	if ( isarray( initial_zone ) )
	{
		for ( i = 0; i < initial_zone.size; i++ )
		{
			zone_init( initial_zone[ i ] );
			enable_zone( initial_zone[ i ] );
		}
	}
	else
	{
		zone_init( initial_zone );
		enable_zone( initial_zone );
	}
	setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	level.newzones = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		level.newzones[ zkeys[ z ] ] = spawnstruct();
	}
	oldzone = undefined;
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
	while ( getDvarInt( "noclip" ) == 0 || getDvarInt( "notarget" ) != 0 )
	{	
		for( z = 0; z < zkeys.size; z++ )
		{
			level.newzones[ zkeys[ z ] ].is_active = 0;
			level.newzones[ zkeys[ z ] ].is_occupied = 0;
		}
		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		level.zone_scanning_active = 1;
		z = 0;
		while ( z < zkeys.size )
		{
			zone = level.zones[ zkeys[ z ] ];
			newzone = level.newzones[ zkeys[ z ] ];
			if( !zone.is_enabled )
			{
				z++;
				continue;
			}
			if ( isdefined(level.zone_occupied_func ) )
			{
				newzone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[ z ] );
			}
			else
			{
				newzone.is_occupied = player_in_zone( zkeys[ z ] );
			}
			if ( newzone.is_occupied )
			{
				newzone.is_active = 1;
				a_zone_is_active = 1;
				if ( zone.is_spawning_allowed )
				{
					a_zone_is_spawning_allowed = 1;
				}
				if ( !isdefined(oldzone) || oldzone != newzone )
				{
					level notify( "newzoneActive", zkeys[ z ] );
					oldzone = newzone;
				}
				azkeys = getarraykeys( zone.adjacent_zones );
				for ( az = 0; az < zone.adjacent_zones.size; az++ )
				{
					if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
					{
						level.newzones[ azkeys[ az ] ].is_active = 1;
						if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
						{
							a_zone_is_spawning_allowed = 1;
						}
					}
				}
			}
			zone_choke++;
			if ( zone_choke >= 3 )
			{
				zone_choke = 0;
				wait 0.05;
			}
			z++;
		}
		level.zone_scanning_active = 0;
		for ( z = 0; z < zkeys.size; z++ )
		{
			level.zones[ zkeys[ z ] ].is_active = level.newzones[ zkeys[ z ] ].is_active;
			level.zones[ zkeys[ z ] ].is_occupied = level.newzones[ zkeys[ z ] ].is_occupied;
		}
		if ( !a_zone_is_active || !a_zone_is_spawning_allowed )
		{
			if ( isarray( initial_zone ) )
			{
				level.zones[ initial_zone[ 0 ] ].is_active = 1;
				level.zones[ initial_zone[ 0 ] ].is_occupied = 1;
				level.zones[ initial_zone[ 0 ] ].is_spawning_allowed = 1;
			}
			else
			{
				level.zones[ initial_zone ].is_active = 1;
				level.zones[ initial_zone ].is_occupied = 1;
				level.zones[ initial_zone ].is_spawning_allowed = 1;
			}
		}
		create_spawner_list( zkeys );
		level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}

create_spawner_list( zkeys ) //modified function
{
	level.zombie_spawn_locations = [];
	level.inert_locations = [];
	level.enemy_dog_locations = [];
	level.zombie_screecher_locations = [];
	level.zombie_avogadro_locations = [];
	level.quad_locations = [];
	level.zombie_leaper_locations = [];
	level.zombie_astro_locations = [];
	level.zombie_brutus_locations = [];
	level.zombie_mechz_locations = [];
	level.zombie_napalm_locations = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		zone = level.zones[ zkeys[ z ] ];
		if ( zone.is_enabled && zone.is_active && zone.is_spawning_allowed )
		{
			for ( i = 0; i < zone.spawn_locations.size; i++ )
			{
				if(level.script == "zm_transit" && level.customMap != "vanilla")
				{
					if ( zone.spawn_locations[ i ].origin == ( -11447, -3424, 254.2 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					if ( zone.spawn_locations[ i ].origin == ( -10944, -3846, 221.14 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					if ( zone.spawn_locations[ i ].origin == ( -11093, 393, 192 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					if ( zone.spawn_locations[ i ].origin == ( -11347, -3134, 283.9 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11332.9, -2876.95, 207 );
					}
					if ( zone.spawn_locations[ i ].origin == ( -11182, -4384, 196.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11115, -3152, 207 );
					}
					if ( zone.spawn_locations[ i ].origin == ( -11251, -4397, 200.02 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11107.8, -1301, 184 );
					}
					if ( zone.spawn_locations[ i ].origin == ( 8394, -2545, -205.16 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( 10249.4, 7691.71, -569.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9339, 6411, -566.9 ) )
					{
						zone.spawn_locations[ i ].origin = ( 9993.29, 7486.83, -582.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9914, 8408, -576 ) )
					{
						zone.spawn_locations[ i ].origin = ( 9993.29, 7550, -582.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9429, 5281, -539.6 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 13019.1, 7382.5, -754 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -3825, -6576, -52.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4061.03, -6754.44, -58.0897 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -3450, -6559, -51.9 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4060.93, -6968.64, -65.3446 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -4165, -6098, -64 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4239.78, -6902.81, -57.0494 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5058, -5902, -73.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4846.77, -6906.38, 54.8145 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -6462, -7159, -64 ) )
					{
						zone.spawn_locations[ i ].origin = ( -6201.18, -7107.83, -59.7182 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5130, -6512, -35.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -5396.36, -6801.88, -60.0821 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -6531, -6613, -54.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -6116.62, -6586.81, -50.8905 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5373, -6231, -51.9 ) )
					{
						zone.spawn_locations[ i ].origin = ( -4827.92, -7137.19, -62.9082 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5752, -6230, -53.4 ) )
					{
						zone.spawn_locations[ i ].origin = ( -5572.47, -6426, -39.1894 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5540, -6508, -42 ) )
					{
						zone.spawn_locations[ i ].origin = ( -5789.51, -6935.81, -57.875 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11093 , 393 , 192 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11431.3, -644.496, 192.125 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -10944, -3846, 221.14 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11351.7, -1988.58, 184.125 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11251, -4397, 200.02 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11431.3, -644.496, 192.125 );
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11334 , -5280, 212.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11600.6, -1918.41, 192.125 );
						zone.spawn_locations[ i ].script_noteworthy = "riser_location";
					}
					else if (zone.spawn_locations[ i ].origin == ( -10836, 1195, 209.7 ) )
					{
						zone.spawn_locations[ i ].origin = ( -11241.2, -1118.76, 184.125 );
					}
					/*
					else if ( zone.spawn_locations[ i ].origin == ( -10747, -63, 203.8 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11347, -3134, 283.9 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11447, -3424, 254.2 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -10761, 155, 236.8 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11110, -2921, 195.79 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					*/
					else if ( zone.spawn_locations[ i ].targetname == "zone_trans_diner_spawners")
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					if ( zone.spawn_locations[ i ].is_enabled )
					{
						level.zombie_spawn_locations[ level.zombie_spawn_locations.size ] = zone.spawn_locations[ i ];
					}
				}
				else if (level.script == "zm_prison" && level.customMap != "vanilla")
				{
					if( zone.spawn_locations[ i ].origin == ( -1880.2, 5419.9, -55 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if( zone.spawn_locations[ i ].origin == ( -1852.2, 5307.9, -55 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
				}
				if(zone.spawn_locations[ i ].is_enabled)
				{
					level.zombie_spawn_locations[level.zombie_spawn_locations.size] = zone.spawn_locations[i];
				}
			}
			for(x = 0; x < zone.inert_locations.size; x++)
			{
				if(zone.inert_locations[x].is_enabled)
				{
					level.inert_locations[level.inert_locations.size] = zone.inert_locations[x];
				}
			}
			for(x = 0; x < zone.dog_locations.size; x++)
			{
				if(zone.dog_locations[x].is_enabled)
				{
					level.enemy_dog_locations[level.enemy_dog_locations.size] = zone.dog_locations[x];
				}
			}
			for(x = 0; x < zone.screecher_locations.size; x++)
			{
				if(zone.screecher_locations[x].is_enabled)
				{
					level.zombie_screecher_locations[level.zombie_screecher_locations.size] = zone.screecher_locations[x];
				}
			}
			/*
			for(x = 0; x < zone.avogadro_locations.size; x++)
			{
				if(zone.avogadro_locations[x].is_enabled)
				{
					level.zombie_avogadro_locations[level.zombie_avogadro_locations.size] = zone.avogadro_locations[x];
				}
			}
			*/
			for(x = 0; x < zone.quad_locations.size; x++)
			{
				if(zone.quad_locations[x].is_enabled)
				{
					level.quad_locations[level.quad_locations.size] = zone.quad_locations[x];
				}
			}
			for(x = 0; x < zone.leaper_locations.size; x++)
			{
				if(zone.leaper_locations[x].is_enabled)
				{
					level.zombie_leaper_locations[level.zombie_leaper_locations.size] = zone.leaper_locations[x];
				}
			}
			for(x = 0; x < zone.astro_locations.size; x++)
			{
				if(zone.astro_locations[x].is_enabled)
				{
					level.zombie_astro_locations[level.zombie_astro_locations.size] = zone.astro_locations[x];
				}
			}
			for(x = 0; x < zone.napalm_locations.size; x++)
			{
				if(zone.napalm_locations[x].is_enabled)
				{
					level.zombie_napalm_locations[level.zombie_napalm_locations.size] = zone.napalm_locations[x];
				}
			}
			for(x = 0; x < zone.brutus_locations.size; x++)
			{
				if(zone.brutus_locations[x].is_enabled)
				{
					level.zombie_brutus_locations[level.zombie_brutus_locations.size] = zone.brutus_locations[x];
				}
			}
			for(x = 0; x < zone.mechz_locations.size; x++)
			{
				if(zone.mechz_locations[x].is_enabled)
				{
					level.zombie_mechz_locations[level.zombie_mechz_locations.size] = zone.mechz_locations[x];
				}
			}
		}
	}
}