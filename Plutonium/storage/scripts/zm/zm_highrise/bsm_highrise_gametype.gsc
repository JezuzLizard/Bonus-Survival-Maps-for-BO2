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
	level.redroomSpawnpoints = [];
	level.redroomSpawnpoints[ 0 ] = spawnstruct();
	level.redroomSpawnpoints[ 0 ].origin = ( 3358, 1359, 1488 );
	level.redroomSpawnpoints[ 0 ].angles = ( 0, 90, 0 );
	level.redroomSpawnpoints[ 0 ].radius = 32;
	level.redroomSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 0 ].script_int = 2048;

	level.redroomSpawnpoints[ 1 ] = spawnstruct();
	level.redroomSpawnpoints[ 1 ].origin = ( 3308, 1359, 1488 );
	level.redroomSpawnpoints[ 1 ].angles = ( 0, 90, 0 );
	level.redroomSpawnpoints[ 1 ].radius = 32;
	level.redroomSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 1 ].script_int = 2048;

	level.redroomSpawnpoints[ 2 ] = spawnstruct();
	level.redroomSpawnpoints[ 2 ].origin = ( 3258, 1359, 1488 );
	level.redroomSpawnpoints[ 2 ].angles = ( 0, 90, 0 );
	level.redroomSpawnpoints[ 2 ].radius = 32;
	level.redroomSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 2 ].script_int = 2048;

	level.redroomSpawnpoints[ 3 ] = spawnstruct();
	level.redroomSpawnpoints[ 3 ].origin = ( 3208, 1359, 1488 );
	level.redroomSpawnpoints[ 3 ].angles = ( 0, 90, 0 );
	level.redroomSpawnpoints[ 3 ].radius = 32;
	level.redroomSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 3 ].script_int = 2048;

	level.redroomSpawnpoints[ 4 ] = spawnstruct();
	level.redroomSpawnpoints[ 4 ].origin = ( 3266, 1718, 1488 );
	level.redroomSpawnpoints[ 4 ].angles = ( 0, 270, 0 );
	level.redroomSpawnpoints[ 4 ].radius = 32;
	level.redroomSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 4 ].script_int = 2048;

	level.redroomSpawnpoints[ 5 ] = spawnstruct();
	level.redroomSpawnpoints[ 5 ].origin = ( 3216, 1718, 1488 );
	level.redroomSpawnpoints[ 5 ].angles = ( 0, 270, 0 );
	level.redroomSpawnpoints[ 5 ].radius = 32;
	level.redroomSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 5 ].script_int = 2048;

	level.redroomSpawnpoints[ 6 ] = spawnstruct();
	level.redroomSpawnpoints[ 6 ].origin = ( 3166, 1718, 1488 );
	level.redroomSpawnpoints[ 6 ].angles = ( 0, 270, 0 );
	level.redroomSpawnpoints[ 6 ].radius = 32;
	level.redroomSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 6 ].script_int = 2048;

	level.redroomSpawnpoints[ 7 ] = spawnstruct();
	level.redroomSpawnpoints[ 7 ].origin = ( 3116, 1718, 1488 );
	level.redroomSpawnpoints[ 7 ].angles = ( 0, 270, 0 );
	level.redroomSpawnpoints[ 7 ].radius = 32;
	level.redroomSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
	level.redroomSpawnpoints[ 7 ].script_int = 2048;
}

init_barriers_for_custom_maps() //custom function
{
	if(isDefined(level.customMap) && level.customMap != "vanilla")
	{
		collision2 = Spawn( "script_model", (1195.34, 1281.47, 3392.13) + (0,50,0) );
		collision2 RotateTo((0,90,0), .1);
		collision2 SetModel( "zm_collision_perks1" );
		collision3 = Spawn( "script_model", (1195.34, 1281.47, 3392.13) + (0,-50,0) );
		collision3 RotateTo((0,90,0), .1);
		collision3 SetModel( "zm_collision_perks1" );
		building1topbarrier1 = Spawn("script_model", (2179.74, 1110.85, 3206.64));
		building1topbarrier1 SetModel("collision_player_wall_256x256x10");
		building1topbarrier1 RotateTo((0,0,0),.1);
		building1topbarrier2 = Spawn("script_model", (2248.78, 1541.87, 3350));
		building1topbarrier2 SetModel("collision_player_wall_256x256x10");
		building1topbarrier2 RotateTo((0,90,0),.1);
		elevatorbarrier1 = Spawn("script_model", (1651.49, 2168.44, 3392.01) + (0,0,32));
		elevatorbarrier1 SetModel("collision_player_wall_64x64x10");
		elevatorbarrier1 RotateTo((0,0,0),.1);
		elevatorbarrier2 = Spawn("script_model", (1958.84, 1676.59, 3391.99) + (0,0,32));
		elevatorbarrier2 SetModel("collision_player_wall_64x64x10");
		elevatorbarrier2 RotateTo((0,0,0),.1);
		elevatorbarrier3 = Spawn("script_model", (1957.68, 1676.22, 3216.03) + (0,0,32));
		elevatorbarrier3 SetModel("collision_player_wall_64x64x10");
		elevatorbarrier3 RotateTo((0,0,0),.1);
		elevatorbarrier4 = Spawn("script_model", (1475.31, 1218.09, 3218.16) + (0,0,32));
		elevatorbarrier4 SetModel("collision_player_wall_64x64x10");
		elevatorbarrier4 RotateTo((0,90,0),.1);
		elevatorbarrier5 = Spawn("script_model", (1647.22, 2171.76, 3215.57) + (0,0,32));
		elevatorbarrier5 SetModel("collision_player_wall_64x64x10");
		elevatorbarrier5 RotateTo((0,0,0),.1);
		elevatorbarrier6 = Spawn("script_model", (1647.7, 2167.82, 3040.09) + (0,0,32));
		elevatorbarrier6 SetModel("collision_player_wall_64x64x10");
		elevatorbarrier6 RotateTo((0,0,0),.1);

		redroombarrier1 = spawn("script_model", ( 3039, 806.27, 1121.68 ));
		redroombarrier1 setModel( "collision_player_wall_512x512x10" );
		redroombarrier1 rotateTo((0,151.5,0),.1);

		redroombarrier2 = spawn("script_model", ( 3342.63,  631, 1121.68 ));
		redroombarrier2 setModel( "collision_player_wall_512x512x10" );
		redroombarrier2 rotateTo((0,151.5,0),.1);

		redroombarrier3 = spawn("script_model", ( 2732, 980, 1121.68 ));
		redroombarrier3 setModel( "collision_player_wall_512x512x10" );
		redroombarrier3 rotateTo((0,151.5,0),.1);

		redroombarrier4 = spawn("script_model", ( 3039, 806.27, 1221.68 ));
		redroombarrier4 setModel( "collision_player_wall_512x512x10" );
		redroombarrier4 rotateTo((0,151.5,0),.1);

		redroombarrier5 = spawn("script_model", ( 3342.63,  631, 1221.68 ));
		redroombarrier5 setModel( "collision_player_wall_512x512x10" );
		redroombarrier5 rotateTo((0,151.5,0),.1);

		redroombarrier6 = spawn("script_model", ( 2732, 980, 1221.68 ));
		redroombarrier6 setModel( "collision_player_wall_512x512x10" );
		redroombarrier6 rotateTo((0,151.5,0),.1);
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
		//custom spawns here
		if ( isdefined( level.customMap ) && level.customMap == "redroom" )
		{
			for(i=0; i<level.redroomSpawnpoints.size;i++)
			{
				spawnpoints[spawnpoints.size] = level.redroomSpawnpoints[i];
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
	return player_spawns;
}