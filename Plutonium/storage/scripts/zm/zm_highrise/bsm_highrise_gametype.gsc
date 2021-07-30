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
	override_map();
	init_spawnpoints_for_custom_survival_maps();
}

init()
{
	init_barriers_for_custom_maps();
	thread map_rotation();
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

getMapString(map) //custom function
{
	if(map == "tunnel")
		return "Tunnel";
	if(map == "diner")
		return "Diner";
	if(map == "power")
		return "Power Station";
	if(map == "house")
		return "Cabin";
	if(map == "cornfield")
		return "Cornfield";
	if(map == "docks")
		return "Docks";
	if(map == "cellblock")
		return "Cellblock";
	if(map == "rooftop")
		return "Rooftop/Bridge";
	if(map == "trenches")
		return "Trenches";
	if(map == "excavation")
		return "No Man's Land";
	if(map == "tank")
		return "Tank/Church";
	if(map == "crazyplace")
		return "Crazy Place";
	if(map == "vanilla")
		return "Vanilla";
}

override_map()
{
	mapname = ToLower( GetDvar( "mapname" ) );
	if( GetDvar("customMap") == "" )
		SetDvar("customMap", "vanilla");
	if ( isdefined(mapname) && mapname == "zm_transit" )
	{
		if ( GetDvar("customMap") != "tunnel" && GetDvar("customMap") != "diner" && GetDvar("customMap") != "power" && GetDvar("customMap") != "cornfield" && GetDvar("customMap") != "house" && GetDvar("customMap") != "vanilla" && GetDvar("customMap") != "town" && GetDvar("customMap") != "farm" && GetDvar("customMap") != "busdepot" )
		{
			SetDvar( "customMap", "house" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_nuked" )
	{
		if ( GetDvar("customMap") != "nuketown" && GetDvar("customMap") != "vanilla")
		{
			SetDvar("customMap", "nuketown");
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_highrise" )
	{
		if ( GetDvar("customMap") != "building1top" && GetDvar("customMap") != "vanilla" )
		{
			SetDvar( "customMap", "building1top" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_prison" )
	{
		if ( GetDvar("customMap") != "docks" && GetDvar("customMap") != "cellblock" && GetDvar("customMap") != "rooftop" && GetDvar("customMap") != "vanilla" )
		{
			SetDvar( "customMap", "docks" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_buried" )
	{
		if ( GetDvar("customMap") != "maze" && GetDvar("customMap") != "vanilla")
		{
			SetDvar( "customMap", "maze" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_tomb" )
	{
		if ( GetDvar("customMap") != "trenches" && GetDvar("customMap") != "crazyplace" && GetDvar("customMap") != "excavation" && GetDvar("customMap") != "vanilla" )
		{
			SetDvar( "customMap", "trenches" );
		}
	}
	map = ToLower(GetDvar("customMap"));
	if(map == "town" || map == "busdepot" || map == "farm" || map == "nuketown")
	{
		level.customMap = "vanilla";
	}
	else
	{
		level.customMap = map;
	}
}

map_rotation() //custom function
{
	level waittill( "end_game");
	wait 2;
	level.randomizeMapRotation = getDvarIntDefault( "randomizeMapRotation", 0 );
	level.customMapRotationActive = getDvarIntDefault( "customMapRotationActive", 0 );
	level.customMapRotation = getDvar( "customMapRotation" );
	level.mapList = strTok( level.customMapRotation, " " );
	if ( !level.customMapRotationActive )
	{
		return;
	}
	if ( !isDefined( level.customMapRotation ) || level.customMapRotation == "" )
	{
		level.customMapRotation = "nuketown cellblock trenches busdepot building1top maze";
	}
	if ( level.randomizeMapRotation && level.mapList.size > 3 )
	{
		level thread random_map_rotation();
		return;
	}
	for(i=0;i<level.mapList.size;i++)
	{
		if(isdefined(level.mapList[i+1]) && getDvar("customMap") == level.mapList[i])
		{
			changeMap(level.mapList[i+1]);
			return;
		}
	}
	changeMap(level.mapList[0]);
}

changeMap(map)
{
	if(!isdefined(map))
		map = GetDvar("customMap");
	SetDvar("customMap", map);
	if(map == "tunnel" || map == "diner" || map == "power" || map == "cornfield" || map == "house")
		SetDvar("sv_maprotation","exec zm_classic_transit.cfg map zm_transit");
	else if(map == "town")
		SetDvar("sv_maprotation","exec zm_standard_town.cfg map zm_transit");
	else if(map == "farm")
		SetDvar("sv_maprotation","exec zm_standard_farm.cfg map zm_transit");
	else if(map == "busdepot")
		SetDvar("sv_maprotation","exec zm_standard_transit.cfg map zm_transit");
	else if(map == "nuketown")
		SetDvar("sv_maprotation","exec zm_standard_nuked.cfg map zm_nuked");
	else if(map == "docks" || map == "cellblock" || map == "rooftop")
		SetDvar("sv_maprotation","exec zm_classic_prison.cfg map zm_prison");
	else if(map == "building1top")
		SetDvar("sv_maprotation", "exec zm_classic_rooftop.cfg map zm_highrise");
	else if(map == "maze")
		SetDvar("sv_maprotation", "exec zm_classic_processing.cfg map zm_buried");
	else if(map == "trenches" || map == "crazyplace")
		SetDvar("sv_maprotation", "exec zm_classic_tomb.cfg map zm_tomb");
}

random_map_rotation() //custom function
{
	level.nextMap = RandomInt( level.mapList.size );
	level.lastMap = getDvar( "lastMap" );
	if( getDvar("customMap") == level.mapList[ level.nextMap ] || level.mapList[ level.nextMap ] == level.lastMap )
	{
		return random_map_rotation();
	}
	else
	{
		setDvar( "lastMap", getDvar("customMap") );
		changeMap(level.mapList[ level.nextMap ]);
		return;
	}
}

init_spawnpoints_for_custom_survival_maps() //custom function
{
	level.disableBSMMagic = getDvarIntDefault("disableBSMMagic", 0);
	//TUNNEL
	
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
	//CUSTOM SPAWNS HERE
	return player_spawns;
}