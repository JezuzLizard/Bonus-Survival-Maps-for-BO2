#include maps\mp\zombies\_zm_perks;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_perk_random;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps\mp\zombies\_zm_perk_random::init, ::init_random_perk);
	replacefunc(maps\mp\zombies\_zm_perk_random::start_random_machine, ::start_random_machine);
}

init_random_perk()
{
	machines = getentarray("random_perk_machine", "targetname");
	foreach(machine in machines)
	{
		machine.origin = (0,0,-10000);
	}
	level._random_zombie_perk_cost = 1500;
	level thread precache();
	level thread init_machines();
	registerclientfield( "scriptmover", "perk_bottle_cycle_state", 14000, 2, "int" );
	registerclientfield( "scriptmover", "turn_active_perk_light_red", 14000, 1, "int" );
	registerclientfield( "scriptmover", "turn_active_perk_light_green", 14000, 1, "int" );
	registerclientfield( "scriptmover", "turn_on_location_indicator", 14000, 1, "int" );
	registerclientfield( "scriptmover", "turn_active_perk_ball_light", 14000, 1, "int" );
	registerclientfield( "scriptmover", "zone_captured", 14000, 1, "int" );
	level._effect[ "perk_machine_light" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light" );
	level._effect[ "perk_machine_light_red" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_red" );
	level._effect[ "perk_machine_light_green" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_light_green" );
	level._effect[ "perk_machine_steam" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_steam" );
	level._effect[ "perk_machine_location" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_identify" );
	level._effect[ "perk_machine_activation_electric_loop" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_on" );
	flag_init( "machine_can_reset" );
}

start_random_machine() //checked 100% parity
{
	return;
}