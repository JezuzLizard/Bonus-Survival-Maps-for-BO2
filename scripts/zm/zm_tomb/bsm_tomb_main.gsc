#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_challenges;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_devgui;
#include maps\mp\zombies\_zm_powerup_zombie_blood;
#include character\c_jap_takeo_dlc4;
#include character\c_ger_richtofen_dlc4;
#include character\c_rus_nikolai_dlc4;
#include character\c_usa_dempsey_dlc4;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\_visionset_mgr;
#include maps\mp\zm_tomb_chamber;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_tomb_ee_side;
#include maps\mp\zm_tomb_ee_main;
#include maps\mp\zm_tomb_main_quest;
#include maps\mp\zm_tomb_dig;
#include maps\mp\zm_tomb_ambient_scripts;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_weap_staff_revive;
#include maps\mp\zombies\_zm_weap_riotshield_tomb;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_weap_beacon;
#include maps\mp\_sticky_grenade;
#include maps\mp\zombies\_zm_perk_random;
#include maps\mp\zm_tomb_challenges;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_magicbox_tomb;
#include maps\mp\zm_tomb_distance_tracking;
#include maps\mp\zm_tomb_achievement;
#include maps\mp\zm_tomb;
#include maps\mp\zombies\_zm_weap_staff_air;
#include maps\mp\zombies\_zm_weap_staff_lightning;
#include maps\mp\zombies\_zm_weap_staff_water;
#include maps\mp\zombies\_zm_weap_staff_fire;
#include maps\mp\zombies\_zm_weap_one_inch_punch;
#include maps\mp\zombies\_zm_perk_electric_cherry;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_perk_divetonuke;
#include maps\mp\zm_tomb_vo;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zombies\_load;
#include maps\mp\zombies\_zm_ai_quadrotor;
#include maps\mp\zombies\_zm_ai_mechz;
#include maps\mp\zm_tomb_amb;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm;
#include maps\mp\zm_tomb_giant_robot;
#include maps\mp\zm_tomb_teleporter;
#include maps\mp\zm_tomb_capture_zones;
#include maps\mp\zm_tomb_quest_fire;
#include maps\mp\zm_tomb_tank;
#include maps\mp\zm_tomb_ffotd;
#include maps\mp\zm_tomb_fx;
#include maps\mp\zm_tomb_gamemodes;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps\mp\zm_tomb_classic::zm_treasure_chest_init, ::zm_treasure_chest_init);
}

init()
{
	if(is_true(level.customMap == "vanilla"))
		return;
	level.oneInchPunchGiveFunc = maps\mp\zombies\_zm_weap_one_inch_punch::one_inch_punch_melee_attack;
	thread turn_on_power();
	thread disable_doors_trenches();
	thread add_staff_to_box();
	level thread override_zombie_count();
	level.special_weapon_magicbox_check = ::tomb_special_weapon_magicbox_check;
	if(GetDvarIntDefault("useBossZombies", 1))
	{
		flag_set("activate_zone_nml");
	}
	flag_wait( "initial_blackscreen_passed" );
	if(isdefined(level.customMap) && level.customMap == "crazyplace")
		thread openChamber();
	if(isdefined(level.customMap) && level.customMap == "trenches")
		thread deactivateTank();
}

turn_on_power()
{
	flag_wait("capture_zones_init_done" );
	foreach(zone in level.zone_capture.zones)
	{
		zone.n_current_progress = 100;
		zone maps\mp\zm_tomb_capture_zones::handle_generator_capture();
		level setclientfield( zone.script_noteworthy, 100 / 100 );
		level setclientfield( "state_" + zone.script_noteworthy, 2 );
	}
	wait 1;
	flag_set("zone_capture_in_progress");
}

add_staff_to_box()
{
	level endon("end_game");
	while(1)
	{
		level waittill("between_round_over");
		if(level.round_number == 10)
		{
			level.zombie_weapons[ "staff_air_zm" ].is_in_box = 1;
			level.limited_weapons["staff_air_zm"] = 1;
			level.zombie_weapons[ "staff_lightning_zm" ].is_in_box = 1;
			level.limited_weapons["staff_lightning_zm"] = 1;
			level.zombie_weapons[ "staff_fire_zm" ].is_in_box = 1;
			level.limited_weapons["staff_fire_zm"] = 1;
			level.zombie_weapons[ "staff_water_zm" ].is_in_box = 1;
			level.limited_weapons["staff_water_zm"] = 1;
			break;
		}
	}
}

disable_doors_trenches()
{
	flag_wait( "initial_blackscreen_passed" );
	zm_doors = getentarray( "zombie_door", "targetname" );
	for(i=0;i<zm_doors.size;i++)
	{
		if(zm_doors[i].origin == (-732, 2240, -64))
			zm_doors[i].origin = (0,0,-10000);
	}
}

tomb_special_weapon_magicbox_check( weapon ) //checked matches cerberus output
{
	if ( isDefined( level.raygun2_included ) && level.raygun2_included )
	{
		if ( weapon == "ray_gun_zm" )
		{
			if ( self has_weapon_or_upgrade( "raygun_mark2_zm" ) )
			{
				return 0;
			}
		}
		if ( weapon == "raygun_mark2_zm" )
		{
			if ( self has_weapon_or_upgrade( "ray_gun_zm" ) )
			{
				return 0;
			}
			if ( randomint( 100 ) >= 33 )
			{
				return 0;
			}
		}
	}
	if ( weapon == "beacon_zm" )
	{
		if ( isDefined( self.beacon_ready ) && self.beacon_ready )
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
	if( weapon == "staff_water_zm")
	{
		if( self has_weapon_or_upgrade( "staff_air_zm") || self has_weapon_or_upgrade( "staff_fire_zm") || self has_weapon_or_upgrade( "staff_lightning_zm") )
		{
			return 0;
		}
	}
	if( weapon == "staff_air_zm")
	{
		if( self has_weapon_or_upgrade( "staff_water_zm") || self has_weapon_or_upgrade( "staff_fire_zm") || self has_weapon_or_upgrade( "staff_lightning_zm") )
		{
			return 0;
		}
	}
	if( weapon == "staff_fire_zm")
	{
		if( self has_weapon_or_upgrade( "staff_air_zm") || self has_weapon_or_upgrade( "staff_water_zm") || self has_weapon_or_upgrade( "staff_lightning_zm") )
		{
			return 0;
		}
	}
	if( weapon == "staff_lightning_zm")
	{
		if( self has_weapon_or_upgrade( "staff_air_zm") || self has_weapon_or_upgrade( "staff_fire_zm") || self has_weapon_or_upgrade( "staff_water_zm") )
		{
			return 0;
		}
	}
	if ( isDefined( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
	{
		if ( self has_weapon_or_upgrade( level.zombie_weapons[ weapon ].shared_ammo_weapon ) )
		{
			return 0;
		}
	}
	return 1;
}

openChamber()
{
	level endon("end_game");
	while(1)
	{
		level waittill("between_round_over");
		if(level.round_number >= 5)
		{
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

zm_treasure_chest_init() //checked matches cerberus output
{
	return;
}