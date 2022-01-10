#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_spawning;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/gametypes_zm/_globallogic_ui;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/gametypes_zm/_globallogic_score;
#include maps/mp/gametypes_zm/_globallogic_defaults;
#include maps/mp/gametypes_zm/_gameobjects;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_callbacksetup;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/_utility;

main()
{
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::game_objects_allowed, ::game_objects_allowed);
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::onspawnplayer, ::onspawnplayer);
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype, ::get_player_spawns_for_gametype);
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::add_map_location_gamemode, ::add_map_location_gamemode);
	init_spawnpoints_for_custom_survival_maps();
}

init()
{
	init_barriers_for_custom_maps();
}

add_map_location_gamemode( mode, location, precache_func, main_func ) //checked matches cerberus output
{
	if ( !isDefined( level.gamemode_map_location_precache[ mode ] ) )
	{
	/*
/#
		println( "*** ERROR : " + mode + " has not been added to the map using add_map_gamemode." );
#/
	*/
		return;
	}
	level.gamemode_map_location_precache[ mode ][ location ] = precache_func;
	level.gamemode_map_location_main[ mode ][ location ] = main_func;
	if(mode == "zstandard" && location == "transit")
	{
		level.gamemode_map_location_main[ mode ][ location ] = scripts/zm/zm_transit/bsm_transit_main::main_busdepot;
	}
}

game_objects_allowed( mode, location ) //checked partially changed to match cerberus output changed at own discretion
{
	allowed[ 0 ] = mode;
	entities = getentarray();
	location = getDvar( "customMap" );
	if ( location == "house" )
	{
		location = "hunters_cabin";
	}
	i = 0;
	while ( i < entities.size )
	{
		if ( isDefined( entities[ i ].script_gameobjectname ) )
		{
			isallowed = maps/mp/gametypes_zm/_gameobjects::entity_is_allowed( entities[ i ], allowed );
			isvalidlocation = maps/mp/gametypes_zm/_gameobjects::location_is_allowed( entities[ i ], location );
			if ( !isallowed || !isvalidlocation && !is_classic() )
			{
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
					{
						entities[ i ] connectpaths();
					}
				}
				entities[ i ] delete();
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].script_vector ) )
			{
				entities[ i ] moveto( entities[ i ].origin + entities[ i ].script_vector, 0.05 );
				entities[ i ] waittill( "movedone" );
				if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
				{
					entities[ i ] disconnectpaths();
				}
				i++;
				continue;
			}
			if ( isDefined( entities[ i ].spawnflags ) && entities[ i ].spawnflags == 1 )
			{
				if ( isDefined( entities[ i ].classname ) && entities[ i ].classname != "trigger_multiple" )
				{
					entities[ i ] connectpaths();
				}
			}
		}
		i++;
	}
}

init_spawnpoints_for_custom_survival_maps() //custom function
{
	//TUNNEL
	level.tunnelSpawnpoints = [];
	level.tunnelSpawnpoints[ 0 ] = spawnstruct();
	level.tunnelSpawnpoints[ 0 ].origin = ( -11196, -837, 192 );
	level.tunnelSpawnpoints[ 0 ].angles = ( 0, -94, 0 );
	level.tunnelSpawnpoints[ 0 ].radius = 32;
	level.tunnelSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 0 ].script_int = 2048;
	
	level.tunnelSpawnpoints[ 1 ] = spawnstruct();
	level.tunnelSpawnpoints[ 1 ].origin = ( -11386, -863, 192 );
	level.tunnelSpawnpoints[ 1 ].angles = ( 0, -44, 0 );
	level.tunnelSpawnpoints[ 1 ].radius = 32;
	level.tunnelSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 1 ].script_int = 2048;
	
	level.tunnelSpawnpoints[ 2 ] = spawnstruct();
	level.tunnelSpawnpoints[ 2 ].origin = ( -11405, -1000, 192 );
	level.tunnelSpawnpoints[ 2 ].angles = ( 0, -32, 0 );
	level.tunnelSpawnpoints[ 2 ].radius = 32;
	level.tunnelSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 2 ].script_int = 2048;
	
	level.tunnelSpawnpoints[ 3 ] = spawnstruct();
	level.tunnelSpawnpoints[ 3 ].origin = ( -11498, -1151, 192 );
	level.tunnelSpawnpoints[ 3 ].angles = ( 0, 4, 0 );
	level.tunnelSpawnpoints[ 3 ].radius = 32;
	level.tunnelSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 3 ].script_int = 2048;
	
	level.tunnelSpawnpoints[ 4 ] = spawnstruct();
	level.tunnelSpawnpoints[ 4 ].origin = ( -11398, -1326, 191 );
	level.tunnelSpawnpoints[ 4 ].angles = ( 0, 50, 0 );
	level.tunnelSpawnpoints[ 4 ].radius = 32;
	level.tunnelSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 4 ].script_int = 2048;
	
	level.tunnelSpawnpoints[ 5 ] = spawnstruct();
	level.tunnelSpawnpoints[ 5 ].origin = ( -11222, -1345, 192 );
	level.tunnelSpawnpoints[ 5 ].angles = ( 0, 89, 0 );
	level.tunnelSpawnpoints[ 5 ].radius = 32;
	level.tunnelSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 5 ].script_int = 2048;
	
	level.tunnelSpawnpoints[ 6 ] = spawnstruct();
	level.tunnelSpawnpoints[ 6 ].origin = ( -10934, -1380, 192 );
	level.tunnelSpawnpoints[ 6 ].angles = ( 0, 157, 0 );
	level.tunnelSpawnpoints[ 6 ].radius = 32;
	level.tunnelSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 6 ].script_int = 2048;
	
	level.tunnelSpawnpoints[ 7 ] = spawnstruct();
	level.tunnelSpawnpoints[ 7 ].origin = ( -10999, -1072, 192 );
	level.tunnelSpawnpoints[ 7 ].angles = ( 0, -144, 0 );
	level.tunnelSpawnpoints[ 7 ].radius = 32;
	level.tunnelSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.tunnelSpawnpoints[ 7 ].script_int = 2048;
	
	//DINER
	level.dinerSpawnpoints = [];									 
	level.dinerSpawnpoints[ 0 ] = spawnstruct();
	level.dinerSpawnpoints[ 0 ].origin = ( -3991, -7317, -63 );
	level.dinerSpawnpoints[ 0 ].angles = ( 0, 161, 0 );
	level.dinerSpawnpoints[ 0 ].radius = 32;
	level.dinerSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 0 ].script_int = 2048;
	
	level.dinerSpawnpoints[ 1 ] = spawnstruct();
	level.dinerSpawnpoints[ 1 ].origin = ( -4231, -7395, -60 );
	level.dinerSpawnpoints[ 1 ].angles = ( 0, 120, 0 );
	level.dinerSpawnpoints[ 1 ].radius = 32;
	level.dinerSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 1 ].script_int = 2048;
	
	level.dinerSpawnpoints[ 2 ] = spawnstruct();
	level.dinerSpawnpoints[ 2 ].origin = ( -4127, -6757, -54 );
	level.dinerSpawnpoints[ 2 ].angles = ( 0, 217, 0 );
	level.dinerSpawnpoints[ 2 ].radius = 32;
	level.dinerSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 2 ].script_int = 2048;
	
	level.dinerSpawnpoints[ 3 ] = spawnstruct();
	level.dinerSpawnpoints[ 3 ].origin = ( -4465, -7346, -58 );
	level.dinerSpawnpoints[ 3 ].angles = ( 0, 173, 0 );
	level.dinerSpawnpoints[ 3 ].radius = 32;
	level.dinerSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 3 ].script_int = 2048;
	
	level.dinerSpawnpoints[ 4 ] = spawnstruct();
	level.dinerSpawnpoints[ 4 ].origin = ( -5770, -6600, -55 );
	level.dinerSpawnpoints[ 4 ].angles = ( 0, -106, 0 );
	level.dinerSpawnpoints[ 4 ].radius = 32;
	level.dinerSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 4 ].script_int = 2048;
	
	level.dinerSpawnpoints[ 5 ] = spawnstruct();
	level.dinerSpawnpoints[ 5 ].origin = ( -6135, -6671, -56 );
	level.dinerSpawnpoints[ 5 ].angles = ( 0, -46, 0 );
	level.dinerSpawnpoints[ 5 ].radius = 32;
	level.dinerSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 5 ].script_int = 2048;
	
	level.dinerSpawnpoints[ 6 ] = spawnstruct();
	level.dinerSpawnpoints[ 6 ].origin = ( -6182, -7120, -60 );
	level.dinerSpawnpoints[ 6 ].angles = ( 0, 51, 0 );
	level.dinerSpawnpoints[ 6 ].radius = 32;
	level.dinerSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 6 ].script_int = 2048;
	
	level.dinerSpawnpoints[ 7 ] = spawnstruct();
	level.dinerSpawnpoints[ 7 ].origin = ( -5882, -7174, -61 );
	level.dinerSpawnpoints[ 7 ].angles = ( 0, 99, 0 );
	level.dinerSpawnpoints[ 7 ].radius = 32;
	level.dinerSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.dinerSpawnpoints[ 7 ].script_int = 2048;
	
	//CORNFIELD
	level.cornfieldSpawnpoints = [];
	level.cornfieldSpawnpoints[ 0 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 0 ].origin = ( 7521, -545, -198 );
	level.cornfieldSpawnpoints[ 0 ].angles = ( 0, 40, 0 );
	level.cornfieldSpawnpoints[ 0 ].radius = 32;
	level.cornfieldSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 0 ].script_int = 2048;
	
	level.cornfieldSpawnpoints[ 1 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 1 ].origin = ( 7751, -522, -202 );
	level.cornfieldSpawnpoints[ 1 ].angles = ( 0, 145, 0 );
	level.cornfieldSpawnpoints[ 1 ].radius = 32;
	level.cornfieldSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 1 ].script_int = 2048;
	
	level.cornfieldSpawnpoints[ 2 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 2 ].origin = ( 7691, -395, -201 );
	level.cornfieldSpawnpoints[ 2 ].angles = ( 0, -131, 0 );
	level.cornfieldSpawnpoints[ 2 ].radius = 32;
	level.cornfieldSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 2 ].script_int = 2048;
	
	level.cornfieldSpawnpoints[ 3 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 3 ].origin = ( 7536, -432, -199 );
	level.cornfieldSpawnpoints[ 3 ].angles = ( 0, -24, 0 );
	level.cornfieldSpawnpoints[ 3 ].radius = 32;
	level.cornfieldSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 3 ].script_int = 2048;
	
	level.cornfieldSpawnpoints[ 4 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 4 ].origin = ( 13745, -336, -188 );
	level.cornfieldSpawnpoints[ 4 ].angles = ( 0, -178, 0 );
	level.cornfieldSpawnpoints[ 4 ].radius = 32;
	level.cornfieldSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 4 ].script_int = 2048;
	
	level.cornfieldSpawnpoints[ 5 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 5 ].origin = ( 13758, -681, -188 );
	level.cornfieldSpawnpoints[ 5 ].angles = ( 0, -179, 0 );
	level.cornfieldSpawnpoints[ 5 ].radius = 32;
	level.cornfieldSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 5 ].script_int = 2048;
	
	level.cornfieldSpawnpoints[ 6 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 6 ].origin = ( 13816, -1088, -189 );
	level.cornfieldSpawnpoints[ 6 ].angles = ( 0, -177, 0 );
	level.cornfieldSpawnpoints[ 6 ].radius = 32;
	level.cornfieldSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 6 ].script_int = 2048;
	
	level.cornfieldSpawnpoints[ 7 ] = spawnstruct();
	level.cornfieldSpawnpoints[ 7 ].origin = ( 13752, -1444, -182 );
	level.cornfieldSpawnpoints[ 7 ].angles = ( 0, -177, 0 ); 
	level.cornfieldSpawnpoints[ 7 ].radius = 32;
	level.cornfieldSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.cornfieldSpawnpoints[ 7 ].script_int = 2048;
	
	//POWER STATION
	level.powerStationSpawnpoints = [];
	level.powerStationSpawnpoints[ 0 ] = spawnstruct();
	level.powerStationSpawnpoints[ 0 ].origin = ( 11288, 7988, -550 );
	level.powerStationSpawnpoints[ 0 ].angles = ( 0, -137, 0 );
	level.powerStationSpawnpoints[ 0 ].radius = 32;
	level.powerStationSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 0 ].script_int = 2048;
	
	level.powerStationSpawnpoints[ 1 ] = spawnstruct();
	level.powerStationSpawnpoints[ 1 ].origin = ( 11284, 7760, -549 );
	level.powerStationSpawnpoints[ 1 ].angles = ( 0, 177, 0 );
	level.powerStationSpawnpoints[ 1 ].radius = 32;
	level.powerStationSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 1 ].script_int = 2048;
	
	level.powerStationSpawnpoints[ 2 ] = spawnstruct();
	level.powerStationSpawnpoints[ 2 ].origin = ( 10784, 7623, -584 );
	level.powerStationSpawnpoints[ 2 ].angles = ( 0, -10, 0 );
	level.powerStationSpawnpoints[ 2 ].radius = 32;
	level.powerStationSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 2 ].script_int = 2048;
	
	level.powerStationSpawnpoints[ 3 ] = spawnstruct();
	level.powerStationSpawnpoints[ 3 ].origin = ( 10866, 7473, -580 );
	level.powerStationSpawnpoints[ 3 ].angles = ( 0, 21, 0 );
	level.powerStationSpawnpoints[ 3 ].radius = 32;
	level.powerStationSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 3 ].script_int = 2048;
	
	level.powerStationSpawnpoints[ 4 ] = spawnstruct();
	level.powerStationSpawnpoints[ 4 ].origin = ( 10261, 8146, -580 );
	level.powerStationSpawnpoints[ 4 ].angles = ( 0, -31, 0 );
	level.powerStationSpawnpoints[ 4 ].radius = 32;
	level.powerStationSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 4 ].script_int = 2048;
	
	level.powerStationSpawnpoints[ 5 ] = spawnstruct();
	level.powerStationSpawnpoints[ 5 ].origin = ( 10595, 8055, -541 );
	level.powerStationSpawnpoints[ 5 ].angles = ( 0, -43, 0 );
	level.powerStationSpawnpoints[ 5 ].radius = 32;
	level.powerStationSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 5 ].script_int = 2048;
	
	level.powerStationSpawnpoints[ 6 ] = spawnstruct();
	level.powerStationSpawnpoints[ 6 ].origin = ( 10477, 7679, -567 );
	level.powerStationSpawnpoints[ 6 ].angles = ( 0, -9, 0 );
	level.powerStationSpawnpoints[ 6 ].radius = 32;
	level.powerStationSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 6 ].script_int = 2048;
	
	level.powerStationSpawnpoints[ 7 ] = spawnstruct();
	level.powerStationSpawnpoints[ 7 ].origin = ( 10165, 7879, -570 );
	level.powerStationSpawnpoints[ 7 ].angles = ( 0, -15, 0 );
	level.powerStationSpawnpoints[ 7 ].radius = 32;
	level.powerStationSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.powerStationSpawnpoints[ 7 ].script_int = 2048;
	
	level.houseSpawnpoints = [];
	level.houseSpawnpoints[ 0 ] = spawnstruct();
	level.houseSpawnpoints[ 0 ].origin = ( 5071, 7022, -20 );
	level.houseSpawnpoints[ 0 ].angles = ( 0, 315, 0 );
	level.houseSpawnpoints[ 0 ].radius = 32;
	level.houseSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 0 ].script_int = 2048;
	
	level.houseSpawnpoints[ 1 ] = spawnstruct();
	level.houseSpawnpoints[ 1 ].origin = ( 5358, 7034, -20 );
	level.houseSpawnpoints[ 1 ].angles = ( 0, 246, 0 );
	level.houseSpawnpoints[ 1 ].radius = 32;
	level.houseSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 1 ].script_int = 2048;
	
	level.houseSpawnpoints[ 2 ] = spawnstruct();
	level.houseSpawnpoints[ 2 ].origin = ( 5078, 6733, -20 );
	level.houseSpawnpoints[ 2 ].angles = ( 0, 56, 0 );
	level.houseSpawnpoints[ 2 ].radius = 32;
	level.houseSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 2 ].script_int = 2048;
	
	level.houseSpawnpoints[ 3 ] = spawnstruct();
	level.houseSpawnpoints[ 3 ].origin = ( 5334, 6723, -20 );
	level.houseSpawnpoints[ 3 ].angles = ( 0, 123, 0 );
	level.houseSpawnpoints[ 3 ].radius = 32;
	level.houseSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 3 ].script_int = 2048;
	
	level.houseSpawnpoints[ 4 ] = spawnstruct();
	level.houseSpawnpoints[ 4 ].origin = ( 5057, 6583, -10 );
	level.houseSpawnpoints[ 4 ].angles = ( 0, 0, 0 );
	level.houseSpawnpoints[ 4 ].radius = 32;
	level.houseSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 4 ].script_int = 2048;
	
	level.houseSpawnpoints[ 5 ] = spawnstruct();
	level.houseSpawnpoints[ 5 ].origin = ( 5305, 6591, -20 );
	level.houseSpawnpoints[ 5 ].angles = ( 0, 180, 0 );
	level.houseSpawnpoints[ 5 ].radius = 32;
	level.houseSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 5 ].script_int = 2048;
	
	level.houseSpawnpoints[ 6 ] = spawnstruct();
	level.houseSpawnpoints[ 6 ].origin = ( 5350, 6882, -20 );
	level.houseSpawnpoints[ 6 ].angles = ( 0, 180, 0 );
	level.houseSpawnpoints[ 6 ].radius = 32;
	level.houseSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 6 ].script_int = 2048;
	
	level.houseSpawnpoints[ 7 ] = spawnstruct();
	level.houseSpawnpoints[ 7 ].origin = ( 5102, 6851, -20 );
	level.houseSpawnpoints[ 7 ].angles = ( 0, 0, 0 );
	level.houseSpawnpoints[ 7 ].radius = 32;
	level.houseSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.houseSpawnpoints[ 7 ].script_int = 2048;

	level.townSpawnpoints = [];
	level.townSpawnpoints[ 0 ] = spawnstruct();
	level.townSpawnpoints[ 0 ].origin = ( 1475, -1405, -61 );
	level.townSpawnpoints[ 0 ].angles = ( 0, 79, 0 );
	level.townSpawnpoints[ 0 ].radius = 32;
	level.townSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 0 ].script_int = 2048;
	
	level.townSpawnpoints[ 1 ] = spawnstruct();
	level.townSpawnpoints[ 1 ].origin = (784.983, -482.281, -61.875);
	level.townSpawnpoints[ 1 ].angles = ( 0, 0, 0 );
	level.townSpawnpoints[ 1 ].radius = 32;
	level.townSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 1 ].script_int = 2048;
	
	level.townSpawnpoints[ 2 ] = spawnstruct();
	level.townSpawnpoints[ 2 ].origin = (1484.29, 386.917, -61.875);
	level.townSpawnpoints[ 2 ].angles = ( 0, 267, 0 );
	level.townSpawnpoints[ 2 ].radius = 32;
	level.townSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 2 ].script_int = 2048;
	
	level.townSpawnpoints[ 3 ] = spawnstruct();
	level.townSpawnpoints[ 3 ].origin = (2066.05, -483.1, -61.875);
	level.townSpawnpoints[ 3 ].angles = ( 0, 168, 0 );
	level.townSpawnpoints[ 3 ].radius = 32;
	level.townSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 3 ].script_int = 2048;
	
	level.townSpawnpoints[ 4 ] = spawnstruct();
	level.townSpawnpoints[ 4 ].origin = (1707.79, -458.352, -55.5342);
	level.townSpawnpoints[ 4 ].angles = ( 0, 180, 0 );
	level.townSpawnpoints[ 4 ].radius = 32;
	level.townSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 4 ].script_int = 2048;
	
	level.townSpawnpoints[ 5 ] = spawnstruct();
	level.townSpawnpoints[ 5 ].origin = (1486.61, -145.148, -61.875);
	level.townSpawnpoints[ 5 ].angles = ( 0, 255, 0 );
	level.townSpawnpoints[ 5 ].radius = 32;
	level.townSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 5 ].script_int = 2048;
	
	level.townSpawnpoints[ 6 ] = spawnstruct();
	level.townSpawnpoints[ 6 ].origin = (1044.67, -170.147, -55.875);
	level.townSpawnpoints[ 6 ].angles = ( 0, 324, 0 );
	level.townSpawnpoints[ 6 ].radius = 32;
	level.townSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 6 ].script_int = 2048;
	
	level.townSpawnpoints[ 7 ] = spawnstruct();
	level.townSpawnpoints[ 7 ].origin = (1273.88, -740.064, -55.875);
	level.townSpawnpoints[ 7 ].angles = ( 0, 60, 0 );
	level.townSpawnpoints[ 7 ].radius = 32;
	level.townSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.townSpawnpoints[ 7 ].script_int = 2048;

	level.farmSpawnpoints = [];
	level.farmSpawnpoints[ 0 ] = spawnstruct();
	level.farmSpawnpoints[ 0 ].origin = (7166, -5755, -46);
	level.farmSpawnpoints[ 0 ].angles = ( 0, 0, 0 );
	level.farmSpawnpoints[ 0 ].radius = 32;
	level.farmSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 0 ].script_int = 2048;
	
	level.farmSpawnpoints[ 1 ] = spawnstruct();
	level.farmSpawnpoints[ 1 ].origin = (7780.54, -5534.08, 22.0331);
	level.farmSpawnpoints[ 1 ].angles = ( 0, 312, 0 );
	level.farmSpawnpoints[ 1 ].radius = 32;
	level.farmSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 1 ].script_int = 2048;
	
	level.farmSpawnpoints[ 2 ] = spawnstruct();
	level.farmSpawnpoints[ 2 ].origin = (8393.6, -5599.27, 45.5198);
	level.farmSpawnpoints[ 2 ].angles = ( 0, 210, 0 );
	level.farmSpawnpoints[ 2 ].radius = 32;
	level.farmSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 2 ].script_int = 2048;
	
	level.farmSpawnpoints[ 3 ] = spawnstruct();
	level.farmSpawnpoints[ 3 ].origin = (8435.45, -6051.42, 78.4683);
	level.farmSpawnpoints[ 3 ].angles = ( 0, 131, 0 );
	level.farmSpawnpoints[ 3 ].radius = 32;
	level.farmSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 3 ].script_int = 2048;
	
	level.farmSpawnpoints[ 4 ] = spawnstruct();
	level.farmSpawnpoints[ 4 ].origin = (7756.5, -6310.07, 117.125);
	level.farmSpawnpoints[ 4 ].angles = ( 0, 38, 0 );
	level.farmSpawnpoints[ 4 ].radius = 32;
	level.farmSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 4 ].script_int = 2048;
	
	level.farmSpawnpoints[ 5 ] = spawnstruct();
	level.farmSpawnpoints[ 5 ].origin = (7715.74, -4835.88, 37.6189);
	level.farmSpawnpoints[ 5 ].angles = ( 0, 278, 0 );
	level.farmSpawnpoints[ 5 ].radius = 32;
	level.farmSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 5 ].script_int = 2048;
	
	level.farmSpawnpoints[ 6 ] = spawnstruct();
	level.farmSpawnpoints[ 6 ].origin = (7931.78, -4819.38, 48.125);
	level.farmSpawnpoints[ 6 ].angles = ( 0, 291, 0 );
	level.farmSpawnpoints[ 6 ].radius = 32;
	level.farmSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 6 ].script_int = 2048;
	
	level.farmSpawnpoints[ 7 ] = spawnstruct();
	level.farmSpawnpoints[ 7 ].origin = (8474.06, -5218, 48.125);
	level.farmSpawnpoints[ 7 ].angles = ( 0, 215, 0 );
	level.farmSpawnpoints[ 7 ].radius = 32;
	level.farmSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.farmSpawnpoints[ 7 ].script_int = 2048;
}

init_barriers_for_custom_maps() //custom function
{
	if(isDefined(level.customMap) && level.customMap != "vanilla")
	{
		//DINER CLIPS
		dinerclip1 = spawn("script_model", (-3952,-6957,-67));
		dinerclip1 setModel("collision_player_wall_256x256x10");
		dinerclip1 rotateTo((0,82,0), .1);

		dinerclip2 = spawn("script_model", (-4173,-6679,-60));
		dinerclip2 setModel("collision_player_wall_512x512x10");
		dinerclip2 rotateTo((0,0,0), .1);

		dinerclip3 = spawn("script_model", (-5073,-6732,-59));
		dinerclip3 setModel("collision_player_wall_512x512x10");
		dinerclip3 rotateTo((0,328,0), .1);

		dinerclip4 = spawn("script_model", (-6104,-6490,-38));
		dinerclip4 setModel("collision_player_wall_512x512x10");
		dinerclip4 rotateTo((0,2,0), .1);

		dinerclip5 = spawn("script_model", (-5850,-6486,-38));
		dinerclip5 setModel("collision_player_wall_256x256x10");
		dinerclip5 rotateTo((0,0,0), .1);

		dinerclip6 = spawn("script_model", (-5624,-6406,-40));
		dinerclip6 setModel("collision_player_wall_256x256x10");
		dinerclip6 rotateTo((0,226,0), .1);

		dinerclip7 = spawn("script_model", (-6348,-6886,-55));
		dinerclip7 setModel("collision_player_wall_512x512x10");
		dinerclip7 rotateTo((0,98,0), .1);

		//TUNNEL BARRIERS
		tunnelbarrier1 = spawn("script_model", (-11250,-520,255));
		tunnelbarrier1 setModel("veh_t6_civ_movingtrk_cab_dead");
		tunnelbarrier1 rotateTo((0,172,0),.1);
		tunnelclip1 = spawn("script_model", (-11250,-580,255));
		tunnelclip1 setModel("collision_player_wall_256x256x10");
		tunnelclip1 rotateTo((0,180,0), .1);
		tunnelclip2 = spawn("script_model", (-11506,-580,255));
		tunnelclip2 setModel("collision_player_wall_256x256x10");
		tunnelclip2 rotateTo((0,180,0), .1);

		tunnelbarrier4 = spawn("script_model", (-10770,-3240,255));
		tunnelbarrier4 setModel("veh_t6_civ_movingtrk_cab_dead");
		tunnelbarrier4 rotateTo((0,214,0),.1);
		tunnelclip3 = spawn("script_model", (-10840,-3190,255));
		tunnelclip3 setModel("collision_player_wall_256x256x10");
		tunnelclip3 rotateTo((0,214,0), .1);

		    //tunnelclip3 DisconnectPaths();

		//HOUSE BARRIERS
		housebarrier1 = spawn("script_model", (5568,6336,-70));
		housebarrier1 setModel("collision_player_wall_512x512x10");
		housebarrier1 rotateTo((0,266,0),.1);
		housebarrier1 ConnectPaths();

		housebarrier2 = spawn("script_model", (5074,7089,-24));
		housebarrier2 setModel("collision_player_wall_128x128x10");
		housebarrier2 rotateTo((0,0,0),.1);
		housebarrier2 ConnectPaths();

		housebarrier3 = spawn("script_model", (4985,5862,-64));
		housebarrier3 setModel("collision_player_wall_512x512x10");
		housebarrier3 rotateTo((0,159,0),.1);
		housebarrier3 ConnectPaths();

		housebarrier4 = spawn("script_model", (5207,5782,-64));
		housebarrier4 setModel("collision_player_wall_512x512x10");
		housebarrier4 rotateTo((0,159,0),.1);
		housebarrier4 ConnectPaths();

		housebarrier5 = spawn("script_model", (4819,6475,-64));
		housebarrier5 setModel("collision_player_wall_512x512x10");
		housebarrier5 rotateTo((0,258,0),.1);
		housebarrier5 ConnectPaths();

		housebarrier6 = spawn("script_model", (4767,6200,-64));
		housebarrier6 setModel("collision_player_wall_512x512x10");
		housebarrier6 rotateTo((0,258,0),.1);
		housebarrier6 ConnectPaths();

		housebarrier7 = spawn("script_model", (5459,5683,-64));
		housebarrier7 setModel("collision_player_wall_512x512x10");
		housebarrier7 rotateTo((0,159,0),.1);
		housebarrier7 ConnectPaths();
		
		housebush1 = spawn("script_model", (5548.5, 6358, -72));
		housebush1 setModel("t5_foliage_bush05");
		housebush1 rotateTo((0,271,0),.1);
		
		housebush2 = spawn("script_model", (5543.79, 6269.37, -64.75));
		housebush2 setModel("t5_foliage_bush05");
		housebush2 rotateTo((0,-45,0),.1);
		
		housebush3 = spawn("script_model", (5553.23, 6446, -76));
		housebush3 setModel("t5_foliage_bush05");
		housebush3 rotateTo((0,90,0),.1);
		
		housebush4 = spawn("script_model", (5534, 6190.8, -64));
		housebush4 setModel("t5_foliage_bush05");
		housebush4 rotateTo((0,180,0),.1);
		
		housebush5 = spawn("script_model", (5565.1, 5661, -64));
		housebush5 setModel("t5_foliage_bush05");
		housebush5 rotateTo((0,-45,0),.1);
		
		housebush6 = spawn("script_model", (5380.4, 5738, -64));
		housebush6 setModel("t5_foliage_bush05");
		housebush6 rotateTo((0,80,0),.1);
		
		housebush7 = spawn("script_model", (5467, 5702, -64));
		housebush7 setModel("t5_foliage_bush05");
		housebush7 rotateTo((0,40,0),.1);
		
		housebush8 = spawn("script_model", (5323.1, 5761.7, -64));
		housebush8 setModel("t5_foliage_bush05");
		housebush8 rotateTo((0,120,0),.1);
		
		housebush9 = spawn("script_model", (5261, 5787.5, -64));
		housebush9 setModel("t5_foliage_bush05");
		housebush9 rotateTo((0,150,0),.1);
		
		housebush10 = spawn("script_model", (5199, 5813.5, -64));
		housebush10 setModel("t5_foliage_bush05");
		housebush10 rotateTo((0,230,0),.1);
		
		housebush11 = spawn("script_model", (5137, 5839.5, -64)); //-62, +26
		housebush11 setModel("t5_foliage_bush05");
		housebush11 rotateTo((0,0,0),.1);
		
		housebush12 = spawn("script_model", (5075, 5865.5, -64));
		housebush12 setModel("t5_foliage_bush05");
		housebush12 rotateTo((0,70,0),.1);
		
		housebush13 = spawn("script_model", (5013, 5891.5, -64));
		housebush13 setModel("t5_foliage_bush05");
		housebush13 rotateTo((0,170,0),.1);
		
		housebush14 = spawn("script_model", (4951, 5917.5, -64));
		housebush14 setModel("t5_foliage_bush05");
		housebush14 rotateTo((0,0,0),.1);
		
		housebush15 = spawn("script_model", (4889, 5943.5, -64));
		housebush15 setModel("t5_foliage_bush05");
		housebush15 rotateTo((0,245,0),.1);
		
		housebush16 = spawn("script_model", (4810, 5926.5, -64));
		housebush16 setModel("t5_foliage_bush05");
		housebush16 rotateTo((0,53,0),.1);
		
		housebush17 = spawn("script_model", (4762, 6069, -64));
		housebush17 setModel("t5_foliage_bush05");
		housebush17 rotateTo((0,100,0),.1);
		
		housebush18 = spawn("script_model", (4777, 6149, -64)); //+15, +80
		housebush18 setModel("t5_foliage_bush05");
		housebush18 rotateTo((0,200,0),.1);
		
		housebush19 = spawn("script_model", (4792, 6229, -64));
		housebush19 setModel("t5_foliage_bush05");
		housebush19 rotateTo((0,100,0),.1);
		
		housebush20 = spawn("script_model", (4807, 6309, -64));
		housebush20 setModel("t5_foliage_bush05");
		housebush20 rotateTo((0,200,0),.1);
		
		housebush21 = spawn("script_model", (4822, 6389, -64));
		housebush21 setModel("t5_foliage_bush05");
		housebush21 rotateTo((0,100,0),.1);
		
		housebush22 = spawn("script_model", (4837, 6469, -64));
		housebush22 setModel("t5_foliage_bush05");
		housebush22 rotateTo((0,200,0),.1);
		
		housebush23 = spawn("script_model", (4852, 6549, -64));
		housebush23 setModel("t5_foliage_bush05");
		housebush23 rotateTo((0,100,0),.1);
		
		housebush24 = spawn("script_model", (4867, 6629, -64));
		housebush24 setModel("t5_foliage_bush05");
		housebush24 rotateTo((0,200,0),.1);
		
		housebush25 = spawn("script_model", (5557.4, 6524.5, -80));
		housebush25 setModel("t5_foliage_bush05");
		housebush25 rotateTo((0,200,0),.1);
		
		housebush26 = spawn("script_model", (5078.68, 7172.37, -64));
		housebush26 setModel("t5_foliage_bush05");
		housebush26 rotateTo((0,234,0),.1);
		
		housebush27 = spawn("script_model", (5017, 7130.22, -64));
		housebush27 setModel("t5_foliage_bush05");
		housebush27 rotateTo((0,45,0),.1);
		
		housebush28 = spawn("script_model", (5154.25, 7133.65, -64));
		housebush28 setModel("t5_foliage_bush05");
		housebush28 rotateTo((0,130,0),.1);
		
		housebush29 = spawn("script_model", (5105.25, 7166.65, -64));
		housebush29 setModel("t5_foliage_bush05");
		housebush29 rotateTo((0,292,0),.1);

		//POWER STATION BARRIERS
		powerbarrier1 = spawn("script_model", (9965,8133,-556));
		powerbarrier1 setModel("veh_t6_civ_60s_coupe_dead");
		powerbarrier1 rotateTo((15,5,0),.1);
		powerclip1 = spawn("script_model", (9955,8105,-575));
		powerclip1 setModel("collision_player_wall_256x256x10");
		powerclip1 rotateTo((0,0,0),.1);

		powerbarrier2 = spawn("script_model", (10056,8350,-584));
		powerbarrier2 setModel("veh_t6_civ_bus_zombie");
		powerbarrier2 rotateTo((0,340,0),.1);
		powerbarrier2 NotSolid();
		powerclip2 = spawn("script_model", (10267,8194,-556));
		powerclip2 setModel("collision_player_wall_256x256x10");
		powerclip2 rotateTo((0,340,0),.1);
		powerclip3 = spawn("script_model", (10409,8220,-181));
		powerclip3 setModel("collision_player_wall_512x512x10");
		powerclip3 rotateTo((0,250,0),.1);
		powerclip4 = spawn("script_model", (10409,8220,-556));
		powerclip4 setModel("collision_player_wall_128x128x10");
		powerclip4 rotateTo((0,250,0),.1);

		powerbarrier3 = spawn("script_model", (10281,7257,-575));
		powerbarrier3 setModel("veh_t6_civ_microbus_dead");
		powerbarrier3 rotateTo((0,13,0),.1);
		powerclip4 = spawn("script_model", (10268,7294,-569));
		powerclip4 setModel("collision_player_wall_256x256x10");
		powerclip4 rotateTo((0,13,0),.1);

		powerbarrier4 = spawn("script_model", (10100,7238,-575));
		powerbarrier4 setModel("veh_t6_civ_60s_coupe_dead");
		powerbarrier4 rotateTo((0,52,0),.1);
		powerclip5 = spawn("script_model", (10170,7292,-505));
		powerclip5 setModel("collision_player_wall_128x128x10");
		powerclip5 rotateTo((0,140,0),.1);
		powerclip6 = spawn("script_model", (10030,7216,-569));
		powerclip6 setModel("collision_player_wall_256x256x10");
		powerclip6 rotateTo((0,49,0),.1);

		powerclip7 = spawn("script_model", (10563,8630,-344));
		powerclip7 setModel("collision_player_wall_256x256x10");
		powerclip7 rotateTo((0,270,0),.1);

		//CORNFIELD BARRIERS
		cornfieldbarrier1 = spawn("script_model", (10190,135,-159));
		cornfieldbarrier1 setModel("veh_t6_civ_movingtrk_cab_dead");
		cornfieldbarrier1 rotateTo((0,172,0),.1);
		cornfieldclip1 = spawn("script_model", (10100,100,-159));
		cornfieldclip1 setModel("collision_player_wall_512x512x10");
		cornfieldclip1 rotateTo((0,172,0),.1);

		cornfieldbarrier2 = spawn("script_model", (10100,-1800,-217));
		cornfieldbarrier2 setModel("veh_t6_civ_bus_zombie");
		cornfieldbarrier2 rotateTo((0,126,0),.1);
		cornfieldbarrier2 NotSolid();
		cornfieldclip1 = spawn("script_model", (10045,-1607,-181));
		cornfieldclip1 setModel("collision_player_wall_512x512x10");
		cornfieldclip1 rotateTo((0,126,0),.1);
	}
}

onspawnplayer( predictedspawn ) //modified function
{
	if ( !isDefined( predictedspawn ) )
	{
		predictedspawn = 0;
	}
	pixbeginevent( "ZSURVIVAL:onSpawnPlayer" );
	self.usingobj = undefined;
	self.is_zombie = 0;
	if ( isDefined( level.custom_spawnplayer ) && isDefined( self.player_initialized ) && self.player_initialized )
	{
		self [[ level.custom_spawnplayer ]]();
		return;
	}
	if ( flag( "begin_spawning" ) )
	{
		spawnpoint = maps/mp/zombies/_zm::check_for_valid_spawn_near_team( self, 1 );
	}
	if ( !isDefined( spawnpoint ) )
	{
		match_string = "";
		location = level.scr_zm_map_start_location;
		if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
		{
			location = level.default_start_location;
		}
		match_string = level.scr_zm_ui_gametype + "_" + location;
		spawnpoints = [];
		if ( isDefined( level.customMap ) && level.customMap == "tunnel" )
		{
			for ( i = 0; i < level.tunnelSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.tunnelSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "diner" )
		{
			for ( i = 0; i < level.dinerSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.dinerSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "cornfield" )
		{
			for ( i = 0; i < level.cornfieldSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.cornfieldSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "power" )
		{
			for ( i = 0; i < level.powerStationSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.powerStationSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "house" )
		{
			for ( i = 0; i < level.houseSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.houseSpawnpoints[ i ];
			}
		}
		else if ( getDvar("customMap") == "town" )
		{
			for( i = 0; i < level.townSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.townSpawnpoints[ i ];
			}
		}
		else if ( getDvar("customMap") == "farm" )
		{
			for( i = 0; i < level.farmSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.farmSpawnpoints[ i ];
			}
		}
		else
		{
			spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
		}
		spawnpoint = getfreespawnpoint( spawnpoints, self );
	}
	self spawn( spawnpoint.origin, spawnpoint.angles, "zsurvival" );
	self.entity_num = self getentitynumber();
	self thread maps/mp/zombies/_zm::onplayerspawned();
	self thread maps/mp/zombies/_zm::player_revive_monitor();
	self freezecontrols( 1 );
	self.spectator_respawn = spawnpoint;
	self.score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "score" );
	self.pers[ "participation" ] = 0;
	
	self.score_total = self.score;
	self.old_score = self.score;
	self.player_initialized = 0;
	self.zombification_time = 0;
	self.enabletext = 1;
	self thread maps/mp/zombies/_zm_blockers::rebuild_barrier_reward_reset();
	if ( isDefined( level.host_ended_game ) && !level.host_ended_game )
	{
		self freeze_player_controls( 0 );
		self enableweapons();
	}
	if ( isDefined( level.game_mode_spawn_player_logic ) )
	{
		spawn_in_spectate = [[ level.game_mode_spawn_player_logic ]]();
		if ( spawn_in_spectate )
		{
			self delay_thread( 0.05, maps/mp/zombies/_zm::spawnspectator );
		}
	}
	pixendevent();
}

getfreespawnpoint( spawnpoints, player ) //checked changed to match cerberus output
{
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
	if ( !isDefined( game[ "spawns_randomized" ] ) )
	{
		game[ "spawns_randomized" ] = 1;
		spawnpoints = array_randomize( spawnpoints );
		random_chance = randomint( 100 );
		if ( random_chance > 50 )
		{
			set_game_var( "side_selection", 1 );
		}
		else
		{
			set_game_var( "side_selection", 2 );
		}
	}
	side_selection = get_game_var( "side_selection" );
	if ( get_game_var( "switchedsides" ) )
	{
		if ( side_selection == 2 )
		{
			side_selection = 1;
		}
		else
		{
			if ( side_selection == 1 )
			{
				side_selection = 2;
			}
		}
	}
	if ( isdefined( player ) && isdefined( player.team ) )
	{
		i = 0;
		while ( isdefined( spawnpoints ) && i < spawnpoints.size )
		{
			if ( side_selection == 1 )
			{
				if ( player.team != "allies" && isdefined( spawnpoints[ i ].script_int ) && spawnpoints[ i ].script_int == 1 )
				{
					arrayremovevalue( spawnpoints, spawnpoints[ i ] );
					i = 0;
				}
				else if ( player.team == "allies" && isdefined( spawnpoints[ i ].script_int) && spawnpoints[ i ].script_int == 2 )
				{
					arrayremovevalue( spawnpoints, spawnpoints[ i ] );
					i = 0;
				}
				else
				{
					i++;
				}
			}
			else //changed to be like beta dump
			{
				if ( player.team == "allies" && isdefined( spawnpoints[ i ].script_int ) && spawnpoints[ i ].script_int == 1 )
				{
					arrayremovevalue(spawnpoints, spawnpoints[i]);
					i = 0;
				}
				else if ( player.team != "allies" && isdefined( spawnpoints[ i ].script_int ) && spawnpoints[ i ].script_int == 2 )
				{
					arrayremovevalue( spawnpoints, spawnpoints[ i ] );
					i = 0;
				}
				else
				{
					i++;
				}
			}
		}
	}
	if ( !isdefined( player.playernum ) )
	{
		if ( player.team == "allies" )
		{
			player.playernum = get_game_var( "_team1_num" );
			set_game_var( "_team1_num", player.playernum + 1 );
		}
		else
		{
			player.playernum = get_game_var( "_team2_num" );
			set_game_var( "_team2_num", player.playernum + 1 );
		}
	}
	for ( j = 0; j < spawnpoints.size; j++ )
	{
		if ( !isdefined( spawnpoints[ j ].en_num ) ) 
		{
			for ( m = 0; m < spawnpoints.size; m++ )
			{
				spawnpoints[m].en_num = m;
			}
		}
		else if ( spawnpoints[ j ].en_num == player.playernum )
		{
			return spawnpoints[ j ];
		}
	}
	return spawnpoints[ 0 ];
}

get_player_spawns_for_gametype() //modified function
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype + "_" + location;
	player_spawns = [];
	structs = getstructarray("player_respawn_point", "targetname");
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_string ) )
		{
			tokens = strtok( structs[ i ].script_string, " " );
			foreach ( token in tokens )
			{
				if ( token == match_string )
				{
					player_spawns[ player_spawns.size ] = structs[ i ];
				}
			}
			i++;
			continue;
		}
		player_spawns[ player_spawns.size ] = structs[ i ];
		i++;
	}
	custom_spawns = [];
	if ( isDefined( level.customMap ) && level.customMap == "tunnel" )
	{
		for(i=0;i<level.tunnelSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.tunnelSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "diner")
	{
		for(i=0;i<level.dinerSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.dinerSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "cornfield")
	{
		for(i=0;i<level.cornfieldSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.cornfieldSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "power")
	{
		for(i=0;i<level.powerStationSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.powerStationSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "house")
	{
		for(i=0;i<level.houseSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.houseSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if(getDvar("customMap") == "town")
	{
		for(i=0;i<level.townSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.townSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if(getDvar("customMap") == "farm")
	{
		for(i=0;i<level.farmSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.farmSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "docks")
	{
		for(i=0;i<level.docksSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.docksSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "cellblock")
	{
		for(i=0;i<level.cellblockSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.cellblockSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "rooftop")
	{
		for(i=0;i<level.rooftopSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.rooftopSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isdefined( level.customMap ) && level.customMap == "maze" )
	{
		for(i=0;i<level.mazeSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.mazeSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if ( isDefined( level.customMap ) && level.customMap == "crazyplace" )
	{
		for ( i = 0; i < level.crazyplaceSpawnpoints.size; i++ )
		{
			custom_spawns[ custom_spawns.size ] = level.crazyplaceSpawnpoints[ i ];
		}
		return custom_spawns;
	}
	else if ( isdefined( level.customMap ) && level.customMap == "excavation" )
	{
		for ( i = 0; i < level.excavationSpawnpoints.size; i++ )
		{
			custom_spawns[ custom_spawns.size ] = level.excavationSpawnpoints[ i ];
		}
		return custom_spawns;
	}
	return player_spawns;
}