#include maps\mp\zombies\_zm_chugabud;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zombies\_zm_equipment;
#include character\c_highrise_player_reporter;
#include character\c_highrise_player_engineer;
#include character\c_highrise_player_oldman;
#include character\c_highrise_player_farmgirl;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_buildables;
#include maps\mp\zombies\_zm_devgui;
#include maps\mp\gametypes_zm\_zm_gametype;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zm_highrise_distance_tracking;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zm_highrise_achievement;
#include maps\mp\zombies\_zm_weap_tazer_knuckles;
#include maps\mp\zombies\_zm_weap_slipgun;
#include maps\mp\zombies\_zm_weap_ballistic_knife;
#include maps\mp\zombies\_zm_weap_claymore;
#include maps\mp\zombies\_zm_weap_cymbal_monkey;
#include maps\mp\zombies\_zm_weap_bowie;
#include maps\mp\_sticky_grenade;
#include maps\mp\zm_highrise;
#include maps\mp\zombies\_zm_ai_leaper;
#include maps\mp\zm_highrise_classic;
#include maps\mp\gametypes_zm\_spawning;
#include maps\mp\zombies\_load;
#include maps\mp\zm_highrise_elevators;
#include maps\mp\zm_highrise_amb;
#include maps\mp\animscripts\zm_death;
#include maps\mp\zombies\_zm;
#include maps\mp\zm_highrise_utility;
#include maps\mp\zm_highrise_ffotd;
#include maps\mp\zm_highrise_fx;
#include maps\mp\zombies\_zm_banking;
#include maps\mp\zm_highrise_sq;
#include maps\mp\zm_highrise_gamemodes;
#include maps\mp\zombies\_zm_weapon_locker;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;

main()
{
	replacefunc(maps\mp\zm_highrise::setup_leapers, ::setup_leapers_custom);
}

init()
{
	custom_vending_precaching();
	level thread elevators();
}

setup_leapers_custom() //checked matches cerberus output dvar not found
{

	/*
	if ( isDefined( getDvarInt( #"60AEA36D" ) ) )
	{
		b_disable_leapers = getDvarInt( #"60AEA36D" );
	}
	*/
	if(isdefined(level.customMap) && level.customMap == "vanilla")
		maps\mp\zombies\_zm_ai_leaper::enable_leaper_rounds();
	level.leapers_per_player = 6;
}
elevators()
{
	if(level.customMap != "vanilla")
	{
		level thread override_zombie_count();
		level waittill("initial_blackscreen_passed");
		foreach(elevator in level.elevators)
		{
			elevator.body.lock_doors = 1;
			elevator.body maps\mp\zm_highrise_elevators::perkelevatordoor(0);
		}
	}
}

custom_vending_precaching() //changed at own discretion
{
	if ( is_true( level.zombiemode_using_divetonuke_perk ) )
	{
		precacheshader( "specialty_divetonuke_zombies" );
		precachemodel( "zombie_vending_nuke_on_lo" );
		level.machine_assets[ "divetonuke" ] = spawnstruct();
		level.machine_assets[ "divetonuke" ].weapon = "zombie_perk_bottle_jugg";
		level.machine_assets[ "divetonuke" ].off_model = "zombie_vending_nuke_on_lo";
		level.machine_assets[ "divetonuke" ].on_model = "zombie_vending_nuke_on_lo";
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
		if ( isdefined(level.customMap) && level.customMap == "redroom" )
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
	if ( isdefined(level.customMap) && level.customMap != "redroom" )
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