#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_game_module;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_blockers;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\gametypes_zm\_hud;
#include maps\mp\zombies\_zm_audio_announcer;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\gametypes_zm\_globallogic_ui;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\gametypes_zm\_globallogic_score;
#include maps\mp\gametypes_zm\_globallogic_defaults;
#include maps\mp\gametypes_zm\_gameobjects;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\gametypes_zm\_weapons;
#include maps\mp\gametypes_zm\_callbacksetup;
#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\_utility;

main()
{
	replacefunc(maps\mp\gametypes_zm\_zm_gametype::game_objects_allowed, ::game_objects_allowed);
	replacefunc(maps\mp\gametypes_zm\_zm_gametype::onspawnplayer, ::onspawnplayer);
	replacefunc(maps\mp\gametypes_zm\_zm_gametype::get_player_spawns_for_gametype, ::get_player_spawns_for_gametype);
	init_spawnpoints_for_custom_survival_maps();
}

init()
{
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
			isallowed = maps\mp\gametypes_zm\_gameobjects::entity_is_allowed( entities[ i ], allowed );
			isvalidlocation = maps\mp\gametypes_zm\_gameobjects::location_is_allowed( entities[ i ], location );
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
	level.trenchesSpawnpoints = [];
	level.trenchesSpawnpoints[ 0 ] = spawnstruct();
	level.trenchesSpawnpoints[ 0 ].origin = (2096.84, 4961.77, -299.875);
	level.trenchesSpawnpoints[ 0 ].angles = ( 0, 300, 0 );
	level.trenchesSpawnpoints[ 0 ].radius = 32;
	level.trenchesSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 0 ].script_int = 2048;
	
	level.trenchesSpawnpoints[ 1 ] = spawnstruct();
	level.trenchesSpawnpoints[ 1 ].origin = (2050.48, 4656.4, -299.875);
	level.trenchesSpawnpoints[ 1 ].angles = ( 0, 47, 0 );
	level.trenchesSpawnpoints[ 1 ].radius = 32;
	level.trenchesSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 1 ].script_int = 2048;
	
	level.trenchesSpawnpoints[ 2 ] = spawnstruct();
	level.trenchesSpawnpoints[ 2 ].origin = (2340.41, 4614.65, -301.92);
	level.trenchesSpawnpoints[ 2 ].angles = ( 0, 134, 0 );
	level.trenchesSpawnpoints[ 2 ].radius = 32;
	level.trenchesSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 2 ].script_int = 2048;
	
	level.trenchesSpawnpoints[ 3 ] = spawnstruct();
	level.trenchesSpawnpoints[ 3 ].origin = (2328.26, 4904.16, -299.875);
	level.trenchesSpawnpoints[ 3 ].angles = ( 0, 210, 0 );
	level.trenchesSpawnpoints[ 3 ].radius = 32;
	level.trenchesSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 3 ].script_int = 2048;
	
	level.trenchesSpawnpoints[ 4 ] = spawnstruct();
	level.trenchesSpawnpoints[ 4 ].origin = (2554.91, 5155.65, -375.875);
	level.trenchesSpawnpoints[ 4 ].angles = ( 0, 50, 0 );
	level.trenchesSpawnpoints[ 4 ].radius = 32;
	level.trenchesSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 4 ].script_int = 2048;
	
	level.trenchesSpawnpoints[ 5 ] = spawnstruct();
	level.trenchesSpawnpoints[ 5 ].origin = (2895.25, 5159.11, -375.875);
	level.trenchesSpawnpoints[ 5 ].angles = ( 0, 137, 0 );
	level.trenchesSpawnpoints[ 5 ].radius = 32;
	level.trenchesSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 5 ].script_int = 2048;
	
	level.trenchesSpawnpoints[ 6 ] = spawnstruct();
	level.trenchesSpawnpoints[ 6 ].origin = (2878.78, 5451.09, -367.875);
	level.trenchesSpawnpoints[ 6 ].angles = ( 0, 220, 0 );
	level.trenchesSpawnpoints[ 6 ].radius = 32;
	level.trenchesSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 6 ].script_int = 2048;
	
	level.trenchesSpawnpoints[ 7 ] = spawnstruct();
	level.trenchesSpawnpoints[ 7 ].origin = (2572.78, 5430.02, -367.875);
	level.trenchesSpawnpoints[ 7 ].angles = ( 0, 310, 0 );
	level.trenchesSpawnpoints[ 7 ].radius = 32;
	level.trenchesSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.trenchesSpawnpoints[ 7 ].script_int = 2048;

	level.excavationSpawnpoints = [];
	level.excavationSpawnpoints[ 0 ] = spawnstruct();
	level.excavationSpawnpoints[ 0 ].origin = ( 1392, 802, 104 );
	level.excavationSpawnpoints[ 0 ].angles = ( 0, 226, 0 );
	level.excavationSpawnpoints[ 0 ].radius = 32;
	level.excavationSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 0 ].script_int = 2048;
	
	level.excavationSpawnpoints[ 1 ] = spawnstruct();
	level.excavationSpawnpoints[ 1 ].origin = ( 480, 800, 83 );
	level.excavationSpawnpoints[ 1 ].angles = ( 0, 329, 0 );
	level.excavationSpawnpoints[ 1 ].radius = 32;
	level.excavationSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 1 ].script_int = 2048;
	
	level.excavationSpawnpoints[ 2 ] = spawnstruct();
	level.excavationSpawnpoints[ 2 ].origin = ( -778, 936, 133 );
	level.excavationSpawnpoints[ 2 ].angles = ( 0, 320, 0 );
	level.excavationSpawnpoints[ 2 ].radius = 32;
	level.excavationSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 2 ].script_int = 2048;
	
	level.excavationSpawnpoints[ 3 ] = spawnstruct();
	level.excavationSpawnpoints[ 3 ].origin = ( -1914, 512, 94 );
	level.excavationSpawnpoints[ 3 ].angles = ( 0, 11, 0 );
	level.excavationSpawnpoints[ 3 ].radius = 32;
	level.excavationSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 3 ].script_int = 2048;
	
	level.excavationSpawnpoints[ 4 ] = spawnstruct();
	level.excavationSpawnpoints[ 4 ].origin = ( -1763, -319, 114 );
	level.excavationSpawnpoints[ 4 ].angles = ( 0, 24, 0 );
	level.excavationSpawnpoints[ 4 ].radius = 32;
	level.excavationSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 4 ].script_int = 2048;
	
	level.excavationSpawnpoints[ 5 ] = spawnstruct();
	level.excavationSpawnpoints[ 5 ].origin = ( -907, -382, 100 );
	level.excavationSpawnpoints[ 5 ].angles = ( 0, 33, 0 );
	level.excavationSpawnpoints[ 5 ].radius = 32;
	level.excavationSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 5 ].script_int = 2048;
	
	level.excavationSpawnpoints[ 6 ] = spawnstruct();
	level.excavationSpawnpoints[ 6 ].origin = ( 742, -945, 66 );
	level.excavationSpawnpoints[ 6 ].angles = ( 0, 131, 0 );
	level.excavationSpawnpoints[ 6 ].radius = 32;
	level.excavationSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 6 ].script_int = 2048;
	
	level.excavationSpawnpoints[ 7 ] = spawnstruct();
	level.excavationSpawnpoints[ 7 ].origin = ( 1286, -266, 99 );
	level.excavationSpawnpoints[ 7 ].angles = ( 0, 147, 0 );
	level.excavationSpawnpoints[ 7 ].radius = 32;
	level.excavationSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.excavationSpawnpoints[ 7 ].script_int = 2048;

	level.tankSpawnpoints = [];
	level.tankSpawnpoints[ 0 ] = spawnstruct();
	level.tankSpawnpoints[ 0 ].origin = ( 308, -2021, 247 );
	level.tankSpawnpoints[ 0 ].angles = ( 0, 129, 0 );
	level.tankSpawnpoints[ 0 ].radius = 32;
	level.tankSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 0 ].script_int = 2048;
	
	level.tankSpawnpoints[ 1 ] = spawnstruct();
	level.tankSpawnpoints[ 1 ].origin = ( 1285, -2074, 168 );
	level.tankSpawnpoints[ 1 ].angles = ( 0, 198, 0 );
	level.tankSpawnpoints[ 1 ].radius = 32;
	level.tankSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 1 ].script_int = 2048;
	
	level.tankSpawnpoints[ 2 ] = spawnstruct();
	level.tankSpawnpoints[ 2 ].origin = ( 1042, -2753, 51 );
	level.tankSpawnpoints[ 2 ].angles = ( 0, 142, 0 );
	level.tankSpawnpoints[ 2 ].radius = 32;
	level.tankSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 2 ].script_int = 2048;
	
	level.tankSpawnpoints[ 3 ] = spawnstruct();
	level.tankSpawnpoints[ 3 ].origin = ( 250, -2928, 62 );
	level.tankSpawnpoints[ 3 ].angles = ( 0, 81, 0 );
	level.tankSpawnpoints[ 3 ].radius = 32;
	level.tankSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 3 ].script_int = 2048;
	
	level.tankSpawnpoints[ 4 ] = spawnstruct();
	level.tankSpawnpoints[ 4 ].origin = ( 213, -2448, 52 );
	level.tankSpawnpoints[ 4 ].angles = ( 0, 259, 0 );
	level.tankSpawnpoints[ 4 ].radius = 32;
	level.tankSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 4 ].script_int = 2048;
	
	level.tankSpawnpoints[ 5 ] = spawnstruct();
	level.tankSpawnpoints[ 5 ].origin = ( -319, -2363, 112 );
	level.tankSpawnpoints[ 5 ].angles = ( 0, 328, 0 );
	level.tankSpawnpoints[ 5 ].radius = 32;
	level.tankSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 5 ].script_int = 2048;
	
	level.tankSpawnpoints[ 6 ] = spawnstruct();
	level.tankSpawnpoints[ 6 ].origin = ( 743, -2282, 51 );
	level.tankSpawnpoints[ 6 ].angles = ( 0, 350, 0 );
	level.tankSpawnpoints[ 6 ].radius = 32;
	level.tankSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 6 ].script_int = 2048;
	
	level.tankSpawnpoints[ 7 ] = spawnstruct();
	level.tankSpawnpoints[ 7 ].origin = ( 633, -2023, 235 );
	level.tankSpawnpoints[ 7 ].angles = ( 0, 143, 0 );
	level.tankSpawnpoints[ 7 ].radius = 32;
	level.tankSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.tankSpawnpoints[ 7 ].script_int = 2048;

	level.crazyplaceSpawnpoints = [];
	level.crazyplaceSpawnpoints[ 0 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 0 ].origin = ( 11164, -6942, -351 );
	level.crazyplaceSpawnpoints[ 0 ].angles = ( 0, 223, 0 );
	level.crazyplaceSpawnpoints[ 0 ].radius = 32;
	level.crazyplaceSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 0 ].script_int = 2048;
	
	level.crazyplaceSpawnpoints[ 1 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 1 ].origin = ( 11301, -7129, -351 );
	level.crazyplaceSpawnpoints[ 1 ].angles = ( 0, 206, 0 );
	level.crazyplaceSpawnpoints[ 1 ].radius = 32;
	level.crazyplaceSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 1 ].script_int = 2048;
	
	level.crazyplaceSpawnpoints[ 2 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 2 ].origin = ( 9531, -7056, -351 );
	level.crazyplaceSpawnpoints[ 2 ].angles = ( 0, 282, 0 );
	level.crazyplaceSpawnpoints[ 2 ].radius = 32;
	level.crazyplaceSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 2 ].script_int = 2048;
	
	level.crazyplaceSpawnpoints[ 3 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 3 ].origin = ( 9683, -7028, -345 );
	level.crazyplaceSpawnpoints[ 3 ].angles = ( 0, 255, 0 );
	level.crazyplaceSpawnpoints[ 3 ].radius = 32;
	level.crazyplaceSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 3 ].script_int = 2048;
	
	level.crazyplaceSpawnpoints[ 4 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 4 ].origin = ( 9469, -8501, -403 );
	level.crazyplaceSpawnpoints[ 4 ].angles = ( 0, 349, 0 );
	level.crazyplaceSpawnpoints[ 4 ].radius = 32;
	level.crazyplaceSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 4 ].script_int = 2048;
	
	level.crazyplaceSpawnpoints[ 5 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 5 ].origin = ( 9480, -8635, -397 );
	level.crazyplaceSpawnpoints[ 5 ].angles = ( 0, 9, 0 );
	level.crazyplaceSpawnpoints[ 5 ].radius = 32;
	level.crazyplaceSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 5 ].script_int = 2048;
	
	level.crazyplaceSpawnpoints[ 6 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 6 ].origin = ( 11198, -8728, -413 );
	level.crazyplaceSpawnpoints[ 6 ].angles = ( 0, 152, 0 );
	level.crazyplaceSpawnpoints[ 6 ].radius = 32;
	level.crazyplaceSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 6 ].script_int = 2048;
	
	level.crazyplaceSpawnpoints[ 7 ] = spawnstruct();
	level.crazyplaceSpawnpoints[ 7 ].origin = ( 11318, -8613, -412 );
	level.crazyplaceSpawnpoints[ 7 ].angles = ( 0, 150, 0 );
	level.crazyplaceSpawnpoints[ 7 ].radius = 32;
	level.crazyplaceSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.crazyplaceSpawnpoints[ 7 ].script_int = 2048;
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
		spawnpoint = maps\mp\zombies\_zm::check_for_valid_spawn_near_team( self, 1 );
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
		if ( isDefined( level.customMap ) && level.customMap == "trenches" )
		{
			for ( i = 0; i < level.trenchesSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.trenchesSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "excavation" )
		{
			for ( i = 0; i < level.excavationSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.excavationSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "tank" )
		{
			for ( i = 0; i < level.tankSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.tankSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "crazyplace" )
		{
			for ( i = 0; i < level.crazyplaceSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.crazyplaceSpawnpoints[ i ];
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
	self thread maps\mp\zombies\_zm::onplayerspawned();
	self thread maps\mp\zombies\_zm::player_revive_monitor();
	self freezecontrols( 1 );
	self.spectator_respawn = spawnpoint;
	self.score = self maps\mp\gametypes_zm\_globallogic_score::getpersstat( "score" );
	self.pers[ "participation" ] = 0;
	
	self.score_total = self.score;
	self.old_score = self.score;
	self.player_initialized = 0;
	self.zombification_time = 0;
	self.enabletext = 1;
	self thread maps\mp\zombies\_zm_blockers::rebuild_barrier_reward_reset();
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
			self delay_thread( 0.05, maps\mp\zombies\_zm::spawnspectator );
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
	if ( isDefined( level.customMap ) && level.customMap == "crazyplace" )
	{
		for ( i = 0; i < level.crazyplaceSpawnpoints.size; i++ )
		{
			custom_spawns[ custom_spawns.size ] = level.crazyplaceSpawnpoints[ i ];
		}
		return custom_spawns;
	}
	else if ( isDefined( level.customMap ) && level.customMap == "trenches" )
	{
		for ( i = 0; i < level.trenchesSpawnpoints.size; i++ )
		{
			custom_spawns[ custom_spawns.size ] = level.trenchesSpawnpoints[ i ];
		}
		return custom_spawns;
	}
	else if ( isDefined( level.customMap ) && level.customMap == "tank" )
	{
		for ( i = 0; i < level.tankSpawnpoints.size; i++ )
		{
			custom_spawns[ custom_spawns.size ] = level.tankSpawnpoints[ i ];
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