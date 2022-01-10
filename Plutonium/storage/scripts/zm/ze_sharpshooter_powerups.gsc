#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_hud_util;

main()
{
	if(GetDvar("zeGamemode") != "sharpshooter")
		return;
	include_powerup( "free_perk" );
	include_powerup( "weapon_upgrade" );
	include_powerup( "invis_zomb" );
	include_powerup( "snail" );
	include_powerup( "bottom_clip" );
	include_powerup( "broken_gun" );
	replacefunc(maps/mp/zombies/_zm_powerups::init_powerups, ::init_powerups);
	replacefunc(maps/mp/zombies/_zm_powerups::get_next_powerup, ::get_next_powerup);
	replacefunc(maps/mp/zombies/_zm_powerups::powerup_grab, ::powerup_grab);
	replacefunc(maps/mp/zombies/_zm_powerups::double_points_powerup, ::double_points_powerup);
	replacefunc(maps/mp/zombies/_zm_perks::give_random_perk, ::give_random_perk);
	replacefunc(maps/mp/zombies/_zm_spawner::zombie_death_points, ::zombie_death_points);
	replacefunc(maps/mp/zombies/_zm_powerups::free_perk_powerup, ::free_perk_powerup);
	replacefunc(maps/mp/zombies/_zm_score::get_points_multiplier, ::get_points_multiplier);
}

init_powerups() //checked matches cerberus output
{
	flag_init( "zombie_drop_powerups" );
	if ( is_true( level.enable_magic ) )
	{
		flag_set( "zombie_drop_powerups" );
	}
	if ( !isDefined( level.active_powerups ) )
	{
		level.active_powerups = [];
	}
	if ( !isDefined( level.zombie_powerup_array ) )
	{
		level.zombie_powerup_array = [];
	}
	if ( !isDefined( level.zombie_special_drop_array ) )
	{
		level.zombie_special_drop_array = [];
	}
	onplayerconnect_callback(::create_legacy_hud);
	if(level.script == "zm_prison" || level.script == "zm_nuked")
		perk_powerup_model = "t6_wpn_zmb_perk_bottle_doubletap_world";
	else
		perk_powerup_model = "zombie_pickup_perk_bottle";
	add_zombie_powerup( "nuke", "zombie_bomb", &"ZOMBIE_POWERUP_NUKE", ::func_should_never_drop, 0, 0, 0, "misc/fx_zombie_mini_nuke_hotness" );
	add_zombie_powerup( "insta_kill", "zombie_skull", &"ZOMBIE_POWERUP_INSTA_KILL", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_instant_kill", "zombie_powerup_insta_kill_time", "zombie_powerup_insta_kill_on" );
	add_zombie_powerup( "full_ammo", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "double_points", "zombie_x2_icon", &"ZOMBIE_POWERUP_DOUBLE_POINTS", ::func_should_always_drop, 1, 0, 0, undefined, "powerup_double_points", "zombie_powerup_point_doubler_time", "zombie_powerup_point_doubler_on" );
	add_zombie_powerup( "carpenter", "zombie_carpenter", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "fire_sale", "zombie_firesale", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_fire_sale", "zombie_powerup_fire_sale_time", "zombie_powerup_fire_sale_on" );
	add_zombie_powerup( "bonfire_sale", "zombie_pickup_bonfire", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_bon_fire", "zombie_powerup_bonfire_sale_time", "zombie_powerup_bonfire_sale_on" );
	add_zombie_powerup( "minigun", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_mini_gun", "zombie_powerup_minigun_time", "zombie_powerup_minigun_on" );
	add_zombie_powerup( "free_perk", perk_powerup_model, &"ZOMBIE_POWERUP_FREE_PERK", ::func_should_never_drop, 1, 0, 0 );
	add_zombie_powerup( "tesla", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_tesla", "zombie_powerup_tesla_time", "zombie_powerup_tesla_on" );
	add_zombie_powerup( "random_weapon", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 1, 0, 0 );
	add_zombie_powerup( "bonus_points_player", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", ::func_should_never_drop, 1, 0, 0 );
	add_zombie_powerup( "bonus_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_BONUS_POINTS", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "lose_points_team", "zombie_z_money_icon", &"ZOMBIE_POWERUP_LOSE_POINTS", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "lose_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "empty_clip", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 1 );
	add_zombie_powerup( "insta_kill_ug", "zombie_skull", &"ZOMBIE_POWERUP_INSTA_KILL", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_instant_kill_ug", "zombie_powerup_insta_kill_ug_time", "zombie_powerup_insta_kill_ug_on", 5000 );
	if ( isDefined( level.level_specific_init_powerups ) )
	{
		[[ level.level_specific_init_powerups ]]();
	}
	randomize_powerups();
	level.zombie_powerup_index = 0;
	randomize_powerups();
	level.rare_powerups_active = 0;
	level.firesale_vox_firstime = 0;
	level thread powerup_hud_monitor();
	if ( isDefined( level.quantum_bomb_register_result_func ) )
	{
		[[ level.quantum_bomb_register_result_func ]]( "random_powerup", ::quantum_bomb_random_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
		[[ level.quantum_bomb_register_result_func ]]( "random_zombie_grab_powerup", ::quantum_bomb_random_zombie_grab_powerup_result, 5, level.quantum_bomb_in_playable_area_validation_func );
		[[ level.quantum_bomb_register_result_func ]]( "random_weapon_powerup", ::quantum_bomb_random_weapon_powerup_result, 60, level.quantum_bomb_in_playable_area_validation_func );
		[[ level.quantum_bomb_register_result_func ]]( "random_bonus_or_lose_points_powerup", ::quantum_bomb_random_bonus_or_lose_points_powerup_result, 25, level.quantum_bomb_in_playable_area_validation_func );
	}
	registerclientfield( "scriptmover", "powerup_fx", 1000, 3, "int" );
}

create_legacy_hud()
{
	self.dp_pwp_hud = self CreateFontString("Objective", 1.25);
	self.dp_pwp_hud SetPoint("CENTER", "BOTTOM", "CENTER", -15);
	self.dp_pwp_hud.label = &"Double Points: ";
	self.dp_pwp_hud.alpha = 0;
}

get_next_powerup() //checked matches cerberus output
{
	powerup = level.zombie_powerup_array[ 0 ];
	randomize_powerups();
	return powerup;
}

powerup_grab(powerup_team) //checked partially changed to match cerberus output
{
	if ( isdefined( self ) && self.zombie_grabbable )
	{
		self thread powerup_zombie_grab( powerup_team );
		return;
	}

	self endon ( "powerup_timedout" );
	self endon ( "powerup_grabbed" );

	range_squared = 4096;
	while ( isdefined( self ) )
	{
		players = get_players();
		i = 0;
		while ( i < players.size )
		{
			// Don't let them grab the minigun, tesla, or random weapon if they're downed or reviving
			//	due to weapon switching issues.
			if ( ( self.powerup_name == "minigun" || self.powerup_name == "tesla" ) && players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() || players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() && ( self.powerup_name == "random_weapon" || self.powerup_name == "meat_stink" ) || players[ i ] usebuttonpressed() && players[ i ] in_revive_trigger() )
			{
				i++;
				continue;
			}
			if ( !is_true( self.can_pick_up_in_last_stand ) && players[ i ] maps/mp/zombies/_zm_laststand::player_is_in_laststand() )
			{
				i++;
				continue;
			}
			if ( self.powerup_name == "free_perk" && !players[ i ] can_have_perk() )
			{
				i++;
				continue;
			}
			ignore_range = 0;
			if ( isdefined( players[ i ].ignore_range_powerup ) && players[ i ].ignore_range_powerup == self )
			{
				players[ i ].ignore_range_powerup = undefined;
				ignore_range = 1;
			}
			if ( DistanceSquared( players[ i ].origin, self.origin ) < range_squared || ignore_range )
			{
				if ( isdefined(level._powerup_grab_check ) )
				{
					if ( !self [[ level._powerup_grab_check ]]( players[ i ] ) )
					{
						i++;
						continue;
					}
				}
				else if ( isdefined( level.zombie_powerup_grab_func ) )
				{
					level thread [[ level.zombie_powerup_grab_func ]]();
					break;
				}
				switch ( self.powerup_name )
				{
					case "nuke":
						level thread nuke_powerup( self, players[ i ].team );
						players[ i ] thread powerup_vo( "nuke" );
						zombies = getaiarray( level.zombie_team );
						players[ i ].zombie_nuked = arraysort( zombies, self.origin );
						players[ i ] notify( "nuke_triggered" );
						break;
					case "full_ammo":
						level thread full_ammo_powerup( self ,players[ i ] );
						players[ i ] thread powerup_vo( "full_ammo" );
						break;
					case "double_points":
						level thread double_points_powerup( self, players[ i ] );
						players[ i ] thread powerup_vo( "double_points" );
						break;
					case "insta_kill":
						level thread insta_kill_powerup( self,players[ i ] );
						players[ i ] thread powerup_vo( "insta_kill" );
						break;
					case "carpenter":
						if ( is_classic() )
						{
							players[ i ] thread maps/mp/zombies/_zm_pers_upgrades::persistent_carpenter_ability_check();
						}
						if ( isdefined( level.use_new_carpenter_func ) )
						{
							level thread [[ level.use_new_carpenter_func ]]( self.origin );
						}
						else
						{
							level thread start_carpenter( self.origin );
						}
						players[ i ] thread powerup_vo( "carpenter" );
						break;
					case "fire_sale":
						level thread start_fire_sale( self );
						players[ i ] thread powerup_vo( "firesale" );
						break;
					case "bonfire_sale":
						level thread start_bonfire_sale( self );
						players[ i ] thread powerup_vo( "firesale" );
						break;	
					case "minigun":
						level thread minigun_weapon_powerup( players[ i ] );
						players[ i ] thread powerup_vo( "minigun" );
						break;
					case "free_perk":
						level thread free_perk_powerup( self, players[i] );
						break;
					case "tesla":
						level thread tesla_weapon_powerup( players[ i ] );
						players[ i ] thread powerup_vo( "tesla" ); 
						break;
					case "random_weapon":
						if ( !level random_weapon_powerup( self, players[ i ] ) )
						{
							i++;
							continue;
						}
						break;
					case "bonus_points_player":
						level thread bonus_points_player_powerup( self, players[ i ] );
						players[ i ] thread powerup_vo( "bonus_points_solo" ); 
						break;
					case "bonus_points_team":
						level thread bonus_points_team_powerup( self );
						players[ i ] thread powerup_vo( "bonus_points_team" ); 
						break;
					case "teller_withdrawl":
						level thread teller_withdrawl( self ,players[ i ] );
						break;
					case "weapon_upgrade":
						level thread scripts/zm/ze_pack_powerup::weapon_upgrade_powerup( self, players[i] );
						break;
					case "invis_zomb":
						level thread scripts/zm/ze_invis_zombie_powerup::invis_zomb_powerup( self, players[i] );
						break;
					case "snail":
						level thread scripts/zm/ze_snail_powerup::snail_powerup( self, players[i] );
						break;
					case "broken_gun":
						level thread scripts/zm/ze_broken_gun_powerup::broken_gun_powerup( self, players[i] );
						break;
					case "bottom_clip":
						level thread scripts/zm/ze_bottom_clip_powerup::bottom_clip_powerup( self, players[i] );
						break;
					default:
						if ( IsDefined( level._zombiemode_powerup_grab ) )
						{
							level thread [[ level._zombiemode_powerup_grab ]]( self, players[ i ] );
						}
						break;	
				}
				
				maps\mp\_demo::bookmark( "zm_player_powerup_grabbed", gettime(), players[ i ] );

				if( should_award_stat ( self.powerup_name )) //don't do this for things that aren't really a powerup
				{
					//track # of picked up powerups/drops for the player
					players[i] maps/mp/zombies/_zm_stats::increment_client_stat( "drops" );
					players[i] maps/mp/zombies/_zm_stats::increment_player_stat( "drops" );
					players[i] maps/mp/zombies/_zm_stats::increment_client_stat( self.powerup_name + "_pickedup" );
					players[i] maps/mp/zombies/_zm_stats::increment_player_stat( self.powerup_name + "_pickedup" );
				}
				
				if ( self.solo )
				{
					playfx( level._effect[ "powerup_grabbed_solo" ], self.origin );
					playfx( level._effect[ "powerup_grabbed_wave_solo" ], self.origin );
				}
				else if ( self.caution )
				{
					playfx( level._effect[ "powerup_grabbed_caution" ], self.origin );
					playfx( level._effect[ "powerup_grabbed_wave_caution" ], self.origin );
				}
				else
				{
					playfx( level._effect[ "powerup_grabbed" ], self.origin );
					playfx( level._effect[ "powerup_grabbed_wave" ], self.origin );
				}

				if ( is_true( self.stolen ) )
				{
					level notify( "monkey_see_monkey_dont_achieved" );
				}
				if ( isdefined( self.grabbed_level_notify ) )
				{
					level notify( self.grabbed_level_notify );
				}

				// RAVEN BEGIN bhackbarth: since there is a wait here, flag the powerup as being taken 
				self.claimed = true;
				self.power_up_grab_player = players[ i ]; //Player who grabbed the power up
				// RAVEN END

				wait 0.1 ;
				
				playsoundatposition("zmb_powerup_grabbed", self.origin);
				self stoploopsound();
				self hide();
				
				//Preventing the line from playing AGAIN if fire sale becomes active before it runs out
				if ( self.powerup_name != "fire_sale" )
				{
					if ( isdefined( self.power_up_grab_player ) )
					{
						if ( isdefined( level.powerup_intro_vox ) )
						{
							level thread [[ level.powerup_intro_vox ]]( self );
							return;
						}
						else if ( isdefined( level.powerup_vo_available ) )
						{
							can_say_vo = [[ level.powerup_vo_available ]]();
							if ( !can_say_vo )
							{
								self powerup_delete();
								self notify( "powerup_grabbed" );
								return;
							}
						}
					}
				}
				level thread maps/mp/zombies/_zm_audio_announcer::leaderdialog( self.powerup_name, self.power_up_grab_player.pers[ "team" ] );
				self powerup_delete();
				self notify( "powerup_grabbed" );
			}
			i++;
		}
		wait 0.1;
	}
}

zombie_death_points( origin, mod, hit_location, attacker, zombie, team ) //checked matches cerberus output
{
	if ( !isDefined( attacker ) || !isplayer( attacker ) )
	{
		return;
	}
	if ( zombie_can_drop_powerups( zombie ) )
	{
		if ( isDefined( zombie.in_the_ground ) && zombie.in_the_ground == 1 )
		{
			trace = bullettrace( zombie.origin + vectorScale( ( 0, 0, 1 ), 100 ), zombie.origin + vectorScale( ( 0, 0, 0 ), -100 ), 0, undefined );
			origin = trace[ "position" ];
			level thread zombie_delay_powerup_drop( origin, attacker );
		}
		else
		{
			trace = groundtrace( zombie.origin + vectorScale( ( 0, 0, 1 ), 5 ), zombie.origin + vectorScale( ( 0, 0, 0 ), -300 ), 0, undefined );
			origin = trace[ "position" ];
			level thread zombie_delay_powerup_drop( origin, attacker );
		}
	}
	level thread maps/mp/zombies/_zm_audio::player_zombie_kill_vox( hit_location, attacker, mod, zombie );
	event = "death";
	if ( isDefined( zombie.damageweapon ) && issubstr( zombie.damageweapon, "knife_ballistic_" ) || mod == "MOD_MELEE" && mod == "MOD_IMPACT" )
	{
		event = "ballistic_knife_death";
	}
	if ( is_true( zombie.deathpoints_already_given ) )
	{
		return;
	}
	zombie.deathpoints_already_given = 1;
	if ( isDefined( zombie.damageweapon ) && is_equipment( zombie.damageweapon ) )
	{
		return;
	}
	attacker maps/mp/zombies/_zm_score::player_add_points( event, mod, hit_location, undefined, team, attacker.currentweapon );
}

zombie_delay_powerup_drop( origin, attacker ) //checked matches cerberus output
{
	wait_network_frame(); 
	level thread maps/mp/zombies/_zm_powerups::powerup_drop( origin );
	if(attacker perks_available() && RandomInt(8) == 0 )
		level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "free_perk", origin );
}

perks_available()
{
	vending_triggers = scripts/zm/bsm_main::getperks();
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ];
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if ( perk == "specialty_weapupgrade" || perk == "specialty_scavenger" || perk == "specialty_quickrevive" || perk == "specialty_finalstand" || perk == "specialty_additionalprimaryweapon" )
		{
			i++;
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
		{
			perks[ perks.size ] = perk;
		}
		i++;
	}
	if(perks.size > 0)
		return 1;
	return 0;
}

free_perk_powerup( item, player ) //checked changed to match cerberus output
{
	player maps/mp/zombies/_zm_perks::give_random_perk();
}

give_random_perk() //checked partially changed to match cerberus output
{
	random_perk = undefined;
	vending_triggers = scripts/zm/bsm_main::getperks();
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ];
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if ( perk == "specialty_weapupgrade" || perk == "specialty_scavenger" || perk == "specialty_quickrevive" || perk == "specialty_finalstand" || perk == "specialty_additionalprimaryweapon" )
		{
			i++;
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
		{
			perks[ perks.size ] = perk;
		}
		i++;
	}
	if ( perks.size > 0 )
	{
		perks = array_randomize( perks );
		random_perk = perks[ 0 ];
		self give_perk( random_perk );
	}
	else
	{
		self playsoundtoplayer( level.zmb_laugh_alias, self );
	}
	return random_perk;
}

can_have_perk()
{
	random_perk = undefined;
	vending_triggers = scripts/zm/bsm_main::getperks();
	perks = [];
	i = 0;
	while ( i < vending_triggers.size )
	{
		perk = vending_triggers[ i ];
		if ( isDefined( self.perk_purchased ) && self.perk_purchased == perk )
		{
			i++;
			continue;
		}
		if ( perk == "specialty_weapupgrade" || perk == "specialty_scavenger" || perk == "specialty_quickrevive" || perk == "specialty_finalstand" || perk == "specialty_additionalprimaryweapon" )
		{
			i++;
			continue;
		}
		if ( !self hasperk( perk ) && !self has_perk_paused( perk ) )
		{
			perks[ perks.size ] = perk;
		}
		i++;
	}
	if(perks.size > 0)
		return 1;
	return 0;
}

double_points_powerup( drop_item, player ) //checked partially matches cerberus output did not change
{
	level notify( "powerup points scaled_" + player.name );
	level endon( "powerup points scaled_" + player.name );
	//level thread point_doubler_on_hud( drop_item, player );
	player.shDoublePoints = 1;
	player setclientfield( "score_cf_double_points_active", 1 );
	time = 30;
	player.dp_pwp_hud.alpha = 1;
	while(time > 0)
	{
		player.dp_pwp_hud SetValue(Int(time));
		wait 1;
		time--;
	}
	player.dp_pwp_hud.alpha = 0;
	player.shDoublePoints = 0;
	player setclientfield( "score_cf_double_points_active", 0 );
}

point_doubler_on_hud( drop_item, player_team ) //checked matches cerberus output
{
	self endon( "disconnect" );
	if ( level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_on" ] )
	{
		level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_time" ] = 30;
		return;
	}
	level.zombie_vars[ player_team ][ "zombie_powerup_point_doubler_on" ] = 1;
	level thread time_remaining_on_point_doubler_powerup( player_team );
}

get_points_multiplier( player ) //checked matches cerberus output
{
	if(isdefined(player.shDoublePoints) && player.shDoublePoints)
	{
		return 2;
	}
	return 1;
}