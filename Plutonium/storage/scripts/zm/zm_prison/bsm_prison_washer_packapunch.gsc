#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_alcatraz_sq;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/zombies/_zm_weapons;

main()
{
	if(GetDvar("customMap") != "showers")
		return;
	replacefunc(maps/mp/zm_alcatraz_sq::setup_dryer_challenge, ::setup_dryer_challenge);
}

setup_dryer_challenge()
{
	t_dryer = getent( "dryer_trigger", "targetname" );
	t_dryer setcursorhint( "HINT_NOICON" );
	t_dryer sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", 5000 );
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
		if ( level.zombie_total < n_zombie_count_min )
		{
			level.zombie_total = n_zombie_count_min;
		}
		maps/mp/zombies/_zm_ai_brutus::brutus_spawn_in_zone( "cellblock_shower" );
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
	flag_clear("dryer_cycle_active");
}


dryer_trigger_thread()
{
	dryer_model = GetEnt("dryer_model", "targetname");
	while(1)
	{
		self.pack_player = undefined;
		self.cost = 5000;
		n_dryer_cycle_duration = 20;
		a_dryer_spawns = [];
		sndent = spawn( "script_origin", ( 1613, 10599, 1203 ) );
		self waittill( "trigger", player );
		index = maps/mp/zombies/_zm_weapons::get_player_index( player );
		current_weapon = player getcurrentweapon();
		current_weapon = player maps/mp/zombies/_zm_weapons::switch_from_alt_weapon( current_weapon );
		if ( isDefined( level.custom_pap_validation ) )
		{
			valid = self [[ level.custom_pap_validation ]]( player );
			if ( !valid )
			{
				continue;
			}
		}
		if ( player maps/mp/zombies/_zm_magicbox::can_buy_weapon() && !player maps/mp/zombies/_zm_laststand::player_is_in_laststand() && !is_true( player.intermission ) || player isthrowinggrenade() && !player maps/mp/zombies/_zm_weapons::can_upgrade_weapon( current_weapon ) )
		{
			wait 0.1;
			continue;
		}
		if ( is_true( level.pap_moving ) )
		{
			continue;
		}
		if ( player isswitchingweapons() )
		{
			wait 0.1;
			if ( player isswitchingweapons() )
			{
				continue;
			}
		}
		if ( !maps/mp/zombies/_zm_weapons::is_weapon_or_base_included( current_weapon ) )
		{
			continue;
		}
		current_cost = self.cost;
		player.restore_ammo = undefined;
		player.restore_clip = undefined;
		player.restore_stock = undefined;
		player_restore_clip_size = undefined;
		player.restore_max = undefined;
		upgrade_as_attachment = will_upgrade_weapon_as_attachment( current_weapon );
		if ( upgrade_as_attachment )
		{
			current_cost = self.attachment_cost;
			player.restore_ammo = 1;
			player.restore_clip = player getweaponammoclip( current_weapon );
			player.restore_clip_size = weaponclipsize( current_weapon );
			player.restore_stock = player getweaponammostock( current_weapon );
			player.restore_max = weaponmaxammo( current_weapon );
		}
		if ( player maps/mp/zombies/_zm_pers_upgrades_functions::is_pers_double_points_active() )
		{
			current_cost = player maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_double_points_cost( current_cost );
		}
		if ( player.score < current_cost ) 
		{
			self playsound( "deny" );
			if ( isDefined( level.custom_pap_deny_vo_func ) )
			{
				player [[ level.custom_pap_deny_vo_func ]]();
			}
			else
			{
				player maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "perk_deny", undefined, 0 );
			}
			continue;
		}
		
		self.pack_player = player;
		flag_set( "pack_machine_in_use" );
		maps/mp/_demo::bookmark( "zm_player_use_packapunch", getTime(), player );
		player maps/mp/zombies/_zm_stats::increment_client_stat( "use_pap" );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "use_pap" );
		self thread destroy_weapon_in_blackout( player );
		self thread destroy_weapon_on_disconnect( player );
		player maps/mp/zombies/_zm_score::minus_to_player_score( current_cost, 1 );
		sound = "evt_bottle_dispense";
		playsoundatposition( sound, self.origin );
		self thread maps/mp/zombies/_zm_audio::play_jingle_or_stinger( "mus_perks_packa_sting" );
		player maps/mp/zombies/_zm_audio::create_and_play_dialog( "weapon_pickup", "upgrade_wait" );
		self trigger_off();
		if ( !is_true( upgrade_as_attachment ) )
		{
			player thread do_player_general_vox( "general", "pap_wait", 10, 100 );
		}
		else
		{
			player thread do_player_general_vox( "general", "pap_wait2", 10, 100 );
		}
		player thread do_knuckle_crack();
		self.current_weapon = current_weapon;
		self.upgrade_name = maps/mp/zombies/_zm_weapons::get_upgrade_weapon( current_weapon, upgrade_as_attachment );
		//WASHING MACHINE STUFF	
		//level setclientfield( "dryer_stage", 2 );
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
		flag_set( "dryer_cycle_active" );
		level clientnotify( "fxanim_dryer_start" );
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
		//level setclientfield( "dryer_stage", 1 );
		stop_exploder( 900 );
		stop_exploder( 1000 );
		sndent thread delaysndenddelete();
		self trigger_on();
		self sethintstring( &"ZOMBIE_GET_UPGRADED" );
		if ( isDefined( player ) )
		{
			self setinvisibletoall();
			self setvisibletoplayer( player );
			self thread wait_for_player_to_take( player, current_weapon, upgrade_as_attachment );
		}
		self thread wait_for_timeout( current_weapon, player );
		self waittill_any( "pap_timeout", "pap_taken", "pap_player_disconnected" );
		self.current_weapon = "";
		if ( is_true( level.zombiemode_reusing_pack_a_punch ) )
		{
			self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH_ATT", self.cost );
		}
		else
		{
			self sethintstring( &"ZOMBIE_PERK_PACKAPUNCH", self.cost );
		}
		self setvisibletoall();
		self.pack_player = undefined;
		flag_clear( "pack_machine_in_use" );
		level clientnotify( "fxanim_dryer_hide_start" );
		//level clientnotify( "fxanim_dryer_start" );
		//level clientnotify( "fxanim_dryer_idle_start" );
	}
}

wait_for_timeout( weapon, player ) //checked //checked matches cerberus output
{
	self endon( "pap_taken" );
	self endon( "pap_player_disconnected" );
	self thread wait_for_disconnect( player );
	wait 15;
	self notify( "pap_timeout" );
	maps/mp/zombies/_zm_weapons::unacquire_weapon_toggle( weapon );
	if ( isDefined( player ) )
	{
		player maps/mp/zombies/_zm_stats::increment_client_stat( "pap_weapon_not_grabbed" );
		player maps/mp/zombies/_zm_stats::increment_player_stat( "pap_weapon_not_grabbed" );
	}
}

wait_for_player_to_take( player, weapon, upgrade_as_attachment ) //changed 3/30/20 4:22 pm //checked matches cerberus output
{
	current_weapon = self.current_weapon;
	upgrade_name = self.upgrade_name;
	/*
/#
	assert( isDefined( current_weapon ), "wait_for_player_to_take: weapon does not exist" );
#/
/#
	assert( isDefined( upgrade_name ), "wait_for_player_to_take: upgrade_weapon does not exist" );
#/
	*/
	upgrade_weapon = upgrade_name;
	self endon( "pap_timeout" );
	level endon( "Pack_A_Punch_off" );
	while ( 1 )
	{
		self waittill( "trigger", trigger_player );
		if ( trigger_player == player ) //working
		{
			player maps/mp/zombies/_zm_stats::increment_client_stat( "pap_weapon_grabbed" );
			player maps/mp/zombies/_zm_stats::increment_player_stat( "pap_weapon_grabbed" );
			current_weapon = player getcurrentweapon();
			/*
/#
			if ( current_weapon == "none" )
			{
				iprintlnbold( "WEAPON IS NONE, PACKAPUNCH RETRIEVAL DENIED" );
#/
			}
			*/
			if ( is_player_valid( player ) && !player.is_drinking && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" && !player hacker_active() )
			{
				maps/mp/_demo::bookmark( "zm_player_grabbed_packapunch", getTime(), player );
				self notify( "pap_taken" );
				player notify( "pap_taken" );
				player.pap_used = 1;
				if ( !is_true( upgrade_as_attachment ) )
				{
					player thread do_player_general_vox( "general", "pap_arm", 15, 100 );
				}
				else
				{
					player thread do_player_general_vox( "general", "pap_arm2", 15, 100 );
				}
				weapon_limit = get_player_weapon_limit( player );
				player maps/mp/zombies/_zm_weapons::take_fallback_weapon();
				primaries = player getweaponslistprimaries();
				if ( isDefined( primaries ) && primaries.size >= weapon_limit )
				{
					player maps/mp/zombies/_zm_weapons::weapon_give( upgrade_weapon );
				}
				else
				{
					player giveweapon( upgrade_weapon, 0, player maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
					player givestartammo( upgrade_weapon );
				}
				player switchtoweapon( upgrade_weapon );
				if ( is_true( player.restore_ammo ) )
				{
					new_clip = player.restore_clip + ( weaponclipsize( upgrade_weapon ) - player.restore_clip_size );
					new_stock = player.restore_stock + ( weaponmaxammo( upgrade_weapon ) - player.restore_max );
					player setweaponammostock( upgrade_weapon, new_stock );
					player setweaponammoclip( upgrade_weapon, new_clip );
				}
				player.restore_ammo = undefined;
				player.restore_clip = undefined;
				player.restore_stock = undefined;
				player.restore_max = undefined;
				player.restore_clip_size = undefined;
				player maps/mp/zombies/_zm_weapons::play_weapon_vo( upgrade_weapon );
				return;
			}
		}
		//wait 0.05;
	}
}