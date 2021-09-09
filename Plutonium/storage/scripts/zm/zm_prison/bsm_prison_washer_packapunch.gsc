#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_alcatraz_sq;

main()
{
	replacefunc(maps/mp/zm_alcatraz_sq::setup_dryer_challenge, ::setup_dryer_challenge);
}

setup_dryer_challenge()
{
	t_dryer = getent( "dryer_trigger", "targetname" );
	t_dryer setcursorhint( "HINT_NOICON" );
	t_dryer sethintstring( &"ZM_PRISON_LAUNDRY_MACHINE_ACTIVATE" );
	t_dryer thread dryer_trigger_thread();
	t_dryer thread dryer_zombies_thread();
	t_dryer trigger_off();
	wait 2;
	level setclientfield( "dryer_stage", 1 );
	t_dryer trigger_on();
	t_dryer playsound( "evt_dryer_rdy_bell" );
}

dryer_zombies_thread()
{
	while(1)
	{
		n_zombie_count_min = 20;
		e_shower_zone = getent( "cellblock_shower", "targetname" );
		flag_wait( "dryer_cycle_active" );
		if ( level.round_number > 4 || isDefined( level.is_forever_solo_game ) && level.is_forever_solo_game )
		{
			if ( level.zombie_total < n_zombie_count_min )
			{
				level.zombie_total = n_zombie_count_min;
			}
			while ( flag( "dryer_cycle_active" ) )
			{
				a_zombies_in_shower = [];
				a_zombies_in_shower = get_zombies_touching_volume( "axis", "cellblock_shower", undefined );
				if ( a_zombies_in_shower.size < n_zombie_count_min )
				{
					e_zombie = get_farthest_available_zombie( e_shower_zone );
					if ( isDefined( e_zombie ) && !isinarray( a_zombies_in_shower, e_zombie ) )
					{
						e_zombie notify( "zapped" );
						e_zombie thread dryer_teleports_zombie();
					}
				}
				wait 1;
			}
		}
		else maps/mp/zombies/_zm_ai_brutus::brutus_spawn_in_zone( "cellblock_shower" );
	}
	flag_clear("dryer_cycle_active");
}


dryer_trigger_thread()
{
	while(1)
	{
		n_dryer_cycle_duration = 30;
		a_dryer_spawns = [];
		sndent = spawn( "script_origin", ( 1613, 10599, 1203 ) );
		self waittill( "trigger" );
		self trigger_off();
		level setclientfield( "dryer_stage", 2 );
		dryer_playerclip = getent( "dryer_playerclip", "targetname" );
		dryer_playerclip moveto( dryer_playerclip.origin + vectorScale( ( 0, 0, 0 ), 104 ), 0,05 );
		if ( isDefined( level.music_override ) && !level.music_override )
		{
			level notify( "sndStopBrutusLoop" );
			level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "laundry_defend" );
		}
		exploder( 1000 );
		sndent thread snddryercountdown( n_dryer_cycle_duration );
		sndent playsound( "evt_dryer_start" );
		sndent playloopsound( "evt_dryer_lp" );
		level clientnotify( "fxanim_dryer_start" );
		flag_set( "dryer_cycle_active" );
		wait 1;
		sndset = sndmusicvariable();
		level clientnotify( "fxanim_dryer_idle_start" );
		i = 3;
		while ( i > 0 )
		{
			wait ( n_dryer_cycle_duration / 3 );
			i--;
		}
		level clientnotify( "fxanim_dryer_end_start" );
		wait 2;
		flag_clear( "dryer_cycle_active" );
		sndent stoploopsound();
		sndent playsound( "evt_dryer_stop" );
		if ( isDefined( sndset ) && sndset )
		{
			level.music_override = 0;
		}
		level setclientfield( "dryer_stage", 1 );
		stop_exploder( 900 );
		stop_exploder( 1000 );
		sndent thread delaysndenddelete();
		self trigger_on();
	}
}