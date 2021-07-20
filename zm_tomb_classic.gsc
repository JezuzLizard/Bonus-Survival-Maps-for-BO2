//checked includes match cerberus output
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zm_tomb_craftables;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

precache() //checked matches cerberus output
{
	if ( is_true( level.createfx_enabled ) )
	{
		return;
	}
	maps/mp/zombies/_zm_craftables::init();
	maps/mp/zm_tomb_craftables::randomize_craftable_spawns();
	maps/mp/zm_tomb_craftables::include_craftables();
	maps/mp/zm_tomb_craftables::init_craftables();
	level thread override_zombie_count();
}

main() //checked matches cerberus output
{
	maps/mp/gametypes_zm/_zm_gametype::setup_standard_objects( "tomb" );
	maps/mp/zombies/_zm_game_module::set_current_game_module( level.game_module_standard_index );
	level thread maps/mp/zombies/_zm_craftables::think_craftables();
	flag_wait( "initial_blackscreen_passed" );
	if(isdefined(level.customMap) && level.customMap == "crazyplace")
		thread openChamber();
	if(isdefined(level.customMap) && level.customMap == "trenches")
		thread deactivateTank();
}

zm_treasure_chest_init() //checked matches cerberus output
{
	if(isdefined(level.customMap) && level.customMap != "vanilla")
		return;
	chest1 = getstruct( "start_chest", "script_noteworthy" );
	level.chests = [];
	level.chests[ level.chests.size ] = chest1;
	maps/mp/zombies/_zm_magicbox::treasure_chest_init( "start_chest" );
}

openChamber()
{
	level endon("end_game");
	while(1)
	{
		level waittill("between_round_over");
		if(level.round_number >= 5)
		{
			IPrintLn("chamber_do_ting");
			flag_set( "any_crystal_picked_up" );
			break;
		}
	}
}

deactivateTank()
{
	trig = getentarray( "trig_tank_station_call", "targetname" );
	foreach(t in trig)
	{
		t disable_trigger();
	}
}

override_zombie_count() //custom function
{
	level endon( "end_game" );
	level.speed_change_round = undefined;
	thread increase_zombie_speed();
	for ( ;; )
	{
		level waittill_any( "start_of_round", "intermission", "check_count" );
		if ( isdefined(level.customMap) && level.customMap == "crazyplace" )
		{
			if ( level.round_number <= 2 )
			{
				level.zombie_move_speed = 20;
			}
		}
	}
}

increase_zombie_speed()
{
	if ( isdefined(level.customMap) && level.customMap != "crazyplace" )
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
			zombies[ i ] set_zombie_run_cycle( "sprint" );
		}
		wait 1;
	}
}
