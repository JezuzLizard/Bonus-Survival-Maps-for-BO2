#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_spawner;
#include maps/mp/zombies/_zm_perks;

main()
{
	if(GetDvar("zeGamemode") != "sharpshooter")
		return;
	include_powerup( "free_perk" );
	include_powerup( "weapon_upgrade" );
	replacefunc(maps/mp/zombies/_zm_powerups::init_powerups, ::init_powerups);
	replacefunc(maps/mp/zombies/_zm_spawner::zombie_death_points, ::zombie_death_points);
	replacefunc(maps/mp/zombies/_zm_perks::give_random_perk, ::give_random_perk);
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
	add_zombie_powerup( "nuke", "zombie_bomb", &"ZOMBIE_POWERUP_NUKE", ::func_should_never_drop, 0, 0, 0, "misc/fx_zombie_mini_nuke_hotness" );
	add_zombie_powerup( "insta_kill", "zombie_skull", &"ZOMBIE_POWERUP_INSTA_KILL", ::func_should_always_drop, 0, 0, 0, undefined, "powerup_instant_kill", "zombie_powerup_insta_kill_time", "zombie_powerup_insta_kill_on" );
	add_zombie_powerup( "full_ammo", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "double_points", "zombie_x2_icon", &"ZOMBIE_POWERUP_DOUBLE_POINTS", ::func_should_always_drop, 0, 0, 0, undefined, "powerup_double_points", "zombie_powerup_point_doubler_time", "zombie_powerup_point_doubler_on" );
	add_zombie_powerup( "carpenter", "zombie_carpenter", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0 );
	add_zombie_powerup( "fire_sale", "zombie_firesale", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_fire_sale", "zombie_powerup_fire_sale_time", "zombie_powerup_fire_sale_on" );
	add_zombie_powerup( "bonfire_sale", "zombie_pickup_bonfire", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_never_drop, 0, 0, 0, undefined, "powerup_bon_fire", "zombie_powerup_bonfire_sale_time", "zombie_powerup_bonfire_sale_on" );
	add_zombie_powerup( "minigun", "zombie_pickup_minigun", &"ZOMBIE_POWERUP_MINIGUN", ::func_should_never_drop, 1, 0, 0, undefined, "powerup_mini_gun", "zombie_powerup_minigun_time", "zombie_powerup_minigun_on" );
	add_zombie_powerup( "free_perk", "zombie_pickup_perk_bottle", &"ZOMBIE_POWERUP_FREE_PERK", ::func_should_never_drop, 1, 0, 0 );
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
	if(attacker perks_available())
		level thread maps/mp/zombies/_zm_powerups::specific_powerup_drop( "free_perk", origin );
}

perks_available()
{
	return 0;
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