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
	init_barriers_for_custom_maps();
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
	level.mazeSpawnpoints = [];
	level.mazeSpawnpoints[ 0 ] = spawnstruct();
	level.mazeSpawnpoints[ 0 ].origin = (6686.14, 870.338, 108.125);
	level.mazeSpawnpoints[ 0 ].angles = ( 0, 190, 0 );
	level.mazeSpawnpoints[ 0 ].radius = 32;
	level.mazeSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 0 ].script_int = 2048;
	
	level.mazeSpawnpoints[ 1 ] = spawnstruct();
	level.mazeSpawnpoints[ 1 ].origin = (6929.56, 789.857, 108.125);
	level.mazeSpawnpoints[ 1 ].angles = ( 0, 280, 0 );
	level.mazeSpawnpoints[ 1 ].radius = 32;
	level.mazeSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 1 ].script_int = 2048;
	
	level.mazeSpawnpoints[ 2 ] = spawnstruct();
	level.mazeSpawnpoints[ 2 ].origin = (6053.2, 568.066, 5.60614);
	level.mazeSpawnpoints[ 2 ].angles = ( 0, 180, 0 );
	level.mazeSpawnpoints[ 2 ].radius = 32;
	level.mazeSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 2 ].script_int = 2048;
	
	level.mazeSpawnpoints[ 3 ] = spawnstruct();
	level.mazeSpawnpoints[ 3 ].origin = (6376.86, 578.717, 108.125);
	level.mazeSpawnpoints[ 3 ].angles = ( 0, 180, 0 );
	level.mazeSpawnpoints[ 3 ].radius = 32;
	level.mazeSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 3 ].script_int = 2048;
	
	level.mazeSpawnpoints[ 4 ] = spawnstruct();
	level.mazeSpawnpoints[ 4 ].origin = (5113.05, 567.025, 11.132);
	level.mazeSpawnpoints[ 4 ].angles = ( 0, 180, 0 );
	level.mazeSpawnpoints[ 4 ].radius = 32;
	level.mazeSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 4 ].script_int = 2048;
	
	level.mazeSpawnpoints[ 5 ] = spawnstruct();
	level.mazeSpawnpoints[ 5 ].origin = (3742.08, 142.653, 4.125);
	level.mazeSpawnpoints[ 5 ].angles = ( 0, 50, 0 );
	level.mazeSpawnpoints[ 5 ].radius = 32;
	level.mazeSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 5 ].script_int = 2048;
	
	level.mazeSpawnpoints[ 6 ] = spawnstruct();
	level.mazeSpawnpoints[ 6 ].origin = (3715.18, 1001.04, 4.125);
	level.mazeSpawnpoints[ 6 ].angles = ( 0, 310, 0 );
	level.mazeSpawnpoints[ 6 ].radius = 32;
	level.mazeSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 6 ].script_int = 2048;
	
	level.mazeSpawnpoints[ 7 ] = spawnstruct();
	level.mazeSpawnpoints[ 7 ].origin = (3964.82, 570.998, 4.125);
	level.mazeSpawnpoints[ 7 ].angles = ( 0, 0, 0 );
	level.mazeSpawnpoints[ 7 ].radius = 32;
	level.mazeSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.mazeSpawnpoints[ 7 ].script_int = 2048;
}

init_barriers_for_custom_maps() //custom function
{
	if(isDefined(level.customMap) && level.customMap != "vanilla")
	{
		mansion_clip1 = Spawn( "script_model", (3546.72, 264.696, 47.2424) + (0,0,128) );
		mansion_clip1 RotateTo((0,90,0), .1);
		mansion_clip1 SetModel( "collision_player_wall_256x256x10" );
		mansion_clip2 = Spawn( "script_model", (3470.43, 1064.11, 61.5909) + (0,0,128) );
		mansion_clip2 RotateTo((0,90,0), .1);
		mansion_clip2 SetModel( "collision_player_wall_256x256x10" );
		gazebo_clip1 = Spawn( "script_model", (6500.32, 575.174, 124.087) + (0,0,64) );
		gazebo_clip1 RotateTo((0,90,0), .1);
		gazebo_clip1 SetModel( "collision_player_wall_128x128x10" );
		gazebo_clip2 = Spawn( "script_model", (6676.68, 791.984, 113.475) + (0,0,32) );
		gazebo_clip2 RotateTo((0,0,0), .1);
		gazebo_clip2 SetModel( "collision_player_wall_64x64x10" );
		gazebo_clip3 = Spawn( "script_model", (6932.09, 541.876, 116.221) + (0,0,32) );
		gazebo_clip3 RotateTo((0,90,0), .1);
		gazebo_clip3 SetModel( "collision_player_wall_64x64x10" );
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
		if ( isdefined( level.customMap ) && level.customMap == "maze" )
		{
			for(i=0; i<level.mazeSpawnpoints.size;i++)
			{
				spawnpoints[spawnpoints.size] = level.mazeSpawnpoints[i];
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
	if( isdefined( level.customMap ) && level.customMap == "maze" )
	{
		for(i=0;i<level.mazeSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.mazeSpawnpoints[i];
		}
		return custom_spawns;
	}
	return player_spawns;
}