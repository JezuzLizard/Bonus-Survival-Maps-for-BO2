#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_transit_standard_station;
#include maps/mp/zombies/_zm_ai_avogadro;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps/mp/zombies/_zm_ai_avogadro::avogadro_spawning_logic, ::avogadro_spawning_logic);
	replacefunc(maps/mp/zm_transit_utility::solo_tombstone_removal, ::solo_tombstone_removal);
	replacefunc(maps/mp/zm_transit_classic::diner_hatch_access, ::diner_hatch_access);
	replacefunc(maps/mp/zm_transit_standard_farm::farm_treasure_chest_init, ::treasure_chest_init);
	replacefunc(maps/mp/zm_transit_standard_station::station_treasure_chest_init, ::treasure_chest_init);
	replacefunc(maps/mp/zm_transit_classic::init_bus, ::init_bus);
}

init()
{
	if(level.customMap == "vanilla")
		return;
	level thread override_zombie_count();
	flag_wait( "initial_blackscreen_passed" );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors(); //added to turn on the power and open doors
}

init_bus() //checked matches cerberus output
{
	flag_wait( "start_zombie_round_logic" );
}

treasure_chest_init()
{
	return;
}

avogadro_spawning_logic()
{
	return;
}

solo_tombstone_removal()
{
	return;
}

diner_hatch_access() //modified function
{
	diner_hatch = getent( "diner_hatch", "targetname" );
	diner_hatch_col = getent( "diner_hatch_collision", "targetname" );
	diner_hatch_mantle = getent( "diner_hatch_mantle", "targetname" );
	if ( !isDefined( diner_hatch ) || !isDefined( diner_hatch_col ) )
	{
		return;
	}
	diner_hatch hide();
	diner_hatch_mantle.start_origin = diner_hatch_mantle.origin;
	diner_hatch_mantle.origin += vectorScale( ( 0, 0, 0 ), 500 );
	diner_hatch show();
	diner_hatch_col delete();
	diner_hatch_mantle.origin = diner_hatch_mantle.start_origin;
	player maps/mp/zombies/_zm_buildables::track_placed_buildables( "dinerhatch" );
}

main_busdepot()
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "station" );
	level.enemy_location_override_func = ::enemy_location_override;
	collision = spawn( "script_model", ( -6896, 4744, 0 ), 1 );
	collision setmodel( "zm_collision_transit_busdepot_survival" );
	collision disconnectpaths();
	flag_wait( "initial_blackscreen_passed" );
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	zombie_doors = getentarray( "zombie_door", "targetname" );
	foreach ( door in zombie_doors )
	{
		if ( isDefined( door.script_noteworthy ) && door.script_noteworthy == "local_electric_door" )
		{
			door trigger_off();
		}
	}
}

override_zombie_count() //custom function
{
	level endon( "end_game" );
	level.speed_change_round = undefined;
	
	if( level.customMap == "house" || level.customMap == "cornfield" )
	{
		level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
	}
	thread increase_cornfield_zombie_speed();
	for ( ;; )
	{
		level waittill_any( "start_of_round", "intermission", "check_count" );
		level thread adjust_zombie_count();
		if ( level.customMap == "house" )
		{
			if ( level.round_number <= 2 )
			{
				level.zombie_move_speed = 20;
			}
		}
		else if ( level.customMap == "cornfield" )
		{
			if ( level.round_number == 1 )
			{
				level.zombie_move_speed = 20;
			}
			else if ( level.round_number <= 3 )
			{
				level.zombie_move_speed = 30;
			}
		}
	}
}

zombie_speed_up_distance_check()
{
	if ( distance( self.origin, self.closestPlayer.origin ) > 1000 )
	{
		return 1;
	}
	return 0;
}

increase_cornfield_zombie_speed()
{
	if ( level.customMap != "cornfield" && level.customMap != "house" )
	{
		return;
	}
	while ( 1 )
	{
		zombies = get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			zombies[ i ].closestPlayer = get_closest_valid_player( zombies[ i ].origin );
		}
		zombies = get_round_enemy_array();
		for ( i = 0; i < zombies.size; i++ )
		{
			if ( zombies[ i ] zombie_speed_up_distance_check() )
			{
				zombies[ i ] set_zombie_run_cycle( "chase_bus" );
			}
			else if ( zombies[ i ].zombie_move_speed != "sprint" )
			{
				zombies[ i ] set_zombie_run_cycle( "sprint" );
			}
		}
		wait 1;
	}
}

adjust_zombie_count() //custom function
{
	if ( level.players.size == 8 )
	{
		level.zombie_ai_limit = 32;
		level.zombie_vars["zombie_ai_per_player"] = 3;
	}
	else if ( level.players.size == 7 )
	{
		level.zombie_ai_limit = 30;
		level.zombie_vars["zombie_ai_per_player"] = 4;
	}
	else if ( level.players.size == 6 )
	{
		level.zombie_ai_limit = 28;
		level.zombie_vars["zombie_ai_per_player"] = 5;
	}
	else if ( level.players.size == 5 )
	{
		level.zombie_ai_limit = 26;
		level.zombie_vars["zombie_ai_per_player"] = 5;
	}
	else
	{
		level.zombie_ai_limit = 24;
		level.zombie_vars["zombie_ai_per_player"] = 6;
	}
}