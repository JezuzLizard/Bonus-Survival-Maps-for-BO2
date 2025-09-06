#include maps\mp\zombies\_zm_equipment;
#include maps\mp\zombies\_zm_ai_quadrotor;
#include maps\mp\zombies\_zm_zonemgr;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_unitrigger;
#include maps\mp\zm_tomb_vo;
#include maps\mp\zm_tomb_main_quest;
#include maps\mp\zm_tomb_utility;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_craftables;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zm_tomb_craftables;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps\mp\zm_tomb_craftables::init_craftables, ::init_craftables);
}

init_craftables() //checked changed to match cerberus output
{
	precachemodel( "p6_zm_tm_quadrotor_stand" );
	flag_init( "quadrotor_cooling_down" );
	level.craftable_piece_count = 4;
	flag_init( "any_crystal_picked_up" );
	flag_init( "staff_air_zm_enabled" );
	flag_init( "staff_fire_zm_enabled" );
	flag_init( "staff_lightning_zm_enabled" );
	flag_init( "staff_water_zm_enabled" );
	register_clientfields();
	add_zombie_craftable( "tomb_shield_zm", &"ZM_TOMB_CRRI", undefined, &"ZOMBIE_BOUGHT_RIOT", undefined, 1 );
	add_zombie_craftable_vox_category( "tomb_shield_zm", "build_zs" );
	make_zombie_craftable_open( "tomb_shield_zm", "t6_wpn_zmb_shield_dlc4_dmg0_world", vectorScale( ( 0, -1, 0 ), 90 ), ( 0, 0, level.riotshield_placement_zoffset ) );
	level.zombie_craftable_persistent_weapon = ::tomb_check_crafted_weapon_persistence;
	level.custom_craftable_validation = ::tomb_custom_craftable_validation;
	level.zombie_custom_equipment_setup = ::setup_quadrotor_purchase;
	level thread hide_staff_model();
	level.quadrotor_status = spawnstruct();
	level.quadrotor_status.crafted = 0;
	level.quadrotor_status.picked_up = 0;
	level.num_staffpieces_picked_up = [];
	level.n_staffs_crafted = 0;
}