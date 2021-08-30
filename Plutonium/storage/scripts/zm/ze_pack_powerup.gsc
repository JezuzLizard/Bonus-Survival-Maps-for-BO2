#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	add_zombie_powerup( "weapon_upgrade", "bear", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 1, 0, 0 );
	powerup_set_can_pick_up_in_last_stand( "weapon_upgrade", 0 );
}

weapon_upgrade_powerup( m_powerup, e_player)
{
	IPrintLn("get called");
}