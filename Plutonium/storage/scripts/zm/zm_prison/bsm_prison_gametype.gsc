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
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::game_objects_allowed, ::game_objects_allowed);
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::onspawnplayer, ::onspawnplayer);
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype, ::get_player_spawns_for_gametype);
	init_spawnpoints_for_custom_survival_maps();
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
	level.docksSpawnpoints = [];
	level.docksSpawnpoints[ 0 ] = spawnstruct();
	level.docksSpawnpoints[ 0 ].origin = ( -335, 5512, -71 );
	level.docksSpawnpoints[ 0 ].angles = ( 0, -169, 0 );
	level.docksSpawnpoints[ 0 ].radius = 32;
	level.docksSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 0 ].script_int = 2048;
	
	level.docksSpawnpoints[ 1 ] = spawnstruct();
	level.docksSpawnpoints[ 1 ].origin = ( -589, 5452, -71 );
	level.docksSpawnpoints[ 1 ].angles = ( 0, -78, 0 );
	level.docksSpawnpoints[ 1 ].radius = 32;
	level.docksSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 1 ].script_int = 2048;
	
	level.docksSpawnpoints[ 2 ] = spawnstruct();
	level.docksSpawnpoints[ 2 ].origin = ( -1094, 5426, -71 );
	level.docksSpawnpoints[ 2 ].angles = ( 0, 170, 0 );
	level.docksSpawnpoints[ 2 ].radius = 32;
	level.docksSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 2 ].script_int = 2048;
	
	level.docksSpawnpoints[ 3 ] = spawnstruct();
	level.docksSpawnpoints[ 3 ].origin = ( -1200, 5882, -71 );
	level.docksSpawnpoints[ 3 ].angles = ( 0, -107, 0 );
	level.docksSpawnpoints[ 3 ].radius = 32;
	level.docksSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 3 ].script_int = 2048;
	
	level.docksSpawnpoints[ 4 ] = spawnstruct();
	level.docksSpawnpoints[ 4 ].origin = ( 669, 6785, 209 );
	level.docksSpawnpoints[ 4 ].angles = ( 0, -143, 0 );
	level.docksSpawnpoints[ 4 ].radius = 32;
	level.docksSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 4 ].script_int = 2048;
	
	level.docksSpawnpoints[ 5 ] = spawnstruct();
	level.docksSpawnpoints[ 5 ].origin = ( 476, 6774, 196 );
	level.docksSpawnpoints[ 5 ].angles = ( 0, -90, 0 );
	level.docksSpawnpoints[ 5 ].radius = 32;
	level.docksSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 5 ].script_int = 2048;
	
	level.docksSpawnpoints[ 6 ] = spawnstruct();
	level.docksSpawnpoints[ 6 ].origin = ( 699, 6562, 208 );
	level.docksSpawnpoints[ 6 ].angles = ( 0, 159, 0 );
	level.docksSpawnpoints[ 6 ].radius = 32;
	level.docksSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 6 ].script_int = 2048;
	
	level.docksSpawnpoints[ 7 ] = spawnstruct();
	level.docksSpawnpoints[ 7 ].origin = ( 344, 6472, 264 );
	level.docksSpawnpoints[ 7 ].angles = ( 0, 26, 0 );
	level.docksSpawnpoints[ 7 ].radius = 32;
	level.docksSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.docksSpawnpoints[ 7 ].script_int = 2048;
	
	level.cellblockSpawnpoints = [];
	level.cellblockSpawnpoints[ 0 ] = spawnstruct();
	level.cellblockSpawnpoints[ 0 ].origin = ( 954, 10521, 1338 );
	level.cellblockSpawnpoints[ 0 ].angles = ( 0, 12, 0 );
	level.cellblockSpawnpoints[ 0 ].radius = 32;
	level.cellblockSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 0 ].script_int = 2048;
	
	level.cellblockSpawnpoints[ 1 ] = spawnstruct();
	level.cellblockSpawnpoints[ 1 ].origin = ( 977, 10649, 1338 );
	level.cellblockSpawnpoints[ 1 ].angles = ( 0, 45, 0 );
	level.cellblockSpawnpoints[ 1 ].radius = 32;
	level.cellblockSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 1 ].script_int = 2048;
	
	level.cellblockSpawnpoints[ 2 ] = spawnstruct();
	level.cellblockSpawnpoints[ 2 ].origin = ( 1118, 10498, 1338 );
	level.cellblockSpawnpoints[ 2 ].angles = ( 0, 90, 0 );
	level.cellblockSpawnpoints[ 2 ].radius = 32;
	level.cellblockSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 2 ].script_int = 2048;
	
	level.cellblockSpawnpoints[ 3 ] = spawnstruct();
	level.cellblockSpawnpoints[ 3 ].origin = ( 1435, 10591, 1338 );
	level.cellblockSpawnpoints[ 3 ].angles = ( 0, 90, 0 );
	level.cellblockSpawnpoints[ 3 ].radius = 32;
	level.cellblockSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 3 ].script_int = 2048;
	
	level.cellblockSpawnpoints[ 4 ] = spawnstruct();
	level.cellblockSpawnpoints[ 4 ].origin = ( 1917, 10376, 1338 );
	level.cellblockSpawnpoints[ 4 ].angles = ( 0, 69, 0 );
	level.cellblockSpawnpoints[ 4 ].radius = 32;
	level.cellblockSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 4 ].script_int = 2048;
	
	level.cellblockSpawnpoints[ 5 ] = spawnstruct();
	level.cellblockSpawnpoints[ 5 ].origin = ( 2025, 10362, 1338 );
	level.cellblockSpawnpoints[ 5 ].angles = ( 0, 121, 0 );
	level.cellblockSpawnpoints[ 5 ].radius = 32;
	level.cellblockSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 5 ].script_int = 2048;
	
	level.cellblockSpawnpoints[ 6 ] = spawnstruct();
	level.cellblockSpawnpoints[ 6 ].origin = ( 2090, 10426, 1338 );
	level.cellblockSpawnpoints[ 6 ].angles = ( 0, 121, 0 );
	level.cellblockSpawnpoints[ 6 ].radius = 32;
	level.cellblockSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 6 ].script_int = 2048;
	
	level.cellblockSpawnpoints[ 7 ] = spawnstruct();
	level.cellblockSpawnpoints[ 7 ].origin = ( 1758, 10562, 1338 );
	level.cellblockSpawnpoints[ 7 ].angles = ( 0, 180, 0 );
	level.cellblockSpawnpoints[ 7 ].radius = 32;
	level.cellblockSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.cellblockSpawnpoints[ 7 ].script_int = 2048;
	
	level.rooftopSpawnpoints = [];
	level.rooftopSpawnpoints[ 0 ] = spawnstruct();
	level.rooftopSpawnpoints[ 0 ].origin = ( 2708, 9596, 1714 );
	level.rooftopSpawnpoints[ 0 ].angles = ( 0, 328, 0 );
	level.rooftopSpawnpoints[ 0 ].radius = 32;
	level.rooftopSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 0 ].script_int = 2048;
	
	level.rooftopSpawnpoints[ 1 ] = spawnstruct();
	level.rooftopSpawnpoints[ 1 ].origin = ( 2875, 9596, 1706 );
	level.rooftopSpawnpoints[ 1 ].angles = ( 0, 275, 0 );
	level.rooftopSpawnpoints[ 1 ].radius = 32;
	level.rooftopSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 1 ].script_int = 2048;
	
	level.rooftopSpawnpoints[ 2 ] = spawnstruct();
	level.rooftopSpawnpoints[ 2 ].origin = ( 3125.5, 9461.5, 1706 );
	level.rooftopSpawnpoints[ 2 ].angles = ( 0, 70, 0 );
	level.rooftopSpawnpoints[ 2 ].radius = 32;
	level.rooftopSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 2 ].script_int = 2048;
	
	level.rooftopSpawnpoints[ 3 ] = spawnstruct();
	level.rooftopSpawnpoints[ 3 ].origin = ( 3408, 9512.5, 1706 );
	level.rooftopSpawnpoints[ 3 ].angles = ( 0, 133, 0 );
	level.rooftopSpawnpoints[ 3 ].radius = 32;
	level.rooftopSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 3 ].script_int = 2048;
	
	level.rooftopSpawnpoints[ 4 ] = spawnstruct();
	level.rooftopSpawnpoints[ 4 ].origin = ( 3421, 9803.5, 1706 );
	level.rooftopSpawnpoints[ 4 ].angles = ( 0, 229, 0 );
	level.rooftopSpawnpoints[ 4 ].radius = 32;
	level.rooftopSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 4 ].script_int = 2048;
	
	level.rooftopSpawnpoints[ 5 ] = spawnstruct();
	level.rooftopSpawnpoints[ 5 ].origin = ( 3168, 9807, 1706 );
	level.rooftopSpawnpoints[ 5 ].angles = ( 0, 295, 0 );
	level.rooftopSpawnpoints[ 5 ].radius = 32;
	level.rooftopSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 5 ].script_int = 2048;
	
	level.rooftopSpawnpoints[ 6 ] = spawnstruct();
	level.rooftopSpawnpoints[ 6 ].origin = ( 2900, 9731.5, 1706 );
	level.rooftopSpawnpoints[ 6 ].angles = ( 0, 68, 0 );
	level.rooftopSpawnpoints[ 6 ].radius = 32;
	level.rooftopSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 6 ].script_int = 2048;
	
	level.rooftopSpawnpoints[ 7 ] = spawnstruct();
	level.rooftopSpawnpoints[ 7 ].origin = ( 2589, 9731.5, 1706 );
	level.rooftopSpawnpoints[ 7 ].angles = ( 0, 36, 0 );
	level.rooftopSpawnpoints[ 7 ].radius = 32;
	level.rooftopSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.rooftopSpawnpoints[ 7 ].script_int = 2048;

	level.showersSpawnpoints = [];
	level.showersSpawnpoints[ 0 ] = spawnstruct();
	level.showersSpawnpoints[ 0 ].origin = (1659.41, 9084.87, 1144.13);
	level.showersSpawnpoints[ 0 ].angles = ( 0, 63, 0 );
	level.showersSpawnpoints[ 0 ].radius = 32;
	level.showersSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 0 ].script_int = 2048;
	
	level.showersSpawnpoints[ 1 ] = spawnstruct();
	level.showersSpawnpoints[ 1 ].origin = (2059.66, 9093.35, 1144.13);
	level.showersSpawnpoints[ 1 ].angles = ( 0, 127, 0 );
	level.showersSpawnpoints[ 1 ].radius = 32;
	level.showersSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 1 ].script_int = 2048;
	
	level.showersSpawnpoints[ 2 ] = spawnstruct();
	level.showersSpawnpoints[ 2 ].origin = (2153.44, 9566.08, 1144.13);
	level.showersSpawnpoints[ 2 ].angles = ( 0, 155, 0 );
	level.showersSpawnpoints[ 2 ].radius = 32;
	level.showersSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 2 ].script_int = 2048;
	
	level.showersSpawnpoints[ 3 ] = spawnstruct();
	level.showersSpawnpoints[ 3 ].origin = (2156.9, 10068.7, 1152.13);
	level.showersSpawnpoints[ 3 ].angles = ( 0, 205, 0 );
	level.showersSpawnpoints[ 3 ].radius = 32;
	level.showersSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 3 ].script_int = 2048;
	
	level.showersSpawnpoints[ 4 ] = spawnstruct();
	level.showersSpawnpoints[ 4 ].origin = (1943.4, 9769.12, 1149.46);
	level.showersSpawnpoints[ 4 ].angles = ( 0, 21, 0 );
	level.showersSpawnpoints[ 4 ].radius = 32;
	level.showersSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 4 ].script_int = 2048;
	
	level.showersSpawnpoints[ 5 ] = spawnstruct();
	level.showersSpawnpoints[ 5 ].origin = (2060.05, 10354.2, 1144.13);
	level.showersSpawnpoints[ 5 ].angles = ( 0, 242, 0 );
	level.showersSpawnpoints[ 5 ].radius = 32;
	level.showersSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 5 ].script_int = 2048;
	
	level.showersSpawnpoints[ 6 ] = spawnstruct();
	level.showersSpawnpoints[ 6 ].origin = (1608.47, 10308, 1144.13);
	level.showersSpawnpoints[ 6 ].angles = ( 0, 308, 0 );
	level.showersSpawnpoints[ 6 ].radius = 32;
	level.showersSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 6 ].script_int = 2048;
	
	level.showersSpawnpoints[ 7 ] = spawnstruct();
	level.showersSpawnpoints[ 7 ].origin = (1781.52, 9561.23, 1152.13);
	level.showersSpawnpoints[ 7 ].angles = ( 0, 242, 0 );
	level.showersSpawnpoints[ 7 ].radius = 32;
	level.showersSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.showersSpawnpoints[ 7 ].script_int = 2048;
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
		if ( isDefined( level.customMap ) && level.customMap == "docks" )
		{
			for ( i = 0; i < level.docksSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.docksSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "showers" )
		{
			for ( i = 0; i < level.showersSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.showersSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "cellblock" )
		{
			for ( i = 0; i < level.cellblockSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.cellblockSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "rooftop" )
		{
			for ( i = 0; i < level.rooftopSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.rooftopSpawnpoints[ i ];
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
	if( isDefined( level.customMap ) && level.customMap == "docks")
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
	else if( isDefined( level.customMap ) && level.customMap == "showers")
	{
		for(i=0;i<level.showersSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.showersSpawnpoints[i];
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
	return player_spawns;
}