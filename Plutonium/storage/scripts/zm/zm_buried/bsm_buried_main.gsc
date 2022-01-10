#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_buried_classic;

main()
{
	if(getDvar("customMap") == "vanilla")
		return;
	replacefunc(maps/mp/zm_buried_classic::zm_treasure_chest_init, ::zm_treasure_chest_init);
}

init()
{
	if(level.customMap == "vanilla")
		return;
	level thread override_zombie_count();
	level.zombie_weapons[ "time_bomb_zm" ].is_in_box = 0;
	if(is_true(level.customMap == "maze"))
	{
		thread maze_reset();
	}
}

maze_reset()
{
	level endon("end_game");
	while(1)
	{
		level waittill("between_round_over");
		if((level.round_number % 5) == 0)
		{
			level waittill("between_round_over");
			maps/mp/zm_buried_maze::maze_do_perm_change();
		}
	}
}

zm_treasure_chest_init()
{
	return;
}

override_zombie_count() //custom function
{
	level endon( "end_game" );
	level.speed_change_round = undefined;
	//thread increase_zombie_speed();
	for ( ;; )
	{
		level waittill_any( "start_of_round", "intermission", "check_count" );
		if ( isdefined(level.customMap) && level.customMap == "maze" )
		{
			if ( level.round_number <= 5 )
			{
				level.zombie_move_speed = 40;
			}
			else
			{
				level.zombie_move_speed = 80;
			}
		}
	}
}

increase_zombie_speed()
{
	if ( isdefined(level.customMap) && level.customMap != "maze" )
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
			zombies[ i ] set_zombie_run_cycle( "run" );
		}
		wait 1;
	}
}