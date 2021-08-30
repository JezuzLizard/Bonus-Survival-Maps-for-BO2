#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	if(GetDvar("zeGamemode") != "sharpshooter")
		return;
	replacefunc(maps/mp/zombies/_zm_score::minus_to_player_score, ::minus_to_player_score);
	replacefunc(maps/mp/zombies/_zm_score::player_reduce_points, ::player_reduce_points);
	replacefunc(maps/mp/zombies/_zm_magicbox::can_buy_weapon, ::can_buy_weapon);
	replacefunc(maps/mp/zombies/_zm::player_revive_monitor, ::player_revive_monitor);
}

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	level.round_wait_func = ::round_wait_override;
	level.round_start_delay = 0;
	level.zombie_vars["zombie_between_round_time"] = 0;
	level.zombie_vars["zombie_powerup_drop_max_per_round"] = 100;
	level.zombie_vars["zombie_powerup_drop_increment"] = 10;
	level.player_starting_points = 0;
	setdvar( "revive_trigger_radius", "0" );
	level.no_end_game_check = 1;
	thread sharpshooter_timer();
	thread disableboxes();
}

round_wait_override()
{
	level endon("restart_round");
	level endon( "kill_round" );

	wait( 1 );

	while( 1 )
	{
		if( get_current_zombie_count() <= 0 || level.zombie_total <= 0 )
		{
			return;
		}			
			
		if( flag( "end_round_wait" ) )
		{
			return;
		}
		wait( 1.0 );
	}
}

sharpshooter_timer()
{
	level endon("end_game");
	level waittill("start_of_round");
	bot = AddTestClient();
	weaponslist = array_randomize(array("ray_gun_zm", "raygun_mark2_zm", "pdw57_zm", "m1911_zm", "m14_zm"));
	for(i=0;i<weaponslist.size;i++)
	{
		GiveNewWeapon(weaponslist[i]);
		time = 30;
		while(time > 0)
		{
			IPrintLn(time);
			refill_ammo_stock();
			if(checkforalldead())
			{
				time = 0;
			}
			time--;
			wait 1;
		}
		kill_all_zambs();
		maps/mp/gametypes_zm/_zm_gametype::revive_laststand_players();
	}
	IPrintLnBold("Winner Winner Chicken Dinner");
	level notify("end_game");
}

GiveNewWeapon(weapon)
{
	players = get_players();
	foreach(player in players)
	{
		player TakeAllWeapons();
		player GiveWeapon(weapon);
	}
}

checkforalldead() //checked changed to match cerberus output
{
	players = get_players();
	count = 0;
	i = 0;
	while ( i < players.size )
	{
		if ( !players[i] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && players[ i ].sessionstate != "spectator" )
		{
			count++;
		}
		i++;
	}
	if(count == 0)
		return 1;
	return 0;
}

kill_all_zambs()
{
	zombies = getaiarray( level.zombie_team );
	zombies_nuked = [];
	i = 0;
	while ( i < zombies.size )
	{
		if( !zombies[ i ] no_zombie_close_to_players() )
		{
			IPrintLn("KILL");
			zombies[i] DoDamage(zombies[i].health + 666, zombies[ i ].origin );
		}
		i++;
	}
}

no_zombie_close_to_players()
{
	for(i=0;i<get_players().size;i++)
	{
		if( Distance(self.origin, get_players()[i].origin) < 200 )
		{
			return 0;
		}
	}
	return 1;
}

refill_ammo_stock()
{
	for(i=0;i<get_players().size;i++)
	{
		primary_weapons = get_players()[i] GetWeaponsListPrimaries();
		j=0;
		while(j<primary_weapons.size)
		{
			get_players()[ i ] GiveMaxAmmo(primary_weapons[ j ]);
			j++;
		}
	}
}

minus_to_player_score( points, ignore_double_points_upgrade ) //checked matches cerberus output
{
	return;
}

disableboxes()
{
	foreach(chest in level.chests)
		chest maps/mp/zombies/_zm_magicbox::hide_chest();
}

can_buy_weapon() //checked matches cerberus output
{
	return 0;
}

player_revive_monitor() //checked matches cerberus output
{
	return;
}

player_reduce_points( event, mod, hit_location ) //checked matches cerberus output
{
	return;
}