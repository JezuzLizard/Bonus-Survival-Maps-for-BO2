#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_blockers;
#include maps/mp/gametypes_zm/_hud_util;

main()
{
	if(GetDvar("zeGamemode") != "sharpshooter")
		return;
	replacefunc(maps/mp/zombies/_zm_score::minus_to_player_score, ::minus_to_player_score);
	replacefunc(maps/mp/zombies/_zm_score::player_reduce_points, ::player_reduce_points);
	replacefunc(maps/mp/zombies/_zm_magicbox::can_buy_weapon, ::can_buy_weapon);
	replacefunc(maps/mp/zombies/_zm::player_revive_monitor, ::player_revive_monitor);
	replacefunc(maps/mp/zombies/_zm::ai_calculate_health, ::ai_calculate_health);
}

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	level.round_wait_func = ::round_wait_override;
	level.round_think_func = ::round_think;
	level.playerlaststand_func = ::player_laststand;
	level.overrideplayerdamage = ::player_damage_override;
	level.round_start_delay = 0;
	level.zombie_vars["zombie_between_round_time"] = 0;
	level.zombie_vars[ "spectators_respawn" ] = 0;
	level.zombie_vars["zombie_powerup_drop_max_per_round"] = 100;
	level.zombie_vars["zombie_powerup_drop_increment"] = 750; //750 regular
	level.player_starting_points = 0;
	setdvar( "revive_trigger_radius", "0" );
	level.no_end_game_check = 1;
	level.using_bot_weapon_logic = 0;
	thread sharpshooter_timer();
	thread disableboxes();
}

round_think()
{
	if ( isDefined( level.initial_round_wait_func ) )
	{
		[[ level.initial_round_wait_func ]]();
	}
	foreach(player in get_players())
	{
		player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
	}
	for(;;)
	{
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
		{
			maxreward = 500;
		}
		level.zombie_vars[ "rebuild_barrier_cap_per_round" ] = maxreward;
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_start" );
		wait 2.5;
		maps/mp/zombies/_zm_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, ::rebuild_barrier_reward_reset );
		level.round_start_time = getTime();
		while ( level.zombie_spawn_locations.size <= 0 )
		{
			wait 0.1;
		}
		level thread [[ level.round_spawn_func ]]();
		level notify( "start_of_round" );
		recordzombieroundstart();
		players = getplayers();
		for ( index = 0; index < players.size; index++  )
		{
			zonename = players[ index ] get_current_zone();
			if ( isDefined( zonename ) )
			{
				players[ index ] recordzombiezone( "startingZone", zonename );
			}
		}
		if ( isDefined( level.round_start_custom_func ) )
		{
			[[ level.round_start_custom_func ]]();
		}
		[[ level.round_wait_func ]]();
		level.first_round = 0;
		level notify( "end_of_round" );
		level thread maps/mp/zombies/_zm_audio::change_zombie_music( "round_end" );
		uploadstats();
		if ( isDefined( level.round_end_custom_logic ) )
		{
			[[ level.round_end_custom_logic ]]();
		}
		players = get_players();
		if ( is_true( level.no_end_game_check ) )
		{
			level thread last_stand_revive();
			level thread spectators_respawn();
		}
		else if ( players.size != 1 )
		{
			level thread spectators_respawn();
		}
		timer = level.zombie_vars[ "zombie_spawn_delay" ];
		if ( timer > 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = timer * 0.95;
		}
		else if ( timer < 0.08 )
		{
			level.zombie_vars[ "zombie_spawn_delay" ] = 0.08;
		}
		if ( level.gamedifficulty == 0 )
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier_easy" ];
		}
		else
		{
			level.zombie_move_speed = level.round_number * level.zombie_vars[ "zombie_move_speed_multiplier" ];
		}
		level.round_number++;
		if ( level.round_number >= 255 )
		{
			level.round_number = 255;
		}
		matchutctime = getutc();
		players = get_players();
		foreach ( player in players )
		{
			if ( level.curr_gametype_affects_rank && level.round_number > 3 + level.start_round )
			{
				player maps/mp/zombies/_zm_stats::add_client_stat( "weighted_rounds_played", level.round_number );
			}
			player maps/mp/zombies/_zm_stats::set_global_stat( "rounds", level.round_number );
			player maps/mp/zombies/_zm_stats::update_playing_utc_time( matchutctime );
		}
		check_quickrevive_for_hotjoin();
		level round_over();
		level notify( "between_round_over" );
		restart = 0;
	}
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
	IPrintLnBold("SHARPSHOOTER");
	sharpshooter_timer = CreateServerFontString("Objective", 1);
	sharpshooter_timer SetPoint("LEFT", "BOTTOM_LEFT", -50, "CENTER");
	sharpshooter_timer.label = &"^1Time left until Switch: ^7";
	sharpshooter_timer.alpha = 1;
	weaponslist = array("m1911_zm", "fivesevendw_zm");
	if(level.script == "zm_prison")
		weaponslist = array_randomize(array("870mcs_zm", "barretm82_zm", "beretta93r_zm", "dsr50_zm",
			"fiveseven_zm", "fivesevendw_zm", "fnfal_zm", "galil_zm", "m14_zm", "ray_gun_zm",
			"raygun_mark2_zm",
			"ak47_zm", "blundergat_zm", "judge_zm", "lsat_zm", "m1911_zm","minigun_alcatraz_zm",
			"mp5k_zm", "pdw57_zm", "rottweil72_zm", "saiga12_zm", "tar21_zm", "thompson_zm",
			"usrpg_zm", "uzi_zm"));
	else if(level.script == "zm_transit")
		weaponslist = array_randomize(array("870mcs_zm", "barretm82_zm", "beretta93r_zm", "dsr50_zm",
			"fiveseven_zm", "fivesevendw_zm", "fnfal_zm", "galil_zm", "m14_zm", "ray_gun_zm",
			"raygun_mark2_zm",
			"ak74u_zm", "hamr_zm", "judge_zm", "knife_ballistic_zm", "kard_zm", "mp5k_zm",
			"m16_zm", "m1911_zm", "m32_zm", "python_zm", "qcw05_zm", "rottweil72_zm", "rpd_zm",
			"saritch_zm", "saiga12_zm", "srm1216_zm", "tar21_zm", "type95_zm", "xm8_zm"));
	else if(level.script == "zm_highrise")
		weaponslist = array_randomize(array("870mcs_zm", "barretm82_zm", "beretta93r_zm", "dsr50_zm",
			"fiveseven_zm", "fivesevendw_zm", "fnfal_zm", "galil_zm", "m14_zm", "ray_gun_zm",
			"raygun_mark2_zm",
			"ak74u_zm", "an94_zm", "hamr_zm", "judge_zm", "kard_zm", "m1911_zm", "m32_zm", "mp5k_zm",
			"pdw57_zm", "python_zm", "qcw05_zm", "rpd_zm", "rottweil72_zm", "saritch_zm", "slipgun_zm",
			"svu_zm", "saiga12_zm", "srm1216_zm", "tar21_zm", "type95_zm", "usrpg_zm", "xm8_zm"));
	else if(level.script == "zm_nuked")
		weaponslist = array_randomize(array("870mcs_zm", "barretm82_zm", "beretta93r_zm", "dsr50_zm",
			"fiveseven_zm", "fivesevendw_zm", "fnfal_zm", "galil_zm", "m14_zm", "ray_gun_zm",
			"raygun_mark2_zm",
			"ak74u_zm", "hamr_zm", "hk416_zm", "judge_zm", "kard_zm", "last_zm", "m16_zm", "m1911_zm",
			"m32_zm", "mp5k_zm", "python_zm", "qcw05_zm", "rpd_zm", "rottweil72_zm", "saritch_zm",
			"saiga12_zm", "srm1216_zm", "tar21_zm", "type95_zm", "usrpg_zm", "xm8_zm"));
	else if(level.script == "zm_buried")
		weaponslist = array_randomize(array("870mcs_zm", "barretm82_zm", "beretta93r_zm", "dsr50_zm",
			"fiveseven_zm", "fivesevendw_zm", "fnfal_zm", "galil_zm", "m14_zm", "ray_gun_zm",
			"raygun_mark2_zm",
			"ak74u_zm","an94_zm", "hamr_zm", "judge_zm", "knife_ballistic_zm", "kard_zm", "lsat_zm",
			"m1911_zm", "m32_zm", "pdw57_zm", "qcw05_zm", "rnma_zm", "rottweil72_zm", "saritch_zm",
			"slowgun_zm", "svu_zm", "srm1216_zm", "saiga12_zm", "tar21_zm", "usrpg_zm"));
	else if(level.script == "zm_tomb")
		weaponslist = array_randomize(array("870mcs_zm", "beretta93r_zm", "dsr50_zm",
			"fiveseven_zm", "fivesevendw_zm", "fnfal_zm", "galil_zm", "m14_zm", "ray_gun_zm",
			"raygun_mark2_zm",
			"ak74u_zm", "ballista_zm", "c96_zm", "evoskorpion_zm", "hamr_zm", "ksg_zm", "m32_zm", 
			"mg08_zm", "mp40_zm", "mp44_zm", "python_zm", "qcw05_zm", "scar_zm", "srm1216_zm", 
			"staff_air_zm", "staff_fire_zm", "staff_lightning_zm", "staff_water_zm", "thompson_zm", 
			"type95_zm", "pdw57_zm"));
	for(i=0;i<weaponslist.size;i++)
	{
		spawnAllPlayers();
		GiveNewWeapon(weaponslist[i]);
		IPrintLn(weaponslist[i]);
		time = 30;
		while(time > 0)
		{
			sharpshooter_timer SetValue(time);
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
	sharpshooter_timer.alpha = 0;
	foreach(player in get_players())
		player FreezeControls(1);
	level notify("end_game");
}

spawnAllPlayers()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].sessionstate == "spectator" && isDefined( players[ i ].spectator_respawn ) )
		{
			players[ i ] [[ level.spawnplayer ]]();
			if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			{
				thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
			}
		}
		i++;
	}
}

GiveNewWeapon(weapon)
{
	players = get_players();
	foreach(player in players)
	{
		player TakeAllWeapons();
		player GiveWeapon(weapon);
		player SwitchToWeapon(weapon);
		if(is_true(player.pers[ "isBot" ]))
			player SetSpawnWeapon(weapon);
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

player_damage_override( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime ) //checked changed to match cerberus output
{
	if ( isDefined( level._game_module_player_damage_callback ) )
	{
		self [[ level._game_module_player_damage_callback ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	idamage = self check_player_damage_callbacks( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	if ( is_true( self.use_adjusted_grenade_damage ) )
	{
		self.use_adjusted_grenade_damage = undefined;
		if ( self.health > idamage )
		{
			return idamage;
		}
	}
	if ( !idamage )
	{
		return 0;
	}
	if ( self maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
	{
		return 0;
	}
	if ( isDefined( einflictor ) )
	{
		if ( is_true( einflictor.water_damage ) )
		{
			return 0;
		}
	}
	if ( isDefined( eattacker ) && is_true( eattacker.is_zombie ) || isplayer( eattacker ) )
	{
		if ( is_true( self.hasriotshield ) && isDefined( vdir ) )
		{
			if ( is_true( self.hasriotshieldequipped ) )
			{
				if ( self player_shield_facing_attacker( vdir, 0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
			else if ( !isDefined( self.riotshieldentity ) )
			{
				if ( !self player_shield_facing_attacker( vdir, -0.2 ) && isDefined( self.player_shield_apply_damage ) )
				{
					self [[ self.player_shield_apply_damage ]]( 100, 0 );
					return 0;
				}
			}
		}
	}
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( self.ignoreattacker ) && self.ignoreattacker == eattacker )
		{
			return 0;
		}
		if ( is_true( self.is_zombie ) && is_true( eattacker.is_zombie ) )
		{
			return 0;
		}
		if ( is_true( eattacker.is_zombie ) )
		{
			self.ignoreattacker = eattacker;
			self thread remove_ignore_attacker();
			if ( isDefined( eattacker.custom_damage_func ) )
			{
				idamage = eattacker [[ eattacker.custom_damage_func ]]( self );
			}
			else if ( isDefined( eattacker.meleedamage ) )
			{
				idamage = eattacker.meleedamage;
			}
			else
			{
				idamage = 50;
			}
		}
		eattacker notify( "hit_player" );
		if ( smeansofdeath != "MOD_FALLING" )
		{
			self thread playswipesound( smeansofdeath, eattacker );
			//changed to match bo3 _zm.gsc
			if ( is_true( eattacker.is_zombie ) || isplayer( eattacker ) )
			{
				self playrumbleonentity( "damage_heavy" );
			}
			canexert = 1;
			if ( is_true( level.pers_upgrade_flopper ) )
			{
				if ( is_true( self.pers_upgrades_awarded[ "flopper" ] ) )
				{
					if ( smeansofdeath != "MOD_PROJECTILE_SPLASH" && smeansofdeath != "MOD_GRENADE" && smeansofdeath != "MOD_GRENADE_SPLASH" )
					{
						canexert = smeansofdeath;
					}
				}
			}
			if ( is_true( canexert ) )
			{
				if ( randomintrange( 0, 1 ) == 0 )
				{
					self thread maps/mp/zombies/_zm_audio::playerexert( "hitmed" );
				}
				else
				{
					self thread maps/mp/zombies/_zm_audio::playerexert( "hitlrg" );
				}
			}
		}
	}
	finaldamage = idamage;
	//checked changed to match bo1 _zombiemode.gsc
	if ( is_placeable_mine( sweapon ) || sweapon == "freezegun_zm" || sweapon == "freezegun_upgraded_zm" )
	{
		return 0;
	}
	if ( isDefined( self.player_damage_override ) )
	{
		self thread [[ self.player_damage_override ]]( einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime );
	}
	if ( smeansofdeath == "MOD_FALLING" )
	{
		if ( self hasperk( "specialty_flakjacket" ) && isDefined( self.divetoprone ) && self.divetoprone == 1 )
		{
			if ( isDefined( level.zombiemode_divetonuke_perk_func ) )
			{
				[[ level.zombiemode_divetonuke_perk_func ]]( self, self.origin );
			}
			return 0;
		}
		if ( is_true( level.pers_upgrade_flopper ) )
		{
			if ( self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_flopper_damage_check( smeansofdeath, idamage ) )
			{
				return 0;
			}
		}
	}
	//checked changed to match bo1 _zombiemode.gsc
	if ( smeansofdeath == "MOD_PROJECTILE" || smeansofdeath == "MOD_PROJECTILE_SPLASH" || smeansofdeath == "MOD_GRENADE" || smeansofdeath == "MOD_GRENADE_SPLASH" )
	{
		if ( self hasperk( "specialty_flakjacket" ) )
		{
			return 0;
		}
		if ( is_true( level.pers_upgrade_flopper ) )
		{
			if ( is_true( self.pers_upgrades_awarded[ "flopper" ] ) )
			{
				return 0;
			}
		}
		if ( self.health > 75 && !is_true( self.is_zombie ) )
		{
			return 75;
		}
	}
	if ( idamage < self.health )
	{
		if ( isDefined( eattacker ) )
		{
			if ( isDefined( level.custom_kill_damaged_vo ) )
			{
				eattacker thread [[ level.custom_kill_damaged_vo ]]( self );
			}
			else
			{
				eattacker.sound_damage_player = self;
			}
			if ( !is_true( eattacker.has_legs ) )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "crawl_hit" );
			}
			else if ( isDefined( eattacker.animname ) && eattacker.animname == "monkey_zombie" )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "monkey_hit" );
			}
		}
		return finaldamage;
	}
	if ( isDefined( eattacker ) )
	{
		if ( isDefined( eattacker.animname ) && eattacker.animname == "zombie_dog" )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "killed_by_zdog" );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "killed_by_zdog" );
		}
		else if ( isDefined( eattacker.is_avogadro ) && eattacker.is_avogadro )
		{
			self maps/mp/zombies/_zm_stats::increment_client_stat( "killed_by_avogadro", 0 );
			self maps/mp/zombies/_zm_stats::increment_player_stat( "killed_by_avogadro" );
		}
	}
	self thread clear_path_timers();
	if ( level.intermission )
	{
		level waittill( "forever" );
	}
	//changed from && to ||
	if ( self.lives > 0 || self hasperk( "specialty_finalstand" ) )
	{
		self.lives--;

		if ( isDefined( level.chugabud_laststand_func ) )
		{
			self thread [[ level.chugabud_laststand_func ]]();
			return 0;
		}
	}
	players = get_players();
	count = 0;
	//subtle changes in logic in the if statements
	for ( i = 0; i < players.size; i++ )
	{
		//count of dead players
		//checked changed to match bo1 _zombiemode.gsc
		if ( players[ i ] == self || players[ i ].is_zombie || players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ i ].sessionstate == "spectator" )
		{
			count++;
		}
	}
	//checked against bo3 _zm.gsc changed to match 
	if ( count < players.size || isDefined( level._game_module_game_end_check ) && ![[ level._game_module_game_end_check ]]() )
	{
		if ( isDefined( self.lives ) && self.lives > 0 && is_true( level.force_solo_quick_revive ) && self hasperk( "specialty_quickrevive" ) )
		{
			self thread wait_and_revive();
		}
		return finaldamage;
	}
	if ( !is_true( level.no_end_game_check ) )
	{
		level notify( "stop_suicide_trigger" );
		self thread maps/mp/zombies/_zm_laststand::playerlaststand( einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime );
		if ( !isDefined( vdir ) )
		{
			vdir = ( 1, 0, 0 );
		}
		self fakedamagefrom( vdir );
		if ( isDefined( level.custom_player_fake_death ) )
		{
			self thread [[ level.custom_player_fake_death ]]( vdir, smeansofdeath );
		}
		else
		{
			self thread player_fake_death();
		}
	}
	surface = "flesh";
	return finaldamage;
}

player_laststand( einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration ) //checked changed to match cerberus output //checked against bo3 _zm.gsc matches within reason
{
	b_alt_visionset = 0;
	self allowjump( 0 );
	currweapon = self getcurrentweapon();
	statweapon = currweapon;
	if ( is_alt_weapon( statweapon ) )
	{
		statweapon = weaponaltweaponname( statweapon );
	}
	self addweaponstat( statweapon, "deathsDuringUse", 1 );
	if ( is_true( self.hasperkspecialtytombstone ) )
	{
		self.laststand_perks = maps/mp/zombies/_zm_tombstone::tombstone_save_perks( self );
	}
	if ( isDefined( self.pers_upgrades_awarded[ "perk_lose" ] ) && self.pers_upgrades_awarded[ "perk_lose" ] )
	{
		self maps/mp/zombies/_zm_pers_upgrades_functions::pers_upgrade_perk_lose_save();
	}
	players = get_players();
	if ( self hasperk( "specialty_additionalprimaryweapon" ) )
	{
		self.weapon_taken_by_losing_specialty_additionalprimaryweapon = take_additionalprimaryweapon();
	}
	if ( is_true( self.hasperkspecialtytombstone ) )
	{
		self [[ level.tombstone_laststand_func ]]();
		self thread [[ level.tombstone_spawn_func ]]();
		self.hasperkspecialtytombstone = undefined;
		self notify( "specialty_scavenger_stop" );
	}
	self clear_is_drinking();
	self thread remove_deadshot_bottle();
	self thread remote_revive_watch();
	self maps/mp/zombies/_zm_score::player_downed_penalty();
	self disableoffhandweapons();
	self thread last_stand_grenade_save_and_return();
	if ( smeansofdeath != "MOD_SUICIDE" && smeansofdeath != "MOD_FALLING" )
	{
		if ( !is_true( self.intermission ) )
		{
			self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "revive_down" );
		}
		else
		{
			if ( isDefined( level.custom_player_death_vo_func ) &&  !self [[ level.custom_player_death_vo_func ]]() )
			{
				self maps/mp/zombies/_zm_audio::create_and_play_dialog( "general", "exert_death" );
			}
		}
	}
	bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "downed", self.origin );
	if ( isDefined( level._zombie_minigun_powerup_last_stand_func ) )
	{
		self thread [[ level._zombie_minigun_powerup_last_stand_func ]]();
	}
	if ( isDefined( level._zombie_tesla_powerup_last_stand_func ) )
	{
		self thread [[ level._zombie_tesla_powerup_last_stand_func ]]();
	}
	if ( self hasperk( "specialty_grenadepulldeath" ) )
	{
		b_alt_visionset = 1;
		if ( isDefined( level.custom_laststand_func ) )
		{
			self thread [[ level.custom_laststand_func ]]();
		}
	}
	if ( is_true( self.intermission ) )
	{
		bbprint( "zombie_playerdeaths", "round %d playername %s deathtype %s x %f y %f z %f", level.round_number, self.name, "died", self.origin );
		wait 0.5;
		self stopsounds();
		level waittill( "forever" );
	}
	if ( !b_alt_visionset )
	{
		visionsetlaststand( "zombie_last_stand", 1 );
	}
}

ai_calculate_health( round_number ) //checked changed to match cerberus output
{
	level.zombie_health = level.zombie_vars[ "zombie_health_start" ];
	i = 2;
	while ( i <= round_number )
	{
		if(i>10)
		{
			return;
		}
		level.zombie_health = int( level.zombie_health + level.zombie_vars[ "zombie_health_increase" ] );
		i++;
	}
}