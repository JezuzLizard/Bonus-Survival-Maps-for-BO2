#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	add_zombie_powerup( "weapon_upgrade", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 1, 0, 0 );
	powerup_set_can_pick_up_in_last_stand( "weapon_upgrade", 0 );
}

weapon_upgrade_powerup( powerup, player)
{
	current_weapon = player GetCurrentWeapon();
	upgrade_name = maps/mp/zombies/_zm_weapons::get_upgrade_weapon( current_weapon );
	if(current_weapon == upgrade_name)
		return;
	player TakeWeapon(current_weapon);
	player GiveWeapon(upgrade_name);
	player SwitchToWeapon(upgrade_name);
}